```instructions
# Copilot Instructions — Poland Food Quality Database

> **Last updated:** 2026-02-10
> **Scope:** Poland (`PL`) only — no other countries active
> **Products:** 560 active (20 categories × 28 each), deprecated products purged
> **EAN coverage:** 558/560 (99.6%)
> **Scoring:** v3.2 — 9-factor weighted formula via `compute_unhealthiness_v32()` (added ingredient concern scoring)
> **Servings:** 877 rows — 560 per-100g (canonical) + 317 per-serving (57% real serving size coverage)
> **Ingredient analytics:** 1,257 unique ingredients (all clean ASCII English), 728 allergen declarations, 782 trace declarations
> **Ingredient concerns:** EFSA-based 4-tier additive classification (0=none, 1=low, 2=moderate, 3=high)
> **QA:** 61 critical checks + 12 informational reports — all passing

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
(categories_tags_en, off_client.py 01_insert_products servings
countries_tags_en=poland) sql_generator.py 02_add_servings nutrition_facts
validator.py 03_add_nutrition scores
categories.py 04_scoring ingredients

````

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
│   │   └── ... (19 more)            # All normalized to 28 active products
│   ├── qa/                          # Test suites
│   │   ├── QA__null_checks.sql      # 32 data integrity checks + 4 informational
│   │   ├── QA__scoring_formula_tests.sql  # 29 scoring validation checks
│   │   └── QA__source_coverage.sql  # 8 informational reports (non-blocking)
│   └── views/
│       └── VIEW__master_product_view.sql  # v_master definition (reference copy)
├── supabase/
│   ├── config.toml
│   └── migrations/                  # 32 append-only schema migrations
│       ├── 20260207000100_create_schema.sql
│       ├── 20260207000200_baseline.sql
│       ├── 20260207000300_add_chip_metadata.sql
│       ├── 20260207000400_data_uniformity.sql
│       ├── 20260207000401_remove_unused_columns.sql
│       ├── 20260207000500_column_metadata.sql
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
│       └── 20260210002000_update_confidence.sql             # Confidence verified/estimated from completeness
│       └── 20260210002100_vmaster_ingredient_data_quality.sql # Add ingredient_data_quality column to v_master
├── docs/
│   ├── SCORING_METHODOLOGY.md       # v3.2 algorithm (9 factors, ceilings, bands)
│   ├── DATA_SOURCES.md              # Source hierarchy & validation workflow
│   ├── RESEARCH_WORKFLOW.md         # Data collection lifecycle
│   ├── VIEWING_AND_TESTING.md       # Queries, Studio UI, test runner
│   ├── COUNTRY_EXPANSION_GUIDE.md   # Future multi-country protocol
│   ├── UX_UI_DESIGN.md              # UI/UX guidelines
│   ├── EAN_VALIDATION_STATUS.md     # 558/560 coverage (99.6%)
│   └── EAN_EXPANSION_PLAN.md        # Completed
├── RUN_LOCAL.ps1                    # Pipeline runner (idempotent)
├── RUN_QA.ps1                       # QA test runner (61 critical + 10 info)
├── RUN_REMOTE.ps1                   # Remote deployment (requires confirmation)
├── validate_eans.py                 # EAN-8/EAN-13 checksum validator (called by RUN_QA)
├── populate_ingredient_data.py      # OFF API → ingredient_ref/product_ingredient/allergens/traces
├── .env.example
└── README.md
```

---

## 4. Database Schema

### Tables

