"""Abstract base scraper with robots.txt compliance, rate limiting, and CSV export.

All retailer scrapers inherit from BaseScraper, which enforces:
  - robots.txt checking before any request
  - Minimum 2-second delay between requests (polite scraping)
  - User-Agent identification for webmaster transparency
  - CSV output compatible with the CSVImporter (#862)
  - Per-run product cap to prevent runaway scraping
"""

from __future__ import annotations

import csv
import logging
import os
import time
import urllib.robotparser
from abc import ABC, abstractmethod
from pathlib import Path

import requests

logger = logging.getLogger(__name__)

# CSV columns matching the CSVImporter schema (#862).
CSV_COLUMNS = [
    "ean",
    "brand",
    "product_name",
    "category",
    "country",
    "calories_kcal",
    "total_fat_g",
    "saturated_fat_g",
    "carbs_g",
    "sugars_g",
    "fibre_g",
    "protein_g",
    "salt_g",
    "trans_fat_g",
    "nutri_score_label",
    "nova_group",
    "ingredients_text",
    "product_type",
    "prep_method",
    "store_availability",
    "controversies",
]


class ScrapingAbortedError(Exception):
    """Raised when too many consecutive errors occur."""


class BaseScraper(ABC):
    """Abstract base for all retailer product scrapers.

    Subclasses must implement:
      - get_base_url()       → retailer root URL
      - get_category_urls()  → list of category page URLs to crawl
      - parse_product_list() → extract product page URLs from category page
      - parse_product_page() → extract product data from product detail page
    """

    DELAY_SECONDS: float = 2.0
    USER_AGENT: str = "TryVitBot/1.0 (+https://github.com/ericsocrat/tryvit)"
    MAX_PRODUCTS_PER_RUN: int = 5000
    MAX_CONSECUTIVE_ERRORS: int = 10
    MAX_RETRIES: int = 3
    BACKOFF_429_SECONDS: float = 60.0

    def __init__(
        self,
        country: str,
        output_dir: str = "scraper_output",
        *,
        max_products: int | None = None,
        dry_run: bool = False,
    ) -> None:
        if country not in ("PL", "DE"):
            msg = f"country must be 'PL' or 'DE', got {country!r}"
            raise ValueError(msg)
        self.country = country
        self.output_dir = output_dir
        self.max_products = min(max_products or self.MAX_PRODUCTS_PER_RUN, self.MAX_PRODUCTS_PER_RUN)
        self.dry_run = dry_run
        self._robot_parser: urllib.robotparser.RobotFileParser | None = None
        self._robots_allowed: bool | None = None
        self._last_request_time: float = 0.0
        self._session = requests.Session()
        self._session.headers.update({"User-Agent": self.USER_AGENT})
        self.stats = {"fetched": 0, "valid": 0, "skipped": 0, "errors": 0}
        self._consecutive_errors = 0

    # ── Abstract interface ────────────────────────────────────────────

    @abstractmethod
    def get_base_url(self) -> str:
        """Return the retailer's root URL (e.g. 'https://bfrisco.pl')."""

    @abstractmethod
    def get_category_urls(self) -> list[str]:
        """Return list of category/listing page URLs to crawl."""

    @abstractmethod
    def parse_product_list(self, html: str, url: str) -> list[str]:
        """Extract product detail page URLs from a category/listing page."""

    @abstractmethod
    def parse_product_page(self, html: str, url: str) -> dict | None:
        """Parse a single product page into a dict with CSV-compatible keys.

        Must return at minimum: ean, brand, product_name, category
        The country and source fields are added automatically.
        Return None to skip the product.
        """

    # ── robots.txt ────────────────────────────────────────────────────

    def check_robots_txt(self, url: str | None = None) -> bool:
        """Check robots.txt for the base domain. Returns True if allowed."""
        if self._robots_allowed is not None:
            return self._robots_allowed

        base = url or self.get_base_url()
        robots_url = f"{base.rstrip('/')}/robots.txt"
        rp = urllib.robotparser.RobotFileParser()
        rp.set_url(robots_url)
        try:
            rp.read()
        except Exception:
            logger.warning("Could not fetch robots.txt from %s — assuming allowed", robots_url)
            self._robots_allowed = True
            return True

        self._robot_parser = rp
        self._robots_allowed = rp.can_fetch(self.USER_AGENT, base)
        if not self._robots_allowed:
            logger.warning("robots.txt DISALLOWS scraping %s for %s", base, self.USER_AGENT)
        return self._robots_allowed

    def is_path_allowed(self, url: str) -> bool:
        """Check if a specific URL path is allowed by robots.txt."""
        if self._robot_parser is None:
            return self.check_robots_txt()
        return self._robot_parser.can_fetch(self.USER_AGENT, url)

    # ── HTTP with rate limiting ───────────────────────────────────────

    def _wait_for_delay(self) -> None:
        """Enforce minimum delay between requests."""
        elapsed = time.monotonic() - self._last_request_time
        if elapsed < self.DELAY_SECONDS:
            time.sleep(self.DELAY_SECONDS - elapsed)

    def polite_get(self, url: str) -> str | None:
        """GET a URL with rate limiting, retry on 5xx, robots.txt respect.

        Returns HTML string or None on failure.
        """
        if not self.is_path_allowed(url):
            logger.info("Skipping disallowed URL: %s", url)
            self.stats["skipped"] += 1
            return None

        for attempt in range(1, self.MAX_RETRIES + 1):
            self._wait_for_delay()
            self._last_request_time = time.monotonic()
            try:
                resp = self._session.get(url, timeout=30)
            except requests.RequestException as exc:
                logger.warning("Request error on %s (attempt %d): %s", url, attempt, exc)
                if attempt == self.MAX_RETRIES:
                    self.stats["errors"] += 1
                    return None
                time.sleep(self.DELAY_SECONDS * attempt)
                continue

            if resp.status_code == 200:
                self._consecutive_errors = 0
                return resp.text

            if resp.status_code == 404:
                logger.debug("404 for %s — skipping", url)
                self.stats["skipped"] += 1
                return None

            if resp.status_code == 429:
                logger.warning("Rate limited (429) on %s — backing off %.0fs", url, self.BACKOFF_429_SECONDS)
                time.sleep(self.BACKOFF_429_SECONDS)
                if attempt == self.MAX_RETRIES:
                    self.stats["errors"] += 1
                    return None
                continue

            if resp.status_code >= 500:
                logger.warning("Server error %d on %s (attempt %d)", resp.status_code, url, attempt)
                if attempt == self.MAX_RETRIES:
                    self.stats["errors"] += 1
                    return None
                time.sleep(self.DELAY_SECONDS * (2 ** attempt))
                continue

            # Other client errors (403, etc.)
            logger.warning("HTTP %d for %s — skipping", resp.status_code, url)
            self.stats["skipped"] += 1
            return None

        self.stats["errors"] += 1
        return None

    # ── Main scrape loop ──────────────────────────────────────────────

    def scrape_all(self) -> list[dict]:
        """Discover and scrape products from all category pages.

        Returns list of validated product dicts.
        """
        if not self.check_robots_txt():
            logger.error("Aborting: robots.txt disallows scraping %s", self.get_base_url())
            return []

        products: list[dict] = []
        category_urls = self.get_category_urls()
        logger.info(
            "Scraping %d categories from %s (max %d products)",
            len(category_urls), self.get_base_url(), self.max_products,
        )

        for cat_url in category_urls:
            if len(products) >= self.max_products:
                break

            html = self.polite_get(cat_url)
            if html is None:
                continue

            product_urls = self.parse_product_list(html, cat_url)
            logger.info("Found %d product URLs on %s", len(product_urls), cat_url)

            for prod_url in product_urls:
                if len(products) >= self.max_products:
                    break

                if self._consecutive_errors >= self.MAX_CONSECUTIVE_ERRORS:
                    logger.error("Aborting: %d consecutive errors", self._consecutive_errors)
                    raise ScrapingAbortedError(f"{self._consecutive_errors} consecutive errors")

                prod_html = self.polite_get(prod_url)
                if prod_html is None:
                    self._consecutive_errors += 1
                    continue

                self.stats["fetched"] += 1
                try:
                    product = self.parse_product_page(prod_html, prod_url)
                except Exception:
                    logger.exception("Parse error for %s", prod_url)
                    self.stats["errors"] += 1
                    self._consecutive_errors += 1
                    continue

                if product is None:
                    self.stats["skipped"] += 1
                    continue

                if not self._validate_product(product):
                    self.stats["skipped"] += 1
                    continue

                # Enrich with country and source provenance
                product["country"] = self.country
                product.setdefault("source_url", prod_url)
                product.setdefault("prep_method", "not-applicable")
                product.setdefault("controversies", "none")

                products.append(product)
                self.stats["valid"] += 1
                self._consecutive_errors = 0

        logger.info(
            "Scrape complete: %d valid / %d fetched / %d skipped / %d errors",
            self.stats["valid"],
            self.stats["fetched"],
            self.stats["skipped"],
            self.stats["errors"],
        )
        return products

    # ── Validation ────────────────────────────────────────────────────

    @staticmethod
    def _validate_product(product: dict) -> bool:
        """Basic validation — EAN and product_name are mandatory."""
        ean = product.get("ean", "")
        if not ean or not isinstance(ean, str):
            logger.debug("Skipping product without EAN")
            return False
        if not product.get("product_name"):
            logger.debug("Skipping product without name")
            return False
        if not product.get("brand"):
            logger.debug("Skipping product without brand")
            return False
        return True

    # ── CSV export ────────────────────────────────────────────────────

    def to_csv(self, products: list[dict], filename: str | None = None) -> str:
        """Export products to CSV compatible with CSVImporter (#862).

        Returns the path to the written CSV file.
        """
        if not filename:
            retailer = type(self).__name__.lower().replace("scraper", "")
            filename = f"{retailer}_{self.country}_{len(products)}.csv"

        os.makedirs(self.output_dir, exist_ok=True)
        path = str(Path(self.output_dir) / filename)

        with open(path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=CSV_COLUMNS, extrasaction="ignore")
            writer.writeheader()
            for p in products:
                writer.writerow(p)

        logger.info("Wrote %d products to %s", len(products), path)
        return path
