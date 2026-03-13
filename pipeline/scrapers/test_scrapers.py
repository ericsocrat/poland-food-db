"""Tests for pipeline.scrapers — retailer product scrapers.

Covers: BaseScraper framework, robots.txt compliance, rate limiting,
CSV export, product validation, Biedronka HTML parsing, REWE HTML parsing.
All HTTP calls are mocked — no real network access.
"""

from __future__ import annotations

import csv
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from pipeline.scrapers.base import CSV_COLUMNS, BaseScraper
from pipeline.scrapers.biedronka import BiedronkaScraper, _parse_numeric
from pipeline.scrapers.rewe import REWEScraper, _parse_de_numeric

# ── Test fixtures ─────────────────────────────────────────────────────


class FakeScraper(BaseScraper):
    """Concrete subclass for testing the abstract BaseScraper."""

    DELAY_SECONDS: float = 0.0  # No delay in tests

    def get_base_url(self) -> str:
        return "https://example.com"

    def get_category_urls(self) -> list[str]:
        return ["https://example.com/cat/food"]

    def parse_product_list(self, html: str, url: str) -> list[str]:
        return ["https://example.com/products/1"]

    def parse_product_page(self, html: str, url: str) -> dict | None:
        return {
            "ean": "5901234567893",
            "brand": "Test",
            "product_name": "Test Product",
            "category": "Dairy",
        }


# ── BaseScraper tests ─────────────────────────────────────────────────


class TestBaseScraper:
    def test_init_valid_country(self) -> None:
        s = FakeScraper(country="PL")
        assert s.country == "PL"
        assert s.max_products <= BaseScraper.MAX_PRODUCTS_PER_RUN

    def test_init_invalid_country(self) -> None:
        with pytest.raises(ValueError, match="country must be"):
            FakeScraper(country="US")

    def test_max_products_capped(self) -> None:
        s = FakeScraper(country="PL", max_products=999999)
        assert s.max_products == BaseScraper.MAX_PRODUCTS_PER_RUN

    def test_validate_product_valid(self) -> None:
        p = {"ean": "5901234567893", "product_name": "X", "brand": "Y"}
        assert BaseScraper._validate_product(p) is True

    def test_validate_product_missing_ean(self) -> None:
        p = {"product_name": "X", "brand": "Y"}
        assert BaseScraper._validate_product(p) is False

    def test_validate_product_missing_name(self) -> None:
        p = {"ean": "5901234567893", "brand": "Y"}
        assert BaseScraper._validate_product(p) is False

    def test_validate_product_missing_brand(self) -> None:
        p = {"ean": "5901234567893", "product_name": "X"}
        assert BaseScraper._validate_product(p) is False


class TestRobotsTxt:
    @patch("urllib.robotparser.RobotFileParser.read")
    @patch("urllib.robotparser.RobotFileParser.can_fetch", return_value=True)
    def test_robots_allowed(self, mock_can_fetch: MagicMock, mock_read: MagicMock) -> None:
        s = FakeScraper(country="PL")
        assert s.check_robots_txt() is True
        assert s._robots_allowed is True

    @patch("urllib.robotparser.RobotFileParser.read")
    @patch("urllib.robotparser.RobotFileParser.can_fetch", return_value=False)
    def test_robots_disallowed(self, mock_can_fetch: MagicMock, mock_read: MagicMock) -> None:
        s = FakeScraper(country="PL")
        assert s.check_robots_txt() is False

    @patch("urllib.robotparser.RobotFileParser.read", side_effect=Exception("network"))
    def test_robots_fetch_error_allows(self, mock_read: MagicMock) -> None:
        s = FakeScraper(country="PL")
        assert s.check_robots_txt() is True  # graceful fallback


class TestPoliteGet:
    @patch.object(FakeScraper, "is_path_allowed", return_value=True)
    def test_successful_get(self, mock_allowed: MagicMock) -> None:
        s = FakeScraper(country="PL")
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.text = "<html>OK</html>"
        s._session.get = MagicMock(return_value=mock_resp)

        result = s.polite_get("https://example.com/page")
        assert result == "<html>OK</html>"

    @patch.object(FakeScraper, "is_path_allowed", return_value=False)
    def test_disallowed_path_skipped(self, mock_allowed: MagicMock) -> None:
        s = FakeScraper(country="PL")
        result = s.polite_get("https://example.com/private")
        assert result is None
        assert s.stats["skipped"] == 1

    @patch.object(FakeScraper, "is_path_allowed", return_value=True)
    def test_404_returns_none(self, mock_allowed: MagicMock) -> None:
        s = FakeScraper(country="PL")
        mock_resp = MagicMock()
        mock_resp.status_code = 404
        s._session.get = MagicMock(return_value=mock_resp)

        result = s.polite_get("https://example.com/missing")
        assert result is None
        assert s.stats["skipped"] == 1