| Table                | Purpose                                      | Primary Key                             | Notes                                                                                                 |
| -------------------- | -------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `products`           | Product identity (brand, name, EAN)          | `product_id` (identity)                 | Upsert key: `(country, brand, product_name)`                                                          |
| `servings`           | Serving definitions (per 100g + per serving) | `serving_id` (identity)                 | FK → products; 560 per-100g + 317 per-serving (57% coverage)                                          |
| `nutrition_facts`    | Nutrition per product+serving                | `(product_id, serving_id)`              | Numeric columns (calories, fat, sugar…)                                                               |
| `scores`             | Computed health scores + flags               | `product_id`                            | Generated by `compute_unhealthiness_v32()`; includes `ingredient_concern_score`                       |
| `ingredients`        | Raw ingredient text + additive count         | `product_id`                            | `additives_count` synced from junction table; `ingredients_raw` in English (493/560 = 88%)            |
| `ingredient_ref`     | Canonical ingredient dictionary              | `ingredient_id` (identity)              | 1,257 unique ingredients; taxonomy_id (OFF), vegan/vegetarian/palm_oil/is_additive/concern_tier flags |
| `product_ingredient` | Product ↔ ingredient junction                | `(product_id, ingredient_id, position)` | 7,435 rows; tracks percent, percent_estimate, sub-ingredients, position order                         |
| `product_allergen`   | Declared allergens per product               | `(product_id, allergen_tag)`            | 728 rows across 347 products (62% coverage); source: OFF allergens_tags                               |
| `product_trace`      | Declared traces per product                  | `(product_id, trace_tag)`               | 782 rows across 250 products (45% coverage); source: OFF traces_tags                                  |
| `sources`            | Data provenance per category                 | `source_id`                             | 20 rows (one per category); joined via `category`                                                     |
| `column_metadata`    | Data dictionary for all tables               | `(table_name, column_name)`             | UI tooltips, type info, examples                                                                      |

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

| Function                      | Purpose                                                                                                                     |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `compute_unhealthiness_v32()` | Scores 1–100 from 9 factors: sat fat, sugars, salt, calories, trans fat, additives, prep, controversies, ingredient concern |
| `assign_confidence()`         | Returns `'verified'`/`'estimated'`/`'low'` from data completeness                                                           |

### View

**`v_master`** — Flat denormalized join: products → servings → nutrition_facts → scores → ingredients → sources (via `category` equijoin) + ingredient analytics via LATERAL subqueries (ingredient_count, additive_names, has_palm_oil, vegan_status, vegetarian_status, allergen_count/tags, trace_count/tags). Includes computed `ingredient_data_quality` column (`'complete'`/`'partial'`/`'missing'`). Filtered to `is_deprecated = false`. This is the primary query surface.

---

## 5. Categories (20)

