"""Fetch products from Open Food Facts and generate pipeline SQL.

Two acquisition modes:
  1. EAN list  (primary) — provide EANs from store visits, CSV, etc.
     Each EAN is fetched individually from the OFF product API.
  2. OFF search (discovery) — search OFF by category tag + country.
     Returns products matching the category, filtered to the target country.

Generates the 4-step pipeline SQL files matching the project's exact
idempotent patterns:

  01_insert_products.sql   — upsert on (country, brand, product_name)
  03_add_nutrition.sql     — delete-then-insert nutrition_facts
  04_scoring.sql           — Nutri-Score + NOVA + CALL score_category()
  05_source_provenance.sql — source_type, source_url, source_ean

Usage:
    # From a list of EANs (primary workflow — most reliable)
    python fetch_off_category.py --country PL --category Chips --ean-file eans.txt
    python fetch_off_category.py --country PL --category Chips --eans 5900073020262,5905187114760

    # From OFF search (discovery — finds globally-tagged products)
    python fetch_off_category.py --country PL --category Chips --off-search "en:chips" --limit 100

    # Dry run (preview without writing files)
    python fetch_off_category.py --country PL --category Chips --ean-file eans.txt --dry-run

Prerequisites:
    pip install requests
"""

from __future__ import annotations

import argparse
import math
import os
import re
import subprocess
import sys
import time
from datetime import date
from pathlib import Path

import requests

# --- Constants ---

OFF_SEARCH_URL = "https://world.openfoodfacts.org/api/v2/search"
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product/{ean}.json"
USER_AGENT = "poland-food-db/1.0 (https://github.com/ericsocrat/poland-food-db)"

# Fields to retrieve from the per-product endpoint
PRODUCT_FIELDS = (
    "code,product_name,brands,categories_tags,"
    "nutriscore_grade,nova_group,nova_groups_tags,"
    "nutriments,countries_tags"
)

# Same fields for the search endpoint
SEARCH_FIELDS = PRODUCT_FIELDS

# Rate limiting
DELAY = 0.35  # seconds between API requests (~100/min OFF limit)
TIMEOUT = 30
MAX_RETRIES = 2

# Nutrition columns that map from OFF nutriments
NUTRITION_MAP = {
    "calories": ("energy-kcal_100g",),
    "total_fat_g": ("fat_100g",),
    "saturated_fat_g": ("saturated-fat_100g",),
    "trans_fat_g": ("trans-fat_100g",),
    "carbs_g": ("carbohydrates_100g",),
    "sugars_g": ("sugars_100g",),
    "fibre_g": ("fiber_100g",),
    "protein_g": ("proteins_100g",),
    "salt_g": ("salt_100g",),
}

PIPELINE_DIR = Path(__file__).parent / "db" / "pipelines"

DB_CONTAINER = "supabase_db_poland-food-db"
DB_USER = "postgres"
DB_NAME = "postgres"

# Country code → EAN prefix ranges for client-side filtering
COUNTRY_EAN_PREFIXES: dict[str, tuple[str, ...]] = {
    "PL": ("590",),
    "DE": ("400", "401", "402", "403", "404", "440"),
    "FR": tuple(str(i) for i in range(300, 380)),
    "ES": tuple(str(i) for i in range(840, 850)),
    "IT": tuple(str(i) for i in range(800, 840)),
    "GB": tuple(str(i) for i in range(500, 510)),
}

# Country code → OFF country tag mapping
COUNTRY_TAGS = {
    "PL": "poland",
    "DE": "germany",
    "FR": "france",
    "ES": "spain",
    "IT": "italy",
    "GB": "united-kingdom",
    "US": "united-states",
    "CZ": "czech-republic",
    "SK": "slovakia",
    "AT": "austria",
    "NL": "netherlands",
    "BE": "belgium",
    "SE": "sweden",
    "DK": "denmark",
    "NO": "norway",
    "FI": "finland",
    "PT": "portugal",
    "RO": "romania",
    "HU": "hungary",
    "BG": "bulgaria",
    "HR": "croatia",
    "LT": "lithuania",
    "LV": "latvia",
    "EE": "estonia",
    "SI": "slovenia",
    "IE": "ireland",
    "GR": "greece",
    "CH": "switzerland",
}


# --- Helpers ---


def sql_escape(val: str) -> str:
    """Escape a string for SQL literal embedding (single-quote doubling)."""
    return val.replace("'", "''")


