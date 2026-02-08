#!/usr/bin/env python3
"""Search for EANs of Dairy products on Open Food Facts API."""

import sys
import io
import requests
import json
from time import sleep

# Load encoding before everything else
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# List of 28 Dairy products (brand, product_name)
dairy_products = [
    ("Bakoma", "Bakoma Kefir Naturalny"),
    ("Bakoma", "Bakoma Satino Kawowy"),
    ("Danio", "Danio Serek Waniliowy"),
    ("Danone", "Actimel Wieloowocowy"),
    ("Danone", "Activia Jogurt Naturalny"),
    ("Danone", "Danonki Truskawka"),
    ("Hochland", "Almette Śmietankowy"),
    ("Hochland", "Hochland Kanapkowy ze Szczypiorkiem"),
    ("Hochland", "Hochland Kremowy ze Śmietanką"),
    ("Łaciate", "Łaciate Masło Extra"),
    ("Łaciate", "Łaciate Mleko 3.2%"),
    ("Mlekovita", "Mlekovita Gouda"),
    ("Mlekovita", "Mlekovita Kefir Naturalny"),
    ("Mlekovita", "Mlekovita Mańlanka Naturalna"),
    ("Mlekovita", "Mlekovita Masło Ekstra"),
    ("Mlekovita", "Mlekovita Mleko UHT 2%"),
    ("Mlekpol", "Jogurt Augustowski Naturalny"),
    ("Müller", "Müller Jogurt Choco Balls"),
    ("Philadelphia", "Philadelphia Original"),
    ("Piątnica", "Piątnica Serek Wiejski"),
    ("Piątnica", "Piątnica Skyr Naturalny"),
    ("Piątnica", "Piątnica Śmietana 18%"),
    ("Piątnica", "Piątnica Twarób Półtłusty"),
    ("Président", "Président Camembert"),
    ("Sierpc", "Sierpc Ser Królewski"),
    ("Zott", "Jogobella Brzoskwinia"),
    ("Zott", "Zott Jogurt Naturalny"),
    ("Zott", "Zott Monte"),
]


def search_open_food_facts(brand, product_name):
    """Search Open Food Facts for product and return EAN if found."""
    try:
        # Build search query
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
                # Filter for valid EANs
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
    """Search for all Dairy products."""
    results = []
    found = 0
    not_found = 0

    print("Searching for Dairy products on Open Food Facts...\n")

    for brand, product_name in dairy_products:
        result = search_open_food_facts(brand, product_name)
        sleep(0.5)  # Rate limit

        status = "✓ FOUND" if result else "✗ NOT FOUND"
        ean = result["ean"] if result else "N/A"
        print(f"{brand:<15} {product_name:<35} {ean:<15} {status}")

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

    print("=" * 70)
    print(f"\nResults: {found} found, {not_found} not found\n")

    # Save results as JSON
    with open("dairy_eans_research.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"Found {len(results)} EANs. Saved to dairy_eans_research.json")


if __name__ == "__main__":
    main()
