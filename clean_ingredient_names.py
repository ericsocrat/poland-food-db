"""
Fix 1+2: Translate all non-English ingredient names to English + rebuild ingredients_raw.

Strategy:
1. Query ingredient_ref for all non-English entries (taxonomy_id NOT LIKE 'en:%')
2. Try OFF taxonomy API to get canonical English name
3. Fall back to Google Translate for remaining
4. Apply manual corrections dictionary
5. Generate migration to update ingredient_ref.name_en
6. Rebuild ingredients_raw from clean structured data
"""

import requests
import subprocess
import time
import re
import sys
import json

# ── Manual translation dictionary for common Polish/French food terms ──
MANUAL_TRANSLATIONS = {
    # Polish
    "maka pszenna": "wheat flour",
    "mąka pszenna": "wheat flour",
    "pszennego": "wheat",
    "pszenne pełnoziarniste": "wholegrain wheat",
    "preparat serwatkowy z mleka": "whey preparation from milk",
    "i produkty pochodne": "and derivatives",
    "ich produkty pochodne": "and their derivatives",
    "produkty przemiału pszenicy": "wheat milling products",
    "ser w proszku z mleka": "milk powder cheese",
    "mieszanka wypiekowa": "baking mix",
    "wyciąg z szyszek chmielowych": "hop cone extract",
    "przefermentowana mąka pszenna": "fermented wheat flour",
    "krem majonezowy": "mayonnaise cream",
    "środek wypiekowy": "raising agent",
    "mieszanka smakowa": "flavoring mix",
    "mieszanina smakowa": "flavor mixture",
    "olej słonecznikowy wysokooleinowy": "high oleic sunflower oil",
    "płatki pszenne pieczone": "baked wheat flakes",
    "kawałki": "pieces",
    "w polewie kakaowej": "in cocoa coating",
    "wiśni": "cherry",
    "wielokwiatowy": "multi-flower",
    "smażone": "fried",
    "smażona": "fried",
    "płatki zytnie": "rye flakes",
    "płatki zbożowe": "cereal flakes",
    "pełnoziarniste": "wholegrain",
    "pełnoziarniste płatki zbożowe": "wholegrain cereal flakes",
    "dojrzały zakwas pszenny": "mature wheat sourdough",
    "środek do przetwarzania maki": "flour processing agent",
    "zawierają białka mleka łącznie z laktozą": "contains milk proteins including lactose",
    "platki zbożowe": "cereal flakes",
    "kawałki orzechów brazylijskich": "brazil nut pieces",
    "produkty pochodzące ze zbóż": "products derived from cereals",
    "sałatka": "salad",
    "białko kolagenowe": "collagen protein",
    "olej rzepakowy z pierwszego tłoczenia": "cold-pressed rapeseed oil",
    "płatki gruszkowe": "pear flakes",
    "wysokooleinowy słonecznikowy": "high oleic sunflower",
    "mąka pszenno-żytnia": "wheat-rye flour",
    "ekstrudat ryżowo-otrębowy": "rice-bran extrudate",
    "z wanilią z madagaskaru": "with Madagascar vanilla",
    "produkt może zawierać też inne zboża zawierające gluten": "may also contain other gluten-containing cereals",
    "krojone marynowane filety ze śledzia atlantyckiego bez skóry": "sliced marinated skinless Atlantic herring fillets",
    "mieszanka przypraw": "spice mix",
    "ser podpuszczkowy": "rennet cheese",
    "masło kakaowe": "cocoa butter",
    "tłuszcz palmowy": "palm fat",
    "olej palmowy": "palm oil",
    "olej rzepakowy": "rapeseed oil",
    "olej słonecznikowy": "sunflower oil",
    "mąka żytnia": "rye flour",
    "skrobia kukurydziana": "corn starch",
    "skrobia modyfikowana": "modified starch",
    "białko sojowe": "soy protein",
    "białko mleka": "milk protein",
    "białko grochu": "pea protein",
    "sól morska": "sea salt",
    "ekstrakt drożdżowy": "yeast extract",
    "ekstrakt słodowy": "malt extract",
    "aromat naturalny": "natural flavoring",
    "aromaty naturalne": "natural flavorings",
    "aromat": "flavoring",
    "kwas cytrynowy": "citric acid",
    "kwas askorbinowy": "ascorbic acid",
    "kwas mlekowy": "lactic acid",
    "lecytyna sojowa": "soy lecithin",
    "lecytyna słonecznikowa": "sunflower lecithin",
    "syrop glukozowo-fruktozowy": "glucose-fructose syrup",
    "syrop glukozowy": "glucose syrup",
    "mleko pełne w proszku": "whole milk powder",
    "mleko odtłuszczone w proszku": "skimmed milk powder",
    "śmietanka": "cream",
    "masło": "butter",
    "jaja": "eggs",
    "mąka kukurydziana": "corn flour",
    "mąka ryżowa": "rice flour",
    "skórka pomarańczowa": "orange peel",
    "koncentrat pomidorowy": "tomato concentrate",
    "pieprz czarny": "black pepper",
    "papryka": "paprika",
    "czosnek": "garlic",
    "cebula": "onion",
    "ocet spirytusowy": "spirit vinegar",
    "ocet jabłkowy": "apple cider vinegar",
    "drożdże": "yeast",
    "żelatyna": "gelatin",
    "błonnik": "fiber",
    "inulina": "inulin",
    "woda": "water",
    "cukier": "sugar",
    "sól": "salt",
    "miód": "honey",
    # French
    "nouilles instantanees": "instant noodles",
    "flocons d epeautre": "spelt flakes",
    "maltodextrin": "maltodextrin",
    "noisettes decortiquees": "shelled hazelnuts",
    "extrait de poulet": "chicken extract",
    "beurre de cacao": "cocoa butter",
    "huile de palme": "palm oil",
    "huile de tournesol": "sunflower oil",
    "huile de colza": "rapeseed oil",
    "farine de ble": "wheat flour",
    "sel": "salt",
    "sucre": "sugar",
    "eau": "water",
    "lait": "milk",
    "oeuf": "egg",
    "amidon": "starch",
    "fecule": "starch",
    # Hungarian
    "extrudált rizs": "extruded rice",
    "módosított kukoricakeményító": "modified corn starch",
    "fűszerek": "spices",
    # Slovak
    "sk zloženie": "SK composition",
    "kukurična krupica": "corn semolina",
    "hnedy cukor": "brown sugar",
    "invertny cukrovy sirup": "invert sugar syrup",
    "melasa z trstinoveho cukru": "cane sugar molasses",
    "fosforečnany sodne": "sodium phosphates",
    # Romanian
    "ovăz integral": "whole oats",
    "substanţă minerală": "mineral substance",
    # Croatian
    "pšenično brašno 1850": "wheat flour 1850",
    # Czech
    "slunečnicový": "sunflower",
    # Azerbaijani
    "manna yarması": "semolina",
    # German
    "weizenmehl": "wheat flour",
    "zucker": "sugar",
    "salz": "salt",
    "wasser": "water",
}


