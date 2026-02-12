```instructions
# Copilot Instructions — Poland Food Quality Database

> **Last updated:** 2026-02-12
> **Scope:** Poland (`PL`) only — no other countries active
> **Products:** 1,025 active (20 categories), 38 deprecated
> **EAN coverage:** 997/1,025 (97.3%)
> **Scoring:** v3.2 — 9-factor weighted formula via `compute_unhealthiness_v32()` (added ingredient concern scoring)
> **Servings:** removed as separate table — all nutrition data is per-100g on nutrition_facts
> **Ingredient analytics:** 2,740 unique ingredients (all clean ASCII English), 1,218 allergen declarations, 1,309 trace declarations
> **Ingredient concerns:** EFSA-based 4-tier additive classification (0=none, 1=low, 2=moderate, 3=high)
> **QA:** 226 checks across 15 suites + 29 negative validation tests — all passing

---

## 1. Role & Principles

You are a **food scientist, nutrition researcher, and senior data engineer** maintaining a science-driven food quality database for products sold in Poland.

**Core principles:**
- **Never invent data.** Use real EU label values only.
- **Never guess Nutri-Score.** Compute from nutrition or cite official sources.
- **Idempotent everything.** Every SQL file safe to run 1× or 100×.
- **Reproducible setup.** `supabase db reset` + pipelines = full rebuild.
- **Poland only.** All products `country = 'PL'`. See `docs/COUNTRY_EXPANSION_GUIDE.md` for future.

---

## 2. Architecture & Data Flow

```

Open Food Facts API v2 Python pipeline SQL files PostgreSQL
───────────────────── → ────────────────── → ──────────────── → ──────────────
/api/v2/search pipeline/run.py db/pipelines/ products
(categories_tags_en, off_client.py 01_insert_products nutrition_facts
countries_tags_en=poland) sql_generator.py 03_add_nutrition ingredient_ref
 validator.py 04_scoring product_ingredient
 categories.py product_allergen_info
