#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Nuts, Seeds & Legumes category (27 products) via Open Food Facts API.
Brands: Alesto, Bakalland, Fasting, Helio, Naturavena, Sante, Społem, Targroch.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != 'utf-8':
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


# List of 27 nuts/seeds/legumes products from database
nuts_products = [
    ("Alesto", "Alesto Migdały"),
    ("Alesto", "Alesto Migdały Prażone Solone"),
    ("Alesto", "Alesto Orzechy Laskowe"),
    ("Alesto", "Alesto Orzechy Nerkowca"),
    ("Alesto", "Alesto Orzechy Nerkowca Prażone Solone"),
    ("Alesto", "Alesto Orzechy Włoskie"),
    ("Bakalland", "Bakalland Migdały"),
    ("Bakalland", "Bakalland Orzechy Laskowe"),
    ("Bakalland", "Bakalland Orzechy Włoskie"),
    ("Fasting", "Fasting Migdały Prażone"),
    ("Fasting", "Fasting Orzeszki Ziemne Solone"),
    ("Helio", "Helio Masło Migdałowe"),
    ("Helio", "Helio Masło Orzechowe Kremowe"),
    ("Helio", "Helio Masło Orzechowe Naturalne"),
    ("Naturavena", "Naturavena Ciecierzyca"),
    ("Naturavena", "Naturavena Fasola Biała"),
    ("Naturavena", "Naturavena Fasola Czerwona"),
    ("Naturavena", "Naturavena Soczewica Czerwona"),
    ("Naturavena", "Naturavena Soczewica Zielona"),
    ("Sante", "Sante Nasiona Chia"),
    ("Sante", "Sante Nasiona Słonecznika"),
    ("Sante", "Sante Pestki Dyni"),
    ("Sante", "Sante Siemię Lniane"),
    ("Społem", "Społem Fasola Jaś"),
    ("Społem", "Społem Soczewica Brązowa"),
    ("Targroch", "Targroch Nasiona Słonecznika Prażone"),
    ("Targroch", "Targroch Pestki Dyni Prażone Solone"),
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


print("Searching for Nuts, Seeds & Legumes products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in nuts_products:
    ean = search_open_food_facts(brand, product_name)
    time.sleep(0.5)  # Rate limit: 0.5s between requests
    
    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_name:60s} {ean_display}")
    
    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(nuts_products) - found_count} not found\n")

# Save results
with open("nuts_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to nuts_eans_research.json")
