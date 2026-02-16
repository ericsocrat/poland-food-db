# Copilot Instructions — Poland Food Quality Database

> **Last updated:** 2026-02-17
> **Scope:** Poland (`PL`) primary + Germany (`DE`) micro-pilot (51 Chips products)
> **Products:** ~1,076 active (20 PL categories + 1 DE category), 38 deprecated
> **EAN coverage:** 997/1,025 (97.3%)
> **Scoring:** v3.2 — 9-factor weighted formula via `compute_unhealthiness_v32()` (added ingredient concern scoring)
> **Servings:** removed as separate table — all nutrition data is per-100g on nutrition_facts
> **Ingredient analytics:** 2,740 unique ingredients (all clean ASCII English), 1,218 allergen declarations, 1,304 trace declarations
> **Ingredient concerns:** EFSA-based 4-tier additive classification (0=none, 1=low, 2=moderate, 3=high)
> **QA:** 360 checks across 24 suites + 29 negative validation tests — all passing

---

## 1. Role & Principles

You are a **food scientist, nutrition researcher, and senior data engineer** maintaining a science-driven food quality database for products sold in Poland.

**Core principles:**

- **Never invent data.** Use real EU label values only.
- **Never guess Nutri-Score.** Compute from nutrition or cite official sources.
- **Idempotent everything.** Every SQL file safe to run 1× or 100×.
- **Reproducible setup.** `supabase db reset` + pipelines = full rebuild.
- **Country-scoped.** PL is primary; DE micro-pilot active (51 Chips). All queries are country-filtered. See `docs/COUNTRY_EXPANSION_GUIDE.md`.
- **Every change must be tested.** No code ships without corresponding tests. See §8.

---

## 2. Architecture & Data Flow

