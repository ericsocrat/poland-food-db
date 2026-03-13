"""CLI entry point for the retailer product scrapers.

Usage::

    python -m pipeline.scrape --retailer biedronka --max-products 500
    python -m pipeline.scrape --retailer rewe --max-products 500 --dry-run
    python -m pipeline.scrape --retailer biedronka --output-dir db/pipelines/scraper-biedronka
"""

from __future__ import annotations

import argparse
import sys

from pipeline.scrapers.base import BaseScraper

# Registry of available scrapers — import lazily to keep CLI fast.
SCRAPERS: dict[str, tuple[str, str]] = {
    "biedronka": ("pipeline.scrapers.biedronka", "BiedronkaScraper"),
    "rewe": ("pipeline.scrapers.rewe", "REWEScraper"),
}


def _load_scraper(name: str) -> type[BaseScraper]:
    """Dynamically import and return a scraper class by registry name."""
    if name not in SCRAPERS:
        print(f"Unknown retailer: {name!r}", file=sys.stderr)
        print(f"Available: {', '.join(sorted(SCRAPERS))}", file=sys.stderr)
        sys.exit(1)
    module_path, class_name = SCRAPERS[name]
    import importlib

    module = importlib.import_module(module_path)
    return getattr(module, class_name)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Scrape retailer websites for product data and export to CSV.",
    )
    parser.add_argument(
        "--retailer",
        required=True,
        choices=sorted(SCRAPERS),
        help="Retailer to scrape.",
    )
    parser.add_argument(
        "--max-products",
        type=int,
        default=500,
        help="Maximum products to scrape (default: 500).",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Directory for output CSV (default: db/pipelines/scraper-<retailer>/).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Scrape and validate without writing CSV files.",
    )
    args = parser.parse_args()

    scraper_cls = _load_scraper(args.retailer)

    # Infer country from the scraper class
    country_map = {"biedronka": "PL", "rewe": "DE"}
    country = country_map.get(args.retailer, "PL")

    output_dir = args.output_dir or f"db/pipelines/scraper-{args.retailer}"

    scraper = scraper_cls(
        country=country,
        output_dir=output_dir,
        max_products=args.max_products,
        dry_run=args.dry_run,
    )

    print(f"Scraping {args.retailer} ({country}) — max {args.max_products} products")
    if args.dry_run:
        print("  DRY RUN — no files will be written")

    products = scraper.scrape_all()

    print()
    print("Scrape Summary")
    print("=" * 40)
    print(f"  Products scraped:  {len(products)}")

    if not products:
        print("  No products found.")
        sys.exit(0)

    if args.dry_run:
        print("  Dry run complete — no CSV written.")
        sys.exit(0)

    csv_path = scraper.to_csv(products)
    print(f"  CSV written:       {csv_path}")
    print()
    print("Next step: import this CSV via the pipeline:")
    print(f"  python -m pipeline.csv_import --file {csv_path}")


if __name__ == "__main__":
    main()
