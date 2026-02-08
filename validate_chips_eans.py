#!/usr/bin/env python3
"""Validate found Chips EANs and generate SQL updates."""

import json
from validate_eans import validate_ean13

# Load results from JSON  
with open("chips_eans_research.json", "r", encoding="utf-8") as f:
    results = json.load(f)

valid_eans = []
invalid_eans = []

print(f"Validating {len(results)} EANs...")
print(f"{'Product':<40} {'EAN':<15} {'Status'}")
print("=" * 65)

for item in results:
    ean = item["ean"]
    product_name = item["product_name"]
    
    is_valid = validate_ean13(ean)
    
    if is_valid:
        print(f"{product_name:<40} {ean:<15} ✓ VALID")
        valid_eans.append(item)
    else:
        # Try as EAN-8
        if len(ean) == 8:
            print(f"{product_name:<40} {ean:<15} ⚠ EAN-8 (not EAN-13)")
            invalid_eans.append(item)
        else:
            print(f"{product_name:<40} {ean:<15} ✗ INVALID")
            invalid_eans.append(item)

print("=" * 65)
print(f"Results: {len(valid_eans)} valid EAN-13, {len(invalid_eans)} invalid/non-standard")

if valid_eans:
    print("\n✓ SQL UPDATEs for valid EAN-13s:\n")
    for item in valid_eans:
        product_name_sql = item["product_name"].replace("'", "''")
        brand_sql = item["brand"].replace("'", "''")
        print(f"UPDATE products SET ean = '{item['ean']}' WHERE brand = '{brand_sql}' AND product_name = '{product_name_sql}' AND category = 'Chips';")

if invalid_eans:
    print(f"\n⚠ Products NOT added (invalid/non-standard EAN format):\n")
    for item in invalid_eans:
        print(f"  - {item['brand']} {item['product_name']}: {item['ean']} ({len(item['ean'])} digits)")

print(f"\n\nSummary:")
print(f"  Valid EAN-13 found: {len(valid_eans)}")
print(f"  Invalid/Non-standard: {len(invalid_eans)}")
print(f"  Total missing (8 not found by API): 8")
print(f"  Final expected Chips with EANs: {21 + len(valid_eans)}/45")
