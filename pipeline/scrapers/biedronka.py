"""Scraper for Biedronka products via bfrisco.pl (Biedronka's online platform).

bfrisco.pl is the online grocery arm of Biedronka (Jeronimo Martins).
Product pages include EAN barcodes, nutrition tables, and ingredient lists.
"""

from __future__ import annotations

import logging
import re

from pipeline.scrapers.base import BaseScraper

logger = logging.getLogger(__name__)

# Category slugs on bfrisco.pl → TryVit category mapping.
BFRISCO_CATEGORIES: dict[str, str] = {
    "nabiał-jaja-i-masło": "Dairy",
    "pieczywo": "Bread",
    "napoje": "Drinks",
    "słodycze-i-przekąski": "Sweets",
    "mięso-wędliny-i-drób": "Meat",
    "mrożonki": "Frozen & Prepared",
    "płatki-musli-i-otręby": "Cereals",
    "konserwy-i-przetwory": "Canned Goods",
    "sosy-i-przyprawy": "Sauces",
    "oliwy-oleje-i-octy": "Oils & Vinegars",
    "ryby-i-owoce-morza": "Seafood & Fish",
    "żywność-dla-dzieci": "Baby",
    "produkty-instant": "Instant & Frozen",
    "orzechy-i-bakalie": "Nuts, Seeds & Legumes",
    "dżemy-miody-i-pasty": "Spreads & Dips",
    "chipsy-i-krakersy": "Chips",
}


class BiedronkaScraper(BaseScraper):
    """Scraper for Biedronka products via bfrisco.pl."""

    BASE_URL = "https://www.bfrisco.pl"

    def get_base_url(self) -> str:
        return self.BASE_URL

    def get_category_urls(self) -> list[str]:
        """Return category listing URLs for food products."""
        return [
            f"{self.BASE_URL}/kategoria/{slug}"
            for slug in BFRISCO_CATEGORIES
        ]

    def parse_product_list(self, html: str, url: str) -> list[str]:
        """Extract product detail page URLs from a category listing page."""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            logger.error("beautifulsoup4 is required: pip install beautifulsoup4")
            return []

        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        for link in soup.select("a.product-card__link, a[data-product-url]"):
            href = link.get("href", "")
            if href and "/produkt/" in href:
                if href.startswith("/"):
                    href = f"{self.BASE_URL}{href}"
                urls.append(href)
        return urls

    def parse_product_page(self, html: str, url: str) -> dict | None:
        """Extract product data from a bfrisco.pl product detail page."""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            return None

        soup = BeautifulSoup(html, "html.parser")

        # --- Product name ---
        name_el = soup.select_one("h1.product-detail__name, h1[data-product-name]")
        product_name = name_el.get_text(strip=True) if name_el else None
        if not product_name:
            return None

        # --- Brand ---
        brand_el = soup.select_one("span.product-detail__brand, [data-product-brand]")
        brand = brand_el.get_text(strip=True) if brand_el else "Biedronka"

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
            "store_availability": "Biedronka",
        }
        product.update(nutrition)
        if ingredients:
            product["ingredients_text"] = ingredients

        return product

    # ── Private helpers ───────────────────────────────────────────────

    def _detect_category(self, url: str) -> str:
        """Map URL path to TryVit category."""
        for slug, cat in BFRISCO_CATEGORIES.items():
            if slug in url:
                return cat
        return "Snacks"  # fallback

    @staticmethod
    def _extract_ean(soup, html: str) -> str | None:
        """Extract EAN-13 barcode from page metadata or structured data."""
        # Try meta tags
        for meta in soup.select("meta[itemprop='gtin13'], meta[property='product:ean']"):
            val = meta.get("content", "").strip()
            if val and len(val) in (8, 13) and val.isdigit():
                return val

        # Try data attributes
        for el in soup.select("[data-ean], [data-product-ean]"):
            val = (el.get("data-ean") or el.get("data-product-ean") or "").strip()
            if val and len(val) in (8, 13) and val.isdigit():
                return val

        # Try JSON-LD structured data
        ean_match = re.search(r'"gtin13"\s*:\s*"(\d{13})"', html)
        if ean_match:
            return ean_match.group(1)

        return None

    @staticmethod
    def _extract_nutrition(soup) -> dict:
        """Extract per-100g nutrition from the product page nutrition table."""
        result: dict = {}
        table = soup.select_one("table.nutrition-table, .product-nutrition table")
        if not table:
            return result

        nutrient_map = {
            "wartość energetyczna": "calories_kcal",
            "energia": "calories_kcal",
            "tłuszcz": "total_fat_g",
            "kwasy tłuszczowe nasycone": "saturated_fat_g",
            "węglowodany": "carbs_g",
            "cukry": "sugars_g",
            "błonnik": "fibre_g",
            "białko": "protein_g",
            "sól": "salt_g",
        }

        for row in table.select("tr"):
            cells = row.select("td, th")
            if len(cells) < 2:
                continue
            label = cells[0].get_text(strip=True).lower()
            value_text = cells[1].get_text(strip=True)

            for pl_name, csv_key in sorted(
                nutrient_map.items(), key=lambda x: len(x[0]), reverse=True
            ):
                if pl_name in label:
                    val = _parse_numeric(value_text)
                    if val is not None:
                        result[csv_key] = val
                    break

        return result

    @staticmethod
    def _extract_ingredients(soup) -> str | None:
        """Extract ingredients text from the product page."""
        for selector in (
            ".product-ingredients",
            "[data-ingredients]",
            ".ingredients-list",
        ):
            el = soup.select_one(selector)
            if el:
                text = el.get_text(strip=True)
                if text:
                    return text
        return None


def _parse_numeric(text: str) -> float | None:
    """Parse a numeric value from text like '12,5 g' or '450 kcal'."""
    # Remove units and whitespace
    cleaned = re.sub(r"[a-zA-Zμ%]+", "", text).strip()
    # Handle Polish decimal separator
    cleaned = cleaned.replace(",", ".")
    # Handle ranges like "1200/287" (kJ/kcal) — take last number
    if "/" in cleaned:
        parts = cleaned.split("/")
        cleaned = parts[-1].strip()
    try:
        return float(cleaned)
    except ValueError:
        return None