````

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
│   ├── __init__.py                  # Package init
│   ├── __main__.py                  # `python -m pipeline` entry point
│   ├── run.py                       # CLI: --category, --max-products, --dry-run
│   ├── off_client.py                # OFF API v2 client with retry logic
│   ├── sql_generator.py             # Generates 4-5 SQL files per category
│   ├── validator.py                 # Data validation before SQL generation
│   ├── utils.py                     # Shared utility helpers
│   └── categories.py               # 20 category definitions + OFF tag mappings
├── db/
│   ├── pipelines/                   # 21 category folders (20 PL + 1 DE), 4-5 SQL files each
│   │   ├── chips-pl/                # Reference PL implementation (copy for new categories)
│   │   ├── chips-de/                # Germany micro-pilot (51 products)
│   │   └── ... (19 more PL)         # Variable product counts per category
│   ├── qa/                          # Test suites
│   │   ├── QA__null_checks.sql      # 29 data integrity checks
│   │   ├── QA__scoring_formula_tests.sql  # 27 scoring validation checks
│   │   ├── QA__api_surfaces.sql     # 18 API surface validation checks
│   │   ├── QA__api_contract.sql     # 30 API contract checks
│   │   ├── QA__confidence_scoring.sql  # 10 confidence scoring checks
│   │   ├── QA__confidence_reporting.sql # 7 confidence reporting checks
│   │   ├── QA__data_quality.sql          # 25 data quality checks
│   │   ├── QA__data_consistency.sql      # 20 data consistency checks
│   │   ├── QA__referential_integrity.sql # 18 referential integrity checks
│   │   ├── QA__view_consistency.sql      # 13 view consistency checks
│   │   ├── QA__naming_conventions.sql    # 12 naming convention checks
│   │   ├── QA__nutrition_ranges.sql      # 16 nutrition range checks
│   │   ├── QA__allergen_integrity.sql    # 14 allergen integrity checks
│   │   ├── QA__allergen_filtering.sql    # 6 allergen filtering checks
│   │   ├── QA__serving_source_validation.sql # 16 serving & source checks
│   │   ├── QA__ingredient_quality.sql    # 14 ingredient quality checks
│   │   ├── QA__security_posture.sql      # 22 security posture checks
│   │   ├── QA__scale_guardrails.sql      # 15 scale guardrails checks
│   │   ├── QA__country_isolation.sql     # 6 country isolation checks
│   │   ├── QA__diet_filtering.sql        # 6 diet filtering checks
│   │   ├── QA__barcode_lookup.sql        # 6 barcode scanner checks
│   │   ├── QA__auth_onboarding.sql       # 8 auth & onboarding checks
│   │   ├── QA__health_profiles.sql       # 14 health profile checks
│   │   ├── QA__source_coverage.sql  # 8 informational reports (non-blocking)
│   │   └── TEST__negative_checks.sql     # 29 negative validation tests
│   └── views/
│       └── VIEW__master_product_view.sql  # v_master definition (reference copy)
├── supabase/
│   ├── config.toml
│   └── migrations/                  # 83 append-only schema migrations
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
│       ├── 20260210003100_multi_source_cross_validation.sql # Multi-source cross validation
│       ├── 20260211*                                         # (7 migrations: concern reasons, secondary sources, cleanup)
│       ├── 20260212*                                         # (2 migrations: schema consolidation, score_category procedure)
│       ├── 20260213000100–001700                             # (17 migrations: allergen/ingredient QA, brand normalization,
│       │                                                     #  dynamic completeness, security hardening, API versioning,
│       │                                                     #  scale guardrails, country expansion readiness,
│       │                                                     #  user_preferences + scanner, auto-country resolution)
│       ├── 20260213200100–200500                             # (5 migrations: DE country ref, activate DE, auth-only platform,
│       │                                                     #  api_category_overview fix)
│       ├── 20260214000100_data_confidence_reporting.sql      # Data confidence reporting
│       ├── 20260214000200_health_profiles.sql                # user_health_profiles table
│       ├── 20260215000100_health_profile_hardening.sql       # Profile hardening
│       ├── 20260215141000–144000                             # (4 migrations: ingredient/allergen enrichment, dedup, inference)
│       ├── 20260215150000_product_lists.sql                  # user_product_lists + user_product_list_items
│       ├── 20260215160000_product_list_membership.sql        # List membership API
│       ├── 20260215170000_product_comparisons.sql            # user_comparisons table
│       ├── 20260215180000_enhanced_search.sql                # user_saved_searches + tsvector search
│       └── 20260215200000_scanner_enhancements.sql           # scan_history + product_submissions
├── docs/
│   ├── SCORING_METHODOLOGY.md       # v3.2 algorithm (9 factors, ceilings, bands)
│   ├── API_CONTRACTS.md             # API surface contracts (6 endpoints) — response shapes, hidden columns
│   ├── PERFORMANCE_REPORT.md        # Performance audit, scale projections, query patterns
│   ├── DATA_SOURCES.md              # Source hierarchy & validation workflow
│   ├── DATA_ACQUISITION_WORKFLOW.md # Data collection pipeline
│   ├── RESEARCH_WORKFLOW.md         # Data collection lifecycle
│   ├── VIEWING_AND_TESTING.md       # Queries, Studio UI, test runner
│   ├── COUNTRY_EXPANSION_GUIDE.md   # Multi-country protocol (PL active, DE micro-pilot)
│   ├── UX_UI_DESIGN.md              # UI/UX guidelines
│   ├── FRONTEND_API_MAP.md          # Frontend ↔ API mapping reference
│   ├── ENVIRONMENT_STRATEGY.md      # Local/staging/production environment strategy
│   ├── STAGING_SETUP.md             # Staging environment setup
│   ├── PRODUCTION_DATA.md           # Production data management
│   ├── FULL_PROJECT_AUDIT.md        # Comprehensive project audit
│   ├── TABLE_AUDIT_2026-02-12.md    # Table-level audit snapshot
│   ├── EAN_VALIDATION_STATUS.md     # 997/1,025 coverage (97.3%)
│   ├── EAN_EXPANSION_PLAN.md        # Completed
│   ├── SECURITY.md                  # Security policy & practices
│   └── SONAR.md                     # SonarCloud configuration & quality gates
├── RUN_LOCAL.ps1                    # Pipeline runner (idempotent)
├── RUN_QA.ps1                       # QA test runner (360 checks across 24 suites)
├── RUN_NEGATIVE_TESTS.ps1           # Negative test runner (29 injection tests)
├── RUN_SANITY.ps1                   # Sanity checks (16) — row counts, schema assertions
├── RUN_REMOTE.ps1                   # Remote deployment (requires confirmation)
├── RUN_SEED.ps1                     # Seed data runner
├── validate_eans.py                 # EAN-8/EAN-13 checksum validator (called by RUN_QA)
├── check_pipeline_structure.py      # Pipeline folder/file structure validator
├── check_enrichment_identity.py     # Enrichment migration identity guard
├── enrich_ingredients.py            # OFF API → ingredient/allergen migration SQL generator
├── fetch_off_category.py            # OFF API → pipeline SQL generator (standalone)
├── frontend/
│   ├── src/
│   │   ├── middleware.ts                # Next.js middleware (auth redirects)
│   │   ├── lib/                     # Shared utilities, API clients, types
│   │   │   ├── supabase/            # Supabase client (client.ts, server.ts, middleware.ts)
│   │   │   ├── *.ts                 # Source modules (api, rpc, types, constants, validation, query-keys)
│   │   │   └── *.test.ts            # Co-located unit tests (Vitest)
│   │   ├── hooks/                   # TanStack Query hooks
│   │   │   ├── use-compare.ts       # Product comparison queries & mutations
│   │   │   └── use-lists.ts         # Product list queries & mutations (CRUD, reorder, share)
│   │   ├── stores/                  # Zustand stores (client-side state)
│   │   │   ├── avoid-store.ts       # Avoided product IDs
│   │   │   ├── compare-store.ts     # Comparison basket state
│   │   │   └── favorites-store.ts   # Favorite product IDs
│   │   ├── components/              # React components
│   │   │   ├── common/              # Shared UI (ConfirmDialog, CountryChip, LoadingSpinner, RouteGuard)
│   │   │   ├── compare/             # Comparison grid (ComparisonGrid, CompareCheckbox, ShareComparison)
│   │   │   ├── product/             # Product detail (AddToListMenu, AvoidBadge, HealthWarningsCard, ListsHydrator)
│   │   │   ├── search/              # Search UI (SearchAutocomplete, FilterPanel, ActiveFilterChips, SaveSearchDialog)
│   │   │   ├── settings/            # Settings UI (HealthProfileSection)
│   │   │   ├── layout/              # Layout components
│   │   │   ├── Providers.tsx         # Root providers (QueryClient, Supabase, Zustand)
│   │   │   └── **/*.test.tsx        # Co-located component tests (Vitest + Testing Library)
│   │   ├── app/                     # Next.js App Router pages
│   │   │   ├── layout.tsx           # Root layout
│   │   │   ├── page.tsx             # Landing page
│   │   │   ├── auth/                # Auth flow (login, callback)
│   │   │   ├── onboarding/          # Onboarding flow (region, preferences)
│   │   │   ├── compare/shared/[token]/ # Public shared comparison view
│   │   │   ├── lists/shared/[token]/   # Public shared list view
│   │   │   ├── contact/, privacy/, terms/ # Static pages
│   │   │   └── app/                 # Authenticated app shell
│   │   │       ├── categories/      # Category listing + [slug] detail
│   │   │       ├── product/[id]/    # Product detail page
│   │   │       ├── scan/            # Barcode scanner + history + submissions
│   │   │       ├── search/          # Search + saved searches
│   │   │       ├── compare/         # Comparison + saved comparisons
│   │   │       ├── lists/           # Product lists + [id] detail
│   │   │       ├── settings/        # User settings (health profile, preferences)
│   │   │       └── admin/           # Admin panel (submission review)
│   │   ├── styles/                  # Global CSS / Tailwind
│   │   └── __tests__/setup.ts       # Vitest global setup
│   ├── e2e/                         # Playwright E2E tests
│   │   ├── smoke.spec.ts            # Public page smoke tests
│   │   ├── authenticated.spec.ts    # Auth-gated flow tests
│   │   ├── auth.setup.ts            # Auth fixture setup
│   │   ├── global-teardown.ts       # Test teardown
│   │   └── helpers/test-user.ts     # Test user provisioning
│   ├── vitest.config.ts             # Vitest configuration (jsdom, v8 coverage)
│   ├── playwright.config.ts         # Playwright configuration (Chromium)
│   └── package.json                 # Dependencies + scripts (test, test:coverage, etc.)
├── .github/workflows/
│   ├── ci.yml                       # Lint → Typecheck → Build → Playwright E2E
│   ├── build.yml                    # Build → Unit tests + coverage → SonarCloud
│   ├── qa.yml                       # Schema → Pipelines → QA (360) → Sanity (16)
│   └── sync-cloud-db.yml            # Remote DB sync
├── sonar-project.properties         # SonarCloud configuration
├── DEPLOYMENT.md                    # Deployment procedures
├── SECURITY.md                      # Security policy
├── .env.example
└── README.md
```

---

## 4. Database Schema

### Tables

| Table                   | Purpose                                     | Primary Key                             | Notes                                                                                                                                     |
| ----------------------- | ------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `products`              | Product identity, scores, flags, provenance | `product_id` (identity)                 | Upsert key: `(country, brand, product_name)`. Scores, flags, source columns all inline.                                                   |
| `nutrition_facts`       | Nutrition per product (per 100g)            | `product_id`                            | Numeric columns (calories, fat, sugar…)                                                                                                   |
| `ingredient_ref`        | Canonical ingredient dictionary             | `ingredient_id` (identity)              | 2,740 unique ingredients; name_en, vegan/vegetarian/palm_oil/is_additive/concern_tier flags                                               |
| `product_ingredient`    | Product ↔ ingredient junction               | `(product_id, ingredient_id, position)` | ~12,892 rows across 859 products; tracks percent, percent_estimate, sub-ingredients, position order                                       |
| `product_allergen_info` | Allergens + traces per product (unified)    | `(product_id, tag, type)`               | ~2,527 rows (1,218 allergens + 1,309 traces) across 655 products; type IN ('contains','traces'); source: OFF allergens_tags / traces_tags |
| `country_ref`           | ISO 3166-1 alpha-2 country codes            | `country_code` (text PK)                | 2 rows (PL, DE); is_active flag; FK from products.country                                                                                 |
| `category_ref`          | Product category master list                | `category` (text PK)                    | 20 rows; FK from products.category; display_name, description, icon_emoji, sort_order                                                     |
| `nutri_score_ref`       | Nutri-Score label definitions               | `label` (text PK)                       | 7 rows (A–E + UNKNOWN + NOT-APPLICABLE); FK from scores.nutri_score_label; color_hex, description                                         |
| `concern_tier_ref`      | EFSA ingredient concern tiers               | `tier` (integer PK)                     | 4 rows (0–3); FK from ingredient_ref.concern_tier; score_impact, examples, EFSA guidance                                                  |
| `user_preferences`      | User personalization (country, diet, allergens) | `user_id` (FK → auth.users)           | One row per user; diet enum, allergen arrays, strict_mode flags; RLS by user                                                              |
| `user_health_profiles`  | Health condition profiles                   | `profile_id` (identity)                 | Conditions + nutrient thresholds (sodium, sugar, sat fat limits). One active profile per user. RLS by user                                |
| `user_product_lists`    | User-created product lists                  | `list_id` (identity)                    | Name, description, share_token, is_public. Default lists: Favorites, Avoid. RLS by user                                                   |
| `user_product_list_items`| Items in product lists                     | `(list_id, product_id)`                 | sort_order, notes. FK to user_product_lists + products. RLS by user                                                                       |
| `user_comparisons`      | Saved product comparisons                   | `comparison_id` (identity)              | product_ids array (2-4), share_token, title. RLS by user                                                                                  |
| `user_saved_searches`   | Saved search queries                        | `search_id` (identity)                  | Query text, filters JSONB, notification preferences. RLS by user                                                                          |
| `scan_history`          | Barcode scan history                        | `scan_id` (identity)                    | user_id, ean, scanned_at, product_id (if matched). RLS by user                                                                           |
| `product_submissions`   | User-submitted products                     | `submission_id` (identity)              | ean, product_name, brand, photo_url, status ('pending'/'approved'/'rejected'). Admin-reviewable                                           |

### Products Columns (key)

| Column               | Type      | Notes                                                                      |
| -------------------- | --------- | -------------------------------------------------------------------------- |
| `product_id`         | `bigint`  | Auto-incrementing identity                                                 |
| `country`            | `text`    | `'PL'` or `'DE'` — FK to country_ref                                      |
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

| Function                           | Purpose                                                                                                                                                   |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `compute_unhealthiness_v32()`      | Scores 1–100 from 9 factors: sat fat, sugars, salt, calories, trans fat, additives, prep, controversies, ingredient concern                               |
| `explain_score_v32()`              | Returns JSONB breakdown of score: final_score + 9 factors with name, weight, raw (0–100), weighted, input, ceiling                                        |
| `find_similar_products()`          | Top-N products by Jaccard ingredient similarity (returns product details + similarity coefficient)                                                        |
| `find_better_alternatives()`       | Healthier substitutes in same/any category, ranked by score improvement and ingredient overlap                                                            |
| `assign_confidence()`              | Returns `'verified'`/`'estimated'`/`'low'` from data completeness                                                                                         |
| `score_category()`                 | Consolidated scoring procedure: Steps 0/1/4/5 (concern defaults, unhealthiness, flags + dynamic `data_completeness_pct`, confidence) for a given category |
| `compute_data_confidence()`        | Composite confidence score (0-100) with 6 components; band, completeness profile                                                                          |
| `compute_data_completeness()`      | Dynamic 15-checkpoint field-coverage function for `data_completeness_pct` (EAN, 9 nutrition, Nutri-Score, NOVA, ingredients, allergens, source)           |
| `api_data_confidence()`            | API wrapper for compute_data_confidence(); returns structured JSONB                                                                                       |
| `api_product_detail()`             | Single product as structured JSONB (identity, scores, flags, nutrition, ingredients, allergens, trust)                                                    |
| `api_category_listing()`           | Paged category listing with sort (score\|calories\|protein\|name\|nutri_score) + pagination                                                               |
| `api_score_explanation()`          | Score breakdown + human-readable headline + warnings + category context (rank, avg, relative position)                                                    |
| `api_better_alternatives()`        | Healthier substitutes wrapper with source product context and structured JSON                                                                             |
| `api_search_products()`            | Full-text + trigram search across product_name and brand; uses pg_trgm GIN indexes                                                                        |
| `refresh_all_materialized_views()` | Refreshes all MVs concurrently; returns timing report JSONB                                                                                               |
| `mv_staleness_check()`             | Checks if MVs are stale by comparing row counts to source tables                                                                                          |

### Views

**`v_master`** — Flat denormalized join: products → nutrition_facts + ingredient analytics via LATERAL subqueries on product_ingredient + ingredient_ref (ingredient_count, additive_names, ingredients_raw, has_palm_oil, vegan_status, vegetarian_status, allergen_count/tags, trace_count/tags). Scores, flags, source provenance all inline on products. Includes `score_breakdown` (JSONB), `ingredient_data_quality`, and `nutrition_data_quality` columns. Filtered to `is_deprecated = false`. This is the primary internal query surface.

**`v_api_category_overview`** — Dashboard-ready category statistics. One row per active category (20 total). Includes product_count, avg/min/max/median score, pct_nutri_a_b, pct_nova_4, display metadata from category_ref.

**`v_product_confidence`** — Materialized view of data confidence scores for all active products. Columns: product_id, product_name, brand, category, nutrition_pts(0-30), ingredient_pts(0-25), source_pts(0-20), ean_pts(0-10), allergen_pts(0-10), serving_pts(0-5), confidence_score(0-100), confidence_band(high/medium/low). Unique index on product_id.

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
| Chips (PL)                 | `chips-pl/`                 |
| Chips (DE)                 | `chips-de/`                 |
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

**21 pipeline folders** (20 PL + 1 DE). Category-to-OFF tag mappings live in `pipeline/categories.py`. Each category has multiple OFF tags and search terms for comprehensive coverage.

---

## 6. Pipeline SQL Conventions

### File Naming & Execution Order

```
PIPELINE__<category>__01_insert_products.sql   # Upsert products (must run FIRST)
PIPELINE__<category>__03_add_nutrition.sql      # Nutrition facts
PIPELINE__<category>__04_scoring.sql            # Nutri-Score + NOVA + CALL score_category()
PIPELINE__<category>__05_source_provenance.sql  # Source URLs + EANs (pipeline-generated categories)
```

**Order matters:** Products (01) must exist before nutrition (03). Scoring (04) sets Nutri-Score/NOVA data, then calls `score_category()` which computes unhealthiness, flags, and confidence. Source provenance (05) is generated by the pipeline and contains OFF API source URLs + EANs.

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

**Data state:** All active products have `prep_method` populated (0 NULLs).
14 categories use `'not-applicable'`. 5 method-sensitive categories (Bread,
Chips, Frozen & Prepared, Seafood & Fish, Snacks) use category-specific values
(`'baked'`, `'fried'`, `'smoked'`, `'marinated'`, `'not-applicable'`). Żabka uses
a mix of `'baked'`, `'fried'`, and `'none'`.

---

## 7. Migrations

**Location:** `supabase/migrations/` — managed by Supabase CLI. Currently **83 migrations**.

**Rules:**

- **Append-only.** Never modify an existing migration file.
- **No product data.** Migrations define schema + seed metadata only.
- Prefer `IF NOT EXISTS` / `IF EXISTS` guards for idempotency.
- New changes → new file with next timestamp.

### CHECK Constraints

24 CHECK constraints enforce domain values at the DB level:

| Table                   | Constraint                         | Rule                                                                                                                                                                                                |
| ----------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `products`              | `chk_products_country`             | `country IN ('PL','DE')` — matches active country_ref entries                                                                                                                                       |
| `products`              | `chk_products_prep_method`         | Valid method (NOT NULL): `air-popped`, `baked`, `fried`, `deep-fried`, `grilled`, `roasted`, `smoked`, `steamed`, `marinated`, `pasteurized`, `fermented`, `dried`, `raw`, `none`, `not-applicable` |
| `products`              | `chk_products_controversies`       | `IN ('none','minor','moderate','serious','palm oil')`                                                                                                                                               |
| `products`              | `chk_products_unhealthiness_range` | 1–100 (unhealthiness_score)                                                                                                                                                                         |
| `products`              | `chk_products_nutri_score_label`   | NULL or `IN ('A','B','C','D','E','UNKNOWN','NOT-APPLICABLE')`                                                                                                                                       |
| `products`              | `chk_products_confidence`          | NULL or `IN ('verified','estimated','low')`                                                                                                                                                         |
| `products`              | `chk_products_nova`                | NULL or `IN ('1','2','3','4')`                                                                                                                                                                      |
| `products`              | 4 × `chk_products_high_*_flag`     | NULL or `IN ('YES','NO')`                                                                                                                                                                           |
| `products`              | `chk_products_completeness`        | 0–100 (data_completeness_pct)                                                                                                                                                                       |
| `products`              | `chk_products_source_type`         | NULL or `IN ('off_api','manual','off_search','csv_import')`                                                                                                                                         |
| `nutrition_facts`       | `chk_nutrition_non_negative`       | All 9 nutrition columns ≥ 0                                                                                                                                                                         |
| `nutrition_facts`       | `chk_nutrition_satfat_le_totalfat` | saturated_fat ≤ total_fat                                                                                                                                                                           |
| `nutrition_facts`       | `chk_nutrition_sugars_le_carbs`    | sugars ≤ carbs                                                                                                                                                                                      |
| `ingredient_ref`        | `chk_concern_tier_range`           | concern_tier 0–3                                                                                                                                                                                    |
| `ingredient_ref`        | `chk_palm_oil_values`              | contains_palm_oil IN ('yes','no','maybe')                                                                                                                                                           |
| `ingredient_ref`        | `chk_vegan_values`                 | vegan IN ('yes','no','maybe')                                                                                                                                                                       |
| `ingredient_ref`        | `chk_vegetarian_values`            | vegetarian IN ('yes','no','maybe')                                                                                                                                                                  |
| `product_allergen_info` | `product_allergen_info_type_check` | type IN ('contains','traces')                                                                                                                                                                       |
| `product_ingredient`    | `chk_percent_range`                | percent BETWEEN 0 AND 100                                                                                                                                                                           |
| `product_ingredient`    | `chk_percent_estimate_range`       | percent_estimate BETWEEN 0 AND 100                                                                                                                                                                  |
| `product_ingredient`    | `chk_sub_has_parent`               | NOT is_sub OR parent_ingredient_id IS NOT NULL                                                                                                                                                      |

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

## 8. Testing & QA (NON-NEGOTIABLE)

A change is **not done** unless relevant tests were added/updated, every suite is green, and coverage/quality gates are not degraded. This applies to every code change — no exceptions.

### 8.1 Testing Stack & Architecture

| Layer               | Tool                                              | Location                                     | Runner                               |
| ------------------- | ------------------------------------------------- | -------------------------------------------- | ------------------------------------ |
| Unit tests          | **Vitest 4.x** (jsdom, v8 coverage)               | `frontend/src/**/*.test.{ts,tsx}` co-located | `cd frontend && npx vitest run`      |
| Component tests     | **Testing Library React** + Vitest                | `frontend/src/components/**/*.test.tsx`      | same as above                        |
| E2E smoke           | **Playwright 1.58** (Chromium)                    | `frontend/e2e/smoke.spec.ts`                 | `cd frontend && npx playwright test` |
| E2E auth            | Playwright (requires `SUPABASE_SERVICE_ROLE_KEY`) | `frontend/e2e/authenticated.spec.ts`         | same (CI auto-detects key)           |
| DB QA (360 checks)  | Raw SQL (zero rows = pass)                        | `db/qa/QA__*.sql` (24 suites)                | `.\RUN_QA.ps1`                       |
| Negative validation | SQL injection/constraint tests                    | `db/qa/TEST__negative_checks.sql`            | `.\RUN_NEGATIVE_TESTS.ps1`           |
| DB sanity           | Row-count + schema assertions                     | via `RUN_SANITY.ps1`                         | `.\RUN_SANITY.ps1 -Env local`        |
| Pipeline structure  | Python validator                                  | `check_pipeline_structure.py`                | `python check_pipeline_structure.py` |
| EAN checksum        | Python validator                                  | `validate_eans.py`                           | `python validate_eans.py`            |
| Code quality        | **SonarCloud**                                    | `sonar-project.properties`                   | CI only (build.yml)                  |

**Coverage** is collected via `npm run test:coverage` (v8 provider, LCOV output at `frontend/coverage/lcov.info`), fed to SonarCloud. Coverage exclusions are declared in both `vitest.config.ts` and `sonar-project.properties`.

### 8.2 Always Discover Existing Patterns First

Before writing or changing **any** code:

1. Search the repo for existing tests covering the area you're touching and follow the established style.
2. Prefer extending existing test files over inventing new patterns.
3. Locate how tests run in CI (GitHub Actions workflows in `.github/workflows/`) and locally (scripts), and align with that.

### 8.3 Every Code Change Must Include Tests

For **any** functional change:

- Add or update tests covering:
  - **Happy path** — expected normal behavior.
  - **Edge cases** — boundary values, empty inputs, unicode, null.
  - **Error/validation paths** — invalid inputs, permission failures, missing data.
  - **Regression** — for bug fixes, add a test that would have caught the bug.
- If you add a feature flag, filter, profile option, or API parameter: test ON/OFF behavior.
- If you touch database logic/migrations: add QA checks that validate schema + expected query behavior.

### 8.4 Test Conventions (must follow)

#### Vitest unit/component tests

- Use `describe()` + `it()` blocks (not `test()`). Descriptions in plain English.
- Import `{ describe, it, expect, vi, beforeEach }` from `"vitest"`.
- Use `@/` path alias for imports (e.g., `@/lib/api`, `@/components/common/RouteGuard`).
- Mock modules with `vi.mock("@/lib/module", () => ({ ... }))`.
- Clear mocks in `beforeEach` with `vi.clearAllMocks()`.
- Component tests: wrap in `QueryClientProvider` via a `createWrapper()` helper with `{ retry: false, staleTime: 0 }`.
- Assertions: `expect(...).toEqual()`, `.toHaveBeenCalledWith()`, `.toBeTruthy()`, `.toBeVisible()`.
- Use ASCII-art section dividers (`// ─── Section ───`) to group test blocks.
- Setup file: `frontend/src/__tests__/setup.ts` (imports `@testing-library/jest-dom/vitest`).