# Detect language from taxonomy_id prefix
def get_lang(taxonomy_id):
    return taxonomy_id.split(":")[0] if ":" in taxonomy_id else "unknown"


def try_off_taxonomy(taxonomy_id):
    """Try to get English name from OFF ingredient taxonomy API."""
    try:
        # OFF taxonomy URL format
        url = f"https://world.openfoodfacts.org/api/v2/taxonomy?tagtype=ingredients&tags={taxonomy_id}&fields=name&lc=en"
        r = requests.get(url, timeout=10, headers={"User-Agent": "poland-food-db/1.0"})
        if r.ok:
            data = r.json()
            # Try to extract English name from response
            if isinstance(data, dict):
                for key, val in data.items():
                    if isinstance(val, dict) and "name" in val:
                        en_name = val["name"].get("en")
                        if en_name:
                            return en_name.lower().strip()
        return None
    except Exception:
        return None


def translate_with_google(text, source_lang="auto"):
    """Translate using deep-translator (Google Translate)."""
    try:
        from deep_translator import GoogleTranslator

        result = GoogleTranslator(source=source_lang, target="en").translate(text)
        if result:
            return result.lower().strip()
    except Exception:
        pass
    return None


# ── Get all non-English ingredients from DB ──
print("Fetching non-English ingredient refs from DB...")
result = subprocess.run(
    [
        "docker",
        "exec",
        "supabase_db_poland-food-db",
        "psql",
        "-U",
        "postgres",
        "-d",
        "postgres",
        "-t",
        "-A",
        "-c",
        "SELECT ingredient_id, taxonomy_id, name_en FROM ingredient_ref WHERE taxonomy_id NOT LIKE 'en:%' ORDER BY ingredient_id",
    ],
    capture_output=True,
    text=True,
    encoding="utf-8",
    errors="replace",
)