**Pipeline CLI:**
```powershell
$env:PYTHONIOENCODING="utf-8"
.\.venv\Scripts\python.exe -m pipeline.run --category "Dairy" --max-products 28
.\.venv\Scripts\python.exe -m pipeline.run --category "Chips" --dry-run
````

**Execute generated SQL:**

```powershell
Get-Content db/pipelines/dairy/*.sql | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres
```

**Run everything:**

```powershell
.\RUN_LOCAL.ps1 -RunQA            # All categories + QA
.\RUN_LOCAL.ps1 -Category chips   # Single category
.\RUN_QA.ps1                      # QA only
```

---

## 3. Project Layout

```
poland-food-db/
├── pipeline/                        # Python OFF API → SQL generator
│   ├── __main__.py                  # `python -m pipeline` entry point
│   ├── run.py                       # CLI: --category, --max-products, --dry-run
│   ├── off_client.py                # OFF API v2 client with retry logic
│   ├── sql_generator.py             # Generates 4 SQL files per category
│   ├── validator.py                 # Data validation before SQL generation
│   └── categories.py               # 20 category definitions + OFF tag mappings
├── db/
│   ├── pipelines/                   # 20 category folders, 4 SQL files each
│   │   ├── chips/                   # Reference implementation (copy for new categories)
│   │   └── ... (19 more)            # Variable product counts per category
│   ├── qa/                          # Test suites
│   │   ├── QA__null_checks.sql      # 29 data integrity checks
│   │   ├── QA__scoring_formula_tests.sql  # 27 scoring validation checks
│   │   ├── QA__api_surfaces.sql     # 14 API contract validation checks
│   │   ├── QA__confidence_scoring.sql  # 10 confidence scoring checks
│   │   ├── QA__data_quality.sql          # 25 data quality checks
│   │   ├── QA__referential_integrity.sql # 18 referential integrity checks
│   │   ├── QA__view_consistency.sql      # 12 view consistency checks
│   │   ├── QA__naming_conventions.sql    # 12 naming convention checks
│   │   ├── QA__nutrition_ranges.sql      # 16 nutrition range checks
│   │   ├── QA__data_consistency.sql      # 20 data consistency checks
│   │   ├── QA__allergen_integrity.sql    # 14 allergen integrity checks
│   │   ├── QA__serving_source_validation.sql # 16 serving & source checks
│   │   ├── QA__ingredient_quality.sql    # 14 ingredient quality checks
│   │   ├── TEST__negative_checks.sql     # 29 negative validation tests
│   │   └── QA__source_coverage.sql  # 8 informational reports (non-blocking)
│   └── views/
│       └── VIEW__master_product_view.sql  # v_master definition (reference copy)
├── supabase/
│   ├── config.toml
│   └── migrations/                  # 55 append-only schema migrations
│       ├── 20260207000100_create_schema.sql
│       ├── 20260207000200_baseline.sql
│       ├── 20260207000300_add_chip_metadata.sql
│       ├── 20260207000400_data_uniformity.sql
│       ├── 20260207000401_remove_unused_columns.sql
│       ├── 20260207000500_column_metadata.sql  # (table dropped in 20260211000500)
│       ├── 20260207000501_scoring_function.sql
│       ├── 20260208000100_add_ean_and_update_view.sql
│       ├── 20260209000100_seed_functions_and_metadata.sql
│       ├── 20260210000100_deduplicate_sources.sql
│       ├── 20260210000200_purge_deprecated_products.sql
│       ├── 20260210000300_sources_category_equijoin.sql
│       ├── 20260210000400_normalize_prep_method.sql
│       ├── 20260210000500_normalize_store_availability.sql
│       ├── 20260210000600_add_check_constraints.sql
│       ├── 20260210000700_index_tuning.sql
│       ├── 20260210000800_expand_prep_method_domain.sql
│       ├── 20260210000900_backfill_prep_method.sql
│       ├── 20260210001000_prep_method_not_null_and_scoring_v31b.sql
│       ├── 20260210001100_backfill_ingredients_raw.sql
│       ├── 20260210001200_standardize_ingredients_english.sql
│       ├── 20260210001300_ingredient_normalization.sql   # DDL: 4 new tables
│       ├── 20260210001400_populate_ingredient_data.sql    # Data: 1,257 + 7,435 + 728 + 782 rows
│       ├── 20260210001500_sync_additives_and_view.sql     # Re-score + enhanced v_master
│       ├── 20260210001600_clean_ingredient_names.sql      # Translate 375 foreign ingredient names to English
│       ├── 20260210001700_add_real_servings.sql            # 317 real per-serving rows + nutrition
│       ├── 20260210001800_fix_vmaster_serving_fanout.sql   # Filter v_master to per-100g + add per-serving columns
│       └── 20260210001900_ingredient_concern_scoring.sql   # EFSA concern tiers + v3.2 scoring function
│       └── ...                                              # (migrations 2000–2700: see file listing)
│       ├── 20260210002800_api_surfaces.sql                  # API views + RPC functions + pg_trgm search indexes
│       ├── 20260210002900_confidence_scoring.sql            # Composite confidence score (0-100) + MV
│       └── 20260210003000_performance_guardrails.sql        # MV refresh helper, staleness check, partial indexes
├── docs/
│   ├── SCORING_METHODOLOGY.md       # v3.2 algorithm (9 factors, ceilings, bands)
│   ├── API_CONTRACTS.md             # API surface contracts (6 endpoints) — response shapes, hidden columns
│   ├── PERFORMANCE_REPORT.md        # Performance audit, scale projections, query patterns
│   ├── DATA_SOURCES.md              # Source hierarchy & validation workflow
│   ├── RESEARCH_WORKFLOW.md         # Data collection lifecycle
│   ├── VIEWING_AND_TESTING.md       # Queries, Studio UI, test runner
│   ├── COUNTRY_EXPANSION_GUIDE.md   # Future multi-country protocol
│   ├── UX_UI_DESIGN.md              # UI/UX guidelines
│   ├── EAN_VALIDATION_STATUS.md     # 997/1,025 coverage (97.3%)
│   └── EAN_EXPANSION_PLAN.md        # Completed
├── RUN_LOCAL.ps1                    # Pipeline runner (idempotent)
├── RUN_QA.ps1                       # QA test runner (226 checks across 15 suites)
├── RUN_NEGATIVE_TESTS.ps1           # Negative test runner (29 injection tests)
├── RUN_REMOTE.ps1                   # Remote deployment (requires confirmation)
├── validate_eans.py                 # EAN-8/EAN-13 checksum validator (called by RUN_QA)
├── .env.example
└── README.md
```

---

## 4. Database Schema

### Tables

| Table                | Purpose                                      | Primary Key                             | Notes                                                                                             |
| -------------------- | -------------------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `products`           | Product identity, scores, flags, provenance  | `product_id` (identity)                 | Upsert key: `(country, brand, product_name)`. Scores, flags, source columns all inline.           |
| `nutrition_facts`    | Nutrition per product (per 100g)             | `product_id`                            | Numeric columns (calories, fat, sugar…)                                                           |
| `ingredient_ref`     | Canonical ingredient dictionary              | `ingredient_id` (identity)              | 2,740 unique ingredients; name_en, vegan/vegetarian/palm_oil/is_additive/concern_tier flags       |
| `product_ingredient` | Product ↔ ingredient junction                | `(product_id, ingredient_id, position)` | ~12,892 rows across 859 products; tracks percent, percent_estimate, sub-ingredients, position order |
| `product_allergen_info` | Allergens + traces per product (unified)    | `(product_id, tag, type)`               | ~2,527 rows (1,218 allergens + 1,309 traces) across 655 products; type IN ('contains','traces'); source: OFF allergens_tags / traces_tags |
| `country_ref`        | ISO 3166-1 alpha-2 country codes             | `country_code` (text PK)                | 1 row (PL); FK from products.country                                                              |
| `category_ref`       | Product category master list                 | `category` (text PK)                    | 20 rows; FK from products.category; display_name, description, icon_emoji, sort_order             |
| `nutri_score_ref`    | Nutri-Score label definitions                | `label` (text PK)                       | 7 rows (A–E + UNKNOWN + NOT-APPLICABLE); FK from scores.nutri_score_label; color_hex, description |
| `concern_tier_ref`   | EFSA ingredient concern tiers                | `tier` (integer PK)                     | 4 rows (0–3); FK from ingredient_ref.concern_tier; score_impact, examples, EFSA guidance          |

### Products Columns (key)

| Column               | Type      | Notes                                                                      |
| -------------------- | --------- | -------------------------------------------------------------------------- |
| `product_id`         | `bigint`  | Auto-incrementing identity                                                 |
| `country`            | `text`    | Always `'PL'`                                                              |
| `brand`              | `text`    | Manufacturer or brand name                                                 |
| `product_name`       | `text`    | Full product name including variant                                        |
| `category`           | `text`    | One of 20 food categories                                                  |
| `product_type`       | `text`    | Subtype (e.g., `'yogurt'`, `'beer'`)                                       |
| `ean`                | `text`    | EAN-13 barcode (unique index)                                              |
| `prep_method`        | `text`    | Preparation method (affects scoring). NOT NULL, default `'not-applicable'` |
| `store_availability` | `text`    | Normalized Polish chain name (Biedronka, Lidl, Żabka, etc.) or NULL        |
| `controversies`      | `text`    | `'none'` or `'palm oil'` etc.                                              |
| `is_deprecated`      | `boolean` | Soft-delete flag                                                           |
| `deprecated_reason`  | `text`    | Why deprecated                                                             |

### Key Functions

| Function                           | Purpose                                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `compute_unhealthiness_v32()`      | Scores 1–100 from 9 factors: sat fat, sugars, salt, calories, trans fat, additives, prep, controversies, ingredient concern |
| `explain_score_v32()`              | Returns JSONB breakdown of score: final_score + 9 factors with name, weight, raw (0–100), weighted, input, ceiling          |
| `find_similar_products()`          | Top-N products by Jaccard ingredient similarity (returns product details + similarity coefficient)                          |
| `find_better_alternatives()`       | Healthier substitutes in same/any category, ranked by score improvement and ingredient overlap                              |
| `assign_confidence()`              | Returns `'verified'`/`'estimated'`/`'low'` from data completeness                                                           |
| `score_category()`                 | Consolidated scoring procedure: Steps 0/1/4/5 (concern defaults, unhealthiness, flags + dynamic `data_completeness_pct`, confidence) for a given category |
| `compute_data_confidence()`        | Composite confidence score (0-100) with 6 components; band, completeness profile                                            |
| `compute_data_completeness()`      | Dynamic 15-checkpoint field-coverage function for `data_completeness_pct` (EAN, 9 nutrition, Nutri-Score, NOVA, ingredients, allergens, source) |
| `api_data_confidence()`            | API wrapper for compute_data_confidence(); returns structured JSONB                                                         |
| `api_product_detail()`             | Single product as structured JSONB (identity, scores, flags, nutrition, ingredients, allergens, trust)                      |
| `api_category_listing()`           | Paged category listing with sort (score\|calories\|protein\|name\|nutri_score) + pagination                                 |
| `api_score_explanation()`          | Score breakdown + human-readable headline + warnings + category context (rank, avg, relative position)                      |
| `api_better_alternatives()`        | Healthier substitutes wrapper with source product context and structured JSON                                               |
| `api_search_products()`            | Full-text + trigram search across product_name and brand; uses pg_trgm GIN indexes                                          |
| `refresh_all_materialized_views()` | Refreshes all MVs concurrently; returns timing report JSONB                                                                 |
| `mv_staleness_check()`             | Checks if MVs are stale by comparing row counts to source tables                                                            |

### Views

**`v_master`** — Flat denormalized join: products → nutrition_facts + ingredient analytics via LATERAL subqueries on product_ingredient + ingredient_ref (ingredient_count, additive_names, ingredients_raw, has_palm_oil, vegan_status, vegetarian_status, allergen_count/tags, trace_count/tags). Scores, flags, source provenance all inline on products. Includes `score_breakdown` (JSONB), `ingredient_data_quality`, and `nutrition_data_quality` columns. Filtered to `is_deprecated = false`. This is the primary internal query surface.

**`v_api_category_overview`** — Dashboard-ready category statistics. One row per active category (20 total). Includes product_count, avg/min/max/median score, pct_nutri_a_b, pct_nova_4, display metadata from category_ref.

**`v_product_confidence`** — Materialized view of data confidence scores for all 1,025 active products. Columns: product_id, product_name, brand, category, nutrition_pts(0-30), ingredient_pts(0-25), source_pts(0-20), ean_pts(0-10), allergen_pts(0-10), serving_pts(0-5), confidence_score(0-100), confidence_band(high/medium/low). Unique index on product_id.

---

## 5. Categories (20)

All categories have **variable product counts** (28–95 active products). Categories are expanded by running the pipeline with `--max-products N`.

| Category                   | Folder slug                 |
| -------------------------- | --------------------------- |
| Alcohol                    | `alcohol/`                  |
| Baby                       | `baby/`                     |
| Bread                      | `bread/`                    |
| Breakfast & Grain-Based    | `breakfast-grain-based/`    |
| Canned Goods               | `canned-goods/`             |
| Cereals                    | `cereals/`                  |
| Chips                      | `chips/`                    |
| Condiments                 | `condiments/`               |
| Dairy                      | `dairy/`                    |
| Drinks                     | `drinks/`                   |
| Frozen & Prepared          | `frozen-prepared/`          |
| Instant & Frozen           | `instant-frozen/`           |
| Meat                       | `meat/`                     |
| Nuts, Seeds & Legumes      | `nuts-seeds-legumes/`       |
| Plant-Based & Alternatives | `plant-based-alternatives/` |
| Sauces                     | `sauces/`                   |
| Seafood & Fish             | `seafood-fish/`             |
| Snacks                     | `snacks/`                   |
| Sweets                     | `sweets/`                   |
| Żabka                      | `zabka/`                    |

Category-to-OFF tag mappings live in `pipeline/categories.py`. Each category has multiple OFF tags and search terms for comprehensive coverage.

---

## 6. Pipeline SQL Conventions

### File Naming & Execution Order

```
PIPELINE__<category>__01_insert_products.sql   # Upsert products (must run FIRST)
PIPELINE__<category>__03_add_nutrition.sql      # Nutrition facts
PIPELINE__<category>__04_scoring.sql            # Nutri-Score + NOVA + CALL score_category()
PIPELINE__<category>__05_source_provenance.sql  # Source URLs + EANs (generated categories only)
```

**Order matters:** Products (01) must exist before nutrition (03). Scoring (04) sets Nutri-Score/NOVA data, then calls `score_category()` which computes unhealthiness, flags, and confidence. Source provenance (05) is optional and only present for pipeline-generated categories.

### Idempotency Patterns

| Operation        | Pattern                                                               |
| ---------------- | --------------------------------------------------------------------- |
| Insert product   | `INSERT ... ON CONFLICT (country, brand, product_name) DO UPDATE SET` |
| Insert nutrition | `LEFT JOIN nutrition_facts ... WHERE nf.product_id IS NULL`           |
| Update scores    | `CALL score_category('CategoryName');`                                |
| Schema change    | `IF NOT EXISTS` / `ADD COLUMN IF NOT EXISTS`                          |

### Scoring Call

Always use `score_category()` — never inline the scoring steps:

```sql
-- After setting Nutri-Score (Step 2) and NOVA (Step 3):
CALL score_category('CategoryName');
```

This procedure handles Steps 0 (default concern score), 1 (compute unhealthiness),
4 (health-risk flags + dynamic `data_completeness_pct` via `compute_data_completeness()`), and 5 (confidence). See
`20260213000800_dynamic_data_completeness.sql` for the latest implementation.

### prep_method Scoring

| Value              | Internal Score |
| ------------------ | -------------- |
| `'air-popped'`     | 20             |
| `'steamed'`        | 30             |
| `'baked'`          | 40             |
| `'not-applicable'` | 50 (default)   |
| `'none'`           | 50 (default)   |
| `'grilled'`        | 60             |
| `'smoked'`         | 65             |
| `'fried'`          | 80             |
| `'deep-fried'`     | 100            |

Additional valid values (scored as 50/default unless added to the scoring function):
`'roasted'`, `'marinated'`, `'pasteurized'`, `'fermented'`, `'dried'`, `'raw'`.

The pipeline's `_detect_prep_method()` infers these from OFF category tags and
product names (both English and Polish keywords).

**Data state:** All 1,025 active products have `prep_method` populated (0 NULLs).
14 categories use `'not-applicable'`. 5 method-sensitive categories (Bread,
Chips, Frozen & Prepared, Seafood & Fish, Snacks) use category-specific values
(`'baked'`, `'fried'`, `'smoked'`, `'marinated'`, `'not-applicable'`). Żabka uses
a mix of `'baked'`, `'fried'`, and `'none'`.

---

## 7. Migrations

**Location:** `supabase/migrations/` — managed by Supabase CLI.

**Rules:**

- **Append-only.** Never modify an existing migration file.
- **No product data.** Migrations define schema + seed metadata only.
- Prefer `IF NOT EXISTS` / `IF EXISTS` guards for idempotency.
- New changes → new file with next timestamp.

### CHECK Constraints

19 CHECK constraints enforce domain values at the DB level:

| Table             | Constraint                         | Rule                                                                                                                                                                                                |
| ----------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `products`        | `chk_products_country`             | `country IN ('PL')`                                                                                                                                                                                 |
| `products`        | `chk_products_prep_method`         | Valid method (NOT NULL): `air-popped`, `baked`, `fried`, `deep-fried`, `grilled`, `roasted`, `smoked`, `steamed`, `marinated`, `pasteurized`, `fermented`, `dried`, `raw`, `none`, `not-applicable` |
| `products`        | `chk_products_controversies`       | `IN ('none','minor','moderate','serious','palm oil')`                                                                                                                                               |
| `products`        | `chk_products_unhealthiness_range` | 1–100 (unhealthiness_score)                                                                                                         |
| `products`        | `chk_products_nutri_score_label`   | NULL or `IN ('A','B','C','D','E','UNKNOWN','NOT-APPLICABLE')`                                                       |
| `products`        | `chk_products_confidence`          | NULL or `IN ('verified','estimated','low')`                                                                                         |
| `products`          | `chk_products_nova`                  | NULL or `IN ('1','2','3','4')`                                                                                                                                                                      |
| `products`          | 4 × `chk_products_high_*_flag`       | NULL or `IN ('YES','NO')`                                                                                                                                                                           |
| `products`          | `chk_products_completeness`          | 0–100 (data_completeness_pct)                                                                                                       |
| `nutrition_facts` | `chk_nutrition_non_negative`       | All 9 nutrition columns ≥ 0                                                                                                                                                                         |
| `nutrition_facts` | `chk_nutrition_satfat_le_totalfat` | saturated_fat ≤ total_fat                                                                                                                                                                           |
| `nutrition_facts` | `chk_nutrition_sugars_le_carbs`    | sugars ≤ carbs                                                                                                                                                                                      |

### Performance Indexes

| Table      | Index Name                         | Columns / Condition                          |
| ---------- | ---------------------------------- | -------------------------------------------- |
| `products` | `products_pkey`                    | `product_id` (PK)                            |
| `products` | `products_country_brand_name_uniq` | `(country, brand, product_name)` UNIQUE      |
| `products` | `products_ean_uniq`                | `ean` UNIQUE WHERE ean IS NOT NULL           |
| `products` | `products_category_idx`            | `category`                                   |
| `products` | `products_active_idx`              | `product_id` WHERE is_deprecated IS NOT TRUE |

| `ingredient_ref` | `idx_ingredient_ref_name` | `name_en` |
| `ingredient_ref` | `idx_ingredient_ref_additive` | `ingredient_id` WHERE is_additive = true |
| `ingredient_ref` | `idx_ingredient_ref_concern` | `concern_tier` WHERE concern_tier > 0 |
| `product_ingredient` | `idx_prod_ingr_product` | `product_id` |
| `product_ingredient` | `idx_prod_ingr_ingredient` | `ingredient_id` |
| `product_ingredient` | `idx_prod_ingr_sub` | `(product_id, parent_ingredient_id)` WHERE sub |
| `product_allergen_info` | `idx_allergen_info_product` | `product_id` |
| `product_allergen_info` | `idx_allergen_info_tag_type` | `(tag, type)` |
| child tables | FK PK indexes | `product_id` (nutrition_facts, etc.) |

---

## 8. Testing & QA

| Suite                   | File                                | Checks | Blocking? |
| ----------------------- | ----------------------------------- | -----: | --------- |
| Data Integrity          | `QA__null_checks.sql`               |     29 | Yes       |
| Scoring Formula         | `QA__scoring_formula_tests.sql`     |     27 | Yes       |
| Source Coverage         | `QA__source_coverage.sql`           |      8 | No        |
| EAN Validation          | `validate_eans.py`                  |      1 | Yes       |
| API Surfaces            | `QA__api_surfaces.sql`              |     14 | Yes       |
| Confidence              | `QA__confidence_scoring.sql`        |     10 | Yes       |
| Data Quality            | `QA__data_quality.sql`              |     25 | Yes       |
| Ref. Integrity          | `QA__referential_integrity.sql`     |     18 | Yes       |
| View Consistency        | `QA__view_consistency.sql`          |     12 | Yes       |
| Naming Conventions      | `QA__naming_conventions.sql`        |     12 | Yes       |
| Nutrition Ranges        | `QA__nutrition_ranges.sql`          |     16 | Yes       |
| Data Consistency        | `QA__data_consistency.sql`          |     20 | Yes       |
| Allergen Integrity      | `QA__allergen_integrity.sql`        |     14 | Yes       |
| Serving & Source        | `QA__serving_source_validation.sql` |     16 | Yes       |
| Ingredient Quality      | `QA__ingredient_quality.sql`        |     14 | Yes       |
| **Negative Validation** | `TEST__negative_checks.sql`         |     29 | Yes       |

**Run:** `.\RUN_QA.ps1` — expects **228/228 checks passing**.
**Run:** `.\RUN_NEGATIVE_TESTS.ps1` — expects **29/29 caught**.

**Key regression tests** (in scoring suite):

- Top Chips Faliste ≈ 51 (palm oil penalty)
- Coca-Cola Zero ≈ 8 (lowest-scoring drink)
- Piątnica Skyr Naturalny ≈ 9 (healthiest dairy)
- Tarczyński Kabanosy ≈ 55 (high-fat cured meat)
- Melvit Płatki Owsiane ≈ 11 (healthiest cereal)
- BoboVita Kaszka Mleczna ≈ varies (baby food regression)
- Somersby Blueberry Cider ≈ varies (alcohol regression)
- Mestemacher Chleb wielozbożowy ≈ 19 (bread regression, baked)
- Marinero Łosoś wędzony ≈ 30 (smoked salmon regression)
- Dr. Oetker Pizza 4 sery ≈ 31 (frozen pizza regression, baked)
- Lajkonik Paluszki extra cienkie ≈ 32 (snacks regression, baked)

Run QA after **every** schema change, data update, or scoring formula adjustment.

---

## 9. Environment

| Environment         | DB URL                                                    | Studio                 |
| ------------------- | --------------------------------------------------------- | ---------------------- |
| **Local** (default) | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` | http://127.0.0.1:54323 |
| **Remote**          | Supabase project `uskvezwftkkudvksmken`                   | Supabase Dashboard     |

**Database access** (no local psql install needed):

```powershell
echo "SELECT * FROM v_master LIMIT 5;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres
```

**Python environment:**

- Virtual env: `.venv` in project root → `.\.venv\Scripts\python.exe`
- Always set `$env:PYTHONIOENCODING="utf-8"` before running (Polish characters)
- Dependencies in `requirements.txt`

---

## 10. Guardrails

- ❌ Modify existing files in `supabase/migrations/`
- ❌ Invent nutrition data or Nutri-Score values
- ❌ Add products from countries other than Poland
- ❌ Use `DELETE` or `TRUNCATE` in pipeline files — deprecate instead
- ❌ Inline the scoring formula — always call `compute_unhealthiness_v32()`
- ❌ Run pipelines against remote without explicit user confirmation
- ❌ Drop or rename tables without a new migration
- ❌ Collapse categories — each gets its own pipeline folder

---

## 11. Adding a New Category

1. Define category in `pipeline/categories.py` (name constant, OFF tags, search terms).
2. Run pipeline: `python -m pipeline.run --category "New Category" --max-products 28`.
3. Execute all generated SQL files against local DB (01, 03, 04).
4. Run `.\RUN_QA.ps1` — verify all checks pass.

**Reference implementation:** `chips/` pipeline. Copy its SQL patterns for manual work.

---

## 12. Naming Conventions

| Item            | Convention                                                  |
| --------------- | ----------------------------------------------------------- |
| Migration files | `YYYYMMDDHHMMSS_description.sql` (Supabase timestamps)      |
| Pipeline files  | `PIPELINE__<category>__<NN>_<action>.sql`                   |
| View files      | `VIEW__<name>.sql`                                          |
| QA files        | `QA__<name>.sql`                                            |
| Table names     | `snake_case`, plural (`products`, `nutrition_facts`)        |
| Column names    | `snake_case` with unit suffix (`saturated_fat_g`, `salt_g`) |

---

## 13. Git Workflow

**Branch strategy:** `main` = stable. Feature branches: `feat/`, `fix/`, `docs/`, `chore/`.

**Commit format:**

```
<type>(<scope>): <description>

feat(dairy): add Piątnica product line
fix(scoring): correct salt ceiling from 1.5 to 3.0
schema: add ean column to products
chore: normalize categories to 28 products
```

**Pre-commit checklist:**

1. `.\RUN_QA.ps1` — 228/228 pass
2. No credentials in committed files
3. No modifications to existing `supabase/migrations/`
4. Docs updated if schema or methodology changed

---

## 14. Scoring Quick Reference

```
unhealthiness_score (1-100) =
  sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
  trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
  controversies(0.08) + ingredient_concern(0.05)
```

**Ceilings** (per 100g): sat fat 10g, sugars 27g, salt 3g, trans fat 2g, calories 600 kcal, additives 10, ingredient concern 100.

| Band     | Score  | Meaning        |
| -------- | ------ | -------------- |
| Green    | 1–20   | Low risk       |
| Yellow   | 21–40  | Moderate risk  |
| Orange   | 41–60  | Elevated risk  |
| Red      | 61–80  | High risk      |
| Dark red | 81–100 | Very high risk |

Full documentation: `docs/SCORING_METHODOLOGY.md`

```

```
