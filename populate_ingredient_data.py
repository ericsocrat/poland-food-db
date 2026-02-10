"""
Populate ingredient_ref, product_ingredient, product_allergen, product_trace
from OFF structured data.

Strategy:
  1. Fetch structured ingredients + allergens + traces for each product via EAN
  2. Build a canonical ingredient_ref dictionary (deduped by taxonomy_id)
  3. Generate migration SQL with INSERTs for all four tables
"""
import requests
import subprocess
import time
import re
import json
import sys
from collections import OrderedDict

# ── Config ──
MIGRATION_NUM = "20260210001400"
MIGRATION_NAME = "populate_ingredient_data"
MIGRATION_PATH = f"supabase/migrations/{MIGRATION_NUM}_{MIGRATION_NAME}.sql"
OFF_FIELDS = (
    "ingredients,allergens_tags,traces_tags,additives_tags,"
    "ingredients_from_palm_oil_n,ingredients_that_may_be_from_palm_oil_n"
)

# ── Get products from DB ──
print("Fetching products from DB...")
result = subprocess.run(
    ["docker", "exec", "supabase_db_poland-food-db", "psql", "-U", "postgres",
     "-d", "postgres", "-t", "-A", "-c",
     "SELECT p.product_id, p.ean FROM products p "
     "WHERE p.is_deprecated = false AND p.ean IS NOT NULL "
     "ORDER BY p.product_id"],
    capture_output=True, text=True, encoding="utf-8", errors="replace"
)
products = []
for line in result.stdout.strip().split("\n"):
    if not line.strip():
        continue
    parts = line.split("|", 1)
    if len(parts) == 2:
        products.append({"product_id": int(parts[0]), "ean": parts[1].strip()})

print(f"Products to process: {len(products)}")

# ── OFF session ──
session = requests.Session()
session.headers.update({"User-Agent": "poland-food-db/1.0"})

# ── Global state ──
# Canonical ingredient dictionary: taxonomy_id -> properties
ingredient_dict = OrderedDict()  # preserves insertion order
# Per-product data
product_ingredients = []  # (product_id, taxonomy_id, position, percent, percent_est, is_sub, parent_taxonomy_id)
product_allergens = []    # (product_id, allergen_tag)
product_traces = []       # (product_id, trace_tag)

# Stats
stats = {
    "products_fetched": 0,
    "products_with_ingredients": 0,
    "products_with_allergens": 0,
    "products_with_traces": 0,
    "unique_ingredients": 0,
    "total_ingredient_links": 0,
    "errors": 0,
}


def is_additive(taxonomy_id):
    """Check if a taxonomy ID is an E-number additive."""
    return bool(re.match(r"^en:e\d{3}", taxonomy_id))


def extract_ingredients(items, product_id, position_counter, parent_taxonomy_id=None):
    """Recursively extract ingredients from OFF structured array."""
    for item in items:
        taxonomy_id = item.get("id", "")
        if not taxonomy_id:
            # Use text as fallback ID
            text = item.get("text", "unknown").strip().lower()
            taxonomy_id = f"xx:{text.replace(' ', '-')}"

        name_en = taxonomy_id.split(":", 1)[-1].replace("-", " ") if ":" in taxonomy_id else taxonomy_id
        is_in_tax = bool(item.get("is_in_taxonomy", 0))
        vegan = item.get("vegan", "unknown") or "unknown"
        vegetarian = item.get("vegetarian", "unknown") or "unknown"
        palm_oil = "unknown"
        if item.get("from_palm_oil") == "yes":
            palm_oil = "yes"
        elif item.get("from_palm_oil") == "no":
            palm_oil = "no"

        # Register in dictionary (or update with richer data)
        if taxonomy_id not in ingredient_dict:
            ingredient_dict[taxonomy_id] = {
                "name_en": name_en,
                "is_additive": is_additive(taxonomy_id),
                "is_in_taxonomy": is_in_tax,
                "vegan": vegan,
                "vegetarian": vegetarian,
                "from_palm_oil": palm_oil,
            }
        else:
            # Update if we have better data
            existing = ingredient_dict[taxonomy_id]
            if vegan != "unknown" and existing["vegan"] == "unknown":
                existing["vegan"] = vegan
            if vegetarian != "unknown" and existing["vegetarian"] == "unknown":
                existing["vegetarian"] = vegetarian
            if palm_oil != "unknown" and existing["from_palm_oil"] == "unknown":
                existing["from_palm_oil"] = palm_oil
            if is_in_tax and not existing["is_in_taxonomy"]:
                existing["is_in_taxonomy"] = True

        pos = next(position_counter)
        is_sub = parent_taxonomy_id is not None

        percent = item.get("percent")
        percent_est = item.get("percent_estimate")

        product_ingredients.append((
            product_id, taxonomy_id, pos,
            percent, percent_est,
            is_sub, parent_taxonomy_id
        ))

        # Process sub-ingredients
        sub_items = item.get("ingredients", [])
        if sub_items:
            extract_ingredients(sub_items, product_id, position_counter, taxonomy_id)


def position_gen():
    """Simple position counter generator."""
    n = 0
    while True:
        n += 1
        yield n