#### Playwright E2E tests

- Use `test.describe()` + `test()` (not `it()`).
- Import `{ test, expect }` from `@playwright/test` only.
- No mocks — tests run against a live dev server at `http://localhost:3000`.
- Locators: prefer `page.locator("text=...")`, `page.getByRole(...)`, CSS selectors.
- Assertions: `expect(page).toHaveTitle(...)`, `expect(locator).toBeVisible()`.
- Auth-protected routes: assert redirect via `page.waitForURL(/\/auth\/login/)`.
- Smoke tests go in `e2e/smoke.spec.ts`; authenticated flows in `e2e/authenticated.spec.ts`.

#### Database QA SQL

- Each check is a numbered `SELECT` returning violation rows. **Zero rows = pass.**
- Include `'ISSUE LABEL' AS issue` and a `detail` column for human-readable output.
- Separate sections with `-- ═══...` ASCII dividers and numbered titles.
- Header comment states total check count and purpose (e.g., `-- 29 checks`).
- Add checks to existing suite files; only create a new `QA__*.sql` suite if the domain is genuinely new.

### 8.5 Coverage & Quality Gates Must Not Regress

- **Never reduce** overall coverage or weaken assertions.
- Prefer strong assertions (specific outputs, types, error codes, DB row counts) over snapshot-only tests.
- If coverage tooling exists (`npm run test:coverage`), ensure new code paths are covered.
- If a change makes coverage impossible, **refactor to make it testable** (pure functions, dependency injection, smaller modules).
- SonarCloud Quality Gate must pass. Do not lower thresholds, delete checks, or skip suites to make failures disappear.

