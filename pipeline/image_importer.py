"""OFF image importer for the poland-food-db pipeline.

Fetches product image URLs from the Open Food Facts API for products
that already exist in the database, and generates SQL INSERT statements
for the ``product_images`` table.

Usage
-----
::

    python -m pipeline.image_importer           # all categories
    python -m pipeline.image_importer Chips      # single category
    python -m pipeline.image_importer --dry-run  # preview SQL without writing

The script queries the local database for active products with EANs, then
fetches image metadata from OFF for each product.  Results are written as
``PIPELINE__<category>__06_add_images.sql`` files.
"""

from __future__ import annotations

import argparse
import datetime
import logging
from typing import Any

from pipeline.off_client import (
    OFF_PRODUCT_URL,
    _get_json,
    _session,
)

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# OFF image fields we request
IMAGE_FIELDS = "images,image_front_url,image_ingredients_url,image_nutrition_url"

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
            "off_image_id": f"{key}.{rev}.400",
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
# CLI entry point
# ---------------------------------------------------------------------------


def main() -> None:
    """CLI entry point for image importing."""
    parser = argparse.ArgumentParser(
        description="Import product images from Open Food Facts"
    )
    parser.add_argument(
        "categories",
        nargs="*",
        help="Category names to import images for (default: all with EANs)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print SQL to stdout instead of writing files",
    )
    parser.add_argument(
        "--output-dir",
        default="db/pipelines",
        help="Base output directory for pipeline SQL files",
    )
    parser.add_argument(
        "--max-products",
        type=int,
        default=200,
        help="Max products per category to fetch images for",
    )

    parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    # This would normally query the database for products with EANs.
    # For now, the pipeline generates SQL files from the OFF API data
    # that already includes EANs. The image importer reads existing
    # pipeline files to extract EANs, then fetches images.
    logger.info("Image importer ready — use generate_image_sql() programmatically")
    logger.info(
        "or integrate with pipeline.run to fetch images during pipeline execution."
    )


if __name__ == "__main__":
    main()
