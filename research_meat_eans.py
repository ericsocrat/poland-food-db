#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Meat category (28 products) via Open Food Facts API.
Polish meat brands: Berlinki, Krakus, Morliny, Sokołów, Tarczyński, etc.
"""

import requests
import json
import time
import sys
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != "utf-8":
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding="utf-8")


# List of 28 meat products from database
meat_products = [
    ("Berlinki", "Berlinki Parówki Klasyczne"),
    ("Berlinki", "Berlinki Parówki z Szynki"),
    ("Drosed", "Drosed Pasztet Podlaski"),
    ("Indykpol", "Indykpol Polędwica z Indyka"),
    ("Krakus", "Krakus Kiełbasa Zwyczajna"),
    ("Krakus", "Krakus Mielonka Tyrolska"),
    ("Krakus", "Krakus Parówki Delikatesowe"),
    ("Krakus", "Krakus Polędwica Sopocka"),
    ("Krakus", "Krakus Szynka Konserwowa"),
    ("Madej Wróbel", "Madej Wróbel Szynka Gotowana"),
    ("Morliny", "Morliny Boczek Drobiowy"),
    ("Morliny", "Morliny Boczek Wędzony"),
    ("Morliny", "Morliny Kiełbasa Podwawelska"),
    ("Morliny", "Morliny Parówki Polskie"),
    ("Morliny", "Morliny Szynka Tradycyjna"),
    ("Plukon", "Plukon Filet z Kurczaka"),
    ("Sokołów", "Sokołów Boczek Pieczony"),
    ("Sokołów", "Sokołów Kiełbasa Krakowska Sucha"),
    ("Sokołów", "Sokołów Mielonka Poznańska"),
    ("Sokołów", "Sokołów Parówki Cienkie"),
    ("Sokołów", "Sokołów Pasztet Firmowy"),
    ("Sokołów", "Sokołów Salami Dojrzewające"),
    ("Sokołów", "Sokołów Szynka Mielona"),
    ("Tarczyński", "Tarczyński Kabanosy Exclusive"),
    ("Tarczyński", "Tarczyński Kabanosy Klasyczne"),
    ("Tarczyński", "Tarczyński Kabanosy z Serem"),
    ("Tarczyński", "Tarczyński Kiełbasa Śląska"),
    ("Tarczyński", "Tarczyński Salami Pepperoni"),
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
        "page_size": 5,
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


print("Searching for Meat products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in meat_products:
    ean = search_open_food_facts(brand, product_name)
    time.sleep(0.5)  # Rate limit: 0.5s between requests

    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_name:60s} {ean_display}")

    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(f"Results: {found_count} found, {len(meat_products) - found_count} not found\n")

# Save results
with open("meat_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to meat_eans_research.json")
