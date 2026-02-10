"""
Fix 3: Fetch real serving sizes from OFF API and add per-serving rows.

Current state: All 560 products have only 'per 100 g' / 100g serving.
This script:
1. Fetches serving_size and serving_quantity from OFF for all EAN products
2. Adds a second serving row ('per serving') with real serving size
3. Adds per-serving nutrition computed from per-100g values
4. Generates a migration SQL file
"""

import requests
import subprocess
import time
import re
import json
import sys

session = requests.Session()
session.headers.update({"User-Agent": "poland-food-db/1.0"})

# ── Get all products with EAN ──
print("Fetching products from DB...")
result = subprocess.run(
    [
        "docker", "exec", "supabase_db_poland-food-db", "psql", "-U", "postgres",
        "-d", "postgres", "-t", "-A", "-c",
        """SELECT p.product_id, p.ean, p.product_name,
                  sv.serving_id,
                  n.calories, n.total_fat_g, n.saturated_fat_g, n.trans_fat_g,
                  n.carbs_g, n.sugars_g, n.fibre_g, n.protein_g, n.salt_g
           FROM products p
           JOIN servings sv ON sv.product_id = p.product_id
           JOIN nutrition_facts n ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
           WHERE p.ean IS NOT NULL
             AND p.is_deprecated IS NOT TRUE
             AND sv.serving_basis = 'per 100 g'
           ORDER BY p.product_id"""
    ],
    capture_output=True, text=True, encoding="utf-8", errors="replace",
)

products = []
for line in result.stdout.strip().split("\n"):
    if not line.strip():
        continue
    parts = line.split("|")
    if len(parts) == 13:
        products.append({
            "product_id": int(parts[0]),
            "ean": parts[1].strip(),
            "name": parts[2].strip(),
            "serving_id": int(parts[3]),
            "cal": float(parts[4]) if parts[4].strip() else 0,
            "fat": float(parts[5]) if parts[5].strip() else 0,
            "sat_fat": float(parts[6]) if parts[6].strip() else 0,
            "trans_fat": float(parts[7]) if parts[7].strip() else 0,
            "carbs": float(parts[8]) if parts[8].strip() else 0,
            "sugars": float(parts[9]) if parts[9].strip() else 0,
            "fibre": float(parts[10]) if parts[10].strip() else 0,
            "protein": float(parts[11]) if parts[11].strip() else 0,
            "salt": float(parts[12]) if parts[12].strip() else 0,
        })

print(f"Products to check: {len(products)}")

# ── Fetch serving data from OFF ──
serving_data = []
no_data = 0
errors = 0

for i, p in enumerate(products):
    try:
        r = session.get(
            f"https://world.openfoodfacts.org/api/v2/product/{p['ean']}",
            params={"fields": "serving_size,serving_quantity"},
            timeout=10,
        )
        if r.ok:
            prod = r.json().get("product", {})
            ss = prod.get("serving_size", "")
            sq = prod.get("serving_quantity")
            
            # Parse serving quantity
            if sq and isinstance(sq, (int, float)) and sq > 0:
                qty = float(sq)
            elif ss:
                # Try to extract number from serving_size string
                match = re.search(r"(\d+(?:\.\d+)?)\s*(?:g|ml|G|ML)", ss)
                if match:
                    qty = float(match.group(1))
                else:
                    qty = None
            else:
                qty = None
            
            if qty and qty != 100 and qty > 0 and qty < 2000:
                # Determine basis from unit
                basis = "per serving"
                if ss and ("ml" in ss.lower() or "cl" in ss.lower()):
                    basis = "per serving"
                
                serving_data.append({
                    "product_id": p["product_id"],
                    "serving_size": ss.strip() if ss else f"{qty}g",
                    "serving_qty": round(qty, 1),
                    "basis": basis,
                    # Compute per-serving nutrition (ratio from per 100g)
                    "cal": round(p["cal"] * qty / 100, 1),
                    "fat": round(p["fat"] * qty / 100, 2),
                    "sat_fat": round(p["sat_fat"] * qty / 100, 2),
                    "trans_fat": round(p["trans_fat"] * qty / 100, 2),
                    "carbs": round(p["carbs"] * qty / 100, 2),
                    "sugars": round(p["sugars"] * qty / 100, 2),
                    "fibre": round(p["fibre"] * qty / 100, 2),
                    "protein": round(p["protein"] * qty / 100, 2),
                    "salt": round(p["salt"] * qty / 100, 2),
                })
            else:
                no_data += 1
        else:
            errors += 1
    except Exception as e:
        errors += 1
    
    if (i + 1) % 50 == 0:
        print(f"  Processed {i+1}/{len(products)}... (found={len(serving_data)}, no_data={no_data}, errors={errors})")
        time.sleep(0.3)

print(f"\nResults:")
print(f"  Products with real serving size: {len(serving_data)}")
print(f"  No serving data on OFF: {no_data}")
print(f"  Errors: {errors}")

# ── Generate migration SQL ──
print("\nGenerating migration SQL...")

lines = [
    "-- Migration: add real serving sizes from OFF API",
    "-- Date: 2026-02-10",
    f"-- Adds per-serving rows for {len(serving_data)} products",
    "-- Each product now has TWO serving rows: per 100g (comparison) + per serving (real portion)",
    "",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "-- Part 1: Insert per-serving serving rows",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "",
]

for sd in serving_data:
    pid = sd["product_id"]
    qty = sd["serving_qty"]
    basis = sd["basis"]
    
    # Insert serving row (idempotent — skip if already exists)
    lines.append(
        f"INSERT INTO servings (product_id, serving_basis, serving_amount_g_ml)"
        f" SELECT {pid}, '{basis}', {qty}"
        f" WHERE NOT EXISTS (SELECT 1 FROM servings WHERE product_id = {pid} AND serving_basis = '{basis}');"
    )

lines.extend([
    "",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "-- Part 2: Insert per-serving nutrition facts",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "",
])

for sd in serving_data:
    pid = sd["product_id"]
    basis = sd["basis"]
    
    # Insert nutrition_facts linked to the new serving
    lines.append(
        f"INSERT INTO nutrition_facts (product_id, serving_id, calories, total_fat_g, saturated_fat_g, "
        f"trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)"
        f" SELECT {pid}, sv.serving_id, {sd['cal']}, {sd['fat']}, {sd['sat_fat']}, "
        f"{sd['trans_fat']}, {sd['carbs']}, {sd['sugars']}, {sd['fibre']}, "
        f"{sd['protein']}, {sd['salt']}"
        f" FROM servings sv"
        f" WHERE sv.product_id = {pid} AND sv.serving_basis = '{basis}'"
        f" AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf"
        f" JOIN servings s2 ON s2.serving_id = nf.serving_id"
        f" WHERE nf.product_id = {pid} AND s2.serving_basis = '{basis}');"
    )

migration_path = "supabase/migrations/20260210001700_add_real_servings.sql"
with open(migration_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"Migration written: {migration_path}")
print(f"Total serving rows to add: {len(serving_data)}")

# Summary stats
qtys = [sd["serving_qty"] for sd in serving_data]
if qtys:
    print(f"  Min serving: {min(qtys)}g")
    print(f"  Max serving: {max(qtys)}g")
    print(f"  Avg serving: {sum(qtys)/len(qtys):.0f}g")
    print(f"  Median serving: {sorted(qtys)[len(qtys)//2]}g")
