"""Fetch ingredient and allergen data from OFF API for all products with EANs.

Generates a migration SQL file that populates:
  - product_ingredient (junction linking products → ingredient_ref)
  - product_allergen_info (allergen/trace tags per product)

Usage:
    python enrich_ingredients.py
"""
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product/{ean}.json"
USER_AGENT = "poland-food-db/1.0 (https://github.com/ericsocrat/poland-food-db)"
FIELDS = "ingredients,allergens_tags,traces_tags,ingredients_analysis_tags"
DELAY = 0.35  # seconds between requests (OFF rate limit: ~100/min)
TIMEOUT = 30
MAX_RETRIES = 2

OUTPUT_DIR = Path(__file__).parent / "supabase" / "migrations"
# Migration filename is generated dynamically at runtime to avoid overwrites
MIGRATION_FILE: Path | None = None  # set in main()

DB_CONTAINER = "supabase_db_poland-food-db"
DB_USER = "postgres"
DB_NAME = "postgres"

# ---------------------------------------------------------------------------
# DB helpers
# ---------------------------------------------------------------------------

def _psql_cmd(query: str) -> list[str]:
    """Build psql command — CI mode (PGHOST set) uses psql directly,
    local mode uses docker exec into the Supabase container."""
    if os.environ.get("PGHOST"):
        return ["psql", "-t", "-A", "-F", "|", "-c", query]
    return [
        "docker", "exec", DB_CONTAINER,
        "psql", "-U", DB_USER, "-d", DB_NAME,
        "-t", "-A", "-F", "|", "-c", query,
    ]


