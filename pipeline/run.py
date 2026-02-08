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
from pipeline.off_client import extract_product_data, search_polish_products
from pipeline.sql_generator import generate_pipeline
from pipeline.validator import validate_product

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _slug(category: str) -> str:
    """Convert a category name to a filesystem-safe slug."""
    return (
        category.lower()
        .replace("&", "")
        .replace(",", "")
        .replace("  ", " ")
        .strip()
        .replace(" ", "-")
    )


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


def run_pipeline(
    category: str,
    max_products: int = 30,
    output_dir: str | None = None,
    dry_run: bool = False,
    min_completeness: float = 0.0,
    max_warnings: int = 3,
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
    """
    if category not in CATEGORY_SEARCH_TERMS:
        valid = ", ".join(sorted(CATEGORY_SEARCH_TERMS))
        print(f"ERROR: Unknown category '{category}'.")
        print(f"Valid categories: {valid}")
        sys.exit(1)

    project_root = Path(__file__).resolve().parent.parent
    if output_dir is None:
        output_dir = str(project_root / "db" / "pipelines" / _slug(category))

    print("Poland Food DB — Open Food Facts Pipeline")
    print("=" * 42)
    print(f"Category: {category}")
    print()

    # ------------------------------------------------------------------
    # 1. Search OFF
    # ------------------------------------------------------------------
    print("Searching Open Food Facts for Polish products...")
    raw_products = search_polish_products(category, max_results=max_products * 2)
    print(f"  Found {len(raw_products)} raw products")

    # ------------------------------------------------------------------
    # 2. Extract & normalise
    # ------------------------------------------------------------------
    extracted: list[dict] = []
    for raw in tqdm(raw_products, desc="Extracting", leave=False):
        product = extract_product_data(raw)
        if product is None:
            continue
        # Verify OFF categories match the target — skip mismatches
        off_cats = raw.get("categories_tags", [])
        resolved = resolve_category(off_cats)
        if resolved is not None and resolved != category:
            continue
        # Override category to the one the user requested
        product["category"] = category
        # Completeness filter
        if product.get("_completeness", 0) < min_completeness:
            continue
        extracted.append(product)

    # ------------------------------------------------------------------
    # 3. Validate
    # ------------------------------------------------------------------
    validated: list[dict] = []
    warn_count = 0
    for product in tqdm(extracted, desc="Validating", leave=False):
        result = validate_product(product, category)
        n_warnings = len(result.get("validation_warnings", []))
        if n_warnings > max_warnings:
            warn_count += 1
            continue
        if n_warnings > 0:
            warn_count += 1
        validated.append(result)

    print(f"  After validation: {len(validated)} products")

    # ------------------------------------------------------------------
    # 4. De-duplicate
    # ------------------------------------------------------------------
    unique = _dedup(validated)
    print(f"  After dedup: {len(unique)} unique products")
    if warn_count:
        print(f"  Warnings: {warn_count} products outside expected ranges")

    if not unique:
        print("\nNo valid products found. Try increasing --max-products.")
        sys.exit(0)

    # Trim to requested max
    unique = unique[:max_products]
    print()

    # ------------------------------------------------------------------
    # 5. Generate SQL
    # ------------------------------------------------------------------
    if dry_run:
        print("[DRY RUN] Would generate SQL files in:", output_dir)
        print(
            f"  PIPELINE__{_slug(category)}__01_insert_products.sql ({len(unique)} products)"
        )
        print(f"  PIPELINE__{_slug(category)}__02_add_servings.sql")
        print(
            f"  PIPELINE__{_slug(category)}__03_add_nutrition.sql ({len(unique)} nutrition rows)"
        )
        print(f"  PIPELINE__{_slug(category)}__04_scoring.sql")
        return

    print("Generating SQL files...")
    files = generate_pipeline(category, unique, output_dir)
    for f in files:
        size_label = ""
        if "01_insert" in f.name:
            size_label = f" ({len(unique)} products)"
        elif "03_add_nutrition" in f.name:
            size_label = f" ({len(unique)} nutrition rows)"
        print(f"  \u2713 {f.name}{size_label}")

    slug = _slug(category)
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
    )


if __name__ == "__main__":
    main()
