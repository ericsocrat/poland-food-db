"""Fetch ingredient and allergen data from OFF API for all products with EANs.

Generates a migration SQL file that populates:
  - product_ingredient (junction linking products → ingredient_ref)
  - product_allergen_info (allergen/trace tags per product)

Usage:
    python enrich_ingredients.py                    # all countries
    python enrich_ingredients.py --country DE       # DE only
"""

import argparse
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
DELAY = 1.0  # seconds between requests (conservative to avoid RemoteDisconnected)
TIMEOUT = 30
MAX_RETRIES = 3

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


def get_products(country_filter: str | None = None) -> list[dict]:
    """Get active products with EANs that are MISSING ingredient or allergen data.
    
    Args:
        country_filter: If set, only return products for this country code (e.g. 'DE').
    """
    country_clause = f"AND p.country = '{country_filter}'" if country_filter else ""
    cmd = _psql_cmd(
        f"""
        SELECT p.product_id, p.country, p.ean, p.brand, p.product_name, p.category
        FROM products p
        WHERE p.is_deprecated = FALSE
          AND p.ean IS NOT NULL
          {country_clause}
          AND (
            NOT EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id)
            OR NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = p.product_id)
          )
        ORDER BY p.product_id;
    """
    )
    result = subprocess.run(
        cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace"
    )
    if result.returncode != 0:
        print(f"DB query failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    products = []
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) >= 4:
            products.append(
                {
                    "product_id": int(parts[0]),
                    "country": parts[1].strip(),
                    "ean": parts[2].strip(),
                    "brand": parts[3].strip(),
                    "product_name": parts[4].strip() if len(parts) > 4 else "",
                    "category": parts[5].strip() if len(parts) > 5 else "",
                }
            )
    return products


def get_ingredient_ref() -> dict[str, int]:
    """Get ingredient_ref lookup: name_en → ingredient_id."""
    cmd = _psql_cmd(
        "SELECT ingredient_id, lower(name_en) FROM ingredient_ref ORDER BY ingredient_id;"
    )
    result = subprocess.run(
        cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace"
    )
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


# Shared session for connection pooling (reduces RemoteDisconnected errors)
_session: requests.Session | None = None


def _get_session() -> requests.Session:
    """Return a shared session with connection pooling."""
    global _session
    if _session is None:
        _session = requests.Session()
        _session.headers.update({"User-Agent": USER_AGENT})
        adapter = requests.adapters.HTTPAdapter(
            max_retries=0,  # we handle retries ourselves
            pool_connections=5,
            pool_maxsize=5,
        )
        _session.mount("https://", adapter)
    return _session


def fetch_off_product(ean: str) -> dict | None:
    """Fetch a single product from OFF API."""
    global _session
    url = OFF_PRODUCT_URL.format(ean=ean)
    session = _get_session()

    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = session.get(url, params={"fields": FIELDS}, timeout=TIMEOUT)
            if resp.status_code == 404:
                return None
            resp.raise_for_status()
            data = resp.json()
            if data.get("status") == 0:
                return None
            return data.get("product", {})
        except KeyboardInterrupt:
            raise  # re-raise to allow graceful shutdown
        except (requests.exceptions.ConnectionError, ConnectionError) as exc:
            # Reset session on connection errors to avoid stale pool
            _session = None
            session = _get_session()
            if attempt < MAX_RETRIES:
                backoff = DELAY * (attempt + 1) * 3
                time.sleep(backoff)
                continue
            print(f"  Failed for EAN {ean}: {exc}", file=sys.stderr)
            return None
        except Exception as exc:
            if attempt < MAX_RETRIES:
                time.sleep(DELAY * (attempt + 1) * 2)
                continue
            print(f"  Failed for EAN {ean}: {exc}", file=sys.stderr)
            return None


# ---------------------------------------------------------------------------
# Ingredient normalization
# ---------------------------------------------------------------------------


