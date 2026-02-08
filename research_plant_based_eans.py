#!/usr/bin/env python3
"""Search for EANs of Plant-Based & Alternatives products on Open Food Facts API."""

import sys
import io
import requests
import json
from time import sleep

# Load encoding first
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# List of 27 unique Plant-Based products
plant_based_products = [
    ("Alpro", "Alpro Jogurt Sojowy Naturalny"),
    ("Alpro", "Alpro Napój Migdałowy Niesłodzony"),
    ("Alpro", "Alpro Napój Owsiany Naturalny"),
    ("Alpro", "Alpro Napój Sojowy Naturalny"),
    ("Beyond Meat", "Beyond Meat Beyond Burger"),
    ("Beyond Meat", "Beyond Meat Beyond Sausage"),
    ("Garden Gourmet", "Garden Gourmet Sensational Burger"),
    ("Garden Gourmet", "Garden Gourmet Vegan Mince"),
    ("Garden Gourmet", "Garden Gourmet Vegan Nuggets"),
    ("Garden Gourmet", "Garden Gourmet Vegan Schnitzel"),
    ("Green Legend", "Green Legend Kotlet Sojowy"),
    ("Kupiec", "Kupiec Ser Tofu Naturalny"),
    ("Kupiec", "Kupiec Ser Tofu Wędzony"),
    ("LikeMeat", "LikeMeat Like Chicken Pieces"),
    ("LikeMeat", "LikeMeat Like Kebab"),
    ("Naturalnie", "Naturalnie Napój Kokosowy"),
    ("Naturalnie", "Naturalnie Napój Owsiany Klasyczny"),
    ("Simply V", "Simply V Ser Kremowy Naturalny"),
    ("Sojasun", "Sojasun Jogurt Sojowy Naturalny"),
    ("Sojasun", "Sojasun Jogurt Sojowy Waniliowy"),
    ("Taifun", "Taifun Tempeh Natural"),
    ("Taifun", "Taifun Tofu Natural"),
    ("Taifun", "Taifun Tofu Rosso"),
    ("Taifun", "Taifun Tofu Smoked"),
    ("Violife", "Violife Cheddar Slices"),
    ("Violife", "Violife Mozzarella Style Shreds"),
    ("Violife", "Violife Original Block"),
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
    """Search for all plant-based products."""
    results = []
    found = 0
    not_found = 0

    print("Searching for Plant-Based & Alternatives products on Open Food Facts...\n")

    for brand, product_name in plant_based_products:
        result = search_open_food_facts(brand, product_name)
        sleep(0.5)  # Rate limit

        status = "✓" if result else "✗"
        ean = result["ean"] if result else "N/A"
        print(f"{status} {brand:<20} {product_name:<40} {ean:<15}")

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

    print("=" * 80)
    print(f"\nResults: {found} found, {not_found} not found\n")

    # Save results
    with open("plant_based_eans_research.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"Found {len(results)} EANs. Saved to plant_based_eans_research.json")


if __name__ == "__main__":
    main()