### 8.6 Update QA Checks When Needed

If you add new constraints (validation rule, EAN rules, scoring rule, CHECK constraint):

- Add/extend the corresponding QA check(s) in `db/qa/` so the rule is enforced.
- Update check count in header comments and this document only if the total changes.
- Keep totals consistent across `copilot-instructions.md`, `RUN_QA.ps1` output, and `qa.yml` job name.

### 8.7 Run Commands and Report Results

Before finalizing any change:

1. Run the **full impacted suite** locally (same entrypoint CI uses).
2. If the full suite is too heavy, run the impacted subset **and explain why**.
3. In your response, include:
   - Commands executed
   - Pass/fail status
   - Key output summaries (counts, durations, suite names)

**Minimum validation per change type:**

| Change type            | Commands to run                                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Frontend component/lib | `cd frontend && npx tsc --noEmit && npx vitest run`                                                                 |
| Frontend + UI flow     | above + `npx playwright test --project=smoke`                                                                       |
| Database schema/SQL    | `python check_pipeline_structure.py`, then `.\RUN_QA.ps1`                                                           |
| Scoring/nutrition      | `.\RUN_QA.ps1` (covers scoring regression tests)                                                                    |
| Python pipeline code   | `python -c "import py_compile; py_compile.compile('file.py', doraise=True)"` + `python check_pipeline_structure.py` |
| Full stack             | all of the above                                                                                                    |