def _is_garbage_name(name: str) -> bool:
    """Reject OCR artifacts and non-meaningful ingredient names."""
    if len(name) < 2:
        return True
    # Reject names that are mostly digits/punctuation (OCR artifacts)
    alpha_count = sum(1 for c in name if c.isalpha())
    if alpha_count < 2:
        return True
    # Reject names containing HTML/barcode fragments
    if any(frag in name.lower() for frag in ['<', '>', 'http', 'www.', 'infolinka']):
        return True
    # Reject single letters
    if len(name.strip()) <= 1:
        return True
    return False


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
    return bool(re.match(r"(en:)?e\d{3}", tag_lower))


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------


def _display_name_for(name: str) -> str:
    """Produce a display name (max 200 chars) from a raw ingredient name."""
    display = name.title() if not any(c.isupper() for c in name[1:]) else name
    return display.strip()[:200]


def _resolve_ingredient(
    item: dict,
    off_id: str,
    name_lower: str,
    name: str,
    ingredient_lookup: dict[str, int],
    new_ingredients: dict[str, dict],
) -> int | str:
    """Look up or register an ingredient. Returns its ID (int or 'NEW:...')."""
    ing_id = ingredient_lookup.get(name_lower)
    if ing_id is not None:
        return ing_id

    is_add = is_additive_tag(off_id) if off_id else False
    if name_lower not in new_ingredients:
        new_ingredients[name_lower] = {
            "name_en": _display_name_for(name),
            "is_additive": is_add,
            "vegan": item.get("vegan", "unknown") or "unknown",
            "vegetarian": item.get("vegetarian", "unknown") or "unknown",
            "from_palm_oil": item.get("from_palm_oil", "unknown") or "unknown",
        }
    return f"NEW:{name_lower}"


def _clamp_percent_estimate(pct_est: float | None) -> float | None:
    """Clamp negative percent_estimate to 0 and round to 2 decimals."""
    if pct_est is None:
        return None
    return round(max(pct_est, 0), 2)


def process_ingredients(
    off_product: dict,
    country: str,
    ean: str,
    ingredient_lookup: dict[str, int],
    new_ingredients: dict[str, dict],
) -> list[dict]:
    """Extract ingredient rows for a product.

    Returns list of dicts with keys: country, ean, ingredient_id, position,
    percent, percent_estimate, is_sub_ingredient, parent_ingredient_id
    """
    ingredients = off_product.get("ingredients", [])
    if not ingredients:
        return []

    rows: list[dict] = []

    def process_item(item: dict, pos: int, is_sub: bool, parent_id: int | None) -> int:
        """Process a single ingredient item. Returns next position."""
        text = item.get("text", "").strip()
        off_id = item.get("id", "").strip()

        if not text and not off_id:
            return pos

        name = text or off_id
        name_lower = normalize_ingredient_name(name)
        if not name_lower or _is_garbage_name(name_lower):
            return pos

        ing_id = _resolve_ingredient(
            item, off_id, name_lower, name, ingredient_lookup, new_ingredients
        )

        rows.append(
            {
                "country": country,
                "ean": ean,
                "ingredient_id": ing_id,
                "position": pos,
                "percent": item.get("percent"),
                "percent_estimate": _clamp_percent_estimate(
                    item.get("percent_estimate")
                ),
                "is_sub_ingredient": is_sub,
                "parent_ingredient_id": parent_id if is_sub else None,
            }
        )

        next_pos = pos + 1
        for sub in item.get("ingredients", []):
            next_pos = process_item(sub, next_pos, True, ing_id)
        return next_pos

    position = 1
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
            rows.append(
                {
                    "country": country,
                    "ean": ean,
                    "tag": clean_tag,
                    "type": "contains",
                }
            )

    traces = off_product.get("traces_tags", [])
    for tag in traces:
        clean_tag = canonical_taxonomy_tag(tag)
        if clean_tag:
            rows.append(
                {
                    "country": country,
                    "ean": ean,
                    "tag": clean_tag,
                    "type": "traces",
                }
            )

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