class TestCSVExport:
    def test_csv_export_creates_file(self, tmp_path: Path) -> None:
        s = FakeScraper(country="PL", output_dir=str(tmp_path))
        products = [
            {
                "ean": "5901234567893",
                "brand": "TestBrand",
                "product_name": "Test Yogurt",
                "category": "Dairy",
                "country": "PL",
                "calories_kcal": 65,
                "total_fat_g": 3.2,
            },
        ]
        path = s.to_csv(products, filename="test_out.csv")
        assert Path(path).exists()

        with open(path, encoding="utf-8") as f:
            reader = csv.DictReader(f)
            rows = list(reader)
            assert len(rows) == 1
            assert rows[0]["ean"] == "5901234567893"
            assert rows[0]["brand"] == "TestBrand"

    def test_csv_has_all_columns(self, tmp_path: Path) -> None:
        s = FakeScraper(country="PL", output_dir=str(tmp_path))
        product = {"ean": "1234567890123", "brand": "X", "product_name": "Y", "category": "Dairy", "country": "PL"}
        path = s.to_csv([product])
        with open(path, encoding="utf-8") as f:
            reader = csv.reader(f)
            header = next(reader)
            assert header == CSV_COLUMNS


class TestScrapeAll:
    @patch.object(FakeScraper, "check_robots_txt", return_value=False)
    def test_robots_blocked_returns_empty(self, mock_robots: MagicMock) -> None:
        s = FakeScraper(country="PL")
        result = s.scrape_all()
        assert result == []

    @patch.object(FakeScraper, "check_robots_txt", return_value=True)
    @patch.object(FakeScraper, "polite_get")
    def test_scrape_all_collects_products(self, mock_get: MagicMock, mock_robots: MagicMock) -> None:
        s = FakeScraper(country="PL", max_products=1)
        # First call = category page, second call = product page
        mock_get.side_effect = ["<html>list</html>", "<html>product</html>"]
        result = s.scrape_all()
        assert len(result) == 1
        assert result[0]["country"] == "PL"
        assert result[0]["ean"] == "5901234567893"


# ── Biedronka scraper tests ──────────────────────────────────────────


class TestBiedronkaScraper:
    def test_base_url(self) -> None:
        s = BiedronkaScraper(country="PL")
        assert "bfrisco.pl" in s.get_base_url()

    def test_category_urls_not_empty(self) -> None:
        s = BiedronkaScraper(country="PL")
        urls = s.get_category_urls()
        assert len(urls) > 0
        assert all("bfrisco.pl" in u for u in urls)

    def test_parse_product_list_empty_html(self) -> None:
        s = BiedronkaScraper(country="PL")
        urls = s.parse_product_list("<html><body></body></html>", "https://bfrisco.pl/cat")
        assert urls == []

    def test_parse_product_list_with_links(self) -> None:
        html = """
        <html><body>
            <a class="product-card__link" href="/produkt/mleko-2-500ml">Mleko</a>
            <a class="product-card__link" href="/produkt/jogurt-naturalny">Jogurt</a>
        </body></html>
        """
        s = BiedronkaScraper(country="PL")
        urls = s.parse_product_list(html, "https://www.bfrisco.pl/kategoria/nabial")
        assert len(urls) == 2
        assert all("/produkt/" in u for u in urls)

    def test_parse_product_page_with_nutrition(self) -> None:
        html = """
        <html><body>
            <h1 class="product-detail__name">Jogurt Naturalny 400g</h1>
            <span class="product-detail__brand">Piątnica</span>
            <meta itemprop="gtin13" content="5900820000123">
            <table class="nutrition-table">
                <tr><td>Wartość energetyczna</td><td>263 kJ / 63 kcal</td></tr>
                <tr><td>Tłuszcz</td><td>3,2 g</td></tr>
                <tr><td>Kwasy tłuszczowe nasycone</td><td>2,1 g</td></tr>
                <tr><td>Węglowodany</td><td>4,6 g</td></tr>
                <tr><td>Cukry</td><td>4,6 g</td></tr>
                <tr><td>Białko</td><td>5,5 g</td></tr>
                <tr><td>Sól</td><td>0,13 g</td></tr>
            </table>
        </body></html>
        """
        s = BiedronkaScraper(country="PL")
        p = s.parse_product_page(html, "https://www.bfrisco.pl/produkt/jogurt-naturalny")
        assert p is not None
        assert p["product_name"] == "Jogurt Naturalny 400g"
        assert p["brand"] == "Piątnica"
        assert p["ean"] == "5900820000123"
        assert p["calories_kcal"] == 63.0
        assert p["total_fat_g"] == 3.2
        assert p["protein_g"] == 5.5

    def test_parse_product_page_no_ean_returns_none(self) -> None:
        html = """
        <html><body>
            <h1 class="product-detail__name">Jogurt</h1>
            <span class="product-detail__brand">Brand</span>
        </body></html>
        """
        s = BiedronkaScraper(country="PL")
        assert s.parse_product_page(html, "https://bfrisco.pl/p/x") is None


