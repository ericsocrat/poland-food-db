"""Backfill ingredients_raw from Open Food Facts for all products with EANs.

Fetches ingredient lists via EAN lookup and generates a SQL migration file.

Usage::

    $env:PYTHONIOENCODING="utf-8"
    .\.venv\Scripts\python.exe backfill_ingredients_raw.py
"""

from __future__ import annotations

import subprocess
import sys
import time

import requests

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product/{ean}.json"
USER_AGENT = "poland-food-db/1.0 (https://github.com/ericsocrat/poland-food-db)"
REQUEST_DELAY = 0.5  # seconds between requests (respect OFF rate limits)
REQUEST_TIMEOUT = 30
MAX_RETRIES = 2

MIGRATION_PATH = "supabase/migrations/20260210001100_backfill_ingredients_raw.sql"


def get_products_from_db() -> list[dict]:
    """Fetch all active products with EANs from the local DB."""
    cmd = [
        "docker",
        "exec",
        "supabase_db_poland-food-db",
        "psql",
        "-U",
        "postgres",
        "-d",
        "postgres",
        "-t",
        "-A",
        "-F",
        "|",
        "-c",
        """
            SELECT p.product_id, p.ean, p.brand, p.product_name, p.category
            FROM products p
            JOIN ingredients i ON i.product_id = p.product_id
            WHERE p.is_deprecated IS NOT TRUE
              AND p.ean IS NOT NULL
              AND (i.ingredients_raw IS NULL OR i.ingredients_raw = '')
            ORDER BY p.category, p.brand, p.product_name;
        """,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        print(f"ERROR: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    products = []
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) >= 5:
            products.append(
                {
                    "product_id": parts[0].strip(),
                    "ean": parts[1].strip(),
                    "brand": parts[2].strip(),
                    "product_name": parts[3].strip(),
                    "category": parts[4].strip(),
                }
            )
    return products


def fetch_ingredients(ean: str, session: requests.Session) -> str | None:
    """Fetch ingredients_text from OFF for a given EAN."""
    url = OFF_PRODUCT_URL.format(ean=ean)
    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = session.get(
                url,
                params={"fields": "ingredients_text"},
                timeout=REQUEST_TIMEOUT,
            )
            resp.raise_for_status()
            data = resp.json()
            if data.get("status") != 1:
                return None
            text = (data.get("product", {}).get("ingredients_text") or "").strip()
            return text if text else None
        except (requests.RequestException, ValueError) as exc:
            if attempt < MAX_RETRIES:
                time.sleep(REQUEST_DELAY * (attempt + 1))
                continue
            return None


def sql_escape(text: str) -> str:
    """Escape single quotes for SQL."""
    return text.replace("'", "''")


def main() -> None:
    print("Backfill ingredients_raw from Open Food Facts")
    print("=" * 50)

    # 1. Get products from DB
    products = get_products_from_db()
    print(f"Found {len(products)} products with EAN but no ingredients_raw")
    if not products:
        print("Nothing to backfill.")
        return

    # 2. Fetch from OFF
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})

    results: list[tuple[str, str, str, str]] = (
        []
    )  # (product_id, brand, name, ingredients)
    found = 0
    skipped = 0

    for i, p in enumerate(products):
        ean = p["ean"]
        ingredients = fetch_ingredients(ean, session)
        if ingredients:
            results.append(
                (p["product_id"], p["brand"], p["product_name"], ingredients)
            )
            found += 1
        else:
            skipped += 1

        if (i + 1) % 25 == 0 or (i + 1) == len(products):
            print(
                f"  Progress: {i + 1}/{len(products)} "
                f"(found: {found}, no data: {skipped})"
            )

        time.sleep(REQUEST_DELAY)

    print(f"\nTotal: {found} have ingredients, {skipped} do not")

    if not results:
        print("No ingredients found. Skipping migration generation.")
        return

    # 3. Generate migration SQL
    lines: list[str] = []
    lines.append("-- Backfill ingredients_raw from Open Food Facts API")
    lines.append(f"-- Generated: 2026-02-10")
    lines.append(f"-- Products with ingredients: {found}/{len(products)}")
    lines.append("")

    # Group by category for readability
    from collections import defaultdict

    by_category: dict[str, list[tuple[str, str]]] = defaultdict(list)
    for pid, brand, name, ingr in results:
        # Find category from products list
        cat = next(
            (p["category"] for p in products if p["product_id"] == pid), "Unknown"
        )
        by_category[cat].append((pid, ingr))

    for cat in sorted(by_category):
        lines.append(f"-- {cat} ({len(by_category[cat])} products)")
        for pid, ingr in by_category[cat]:
            safe_ingr = sql_escape(ingr)
            # Truncate very long ingredient lists (>500 chars)
            if len(safe_ingr) > 500:
                safe_ingr = safe_ingr[:497] + "..."
            lines.append(
                f"UPDATE ingredients SET ingredients_raw = '{safe_ingr}' "
                f"WHERE product_id = {pid};"
            )
        lines.append("")

    migration_sql = "\n".join(lines)

    with open(MIGRATION_PATH, "w", encoding="utf-8") as f:
        f.write(migration_sql)

    print(f"\nMigration written to: {MIGRATION_PATH}")
    print(f"Run: supabase db reset  OR  pipe directly to psql")


if __name__ == "__main__":
    main()