def ean_checksum_valid(ean: str) -> bool:
    """Validate EAN-8 or EAN-13 check digit."""
    if not ean or not ean.isdigit() or len(ean) not in (8, 13):
        return False
    digits = [int(d) for d in ean]
    if len(ean) == 13:
        total = sum(d * (1 if i % 2 == 0 else 3) for i, d in enumerate(digits[:-1]))
    else:
        total = sum(d * (3 if i % 2 == 0 else 1) for i, d in enumerate(digits[:-1]))
    expected = (10 - (total % 10)) % 10
    return digits[-1] == expected


def sanitize_folder_name(category: str) -> str:
    """Convert a category name to a valid folder name (lowercase, hyphens)."""
    name = category.lower()
    name = name.replace("ż", "z").replace("ą", "a").replace("ę", "e")
    name = name.replace("ó", "o").replace("ś", "s").replace("ć", "c")
    name = name.replace("ź", "z").replace("ł", "l").replace("ń", "n")
    name = re.sub(r"[^a-z0-9]+", "-", name)
    return name.strip("-")


def extract_nutrition(nutriments: dict) -> dict:
    """Extract nutrition values from OFF nutriments dict."""
    result = {}
    for col, keys in NUTRITION_MAP.items():
        val = None
        for key in keys:
            if key in nutriments:
                try:
                    val = round(float(nutriments[key]), 1)
                except (ValueError, TypeError):
                    continue
                break
        result[col] = val if val is not None else 0
    return result


def extract_nutri_score(product: dict) -> str:
    """Extract Nutri-Score letter from OFF product data."""
    grade = product.get("nutriscore_grade", "")
    if grade and grade.upper() in ("A", "B", "C", "D", "E"):
        return grade.upper()
    return "UNKNOWN"


def extract_nova(product: dict) -> str:
    """Extract NOVA group (1-4) from OFF product data."""
    # Try nova_group field first
    ng = product.get("nova_group")
    if ng and str(ng) in ("1", "2", "3", "4"):
        return str(ng)
    # Try nova_groups_tags
    tags = product.get("nova_groups_tags", [])
    for tag in tags or []:
        for n in ("1", "2", "3", "4"):
            if n in str(tag):
                return n
    return "UNKNOWN"


def _psql_cmd(query: str) -> list[str]:
    """Build psql command for local or CI mode."""
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


def get_existing_categories() -> set[str]:
    """Get set of registered category names from category_ref."""
    cmd = _psql_cmd("SELECT category FROM category_ref;")
    result = subprocess.run(
        cmd, capture_output=True, timeout=30, encoding="utf-8", errors="replace"
    )
    if result.returncode != 0:
        return set()
    return {line.strip() for line in result.stdout.strip().split("\n") if line.strip()}


# --- OFF API ---


def _matches_country(
    product: dict, ean_prefixes: tuple[str, ...], country_tag: str
) -> bool:
    """Return True if the product matches the target country by EAN prefix or tag."""
    code = str(product.get("code", ""))
    countries = product.get("countries_tags") or []
    ean_match = ean_prefixes and any(code.startswith(pf) for pf in ean_prefixes)
    return ean_match or country_tag in countries


def _fetch_search_page(
    session: requests.Session,
    off_tag: str,
    page: int,
    page_size: int,
) -> list[dict] | None:
    """Fetch a single search page with retries. Returns None on total failure."""
    params = {
        "categories_tags": off_tag,
        "page_size": page_size,
        "page": page,
        "fields": SEARCH_FIELDS,
    }
    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = session.get(OFF_SEARCH_URL, params=params, timeout=TIMEOUT)
            resp.raise_for_status()
            return resp.json().get("products", [])
        except requests.RequestException as e:
            if attempt == MAX_RETRIES:
                print(
                    f"  WARN: Search page {page} failed after {MAX_RETRIES+1} attempts: {e}",
                    file=sys.stderr,
                )
                return None
            time.sleep(2**attempt)
    return None  # unreachable, but keeps linters happy


def _filter_country_matches(
    page_products: list[dict],
    ean_prefixes: tuple[str, ...],
    country_tag: str,
    products: list[dict],
    max_products: int,
) -> None:
    """Append country-matched products from a search page to the results list."""
    for p in page_products:
        if _matches_country(p, ean_prefixes, country_tag):
            products.append(p)
            if len(products) >= max_products:
                break


