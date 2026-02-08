#!/usr/bin/env python3
"""Validate found Dairy EANs and generate SQL updates."""

import json
from validate_eans import validate_ean13

# Load results from JSON
with open("dairy_eans_research.json", "r", encoding="utf-8") as f:
    results = json.load(f)

valid_eans = []
invalid_eans = []

print(f"Validating {len(results)} Dairy EANs...\n")

for item in results:
    ean = item["ean"]
    product_name = item["product_name"]

    is_valid = validate_ean13(ean)

    if is_valid:
        print(f"{product_name:<40} {ean:<15} OK")
        valid_eans.append(item)
    else:
        if len(ean) == 8:
            print(f"{product_name:<40} {ean:<15} WARN (EAN-8)")
        else:
            print(f"{product_name:<40} {ean:<15} FAIL")
        invalid_eans.append(item)

print("=" * 60)
print(f"Results: {len(valid_eans)} valid, {len(invalid_eans)} invalid\n")

if valid_eans:
    print("SQL UPDATEs for valid EANs:\n")
    for item in valid_eans:
        product_name_sql = item["product_name"].replace("'", "''")
        brand_sql = item["brand"].replace("'", "''")
        print(
            f"UPDATE products SET ean = '{item['ean']}' WHERE brand = '{brand_sql}' AND product_name = '{product_name_sql}' AND category = 'Dairy';"
        )

print(f"\n\nSummary:")
print(f"  Valid EANs: {len(valid_eans)}")
print(f"  Not found via API: 5")
print(
    f"  Expected Dairy with EANs: {len(valid_eans)}/28 ({100.0 * len(valid_eans) / 28:.1f}%)"
)
