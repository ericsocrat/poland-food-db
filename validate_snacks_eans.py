#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Validate Snacks EANs using GS1 Modulo-10 checksum."""

import json
import sys
from io import TextIOWrapper

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
with open('snacks_eans_research.json', 'r', encoding='utf-8') as f:
    research_data = json.load(f)

print("Validating Snacks EANs...")
print("=" * 80)

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
        valid_results.append(item)
    else:
        invalid_count += 1

print("=" * 80)
print(f"Validation Results: Valid {len(valid_results)}/{len(research_data)}, Invalid {invalid_count}/{len(research_data)}\n")

if valid_results:
    # Generate migration SQL
    migration_sql = []
    for item in valid_results:
        brand = item['brand'].replace("'", "''")
        product_name = item['product_name'].replace("'", "''")
        ean = item['ean']
        sql_line = f"UPDATE products SET ean = '{ean}' WHERE brand = '{brand}' AND product_name = '{product_name}' AND category = 'Snacks';"
        migration_sql.append(sql_line)
    
    # Save migration file
    with open('db/migrations/20260208_add_snacks_eans.sql', 'w', encoding='utf-8') as f:
        f.write('\n'.join(migration_sql))
    
    print(f"✓ All EANs passed checksum validation!")
    print(f"Migration saved to: db/migrations/20260208_add_snacks_eans.sql\n")
else:
    print("✗ No valid EANs found!")
