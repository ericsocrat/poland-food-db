#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Snacks category (28 products) via Open Food Facts API.
Brands: Alesto, Bakalland, Crownfield, Crunchips, Frito, Grześkowiak, Kupiec, Lay's, Naturavena, Pringles, Sante, Snack Day, Stop & Shop, Vitanella.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


# List of Snacks products from database
snacks_products = [
    ("Alesto", "Alesto Grissini Sticks"),
    ("Alesto", "Alesto Mixed Nuts"),
    ("Bakalland", "Bakalland Breadsticks"),
    ("Bakalland", "Bakalland Dried Cranberries"),
    ("Crownfield", "Crownfield Fruit Granola Bar"),
    ("Crownfield", "Crownfield Plain Rice Cakes"),
    ("Crunchips", "Crunchips Multigrain Crackers"),
    ("Crunchips", "Crunchips Pretzel Rods"),
    ("Crunchips", "Crunchips Spicy Cheese Puffs"),
    ("Frito", "Frito Salted Pretzels"),
    ("Grześkowiak", "Grześkowiak Carrot Chips"),
    ("Grześkowiak", "Grześkowiak Salted Crackers"),
    ("Kupiec", "Kupiec Beet Chips"),
    ("Kupiec", "Kupiec Cheese-flavored Crackers"),
    ("Lay's", "Lay's Classic Cheese Puffs"),
    ("Lay's", "Lay's Classic Wheat Crackers"),
    ("Lay's", "Lay's Salted Popcorn"),
    ("Naturavena", "Naturavena Chocolate Granola Bar"),
    ("Naturavena", "Naturavena Rice Cakes with Herbs"),
    ("Pringles", "Pringles Butter Popcorn"),
    ("Pringles", "Pringles Original Rye Crackers"),
    ("Sante", "Sante Caramel Popcorn"),
    ("Sante", "Sante Honey-Nut Granola Bar"),
    ("Snack Day", "Snack Day Pumpkin Seeds"),
    ("Snack Day", "Snack Day Sesame Crackers"),
    ("Stop & Shop", "Stop & Shop Reduced Sugar Granola Bar"),
    ("Stop & Shop", "Stop & Shop Sesame Rice Cakes"),
    ("Vitanella", "Vitanella Raisins"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts API for product and return EAN if found."""
    query = f"{brand} {product_name}"
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
            product = data["products"][0]
            ean = product.get("code", "").strip()
            if ean and len(ean) == 13 and ean.isdigit():
                return ean
        return None
    except Exception:
        return None


print("Searching for Snacks products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in snacks_products:
    ean = search_open_food_facts(brand, product_name)
    time.sleep(0.2)  # Rate limit
    
    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:20s} {product_name:40s} {ean_display}")
    
    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(snacks_products) - found_count} not found\n")

# Save results
with open("snacks_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to snacks_eans_research.json")
