#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Research EANs for Alcohol category (28 products) via Open Food Facts API.
Includes Polish beer brands (Lech, Tyskie, Żubr, Żywiec, Okocim, Warka)
and international brands (Somersby, Karlsquell, Just 0.).
"""

import requests
import json
import time
import sys
from datetime import datetime
from io import TextIOWrapper

# Fix Windows console encoding
if sys.stdout.encoding != "utf-8":
    sys.stdout = TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# List of 28 alcohol products from database
alcohol_products = [
    ("Dzik", "Dzik Cydr 0% jabłko i marakuja"),
    ("Just 0.", "Just 0. Red"),
    ("Just 0.", "Just 0. White alcoholfree"),
    ("Karlsquell", "Free! Radler o smaku mango"),
    ("Karmi", "Karmi"),
    ("Lech", "Lech Free"),
    ("Lech", "Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai"),
    ("Lech", "Lech Free 0,0% limonka i mięta"),
    ("Lech", "Lech Free 0,0% piwo bezalkoholowe o smaku arbuz mięta"),
    ("Lech", "Lech Free 0,0% piwo bezalkoholowe o smaku grejpfruta i guawy"),
    ("Lech", "Lech Free 0,0% piwo bezalkoholowe o smaku jeżyny i wiśni"),
    ("Lech", "Lech Free 0,0% piwo o smaku yuzu i pomelo"),
    ("Lech", "Lech Free Active Hydrate mango i cytryna 0,0%"),
    ("Lech", "Lech Free Citrus Sour"),
    ("Lech", "Lech Free smoczy owoc i winogrono 0,0%"),
    ("Lech", "Lech Premium"),
    ("Łomża", "Łomża 0% o smaku jabłko & mięta"),
    ("Łomża", "Łomża piwo jasne bezalkoholowe"),
    ("Łomża", "Łomża Radler 0,0%"),
    ("Okocim", "Okocim 0,0% mango z marakują"),
    ("Okocim", "Okocim Piwo Jasne 0%"),
    ("Somersby", "Somersby blackcurrant & lime 0%"),
    ("Somersby", "Somersby Blueberry Flavoured Cider"),
    ("Tyskie", "Tyskie Gronie"),
    ("Warka", "Piwo Warka Radler"),
    ("Warka", "Warka Kiwi Z Pigwą 0,0%"),
    ("Żubr", "Żubr Premium"),
    ("Zywiec", "Zywiec Full"),
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
    except Exception as e:
        return None


print("Searching for Alcohol products on Open Food Facts...")
print("=" * 80)

results = []
found_count = 0

for brand, product_name in alcohol_products:
    ean = search_open_food_facts(brand, product_name)
    time.sleep(0.5)  # Rate limit: 0.5s between requests

    status = "FOUND" if ean else "NOT FOUND"
    ean_display = ean if ean else "N/A"
    print(f"[{status:9s}] {brand:15s} {product_name:60s} {ean_display}")

    if ean:
        found_count += 1
        results.append({"brand": brand, "product_name": product_name, "ean": ean})

print("=" * 80)
print(
    f"Results: {found_count} found, {len(alcohol_products) - found_count} not found\n"
)

# Save results
with open("alcohol_eans_research.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Found {found_count} EANs. Saved to alcohol_eans_research.json")