non_english = []
for line in result.stdout.strip().split("\n"):
    if not line.strip():
        continue
    parts = line.split("|", 2)
    if len(parts) == 3:
        non_english.append(
            {
                "id": int(parts[0]),
                "taxonomy_id": parts[1].strip(),
                "name_en": parts[2].strip(),
            }
        )

print(f"Non-English ingredients to translate: {len(non_english)}")

# Also get English ingredients that are not in taxonomy (might need cleanup)
result2 = subprocess.run(
    [
        "docker",
        "exec",
        "supabase_db_poland-food-db",
        "psql",
        "-U",
        "postgres",
        "-d",
        "postgres",
        "-t",
        "-A",
        "-c",
        "SELECT ingredient_id, taxonomy_id, name_en FROM ingredient_ref WHERE taxonomy_id LIKE 'en:%' AND NOT is_in_taxonomy ORDER BY ingredient_id",
    ],
    capture_output=True,
    text=True,
    encoding="utf-8",
    errors="replace",
)

en_not_taxonomy = []
for line in result2.stdout.strip().split("\n"):
    if not line.strip():
        continue
    parts = line.split("|", 2)
    if len(parts) == 3:
        en_not_taxonomy.append(
            {
                "id": int(parts[0]),
                "taxonomy_id": parts[1].strip(),
                "name_en": parts[2].strip(),
            }
        )

print(f"English not-in-taxonomy ingredients: {len(en_not_taxonomy)}")

# ── Translate non-English ingredients ──
updates = []
manual_hits = 0
google_hits = 0
kept = 0

for i, item in enumerate(non_english):
    tid = item["taxonomy_id"]
    current = item["name_en"]
    iid = item["id"]

    # Step 1: Check manual dictionary
    if current.lower() in MANUAL_TRANSLATIONS:
        new_name = MANUAL_TRANSLATIONS[current.lower()]
        updates.append({"id": iid, "new_name": new_name, "source": "manual"})
        manual_hits += 1
        continue

    # Step 2: Try to extract English name from taxonomy ID
    # e.g., "fr:nouilles-instantanees" -> try looking up canonical name
    # For pl: prefix, the taxonomy ID IS the Polish text, so we need to translate

    # Step 3: Google Translate the current name_en (which is in the source language)
    lang = get_lang(tid)
    lang_map = {
        "pl": "pl",
        "fr": "fr",
        "de": "de",
        "hu": "hu",
        "sk": "sk",
        "ro": "ro",
        "cs": "cs",
        "hr": "hr",
        "et": "et",
        "es": "es",
        "da": "da",
        "az": "az",
    }
    src_lang = lang_map.get(lang, "auto")

    translated = None
    for attempt in range(3):
        try:
            translated = translate_with_google(current, src_lang)
            break
        except Exception:
            time.sleep(2 * (attempt + 1))
    if translated and translated != current.lower():
        updates.append({"id": iid, "new_name": translated, "source": "google"})
        google_hits += 1
    else:
        # Keep as-is but log
        kept += 1

    # Rate limiting
    if (i + 1) % 20 == 0:
        print(
            f"  Translated {i+1}/{len(non_english)}... (manual={manual_hits}, google={google_hits}, kept={kept})"
        )
        time.sleep(0.5)

