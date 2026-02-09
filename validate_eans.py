"""
EAN-13 Checksum Validator for Poland Food DB.

Queries all non-deprecated products with EAN codes and validates
that each has a correct EAN-13 check digit.

Exit code:
    0  — all EANs valid
    1  — one or more invalid checksums detected

Output format (last line):
    Results: N valid, M invalid
"""

import subprocess
import sys


def ean_check_digit(digits: str, length: int) -> str:
    """Compute the expected check digit for an EAN-8 or EAN-13 prefix.

    EAN-13: 12-digit prefix, weights alternate 1,3,1,3,...
    EAN-8:   7-digit prefix, weights alternate 3,1,3,1,...
    """
    prefix_len = length - 1
    if length == 13:
        weights = [1 if i % 2 == 0 else 3 for i in range(prefix_len)]
    else:  # EAN-8
        weights = [3 if i % 2 == 0 else 1 for i in range(prefix_len)]
    total = sum(int(d) * w for d, w in zip(digits[:prefix_len], weights))
    return str((10 - total % 10) % 10)


def validate_ean(ean: str) -> tuple[bool, str]:
    """Validate an EAN-8 or EAN-13 code. Returns (is_valid, reason)."""
    if not ean or ean.strip() == "":
        return False, "empty"
    ean = ean.strip()
    if not ean.isdigit():
        return False, f"non-numeric: {ean}"
    if len(ean) not in (8, 13):
        return False, f"wrong length ({len(ean)}): {ean}"
    expected = ean_check_digit(ean, len(ean))
    last = ean[-1]
    if last != expected:
        fmt = "EAN-8" if len(ean) == 8 else "EAN-13"
        return False, f"bad {fmt} checksum: {ean} (expected ...{expected}, got ...{last})"
    return True, ""


DB_CONTAINER = "supabase_db_poland-food-db"
DB_USER = "postgres"
DB_NAME = "postgres"

QUERY = """
SELECT brand, product_name, category, ean
FROM products
WHERE is_deprecated IS NOT TRUE
  AND ean IS NOT NULL
  AND ean <> ''
ORDER BY category, brand, product_name;
"""


def main() -> int:
    # Query the database
    result = subprocess.run(
        [
            "docker", "exec", "-i", DB_CONTAINER,
            "psql", "-U", DB_USER, "-d", DB_NAME,
            "-t", "-A", "-F", "|",
            "-c", QUERY,
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
    )

    if result.returncode != 0:
        print(f"ERROR: Database query failed:\n{result.stderr}", file=sys.stderr)
        return 2

    lines = [line for line in result.stdout.strip().splitlines() if line.strip()]
    if not lines:
        print("WARNING: No products with EAN codes found.")
        return 0

    valid_count = 0
    invalid_count = 0
    invalid_details: list[str] = []

    for line in lines:
        parts = line.split("|", 3)
        if len(parts) < 4:
            continue
        brand, product_name, category, ean = parts
        is_valid, reason = validate_ean(ean)
        if is_valid:
            valid_count += 1
        else:
            invalid_count += 1
            invalid_details.append(
                f"  [{category}] {brand} — {product_name}: {reason}"
            )

    # Print results
    if invalid_details:
        print(f"Invalid EAN checksums ({invalid_count}):")
        for detail in invalid_details:
            print(detail)
        print()

    total = valid_count + invalid_count
    print(f"Results: {valid_count} valid, {invalid_count} invalid (of {total} total)")

    return 0 if invalid_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
