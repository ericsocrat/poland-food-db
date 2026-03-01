"""OFF image importer for the poland-food-db pipeline.

Fetches product image URLs from the Open Food Facts API for products
that already exist in the database, and generates SQL INSERT statements
for the ``product_images`` table.

Usage
-----
::

    python -m pipeline.image_importer                          # all categories
    python -m pipeline.image_importer --category Chips         # single category
    python -m pipeline.image_importer --country DE             # DE only
    python -m pipeline.image_importer --dry-run                # preview without writing

The script queries the local database for active products with EANs, then
fetches image metadata from OFF for each product.  Results are written as
``PIPELINE__<category>__06_add_images.sql`` files.
"""

from __future__ import annotations

import argparse
import datetime
import logging
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

from pipeline.off_client import (
    OFF_PRODUCT_URL,
    _get_json,
    _session,
)
from pipeline.utils import slug as _slug

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# OFF image fields we request
IMAGE_FIELDS = "images,image_front_url,image_ingredients_url,image_nutrition_url"

# Delay between OFF API requests (conservative for rate-limiting)
REQUEST_DELAY = 0.5  # seconds

# DB connection constants (matching enrich_ingredients.py)
DB_CONTAINER = "supabase_db_poland-food-db"
DB_USER = "postgres"
DB_NAME = "postgres"

# Mapping from OFF image key prefix → our image_type
OFF_TYPE_MAP = {
    "front": "front",
    "ingredients": "ingredients",
    "nutrition": "nutrition_label",
    "packaging": "packaging",
}


# ---------------------------------------------------------------------------
# OFF image extraction
# ---------------------------------------------------------------------------


def fetch_product_images(ean: str) -> list[dict[str, Any]]:
    """Fetch image URLs for a product from OFF by EAN.

    Returns a list of dicts with keys: url, image_type, off_image_id, alt_text.
    """
    with _session() as session:
        url = OFF_PRODUCT_URL.format(ean=ean)
        params = {"fields": IMAGE_FIELDS}
        data = _get_json(session, url, params)

        if data is None or data.get("status") != 1:
            return []

        product = data.get("product", {})
        return _extract_images(product, ean)


def _try_build_fallback_image(
    key: str, meta: Any, ean: str, seen_urls: set[str]
) -> dict[str, Any] | None:
    """Try to build an image dict from an OFF images dict entry.

    Returns the image dict if successful, or None if the entry is
    not a recognized type or lacks a revision.
    """
    if not isinstance(meta, dict):
        return None

    for prefix, image_type in OFF_TYPE_MAP.items():
        if not key.startswith(prefix):
            continue

        rev = meta.get("rev")
        if rev is None:
            return None

        barcode_path = _ean_to_off_path(ean)
        img_url = (
            f"https://images.openfoodfacts.org/images/products/"
            f"{barcode_path}/{key}.{rev}.400.jpg"
        )

        if img_url in seen_urls:
            return None

        seen_urls.add(img_url)
        return {
            "url": img_url,
            "image_type": image_type,
            # Include EAN to ensure globally unique off_image_id —
            # rev numbers like "front_pl.4.400" collide across products.
            "off_image_id": f"{key}.{rev}.400_{ean}",
            "alt_text": f"{image_type.replace('_', ' ').title()} — EAN {ean}",
        }

    return None


def _extract_images(product: dict, ean: str) -> list[dict[str, Any]]:
    """Extract structured image metadata from an OFF product dict."""
    images: list[dict[str, Any]] = []
    seen_urls: set[str] = set()

    # 1. Direct URL fields (highest quality — 400px versions)
    for off_key, image_type in [
        ("image_front_url", "front"),
        ("image_ingredients_url", "ingredients"),
        ("image_nutrition_url", "nutrition_label"),
    ]:
        raw_url = product.get(off_key)
        if raw_url and raw_url.startswith("https://") and raw_url not in seen_urls:
            seen_urls.add(raw_url)
            images.append(
                {
                    "url": raw_url,
                    "image_type": image_type,
                    "off_image_id": f"{image_type}_{ean}",
                    "alt_text": f"{image_type.replace('_', ' ').title()} — EAN {ean}",
                }
            )

    # 2. Fallback: parse the images dict for additional types
    raw_images = product.get("images", {})
    if isinstance(raw_images, dict):
        for key, meta in raw_images.items():
            img = _try_build_fallback_image(key, meta, ean, seen_urls)
            if img is not None:
                images.append(img)

    return images


