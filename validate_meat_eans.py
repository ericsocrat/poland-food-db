#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Validate Meat category EANs using GS1 Modulo-10 checksum algorithm
and generate SQL migration script.

EAN-13 validation per ISO/IEC 15420 standard.
"""

import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != "utf-8":
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding="utf-8")


def validate_ean13(ean):
    """
    Validate EAN-13 checksum using GS1 Modulo-10 algorithm.

    Args:
        ean: 13-digit EAN code as string

    Returns:
        tuple: (is_valid: bool, expected_checksum: int, actual_checksum: int)
    """
    if not ean or len(ean) != 13 or not ean.isdigit():
        return False, None, None

    # GS1 Modulo-10: multiply odd positions by 1, even by 3
    digits = [int(d) for d in ean[:12]]
    checksum_calc = sum(d * (3 if i % 2 == 1 else 1) for i, d in enumerate(digits))
    expected = (10 - (checksum_calc % 10)) % 10
    actual = int(ean[12])

    return expected == actual, expected, actual


# EAN codes from meat_eans_research.json
meat_eans = [
    ("Drosed", "Drosed Pasztet Podlaski", "5901204000733"),
    ("Krakus", "Krakus Szynka Konserwowa", "0226201603202"),
    ("Morliny", "Morliny Boczek Wędzony", "5902659896735"),
    ("Tarczyński", "Tarczyński Kabanosy Exclusive", "5908230522208"),
    ("Tarczyński", "Tarczyński Kabanosy Klasyczne", "5908230529429"),
]


print("Validating Meat EANs using GS1 Modulo-10 algorithm...")
print("=" * 80)

valid_count = 0
invalid_count = 0
invalid_eans = []

for brand, product_name, ean in meat_eans:
    is_valid, expected, actual = validate_ean13(ean)

    if is_valid:
        print(f"[VALID  ] {brand:15s} {product_name:60s} {ean}")
        valid_count += 1
    else:
        print(
            f"[INVALID] {brand:15s} {product_name:60s} {ean} (expected: {expected}, got: {actual})"
        )
        invalid_count += 1
        invalid_eans.append((brand, product_name, ean))

print("=" * 80)
print(f"\nValidation Results:")
print(f"  Valid:   {valid_count}/{len(meat_eans)}")
print(f"  Invalid: {invalid_count}/{len(meat_eans)}")

if invalid_eans:
    print(f"\nWARNING: {invalid_count} invalid EAN(s) found!")
    for brand, product_name, ean in invalid_eans:
        print(f"  - {brand} | {product_name} | {ean}")
    print("\nPlease verify these EANs before proceeding with migration.")
else:
    print("\nAll EANs passed checksum validation!")

    # Generate SQL migration
    print("\n" + "=" * 80)
    print("Generating SQL migration script...")
    print("=" * 80 + "\n")

    sql_lines = [
        "-- Migration: Add verified EANs to Meat category",
        "-- Date: 2026-02-08",
        "-- Products: 5 verified EANs (17.9% coverage = 5/28)",
        "--",
        "-- Validation: All EANs verified with GS1 Modulo-10 checksum",
        "-- Note: Low success rate due to limited API coverage for Polish specialty meat brands",
        "-- Success rate by brand:",
        "--   Drosed:      1/1  (100%)",
        "--   Krakus:      1/4  (25%)",
        "--   Morliny:     1/5  (20%)",
        "--   Tarczyński:  2/5  (40%)",
        "",
        "\\echo 'Adding 5 verified EANs to Meat category...'",
        "",
    ]

    for brand, product_name, ean in meat_eans:
        # Escape single quotes in product names
        safe_name = product_name.replace("'", "''")
        sql_lines.append(
            f"UPDATE products SET ean = '{ean}' "
            f"WHERE brand = '{brand}' AND product_name = '{safe_name}' AND category = 'Meat';"
        )

    sql_lines.append("")
    sql_lines.append("\\echo 'Migration complete: 5 EANs added to Meat category'")

    sql_content = "\n".join(sql_lines)

    # Save to migration file
    migration_file = "db/migrations/20260208_add_meat_eans.sql"
    with open(migration_file, "w", encoding="utf-8") as f:
        f.write(sql_content)

    print(f"Migration saved to: {migration_file}")
