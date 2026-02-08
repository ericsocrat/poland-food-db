#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Query database for canned goods and generate product list for research script."""

import subprocess
import json

# Query database
result = subprocess.run(
    [
        "docker", "exec", "supabase_db_poland-food-db", "psql", 
        "-U", "postgres", "-d", "postgres", 
        "-c", "SELECT brand, product_name FROM products WHERE category='Canned Goods' ORDER BY brand, product_name;"
    ],
    capture_output=True,
    text=True
)

if result.returncode != 0:
    print(f"Error: {result.stderr}")
    exit(1)

# Parse output
products = []
for line in result.stdout.split('\n'):
    parts = [p.strip() for p in line.split('|') if p.strip()]
    if len(parts) == 2 and not any(x in parts[0] for x in ['brand', '---', '(', ')']):
        brand, product_name = parts
        products.append((brand, product_name))

# Save for inspection
with open('canned_products_actual.json', 'w', encoding='utf-8') as f:
    json.dump(products, f, ensure_ascii=False, indent=2)

print(f"Found {len(products)} products:")
for i, (brand, name) in enumerate(products, 1):
    print(f"{i:2d}. {brand:20s} {name}")
