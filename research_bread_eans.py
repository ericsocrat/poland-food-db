#!/usr/bin/env python3
"""Search for EANs of Bread products on Open Food Facts API."""

import sys
import io
import requests
import json
from time import sleep

# Load encoding first
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# List of 28 Bread products
bread_products = [
    ("Carrefour", "Carrefour Pieczywo Chrupkie Kukurydziane"),
    ("Carrefour", "Carrefour Sucharki Pełnoziarniste"),
    ("Klara", "Klara American Sandwich Toast XXL"),
    ("Mestemacher", "Mestemacher Chleb Razowy"),
    ("Mestemacher", "Mestemacher Chleb Wielozbożowy Żytni"),
    ("Mestemacher", "Mestemacher Chleb Ziarnisty"),
    ("Mestemacher", "Mestemacher Chleb Żytni"),
    ("Mestemacher", "Mestemacher Pumpernikiel"),
    ("Oskroba", "Oskroba Bułki Hamburgerowe"),
    ("Oskroba", "Oskroba Chleb Baltonowski"),
    ("Oskroba", "Oskroba Chleb Graham"),
    ("Oskroba", "Oskroba Chleb Litewski"),
    ("Oskroba", "Oskroba Chleb Pszenno-Żytni"),
    ("Oskroba", "Oskroba Chleb Pszenno-Żytni z Ziarnami"),
    ("Oskroba", "Oskroba Chleb Żytni Pełnoziarnisty"),
    ("Oskroba", "Oskroba Chleb Żytni Razowy"),
    ("Oskroba", "Oskroba Chleb Żytni Wieloziarnisty"),
    ("Pano", "Pano Bułeczki Śniadaniowe"),
    ("Pano", "Pano Tortilla"),
    ("Pano", "Pano Tost Maślany"),
    ("Pano", "Pano Tost Pełnoziarnisty"),
    ("Schulstad", "Schulstad Toast Pszenny"),
    ("Sonko", "Sonko Pieczywo Chrupkie Ryżowe"),
    ("Tastino", "Tastino Tortilla Wraps"),
    ("Tastino", "Tastino Wholegrain Wraps"),
    ("Wasa", "Wasa Lekkie 7 Ziaren"),
    ("Wasa", "Wasa Original"),
    ("Wasa", "Wasa Pieczywo z Błonnikiem"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts for product and return EAN if found."""
    try:
        search_query = f"{brand} {product_name}"
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

        if data.get("products"):
            for product in data["products"]:
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
    """Search for all bread products."""
    results = []
    found = 0
    not_found = 0

    print("Searching for Bread products on Open Food Facts...\n")

    for brand, product_name in bread_products:
        result = search_open_food_facts(brand, product_name)
        sleep(0.5)  # Rate limit

        status = "✓" if result else "✗"
        ean = result["ean"] if result else "N/A"
        print(f"{status} {brand:<20} {product_name:<50} {ean:<15}")

        if result:
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
            not_found += 1

    print("=" * 90)
    print(f"\nResults: {found} found, {not_found} not found\n")

    # Save results
    with open("bread_eans_research.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"Found {len(results)} EANs. Saved to bread_eans_research.json")


if __name__ == "__main__":
    main()
