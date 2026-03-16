# ADR-010: Ingredient Language Model

> **Date:** 2026-03-16
> **Status:** accepted
> **Deciders:** @ericsocrat
> **Related:** ADR-007 (English Canonical Ingredients), Issue #890

## Context

TryVit stores ~2,740 unique ingredients in `ingredient_ref` with English canonical names (`name_en`). This decision was documented in ADR-007 and serves cross-product analysis, allergen inference, EFSA concern classification, and dietary filtering.

As the platform expands from Poland to Germany (and potentially further), several questions arise about how ingredient data should relate to localization:

1. Polish and German users see ingredient lists in English — not their label language
2. The schema includes `ingredient_translations` (migration `20260315001300`) and `language_ref` (seeded with en/pl/de), providing infrastructure for localized display names — but `ingredient_translations` is currently empty (0 rows)
3. The `resolve_ingredient_name()` function implements a 4-tier COALESCE fallback (requested language → English translation → `name_en` → NULL) — but always falls through to `name_en` because no translations exist
4. The `products.ingredients_raw` column, which once preserved original Polish/German label text from source data, was dropped during schema evolution. Original source-language text is no longer in the database.
5. Open Food Facts provides a structured `ingredients` array with taxonomy IDs (e.g., `en:sugar`, `en:sea-salt`) per ingredient — but does **not** offer separate per-language ingredient text fields (`ingredients_text_pl`, `ingredients_text_de` do not exist in the API response)

This ADR establishes the complete ingredient language model: what is canonical, how translations are sourced, how the API behaves by locale, and what trade-offs the current architecture accepts.

### Investigation summary

**Schema archaeology (verified against live local DB, 2026-03-16):**

| Object | State |
|--------|-------|
| `ingredient_ref` | 3 rows locally (enrichment-dependent); `name_en` TEXT UNIQUE, `taxonomy_id` TEXT UNIQUE |
| `ingredient_translations` | Table exists, **0 rows**; PK: `(ingredient_id, language_code)` |
| `language_ref` | **3 rows seeded**: en/English, pl/Polish, de/German — all enabled |
| `resolve_ingredient_name()` | Function exists, 4-tier COALESCE fallback implemented |
| `products.ingredients_raw` | Column **does not exist** (dropped after English normalization) |
| `products` columns | 42 columns — no remnant of source-language ingredient text |

**Pipeline analysis (`enrich_ingredients.py`):**