# ---------------------------------------------------------------------------
# SQL generation constants (avoid duplication flagged by SonarCloud)
# ---------------------------------------------------------------------------

SQL_SECTION_SEPARATOR = (
    "-- ═══════════════════════════════════════════════════════════════"
)
SQL_FROM_VALUES = "FROM (VALUES"
SQL_JOIN_PRODUCTS = "JOIN products p ON p.country = v.country AND p.ean = v.ean"
SQL_WHERE_ACTIVE = "WHERE p.is_deprecated IS NOT TRUE"


# ---------------------------------------------------------------------------
# Migration section generators
# ---------------------------------------------------------------------------


def _format_nullable(val: object) -> str:
    """Format a potentially None value as SQL literal."""
    return str(val) if val is not None else "NULL"


def _format_ingredient_row(r: dict) -> tuple[str, str, str, bool]:
    """Extract common fields from an ingredient row for SQL generation."""
    pct = _format_nullable(r["percent"])
    pct_est = _format_nullable(r["percent_estimate"])
    parent_id = r["parent_ingredient_id"]
    parent = (
        str(parent_id)
        if parent_id is not None and not isinstance(parent_id, str)
        else "NULL"
    )
    # If parent can't be resolved, force is_sub=false to satisfy chk_sub_has_parent
    is_sub = r["is_sub_ingredient"] and parent != "NULL"
    return pct, pct_est, parent, is_sub


def _gen_new_ingredients_section(new_ingredients: dict[str, dict]) -> list[str]:
    """Generate SQL for inserting new ingredients into ingredient_ref."""
    lines = [
        SQL_SECTION_SEPARATOR,
        "-- 1. Add new ingredients to ingredient_ref",
        SQL_SECTION_SEPARATOR,
        "",
        "INSERT INTO ingredient_ref (name_en, is_additive, vegan, vegetarian, from_palm_oil)",
        "VALUES",
    ]
    vals = []
    for _name_lower, info in sorted(new_ingredients.items()):
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
    return lines


def _gen_allergen_batch(batch: list[dict]) -> list[str]:
    """Generate SQL for a single batch of allergen inserts."""
    lines = ["INSERT INTO product_allergen_info (product_id, tag, type)"]
    lines.append("SELECT p.product_id, v.tag, v.type")
    lines.append(SQL_FROM_VALUES)
    vals = []
    for r in batch:
        vals.append(
            f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, "
            f"{sql_escape(r['tag'])}, {sql_escape(r['type'])})"
        )
    lines.append(",\n".join(vals))
    lines.append(") AS v(country, ean, tag, type)")
    lines.append(SQL_JOIN_PRODUCTS)
    lines.append(SQL_WHERE_ACTIVE)
    lines.append("ON CONFLICT (product_id, tag, type) DO NOTHING;")
    lines.append("")
    return lines


def _gen_allergen_section(allergen_rows: list[dict]) -> list[str]:
    """Generate SQL for populating product_allergen_info."""
    lines = [
        SQL_SECTION_SEPARATOR,
        "-- 2. Populate product_allergen_info",
        SQL_SECTION_SEPARATOR,
        "-- Resolve product_id by stable key (country + ean) for portability",
        "",
    ]
    batch_size = 500
    for i in range(0, len(allergen_rows), batch_size):
        lines.extend(_gen_allergen_batch(allergen_rows[i : i + batch_size]))
    return lines


def _gen_resolved_ingredient_batch(batch: list[dict]) -> list[str]:
    """Generate SQL for a batch of resolved ingredient inserts."""
    lines = [
        "INSERT INTO product_ingredient (product_id, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)",
        "SELECT p.product_id, v.ingredient_id, v.position, v.percent, v.percent_estimate, v.is_sub_ingredient, v.parent_ingredient_id",
        SQL_FROM_VALUES,
    ]
    vals = []
    for r in batch:
        pct, pct_est, parent, is_sub = _format_ingredient_row(r)
        vals.append(
            f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, "
            f"{r['ingredient_id']}, {r['position']}, {pct}, {pct_est}, "
            f"{'true' if is_sub else 'false'}, {parent})"
        )
    lines.append(",\n".join(vals))
    lines.append(
        ") AS v(country, ean, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)"
    )
    lines.append(SQL_JOIN_PRODUCTS)
    lines.append(SQL_WHERE_ACTIVE)
    lines.append("ON CONFLICT (product_id, ingredient_id, position) DO NOTHING;")
    lines.append("")
    return lines


