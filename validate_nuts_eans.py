#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Validate Nuts, Seeds & Legumes EANs and generate SQL migration.
"""

import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


def validate_ean13(ean):
    """Validate EAN-13 checksum using GS1 Modulo-10 algorithm."""
    if not ean or len(ean) != 13 or not ean.isdigit():
        return False, None, None
    
    digits = [int(d) for d in ean[:12]]
    checksum_calc = sum(d * (3 if i % 2 == 1 else 1) for i, d in enumerate(digits))
    expected = (10 - (checksum_calc % 10)) % 10
    actual = int(ean[12])
    
    return expected == actual, expected, actual


# EAN codes from nuts_eans_research.json
nuts_eans = [
    ("Alesto", "Alesto Migdały", "4335619141612"),
    ("Alesto", "Alesto Orzechy Laskowe", "4335619141544"),
    ("Bakalland", "Bakalland Migdały", "5900749020091"),
    ("Bakalland", "Bakalland Orzechy Laskowe", "5900749020022"),
    ("Naturavena", "Naturavena Ciecierzyca", "5908445474514"),
    ("Naturavena", "Naturavena Fasola Czerwona", "5906750251233"),
    ("Sante", "Sante Nasiona Chia", "5900617016492"),
    ("Sante", "Sante Siemię Lniane", "5900617013613"),
]


print("Validating Nuts, Seeds & Legumes EANs using GS1 Modulo-10 algorithm...")
print("=" * 80)

valid_count = 0
invalid_count = 0
invalid_eans = []

for brand, product_name, ean in nuts_eans:
    is_valid, expected, actual = validate_ean13(ean)
    
    if is_valid:
        print(f"[VALID  ] {brand:15s} {product_name:60s} {ean}")
        valid_count += 1
    else:
        print(f"[INVALID] {brand:15s} {product_name:60s} {ean} (expected: {expected}, got: {actual})")
        invalid_count += 1
        invalid_eans.append((brand, product_name, ean))

print("=" * 80)
print(f"\nValidation Results:")
print(f"  Valid:   {valid_count}/{len(nuts_eans)}")
print(f"  Invalid: {invalid_count}/{len(nuts_eans)}")

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
        "-- Migration: Add verified EANs to Nuts, Seeds & Legumes category",
        "-- Date: 2026-02-08",
        f"-- Products: {valid_count} verified EANs ({valid_count*100//27}% coverage = {valid_count}/27)",
        "--",
        "-- Validation: All EANs verified with GS1 Modulo-10 checksum",
        "-- Note: Limited API coverage for Polish specialty legumes/seeds brands",
        "-- Success rate by brand:",
        "--   Alesto:       2/6  (33%)",
        "--   Bakalland:    2/3  (67%)",
        "--   Fasting:      0/2  (0%)",
        "--   Helio:        0/3  (0%)",
        "--   Naturavena:   2/5  (40%)",
        "--   Sante:        2/4  (50%)",
        "--   Społem:       0/2  (0%)",
        "--   Targroch:     0/2  (0%)",
        "",
        f"\\echo 'Adding {valid_count} verified EANs to Nuts, Seeds & Legumes category...'",
        "",
    ]
    
    for brand, product_name, ean in nuts_eans:
        safe_name = product_name.replace("'", "''")
        sql_lines.append(
            f"UPDATE products SET ean = '{ean}' "
            f"WHERE brand = '{brand}' AND product_name = '{safe_name}' AND category = 'Nuts, Seeds & Legumes';"
        )
    
    sql_lines.append("")
    sql_lines.append(f"\\echo 'Migration complete: {valid_count} EANs added to Nuts, Seeds & Legumes category'")
    
    sql_content = "\n".join(sql_lines)
    
    migration_file = "db/migrations/20260208_add_nuts_eans.sql"
    with open(migration_file, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"Migration saved to: {migration_file}")
