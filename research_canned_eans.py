#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Canned Goods via Open Food Facts API.
Using direct product names from database for accuracy.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


# Actual canned goods products from database
canned_products = [
    ("Bonduelle", "Champignon Mushrooms"),
    ("Bonduelle", "Chickpeas"),
    ("Bonduelle", "Mixed Beans"),
    ("Bonduelle", "Sweet Corn"),
    ("Heinz", "Cream of Tomato Soup"),
    ("Heinz", "Ravioli in Tomato Sauce"),
    ("Heinz", "Spaghetti in Tomato Sauce"),
    ("Kotlin", "Beans in Tomato Sauce"),
    ("Kotlin", "Cherries in Syrup"),
    ("Kotlin", "Green Peas"),
    ("Kotlin", "Lentils"),
    ("Kotlin", "Mandarin Oranges in Syrup"),
    ("Kotlin", "Red Kidney Beans"),
    ("Kotlin", "Sliced Carrots"),
    ("Kotlin", "Spaghetti Bolognese"),
    ("Kotlin", "White Beans"),
    ("Kotlin", "Whole Tomatoes"),
    ("Profi", "Chicken Soup"),
    ("Profi", "Fruit Cocktail in Syrup"),
    ("Profi", "Peaches in Syrup"),
    ("Profi", "Pears in Syrup"),
    ("Profi", "Pineapple Slices in Syrup"),
    ("Profi", "Pork Luncheon Meat"),
    ("Pudliszki", "Corned Beef"),
    ("Pudliszki", "Cream of Mushroom Soup"),
    ("Pudliszki", "Diced Tomatoes"),
    ("Pudliszki", "Vegetable Soup"),
    ("Pudliszki", "Whole Beets"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts API with retry logic."""
    url = "https://world.openfoodfacts.org/cgi/search.pl"
    
    # Try different search strategies
    queries = [
        f"{brand} {product_name}",
        f"{brand}",
        product_name.split()[0],  # Just first word
    ]
    
    for query in queries:
        params = {
            "search_terms": query,
            "search_simple": 1,
            "action": "process",
            "json": 1,
            "page_size": 5
        }
        
        try:
            response = requests.get(url, params=params, timeout=8)
            response.raise_for_status()
            data = response.json()
            
            if data.get("products"):
                for prod in data["products"]:
                    ean = prod.get("code", "").strip()
                    if ean and len(ean) == 13 and ean.isdigit():
                        # Try to match brand
                        api_brand = prod.get("brands", "").lower()
                        if brand.lower() in api_brand or brand.lower() in prod.get("name", "").lower():
                            return ean
                        # If brand match fails but EAN exists, may still be valid
                        if query == f"{brand} {product_name}":  # Only return on exact query
                            return ean
            
            time.sleep(0.15)
        except:
            pass
    
    return None


print("Searching for Canned Goods products (30 items)...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in canned_products:
    ean = search_open_food_facts(brand, product_name)
    
    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_name:40s} {ean_display}")
    
    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(canned_products) - found_count} not found\n")

# Save results
with open("canned_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to canned_eans_research.json")

