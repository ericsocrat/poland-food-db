#!/usr/bin/env python3
"""Test Open Food Facts API with Bonduelle products."""

import requests
import json

# Test different search approaches
tests = [
    "Bonduelle",
    "Bonduelle mushrooms",
    "Bonduelle chickpeas",
    "Heinz tomato",
    "canned mushrooms",
    "mushrooms 400g",
]

url = "https://world.openfoodfacts.org/cgi/search.pl"

for query in tests:
    print(f"\n{'=' * 60}")
    print(f"Testing: {query}")
    print('=' * 60)
    
    params = {
        "search_terms": query,
        "search_simple": 1,
        "action": "process",
        "json": 1,
        "page_size": 3
    }
    
    try:
        response = requests.get(url, params=params, timeout=5)
        data = response.json()
        
        count = data.get("count", 0)
        print(f"Found {count} products")
        
        if data.get("products"):
            for i, prod in enumerate(data["products"][:2], 1):
                print(f"\n{i}. {prod.get('name', 'N/A')}")
                print(f"   EAN: {prod.get('code', 'N/A')}")
                print(f"   Brand: {prod.get('brands', 'N/A')}")
    except Exception as e:
        print(f"Error: {e}")
    
    import time
    time.sleep(0.5)