class TestParseNumeric:
    def test_plain_number(self) -> None:
        assert _parse_numeric("12.5") == 12.5

    def test_polish_decimal(self) -> None:
        assert _parse_numeric("3,2 g") == 3.2

    def test_kcal_slash(self) -> None:
        assert _parse_numeric("263 kJ / 63 kcal") == 63.0

    def test_invalid(self) -> None:
        assert _parse_numeric("N/A") is None


# ── REWE scraper tests ────────────────────────────────────────────────


class TestREWEScraper:
    def test_base_url(self) -> None:
        s = REWEScraper(country="DE")
        assert "rewe.de" in s.get_base_url()

    def test_category_urls_not_empty(self) -> None:
        s = REWEScraper(country="DE")
        urls = s.get_category_urls()
        assert len(urls) > 0
        assert all("rewe.de" in u for u in urls)

    def test_parse_product_list_empty(self) -> None:
        s = REWEScraper(country="DE")
        urls = s.parse_product_list("<html></html>", "https://rewe.de/c/x/")
        assert urls == []

    def test_parse_product_page_with_nutrition(self) -> None:
        html = """
        <html><body>
            <h1 class="rs-qa-product-name">REWE Bio Vollmilch 3,5%</h1>
            <span class="rs-qa-manufacturer">REWE Bio</span>
            <meta itemprop="gtin13" content="4388860123456">
            <table class="nutrition-table">
                <tr><td>Brennwert</td><td>276 kJ / 66 kcal</td></tr>
                <tr><td>Fett</td><td>3,5 g</td></tr>
                <tr><td>davon gesättigte Fettsäuren</td><td>2,3 g</td></tr>
                <tr><td>Kohlenhydrate</td><td>4,8 g</td></tr>
                <tr><td>davon Zucker</td><td>4,8 g</td></tr>
                <tr><td>Eiweiß</td><td>3,3 g</td></tr>
                <tr><td>Salz</td><td>0,13 g</td></tr>
            </table>
        </body></html>
        """
        s = REWEScraper(country="DE")
        p = s.parse_product_page(html, "https://www.rewe.de/p/bio-vollmilch/123")
        assert p is not None
        assert p["product_name"] == "REWE Bio Vollmilch 3,5%"
        assert p["brand"] == "REWE Bio"
        assert p["ean"] == "4388860123456"
        assert p["calories_kcal"] == 66.0
        assert p["total_fat_g"] == 3.5
        assert p["saturated_fat_g"] == 2.3
        assert p["protein_g"] == 3.3


class TestParseDeNumeric:
    def test_german_decimal(self) -> None:
        assert _parse_de_numeric("3,5 g") == 3.5

    def test_kcal_slash(self) -> None:
        assert _parse_de_numeric("276 kJ / 66 kcal") == 66.0

    def test_less_than(self) -> None:
        assert _parse_de_numeric("<0,1 g") == 0.1

    def test_invalid(self) -> None:
        assert _parse_de_numeric("k.A.") is None
