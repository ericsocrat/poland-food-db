#!/usr/bin/env python3
"""Search for EANs of missing Chips products on Open Food Facts API."""

import sys
import io
import requests
import json
from time import sleep

# Fix Windows UTF-8 encoding for Polish characters
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# List of 24 missing Chips products (brand, product_name)
missing_products = [
    ("Żabka", "Żabka chips salted (store brand)"),
    ("Cheetos", "Cheetos Puffs"),
    ("Chio", "Chio Chips Paprika"),
    ("Chio", "Chio Chips Salted"),
    ("Crunchips", "Crunchips X-Cut Paprika"),
    ("Crunchips", "Crunchips X-Cut Salted"),
    ("Doritos", "Doritos Nacho Cheese"),
    ("Doritos", "Doritos Sweet Chilli"),
    ("Generic/Reference", "Potato chips (fried, 100 g)"),
    ("Lay's", "Lay's Classic Salted"),
    ("Lay's", "Lay's Fromage"),
    ("Lay's", "Lay's Max Karbowane Papryka"),
    ("Lay's", "Lay's Maxx Ser z Cebulką"),
    ("Lay's", "Lay's Oven Baked (classic)"),
    ("Lay's", "Lay's Oven Baked (paprika)"),
    ("Lay's", "Lay's Oven Baked Grilled Paprika"),
    ("Lay's", "Lay's Pikantna Papryka"),
    ("Lay's", "Lay's Solone"),
    ("Lay's", "Lay's Zielona Cebulka"),
    ("Lorenz", "Lorenz Naturals Sea Salt"),
    ("Snack Day (Lidl)", "Snack Day Paprika"),
    ("Snack Day (Lidl)", "Snack Day Salted"),
    ("Top Chips (Biedronka)", "Top Chips Paprika"),
    ("Top Chips (Biedronka)", "Top Chips Salted"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts for product and return EAN if found."""
    try:
        # Build search query - focus on Polish market where possible
        search_query = f"{brand} {product_name}"

        # API endpoint for search
        url = "https://world.openfoodfacts.org/cgi/search.pl"
        params = {
            "search_terms": search_query,
            "action": "process",
            "json": 1,
            "page_size": 5,
        }

        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        data = response.json()

        # Check if any products found
        if data.get("products"):
            for product in data["products"]:
                # Filter for Polish products or products with valid EANs
                if product.get("code") and len(str(product.get("code", ""))) >= 8:
                    return {
                        "ean": product["code"],
                        "name": product.get("product_name", ""),
                        "brand": product.get("brands", ""),
                        "country": product.get("countries", ""),
                    }
        return None
    except Exception as e:
        return None


def main():
    """Search for all missing products."""
    results = []
    found = 0
    not_found = 0

    print("Searching for missing Chips products on Open Food Facts...\n")
    print(f"{'Brand':<20} {'Product Name':<50} {'EAN':<15} {'Status'}")
    print("=" * 100)

    for brand, product_name in missing_products:
        result = search_open_food_facts(brand, product_name)
        sleep(0.5)  # Rate limit - be respectful to API

        if result:
            print(f"{brand:<20} {product_name:<50} {result['ean']:<15} ✓ FOUND")
            results.append(
                {
                    "brand": brand,
                    "product_name": product_name,
                    "ean": result["ean"],
                    "off_brand": result.get("brand", ""),
                    "country": result.get("country", ""),
                }
            )
            found += 1
        else:
            print(f"{brand:<20} {product_name:<50} {'N/A':<15} ✗ NOT FOUND")
            not_found += 1

    print("=" * 100)
    print(f"\nResults: {found} found, {not_found} not found")

    # Save results as JSON
    with open("chips_eans_research.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\nFound {len(results)} EANs. Saved to chips_eans_research.json")

    if results:
        print("\nRecommended SQL UPDATEs:\n")
        for r in results:
            product_name_sql = r["product_name"].replace("'", "''")
            print(
                f"update products set ean = '{r['ean']}' where brand = '{r['brand']}' and product_name = '{product_name_sql}' and category = 'Chips';"
            )


if __name__ == "__main__":
    main()