All categories normalized to **28 active products** each. Excess products are deprecated and periodically purged.

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
PIPELINE__<category>__02_add_servings.sql       # Serving definitions
PIPELINE__<category>__03_add_nutrition.sql      # Nutrition facts
PIPELINE__<category>__04_scoring.sql            # Scores + flags + Nutri-Score + NOVA
```

**Order matters:** Products (01) must exist before servings (02) and nutrition (03). Scoring (04) creates score/ingredient rows if missing, then computes all values.

### Idempotency Patterns

| Operation        | Pattern                                                               |
| ---------------- | --------------------------------------------------------------------- |
| Insert product   | `INSERT ... ON CONFLICT (country, brand, product_name) DO UPDATE SET` |
| Insert serving   | `LEFT JOIN servings ... WHERE s.serving_id IS NULL`                   |
| Insert nutrition | `LEFT JOIN nutrition_facts ... WHERE nf.product_id IS NULL`           |
| Insert score row | `LEFT JOIN scores ... WHERE sc.product_id IS NULL`                    |
| Update scores    | `UPDATE scores ... FROM products ... WHERE ...`                       |
| Schema change    | `IF NOT EXISTS` / `ADD COLUMN IF NOT EXISTS`                          |

### Scoring Call

Always use the function — never inline the formula:

```sql
unhealthiness_score = compute_unhealthiness_v32(
    nf.saturated_fat_g::numeric, nf.sugars_g::numeric, nf.salt_g::numeric,
    nf.calories::numeric, nf.trans_fat_g::numeric, i.additives_count::numeric,
    p.prep_method, p.controversies, sc.ingredient_concern_score
)::text
```

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

**Data state:** All 560 active products have `prep_method` populated (0 NULLs).
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

| Table             | Constraint                               | Rule                                                                                                                                                                                                |
| ----------------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `products`        | `chk_products_country`                   | `country IN ('PL')`                                                                                                                                                                                 |
| `products`        | `chk_products_prep_method`               | Valid method (NOT NULL): `air-popped`, `baked`, `fried`, `deep-fried`, `grilled`, `roasted`, `smoked`, `steamed`, `marinated`, `pasteurized`, `fermented`, `dried`, `raw`, `none`, `not-applicable` |
| `products`        | `chk_products_controversies`             | `IN ('none','minor','moderate','serious','palm oil')`                                                                                                                                               |
| `scores`          | `chk_scores_unhealthiness_range`         | 1–100                                                                                                                                                                                               |
| `scores`          | `chk_scores_nutri_score_label`           | NULL or `IN ('A','B','C','D','E','UNKNOWN','NOT-APPLICABLE')`                                                                                                                                       |
| `scores`          | `chk_scores_confidence`                  | NULL or `IN ('verified','estimated','low')`                                                                                                                                                         |
| `scores`          | `chk_scores_nova`                        | NULL or `IN ('1','2','3','4')`                                                                                                                                                                      |
| `scores`          | `chk_scores_processing_risk`             | NULL or `IN ('Low','Moderate','High')`                                                                                                                                                              |
| `scores`          | 4 × `chk_scores_high_*_flag`             | NULL or `IN ('YES','NO')`                                                                                                                                                                           |
| `scores`          | `chk_scores_completeness`                | 0–100                                                                                                                                                                                               |
| `nutrition_facts` | `chk_nutrition_non_negative`             | All 9 nutrition columns ≥ 0                                                                                                                                                                         |
| `nutrition_facts` | `chk_nutrition_satfat_le_totalfat`       | saturated_fat ≤ total_fat                                                                                                                                                                           |
| `nutrition_facts` | `chk_nutrition_sugars_le_carbs`          | sugars ≤ carbs                                                                                                                                                                                      |
| `servings`        | `chk_servings_basis`                     | `IN ('per 100 g','per 100 ml','per piece','per serving')`                                                                                                                                           |
| `servings`        | `chk_servings_amount_positive`           | serving_amount > 0                                                                                                                                                                                  |
| `ingredients`     | `chk_ingredients_additives_non_negative` | additives_count ≥ 0                                                                                                                                                                                 |

### Performance Indexes

| Table                | Index Name                         | Columns / Condition                                |
| -------------------- | ---------------------------------- | -------------------------------------------------- |
| `products`           | `products_pkey`                    | `product_id` (PK)                                  |
| `products`           | `products_country_brand_name_uniq` | `(country, brand, product_name)` UNIQUE            |
| `products`           | `products_ean_uniq`                | `ean` UNIQUE WHERE ean IS NOT NULL                 |
| `products`           | `products_category_idx`            | `category`                                         |
| `products`           | `products_active_idx`              | `product_id` WHERE is_deprecated IS NOT TRUE       |
| `sources`            | `sources_category_idx`             | `category`                                         |
| `ingredient_ref`     | `idx_ingredient_ref_name`          | `name_en`                                          |
| `ingredient_ref`     | `idx_ingredient_ref_additive`      | `ingredient_id` WHERE is_additive = true           |
| `ingredient_ref`     | `idx_ingredient_ref_concern`       | `concern_tier` WHERE concern_tier > 0              |
| `product_ingredient` | `idx_prod_ingr_product`            | `product_id`                                       |
| `product_ingredient` | `idx_prod_ingr_ingredient`         | `ingredient_id`                                    |
| `product_ingredient` | `idx_prod_ingr_sub`                | `(product_id, parent_ingredient_id)` WHERE sub     |
| `product_allergen`   | `idx_allergen_tag`                 | `allergen_tag`                                     |
| `product_trace`      | `idx_trace_tag`                    | `trace_tag`                                        |
| child tables         | FK PK indexes                      | `product_id` (scores, ingredients, servings, etc.) |

---

## 8. Testing & QA

| Suite           | File                            | Checks | Blocking? |
| --------------- | ------------------------------- | -----: | --------- |
| Data Integrity  | `QA__null_checks.sql`           |     32 | Yes       |
| Scoring Formula | `QA__scoring_formula_tests.sql` |     29 | Yes       |
| Source Coverage | `QA__source_coverage.sql`       |      8 | No        |
| EAN Validation  | `validate_eans.py`              |    all | Yes       |

**Run:** `.\RUN_QA.ps1` — expects **61/61 critical checks passing**.

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
3. Execute all generated SQL files against local DB.
4. Insert a `sources` row for provenance tracking.
5. Register the folder in `RUN_LOCAL.ps1` and `RUN_REMOTE.ps1`.
6. Add at least one regression test to `QA__scoring_formula_tests.sql`.
7. Run `.\RUN_QA.ps1` — verify 61/61 pass.

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

1. `.\RUN_QA.ps1` — 61/61 pass
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
