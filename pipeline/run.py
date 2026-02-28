"""CLI entry point for the poland-food-db Open Food Facts pipeline.

Usage::

    python -m pipeline.run --category "Dairy" --max-products 30
    python -m pipeline.run --category "Chips" --dry-run
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

from tqdm import tqdm

from pipeline.categories import CATEGORY_SEARCH_TERMS, resolve_category
from pipeline.off_client import (
    extract_product_data,
    market_score,
    search_products,
)
from pipeline.sql_generator import generate_pipeline
from pipeline.utils import slug as _slug
from pipeline.validator import validate_product

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _dedup(products: list[dict]) -> list[dict]:
    """De-duplicate products by (brand, product_name), keeping first seen."""
    seen: set[tuple[str, str]] = set()
    unique: list[dict] = []
    for p in products:
        key = (p["brand"], p["product_name"])
        if key not in seen:
            seen.add(key)
            unique.append(p)
    return unique


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------


def _extract_products(
    raw_products: list[dict],
    category: str,
    min_completeness: float,
) -> list[dict]:
    """Phase 2: extract, normalise, and filter raw OFF products."""
    extracted: list[dict] = []
    for raw in tqdm(raw_products, desc="Extracting", leave=False):
        product = extract_product_data(raw)
        if product is None:
            continue
        off_cats = raw.get("categories_tags", [])
        resolved = resolve_category(off_cats)
        if resolved is not None and resolved != category:
            continue
        product["category"] = category
        try:
            completeness = float(product.get("_completeness", 0))
        except (ValueError, TypeError):
            completeness = 0.0
        if completeness < min_completeness:
            continue
        extracted.append(product)
    return extracted


def _validate_products(
    extracted: list[dict],
    category: str,
    max_warnings: int,
) -> tuple[list[dict], int, list[dict]]:
    """Phase 3: validate products and count warnings.

    Returns
    -------
    tuple
        (validated_products, warning_count, blocked_products)
        ``blocked_products`` contains products blocked by anomaly errors
        (absolute cap violations).
    """
    validated: list[dict] = []
    blocked: list[dict] = []
    warn_count = 0
    for product in tqdm(extracted, desc="Validating", leave=False):
        result = validate_product(product, category)
        anomaly_errors = result.get("anomaly_errors", [])
        if anomaly_errors:
            blocked.append(result)
            warn_count += 1
            continue
        n_warnings = len(result.get("validation_warnings", []))
        if n_warnings > max_warnings:
            warn_count += 1
            continue
        if n_warnings > 0:
            warn_count += 1
        validated.append(result)
    return validated, warn_count, blocked


# Country code → OFF country name for API queries
_COUNTRY_OFF_NAME: dict[str, str] = {
    "PL": "poland",
    "DE": "germany",
}


def run_pipeline(
    category: str,
    max_products: int = 30,
    output_dir: str | None = None,
    dry_run: bool = False,
    min_completeness: float = 0.0,
    max_warnings: int = 3,
    country: str = "PL",
) -> None:
    """Execute the full pipeline for a single category.

    Parameters
    ----------
    category:
        Database category name (must exist in ``CATEGORY_SEARCH_TERMS``).
    max_products:
        Maximum number of products to fetch from OFF.
    output_dir:
        Directory for SQL output.  Defaults to ``db/pipelines/{slug}/``.
    dry_run:
        If *True*, display what would be generated without writing files.
    min_completeness:
        Minimum OFF completeness score (0–1) to keep a product.
    max_warnings:
        Products with more than this many validation warnings are dropped.
    country:
        ISO 3166-1 alpha-2 country code (default ``"PL"``).
    """
    if category not in CATEGORY_SEARCH_TERMS:
        valid = ", ".join(sorted(CATEGORY_SEARCH_TERMS))
        print(f"ERROR: Unknown category '{category}'.")
        print(f"Valid categories: {valid}")
        sys.exit(1)

    off_country = _COUNTRY_OFF_NAME.get(country, country.lower())

    project_root = Path(__file__).resolve().parent.parent
    if output_dir is None:
        slug_base = _slug(category)
        # Non-PL categories get a country suffix on the folder name
        dir_slug = f"{slug_base}-{country.lower()}" if country != "PL" else slug_base
        output_dir = str(project_root / "db" / "pipelines" / dir_slug)

    print("Poland Food DB — Open Food Facts Pipeline")
    print("=" * 42)
    print(f"Category: {category}")
    print(f"Country:  {country} ({off_country})")
    print()

    # 1. Search OFF
    print(f"Searching Open Food Facts for {off_country.title()} products...")
    try:
        raw_products = search_products(
            category, max_results=max_products * 3, country=off_country
        )
    except Exception as exc:
        logger.error("Search failed with unexpected error: %s", exc)
        raw_products = []
    print(f"  Found {len(raw_products)} raw products")

    if not raw_products:
        print(
            "\nNo products found. The OFF API may be unavailable."
            "\nTry again later or increase --max-products."
        )
        sys.exit(0)

    # 2. Extract & normalise
    extracted = _extract_products(raw_products, category, min_completeness)

    # 3. Validate
    validated, warn_count, blocked = _validate_products(
        extracted, category, max_warnings
    )
    print(f"  After validation: {len(validated)} products")

    # 4. De-duplicate
    unique = _dedup(validated)
    print(f"  After dedup: {len(unique)} unique products")
    if warn_count:
        print(f"  Warnings: {warn_count} products outside expected ranges")

    # Anomaly report — blocked products with absolute cap violations
    if blocked:
        print()
        print(f"  ANOMALY REPORT — {len(blocked)} product(s) blocked:")
        for bp in blocked:
            name = bp.get("product_name", "unknown")
            brand = bp.get("brand", "unknown")
            errors = bp.get("anomaly_errors", [])
            for err in errors:
                print(f"    ✗ {brand} / {name}: {err}")
        print()

    if not unique:
        print("\nNo valid products found after extraction/validation/dedup.")
        print("  This may mean the OFF API returned too few results or the")
        print("  category terms need expanding.  Try increasing --max-products.")
        sys.exit(0)

    # Sort by market relevance (highest score first)
    unique.sort(key=lambda p: market_score(p, country), reverse=True)
    unique = unique[:max_products]

    if len(unique) < max_products:
        print(
            f"  NOTE: Only {len(unique)} of {max_products} requested products"
            f" passed validation.  SQL will be generated for what we have."
        )
    print()

    # 5. Generate SQL
    _generate_sql_output(category, unique, output_dir, dry_run, country)


def _generate_sql_output(
    category: str,
    products: list[dict],
    output_dir: str,
    dry_run: bool,
    country: str = "PL",
) -> None:
    """Phase 5: generate SQL files or print dry-run summary."""
    slug = _slug(category)
    if dry_run:
        print("[DRY RUN] Would generate SQL files in:", output_dir)
        print(f"  PIPELINE__{slug}__01_insert_products.sql ({len(products)} products)")
        print(
            f"  PIPELINE__{slug}__03_add_nutrition.sql ({len(products)} nutrition rows)"
        )
        print(f"  PIPELINE__{slug}__04_scoring.sql")
        print(f"  PIPELINE__{slug}__05_source_provenance.sql")
        print(f"  PIPELINE__{slug}__06_add_images.sql")
        return

    print("Generating SQL files...")
    files = generate_pipeline(category, products, output_dir, country=country)
    for f in files:
        size_label = ""
        if "01_insert" in f.name:
            size_label = f" ({len(products)} products)"
        elif "03_add_nutrition" in f.name:
            size_label = f" ({len(products)} nutrition rows)"
        print(f"  OK {f.name}{size_label}")

    print()
    print("Pipeline ready! Run with:")
    print(f"  .\\RUN_LOCAL.ps1 -Category {slug} -RunQA")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    """Parse arguments and run the pipeline."""
    parser = argparse.ArgumentParser(
        description="Fetch Polish products from Open Food Facts and generate SQL pipeline files.",
    )
    parser.add_argument(
        "--category",
        required=True,
        help="Database category (e.g. 'Dairy', 'Chips')",
    )
    parser.add_argument(
        "--max-products",
        type=int,
        default=30,
        help="Maximum products to include (default: 30)",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory (default: db/pipelines/{category-slug}/)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be generated without writing files",
    )
    parser.add_argument(
        "--min-completeness",
        type=float,
        default=0.0,
        help="Minimum OFF completeness score 0–1 (default: 0.0)",
    )
    parser.add_argument(
        "--max-warnings",
        type=int,
        default=3,
        help="Drop products with more than N validation warnings (default: 3)",
    )
    parser.add_argument(
        "--country",
        default="PL",
        help="ISO 3166-1 alpha-2 country code (default: PL). Supported: PL, DE",
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    run_pipeline(
        category=args.category,
        max_products=args.max_products,
        output_dir=args.output_dir,
        dry_run=args.dry_run,
        min_completeness=args.min_completeness,
        max_warnings=args.max_warnings,
        country=args.country.upper(),
    )


if __name__ == "__main__":
    main()
