"""
Guardrail: block new enrichment migrations that anchor rows by raw product_id.

Why:
- product_id values differ between local/CI/prod
- enrichment migrations must resolve product_id via stable key (country + ean)

This script scans enrichment migration files and fails if INSERT statements for:
- product_allergen_info
- product_ingredient
use direct VALUES with product_id literals instead of JOINing products by
(country, ean).

Historical exception:
- 20260213000500_populate_ingredients_allergens.sql is legacy and grandfathered.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent
MIGRATIONS_DIR = ROOT / "supabase" / "migrations"
LEGACY_ALLOWLIST = {
    "20260213000500_populate_ingredients_allergens.sql",
}

TARGET_PATTERNS = [
    "_populate_ingredients_allergens.sql",
]


def split_sql_statements(sql: str) -> list[str]:
    parts = [p.strip() for p in sql.split(";")]
    return [p for p in parts if p]


def is_target_file(path: Path) -> bool:
    name = path.name
    if name in LEGACY_ALLOWLIST:
        return False
    return any(name.endswith(suffix) for suffix in TARGET_PATTERNS)


def validate_statement(stmt: str) -> str | None:
    s = re.sub(r"\s+", " ", stmt.strip()).lower()

    is_allergen_insert = "insert into product_allergen_info (product_id" in s
    is_ingredient_insert = "insert into product_ingredient (product_id" in s
    if not (is_allergen_insert or is_ingredient_insert):
        return None

    has_join_identity = "join products p on p.country = v.country and p.ean = v.ean" in s
    has_direct_values = "insert into product_allergen_info (product_id" in s and " values " in s

    if is_ingredient_insert:
        has_direct_values = " values " in s and " from (values " not in s

    if has_direct_values:
        return "Direct VALUES-based insert detected for product_id-anchored enrichment insert"

    if not has_join_identity:
        return "Missing stable-key join: JOIN products p ON p.country = v.country AND p.ean = v.ean"

    return None


def main() -> int:
    if not MIGRATIONS_DIR.exists():
        print(f"ERROR: migrations directory not found: {MIGRATIONS_DIR}")
        return 1

    target_files = sorted(p for p in MIGRATIONS_DIR.glob("*.sql") if is_target_file(p))
    if not target_files:
        print("No non-legacy enrichment migration files found to validate.")
        return 0

    violations: list[str] = []
    for path in target_files:
        sql = path.read_text(encoding="utf-8", errors="replace")
        statements = split_sql_statements(sql)
        for i, stmt in enumerate(statements, start=1):
            issue = validate_statement(stmt)
            if issue:
                violations.append(f"{path.name} [statement #{i}]: {issue}")

    if violations:
        print("\n❌ Enrichment identity guard failed:\n")
        for v in violations:
            print(f"  - {v}")
        print("\nFix: resolve product_id via (country, ean) join in migration SQL generation.")
        return 1

    print("✅ Enrichment identity guard passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
