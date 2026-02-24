"""
Migration Ordering Validator — Drift Detection Automation (#199)

Verifies that all migration files in supabase/migrations/ have:
1. Monotonically increasing timestamps (no duplicates, no out-of-order)
2. Valid YYYYMMDDHHMMSS prefix format
3. Descriptive suffix (no bare timestamps)

Usage:
    python scripts/check_migration_order.py
    python scripts/check_migration_order.py --migrations-dir supabase/migrations

Exit codes:
    0 — All migrations properly ordered
    1 — Ordering violations detected
"""

import argparse
import os
import re
import sys

MIGRATION_PATTERN = re.compile(r"^(\d{14})_(.+)\.sql$")


def check_migration_ordering(migrations_dir: str = "supabase/migrations") -> list[str]:
    """
    Validate migration files are monotonically increasing.

    Returns a list of violation messages (empty = all good).
    """
    violations: list[str] = []

    if not os.path.isdir(migrations_dir):
        violations.append(f"Directory not found: {migrations_dir}")
        return violations

    files = sorted(f for f in os.listdir(migrations_dir) if f.endswith(".sql"))

    if not files:
        violations.append(f"No .sql files found in {migrations_dir}")
        return violations

    prev_timestamp = ""
    prev_file = ""
    seen_timestamps: dict[str, str] = {}

    for filename in files:
        match = MIGRATION_PATTERN.match(filename)

        if not match:
            violations.append(
                f"NAMING: '{filename}' does not match YYYYMMDDHHMMSS_description.sql"
            )
            continue

        timestamp = match.group(1)
        description = match.group(2)

        # Check for empty/trivial descriptions
        if len(description) < 3:
            violations.append(
                f"NAMING: '{filename}' has too-short description '{description}'"
            )

        # Check for duplicate timestamps
        if timestamp in seen_timestamps:
            violations.append(
                f"DUPLICATE: '{filename}' has same timestamp as '{seen_timestamps[timestamp]}'"
            )

        # Check monotonic ordering
        if timestamp < prev_timestamp:
            violations.append(
                f"ORDER: '{filename}' (ts={timestamp}) comes after "
                f"'{prev_file}' (ts={prev_timestamp}) but has earlier timestamp"
            )

        seen_timestamps[timestamp] = filename
        prev_timestamp = timestamp
        prev_file = filename

    return violations


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate migration file ordering (drift detection)"
    )
    parser.add_argument(
        "--migrations-dir",
        type=str,
        default="supabase/migrations",
        help="Path to migrations directory (default: supabase/migrations)",
    )
    args = parser.parse_args()

    violations = check_migration_ordering(args.migrations_dir)

    if not violations:
        count = sum(1 for f in os.listdir(args.migrations_dir) if f.endswith(".sql"))
        print(
            f"OK  All {count} migrations in {args.migrations_dir}/ are properly ordered"
        )
        return 0

    print(f"MIGRATION ORDERING VIOLATIONS ({len(violations)}):")
    print()
    for v in violations:
        print(f"  {v}")

    return 1


if __name__ == "__main__":
    sys.exit(main())