def search_off_products(
    off_tag: str,
    country: str,
    page_size: int = 100,
    max_products: int = 200,
) -> list[dict]:
    """Search OFF v2 API for products by category tag, with pagination.

    Country filtering is done client-side by EAN prefix and countries_tags
    because OFF search indexing for non-Western countries is unreliable.
    """
    products: list[dict] = []
    page = 1
    pages_needed = math.ceil(max_products / page_size)

    ean_prefixes = COUNTRY_EAN_PREFIXES.get(country, ())
    country_tag = f"en:{COUNTRY_TAGS.get(country, country.lower())}"

    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})

    max_pages = pages_needed * 5  # allow up to 5x more pages for sparse data

    while page <= max_pages and len(products) < max_products:
        page_products = _fetch_search_page(session, off_tag, page, page_size)
        if page_products is None:
            return products
        if not page_products:
            break

        _filter_country_matches(
            page_products, ean_prefixes, country_tag, products, max_products
        )

        print(
            f"  Page {page}: scanned {len(page_products)} "
            f"(matched: {len(products)}/{max_products})"
        )

        if len(page_products) < page_size:
            break  # last page

        page += 1
        time.sleep(DELAY)

    return products[:max_products]


def _fetch_single_ean(
    session: requests.Session, ean: str
) -> requests.Response | None:
    """Fetch a single EAN with retry logic. Returns response or None."""
    url = OFF_PRODUCT_URL.format(ean=ean)
    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = session.get(
                url, params={"fields": PRODUCT_FIELDS}, timeout=TIMEOUT
            )
            resp.raise_for_status()
            return resp
        except requests.RequestException as e:
            if attempt == MAX_RETRIES:
                print(f"FAILED ({e})")
                return None
            time.sleep(2**attempt)
    return None


def _extract_valid_product(data: dict) -> dict | None:
    """Extract and validate a product from OFF API response data."""
    if data.get("status") != 1 or not data.get("product"):
        print("NOT FOUND on OFF")
        return None

    product = data["product"]
    name = (product.get("product_name") or "").strip()
    brand = (product.get("brands") or "").strip()

    if not name or not brand:
        print("SKIP — missing name or brand")
        return None

    print(f"OK — {brand} | {name}")
    return product


def fetch_products_by_eans(eans: list[str]) -> list[dict]:
    """Fetch product data from OFF for a list of EANs.

    This is the primary acquisition mode — most reliable for Polish products.
    """
    products: list[dict] = []
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})

    for i, ean in enumerate(eans, 1):
        print(f"  [{i}/{len(eans)}] Fetching {ean}...", end=" ")

        resp = _fetch_single_ean(session, ean)
        if resp is None:
            time.sleep(DELAY)
            continue

        product = _extract_valid_product(resp.json())
        if product is not None:
            products.append(product)

        time.sleep(DELAY)

    return products


# --- Product processing ---


def _is_valid_ean(ean: str) -> bool:
    """Check if an EAN string is a valid 8- or 13-digit barcode."""
    return (
        bool(ean) and ean.isdigit() and len(ean) in (8, 13) and ean_checksum_valid(ean)
    )


def _is_valid_product_name(name: str) -> bool:
    """Check if a product name is valid (non-empty, at least 3 chars)."""
    return bool(name) and len(name) >= 3


def process_off_products(
    raw_products: list[dict],
    country: str,
) -> list[dict]:
    """Clean and normalize OFF products into our schema format.

    Returns list of dicts with keys matching our pipeline columns.
    Filters out products without valid EANs or product names.
    """
    seen_eans: set[str] = set()
    seen_names: set[str] = set()
    processed = []

    for raw in raw_products:
        ean = str(raw.get("code", "")).strip()
        name = (raw.get("product_name") or "").strip()
        brand = (raw.get("brands") or "Unknown").split(",")[0].strip()

        # --- Filters ---
        if not _is_valid_ean(ean) or not _is_valid_product_name(name):
            continue
        if ean in seen_eans:
            continue
        # Deduplicate by (brand, name) — the upsert key
        identity = (brand.lower(), name.lower())
        if identity in seen_names:
            continue

        seen_eans.add(ean)
        seen_names.add(identity)

        # --- Nutrition ---
        nutriments = raw.get("nutriments", {})
        nutrition = extract_nutrition(nutriments)

        # --- Scoring ---
        nutri_score = extract_nutri_score(raw)
        nova = extract_nova(raw)

        processed.append(
            {
                "country": country,
                "ean": ean,
                "brand": brand,
                "product_name": name,
                "product_type": "Grocery",
                "prep_method": "not-applicable",
                "store_availability": None,
                "controversies": "none",
                "nutrition": nutrition,
                "nutri_score": nutri_score,
                "nova": nova,
            }
        )

    return processed


