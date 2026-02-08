#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Sweets category (28 products) via Open Food Facts API.
Major brands: Haribo, Kinder, Snickers, Twix, Milka, Wawel, Wedel, Prince Polo.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


# List of 28 sweets products from database
sweets_products = [
    ("Delicje", "Delicje Szampańskie Wiśniowe"),
    ("Goplana", "Goplana Jeżyki Cherry"),
    ("Grześki", "Grześki Mini Chocolate"),
    ("Grześki", "Grześki Wafer Toffee"),
    ("Haribo", "Haribo Goldbären"),
    ("Kinder", "Kinder Bueno Mini"),
    ("Kinder", "Kinder Cards"),
    ("Kinder", "Kinder Chocolate Bar"),
    ("Milka", "Milka Alpenmilch"),
    ("Milka", "Milka Trauben-Nuss"),
    ("Prince Polo", "Prince Polo XXL Classic"),
    ("Prince Polo", "Prince Polo XXL Mleczne"),
    ("Snickers", "Snickers Bar"),
    ("Solidarność", "Solidarność Śliwki w Czekoladzie"),
    ("Twix", "Twix Twin"),
    ("Wawel", "Wawel Czekolada Gorzka 70%"),
    ("Wawel", "Wawel Czekolada Karmelowe"),
    ("Wawel", "Wawel Kasztanki Nadziewana"),
    ("Wawel", "Wawel Mleczna z Rodzynkami i Orzeszkami"),
    ("Wawel", "Wawel Tiki Taki Kokosowo-Orzechowe"),
    ("Wawel", "Wawel Tiramisu Nadziewana"),
    ("Wedel", "Wedel Czekolada Gorzka 80%"),
    ("Wedel", "Wedel Czekolada Mleczna"),
    ("Wedel", "Wedel Mleczna Truskawkowa"),
    ("Wedel", "Wedel Mleczna z Bakaliami"),
    ("Wedel", "Wedel Mleczna z Orzechami"),
    ("Wedel", "Wedel Ptasie Mleczko Gorzka 80%"),
    ("Wedel", "Wedel Ptasie Mleczko Waniliowe"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts API for product EAN."""
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
        response = requests.get(url, params=params, timeout=10)
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


print("Searching for Sweets products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in sweets_products:
    ean = search_open_food_facts(brand, product_name)
    time.sleep(0.5)  # Rate limit: 0.5s between requests
    
    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_name:60s} {ean_display}")
    
    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(sweets_products) - found_count} not found\n")

# Save results
with open("sweets_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to sweets_eans_research.json")
