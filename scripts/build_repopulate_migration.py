"""
Build a combined repopulate migration from existing enrichment migrations.

Reads:
  - supabase/migrations/20260215141000_populate_ingredients_allergens.sql (PL)
  - supabase/migrations/20260309000100_de_enrichment_ingredients_allergens.sql (DE)

Extracts sections 1 (ingredient_ref), 2 (allergen), 3 (product_ingredient),
transforms allergen tags to canonical IDs, and outputs a single migration file.
"""

import re
import sys
from pathlib import Path

# ── Canonical allergen mapping ──────────────────────────────────────
# Maps OFF API allergen tags (with/without en: prefix, Polish, German)
# to the 14 EU-mandatory allergen IDs in allergen_ref.
CANONICAL_ALLERGENS = {
    "celery", "crustaceans", "eggs", "fish", "gluten", "lupin",
    "milk", "molluscs", "mustard", "peanuts", "sesame",
    "soybeans", "sulphites", "tree-nuts",
}

TAG_MAP: dict[str, str] = {
    # English canonical (with en: prefix)
    "en:gluten": "gluten",
    "en:milk": "milk",
    "en:eggs": "eggs",
    "en:fish": "fish",
    "en:soybeans": "soybeans",
    "en:peanuts": "peanuts",
    "en:celery": "celery",
    "en:mustard": "mustard",
    "en:lupin": "lupin",
    "en:crustaceans": "crustaceans",
    "en:molluscs": "molluscs",
    "en:sulphites": "sulphites",
    "en:tree-nuts": "tree-nuts",
    "en:sesame": "sesame",
    # Common OFF API variants
    "en:sesame-seeds": "sesame",
    "en:sulphur-dioxide-and-sulphites": "sulphites",
    "en:nuts": "tree-nuts",
    "en:wheat": "gluten",
    "en:barley": "gluten",
    "en:rye": "gluten",
    "en:oats": "gluten",
    "en:spelt": "gluten",
    "en:kamut": "gluten",
    "en:cashew-nuts": "tree-nuts",
    "en:almonds": "tree-nuts",
    "en:hazelnuts": "tree-nuts",
    "en:walnuts": "tree-nuts",
    "en:pecans": "tree-nuts",
    "en:brazil-nuts": "tree-nuts",
    "en:pistachio-nuts": "tree-nuts",
    "en:macadamia-nuts": "tree-nuts",
    "en:shrimp": "crustaceans",
    "en:crab": "crustaceans",
    "en:lobster": "crustaceans",
    "en:squid": "molluscs",
    "en:clams": "molluscs",
    "en:mussels": "molluscs",
    "en:oysters": "molluscs",
    "en:snails": "molluscs",
    "en:soy": "soybeans",
    "en:soya": "soybeans",
    "en:lactose": "milk",
    "en:butter": "milk",
    "en:cream": "milk",
    "en:cheese": "milk",
    "en:casein": "milk",
    "en:whey": "milk",
    # Polish allergen names
    "pszeniczny": "gluten", "pszenny": "gluten", "pszenica": "gluten",
    "żyto": "gluten", "żytni": "gluten", "żytnia": "gluten",
    "jęczmień": "gluten", "jęczmienny": "gluten",
    "owies": "gluten", "owsiany": "gluten", "owsiana": "gluten",
    "orkisz": "gluten", "orkiszowy": "gluten",
    "gluten": "gluten", "glutenu": "gluten",
    "mleko": "milk", "mleczny": "milk", "mleczna": "milk",
    "mleczne": "milk", "mleka": "milk",
    "laktoza": "milk", "laktozy": "milk",
    "masło": "milk", "śmietana": "milk", "śmietany": "milk",
    "ser": "milk", "sera": "milk", "serowy": "milk",
    "kazeina": "milk", "kazeiny": "milk",
    "serwatka": "milk", "serwatki": "milk",
    "jaja": "eggs", "jajka": "eggs", "jajeczny": "eggs",
    "jajeczna": "eggs", "jajeczne": "eggs", "jaj": "eggs",
    "jajo": "eggs",
    "ryby": "fish", "ryba": "fish", "rybny": "fish",
    "rybna": "fish", "rybne": "fish",
    "soja": "soybeans", "soi": "soybeans", "sojowy": "soybeans",
    "sojowa": "soybeans", "sojowe": "soybeans", "soją": "soybeans",
    "sojowych": "soybeans", "sojowego": "soybeans",
    "orzeszki ziemne": "peanuts", "arachidowe": "peanuts",
    "orzeszków ziemnych": "peanuts", "arachidowy": "peanuts",
    "seler": "celery", "selera": "celery", "selerowy": "celery",
    "gorczyca": "mustard", "gorczycy": "mustard",
    "gorczycowy": "mustard",
    "sezam": "sesame", "sezamu": "sesame", "sezamowy": "sesame",
    "łubin": "lupin", "łubinu": "lupin", "łubinowy": "lupin",
    "orzechy": "tree-nuts", "orzechów": "tree-nuts",
    "orzechowy": "tree-nuts", "orzechowe": "tree-nuts",
    "migdały": "tree-nuts", "migdałów": "tree-nuts",
    "migdałowy": "tree-nuts",
    "laskowe": "tree-nuts", "laskowych": "tree-nuts",
    "pistacjowe": "tree-nuts", "pistacjowych": "tree-nuts",
    "włoskie": "tree-nuts", "włoskich": "tree-nuts",
    "pekan": "tree-nuts", "nerkowce": "tree-nuts",
    "nerkowców": "tree-nuts", "makadamia": "tree-nuts",
    "brazylijskie": "tree-nuts",
    "skorupiaki": "crustaceans", "skorupiaków": "crustaceans",
    "krewetki": "crustaceans", "krewetek": "crustaceans",
    "krab": "crustaceans", "kraba": "crustaceans",
    "homar": "crustaceans", "homara": "crustaceans",
    "mięczaki": "molluscs", "mięczaków": "molluscs",
    "małże": "molluscs", "ostrygi": "molluscs",
    "kalmary": "molluscs", "ślimaki": "molluscs",
    "siarka": "sulphites", "siarczyny": "sulphites",
    "dwutlenek siarki": "sulphites", "siarczynu": "sulphites",
    "dwutlenku siarki": "sulphites",
    # German allergen names
    "weizen": "gluten", "roggen": "gluten", "gerste": "gluten",
    "hafer": "gluten", "dinkel": "gluten", "kamut": "gluten",
    "milch": "milk", "laktose": "milk", "sahne": "milk",
    "butter": "milk", "käse": "milk", "molke": "milk",
    "eier": "eggs", "ei": "eggs",
    "fisch": "fish", "fische": "fish",
    "sojabohnen": "soybeans",
    "erdnüsse": "peanuts", "erdnuss": "peanuts",
    "sellerie": "celery",
    "senf": "mustard",
    "sesam": "sesame", "sesamsamen": "sesame",
    "lupinen": "lupin", "lupine": "lupin",
    "nüsse": "tree-nuts", "schalenfrüchte": "tree-nuts",
    "mandeln": "tree-nuts", "haselnüsse": "tree-nuts",
    "walnüsse": "tree-nuts", "pistazien": "tree-nuts",
    "cashewnüsse": "tree-nuts", "pekannüsse": "tree-nuts",
    "macadamianüsse": "tree-nuts", "paranüsse": "tree-nuts",
    "krebstiere": "crustaceans", "garnelen": "crustaceans",
    "weichtiere": "molluscs", "muscheln": "molluscs",
    "schwefeldioxid": "sulphites", "sulfite": "sulphites",
}


