#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Canned Goods with multiple search strategies.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Simplified product list with shorter names for better API matching
canned_products = [
    ("Bonduelle", "Mushrooms"),
    ("Bonduelle", "Chickpeas"),
    ("Bonduelle", "Beans"),
    ("Bonduelle", "Corn"),
    ("Heinz", "Tomato Soup"),
    ("Heinz", "Ravioli"),
    ("Heinz", "Spaghetti"),
    ("Kotlin", "Beans"),
    ("Kotlin", "Peas"),
    ("Kotlin", "Corn"),
    ("Kotlin", "Carrots"),
    ("Kotlin", "Lentils"),
    ("Kotlin", "Tomatoes"),
    ("Kotlin", "Mushrooms"),
    ("Kotlin", "Cherries"),
    ("Kotlin", "Mandarin"),
    ("Kotlin", "Kidney Beans"),
    ("Kotlin", "White Beans"),
    ("Profi", "Soup"),
    ("Profi", "Fruit Cocktail"),
    ("Profi", "Peaches"),
    ("Profi", "Pears"),
    ("Profi", "Pineapple"),
    ("Profi", "Meat"),
    ("Pudliszki", "Beef"),
    ("Pudliszki", "Soup"),
    ("Pudliszki", "Tomatoes"),
    ("Pudliszki", "Beets"),
]


def search_open_food_facts(brand, product_type):
    """Search Open Food Facts API with fallback strategies."""
    queries = [
        f"{brand} {product_type}",
        product_type,
    ]
    
    for query in queries:
        url = "https://world.openfoodfacts.org/cgi/search.pl"
        params = {
            "search_terms": query,
            "search_simple": 1,
            "action": "process",
            "fields": "code,name,brands",
            "json": 1,
            "page_size": 5
        }
        
        try:
            response = requests.get(url, params=params, timeout=5)
            response.raise_for_status()
            data = response.json()
            
            if data.get("products"):
                # Check first product that matches brand
                for product in data["products"]:
                    ean = product.get("code", "").strip()
                    if ean and len(ean) == 13 and ean.isdigit():
                        api_brand = product.get("brands", "").lower()
                        if brand.lower() in api_brand:
                            return ean
                        # If no brand match, still try first result
                        if not any(api_brand):
                            return ean
            return None
        except:
            pass
        
        time.sleep(0.1)
    
    return None


print("Searching for Canned Goods products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_type in canned_products:
    ean = search_open_food_facts(brand, product_type)
    time.sleep(0.1)
    
    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_type:35s} {ean_display}")
    
    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_type, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(canned_products) - found_count} not found\n")

# Save results
with open("canned_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to canned_eans_research.json")