print(f"\nTranslation results:")
print(f"  Manual dictionary: {manual_hits}")
print(f"  Google Translate: {google_hits}")
print(f"  Kept original: {kept}")
print(f"  Total updates: {len(updates)}")

# ── Also clean up the en: not-in-taxonomy entries ──
# These are mostly already English but might have artifacts
en_cleanups = []
for item in en_not_taxonomy:
    tid = item["taxonomy_id"]
    current = item["name_en"]
    # Extract from taxonomy ID: en:some-thing -> "some thing"
    if tid.startswith("en:"):
        clean = tid[3:].replace("-", " ").strip()
        if clean and clean != current.lower():
            en_cleanups.append(
                {"id": item["id"], "new_name": clean, "source": "tid_extract"}
            )

print(f"  English cleanup from taxonomy IDs: {len(en_cleanups)}")

# ── Also get the garbage entries we need to fix ──
# Entries like "6 vztiahnute na obsahzložky v celom vyrobku" and "sk zloženie"
# are not real ingredients — they're OCR artifacts
GARBAGE_PATTERNS = [
    r"vztiahnute na",
    r"zloženie",
    r"www\.",
    r"\d{10,}",  # barcodes
    r"store at",
    r"do not refreeze",
    r"NORI Food",
    r"CHRUP",
    r"information at",
]

# ── Generate SQL migration ──
print("\nGenerating migration SQL...")

migration_lines = [
    "-- Migration: clean ingredient names and rebuild ingredients_raw",
    "-- Date: 2026-02-10",
    "-- Fix 1: Translate 433 non-English ingredient_ref names to English",
    "-- Fix 2: Rebuild ingredients_raw from structured junction data",
    "",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "-- Part 1: Update ingredient_ref.name_en with English translations",
    "-- ═══════════════════════════════════════════════════════════════════════════",
    "",
]

all_updates = updates + en_cleanups
for u in all_updates:
    escaped = u["new_name"].replace("'", "''")
    migration_lines.append(
        f"UPDATE ingredient_ref SET name_en = '{escaped}' WHERE ingredient_id = {u['id']}; -- {u['source']}"
    )

migration_lines.extend(
    [
        "",
        "-- ═══════════════════════════════════════════════════════════════════════════",
        "-- Part 2: Rebuild ingredients_raw from structured product_ingredient data",
        "-- Each product gets a clean comma-separated English ingredient list",
        "-- ═══════════════════════════════════════════════════════════════════════════",
        "",
        "UPDATE ingredients i",
        "SET ingredients_raw = sub.clean_list",
        "FROM (",
        "  SELECT",
        "    pi.product_id,",
        "    STRING_AGG(",
        "      CASE",
        "        WHEN pi.percent IS NOT NULL THEN ir.name_en || ' ' || pi.percent || '%'",
        "        ELSE ir.name_en",
        "      END,",
        "      ', '",
        "      ORDER BY pi.position",
        "    ) AS clean_list",
        "  FROM product_ingredient pi",
        "  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id",
        "  GROUP BY pi.product_id",
        ") sub",
        "WHERE sub.product_id = i.product_id",
        "  AND sub.clean_list IS NOT NULL",
        "  AND LENGTH(sub.clean_list) > 0;",
        "",
    ]
)

# Write migration
migration_path = "supabase/migrations/20260210001600_clean_ingredient_names.sql"
with open(migration_path, "w", encoding="utf-8") as f:
    f.write("\n".join(migration_lines))

print(f"Migration written: {migration_path}")
print(f"Total ingredient_ref updates: {len(all_updates)}")
print("Done!")