def _ean_to_off_path(ean: str) -> str:
    """Convert an EAN to the OFF image directory path.

    EAN ``5900259128843`` → ``590/025/912/8843``
    Short EANs are zero-padded to 13 digits.
    """
    code = ean.zfill(13)
    return f"{code[:3]}/{code[3:6]}/{code[6:9]}/{code[9:]}"


# ---------------------------------------------------------------------------
# SQL generation
# ---------------------------------------------------------------------------


def _sql_text(value: str | None) -> str:
    """SQL-safe text literal."""
    if value is None:
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


def generate_image_sql(
    category: str,
    product_images: list[dict[str, Any]],
) -> str:
    """Generate SQL for inserting product images.

    Parameters
    ----------
    category:
        Database category name.
    product_images:
        List of dicts with keys: ean, images (list of image dicts).
    """
    today = datetime.date.today().isoformat()
    lines: list[str] = []
    lines.append(f"-- PIPELINE ({category}): add product images")
    lines.append("-- Source: Open Food Facts API (automated pipeline)")
    lines.append(f"-- Generated: {today}")
    lines.append("")

    # Delete existing OFF images for this category to avoid duplicates
    lines.append("-- 1. Remove existing OFF images for this category")
    lines.append("DELETE FROM product_images")
    lines.append("WHERE source = 'off_api'")
    lines.append("  AND product_id IN (")
    lines.append("    SELECT p.product_id FROM products p")
    lines.append(f"    WHERE p.category = {_sql_text(category)}")
    lines.append("      AND p.is_deprecated IS NOT TRUE")
    lines.append("  );")
    lines.append("")

    # Build INSERT values
    value_rows: list[str] = []

    for item in product_images:
        ean = item["ean"]
        images = item.get("images", [])
        for i, img in enumerate(images):
            is_primary = "true" if i == 0 and img["image_type"] == "front" else "false"
            row = (
                f"  ((SELECT p.product_id FROM products p "
                f"WHERE p.ean = {_sql_text(ean)} AND p.is_deprecated IS NOT TRUE LIMIT 1), "
                f"{_sql_text(img['url'])}, 'off_api', "
                f"{_sql_text(img['image_type'])}, {is_primary}, "
                f"null, null, "
                f"{_sql_text(img.get('alt_text'))}, "
                f"{_sql_text(img.get('off_image_id'))})"
            )
            value_rows.append(row)

    if not value_rows:
        lines.append("-- No images found for this category.")
        return "\n".join(lines)

    lines.append("-- 2. Insert images")
    lines.append(
        "INSERT INTO product_images "
        "(product_id, url, source, image_type, is_primary, width, height, alt_text, off_image_id)"
    )
    lines.append("VALUES")
    lines.append(",\n".join(value_rows))
    lines.append(
        "ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET"
    )
    lines.append("  url = EXCLUDED.url,")
    lines.append("  image_type = EXCLUDED.image_type,")
    lines.append("  is_primary = EXCLUDED.is_primary,")
    lines.append("  alt_text = EXCLUDED.alt_text;")
    lines.append("")

    # Set first front image as primary if none marked
    lines.append("-- 3. Ensure exactly one primary per product")
    lines.append("UPDATE product_images pi SET is_primary = true")
    lines.append("WHERE pi.image_id = (")
    lines.append("  SELECT img.image_id FROM product_images img")
    lines.append("  WHERE img.product_id = pi.product_id")
    lines.append("    AND img.image_type = 'front'")
    lines.append("  ORDER BY img.image_id")
    lines.append("  LIMIT 1")
    lines.append(")")
    lines.append("AND pi.product_id IN (")
    lines.append("  SELECT p.product_id FROM products p")
    lines.append(f"  WHERE p.category = {_sql_text(category)}")
    lines.append("    AND p.is_deprecated IS NOT TRUE")
    lines.append(")")
    lines.append("AND NOT EXISTS (")
    lines.append("  SELECT 1 FROM product_images existing")
    lines.append("  WHERE existing.product_id = pi.product_id")
    lines.append("    AND existing.is_primary = true")
    lines.append(");")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# DB helpers