### 8.8 Test Placement Rules

| Area                               | Test location                                         | Level                  |
| ---------------------------------- | ----------------------------------------------------- | ---------------------- |
| `frontend/src/lib/*.ts`            | Co-located `*.test.ts` in same dir                    | Unit                   |
| `frontend/src/components/**/*.tsx` | Co-located `*.test.tsx` in same dir                   | Unit / Component       |
| API routes / RPC wrappers          | `frontend/src/lib/rpc.test.ts` or `api.test.ts`       | Unit (mocked Supabase) |
| UI flows & navigation              | `frontend/e2e/smoke.spec.ts`                          | E2E                    |
| Auth-gated flows                   | `frontend/e2e/authenticated.spec.ts`                  | E2E                    |
| DB schema & constraints            | `db/qa/QA__*.sql` suites                              | DB QA                  |
| Scoring formula                    | `db/qa/QA__scoring_formula_tests.sql`                 | DB regression          |
| Pipeline SQL structure             | `check_pipeline_structure.py`                         | Python validator       |
| Bug fixes                          | Add regression test in the appropriate location above | Same as area           |

### 8.9 Determinism (Flake Prevention)

All tests **must** be deterministic:

- **No live network calls.** Mock external APIs (`vi.mock()` for OFF API, Supabase).
- **No time-dependent assertions** without freezing time (`vi.useFakeTimers()`).
- **No randomness** without seeding.
- **No dependency on local machine state** (port availability, file system, env vars).
- If unavoidable, mock/stub and document why.
- Use local test DB / fixtures as per repo conventions.