def get_products() -> list[dict]:
    """Get all active products with EANs from the local DB."""
    cmd = _psql_cmd("""
        SELECT product_id, country, ean, brand, product_name, category
        FROM products
        WHERE is_deprecated = FALSE AND ean IS NOT NULL
        ORDER BY product_id;
    """)
    result = subprocess.run(cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace")
    if result.returncode != 0:
        print(f"DB query failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    products = []
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) >= 4:
            products.append({
                "product_id": int(parts[0]),
                "country": parts[1].strip(),
                "ean": parts[2].strip(),
                "brand": parts[3].strip(),
                "product_name": parts[4].strip() if len(parts) > 4 else "",
                "category": parts[5].strip() if len(parts) > 5 else "",
            })
    return products


def get_ingredient_ref() -> dict[str, int]:
    """Get ingredient_ref lookup: name_en → ingredient_id."""
    cmd = _psql_cmd("SELECT ingredient_id, lower(name_en) FROM ingredient_ref ORDER BY ingredient_id;")
    result = subprocess.run(cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace")
    if result.returncode != 0:
        print(f"DB query failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    lookup = {}
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|", 1)
        if len(parts) == 2:
            lookup[parts[1].strip()] = int(parts[0])
    return lookup


# ---------------------------------------------------------------------------
# OFF API
# ---------------------------------------------------------------------------

def fetch_off_product(ean: str) -> dict | None:
    """Fetch a single product from OFF API."""
    url = OFF_PRODUCT_URL.format(ean=ean)
    headers = {"User-Agent": USER_AGENT}

    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = requests.get(
                url,
                params={"fields": FIELDS},
                headers=headers,
                timeout=TIMEOUT
            )
            if resp.status_code == 404:
                return None
            resp.raise_for_status()
            data = resp.json()
            if data.get("status") == 0:
                return None
            return data.get("product", {})
        except Exception as exc:
            if attempt < MAX_RETRIES:
                time.sleep(DELAY * (attempt + 1) * 2)
                continue
            print(f"  Failed for EAN {ean}: {exc}", file=sys.stderr)
            return None


# ---------------------------------------------------------------------------
# Ingredient normalization
# ---------------------------------------------------------------------------

def normalize_ingredient_name(name: str) -> str:
    """Normalize an OFF ingredient name to match ingredient_ref.name_en."""
    # OFF ingredients use format like "en:sugar" or just "sugar"
    name = name.strip()
    # Remove language prefix
    if ":" in name:
        name = name.split(":", 1)[1]
    # Clean up
    name = name.replace("-", " ").replace("_", " ")
    name = re.sub(r"\s+", " ", name).strip()
    # Title case to match ingredient_ref convention
    return name.lower()


def is_additive_tag(tag: str) -> bool:
    """Check if an OFF ingredient ID looks like an additive (e.g., en:e300)."""
    tag_lower = tag.lower()
    return bool(re.match(r'(en:)?e\d{3}', tag_lower))


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

def process_ingredients(off_product: dict, country: str, ean: str,
                        ingredient_lookup: dict[str, int],
                        new_ingredients: dict[str, dict]) -> list[dict]:
    """Extract ingredient rows for a product.

    Returns list of dicts with keys: country, ean, ingredient_id, position,
    percent, percent_estimate, is_sub_ingredient, parent_ingredient_id
    """
    ingredients = off_product.get("ingredients", [])
    if not ingredients:
        return []

    rows = []
    position = 1

    def process_item(item: dict, pos: int, is_sub: bool, parent_id: int | None) -> int:
        """Process a single ingredient item. Returns next position."""
        text = item.get("text", "").strip()
        off_id = item.get("id", "").strip()

        if not text and not off_id:
            return pos

        # Normalize the name
        name = text if text else off_id
        name_lower = normalize_ingredient_name(name)

        if not name_lower:
            return pos

        # Try to find in ingredient_ref
        ing_id = ingredient_lookup.get(name_lower)

        if ing_id is None:
            # Check if it's an additive by tag
            is_add = is_additive_tag(off_id) if off_id else False

            # Create new ingredient_ref entry
            if name_lower not in new_ingredients:
                # Use title case for the display name
                display_name = name.title() if not any(c.isupper() for c in name[1:]) else name
                display_name = display_name.strip()
                if len(display_name) > 200:
                    display_name = display_name[:200]

                new_ingredients[name_lower] = {
                    "name_en": display_name,
                    "is_additive": is_add,
                    "vegan": item.get("vegan", "unknown") or "unknown",
                    "vegetarian": item.get("vegetarian", "unknown") or "unknown",
                    "from_palm_oil": item.get("from_palm_oil", "unknown") or "unknown",
                }
            # We'll resolve the ID after inserting new ingredients
            ing_id = f"NEW:{name_lower}"

        pct = item.get("percent")
        pct_est = item.get("percent_estimate")

        row = {
            "country": country,
            "ean": ean,
            "ingredient_id": ing_id,
            "position": pos,
            "percent": pct,
            "percent_estimate": round(pct_est, 2) if pct_est is not None else None,
            "is_sub_ingredient": is_sub,
            "parent_ingredient_id": parent_id if is_sub else None,
        }
        rows.append(row)

        current_id = ing_id
        next_pos = pos + 1

        # Process sub-ingredients
        for sub in item.get("ingredients", []):
            next_pos = process_item(sub, next_pos, True, current_id)

        return next_pos

    for item in ingredients:
        position = process_item(item, position, False, None)

    return rows


def canonical_taxonomy_tag(tag: str) -> str:
    """Normalize OFF taxonomy tags to canonical en:* namespace."""
    t = (tag or "").strip().lower()
    if not t:
        return ""
    if t.startswith("en:"):
        return t
    if ":" in t:
        t = t.split(":", 1)[1].strip()
    return f"en:{t}" if t else ""


def process_allergens(off_product: dict, country: str, ean: str) -> list[dict]:
    """Extract allergen_info rows for a product."""
    rows = []

    allergens = off_product.get("allergens_tags", [])
    for tag in allergens:
        clean_tag = canonical_taxonomy_tag(tag)
        if clean_tag:
            rows.append({
                "country": country,
                "ean": ean,
                "tag": clean_tag,
                "type": "contains",
            })

    traces = off_product.get("traces_tags", [])
    for tag in traces:
        clean_tag = canonical_taxonomy_tag(tag)
        if clean_tag:
            rows.append({
                "country": country,
                "ean": ean,
                "tag": clean_tag,
                "type": "traces",
            })

    return rows


def sql_escape(val: str | None) -> str:
    """Escape a string for safe SQL embedding.

    Handles single quotes, backslashes, and null bytes that can
    appear in OFF API data.
    """
    if val is None:
        return "NULL"
    s = str(val).replace("\x00", "")  # strip null bytes
    s = s.replace("'", "''")
    if "\\" in s:
        # Use E'' escape-string syntax for backslash-containing values
        return "E'" + s.replace("\\", "\\\\") + "'"
    return "'" + s + "'"


def generate_migration(ingredient_rows: list[dict],
                       allergen_rows: list[dict],
                       new_ingredients: dict[str, dict],
                       stats: dict) -> str:
    """Generate the migration SQL."""
    lines = []
    lines.append("-- Populate product_ingredient and product_allergen_info tables")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append(f"-- Products processed: {stats['processed']}")
    lines.append(f"-- Products with ingredients: {stats['with_ingredients']}")
    lines.append(f"-- Products with allergens: {stats['with_allergens']}")
    lines.append(f"-- New ingredient_ref entries: {len(new_ingredients)}")
    lines.append(f"-- Total product_ingredient rows: {len(ingredient_rows)}")
    lines.append(f"-- Total product_allergen_info rows: {len(allergen_rows)}")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")

    # 1. Insert new ingredients into ingredient_ref
    if new_ingredients:
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("-- 1. Add new ingredients to ingredient_ref")
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("")
        lines.append("INSERT INTO ingredient_ref (name_en, is_additive, vegan, vegetarian, from_palm_oil)")
        lines.append("VALUES")

        vals = []
        for name_lower, info in sorted(new_ingredients.items()):
            vals.append(
                f"  ({sql_escape(info['name_en'])}, "
                f"{'true' if info['is_additive'] else 'false'}, "
                f"{sql_escape(info['vegan'])}, "
                f"{sql_escape(info['vegetarian'])}, "
                f"{sql_escape(info['from_palm_oil'])})"
            )
        lines.append(",\n".join(vals))
        lines.append("ON CONFLICT DO NOTHING;")
        lines.append("")

    # 2. Insert product_allergen_info (resolved via country + ean)
    if allergen_rows:
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("-- 2. Populate product_allergen_info")
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("-- Resolve product_id by stable key (country + ean) for portability")
        lines.append("")

        # Batch by 500 rows
        batch_size = 500
        for i in range(0, len(allergen_rows), batch_size):
            batch = allergen_rows[i:i + batch_size]
            lines.append("INSERT INTO product_allergen_info (product_id, tag, type)")
            lines.append("SELECT p.product_id, v.tag, v.type")
            lines.append("FROM (VALUES")
            vals = []
            for r in batch:
                vals.append(
                    f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, "
                    f"{sql_escape(r['tag'])}, {sql_escape(r['type'])})"
                )
            lines.append(",\n".join(vals))
            lines.append(") AS v(country, ean, tag, type)")
            lines.append("JOIN products p ON p.country = v.country AND p.ean = v.ean")
            lines.append("WHERE p.is_deprecated IS NOT TRUE")
            lines.append("ON CONFLICT (product_id, tag, type) DO NOTHING;")
            lines.append("")

    # 3. Insert product_ingredient — needs resolved ingredient_ids
    # For new ingredients, we use a subquery to look up the ID by name
    if ingredient_rows:
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("-- 3. Populate product_ingredient")
        lines.append("-- ═══════════════════════════════════════════════════════════════")
        lines.append("-- Resolve product_id by stable key (country + ean) for portability")
        lines.append("")

        # Group by whether they need name resolution
        resolved = [r for r in ingredient_rows if not isinstance(r["ingredient_id"], str)]
        unresolved = [r for r in ingredient_rows if isinstance(r["ingredient_id"], str)]

        # Insert resolved rows (direct ingredient_id)
        if resolved:
            batch_size = 500
            for i in range(0, len(resolved), batch_size):
                batch = resolved[i:i + batch_size]
                lines.append("INSERT INTO product_ingredient (product_id, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)")
                lines.append("SELECT p.product_id, v.ingredient_id, v.position, v.percent, v.percent_estimate, v.is_sub_ingredient, v.parent_ingredient_id")
                lines.append("FROM (VALUES")
                vals = []
                for r in batch:
                    pct = str(r['percent']) if r['percent'] is not None else 'NULL'
                    pct_est = str(r['percent_estimate']) if r['percent_estimate'] is not None else 'NULL'
                    parent = str(r['parent_ingredient_id']) if r['parent_ingredient_id'] is not None and not isinstance(r['parent_ingredient_id'], str) else 'NULL'
                    vals.append(
                        f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, "
                        f"{r['ingredient_id']}, {r['position']}, {pct}, {pct_est}, "
                        f"{'true' if r['is_sub_ingredient'] else 'false'}, {parent})"
                    )
                lines.append(",\n".join(vals))
                lines.append(") AS v(country, ean, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)")
                lines.append("JOIN products p ON p.country = v.country AND p.ean = v.ean")
                lines.append("WHERE p.is_deprecated IS NOT TRUE")
                lines.append("ON CONFLICT (product_id, ingredient_id, position) DO NOTHING;")
                lines.append("")

        # Insert unresolved rows (need name lookup)
        if unresolved:
            batch_size = 500
            for i in range(0, len(unresolved), batch_size):
                batch = unresolved[i:i + batch_size]
                lines.append("INSERT INTO product_ingredient (product_id, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)")
                lines.append("SELECT p.product_id, ir.ingredient_id, v.position, v.percent, v.percent_estimate, v.is_sub_ingredient, v.parent_ingredient_id")
                lines.append("FROM (VALUES")
                vals = []
                for r in batch:
                    name_lower = r['ingredient_id'].replace("NEW:", "")
                    display_name = new_ingredients[name_lower]['name_en']
                    pct = str(r['percent']) if r['percent'] is not None else 'NULL'
                    pct_est = str(r['percent_estimate']) if r['percent_estimate'] is not None else 'NULL'
                    parent = str(r['parent_ingredient_id']) if r['parent_ingredient_id'] is not None and not isinstance(r['parent_ingredient_id'], str) else 'NULL'
                    vals.append(
                        f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, {sql_escape(display_name)}, {r['position']}, "
                        f"{pct}::numeric, {pct_est}::numeric, "
                        f"{'true' if r['is_sub_ingredient'] else 'false'}, {parent}::bigint)"
                    )
                lines.append(",\n".join(vals))
                lines.append(") AS v(country, ean, ingredient_name, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)")
                lines.append("JOIN products p ON p.country = v.country AND p.ean = v.ean")
                lines.append("JOIN ingredient_ref ir ON lower(ir.name_en) = lower(v.ingredient_name)")
                lines.append("WHERE p.is_deprecated IS NOT TRUE")
                lines.append("ON CONFLICT (product_id, ingredient_id, position) DO NOTHING;")
                lines.append("")

    # 4. Refresh materialized views
    lines.append("-- ═══════════════════════════════════════════════════════════════")
    lines.append("-- 4. Refresh materialized views")
    lines.append("-- ═══════════════════════════════════════════════════════════════")
    lines.append("")
    lines.append("SELECT refresh_all_materialized_views();")
    lines.append("")
    lines.append("COMMIT;")

    return "\n".join(lines)


def main():
    print("=" * 60)
    print("Ingredient & Allergen Enrichment")
    print("=" * 60)

    # Set migration filename dynamically to avoid overwrites
    global MIGRATION_FILE
    ts = datetime.now().strftime("%Y%m%d%H%M%S")
    MIGRATION_FILE = OUTPUT_DIR / f"{ts}_populate_ingredients_allergens.sql"

    # 1. Load products and ingredient_ref
    print("\n[1/4] Loading products from database...")
    products = get_products()
    print(f"  Found {len(products)} active products with EANs")

    print("\n[2/4] Loading ingredient_ref...")
    ingredient_lookup = get_ingredient_ref()
    print(f"  Found {len(ingredient_lookup)} ingredients in reference table")

    # 2. Fetch from OFF API
    print(f"\n[3/4] Fetching ingredient data from OFF API...")
    print(f"  Rate limit: {DELAY}s between requests")
    print(f"  Estimated time: ~{len(products) * DELAY / 60:.0f} minutes")

    all_ingredient_rows = []
    all_allergen_rows = []
    new_ingredients: dict[str, dict] = {}

    stats = {
        "processed": 0,
        "with_ingredients": 0,
        "with_allergens": 0,
        "not_found": 0,
        "api_errors": 0,
    }

    for i, product in enumerate(products):
        if (i + 1) % 50 == 0 or i == 0:
            print(f"  Processing {i+1}/{len(products)} "
                  f"(ingredients: {stats['with_ingredients']}, "
                  f"allergens: {stats['with_allergens']}, "
                  f"not found: {stats['not_found']})...")

        off_data = fetch_off_product(product["ean"])
        stats["processed"] += 1

        if off_data is None:
            stats["not_found"] += 1
            time.sleep(DELAY)
            continue

        # Process ingredients
        ing_rows = process_ingredients(off_data, product["country"], product["ean"],
                                       ingredient_lookup, new_ingredients)
        if ing_rows:
            stats["with_ingredients"] += 1
            all_ingredient_rows.extend(ing_rows)

        # Process allergens/traces
        alg_rows = process_allergens(off_data, product["country"], product["ean"])
        if alg_rows:
            stats["with_allergens"] += 1
            all_allergen_rows.extend(alg_rows)

        time.sleep(DELAY)

    # 3. Generate migration
    print(f"\n[4/4] Generating migration SQL...")
    print(f"  Products processed: {stats['processed']}")
    print(f"  With ingredients: {stats['with_ingredients']}")
    print(f"  With allergens/traces: {stats['with_allergens']}")
    print(f"  Not found on OFF: {stats['not_found']}")
    print(f"  New ingredients to add: {len(new_ingredients)}")
    print(f"  Total ingredient rows: {len(all_ingredient_rows)}")
    print(f"  Total allergen rows: {len(all_allergen_rows)}")

    sql = generate_migration(all_ingredient_rows, all_allergen_rows,
                              new_ingredients, stats)

    MIGRATION_FILE.write_text(sql, encoding="utf-8")
    print(f"\n  Migration written to: {MIGRATION_FILE}")
    print(f"  File size: {MIGRATION_FILE.stat().st_size / 1024:.1f} KB")
    print("\nDone! Run the migration with:")
    print(f"  docker exec supabase_db_poland-food-db psql -U postgres -d postgres -f ...")
    print(f"  or: Get-Content '{MIGRATION_FILE}' -Raw | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres")


if __name__ == "__main__":
    main()