def _gen_unresolved_ingredient_batch(
    batch: list[dict], new_ingredients: dict[str, dict]
) -> list[str]:
    """Generate SQL for a batch of unresolved ingredient inserts (need name lookup)."""
    lines = [
        "INSERT INTO product_ingredient (product_id, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)",
        "SELECT p.product_id, ir.ingredient_id, v.position, v.percent, v.percent_estimate, v.is_sub_ingredient, v.parent_ingredient_id",
        SQL_FROM_VALUES,
    ]
    vals = []
    for r in batch:
        name_lower = r["ingredient_id"].replace("NEW:", "")
        display_name = new_ingredients[name_lower]["name_en"]
        pct, pct_est, parent, is_sub = _format_ingredient_row(r)
        vals.append(
            f"  ({sql_escape(r['country'])}, {sql_escape(r['ean'])}, {sql_escape(display_name)}, {r['position']}, "
            f"{pct}::numeric, {pct_est}::numeric, "
            f"{'true' if is_sub else 'false'}, {parent}::bigint)"
        )
    lines.append(",\n".join(vals))
    lines.append(
        ") AS v(country, ean, ingredient_name, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id)"
    )
    lines.append(SQL_JOIN_PRODUCTS)
    lines.append(
        "JOIN ingredient_ref ir ON lower(ir.name_en) = lower(v.ingredient_name)"
    )
    lines.append(SQL_WHERE_ACTIVE)
    lines.append("ON CONFLICT (product_id, ingredient_id, position) DO NOTHING;")
    lines.append("")
    return lines


def _gen_ingredient_section(
    ingredient_rows: list[dict], new_ingredients: dict[str, dict]
) -> list[str]:
    """Generate SQL for populating product_ingredient."""
    lines = [
        SQL_SECTION_SEPARATOR,
        "-- 3. Populate product_ingredient",
        SQL_SECTION_SEPARATOR,
        "-- Resolve product_id by stable key (country + ean) for portability",
        "",
    ]

    # Group by whether they need name resolution
    resolved = [r for r in ingredient_rows if not isinstance(r["ingredient_id"], str)]
    unresolved = [r for r in ingredient_rows if isinstance(r["ingredient_id"], str)]

    batch_size = 500
    for i in range(0, len(resolved), batch_size):
        lines.extend(_gen_resolved_ingredient_batch(resolved[i : i + batch_size]))

    for i in range(0, len(unresolved), batch_size):
        lines.extend(
            _gen_unresolved_ingredient_batch(
                unresolved[i : i + batch_size], new_ingredients
            )
        )

    return lines


