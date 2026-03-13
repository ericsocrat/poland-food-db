"""Scraper for REWE products via rewe.de.

REWE is one of Germany's largest supermarket chains. Their website
provides product pages with EAN, nutrition tables, and ingredients.
"""

from __future__ import annotations

import logging
import re

from pipeline.scrapers.base import BaseScraper

logger = logging.getLogger(__name__)

# REWE category slugs → TryVit category mapping.
REWE_CATEGORIES: dict[str, str] = {
    "milch-milchprodukte": "Dairy",
    "brot-backwaren": "Bread",
    "getraenke": "Drinks",
    "suesswaren-knabbereien": "Sweets",
    "fleisch-wurst": "Meat",
    "tiefkuehlkost": "Frozen & Prepared",
    "cerealien-muesli": "Cereals",
    "konserven": "Canned Goods",
    "saucen-gewuerze": "Sauces",
    "oele-essig": "Oils & Vinegars",
    "fisch-meeresfruechte": "Seafood & Fish",
    "babynahrung": "Baby",
    "fertiggerichte": "Instant & Frozen",
    "nuesse-trockenobst": "Nuts, Seeds & Legumes",
    "brotaufstriche": "Spreads & Dips",
    "chips-salzgebaeck": "Chips",
    "wurstwaren": "Condiments",
}


class REWEScraper(BaseScraper):
    """Scraper for REWE products via rewe.de."""

    BASE_URL = "https://www.rewe.de"

    def get_base_url(self) -> str:
        return self.BASE_URL

    def get_category_urls(self) -> list[str]:
        """Return category listing URLs for food products."""
        return [
            f"{self.BASE_URL}/c/{slug}/"
            for slug in REWE_CATEGORIES
        ]

    def parse_product_list(self, html: str, url: str) -> list[str]:
        """Extract product URLs from a REWE category listing page."""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            logger.error("beautifulsoup4 is required: pip install beautifulsoup4")
            return []

        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        for link in soup.select("a.search-service-productDetailsLink, a[href*='/p/']"):
            href = link.get("href", "")
            if href and "/p/" in href:
                if href.startswith("/"):
                    href = f"{self.BASE_URL}{href}"
                urls.append(href)
        return urls

    def parse_product_page(self, html: str, url: str) -> dict | None:
        """Extract product data from a REWE product detail page."""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            return None

        soup = BeautifulSoup(html, "html.parser")

        # --- Product name ---
        name_el = soup.select_one("h1.rs-qa-product-name, h1[data-qa='product-name']")
        product_name = name_el.get_text(strip=True) if name_el else None
        if not product_name:
            return None

        # --- Brand ---
        brand_el = soup.select_one(".rs-qa-manufacturer, [data-qa='manufacturer']")
        brand = brand_el.get_text(strip=True) if brand_el else "REWE"

        # --- EAN ---
        ean = self._extract_ean(soup, html)
        if not ean:
            return None

        # --- Category ---
        category = self._detect_category(url)

        # --- Nutrition table ---
        nutrition = self._extract_nutrition(soup)

        # --- Ingredients ---
        ingredients = self._extract_ingredients(soup)

        product: dict = {
            "ean": ean,
            "brand": brand,
            "product_name": product_name,
            "category": category,
            "store_availability": "REWE",
        }
        product.update(nutrition)
        if ingredients:
            product["ingredients_text"] = ingredients

        return product

    # ── Private helpers ───────────────────────────────────────────────

    def _detect_category(self, url: str) -> str:
        """Map URL path to TryVit category."""
        for slug, cat in REWE_CATEGORIES.items():
            if slug in url:
                return cat
        return "Snacks"

    @staticmethod
    def _extract_ean(soup, html: str) -> str | None:
        """Extract EAN-13 barcode from page metadata or structured data."""
        for meta in soup.select("meta[itemprop='gtin13'], meta[property='product:ean']"):
            val = meta.get("content", "").strip()
            if val and len(val) in (8, 13) and val.isdigit():
                return val

        for el in soup.select("[data-ean], [data-product-ean]"):
            val = (el.get("data-ean") or el.get("data-product-ean") or "").strip()
            if val and len(val) in (8, 13) and val.isdigit():
                return val

        ean_match = re.search(r'"gtin13"\s*:\s*"(\d{13})"', html)
        if ean_match:
            return ean_match.group(1)

        return None

    @staticmethod
    def _extract_nutrition(soup) -> dict:
        """Extract per-100g nutrition from the REWE nutrition table."""
        result: dict = {}
        table = soup.select_one(".nutrition-table, .pdd-NutritionTable table")
        if not table:
            return result

        nutrient_map = {
            "brennwert": "calories_kcal",
            "energie": "calories_kcal",
            "fett": "total_fat_g",
            "gesättigte fettsäuren": "saturated_fat_g",
            "davon gesättigte": "saturated_fat_g",
            "kohlenhydrate": "carbs_g",
            "zucker": "sugars_g",
            "davon zucker": "sugars_g",
            "ballaststoffe": "fibre_g",
            "eiweiß": "protein_g",
            "salz": "salt_g",
        }

        for row in table.select("tr"):
            cells = row.select("td, th")
            if len(cells) < 2:
                continue
            label = cells[0].get_text(strip=True).lower()
            value_text = cells[1].get_text(strip=True)

            for de_name, csv_key in sorted(
                nutrient_map.items(), key=lambda x: len(x[0]), reverse=True
            ):
                if de_name in label:
                    val = _parse_de_numeric(value_text)
                    if val is not None:
                        result[csv_key] = val
                    break

        return result

    @staticmethod
    def _extract_ingredients(soup) -> str | None:
        """Extract ingredients text from the product page."""
        for selector in (
            ".pdd-Ingredients",
            "[data-qa='ingredients']",
            ".ingredients-section",
        ):
            el = soup.select_one(selector)
            if el:
                text = el.get_text(strip=True)
                if text:
                    return text
        return None


def _parse_de_numeric(text: str) -> float | None:
    """Parse a numeric value from German-format text like '12,5 g' or '450 kcal'.

    Handles German decimal separator (comma → dot).
    """
    cleaned = re.sub(r"[a-zA-Zμ%<>~]+", "", text).strip()
    cleaned = cleaned.replace(",", ".")
    if "/" in cleaned:
        parts = cleaned.split("/")
        cleaned = parts[-1].strip()
    try:
        return float(cleaned)
    except ValueError:
        return None
