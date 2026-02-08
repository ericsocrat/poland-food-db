#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Validate Canned Goods EANs using GS1 Modulo-10 checksum and detect duplicates."""

import json
import sys
from io import TextIOWrapper
from collections import defaultdict

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


def validate_ean13(ean):
    """Validate EAN-13 using GS1 Modulo-10 checksum."""
    if not ean or len(ean) != 13 or not ean.isdigit():
        return False
    
    # Calculate checksum from first 12 digits
    digits = [int(d) for d in ean[:12]]
    total = sum(d * (3 if i % 2 == 1 else 1) for i, d in enumerate(digits))
    expected_checksum = (10 - (total % 10)) % 10
    actual_checksum = int(ean[12])
    
    return expected_checksum == actual_checksum


# Load research results
with open('canned_eans_research.json', 'r', encoding='utf-8') as f:
    research_data = json.load(f)

print("Validating Canned Goods EANs...")
print("=" * 80)

# Track EANs to detect duplicates
ean_products = defaultdict(list)
valid_results = []
invalid_count = 0

for item in research_data:
    brand = item['brand']
    product_name = item['product_name']
    ean = item['ean']
    
    is_valid = validate_ean13(ean)
    status = "VALID" if is_valid else "INVALID"
    print(f"[{status:7s}] {brand:20s} {product_name:40s} {ean}")
    
    if is_valid:
        ean_products[ean].append((brand, product_name))
        valid_results.append(item)
    else:
        invalid_count += 1

print("=" * 80)
print(f"Validation Results: Valid {len(valid_results)}/{len(research_data)}, Invalid {invalid_count}/{len(research_data)}\n")

# Check for duplicates
print("Duplicate EAN Detection:")
print("-" * 80)
duplicates_found = False
for ean, products in ean_products.items():
    if len(products) > 1:
        duplicates_found = True
        print(f"EAN {ean} assigned to {len(products)} products:")
        for brand, product in products:
            print(f"  • {brand:20s} {product}")

if not duplicates_found:
    print("No duplicate EANs found ✓\n")

# Filter out duplicates - keep only first occurrence per EAN
unique_eans_set = set()
final_results = []
for item in valid_results:
    ean = item['ean']
    if ean not in unique_eans_set:
        unique_eans_set.add(ean)
        final_results.append(item)

print(f"\nAfter duplicate removal: {len(final_results)} unique EANs to apply\n")

if final_results:
    # Generate migration SQL
    migration_sql = []
    for item in final_results:
        brand = item['brand'].replace("'", "''")
        product_name = item['product_name'].replace("'", "''")
        ean = item['ean']
        sql_line = f"UPDATE products SET ean = '{ean}' WHERE brand = '{brand}' AND product_name = '{product_name}' AND category = 'Canned Goods';"
        migration_sql.append(sql_line)
    
    # Save migration file
    with open('db/migrations/20260208_add_canned_goods_eans.sql', 'w', encoding='utf-8') as f:
        f.write('\n'.join(migration_sql))
    
    print(f"✓ {len(final_results)} unique, valid EANs ready for database")
    print(f"Migration saved to: db/migrations/20260208_add_canned_goods_eans.sql\n")
else:
    print("✗ No valid EANs after filtering!")