- Processes OFF API `ingredients` structured array → extracts `taxonomy_id` per ingredient
- Normalizes to English via taxonomy ID prefix (e.g., `en:water` → "Water")
- Allergen detection uses `_OFF_TO_CANONICAL_ALLERGEN` mapper: 60+ language variants → 14 EU mandatory allergens — operates on canonical IDs, fully decoupled from display names
- Does **not** request per-language ingredient text from OFF API (field doesn't exist)

**OFF API limitations:**

- Structured `ingredients` array provides: `id` (taxonomy), `text` (ingredient text in product's source language), `percent_estimate`, `vegan`/`vegetarian`
- The `text` field contains the ingredient name as it appears on the physical label — this is the closest source of original-language text, but it is not systematically captured during enrichment
- No separate `ingredients_text_<lang>` endpoints exist

### Approaches considered

| Approach | Verdict | Rationale |
|----------|---------|-----------|
| A. **Store ingredients in each product's label language** | ❌ Rejected | Breaks cross-product analysis. "Sól morska" and "Meersalz" and "sea salt" would be three separate entries. Allergen inference and concern classification require a single canonical reference. |
| B. **English canonical + optional translation table** (current architecture) | ✅ Chosen | Preserves all analytical capabilities. Translation table provides localized display names without touching the canonical layer. Fallback to English is always safe. Schema already exists. |
| C. **Dual-store: canonical English + captured source-language text per product** | ⚠️ Deferred | Would re-introduce per-product source-language text (akin to the dropped `ingredients_raw`). Valuable for label fidelity and auditability, but the primary source (OFF API `ingredients[].text`) would require pipeline changes to capture. Not justified until a concrete user-facing need arises. |

## Decision

### 1. Canonical ingredient identity language: **English**

Reaffirmed from ADR-007. All entries in `ingredient_ref` use `name_en` as the primary identifier. Taxonomy IDs (`en:sugar`, `en:sea-salt`) anchor cross-reference with Open Food Facts. No change.

### 2. Localized display-name source: **`ingredient_translations` table**

Localized ingredient names are stored in `ingredient_translations` with FK to `ingredient_ref` and `language_ref`. The `source` column tracks provenance (`curated`, `off_api`, `auto_translated`, `user_submitted`). The table is currently empty — population is a separate implementation concern (see Follow-up §).

Candidate population sources (ranked by reliability):
1. **OFF taxonomy exports** — the Open Food Facts taxonomy project provides multilingual ingredient names keyed by taxonomy ID. Highest coverage, programmatically extractable.
2. **Curated manual entries** — for high-visibility ingredients (top 200 by product frequency). Highest accuracy, lowest coverage.
3. **Community submissions** — via `user_submitted` source type with review workflow. Scales well but requires moderation infrastructure.

### 3. Fallback behavior: **4-tier COALESCE chain**

`resolve_ingredient_name(p_ingredient_id, p_language)` implements:

```
1. ingredient_translations WHERE language_code = p_language  → use it
2. ingredient_translations WHERE language_code = 'en'        → English translation
3. ingredient_ref.name_en                                     → canonical name
4. NULL                                                        → ingredient not found
```

This chain is already implemented and deployed. The practical effect today: all calls resolve to tier 3 (`name_en`) because `ingredient_translations` is empty. As translations are populated, the function automatically begins returning localized names with zero API or schema changes.

### 4. Allergen detection: **fully decoupled from localization**

Allergen detection operates exclusively on canonical identifiers:
- `product_allergen_info.tag` stores canonical allergen tags (e.g., `en:gluten`, `en:milk`)
- The pipeline's `_OFF_TO_CANONICAL_ALLERGEN` mapper covers 60+ spelling/language variants → 14 EU mandatory allergens
- Detection uses taxonomy IDs and canonical tags — never display names
- Translating ingredient display names has **zero impact** on allergen detection accuracy

### 5. Schema changes needed now: **none**

All required infrastructure is already deployed:
- `ingredient_translations` table with RLS, indexes, and grants (migration `20260315001300`)
- `language_ref` seeded with en/pl/de (migration `20260216000800`)
- `resolve_ingredient_name()` function with fallback chain
- `ingredient_ref.taxonomy_id` for OFF cross-reference

No new migration is required for this ADR.

### 6. Next implementation step: **populate `ingredient_translations`**

The immediate next step is a data population effort — inserting translation rows into the existing `ingredient_translations` table. This should be:
- A new issue with its own migration (a `populate_ingredient_translations.sql` pattern)
- Starting with the highest-frequency ingredients (those appearing in the most products)
- Using OFF taxonomy exports as the primary source
- Scoped to Polish first (largest user base), then German

### Source-language text: trade-offs acknowledged

The dropped `ingredients_raw` column means original source-language label text is no longer in the database. This is **acceptable for the current canonical-taxonomy architecture** because:

- The analytical layer (scoring, allergen detection, dietary filtering) operates entirely on canonical English names and taxonomy IDs
- The OFF API does not provide clean per-language ingredient text — only the raw label `text` field within the structured ingredients array
- The `resolve_ingredient_name()` fallback chain ensures users always see a name (English, at minimum)

However, this comes with **real trade-offs**:

- **Label fidelity** — the database cannot reproduce the exact ingredient list as printed on a Polish or German product label. For regulatory reference or consumer dispute resolution, users must consult the physical label.
- **Auditability** — there is no database record of what the source data originally said in the label language. Audit trails for ingredient normalization rely on Git history of pipeline migrations, not on live data.
- **Future label-ingestion opportunities** — if OFF later provides per-language ingredient text, or if TryVit adds OCR/photo-based label capture, the schema will need a new column or table to store per-product source-language text (see Approach C above). This is not blocking but represents deferred work.

These trade-offs are acceptable at current scale (2 countries, ~2,600 products) and can be revisited if label-level fidelity becomes a user-facing requirement.

## Consequences

### Positive

- **Zero schema changes required** — all infrastructure exists and is deployed
- **Incremental population** — translations can be added one language/ingredient at a time with immediate user-visible benefit via the existing fallback chain
- **Allergen safety preserved** — allergen detection is completely independent of display language, eliminating localization as a safety risk
- **Multi-country ready** — adding a new language requires only `INSERT INTO language_ref` + populating `ingredient_translations` for that language code
- **Source tracking** — the `source` column on `ingredient_translations` enables quality tiers: curated translations can be distinguished from automated ones

### Negative

- **Translation population effort** — ~2,740 ingredients × N languages requires significant data work (mitigated by OFF taxonomy exports and frequency-based prioritization)
- **No source-language label text** — the database cannot reproduce original label ingredient lists, limiting label fidelity and audit capability
- **English-first user experience** — until translations are populated, all ingredient names display in English regardless of user locale

### Neutral

- ADR-007 remains in force — this ADR extends it with the localization layer, does not supersede it
- `v_master` view's `ingredients_text` column (English-only `STRING_AGG`) is unaffected — it serves internal analytics, not user-facing display
- The `ingredient_translations` trigram index (`idx_ingredient_translations_name_trgm`) is ready for localized ingredient search once data exists

## Follow-up issues implied (not implemented in this ADR)

1. **Populate `ingredient_translations` for Polish** — Migration to insert Polish translations for the top N ingredients by product frequency, sourced from OFF taxonomy exports. Scope: data migration + QA checks for translation coverage.

2. **Populate `ingredient_translations` for German** — Same pattern as Polish, second priority. Can be a separate issue or combined with Polish if effort is small.

3. **Capture OFF `ingredients[].text` during enrichment** — Modify `enrich_ingredients.py` to extract and store the per-ingredient `text` field (source-language label text) from the OFF API structured ingredients array. Requires a new column or table (e.g., `product_ingredient.label_text`). Addresses the label fidelity trade-off documented above.

4. **Wire `resolve_ingredient_name()` into API responses** — Update `api_product_detail()` (or a new variant) to accept a language parameter and return localized ingredient names via the resolve function. Currently the API returns aggregated counts/flags but not individual ingredient names.

5. **Frontend ingredient display localization** — Once the API returns localized ingredient names, update product detail components to display ingredients in the user's preferred language. Depends on issues 1–2 (data) and 4 (API).

---

> **Template:** Based on [MADR 3.0](https://adr.github.io/madr/) (Markdown Any Decision Records)
