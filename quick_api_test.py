#!/usr/bin/env python3
"""Quick API test."""
import requests
print("Testing Open Food Facts API...")
try:
    r = requests.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        params={'search_terms': 'Lays', 'json': 1},
        timeout=10
    )
    print(f"✓ Status: {r.status_code}")
    data = r.json()
    print(f"✓ Products found: {len(data.get('products', []))}")
    if data.get('products'):
        print(f"✓ API is working - first product: {data['products'][0].get('name', 'N/A')}")
except Exception as e:
    print(f"✗ API error: {type(e).__name__}: {e}") 