def map_allergen_tag(raw_tag: str) -> str | None:
    """Map a raw OFF allergen tag to a canonical allergen_ref ID."""
    t = raw_tag.strip().lower()
    # Direct lookup
    if t in TAG_MAP:
        return TAG_MAP[t]
    # Strip en: prefix and retry
    if t.startswith("en:"):
        bare = t[3:]
        if bare in CANONICAL_ALLERGENS:
            return bare
        if bare in TAG_MAP:
            return TAG_MAP[bare]
    # Unknown tag — skip
    return None


def extract_sections(filepath: Path) -> tuple[str, str, str]:
    """Extract sections 1 (ingredient_ref), 2 (allergen), 3 (product_ingredient) from migration file."""
    text = filepath.read_text(encoding="utf-8")
    lines = text.split("\n")

    # Find section boundaries by looking for section header patterns
    section_starts: list[int] = []
    for i, line in enumerate(lines):
        if re.match(r"^-- [1234]\.", line):
            section_starts.append(i)

    if len(section_starts) < 3:
        # Fallback: find by separator pattern
        sep_indices = [i for i, line in enumerate(lines) if "═══" in line]
        # Sections start after each pair of separator lines
        section_starts = [sep_indices[i] + 2 for i in range(0, len(sep_indices), 2)]

    if len(section_starts) < 3:
        print(f"ERROR: Could not find 3+ sections in {filepath}")
        sys.exit(1)

    # Extract each section (from header line to line before next header)
    sec1_start = section_starts[0]
    sec2_start = section_starts[1]
    sec3_start = section_starts[2]
    sec4_start = section_starts[3] if len(section_starts) > 3 else len(lines)

    # Find the actual SQL start for each section (after the header/separator lines)
    sec1_text = "\n".join(lines[sec1_start:sec2_start]).rstrip()
    sec2_text = "\n".join(lines[sec2_start:sec3_start]).rstrip()
    sec3_text = "\n".join(lines[sec3_start:sec4_start]).rstrip()

    return sec1_text, sec2_text, sec3_text