# --- SQL generation ---


def generate_step_01(products: list[dict], category: str, country: str) -> str:
    """Generate 01_insert_products.sql matching the project's exact pattern."""
    today = date.today().isoformat()
    ean_list = ", ".join(f"'{p['ean']}'" for p in products)
    name_list = ", ".join(f"'{sql_escape(p['product_name'])}'" for p in products)

    values = []
    for p in products:
        store = (
            f"'{sql_escape(p['store_availability'])}'"
            if p["store_availability"]
            else "null"
        )
        values.append(
            f"  ('{p['country']}', '{sql_escape(p['brand'])}', '{p['product_type']}', "
            f"'{sql_escape(category)}', '{sql_escape(p['product_name'])}', "
            f"'{p['prep_method']}', {store}, '{p['controversies']}', '{p['ean']}')"
        )

    return f"""\
-- PIPELINE ({category}): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: {today}

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = '{country}'
  and category = '{sql_escape(category)}'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ({ean_list})
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
{",\n".join(values)}
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = '{country}' and category = '{sql_escape(category)}'
  and is_deprecated is not true
  and product_name not in ({name_list});
"""


def generate_step_03(products: list[dict], category: str, country: str) -> str:
    """Generate 03_add_nutrition.sql matching the project's exact pattern."""
    today = date.today().isoformat()
    values = []
    for p in products:
        n = p["nutrition"]
        values.append(
            f"    ('{sql_escape(p['brand'])}', '{sql_escape(p['product_name'])}', "
            f"{n['calories']}, {n['total_fat_g']}, {n['saturated_fat_g']}, "
            f"{n['trans_fat_g']}, {n['carbs_g']}, {n['sugars_g']}, "
            f"{n['fibre_g']}, {n['protein_g']}, {n['salt_g']})"
        )

    return f"""\
-- PIPELINE ({category}): add nutrition facts
-- Source: Open Food Facts verified per-100g data
-- Generated: {today}

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = '{country}' and p.category = '{sql_escape(category)}'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
{",\n".join(values)}
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = '{country}' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = '{sql_escape(category)}' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
"""


def generate_step_04(products: list[dict], category: str, country: str) -> str:
    """Generate 04_scoring.sql matching the project's exact pattern."""
    today = date.today().isoformat()

    ns_values = []
    nova_values = []
    for p in products:
        ns_values.append(
            f"    ('{sql_escape(p['brand'])}', '{sql_escape(p['product_name'])}', "
            f"'{p['nutri_score']}')"
        )
        nova_val = "NULL" if p["nova"] == "UNKNOWN" else f"'{p['nova']}'"
        nova_values.append(
            f"    ('{sql_escape(p['brand'])}', '{sql_escape(p['product_name'])}', "
            f"{nova_val})"
        )

    return f"""\
-- PIPELINE ({category}): scoring
-- Generated: {today}

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
{",\n".join(ns_values)}
) as d(brand, product_name, ns)
where p.country = '{country}' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
{",\n".join(nova_values)}
) as d(brand, product_name, nova)
where p.country = '{country}' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('{sql_escape(category)}', 100, '{country}');
"""


def generate_step_05(products: list[dict], category: str, country: str) -> str:
    """Generate 05_source_provenance.sql matching the project's exact pattern."""
    today = date.today().isoformat()
    values = []
    for p in products:
        url = f"https://world.openfoodfacts.org/product/{p['ean']}"
        values.append(
            f"    ('{sql_escape(p['brand'])}', '{sql_escape(p['product_name'])}', "
            f"'{url}', '{p['ean']}')"
        )

    return f"""\
-- PIPELINE ({category}): source provenance
-- Generated: {today}

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
{",\n".join(values)}
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = '{country}' AND p.brand = d.brand AND p.product_name = d.product_name;
"""


# --- Main helpers ---