# ── Fetch all products ──
print("Fetching from OFF API...")
for i, prod in enumerate(products):
    ean = prod["ean"]
    pid = prod["product_id"]

    try:
        resp = session.get(
            f"https://world.openfoodfacts.org/api/v2/product/{ean}.json",
            params={"fields": OFF_FIELDS},
            timeout=10,
        )
        data = resp.json()
        product = data.get("product", {})

        # Structured ingredients
        ingredients = product.get("ingredients", [])
        if ingredients:
            counter = position_gen()
            extract_ingredients(ingredients, pid, counter)
            stats["products_with_ingredients"] += 1
            stats["total_ingredient_links"] += sum(1 for pi in product_ingredients if pi[0] == pid)

        # Allergens
        allergens = product.get("allergens_tags", [])
        for atag in allergens:
            product_allergens.append((pid, atag))
        if allergens:
            stats["products_with_allergens"] += 1

        # Traces
        traces = product.get("traces_tags", [])
        for ttag in traces:
            product_traces.append((pid, ttag))
        if traces:
            stats["products_with_traces"] += 1

        stats["products_fetched"] += 1

    except Exception as e:
        print(f"  ERROR for {ean}: {e}", file=sys.stderr)
        stats["errors"] += 1

    if (i + 1) % 50 == 0:
        print(f"  Processed {i+1}/{len(products)} — "
              f"ingr_dict={len(ingredient_dict)}, "
              f"links={len(product_ingredients)}, "
              f"allergens={len(product_allergens)}, "
              f"traces={len(product_traces)}")

    time.sleep(0.15)

stats["unique_ingredients"] = len(ingredient_dict)

print(f"\n{'='*60}")
print(f"FETCH RESULTS:")
for k, v in stats.items():
    print(f"  {k}: {v}")

# ── Generate migration SQL ──
print(f"\nGenerating migration SQL...")

sql_lines = [
    f"-- Populate ingredient_ref, product_ingredient, product_allergen, product_trace",
    f"-- from OFF structured data ({stats['products_fetched']} products)",
    f"-- Generated by populate_ingredient_data.py",
    "",
    "BEGIN;",
    "",
    "-- ── 1. ingredient_ref inserts ──",
    "",
]


def esc(s):
    """Escape single quotes for SQL."""
    if s is None:
        return "NULL"
    return "'" + str(s).replace("'", "''") + "'"


# Insert canonical ingredients
for taxonomy_id, props in ingredient_dict.items():
    sql_lines.append(
        f"INSERT INTO ingredient_ref (taxonomy_id, name_en, is_additive, is_in_taxonomy, vegan, vegetarian, from_palm_oil) "
        f"VALUES ({esc(taxonomy_id)}, {esc(props['name_en'])}, {str(props['is_additive']).lower()}, "
        f"{str(props['is_in_taxonomy']).lower()}, {esc(props['vegan'])}, {esc(props['vegetarian'])}, "
        f"{esc(props['from_palm_oil'])}) "
        f"ON CONFLICT (taxonomy_id) DO NOTHING;"
    )

sql_lines.extend(["", "-- ── 2. product_ingredient inserts ──", ""])

# Build the junction table inserts
# We need ingredient_id from taxonomy_id -> use a subquery
for pi in product_ingredients:
    pid, tax_id, pos, pct, pct_est, is_sub, parent_tax = pi
    pct_sql = f"{pct}" if pct is not None else "NULL"
    pct_est_sql = f"{max(min(round(pct_est, 2), 100), 0)}" if pct_est is not None else "NULL"
    parent_sql = (
        f"(SELECT ingredient_id FROM ingredient_ref WHERE taxonomy_id = {esc(parent_tax)})"
        if parent_tax else "NULL"
    )

    sql_lines.append(
        f"INSERT INTO product_ingredient (product_id, ingredient_id, position, percent, percent_estimate, is_sub_ingredient, parent_ingredient_id) "
        f"VALUES ({pid}, (SELECT ingredient_id FROM ingredient_ref WHERE taxonomy_id = {esc(tax_id)}), "
        f"{pos}, {pct_sql}, {pct_est_sql}, {str(is_sub).lower()}, {parent_sql}) "
        f"ON CONFLICT DO NOTHING;"
    )

sql_lines.extend(["", "-- ── 3. product_allergen inserts ──", ""])

for pa in product_allergens:
    pid, atag = pa
    sql_lines.append(
        f"INSERT INTO product_allergen (product_id, allergen_tag) "
        f"VALUES ({pid}, {esc(atag)}) ON CONFLICT DO NOTHING;"
    )

sql_lines.extend(["", "-- ── 4. product_trace inserts ──", ""])

for pt in product_traces:
    pid, ttag = pt
    sql_lines.append(
        f"INSERT INTO product_trace (product_id, trace_tag) "
        f"VALUES ({pid}, {esc(ttag)}) ON CONFLICT DO NOTHING;"
    )

sql_lines.extend(["", "COMMIT;"])

with open(MIGRATION_PATH, "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lines))

print(f"Migration written to: {MIGRATION_PATH}")
print(f"  ingredient_ref rows:      {len(ingredient_dict)}")
print(f"  product_ingredient rows:  {len(product_ingredients)}")
print(f"  product_allergen rows:    {len(product_allergens)}")
print(f"  product_trace rows:       {len(product_traces)}")