def transform_allergen_section(sec2_text: str) -> str:
    """Transform allergen section to use canonical allergen_ref IDs."""
    lines = sec2_text.split("\n")
    output_lines: list[str] = []
    skipped = 0
    transformed = 0
    seen_tuples: set[tuple[str, str, str, str]] = set()  # dedup

    for line in lines:
        # Match allergen value lines: ('PL', '5900014005716', 'en:gluten', 'contains'),
        m = re.match(
            r"^(\s*)\('([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)'\)([,;]?)(.*)$",
            line,
        )
        if m:
            indent, country, ean, raw_tag, allergen_type, separator, rest = m.groups()
            canonical = map_allergen_tag(raw_tag)
            if canonical is None:
                skipped += 1
                continue
            # Dedup (same product + tag + type = skip)
            key = (country, ean, canonical, allergen_type)
            if key in seen_tuples:
                skipped += 1
                continue
            seen_tuples.add(key)
            # Rebuild the line with canonical tag
            output_lines.append(
                f"{indent}('{country}', '{ean}', '{canonical}', '{allergen_type}'){separator}{rest}"
            )
            transformed += 1
        else:
            output_lines.append(line)

    # Fix trailing commas: find the last value line and ensure it ends without comma
    for i in range(len(output_lines) - 1, -1, -1):
        if output_lines[i].strip().startswith("("):
            # Replace trailing comma with nothing
            output_lines[i] = re.sub(r",(\s*)$", r"\1", output_lines[i])
            break

    print(f"  Allergens: {transformed} kept, {skipped} skipped (unmapped/dupes)")
    return "\n".join(output_lines)


def main():
    root = Path(__file__).resolve().parent.parent
    migrations_dir = root / "supabase" / "migrations"

    pl_file = migrations_dir / "20260215141000_populate_ingredients_allergens.sql"
    de_file = migrations_dir / "20260309000100_de_enrichment_ingredients_allergens.sql"
    out_file = migrations_dir / "20260313000100_repopulate_ingredients_allergens.sql"

    if not pl_file.exists():
        print(f"ERROR: {pl_file} not found")
        sys.exit(1)
    if not de_file.exists():
        print(f"ERROR: {de_file} not found")
        sys.exit(1)

    print(f"Reading PL migration: {pl_file.name}")
    pl_s1, pl_s2, pl_s3 = extract_sections(pl_file)

    print(f"Reading DE migration: {de_file.name}")
    de_s1, de_s2, de_s3 = extract_sections(de_file)

    print("\nTransforming PL allergen section...")
    pl_s2_clean = transform_allergen_section(pl_s2)

    print("Transforming DE allergen section...")
    de_s2_clean = transform_allergen_section(de_s2)

    # Build combined migration
    header = """-- Repopulate product_ingredient and product_allergen_info tables
-- Combined from PL (20260215141000) + DE (20260309000100) enrichment migrations
-- Placed AFTER all cleanup migrations to survive db reset replay
-- Generated by scripts/build_repopulate_migration.py
--
-- Rollback: DELETE FROM product_ingredient;
-- DELETE FROM product_allergen_info WHERE tag IN (SELECT allergen_id FROM allergen_ref);

BEGIN;
"""

    # Combine sections 1 (ingredient_ref — ON CONFLICT DO NOTHING is safe)
    section1 = f"""
-- ═══════════════════════════════════════════════════════════════
-- 1a. PL — Add new ingredients to ingredient_ref
-- ═══════════════════════════════════════════════════════════════

{pl_s1}

-- ═══════════════════════════════════════════════════════════════
-- 1b. DE — Add new ingredients to ingredient_ref
-- ═══════════════════════════════════════════════════════════════

{de_s1}
"""

    # Combine sections 2 (allergens — transformed to canonical IDs)
    section2 = f"""
-- ═══════════════════════════════════════════════════════════════
-- 2a. PL — Populate product_allergen_info (canonical tags)
-- ═══════════════════════════════════════════════════════════════

{pl_s2_clean}

-- ═══════════════════════════════════════════════════════════════
-- 2b. DE — Populate product_allergen_info (canonical tags)
-- ═══════════════════════════════════════════════════════════════

{de_s2_clean}
"""

    # Combine sections 3 (product_ingredient)
    section3 = f"""
-- ═══════════════════════════════════════════════════════════════
-- 3a. PL — Populate product_ingredient
-- ═══════════════════════════════════════════════════════════════

{pl_s3}

-- ═══════════════════════════════════════════════════════════════
-- 3b. DE — Populate product_ingredient
-- ═══════════════════════════════════════════════════════════════

{de_s3}
"""

    # Section 4: refresh MVs
    section4 = """
-- ═══════════════════════════════════════════════════════════════
-- 4. Refresh materialized views
-- ═══════════════════════════════════════════════════════════════

SELECT refresh_all_materialized_views();

COMMIT;
"""

    full = header + section1 + section2 + section3 + section4

    out_file.write_text(full, encoding="utf-8")
    line_count = full.count("\n") + 1
    size_kb = len(full.encode("utf-8")) / 1024

    print(f"\n✓ Written: {out_file.name}")
    print(f"  Lines: {line_count:,}")
    print(f"  Size: {size_kb:.1f} KB")


if __name__ == "__main__":
    main()
