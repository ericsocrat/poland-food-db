"""
Standardize ingredients_raw to English using OFF structured taxonomy.

Strategy:
1. For products with ingredients_text_en on OFF -> use that directly
2. For products with structured 'ingredients' array -> reconstruct English
   from taxonomy IDs (en:potato-flakes -> "potato flakes")
3. For the 1 product without structured data -> keep original
"""

import requests
import subprocess
import json
import time
import re
import sys

# ── Get product_ids and EANs from DB ──
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
        """SELECT p.product_id, p.ean, i.ingredients_raw
        FROM products p
        JOIN ingredients i ON p.product_id = i.product_id
        WHERE p.is_deprecated = false
          AND i.ingredients_raw IS NOT NULL
          AND p.ean IS NOT NULL
        ORDER BY p.product_id""",
    ],
    capture_output=True,
    text=True,
    encoding="utf-8",
    errors="replace",
)
rows = []
for line in result.stdout.strip().split("\n"):
    if not line.strip():
        continue
    parts = line.split("|", 2)
    if len(parts) == 3:
        rows.append(
            {
                "product_id": int(parts[0]),
                "ean": parts[1].strip(),
                "raw": parts[2].strip(),
            }
        )

print(f"Products to process: {len(rows)}")

session = requests.Session()
session.headers.update({"User-Agent": "poland-food-db/1.0"})


def build_english_from_taxonomy(ingredients, depth=0):
    """Recursively build English ingredient text from OFF structured array."""
    parts = []
    for item in ingredients:
        eng_id = item.get("id", "")
        text = item.get("text", "")
        percent = item.get("percent")
        percent_estimate = item.get("percent_estimate")

        # Get English name from taxonomy ID
        if eng_id.startswith("en:"):
            name = eng_id[3:].replace("-", " ")
        elif text:
            # Use original text if no English taxonomy ID
            name = text
        else:
            continue

        # Add percentage if available
        pct_str = ""
        if percent is not None:
            pct_str = f" {percent}%"

        # Handle sub-ingredients
        subs = item.get("ingredients", [])
        if subs:
            sub_text = build_english_from_taxonomy(subs, depth + 1)
            if sub_text:
                parts.append(f"{name}{pct_str} ({sub_text})")
            else:
                parts.append(f"{name}{pct_str}")
        else:
            parts.append(f"{name}{pct_str}")

    return ", ".join(parts)


def clean_english_text(text):
    """Clean up an English ingredients string."""
    # Normalize whitespace
    text = re.sub(r"\s+", " ", text).strip()
    # Remove trailing period
    text = text.rstrip(".")
    # Capitalize first letter only
    if text:
        text = text[0].upper() + text[1:]
    return text


# ── Process all products ──
updates = []
used_en_text = 0
used_taxonomy = 0
kept_original = 0
errors = 0

for i, row in enumerate(rows):
    ean = row["ean"]
    pid = row["product_id"]
    original = row["raw"]

    try:
        resp = session.get(
            f"https://world.openfoodfacts.org/api/v2/product/{ean}.json",
            params={"fields": "ingredients,ingredients_text_en"},
            timeout=10,
        )
        data = resp.json()
        product = data.get("product", {})

        # Priority 1: Use ingredients_text_en if available and decent length
        en_text = (product.get("ingredients_text_en") or "").strip()
        if len(en_text) > 10:
            cleaned = clean_english_text(en_text)
            updates.append({"product_id": pid, "text": cleaned, "source": "en_text"})
            used_en_text += 1
        else:
            # Priority 2: Reconstruct from structured taxonomy
            ingredients = product.get("ingredients", [])
            if ingredients:
                english = build_english_from_taxonomy(ingredients)
                cleaned = clean_english_text(english)
                if cleaned:
                    updates.append(
                        {"product_id": pid, "text": cleaned, "source": "taxonomy"}
                    )
                    used_taxonomy += 1
                else:
                    updates.append(
                        {"product_id": pid, "text": original, "source": "original"}
                    )
                    kept_original += 1
            else:
                updates.append(
                    {"product_id": pid, "text": original, "source": "original"}
                )
                kept_original += 1

    except Exception as e:
        print(f"  ERROR for {ean}: {e}", file=sys.stderr)
        updates.append({"product_id": pid, "text": original, "source": "original"})
        errors += 1

    if (i + 1) % 50 == 0:
        print(
            f"  Processed {i+1}/{len(rows)} — en_text={used_en_text}, taxonomy={used_taxonomy}, original={kept_original}, errors={errors}"
        )

    time.sleep(0.15)

print(f"\n{'='*60}")
print(f"RESULTS (before translation):")
print(f"  From EN text:      {used_en_text}")
print(f"  From taxonomy:     {used_taxonomy}")
print(f"  Kept original:     {kept_original}")
print(f"  Errors:            {errors}")
print(f"  Total:             {len(updates)}")

# ── Translation pass for remaining non-English texts ──
from deep_translator import GoogleTranslator