def _collect_ean_list(args: argparse.Namespace) -> list[str]:
    """Build the EAN list from --eans and --ean-file arguments."""
    ean_list: list[str] = []
    if args.eans:
        ean_list.extend(e.strip() for e in args.eans.split(",") if e.strip())
    if args.ean_file:
        ean_path = Path(args.ean_file)
        if not ean_path.exists():
            print(f"ERROR: EAN file not found: {ean_path}")
            sys.exit(1)
        for line in ean_path.read_text(encoding="utf-8").splitlines():
            clean = line.strip()
            if clean and not clean.startswith("#"):
                ean_list.append(clean)

    # Validate EAN format
    invalid_eans = [e for e in ean_list if not e.isdigit() or len(e) not in (8, 13)]
    if invalid_eans:
        print(
            f"WARNING: Skipping {len(invalid_eans)} invalid EANs: "
            f"{', '.join(invalid_eans[:5])}{'...' if len(invalid_eans) > 5 else ''}"
        )
        ean_list = [e for e in ean_list if e not in invalid_eans]
    return ean_list


def _fetch_raw_products(
    args: argparse.Namespace, ean_list: list[str], country: str
) -> list[dict]:
    """Fetch raw product data via EAN list and/or OFF search."""
    raw_products: list[dict] = []

    if ean_list:
        print(f"Fetching {len(ean_list)} products by EAN...")
        ean_products = fetch_products_by_eans(ean_list)
        raw_products.extend(ean_products)
        print(f"  EAN mode: {len(ean_products)}/{len(ean_list)} found\n")

    if args.off_search:
        print(f"Searching OFF for '{args.off_search}' in {country}...")
        search_products = search_off_products(
            args.off_search, country, page_size=100, max_products=args.limit
        )
        raw_products.extend(search_products)
        print(f"  Search mode: {len(search_products)} matched\n")

    return raw_products


def _print_data_quality(products: list[dict]) -> None:
    """Print data quality statistics for processed products."""
    total = len(products)
    ns_known = sum(1 for p in products if p["nutri_score"] != "UNKNOWN")
    nova_known = sum(1 for p in products if p["nova"] != "UNKNOWN")
    nutrition_complete = sum(
        1
        for p in products
        if p["nutrition"]["calories"] > 0 and p["nutrition"]["protein_g"] >= 0
    )

    print("Data quality summary:")
    print(f"  Products with valid EAN:    {total}")
    print(f"  Nutri-Score available:      {ns_known}/{total} ({100*ns_known//total}%)")
    print(
        f"  NOVA group available:       {nova_known}/{total} ({100*nova_known//total}%)"
    )
    print(
        f"  Nutrition data present:     {nutrition_complete}/{total} "
        f"({100*nutrition_complete//total}%)"
    )
    print()


def _write_pipeline_files(
    products: list[dict],
    output_dir: Path,
    folder_name: str,
    category: str,
    country: str,
    overwrite: bool,
) -> None:
    """Generate and write the 4-step pipeline SQL files."""
    if not output_dir.exists():
        output_dir.mkdir(parents=True)
        print(f"Created pipeline folder: {output_dir}")

    files = {
        f"PIPELINE__{folder_name}__01_insert_products.sql": generate_step_01(
            products, category, country
        ),
        f"PIPELINE__{folder_name}__03_add_nutrition.sql": generate_step_03(
            products, category, country
        ),
        f"PIPELINE__{folder_name}__04_scoring.sql": generate_step_04(
            products, category, country
        ),
        f"PIPELINE__{folder_name}__05_source_provenance.sql": generate_step_05(
            products, category, country
        ),
    }

    for filename, content in files.items():
        path = output_dir / filename
        if path.exists() and not overwrite:
            print(f"  SKIP: {path.name} (exists — use --overwrite to replace)")
            continue
        path.write_text(content, encoding="utf-8", newline="\n")
        print(f"  WROTE: {path.name} ({len(content):,} bytes)")

    print()
    print("=" * 60)
    print(f"  Pipeline generated: {len(products)} products")
    print("=" * 60)
    print()
    print("Next steps:")
    print(f"  1. Review generated SQL in {output_dir}/")
    print(f"  2. Run pipeline:  .\\RUN_LOCAL.ps1 -Category {folder_name}")
    print("  3. Enrich:        python enrich_ingredients.py")
    print("  4. Validate:      .\\RUN_QA.ps1")
    print()


