#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Validate Bread category EANs using GS1 Modulo-10 checksum algorithm
and generate SQL migration script.

EAN-13 validation per ISO/IEC 15420 standard.
"""


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


# EAN codes from bread_eans_research.json
bread_eans = [
    # Carrefour (1/2 found)
    ("Carrefour", "Carrefour Pieczywo Chrupkie Kukurydziane", "5905784303253"),
    # Klara (1/1 found)
    ("Klara", "Klara American Sandwich Toast XXL", "3856016906945"),
    # Mestemacher (5/5 found)
    ("Mestemacher", "Mestemacher Chleb Razowy", "5900585000110"),
    ("Mestemacher", "Mestemacher Chleb Wielozbożowy Żytni", "5900585000028"),
    ("Mestemacher", "Mestemacher Chleb Ziarnisty", "5900585001810"),
    ("Mestemacher", "Mestemacher Chleb Żytni", "5900585000158"),
    ("Mestemacher", "Mestemacher Pumpernikiel", "5900585000059"),
    # Oskroba (5/9 found - removed invalid Chleb Graham)
    ("Oskroba", "Oskroba Chleb Baltonowski", "5900340007231"),
    # ("Oskroba", "Oskroba Chleb Graham", "2434000070009"),  # INVALID: checksum failed
    ("Oskroba", "Oskroba Chleb Litewski", "5900340000423"),
    ("Oskroba", "Oskroba Chleb Pszenno-Żytni", "5900340000935"),
    ("Oskroba", "Oskroba Chleb Żytni Pełnoziarnisty", "5900340015342"),
    ("Oskroba", "Oskroba Chleb Żytni Razowy", "5900340003615"),
    # Pano (4/4 found)
    ("Pano", "Pano Bułeczki Śniadaniowe", "5900864727806"),
    ("Pano", "Pano Tortilla", "5900928032358"),
    ("Pano", "Pano Tost Maślany", "5900340003912"),
    ("Pano", "Pano Tost Pełnoziarnisty", "5900340012815"),
    # Tastino (1/2 found)
    ("Tastino", "Tastino Tortilla Wraps", "4056489918202"),
    # Wasa (3/3 found)
    ("Wasa", "Wasa Lekkie 7 Ziaren", "7300400115889"),
    ("Wasa", "Wasa Original", "7300400118101"),
    ("Wasa", "Wasa Pieczywo z Błonnikiem", "7300400481441"),
]


print("Validating Bread EANs using GS1 Modulo-10 algorithm...")
print("=" * 80)

valid_count = 0
invalid_count = 0
invalid_eans = []

for brand, product_name, ean in bread_eans:
    is_valid, expected, actual = validate_ean13(ean)

    if is_valid:
        print(f"✓ {brand:20s} {product_name:50s} {ean}")
        valid_count += 1
    else:
        print(
            f"✗ {brand:20s} {product_name:50s} {ean} (expected: {expected}, got: {actual})"
        )
        invalid_count += 1
        invalid_eans.append((brand, product_name, ean))

print("=" * 80)
print(f"\nValidation Results:")
print(f"  Valid:   {valid_count}/{len(bread_eans)}")
print(f"  Invalid: {invalid_count}/{len(bread_eans)}")

if invalid_eans:
    print(f"\n⚠️  WARNING: {invalid_count} invalid EAN(s) found!")
    for brand, product_name, ean in invalid_eans:
        print(f"  - {brand} | {product_name} | {ean}")
    print("\nPlease verify these EANs before proceeding with migration.")
else:
    print("\n✓ All EANs passed checksum validation!")

    # Generate SQL migration
    print("\n" + "=" * 80)
    print("Generating SQL migration script...")
    print("=" * 80 + "\n")

    sql_lines = [
        "-- Migration: Add verified EANs to Bread category",
        "-- Date: 2026-02-08",
        "-- Products: 20 verified EANs (71.4% coverage = 20/28)",
        "--",
        "-- Validation: All EANs verified with GS1 Modulo-10 checksum",
        "-- Note: 1 invalid EAN removed (Oskroba Chleb Graham - checksum failed)",
        "-- Success rate by brand:",
        "--   Carrefour:   1/2  (50%)",
        "--   Klara:       1/1  (100%)",
        "--   Mestemacher: 5/5  (100%)",
        "--   Oskroba:     5/9  (56%)",
        "--   Pano:        4/4  (100%)",
        "--   Tastino:     1/2  (50%)",
        "--   Wasa:        3/3  (100%)",
        "",
        "\\echo 'Adding 20 verified EANs to Bread category...'",
        "",
    ]

    for brand, product_name, ean in bread_eans:
        # Escape single quotes in product names
        safe_name = product_name.replace("'", "''")
        sql_lines.append(
            f"UPDATE products SET ean = '{ean}' "
            f"WHERE brand = '{brand}' AND product_name = '{safe_name}' AND category = 'Bread';"
        )

    sql_lines.append("")
    sql_lines.append("\\echo 'Migration complete: 20 EANs added to Bread category'")

    sql_content = "\n".join(sql_lines)

    # Save to migration file
    migration_file = "db/migrations/20260208_add_bread_eans.sql"
    with open(migration_file, "w", encoding="utf-8") as f:
        f.write(sql_content)

    print(f"✓ Migration saved to: {migration_file}")
    print(
        f"✓ Ready to apply with: docker exec supabase_db_poland-food-db psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/migrations/20260208_add_bread_eans.sql"
    )