non_ascii_pattern = re.compile(r"[^\x00-\x7F]")
needs_translation = [u for u in updates if non_ascii_pattern.search(u["text"])]
print(f"\nProducts needing translation: {len(needs_translation)}")

translator = GoogleTranslator(source="auto", target="en")
translated_count = 0
translation_errors = 0

for i, u in enumerate(needs_translation):
    try:
        original_text = u["text"]
        translated = translator.translate(original_text)
        if translated and len(translated.strip()) > 5:
            u["text"] = clean_english_text(translated)
            u["source"] = u["source"] + "+translated"
            translated_count += 1
        # else keep the original text
    except Exception as e:
        print(f"  Translation error pid={u['product_id']}: {e}", file=sys.stderr)
        translation_errors += 1

    if (i + 1) % 20 == 0:
        print(f"  Translated {i+1}/{len(needs_translation)}")

    time.sleep(0.3)  # rate limit for Google Translate

print(f"\nTranslation results:")
print(f"  Translated:        {translated_count}")
print(f"  Translation errors: {translation_errors}")

# ── Final verification ──
still_non_ascii = sum(1 for u in updates if non_ascii_pattern.search(u["text"]))
print(f"  Still non-ASCII:   {still_non_ascii}")

# ── Second pass: targeted dictionary-based cleanup ──
# Common Polish/German/French food terms that Google Translate misses in mixed text
FOOD_TERM_MAP = {
    # Polish food/ingredient terms
    "bułka pszenna": "wheat roll",
    "Bułka pszenna": "Wheat roll",
    "sos koktajlowy": "cocktail sauce",
    "środek do przetwarzania mąki": "flour treatment agent",
    "środek wypiekowy": "baking agent",
    "środek": "agent",
    "kwasów tłuszczowych": "fatty acids",
    "chleb pszenny": "wheat bread",
    "Chleb pszenny": "Wheat bread",
    "pieczywo pszenne": "wheat bread",
    "Pieczywo pszenne": "Wheat bread",
    "mąka pszenna": "wheat flour",
    "mąka": "flour",
    "maka PSZENNA": "WHEAT flour",
    "płatki zbożowe": "cereal flakes",
    "płatki ŻYTNIE": "RYE flakes",
    "płatki": "flakes",
    "smażone": "fried",
    "słonecznikowy": "sunflower",
    "ryżowy": "rice",
    "przemiału": "milling",
    "płaskostrąkowa": "legume",
    "może zawierać": "may contain",
    "zawierać": "contain",
    "może": "may",
    "słodko-kwaśny": "sweet and sour",
    "słodko": "sweet",
    "kwaśny": "sour",
    "surówka": "raw salad",
    "słody": "malts",
    "polepszająca": "improving",
    "pszenicę": "wheat",
    "śruta słodowa ŻYTNIA": "RYE malt grist",
    "marchewka z groszkiem": "carrots with peas",
    "Marchewka z groszkiem": "Carrots with peas",
    "ocet buforowy": "buffered vinegar",
    "ocet buforowany": "buffered vinegar",
    "podgórne": "Podgorne",
    "podgóme": "Podgorne",
    "cokreć": "licorice",
    "mąka PSZENNA": "WHEAT flour",
    # German food terms
    "Süßmolken": "sweet whey",
    "süßmolken": "sweet whey",
    # French food terms
    "purée": "puree",
    "instantanées": "instant",
    "céréales": "cereals",
    "maïs": "corn",
    "blé": "wheat",
    "soufflé": "puffed",
    "pâte": "paste",
    "à": "with",
    # Estonian
    "maisiõli": "corn oil",
    "köömne": "caraway",
    # Korean (just remove)
    "삼양식품": "Samyang Foods",
    "주": "",
    # Special characters that are fine
    "jalapeño": "jalapeno",
    "tapiocastárkeons": "tapioca starch",
    # Additional Polish terms from second pass analysis
    "Podgóme": "Podgorne",
    "COKREĆ": "LICORICE",
    "Mąka": "Flour",
    "smażona": "fried",
    "mięso": "meat",
    "kurczęcej": "chicken",
    "zawierająca": "containing",
    "białka": "proteins",
    "grabów": "Grabow",
    "prosną": "Prosna",
    "sál": "salt",
    "Pieczywo pszenne": "Wheat bread",
    "pieczywo pszenne": "wheat bread",
    # French terms
    "entièrement": "fully",
    "hydrogénée": "hydrogenated",
    "pâté": "pate",
    # Greek
    "ΤΠΣΑΥ": "",
    "ΖΙΤΘ": "",
    "ΓΕΜΕΣΪ": "",
    # Temperature
    "°c": "C",
    "°C": "C",
    # Additional isolated Polish terms (third pass)
    "pełnoziarniste": "whole grain",
    "użyta": "used",
    "przeciwbrylujący": "anti-caking",
    "Sposób": "Method",
    "płaski": "flat",
    "łącznie": "including",
    "_LAKTOZĄ_": "_LACTOSE_",
    "brokułowy": "broccoli",
    "muszkatołowy": "nutmeg",
    "_śledziowe_": "_herring_",
    "3‚61": "3.61",
    # Unicode superscripts
    "¹⁾": "",
    "¹": "",
    "²": "",
    "³": "",
    "⁾": "",
    # More Polish food terms
    "miodowy": "honey",
    "pszeniczny": "wheat",
    "żytni": "rye",
    "kukurydziany": "corn",
    "ziemniaczany": "potato",
    "cukrowy": "sugar",
    "mleczny": "milk",
    "owsiany": "oat",
    "sojowy": "soy",
    "palmowy": "palm",
    "kokosowy": "coconut",
    # Unicode symbols
    "±": "+/-",
    "µg": "mcg",
    "–": "-",
    "biaŁowy": "protein",
    "biaŁowy ekstrudat zbofeline": "cereal protein extrudate",
    "6tô": "6to",
}

