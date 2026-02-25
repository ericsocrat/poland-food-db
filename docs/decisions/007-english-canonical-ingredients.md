# ADR-007: Ingredient Data in English Canonical Names

> **Date:** 2026-02-10 (retroactive — implemented in migration `20260210001600`)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

Product labels in Poland use Polish ingredient names. Open Food Facts provides ingredients in the product's original language (often Polish, sometimes mixed Polish/English/German). The database needs a canonical ingredient dictionary for:

- Cross-product comparison (is "sól" the same as "salt"?)
- Allergen inference from ingredients
- Additive classification (EFSA concern tiers)
- Dietary filtering (vegan, vegetarian, palm oil)

Three approaches were considered:

1. **Store in original language** — preserves label fidelity but prevents cross-product analysis. "Sól morska" and "sea salt" would be separate entries.
2. **Multi-language with translation table** — comprehensive but high maintenance. Requires ongoing translation effort for every new ingredient.
3. **English canonical + provenance** — normalize all ingredients to clean ASCII English names. Store the original label text in `ingredients_raw` for reference.

## Decision

All 2,740 ingredients in `ingredient_ref` are stored as **clean ASCII English** names:

- Polish names translated to English during pipeline import
- Mixed-language names normalized (e.g., "sól morska" → "sea salt")
- Diacritics stripped for consistency (`name_en` column is ASCII-safe)
- Original label text preserved in `products.ingredients_raw`
- Migration `20260210001600` translated 375 foreign ingredient names

Each ingredient has classification flags:
- `is_additive` — boolean (E-number additives)
- `concern_tier` — 0–3 (EFSA-based risk classification)
- `vegan` / `vegetarian` — 'yes'/'no'/'maybe'
- `contains_palm_oil` — 'yes'/'no'/'maybe'

## Consequences

### Positive

- **Cross-product analysis** — all products use the same ingredient dictionary regardless of label language
- **Allergen inference** — matching against English canonical names is reliable
- **Additive classification** — EFSA concern tiers work on standardized names
- **Search consistency** — users search in one language, not multiple
- **2,740 unique ingredients** across 859 products with full classification

### Negative

- **Translation maintenance** — new Polish/German products may introduce untranslated ingredients requiring manual mapping
- **Lossy normalization** — some nuance may be lost (e.g., "ser żółty" vs "yellow cheese" vs "semi-hard cheese")
- **English bias** — non-English-speaking contributors may find the ingredient dictionary less intuitive

### Neutral

- `ingredient_ref` table has unique constraint on `name_en`
- `product_ingredient` junction table tracks position, percent, sub-ingredient relationships
- QA suite `QA__ingredient_quality.sql` (14 checks) validates data quality
- 4-tier concern system documented in `concern_tier_ref` table with EFSA guidance