# ---------------------------------------------------------------------------


def _psql_cmd(query: str) -> list[str]:
    """Build psql command — CI mode (PGHOST set) uses psql directly,
    local mode uses docker exec into the Supabase container."""
    if os.environ.get("PGHOST"):
        return ["psql", "-t", "-A", "-F", "|", "-c", query]
    return [
        "docker",
        "exec",
        DB_CONTAINER,
        "psql",
        "-U",
        DB_USER,
        "-d",
        DB_NAME,
        "-t",
        "-A",
        "-F",
        "|",
        "-c",
        query,
    ]


def _get_products_with_eans(
    category: str | None = None,
    country: str | None = None,
) -> list[dict[str, str]]:
    """Query the database for active products with EANs.

    Returns list of dicts: {product_id, country, ean, brand, product_name, category}
    """
    clauses: list[str] = [
        "p.is_deprecated = FALSE",
        "p.ean IS NOT NULL",
    ]
    if category:
        clauses.append(f"p.category = '{category}'")
    if country:
        clauses.append(f"p.country = '{country}'")

    where = " AND ".join(clauses)
    cmd = _psql_cmd(
        f"SELECT p.product_id, p.country, p.ean, p.brand, p.product_name, p.category "
        f"FROM products p WHERE {where} ORDER BY p.category, p.product_id"
    )
    result = subprocess.run(
        cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace"
    )
    if result.returncode != 0:
        logger.error("DB query failed: %s", result.stderr)
        sys.exit(1)

    products: list[dict[str, str]] = []
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) < 6:
            continue
        products.append(
            {
                "product_id": parts[0],
                "country": parts[1],
                "ean": parts[2],
                "brand": parts[3],
                "product_name": parts[4],
                "category": parts[5],
            }
        )
    return products


# ---------------------------------------------------------------------------
# SQL generation (compatible with pipeline/sql_generator.py pattern)
# ---------------------------------------------------------------------------


def _sql_text(value: str | None) -> str:
    """SQL-safe text literal."""
    if value is None:
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