second_pass_fixed = 0
for u in updates:
    if non_ascii_pattern.search(u["text"]):
        original = u["text"]
        text = u["text"]
        for foreign, english in FOOD_TERM_MAP.items():
            text = text.replace(foreign, english)
        if text != original:
            u["text"] = clean_english_text(text)
            second_pass_fixed += 1

still_non_ascii_after = sum(1 for u in updates if non_ascii_pattern.search(u["text"]))
print(f"\nSecond pass (dictionary):")
print(f"  Fixed:             {second_pass_fixed}")
print(f"  Still non-ASCII:   {still_non_ascii_after}")

# Show remaining non-ASCII for inspection
if still_non_ascii_after > 0:
    print("\nRemaining non-ASCII samples:")
    remaining = [u for u in updates if non_ascii_pattern.search(u["text"])]
    for u in remaining[:10]:
        # Find non-ASCII fragments
        frags = re.findall(r"[\w]*[^\x00-\x7F][\w]*", u["text"])
        print(f"  pid={u['product_id']}: fragments={frags[:5]}")

# ── Third pass: force-translate remaining non-ASCII fragments ──
still_remaining = [u for u in updates if non_ascii_pattern.search(u["text"])]
if still_remaining:
    print(
        f"\nThird pass: force-translating {len(still_remaining)} remaining products (pl->en)..."
    )
    pl_translator = GoogleTranslator(source="pl", target="en")
    third_fixed = 0
    for u in still_remaining:
        try:
            # Extract non-ASCII segments and translate them
            text = u["text"]
            fragments = re.findall(r"[^\x00-\x7F\s][^\x00-\x7F\w\s]*[\w]*", text)
            for frag in set(fragments):
                if len(frag.strip()) < 2:
                    continue
                try:
                    translated_frag = pl_translator.translate(frag.strip())
                    if translated_frag and translated_frag != frag:
                        text = text.replace(frag, translated_frag)
                except:
                    pass
            if text != u["text"]:
                u["text"] = clean_english_text(text)
                third_fixed += 1
            time.sleep(0.3)
        except Exception as e:
            pass

    final_non_ascii = sum(1 for u in updates if non_ascii_pattern.search(u["text"]))
    print(f"  Third pass fixed: {third_fixed}")
    print(f"  Final non-ASCII:  {final_non_ascii}")

# ── Fourth pass: re-apply dictionary to anything the third pass introduced ──
for u in updates:
    if non_ascii_pattern.search(u["text"]):
        text = u["text"]
        for foreign, english in FOOD_TERM_MAP.items():
            text = text.replace(foreign, english)
        u["text"] = clean_english_text(text)

absolute_final = sum(1 for u in updates if non_ascii_pattern.search(u["text"]))
print(f"  After final dict:  {absolute_final}")

# ── Show samples ──
print(f"\n{'='*60}")
print("SAMPLE OUTPUTS:")
for source_type in [
    "en_text",
    "taxonomy",
    "en_text+translated",
    "taxonomy+translated",
    "original",
]:
    samples = [u for u in updates if u["source"] == source_type][:3]
    for s in samples:
        print(f"  [{source_type}] pid={s['product_id']}: {s['text'][:150]}")

# ── Generate migration SQL ──
migration_lines = [
    "-- Standardize ingredients_raw to English",
    "-- Source: OFF taxonomy IDs + ingredients_text_en",
    "-- Generated by standardize_ingredients_english.py",
    "",
    "BEGIN;",
    "",
]

for u in updates:
    escaped = u["text"].replace("'", "''")
    migration_lines.append(
        f"UPDATE ingredients SET ingredients_raw = '{escaped}' WHERE product_id = {u['product_id']};"
    )

migration_lines.extend(
    [
        "",
        "COMMIT;",
    ]
)

migration_path = (
    "supabase/migrations/20260210001200_standardize_ingredients_english.sql"
)
with open(migration_path, "w", encoding="utf-8") as f:
    f.write("\n".join(migration_lines))

print(f"\nMigration written to: {migration_path}")