# --- Main ---


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch products from Open Food Facts and generate pipeline SQL.",
        epilog=(
            "Examples:\n"
            "  # Primary: fetch by EAN list (most reliable for PL)\n"
            "  python fetch_off_category.py --country PL --category Chips --ean-file eans.txt\n"
            "  python fetch_off_category.py --country PL --category Chips --eans 5900073020262,5905187114760\n"
            "\n"
            "  # Discovery: search OFF by category tag\n"
            '  python fetch_off_category.py --country PL --category Chips --off-search "en:chips" --limit 100\n'
            "\n"
            "  # Combined: EAN list + OFF discovery\n"
            '  python fetch_off_category.py --country PL --category Chips --ean-file eans.txt --off-search "en:chips"\n'
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--country", required=True, help="Two-letter country code (e.g., PL, DE, FR)"
    )
    parser.add_argument(
        "--category",
        required=True,
        help="Category name as it appears in category_ref (e.g., 'Chips', 'Frozen & Prepared')",
    )

    # Acquisition modes (at least one required)
    acq = parser.add_argument_group("acquisition modes (at least one required)")
    acq.add_argument(
        "--eans", type=str, default=None, help="Comma-separated list of EAN barcodes"
    )
    acq.add_argument(
        "--ean-file",
        type=str,
        default=None,
        help="Path to a text file with one EAN per line",
    )
    acq.add_argument(
        "--off-search",
        type=str,
        default=None,
        help="OFF category tag for search discovery (e.g., 'en:chips')",
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=100,
        help="Max products from OFF search (default: 100, ignored for EAN mode)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Fetch and report without writing SQL files",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing pipeline files if present",
    )

    args = parser.parse_args()

    country = args.country.upper()
    category = args.category

    # Validate country
    if country not in COUNTRY_TAGS:
        print(
            f"ERROR: Unknown country code '{country}'. "
            f"Supported: {', '.join(sorted(COUNTRY_TAGS.keys()))}"
        )
        sys.exit(1)

    # Validate at least one acquisition mode
    if not args.eans and not args.ean_file and not args.off_search:
        print("ERROR: Provide at least one of --eans, --ean-file, or --off-search")
        parser.print_help()
        sys.exit(1)

    # Collect EANs from arguments
    ean_list = _collect_ean_list(args)

    folder_name = sanitize_folder_name(category)
    folder_name = f"{folder_name}-{country.lower()}"
    output_dir = PIPELINE_DIR / folder_name

    print("=" * 60)
    print("  Poland Food DB — OFF Category Fetcher")
    print("=" * 60)
    print(f"  Country:      {country} (en:{COUNTRY_TAGS[country]})")
    print(f"  Category:     {category}")
    if ean_list:
        print(f"  EAN list:     {len(ean_list)} barcodes")
    if args.off_search:
        print(f"  OFF search:   {args.off_search} (limit {args.limit})")
    print(f"  Output:       {output_dir}")
    print(f"  Dry run:      {args.dry_run}")
    print()

    # ── Check category registration ──
    existing = get_existing_categories()
    if existing and category not in existing:
        print(f"  WARNING: Category '{category}' is not in category_ref.")
        print(f"  Registered categories: {', '.join(sorted(existing))}")
        print("  You may need to add it before running the pipeline.")
        print()

    # ── Fetch from OFF ──
    raw_products = _fetch_raw_products(args, ean_list, country)
    print(f"  Total raw products: {len(raw_products)}")

    # ── Process & filter ──
    products = process_off_products(raw_products, country)
    print(f"  After validation/dedup: {len(products)}")
    print()

    if not products:
        print("ERROR: No valid products found. Try a different OFF tag or country.")
        sys.exit(1)

    # ── Statistics ──
    _print_data_quality(products)

    if args.dry_run:
        print("DRY RUN — no files written. Product preview:")
        for i, p in enumerate(products[:10], 1):
            print(
                f"  {i:3d}. [{p['ean']}] {p['brand']} — {p['product_name']} "
                f"(NS:{p['nutri_score']}, NOVA:{p['nova']})"
            )
        if len(products) > 10:
            print(f"  ... and {len(products) - 10} more")
        return

    # ── Generate SQL files ──
    _write_pipeline_files(
        products, output_dir, folder_name, category, country, args.overwrite
    )
    print()


if __name__ == "__main__":
    main()