def generate_migration(
    ingredient_rows: list[dict],
    allergen_rows: list[dict],
    new_ingredients: dict[str, dict],
    stats: dict,
) -> str:
    """Generate the migration SQL."""
    lines = [
        "-- Populate product_ingredient and product_allergen_info tables",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"-- Products processed: {stats['processed']}",
        f"-- Products with ingredients: {stats['with_ingredients']}",
        f"-- Products with allergens: {stats['with_allergens']}",
        f"-- New ingredient_ref entries: {len(new_ingredients)}",
        f"-- Total product_ingredient rows: {len(ingredient_rows)}",
        f"-- Total product_allergen_info rows: {len(allergen_rows)}",
        "",
        "BEGIN;",
        "",
    ]

    if new_ingredients:
        lines.extend(_gen_new_ingredients_section(new_ingredients))

    if allergen_rows:
        lines.extend(_gen_allergen_section(allergen_rows))

    if ingredient_rows:
        lines.extend(_gen_ingredient_section(ingredient_rows, new_ingredients))

    # 4. Refresh materialized views
    lines.append(SQL_SECTION_SEPARATOR)
    lines.append("-- 4. Refresh materialized views")
    lines.append(SQL_SECTION_SEPARATOR)
    lines.append("")
    lines.append("SELECT refresh_all_materialized_views();")
    lines.append("")
    lines.append("COMMIT;")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Enrich ingredient & allergen data from OFF API")
    parser.add_argument("--country", type=str, default=None, help="Country code filter (e.g. DE, PL)")
    args = parser.parse_args()

    print("=" * 60)
    print("Ingredient & Allergen Enrichment")
    if args.country:
        print(f"  Country filter: {args.country.upper()}")
    print("=" * 60)

    # Set migration filename dynamically to avoid overwrites
    global MIGRATION_FILE
    ts = datetime.now().strftime("%Y%m%d%H%M%S")
    MIGRATION_FILE = OUTPUT_DIR / f"{ts}_populate_ingredients_allergens.sql"

    # 1. Load products and ingredient_ref
    print("\n[1/4] Loading products from database...")
    products = get_products(country_filter=args.country.upper() if args.country else None)
    print(f"  Found {len(products)} active products with EANs")

    print("\n[2/4] Loading ingredient_ref...")
    ingredient_lookup = get_ingredient_ref()
    print(f"  Found {len(ingredient_lookup)} ingredients in reference table")

    # 2. Fetch from OFF API
    print("\n[3/4] Fetching ingredient data from OFF API...")
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

    try:
        for i, product in enumerate(products):
            if (i + 1) % 50 == 0 or i == 0:
                print(
                    f"  Processing {i+1}/{len(products)} "
                    f"(ingredients: {stats['with_ingredients']}, "
                    f"allergens: {stats['with_allergens']}, "
                    f"not found: {stats['not_found']})..."
                )

            off_data = fetch_off_product(product["ean"])
            stats["processed"] += 1

            if off_data is None:
                stats["not_found"] += 1
                time.sleep(DELAY)
                continue

            # Process ingredients
            ing_rows = process_ingredients(
                off_data,
                product["country"],
                product["ean"],
                ingredient_lookup,
                new_ingredients,
            )
            if ing_rows:
                stats["with_ingredients"] += 1
                all_ingredient_rows.extend(ing_rows)

            # Process allergens/traces
            alg_rows = process_allergens(off_data, product["country"], product["ean"])
            if alg_rows:
                stats["with_allergens"] += 1
                all_allergen_rows.extend(alg_rows)

            time.sleep(DELAY)
    except KeyboardInterrupt:
        print(
            f"\n  Interrupted at {stats['processed']}/{len(products)} — generating migration with collected data..."
        )

    # 3. Generate migration
    print("\n[4/4] Generating migration SQL...")
    print(f"  Products processed: {stats['processed']}")
    print(f"  With ingredients: {stats['with_ingredients']}")
    print(f"  With allergens/traces: {stats['with_allergens']}")
    print(f"  Not found on OFF: {stats['not_found']}")
    print(f"  New ingredients to add: {len(new_ingredients)}")
    print(f"  Total ingredient rows: {len(all_ingredient_rows)}")
    print(f"  Total allergen rows: {len(all_allergen_rows)}")

    sql = generate_migration(
        all_ingredient_rows, all_allergen_rows, new_ingredients, stats
    )

    MIGRATION_FILE.write_text(sql, encoding="utf-8")
    print(f"\n  Migration written to: {MIGRATION_FILE}")
    print(f"  File size: {MIGRATION_FILE.stat().st_size / 1024:.1f} KB")
    print("\nDone! Run the migration with:")
    print(
        "  docker exec supabase_db_poland-food-db psql -U postgres -d postgres -f ..."
    )
    print(
        f"  or: Get-Content '{MIGRATION_FILE}' -Raw | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres"
    )


if __name__ == "__main__":
    main()
