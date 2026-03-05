# Country Expansion Guide

> **Last updated:** 2026-03-05
> **Current status:** Poland (`PL`) is fully active (1,198 products, 20 categories). Germany (`DE`) is at **full parity** (1,066 products, 19 categories).
> **DE graduated from micro-pilot to full market on 2026-03-05.** See Section 12 for lessons learned.

---

## 1. Expansion Philosophy

This project is designed for eventual EU-wide coverage, but expansion must be **methodical, not opportunistic**. Each country introduces:

- Different product formulations (same brand, different recipe)
- Different labeling regulations (mandatory vs. voluntary fields)
- Different retail landscapes (stores, private labels)
- Different Nutri-Score adoption status
- Different food safety authorities and additive rules

**Rule:** A country is never "partially" added. Either all prerequisites are complete and the country is fully operational, or it does not exist in the database.

---

## 2. Prerequisites for Adding a Country

Before any data for country `XX` enters the database, **all** of the following must be true:

### 2.1 Regulatory Research (Documentation)

- [ ] Document which EU regulations apply to food labeling in country `XX`
- [ ] Confirm whether Nutri-Score is mandatory, voluntary, or absent
- [ ] Identify the national food safety authority (equivalent of Poland's GIS/SANEPID)
- [ ] Document any country-specific additive restrictions beyond EU baseline
- [ ] Identify label language(s) and translation requirements

### 2.2 Retail Landscape (Documentation)

- [ ] Identify the top 5–10 retailers in country `XX` by market share
- [ ] Document which retailers have online product catalogs with nutrition data
- [ ] Identify major private-label brands and their ownership
- [ ] Confirm per-100g labeling convention (vs. per-serving in non-EU contexts)

### 2.3 Data Sources (Verification)

- [ ] Confirm Open Food Facts coverage for country `XX` (number of verified products)
- [ ] Identify at least one reliable primary source for label data
- [ ] Test data collection workflow on 5–10 products before committing

### 2.4 Technical Setup (Implementation)

- [x] Create pipeline folder: `db/pipelines/<country_lower>/` or `db/pipelines/<category>-<country>/`
- [x] Verify that the `products(country, brand, product_name)` unique constraint handles the new country
- [x] Confirm that all schemas support the new country's data without migration changes
- [x] Create `RUN_LOCAL.ps1` / `RUN_REMOTE.ps1` entries for the new pipelines
- [x] Set `country_ref.nutri_score_official` for the new country (`true` if officially adopted, `false` otherwise)
- [x] Update `copilot-instructions.md` to list the new country as active

### 2.5 Country Expansion Readiness (Go/No-Go Bar)

All of these must be true before activating a second country:

- [x] API supports country filtering on search + listings (`p_country` param, RPC-compatible)
- [x] Auto-country resolution when `p_country` is NULL (`resolve_effective_country` — user pref → system default)
- [x] Alternatives/similarity are country-isolated (inferred from source product)
- [x] Scoring + completeness are country-parameterized (`score_category` accepts `p_country`)
- [x] Dashboard stats are country-aware (`v_api_category_overview_by_country` view)
- [x] Activation gating exists (`country_ref.is_active` enforced by QA)
- [x] `sql_generator.py` accepts `country` parameter (no more hardcoded `'PL'`)
- [x] QA checks for cross-country leakage (api_surfaces #16, #17, #18)
- [x] Pilot country with 5–10 products: all QA passes, no cross-country leakage

> **DE completion date:** 2026-03-05 — all prerequisites met, 1,066 products across 19 categories, full QA validation passed (see §12).

---

## 3. Country Isolation Rules

### 3.1 Data Isolation

Every row in the `products` table carries a `country` column. This is the **primary isolation mechanism**.

```sql
-- All pipeline queries MUST filter by country
WHERE p.country = 'XX'
```

- Products from different countries are **never mixed** in a single pipeline file.
- A product sold in both Poland and Germany is entered as **two separate rows** with `country = 'PL'` and `country = 'DE'`, because formulations differ.
- Scores are computed per-country, never averaged across countries.

### 3.2 Pipeline Isolation

Each country's pipelines are independent:

```
db/pipelines/
├── chips-pl/               # PL chips
├── dairy/                  # PL dairy (legacy naming — no DE counterpart yet uses this)
├── zabka/                  # PL Żabka store (PL-only)
├── chips-de/               # DE chips
├── dairy-de/               # DE dairy
├── bread-de/               # DE bread
└── ...                     # 39 total folders (20 PL + 19 DE)
```

**Naming convention** — **decided: category + hyphenated country suffix**:

| Strategy           | Example            | When to use                         | Status           |
| ------------------ | ------------------ | ----------------------------------- | ---------------- |
| Category-only      | `dairy/`           | Single-country (legacy PL)          | **Legacy**       |
| Category-pl        | `chips-pl/`        | PL category with DE counterpart     | **Active**       |
| Category-de        | `chips-de/`        | DE category                         | **Active**       |
| Store-based        | `zabka/`           | Country-specific store chains       | **Active (PL)**  |

**Transition rule:** When a second country is added for an existing category:
1. Rename the PL folder: `chips/` → `chips_pl/` (update `RUN_*.ps1` accordingly)
2. Create the new country folder: `chips_de/`
3. Both folders now follow the `<category>_<country>` pattern
4. **Do NOT rename until the second country is actually added** — premature renaming breaks the current working pipeline

### 3.3 No Cross-Country Scoring

- Unhealthiness Scores are **not comparable** across countries because:
  - Formulations differ (same brand/product, different recipe)
  - Serving conventions may differ
  - Regulatory thresholds (salt, sugar flags) may need country adjustment
- The `v_master` view operates globally but should be filtered by `country` in all queries.

---

## 4. Store Differences Across Countries

| Aspect                | Poland (PL)            | Germany (DE) — Example       |
| --------------------- | ---------------------- | ---------------------------- |
| Discount leaders      | Biedronka, Lidl        | Aldi, Lidl                   |
| Convenience           | Żabka                  | REWE To Go, Aral             |
| Hypermarkets          | Auchan, Carrefour      | Kaufland, Real               |
| Private label density | High (Biedronka, Lidl) | Very high (Aldi, Lidl, REWE) |
| Nutri-Score adoption  | Voluntary              | Voluntary (widely used)      |
| Label language        | Polish                 | German                       |

**Implication:** Store-based pipelines (like `zabka/`) are **country-specific by definition** and cannot be reused across countries. Category-based pipelines (like `chips/`) can serve as **templates** but must be duplicated and customized.

---

## 5. Pipeline Duplication Rules

When expanding to a new country, follow this process:

### Step 1: Copy the Reference Pipeline

```powershell
# Example: Adding German chips
Copy-Item -Recurse db/pipelines/chips db/pipelines/chips_de
```

### Step 2: Rename All Files

```
PIPELINE__chips_de__01_insert_products.sql
PIPELINE__chips_de__03_add_nutrition.sql
PIPELINE__chips_de__04_scoring.sql
PIPELINE__chips_de__05_source_provenance.sql
```

### Step 3: Update All Queries

In every file, change:
- `country = 'PL'` → `country = 'DE'`
- `category = 'Chips'` remains `'Chips'` (categories are language-neutral)
- Product names → German market SKUs
- Brand names → German market variants
- Store availability → German retailers
- Nutrition values → German label values

### Step 4: Add to Run Scripts

Update `RUN_LOCAL.ps1` and `RUN_REMOTE.ps1` to include the new pipeline folder.

### Step 5: Test Locally

Run the new pipeline against local Supabase. Verify:
- [ ] All products insert with `country = 'DE'`
- [ ] No conflict with existing PL products
- [ ] Scores compute correctly
- [ ] `v_master` view returns both PL and DE rows

---

## 6. Schema Considerations

The current schema is **country-agnostic by design**:

- `products.country` — discriminator column, part of the unique constraint
- `products` — stores scores, flags, confidence, and source provenance inline (`source_type`, `source_url`, `source_ean`)
- `nutrition_facts` — linked by `product_id`, inheriting country from the product
- `product_allergen_info` — linked by `product_id` for contains/traces declarations

### Potential Future Schema Changes

These changes are **not needed now** but may be required during expansion:

| Change                                                  | Trigger                                                        |
| ------------------------------------------------------- | -------------------------------------------------------------- |
| Add `country` to source reference table (if introduced) | Only if multi-source lineage is normalized to a separate table |
| Add `currency` column for price data                    | If price tracking is ever added (out of scope)                 |
| Add `regulation_ref` to `products`                      | To cite country-specific labeling regulations                  |
| Separate schema per country                             | Only if dataset exceeds millions of rows                       |

**Rule:** Any schema change requires a new Supabase migration. Never modify existing migrations.

---

## 7. Regulatory Differences to Watch

| Regulation area             | Varies by country? | Impact on scoring                 |
| --------------------------- | ------------------ | --------------------------------- |
| Mandatory nutrition fields  | Slightly           | Core 7 fields are EU-wide         |
| Nutri-Score adoption        | Yes                | Affects data availability         |
| Traffic light labeling (UK) | Post-Brexit only   | Not applicable in EU              |
| Additive restrictions       | Rarely             | Some national bans beyond EU list |
| Organic certification marks | Yes                | Different national logos          |
| Allergen labeling format    | Slightly           | Bolding vs. separate list         |
| Trans fat declaration       | Voluntary in EU    | May become mandatory              |

---

## 8. Expansion Roadmap (Indicative)

This is a **suggested** order based on data availability, market size, and Nutri-Score adoption:

| Phase | Country | Code | Rationale                                          | Status                             |
| ----- | ------- | ---- | -------------------------------------------------- | ---------------------------------- |
| 1     | Poland  | PL   | Founder's market; full access to labels            | **Active** — 1,198 products, 20 categories |
| 2     | Germany | DE   | Largest EU market; strong Open Food Facts coverage | **Active** — 1,066 products, 19 categories (full parity since 2026-03-05) |
| 3     | France  | FR   | Nutri-Score origin country; best data quality      | Planned                            |
| 4     | Spain   | ES   | Large market; growing Nutri-Score adoption         | Future                             |
| 5     | Italy   | IT   | Complex food landscape; controversial with NS      | Future                             |
| 6     | Czechia | CZ   | Regional neighbor; similar retail landscape to PL  | Future                             |

**This roadmap is non-binding.** Expansion happens only when prerequisites in Section 2 are fully met.

---

## 9. What NOT to Do During Expansion

- ❌ Do NOT add a country "just to test" — even test data pollutes the schema
- ❌ Do NOT share pipeline files between countries — always duplicate and customize
- ❌ Do NOT assume same brand = same product across countries
- ❌ Do NOT compare Unhealthiness Scores across countries without methodology review
- ❌ Do NOT modify Polish pipelines to accommodate another country's needs
- ❌ Do NOT use non-EU data sources (USDA, etc.) for EU country products
- ❌ Do NOT add a country if Open Food Facts has < 100 verified products for it

---

## 10. Search Configuration for New Countries (#192)

When adding a new country, configure search infrastructure:

### Step 1: Add Language (if not present)

```sql
INSERT INTO language_ref (code, name_en, name_native, sort_order)
VALUES ('xx', 'Language', 'Native Name', 10)
ON CONFLICT (code) DO NOTHING;
```

### Step 2: Update `build_search_vector()`

Add a WHEN clause to the country CASE in `build_search_vector()`:

```sql
WHEN 'XX' THEN 'config_name'::regconfig
```

Available built-in configs: `simple`, `english`, `german`, `french`, `italian`,
`spanish`, `dutch`, `danish`, `swedish`, `norwegian`, `finnish`, `russian`.

### Step 3: Add Synonym Pairs

Insert bidirectional synonym pairs for common food terms:

```sql
INSERT INTO search_synonyms (term_original, term_target, language_from, language_to)
VALUES
    ('local_term', 'english_term', 'xx', 'en'),
    ('english_term', 'local_term', 'en', 'xx');
```

Aim for 40–50 bidirectional pairs covering common food categories.

### Step 4: Backfill Search Vectors

```sql
UPDATE products
SET search_vector = build_search_vector(
    product_name, product_name_en, brand, category, country
)
WHERE country = 'XX';
```

### Step 5: Verify

Run `db/qa/QA__search_architecture.sql` to confirm all tests pass.

## 11. Data Provenance Setup for New Countries (#193)

When adding a new country, configure data provenance and governance:

### Step 1: Add Country Data Policy

```sql
INSERT INTO country_data_policies (
    country, is_active, allergen_strictness,
    min_confidence_for_publish, regulatory_framework, notes
) VALUES (
    'XX', false, 'standard',
    0.60, 'EU FIC 1169/2011', 'Initial setup'
);
```

Set `allergen_strictness` to `'strict'` for countries with enhanced allergen
regulations (e.g., DE, UK).

### Step 2: Add Freshness Policies

Insert 6 rows per country (one per field group):

```sql
INSERT INTO freshness_policies
    (country, field_group, warning_age_days, critical_age_days,
     max_age_days, refresh_strategy)
VALUES
    ('XX', 'nutrition',   90, 120, 150, 'auto_api'),
    ('XX', 'allergens',   45,  60,  75, 'manual_review'),
    ('XX', 'ingredients', 90, 120, 150, 'auto_api'),
    ('XX', 'identity',   150, 200, 365, 'auto_api'),
    ('XX', 'images',     150, 200, 365, 'auto_api'),
    ('XX', 'scoring',     15,  20,  30, 'auto_api');
```

Adjust thresholds based on local regulatory refresh requirements.

### Step 3: Add Conflict Resolution Rules

Insert rules for field groups that should auto-resolve vs. require manual review:

```sql
INSERT INTO conflict_resolution_rules
    (country, field_group, max_auto_resolve_severity, resolution_strategy)
VALUES
    ('XX', 'nutrition',   'high',     'highest_confidence'),
    ('XX', 'allergens',   'low',      'manual_always'),
    ('XX', 'ingredients', 'medium',   'highest_confidence'),
    ('XX', 'identity',    'high',     'most_recent'),
    ('XX', 'images',      'high',     'most_recent'),
    ('XX', 'scoring',     'high',     'highest_confidence');
```

### Step 4: Register Country-Specific Sources

Add retailer or local data sources:

```sql
INSERT INTO data_sources
    (source_key, display_name, source_type, base_confidence,
     country_coverage, is_active)
VALUES
    ('retailer_local', 'Local Retailer', 'retailer', 0.80,
     ARRAY['XX'], true);
```

### Step 5: Activate Country

Once fully configured and validated:

```sql
UPDATE country_data_policies SET is_active = true WHERE country = 'XX';
```

### Step 6: Verify

Run `db/qa/QA__data_provenance.sql` — tests T15–T16 validate country policies.
Also run `validate_product_for_country(product_id, 'XX')` on sample products.

---

## 12. Lessons Learned from DE Expansion (2026-03-05)

Expanding from PL-only to PL+DE took approximately 3 weeks of focused work. The following lessons apply to any future country expansion.

### 12.1 What Went Well

- **Country isolation worked perfectly.** The `products.country` discriminator + QA suite `QA__country_isolation.sql` (11 checks) caught all cross-contamination risks before they shipped.
- **Pipeline generator (`pipeline/run.py --country DE`) scaled cleanly.** The `--country` flag required minimal code changes — `sql_generator.py` and `categories.py` were already parameterized.
- **Automated enrichment (`enrich_ingredients.py`) applied unchanged to DE.** The same OFF API enrichment flow that processed PL ingredients worked for DE with zero code changes.
- **Reference tables (`country_ref`, `category_ref`) made activation trivial.** Adding DE was a single `INSERT` + `UPDATE is_active = true`.

### 12.2 What Was Harder Than Expected

- **Volume of pipeline SQL files.** 19 categories × 4–5 SQL files each = ~85 new files. Each required manual review of product names, EANs, and nutrition values. The pipeline generator helped but still produced files needing spot-checks.
- **Multi-country QA checks needed v3.3 scoring function updates.** Two QA checks in `QA__multi_country_consistency.sql` called the stale `compute_unhealthiness_v32()` and had to be upgraded to v3.3 with correct column names.
- **Merge conflicts during parallel work.** `copilot-instructions.md` and `CURRENT_STATE.md` had frequent conflicts when multiple PRs updated documentation counts. Resolution rule from §13.1 ("take the higher/more complete version") was essential.
- **OFF API data quality for DE.** Some German products had missing or inconsistent nutrition data. 9 products had calorie back-calculation outliers from OFF source data — documented as known QA exceptions.

### 12.3 Recommended Process for Future Countries

| Step | Action | Effort | Reference |
|------|--------|--------|-----------|
| 1 | Add `INSERT INTO country_ref` + `UPDATE is_active` | 1 migration | §2.4 |
| 2 | Run `pipeline/run.py --country XX --category "..." --max-products 51` for each category | ~1 day per 5 categories | §5 |
| 3 | Execute generated SQL against local DB | ~2h | `RUN_LOCAL.ps1` |
| 4 | Run `enrich_ingredients.py` for the new country | ~2h | PR #651, #654 |
| 5 | Run full QA suite + scoring anchor validation | ~1h | `RUN_QA.ps1` |
| 6 | Update documentation (this guide, `copilot-instructions.md`, `CHANGELOG.md`) | ~2h | This section |
| 7 | Deploy to production (after user confirmation) | ~30 min | §5, `RUN_REMOTE.ps1` |

### 12.4 DE Expansion Statistics

| Metric | Value |
|--------|-------|
| Products added | 1,066 active + 105 deprecated |
| Categories | 19 (all PL categories except Żabka) |
| Pipeline folders created | 19 (`*-de/` naming convention) |
| Unique ingredients (DE) | Integrated into shared `ingredient_ref` (2,898 total) |
| Product-ingredient links (DE) | Part of 14,392 total links |
| Allergen declarations (DE) | Part of 2,691 allergens + 2,702 traces total |
| QA checks added | 5 DE scoring anchors in `QA__scoring_formula_tests.sql` |
| New QA suites | `QA__multi_country_consistency.sql` (13 checks) |
| Migrations | 1 enrichment migration (18,938 lines) |
| EAN coverage | 99.9% (2,261/2,264) |