E2E tests are the **only** exception — they run against a live dev server but use Playwright's retry and timeout mechanisms.

### 8.10 CI Parity (Don't "Green Locally, Red in CI")

- Use the **same entrypoints** CI uses (`.github/workflows/ci.yml`, `build.yml`, `qa.yml`).
- If a test needs env vars, provide defaults in test setup (not in CI-only secrets).
- If you add a new dependency/tool, ensure it's installed in CI (`package.json` or `requirements.txt`).
- CI workflows:
  - **`ci.yml`**: Lint → Typecheck → Build → Playwright E2E
  - **`build.yml`**: Lint → Typecheck → Build → Unit tests with coverage → Playwright → SonarCloud scan + Quality Gate
  - **`qa.yml`**: Pipeline structure guard → Schema migrations → Pipelines → QA (360 checks) → Sanity (16 checks) → Confidence threshold

### 8.11 Test Plan Required (Before Coding)

Before implementing a non-trivial change, write a short **Test Plan**:

- **What** should be tested (bullet list)
- **Where** the tests will live (file paths)
- **What level** (unit / component / integration / e2e / DB QA)
  Then implement code + tests accordingly. Skip this for trivial one-line fixes.

### 8.12 Contract Tests for APIs & RPC

When modifying any API route or Supabase RPC wrapper:

- Add tests that assert the **API contract**:
  - Status codes / return types
  - Response schema/fields
  - Error shapes (type, message)
  - Auth requirements (anon vs authenticated)
- If a shared TypeScript type or Zod schema exists, assert against it.
- Existing patterns: `frontend/src/lib/rpc.test.ts` (38 tests), `frontend/src/lib/api.test.ts` (8 tests).

### 8.13 Database Safety Rules

If adding/changing DB schema or SQL functions:

- **Append-only migrations.** Never modify an existing `supabase/migrations/` file.
- Provide a migration plan and rollback note (comment in the migration file).
- Add a QA check that verifies the migration outcome (row counts, constraint behavior).
- Ensure idempotency (`IF NOT EXISTS`, `ON CONFLICT`, `DO UPDATE SET`).
- Run `.\RUN_QA.ps1` to verify all 360 checks pass + `.\RUN_NEGATIVE_TESTS.ps1` for 29 injection tests.

### 8.14 Snapshots Are Not Enough

Do not rely solely on snapshot tests for logic-heavy changes. Snapshots are only allowed for:

- Stable UI rendering (component structure)
- Large response payloads

But they **must** be paired with explicit assertions on key fields/values.

### 8.15 Refactors: Maintain Behavior and Prove It

For refactors:

