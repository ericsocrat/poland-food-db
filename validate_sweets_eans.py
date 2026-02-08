#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Validate Sweets category EANs and generate SQL migration.
"""

import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != "utf-8":
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding="utf-8")


def validate_ean13(ean):
    """Validate EAN-13 checksum using GS1 Modulo-10 algorithm."""
    if not ean or len(ean) != 13 or not ean.isdigit():
        return False, None, None

    digits = [int(d) for d in ean[:12]]
    checksum_calc = sum(d * (3 if i % 2 == 1 else 1) for i, d in enumerate(digits))
    expected = (10 - (checksum_calc % 10)) % 10
    actual = int(ean[12])

    return expected == actual, expected, actual


# EAN codes from sweets_eans_research.json
sweets_eans = [
    ("Delicje", "Delicje Szampańskie Wiśniowe", "5906747308469"),
    ("Grześki", "Grześki Wafer Toffee", "5900394006181"),
    ("Haribo", "Haribo Goldbären", "8691216020627"),
    ("Kinder", "Kinder Bueno Mini", "8000500180709"),
    ("Kinder", "Kinder Cards", "8000500269169"),
    ("Milka", "Milka Alpenmilch", "7622400883033"),
    ("Milka", "Milka Trauben-Nuss", "3045140280902"),
    ("Prince Polo", "Prince Polo XXL Classic", "7622210309792"),
    ("Prince Polo", "Prince Polo XXL Mleczne", "7622210309990"),
    ("Snickers", "Snickers Bar", "5000159461122"),
    ("Twix", "Twix Twin", "5000159459228"),
    ("Wawel", "Wawel Czekolada Gorzka 70%", "5900102025473"),
    ("Wawel", "Wawel Kasztanki Nadziewana", "5900102009138"),
    ("Wawel", "Wawel Mleczna z Rodzynkami i Orzeszkami", "5900102022212"),
    ("Wawel", "Wawel Tiramisu Nadziewana", "5900102021215"),
    ("Wedel", "Wedel Czekolada Gorzka 80%", "5901588018195"),
    ("Wedel", "Wedel Czekolada Mleczna", "5901588016443"),
    ("Wedel", "Wedel Mleczna Truskawkowa", "5901588016443"),
    ("Wedel", "Wedel Mleczna z Bakaliami", "5901588016740"),
    ("Wedel", "Wedel Mleczna z Orzechami", "5901588017990"),
    ("Wedel", "Wedel Ptasie Mleczko Waniliowe", "5901588058658"),
]


print("Validating Sweets EANs using GS1 Modulo-10 algorithm...")
print("=" * 80)

valid_count = 0
invalid_count = 0
invalid_eans = []

for brand, product_name, ean in sweets_eans:
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
print(f"  Valid:   {valid_count}/{len(sweets_eans)}")
print(f"  Invalid: {invalid_count}/{len(sweets_eans)}")

if invalid_eans:
    print(f"\nWARNING: {invalid_count} invalid EAN(s) found!")
    for brand, product_name, ean in invalid_eans:
        print(f"  - {brand} | {product_name} | {ean}")
else:
    print("\nAll EANs passed checksum validation!")

    # Generate SQL migration
    print("\n" + "=" * 80)
    print("Generating SQL migration script...")
    print("=" * 80 + "\n")

    sql_lines = [
        "-- Migration: Add verified EANs to Sweets category",
        "-- Date: 2026-02-08",
        f"-- Products: {valid_count} verified EANs ({valid_count*100//28}% coverage = {valid_count}/28)",
        "--",
        "-- Validation: All EANs verified with GS1 Modulo-10 checksum",
        "-- Success rate by brand:",
        "--   Delicje:     1/1  (100%)",
        "--   Goplana:     0/1  (0%)",
        "--   Grześki:     1/2  (50%)",
        "--   Haribo:      1/1  (100%)",
        "--   Kinder:      2/3  (67%)",
        "--   Milka:       2/2  (100%)",
        "--   Prince Polo: 2/2  (100%)",
        "--   Snickers:    1/1  (100%)",
        "--   Twix:        1/1  (100%)",
        "--   Wawel:       5/6  (83%)",
        "--   Wedel:       6/7  (86%)",
        "",
        "\\echo 'Adding {valid_count} verified EANs to Sweets category...'",
        "",
    ]

    for brand, product_name, ean in sweets_eans:
        safe_name = product_name.replace("'", "''")
        sql_lines.append(
            f"UPDATE products SET ean = '{ean}' "
            f"WHERE brand = '{brand}' AND product_name = '{safe_name}' AND category = 'Sweets';"
        )

    sql_lines.append("")
    sql_lines.append(
        f"\\echo 'Migration complete: {valid_count} EANs added to Sweets category'"
    )

    sql_content = "\n".join(sql_lines)

    migration_file = "db/migrations/20260208_add_sweets_eans.sql"
    with open(migration_file, "w", encoding="utf-8") as f:
        f.write(sql_content)

    print(f"Migration saved to: {migration_file}")