def generate_image_sql_v2(
    category: str,
    country: str,
    product_images: list[dict[str, Any]],
) -> str:
    """Generate SQL for inserting product images.

    Uses the same SQL pattern as pipeline/sql_generator.py _gen_06_add_images
    for full compatibility with existing DE image files.

    Parameters
    ----------
    category:
        Database category name (e.g., 'Chips').
    country:
        ISO 3166-1 alpha-2 country code (e.g., 'PL').
    product_images:
        List of dicts: {ean, brand, product_name, images: [{url, image_type, off_image_id, alt_text}]}
    """
    today = datetime.date.today().isoformat()

    # Build value rows
    image_rows: list[str] = []
    for item in product_images:
        brand = _sql_text(item["brand"])
        name = _sql_text(item["product_name"])
        # Track which products already have a primary image to avoid
        # violating the idx_product_images_primary unique constraint
        # (only one is_primary=true row per product allowed).
        primary_set = False
        for img in item.get("images", []):
            is_front = img["image_type"] == "front"
            is_primary = "true" if is_front and not primary_set else "false"
            if is_front and not primary_set:
                primary_set = True
            off_id = _sql_text(img.get("off_image_id"))
            alt = _sql_text(img.get("alt_text"))
            url = _sql_text(img["url"])
            image_rows.append(
                f"    ({brand}, {name}, {url}, 'off_api', "
                f"{_sql_text(img['image_type'])}, {is_primary}, {alt}, {off_id})"
            )

    if not image_rows:
        return (
            f"-- PIPELINE ({category}): add product images\n"
            f"-- Generated: {today}\n\n"
            f"-- No product images available from OFF API for this category.\n"
        )

    image_block = ",\n".join(image_rows)

    return (
        f"-- PIPELINE ({category}): add product images\n"
        f"-- Source: Open Food Facts API (image_importer.py)\n"
        f"-- Generated: {today}\n"
        f"-- Products with images: {len(product_images)}\n\n"
        f"-- 1. Remove existing OFF images for this category\n"
        f"DELETE FROM product_images\n"
        f"WHERE source = 'off_api'\n"
        f"  AND product_id IN (\n"
        f"    SELECT p.product_id FROM products p\n"
        f"    WHERE p.country = {_sql_text(country)} AND p.category = {_sql_text(category)}\n"
        f"      AND p.is_deprecated IS NOT TRUE\n"
        f"  );\n\n"
        f"-- 2. Insert images\n"
        f"INSERT INTO product_images\n"
        f"  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)\n"
        f"SELECT\n"
        f"  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id\n"
        f"FROM (\n"
        f"  VALUES\n"
        f"{image_block}\n"
        f") AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)\n"
        f"JOIN products p ON p.country = {_sql_text(country)} AND p.brand = d.brand "
        f"AND p.product_name = d.product_name\n"
        f"  AND p.category = {_sql_text(category)} AND p.is_deprecated IS NOT TRUE\n"
        f"ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET\n"
        f"  url = EXCLUDED.url,\n"
        f"  image_type = EXCLUDED.image_type,\n"
        f"  is_primary = EXCLUDED.is_primary,\n"
        f"  alt_text = EXCLUDED.alt_text;\n"
    )


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------