1. **Lock behavior** — ensure existing tests pass before refactoring. If no tests exist, add characterization tests first.
2. **Refactor** — make the structural change.
3. **Prove no regression** — all tests must still pass with zero changes to assertions.
4. Validate with `python -c "import py_compile; py_compile.compile('file.py', doraise=True)"` for Python, `npx tsc --noEmit` for TypeScript.

### 8.16 Don't Weaken Gates to Fix Failures

**Never** "fix" a failure by:

- Lowering coverage or quality thresholds
- Deleting or skipping checks/suites
- Widening assertion tolerances without justification
- Removing `ON_ERROR_STOP` or `set -euo pipefail`

Only do this if explicitly requested **and** with a clear written justification.

### 8.17 Verification Output

At the end of every PR-like change, include a **Verification** section:

- **Commands run** (with output)
- **Results summary** (pass/fail, counts)
- **New/updated tests** listed
- **QA check changes** listed (if any)

### 8.18 DB QA Suites Reference

| Suite                   | File                                | Checks | Blocking? |
| ----------------------- | ----------------------------------- | -----: | --------- |
| Data Integrity          | `QA__null_checks.sql`               |     29 | Yes       |
| Scoring Formula         | `QA__scoring_formula_tests.sql`     |     27 | Yes       |
| Source Coverage          | `QA__source_coverage.sql`           |      8 | No        |
| EAN Validation          | `validate_eans.py`                  |      1 | Yes       |
| API Surfaces            | `QA__api_surfaces.sql`              |     18 | Yes       |
| API Contract            | `QA__api_contract.sql`              |     30 | Yes       |
| Confidence Scoring      | `QA__confidence_scoring.sql`        |     10 | Yes       |
| Confidence Reporting    | `QA__confidence_reporting.sql`      |      7 | Yes       |
| Data Quality            | `QA__data_quality.sql`              |     25 | Yes       |
| Ref. Integrity          | `QA__referential_integrity.sql`     |     18 | Yes       |
| View Consistency        | `QA__view_consistency.sql`          |     13 | Yes       |
| Naming Conventions      | `QA__naming_conventions.sql`        |     12 | Yes       |
| Nutrition Ranges        | `QA__nutrition_ranges.sql`          |     16 | Yes       |
| Data Consistency        | `QA__data_consistency.sql`          |     20 | Yes       |
| Allergen Integrity      | `QA__allergen_integrity.sql`        |     14 | Yes       |
| Allergen Filtering      | `QA__allergen_filtering.sql`        |      6 | Yes       |
| Serving & Source        | `QA__serving_source_validation.sql` |     16 | Yes       |
| Ingredient Quality      | `QA__ingredient_quality.sql`        |     14 | Yes       |
| Security Posture        | `QA__security_posture.sql`          |     22 | Yes       |
| Scale Guardrails        | `QA__scale_guardrails.sql`          |     15 | Yes       |
| Country Isolation       | `QA__country_isolation.sql`         |      6 | Yes       |
| Diet Filtering          | `QA__diet_filtering.sql`            |      6 | Yes       |
| Barcode Lookup          | `QA__barcode_lookup.sql`            |      6 | Yes       |
| Auth & Onboarding       | `QA__auth_onboarding.sql`           |      8 | Yes       |
| Health Profiles         | `QA__health_profiles.sql`           |     14 | Yes       |
| **Negative Validation** | `TEST__negative_checks.sql`         |     29 | Yes       |

**Run:** `.\RUN_QA.ps1` — expects **360/360 checks passing** (+ EAN validation).
**Run:** `.\RUN_NEGATIVE_TESTS.ps1` — expects **29/29 caught**.

### 8.19 Key Regression Tests (Scoring Suite)

These are **anchor products** whose scores must remain stable. If a scoring change causes drift beyond ±2 points, investigate before committing:

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
- ❌ Add products from countries not in `country_ref` (currently PL and DE only)
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

**Reference implementation:** `chips-pl/` pipeline. Copy its SQL patterns for manual work.

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

1. `.\RUN_QA.ps1` — 360/360 pass
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