def main() -> None:
    """CLI entry point for image importing.

    Queries the database for active products with EANs, fetches image URLs
    from the OFF API, and generates PIPELINE__*__06_add_images.sql files.
    """
    parser = argparse.ArgumentParser(
        description="Import product images from Open Food Facts"
    )
    parser.add_argument(
        "--category",
        default=None,
        help="Single category to import images for (default: all)",
    )
    parser.add_argument(
        "--country",
        default=None,
        help="Country filter: PL or DE (default: all)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print summary to stdout instead of writing files",
    )
    parser.add_argument(
        "--output-dir",
        default="db/pipelines",
        help="Base output directory for pipeline SQL files",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Also apply the generated SQL files to the database",
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    # 1. Query DB for products with EANs
    logger.info("Querying database for products with EANs...")
    products = _get_products_with_eans(
        category=args.category,
        country=args.country.upper() if args.country else None,
    )
    if not products:
        logger.warning("No products found with EANs matching filters.")
        sys.exit(0)

    logger.info("Found %d products with EANs", len(products))

    # 2. Group by (country, category)
    groups: dict[tuple[str, str], list[dict[str, str]]] = {}
    for p in products:
        key = (p["country"], p["category"])
        groups.setdefault(key, []).append(p)

    logger.info("Processing %d category groups...", len(groups))

    # 3. Fetch images from OFF API for each product
    total_images = 0
    total_products_with_images = 0
    sql_files_written: list[Path] = []

    for (country, category), cat_products in sorted(groups.items()):
        logger.info(
            "  [%s/%s] Fetching images for %d products...",
            country,
            category,
            len(cat_products),
        )

        product_images: list[dict[str, Any]] = []
        for p in cat_products:
            ean = p["ean"]
            images = fetch_product_images(ean)
            if images:
                product_images.append(
                    {
                        "ean": ean,
                        "brand": p["brand"],
                        "product_name": p["product_name"],
                        "images": images,
                    }
                )
                total_images += len(images)
                total_products_with_images += 1
            time.sleep(REQUEST_DELAY)

        coverage = (
            f"{len(product_images)}/{len(cat_products)} "
            f"({100 * len(product_images) / len(cat_products):.0f}%)"
            if cat_products
            else "0/0"
        )
        logger.info(
            "    Coverage: %s products have images (%d image URLs)",
            coverage,
            sum(len(pi["images"]) for pi in product_images),
        )

        # 4. Generate SQL
        sql = generate_image_sql_v2(category, country, product_images)

        if args.dry_run:
            print(f"\n--- {country}/{category} ---")
            print(f"Products with images: {len(product_images)}/{len(cat_products)}")
            print(
                f"Total image URLs: {sum(len(pi['images']) for pi in product_images)}"
            )
            continue

        # 5. Write SQL file
        # Resolve output directory to match existing pipeline folders.
        # Most PL categories use plain slug (e.g., "bread"), but chips-pl
        # is a special case.  DE categories always use "{slug}-de".
        slug_base = _slug(category)
        base_dir = Path(args.output_dir)
        if country != "PL":
            dir_slug = f"{slug_base}-{country.lower()}"
        elif (base_dir / f"{slug_base}-pl").is_dir():
            # e.g., chips-pl/ exists because DE expansion renamed it
            dir_slug = f"{slug_base}-pl"
        else:
            dir_slug = slug_base
        output_path = base_dir / dir_slug
        output_path.mkdir(parents=True, exist_ok=True)

        # Use dir_slug in filename to match sql_generator.py convention
        # (e.g., PIPELINE__bread-de__06_add_images.sql in bread-de/)
        filename = f"PIPELINE__{dir_slug}__06_add_images.sql"
        filepath = output_path / filename
        filepath.write_text(sql, encoding="utf-8")
        sql_files_written.append(filepath)
        logger.info("    Wrote: %s", filepath)

    # 6. Summary
    print()
    print("=" * 50)
    print("  Image Import Summary")
    print("=" * 50)
    print(f"  Products queried:       {len(products)}")
    print(f"  Products with images:   {total_products_with_images}")
    print(f"  Total image URLs:       {total_images}")
    print(f"  SQL files written:      {len(sql_files_written)}")
    if products:
        print(
            f"  Overall coverage:       "
            f"{100 * total_products_with_images / len(products):.1f}%"
        )
    print()

    # 7. Optionally apply SQL files
    if args.apply and sql_files_written:
        logger.info("Applying %d SQL files to database...", len(sql_files_written))
        for filepath in sql_files_written:
            cmd_parts: list[str]
            if os.environ.get("PGHOST"):
                cmd_parts = ["psql", "-v", "ON_ERROR_STOP=1", "-f", str(filepath)]
            else:
                # Read file and pipe to docker exec
                sql_content = filepath.read_text(encoding="utf-8")
                cmd_parts = [
                    "docker",
                    "exec",
                    "-i",
                    DB_CONTAINER,
                    "psql",
                    "-U",
                    DB_USER,
                    "-d",
                    DB_NAME,
                    "-v",
                    "ON_ERROR_STOP=1",
                ]
                result = subprocess.run(
                    cmd_parts,
                    input=sql_content,
                    capture_output=True,
                    timeout=60,
                    encoding="utf-8",
                    errors="replace",
                )
                if result.returncode != 0:
                    logger.error("Failed to apply %s: %s", filepath.name, result.stderr)
                else:
                    logger.info("  Applied: %s", filepath.name)
                continue
            result = subprocess.run(
                cmd_parts,
                capture_output=True,
                timeout=60,
                encoding="utf-8",
                errors="replace",
            )
            if result.returncode != 0:
                logger.error("Failed to apply %s: %s", filepath.name, result.stderr)
            else:
                logger.info("  Applied: %s", filepath.name)

        # Verify final counts
        verify_cmd = _psql_cmd(
            "SELECT count(*) AS total, "
            "count(DISTINCT product_id) AS products_with_images "
            "FROM product_images WHERE source = 'off_api'"
        )
        result = subprocess.run(
            verify_cmd,
            capture_output=True,
            timeout=30,
            encoding="utf-8",
            errors="replace",
        )
        if result.returncode == 0:
            print(f"\n  DB verification: {result.stdout.strip()}")
    elif not args.dry_run and sql_files_written:
        print("  To apply, re-run with --apply or execute:")
        print("  .\\RUN_LOCAL.ps1")


if __name__ == "__main__":
    main()
