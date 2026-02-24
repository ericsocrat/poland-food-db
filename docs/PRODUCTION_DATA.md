# Production Data Strategy — Phase 6

> **Last updated:** 2026-02-15
> **Status:** Comprehensive audit of production data infrastructure
> **Project:** poland-food-db (Supabase project `uskvezwftkkudvksmken`)

---

## Table of Contents

1. [Database Schema & Migrations](#1-database-schema--migrations)
2. [Data Pipelines](#2-data-pipelines)
3. [CI Configuration](#3-ci-configuration)
4. [Init / Setup Scripts](#4-init--setup-scripts)
5. [Supabase Configuration](#5-supabase-configuration)
6. [Current Data Stats](#6-current-data-stats)
7. [Backup & Restore Patterns](#7-backup--restore-patterns)
8. [Production Deployment Workflow](#8-production-deployment-workflow)
9. [Security Posture](#9-security-posture)
10. [Risk Assessment & Recommendations](#10-risk-assessment--recommendations)

---

## 1. Database Schema & Migrations

### 1.1 Project Configuration

| Setting              | Value                                                      |
| -------------------- | ---------------------------------------------------------- |
| Project ID (local)   | `poland-food-db`                                           |
| Project Ref (remote) | `uskvezwftkkudvksmken`                                     |
| DB Host (remote)     | `db.uskvezwftkkudvksmken.supabase.co`                      |
| DB Port (remote)     | `5432`                                                     |
| DB Port (local)      | `54322`                                                    |
| DB Name              | `postgres`                                                 |
| DB User              | `postgres`                                                 |
| PostgreSQL Version   | `17`                                                       |
| Pooler               | Enabled, `transaction` mode, pool size 20, max 100 clients |
| Docker Container     | `supabase_db_poland-food-db`                               |

### 1.2 Migration Inventory

**Location:** `supabase/migrations/` — **124 migration files**, append-only.

**Naming convention:** `YYYYMMDDHHMMSS_description.sql` (Supabase CLI timestamps). Files are applied in lexicographic sort order.

**Migration timeline:**

| Date Range                 | Migrations | Theme                                                                                                                         |
| -------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 2026-02-07 (000100–000501) | 6          | Schema creation, baseline, chip metadata, uniformity, scoring function                                                        |
| 2026-02-08 (000100)        | 1          | EAN column + view update                                                                                                      |
| 2026-02-09 (000100)        | 1          | Seed functions & metadata                                                                                                     |
| 2026-02-10 (000100–003100) | 22         | Major phase: dedupe, normalization, ingredients, nutrition, API surfaces, confidence, performance                             |
| 2026-02-11 (000100–000700) | 7          | Cleanup: concern reasons, secondary sources, synthetic cleanup, ingredient ref, drop columns                                  |
| 2026-02-12 (000100–000200) | 2          | Schema consolidation (merge 5 tables into fewer), scoring procedure                                                           |
| 2026-02-13 (000100–200500) | 25         | Allergens, brands, security hardening, API versioning, scale guardrails, country expansion, DE pilot, auth, category overview |
| 2026-02-14 (000100–000200) | 2          | Data confidence reporting, health profiles                                                                                    |

**Key migrations by purpose:**

| Migration                                        | Purpose                                                                                         |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| `20260207000100_create_schema.sql`               | Schema setup, `auth.uid()` function, extensions                                                 |
| `20260207000200_baseline.sql`                    | Identity columns, unique constraints, indexes                                                   |
| `20260210000600_add_check_constraints.sql`       | 24 CHECK constraints for domain enforcement                                                     |
| `20260210001300_ingredient_normalization.sql`    | 4 new tables: `ingredient_ref`, `product_ingredient`, etc.                                      |
| `20260210002800_api_surfaces.sql`                | All API views + RPC functions + `pg_trgm` search                                                |
| `20260210002900_confidence_scoring.sql`          | Composite confidence score (0–100) + materialized view                                          |
| `20260210003000_performance_guardrails.sql`      | `refresh_all_materialized_views()`, staleness check                                             |
| `20260212000100_consolidate_schema.sql`          | Major consolidation: eliminated `servings`, `product_sources`, merged allergens, inlined scores |
| `20260213001000_security_hardening.sql`          | RLS on all 9 tables, grant lockdown, `SECURITY DEFINER` on API functions                        |
| `20260213001100_api_contract_versioning.sql`     | `api_version: "1.0"` in all API responses                                                       |
| `20260213001200_scale_guardrails.sql`            | Statement timeouts (5s for API roles), limit clamping, country CHECK relaxation                 |
| `20260213001400_country_expansion_readiness.sql` | Multi-country API filtering, country-isolated alternatives/scoring                              |
| `20260213200100_add_de_country_ref.sql`          | Germany added to `country_ref` (initially inactive)                                             |
| `20260213200300_activate_de.sql`                 | Germany activated after micro-pilot validation (51 chips products)                              |
| `20260213200400_auth_only_platform.sql`          | Auth-only platform configuration                                                                |
| `20260214000200_health_profiles.sql`             | `user_health_profiles` table + CRUD RPCs + `compute_health_warnings()`                          |

### 1.3 Seed File

**`supabase/seed.sql`** is intentionally empty. All data insertion is handled by pipeline SQL files under `db/pipelines/`. The seed file exists solely to prevent `supabase db reset` from failing on a missing file reference.

### 1.4 Database Tables (10 base tables)

| Table                   | Primary Key                        | Rows (audit)         | Purpose                         |
| ----------------------- | ---------------------------------- | -------------------- | ------------------------------- |
| `products`              | `product_id` (identity)            | 1,063 (1,025 active) | Product identity, scores, flags |
| `nutrition_facts`       | `product_id`                       | 1,032                | Per-100g nutrition data         |
| `ingredient_ref`        | `ingredient_id` (identity)         | 2,740                | Canonical ingredient dictionary |
| `product_ingredient`    | `(product_id, ingredient_id, pos)` | 12,892               | Product ↔ ingredient junction   |
| `product_allergen_info` | `(product_id, tag, type)`          | 2,527                | Allergens + traces              |
| `country_ref`           | `country_code` (text)              | 2                    | PL (active), DE (active)        |
| `category_ref`          | `category` (text)                  | 20                   | Category master list            |
| `nutri_score_ref`       | `label` (text)                     | 7                    | Nutri-Score definitions         |
| `concern_tier_ref`      | `tier` (integer)                   | 4                    | EFSA ingredient concern tiers   |
| `user_preferences`      | per-user                           | per-user             | RLS-scoped preferences          |
| `user_health_profiles`  | `profile_id` (uuid)                | per-user             | Health profiles (Phase 5)       |

### 1.5 Views & Materialized Views

| View/MV                   | Type              | Purpose                                                                                                |
| ------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------ |
| `v_master`                | View              | Flat denormalized join: products → nutrition → ingredients → allergens. Primary internal query surface |
| `v_api_category_overview` | View              | Dashboard stats per category (product_count, score stats, display metadata)                            |
| `v_product_confidence`    | Materialized View | Confidence scores for all active products (unique index on `product_id`)                               |
| `mv_ingredient_frequency` | Materialized View | Ingredient frequency analytics                                                                         |

### 1.6 Key Functions & Procedures

| Function                           | Purpose                                                                                |
| ---------------------------------- | -------------------------------------------------------------------------------------- |
| `compute_unhealthiness_v32()`      | 9-factor weighted scoring formula (1–100)                                              |
| `explain_score_v32()`              | JSONB score breakdown                                                                  |
| `score_category()`                 | Consolidated scoring procedure (concern defaults → unhealthiness → flags → confidence) |
| `compute_data_confidence()`        | Composite confidence score (0-100) with 6 components                                   |
| `compute_data_completeness()`      | 15-checkpoint field-coverage function                                                  |
| `api_product_detail()`             | Single product structured JSONB                                                        |
| `api_category_listing()`           | Paged category browse with sort + pagination                                           |
| `api_search_products()`            | Full-text + trigram search (pg_trgm)                                                   |
| `api_score_explanation()`          | Human-readable score breakdown + category context                                      |
| `api_better_alternatives()`        | Healthier substitutes wrapper                                                          |
| `refresh_all_materialized_views()` | Concurrent MV refresh with timing report                                               |
| `mv_staleness_check()`             | MV freshness reporting                                                                 |
| `compute_health_warnings()`        | Per-product health warnings based on user profile                                      |

---

## 2. Data Pipelines

### 2.1 Pipeline Categories

**21 pipeline folders** under `db/pipelines/`, covering **20 logical food categories** + 1 country-variant:

| #   | Folder                      | Country | Category                   |
| --- | --------------------------- | ------- | -------------------------- |
| 1   | `alcohol/`                  | PL      | Alcohol                    |
| 2   | `baby/`                     | PL      | Baby                       |
| 3   | `bread/`                    | PL      | Bread                      |
| 4   | `breakfast-grain-based/`    | PL      | Breakfast & Grain-Based    |
| 5   | `canned-goods/`             | PL      | Canned Goods               |
| 6   | `cereals/`                  | PL      | Cereals                    |
| 7   | `chips-de/`                 | DE      | Chips (Germany)            |
| 8   | `chips-pl/`                 | PL      | Chips (Poland)             |
| 9   | `condiments/`               | PL      | Condiments                 |
| 10  | `dairy/`                    | PL      | Dairy                      |
| 11  | `drinks/`                   | PL      | Drinks                     |
| 12  | `frozen-prepared/`          | PL      | Frozen & Prepared          |
| 13  | `instant-frozen/`           | PL      | Instant & Frozen           |
| 14  | `meat/`                     | PL      | Meat                       |
| 15  | `nuts-seeds-legumes/`       | PL      | Nuts, Seeds & Legumes      |
| 16  | `plant-based-alternatives/` | PL      | Plant-Based & Alternatives |
| 17  | `sauces/`                   | PL      | Sauces                     |
| 18  | `seafood-fish/`             | PL      | Seafood & Fish             |
| 19  | `snacks/`                   | PL      | Snacks                     |
| 20  | `sweets/`                   | PL      | Sweets                     |
| 21  | `zabka/`                    | PL      | Żabka (store-specific)     |

**Countries:**
- **Poland (PL):** 20 categories, fully active, ~1,025 products
- **Germany (DE):** 1 category (chips-de, 51 products), micro-pilot activated

### 2.2 Pipeline Step Pattern

Each pipeline folder contains **4 SQL files**, executed in this exact order:

```
PIPELINE__<category>__01_insert_products.sql    # Step 1: Upsert products
PIPELINE__<category>__03_add_nutrition.sql      # Step 3: Nutrition facts
PIPELINE__<category>__04_scoring.sql            # Step 4: Nutri-Score + NOVA + score_category()
PIPELINE__<category>__05_source_provenance.sql  # Step 5: Source URLs + EANs
```

> **Note:** Step 02 was historically skipped (no separate servings step — all nutrition is per-100g).

**Step 01 — Insert Products:**
- Deprecates old products in category first (`is_deprecated = true, ean = null`)
- Releases EANs across ALL categories to prevent unique constraint conflicts
- Inserts new products with `country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean`
- Idempotent via `ON CONFLICT (country, brand, product_name) DO UPDATE SET`

**Step 03 — Add Nutrition:**
- Deletes existing nutrition facts for the category
- Inserts new per-100g nutrition data (calories, fats, carbs, sugars, fibre, protein, salt)
- Joins by `(brand, product_name)` to resolve `product_id`

**Step 04 — Scoring:**
- Sets `nutri_score_label` and `nova_classification` via VALUES lists
- Calls `CALL score_category('CategoryName')` which computes unhealthiness, flags, completeness, and confidence

**Step 05 — Source Provenance:**
- Sets `source_type = 'off_api'`, `source_url`, and `source_ean` for each product
- Uses Open Food Facts product URLs as provenance links

### 2.3 Pipeline Generation

Pipelines are generated by the Python pipeline system:

```
pipeline/
├── __main__.py         # python -m pipeline entry point
├── run.py              # CLI: --category, --max-products, --dry-run, --country
├── off_client.py       # Open Food Facts API v2 client with retry logic
├── sql_generator.py    # Generates 4 SQL files per category
├── validator.py        # Data validation before SQL generation
├── categories.py       # 20 category definitions + OFF tag mappings
└── utils.py            # Slug helpers
```

**Usage:**
```powershell
$env:PYTHONIOENCODING="utf-8"
.\.venv\Scripts\python.exe -m pipeline.run --category "Dairy" --max-products 28
.\.venv\Scripts\python.exe -m pipeline.run --category "Chips" --dry-run
```

**Data source:** Open Food Facts API v2 (`/api/v2/search`), filtered by `countries_tags_en=poland`.

**Dependencies:** `requests>=2.31,<3` and `tqdm>=4.66,<5` (from `requirements.txt`).

### 2.4 Post-Pipeline Fixup

**`db/ci_post_pipeline.sql`** handles data-state issues that arise because data-enrichment migrations reference hardcoded `product_id` values from the local environment. In CI, products get new auto-increment IDs. This script:

1. Defaults `source_type = 'off_api'` for products missing source info
2. Defaults `ingredient_concern_score = 0` where missing
3. Populates a subset of allergen declarations (chips, bread, dairy, sweets — using portable `(country, ean)` JOINs)
4. Recalculates `data_completeness_pct` and `confidence` for affected products
5. Refreshes all materialized views

---

## 3. CI Configuration

### 3.1 GitHub Actions Workflows

Three workflow files exist in `.github/workflows/`:

#### `ci.yml` — Frontend CI (Lint, Typecheck, Build, E2E)

**Triggers:** Push to `main`, pull requests to `main`.

**Environment variables (secrets):**
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

**Jobs:**
1. **lint-typecheck-build:** Node 20, `npm ci`, TypeScript check, ESLint, Next.js build
2. **playwright:** E2E tests (depends on job 1), uploads `playwright-report/` artifact (14-day retention)

#### `qa.yml` — Database QA Pipeline (358 checks)

**Triggers:** Push to `main` (paths: `db/**`, `supabase/**`, scripts, workflows), pull requests, workflow_dispatch with `fail_on_warn` input.

**Infrastructure:** Ephemeral PostgreSQL 17 service container (`postgres:postgres` credentials — CI-only), port 54322.

**Steps:**
1. Checkout + Python 3.12 setup
2. Install Python dependencies (`pip install -r requirements.txt`)
3. **Enrichment identity guard** — `python check_enrichment_identity.py` (blocks migrations that anchor rows by raw `product_id`)
4. **Pipeline structure guard** — `python check_pipeline_structure.py` (validates pipeline folders have required step files and patterns)
5. **Apply schema migrations** — iterates all `supabase/migrations/*.sql` in sort order, applies with `psql -v ON_ERROR_STOP=1`
6. **Run pipelines** — iterates all `db/pipelines/*/PIPELINE__*.sql` in sort order
7. **Post-pipeline fixup** — applies `db/ci_post_pipeline.sql`
8. **Run QA** — executes `RUN_QA.ps1 -Json -OutFile qa.json`
9. **Upload QA results** — `qa.json` artifact (30-day retention)
10. **Confidence coverage threshold** — fails if >5% of products have `confidence_band = 'low'`
11. **Generate QA summary** — markdown table in GitHub Step Summary
12. **Fail gate** — exits non-zero if QA overall = fail

**Key CI detail:** Migrations are applied via raw `psql`, NOT via `supabase db push`. No Supabase CLI is used in CI.

#### `build.yml` — Build, Test & SonarQube

**Triggers:** Push to `main`, pull requests.

**Steps:**
1. Checkout (full history for SonarQube)
2. Node 20 setup, `npm ci`
3. Type-check, lint, build
4. **Unit tests with coverage** (`npm run test:coverage`)
5. Playwright E2E tests (with placeholder Supabase env vars)
6. **SonarQube Scan** (using `SONAR_TOKEN` secret)
7. **SonarQube Quality Gate** (5-min timeout)

### 3.2 Secrets Referenced

| Secret                          | Used In   | Purpose                  |
| ------------------------------- | --------- | ------------------------ |
| `NEXT_PUBLIC_SUPABASE_URL`      | ci.yml    | Frontend Supabase URL    |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ci.yml    | Frontend anon key        |
| `SUPABASE_SERVICE_ROLE_KEY`     | ci.yml    | Service role key         |
| `SONAR_TOKEN`                   | build.yml | SonarQube authentication |

### 3.3 No Dedicated Deployment Workflow

There is **no automated deployment workflow** to push schema changes or data to the remote Supabase instance. Remote deployment is **manual** via `RUN_REMOTE.ps1`.

---

## 4. Init / Setup Scripts

### 4.1 Script Inventory

| Script                         | Purpose                                                              | Target                       |
| ------------------------------ | -------------------------------------------------------------------- | ---------------------------- |
| `RUN_LOCAL.ps1`                | Execute all pipeline SQL files against local Supabase                | Local (docker exec)          |
| `RUN_REMOTE.ps1`               | Execute all pipeline SQL files against remote Supabase               | Remote (psql)                |
| `RUN_SEED.ps1`                 | Unified seed runner — reference data + pipelines for any environment | Local / Staging / Production |
| `RUN_SANITY.ps1`               | Cross-environment sanity checks (16 checks)                          | Any environment              |
| `RUN_QA.ps1`                   | Run 25 QA test suites (362 checks)                                   | Local or CI                  |
| `RUN_NEGATIVE_TESTS.ps1`       | Run 29 negative injection tests (rollback)                           | Local                        |
| `validate_eans.py`             | EAN-8/EAN-13 checksum validation                                     | Called by RUN_QA             |
| `check_enrichment_identity.py` | Block migrations using raw `product_id` anchors                      | CI guard                     |
| `check_pipeline_structure.py`  | Validate pipeline folder structure and SQL patterns                  | CI guard                     |
| `enrich_ingredients.py`        | Ingredient enrichment utility                                        | Manual                       |
| `fetch_off_category.py`        | Fetch OFF data for a category                                        | Manual                       |

### 4.2 Database Initialization Workflow

There is no standalone `init_db_structure.py` script. Database initialization follows this deterministic path:

```
supabase db reset
  → Applies all 124 migrations in order (supabase/migrations/*.sql)
  → Runs seed.sql (empty — no-op)
  → Schema is ready

RUN_LOCAL.ps1
  → Executes all PIPELINE__*.sql files across 21 category folders
  → Refreshes materialized views
  → Optionally runs QA (-RunQA flag)
```

**Reproducibility guarantee:** `supabase db reset` + `RUN_LOCAL.ps1` = full rebuild from scratch.

### 4.3 RUN_LOCAL.ps1 Details

- **Target:** Local Supabase via `docker exec supabase_db_poland-food-db`
- **Parameters:** `-Category <name>` (single category), `-DryRun`, `-RunQA`
- **Safety:** No psql installation required (uses Docker), idempotent, safe to run repeatedly
- **Error handling:** Stops on first error to prevent cascading failures
- **Post-pipeline:** Calls `refresh_all_materialized_views()` after all SQL files complete

### 4.4 RUN_REMOTE.ps1 Details

- **Target:** Remote Supabase at `db.uskvezwftkkudvksmken.supabase.co:5432`
- **Safety features:**
  - Requires explicit `-Force` flag OR interactive "YES" confirmation
  - Displays warning banner: "⚠️ THIS MODIFIES PRODUCTION DATA"
  - Shows exact files that will be executed before prompting
  - Never runs automatically or unattended
- **Authentication:** Uses `$env:SUPABASE_DB_PASSWORD` or prompts for SecureString
- **Post-pipeline:** Applies `ci_post_pipeline.sql`, refreshes materialized views, clears password from environment
- **Parameters:** `-Category <name>`, `-DryRun`, `-Force`

### 4.5 RUN_QA.ps1 Details

- **25 test suites, 358 total checks** (up from 278/18 earlier in project)
- **Modes:** Human-readable (default), `-Json` (machine-readable), `-OutFile <path>`, `-FailOnWarn`
- **Database connection abstraction:** Auto-detects CI mode (`PGHOST` set → psql) vs. local mode (docker exec)
- **Suite 3 (Source Coverage):** Non-blocking/informational — does not fail the run
- **Output JSON structure:** `{ timestamp, version, suites[], summary, inventory, overall }`
- **Inventory query:** Reports active products, deprecated, nutrition rows, ingredient refs, product ingredients, allergens, traces, categories
- **Exit codes:** 0 (pass), 1 (fail), 2 (warnings with `-FailOnWarn`)

---

## 5. Supabase Configuration

### 5.1 Full Config Analysis (`supabase/config.toml`)

**API:**
- Port 54321, schemas `["public", "graphql_public"]`, max 1000 rows per response
- TLS disabled locally

**Database:**
- PostgreSQL 17, port 54322, shadow port 54320
- Pooler: transaction mode, pool size 20, max 100 clients
- Migrations enabled, seed enabled (`./seed.sql`)
- Network restrictions disabled (allow all IPv4/IPv6)

**Auth:**
- Enabled, site URL `http://127.0.0.1:3000`
- JWT expiry: 3600s (1 hour), refresh token rotation enabled
- Signup enabled, anonymous sign-ins disabled
- Email: signup enabled, double-confirm changes, no confirmation required
- SMTP: commented out (local uses inbucket for email testing)
- MFA: disabled (TOTP + phone + WebAuthn all off)
- External OAuth: all disabled (Apple, etc.)
- Web3: disabled

**Storage:**
- Enabled, 50 MiB max file size, S3 protocol enabled
- Analytics and vector storage disabled

**Edge Runtime:**
- Enabled, `per_worker` policy, Deno 2, inspector port 8083

**Analytics:**
- Enabled, port 54327, PostgreSQL backend

### 5.2 Environment Variables

**`.env.example`** (project root):
```
SUPABASE_DB_PASSWORD=         # Remote DB password (used by RUN_REMOTE.ps1)
SUPABASE_PROJECT_REF=         # Remote project ref (for supabase link)
```

**`frontend/.env.local.example`**:
```
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

**No `.env` files committed** — `.env` is git-ignored per the example comment.

### 5.3 Supabase CLI Usage Patterns

- **`supabase db reset`** — Full rebuild (migrations + seed)
- **`supabase start`** — Start local containers (prerequisite for `RUN_LOCAL.ps1`)
- **`supabase link --project-ref uskvezwftkkudvksmken`** — Link to remote project (noted in `RUN_REMOTE.ps1`)
- **No `supabase db push` in CI** — migrations are applied via raw `psql` in the QA workflow
- **No `supabase migration` commands in CI** — all migrations are pre-generated files

---

## 6. Current Data Stats

### 6.1 Product Inventory (from Table Audit 2026-02-12)

| Metric                | Count                     |
| --------------------- | ------------------------- |
| Total products        | 1,063                     |
| Active products       | 1,025                     |
| Deprecated products   | 38                        |
| Active categories     | 20                        |
| Active countries      | 2 (PL, DE)                |
| Country PL products   | ~974 (20 categories)      |
| Country DE products   | 51 (chips-de micro-pilot) |
| Products per category | 9–98 (variable)           |

### 6.2 Related Data

| Table                   | Rows                                    |
| ----------------------- | --------------------------------------- |
| `nutrition_facts`       | 1,032                                   |
| `ingredient_ref`        | 2,740 unique ingredients                |
| `product_ingredient`    | 12,892 associations                     |
| `product_allergen_info` | 2,527 (1,218 allergens + 1,309 traces)  |
| `category_ref`          | 20 categories                           |
| `country_ref`           | 2 entries (PL active, DE active)        |
| `nutri_score_ref`       | 7 labels (A–E, UNKNOWN, NOT-APPLICABLE) |
| `concern_tier_ref`      | 4 tiers (0–3 EFSA classification)       |

### 6.3 Data Quality Metrics

- **EAN coverage:** 997/1,025 (97.3%)
- **Scoring version:** v3.2 — 9-factor weighted formula
- **QA checks:** 358 checks across 25 suites — all passing
- **Negative tests:** 29 injection tests — all caught
- **Confidence threshold (CI):** ≤5% low-confidence products allowed
- **CHECK constraints:** 24 domain constraints enforced at DB level
- **42 named constraints** all validated (`convalidated = true`)
- **Foreign keys:** All structurally valid

### 6.4 Data Source

- **Primary source:** Open Food Facts API v2 (off_api)
- **Source type distribution:** All 1,025 active products are `source_type = 'off_api'`
- **Source hierarchy:** Physical label > Manufacturer website > Government DB > OFF > Retailer > Scientific literature > Category averages
- **Confidence levels:** `verified`, `estimated`, `low` — assigned by `assign_confidence()` based on data completeness + source type

### 6.5 Test Data vs Production Data

There is **no separation** between test and production data at the data layer. The same pipeline SQL files populate both local and remote databases. Differences arise from:

- **Local:** Auto-increment IDs start fresh on `supabase db reset`
- **CI:** Ephemeral PostgreSQL container, migrations applied then pipelines run — same data, different IDs
- **Remote (production):** `RUN_REMOTE.ps1` executes the same SQL files, products get persistent IDs
- **`ci_post_pipeline.sql`** bridges gaps where enrichment migrations used hardcoded `product_id` values

---

## 7. Backup & Restore Patterns

### 7.1 Current State

**No dedicated backup infrastructure exists.** There are:

- **No `pg_dump` scripts** in the repository
- **No automated backup workflows** in GitHub Actions
- **No Supabase Dashboard backup references** in documentation
- **No data export tooling** or snapshot scripts
- **No point-in-time recovery (PITR) configuration** documented

### 7.2 Implicit Backup via Reproducibility

The project's architecture provides an **implicit backup mechanism**:

```
Backup = supabase/migrations/*.sql + db/pipelines/*.sql
```

Since the database can be fully reconstructed from:
1. 124 migration files (schema + functions + views)
2. 21 × 4 pipeline SQL files (all product data)
3. `ci_post_pipeline.sql` (data fixups)

This means the **Git repository itself is the backup**. However, this does NOT cover:
- User-generated data (`user_preferences`, `user_health_profiles`)
- Auto-increment ID stability (IDs differ between rebuilds)
- Runtime state (materialized view freshness, etc.)

### 7.3 Supabase Platform Backups

Supabase hosted projects include:
- **Daily automated backups** (depending on plan tier)
- **Point-in-time recovery** (Pro plan and above)
- **Database dumps** via Supabase Dashboard

These are platform-managed and not controlled by this repository.

### 7.4 Recommendations

1. **Add a `pg_dump` script** for on-demand logical backups before remote deployments
2. **Document Supabase backup tier** — confirm which plan features are available
3. **Add user data export** — `user_preferences` and `user_health_profiles` are not reproducible from pipelines
4. **Pre-deployment snapshot** — `RUN_REMOTE.ps1` should optionally dump before executing

---

## 8. Production Deployment Workflow

### 8.1 Current Deployment Process

**Frontend:** Deployed to Vercel from `frontend/` directory.

| Setting         | Value      |
| --------------- | ---------- |
| Root Directory  | `frontend` |
| Framework       | Next.js    |
| Build Command   | Auto       |
| Install Command | `npm ci`   |

**Required Vercel env vars:**
- `NEXT_PUBLIC_SUPABASE_URL` (e.g., `https://uskvezwftkkudvksmken.supabase.co`)
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

**Database (schema):** Applied via `supabase db push` or `supabase link` + manual migration application. No automated deployment workflow.

**Database (data):** Manual execution of `RUN_REMOTE.ps1` with explicit confirmation.

### 8.2 Deployment Sequence

```
1. Develop locally (supabase start → RUN_LOCAL.ps1 → RUN_QA.ps1)
2. Commit & push to main
3. CI runs: build.yml (frontend) + qa.yml (database QA against ephemeral PG)
4. If CI passes:
   a. Schema changes: supabase link → supabase db push (manual)
   b. Data changes: RUN_REMOTE.ps1 (manual, requires confirmation)
   c. Frontend: Vercel auto-deploys from main
5. Verify via Supabase Dashboard
```

### 8.3 Auth Flow (Production)

```
User signs up → Supabase sends confirmation email
  → User clicks link → /auth/callback (exchanges code for session)
  → Redirect to /app/search
  → App layout checks onboarding_complete
  → If false → /onboarding/region → /onboarding/preferences → /app/search
```

Supabase Auth URL configuration required:
- Site URL: production domain
- Redirect URLs: `https://<domain>/auth/callback`
- Preview deployments: wildcard redirect URL for Vercel previews

---

## 9. Security Posture

### 9.1 Database Security

- **RLS enabled** on all 9 data tables with read-only policies
- **Write privileges revoked** from `anon`/`authenticated` on all tables and sequences
- **Only `service_role` and `postgres` can write data**
- **6 `api_*` functions** marked as `SECURITY DEFINER` (run as owner)
- **Internal functions** (`compute_*`, `find_*`, `refresh_*`) not callable by anonymous users
- **Default privileges** reset so future objects get minimal grants
- **Statement timeouts:** 5s for `anon`/`authenticated`/`authenticator` roles
- **Idle transaction timeout:** 30s for API roles

### 9.2 Credential Management

- Database password: `$env:SUPABASE_DB_PASSWORD` or interactive SecureString prompt
- Password cleared from environment after `RUN_REMOTE.ps1` execution
- No credentials in committed files (`.env` is git-ignored)
- CI uses ephemeral `postgres:postgres` credentials (clearly marked as non-production)
- SonarQube configured for security scanning

### 9.3 API Security

- API version field (`api_version: "1.0"`) in all API responses
- `api_better_alternatives p_limit` clamped to 1–20
- Max 1000 rows per API response (`config.toml`)
- Open-redirect prevention in login form (only relative paths starting with `/`)

---

## 10. Risk Assessment & Recommendations

### 10.1 Strengths

1. **Fully reproducible database** from Git repository (migrations + pipelines)
2. **Comprehensive QA** (358 checks, 29 negative tests, CI-enforced)
3. **Idempotent pipelines** — safe to re-run any number of times
4. **Strong security hardening** — RLS, grant lockdown, SECURITY DEFINER
5. **Multi-country architecture** ready (PL active, DE micro-pilot)
6. **Pipeline structure guards** prevent malformed data entry
7. **Enrichment identity guards** prevent non-portable migrations
8. **Confidence scoring** tracks data quality at the product level

### 10.2 Risks & Gaps

| Risk                                         | Severity | Mitigation                                                                 |
| -------------------------------------------- | -------- | -------------------------------------------------------------------------- |
| No automated remote deployment               | Medium   | `RUN_REMOTE.ps1` is manual; add CI deployment workflow                     |
| No backup scripts                            | High     | Add `pg_dump` pre-deployment; document Supabase backup tier                |
| User data not reproducible                   | Medium   | `user_preferences` and `user_health_profiles` lost on rebuild              |
| No schema diff validation                    | Medium   | CI applies migrations to ephemeral PG, but doesn't validate against remote |
| `product_id` instability across environments | Low      | CI post-pipeline fixup handles this; consider EAN-based canonical IDs      |
| Manual Supabase auth URL config              | Low      | Document and verify after each domain change                               |
| No monitoring/alerting                       | Medium   | Add MV staleness monitoring, row count ceiling alerts                      |
| Country CHECK constraint removed             | Low      | FK to `country_ref` enforces validity; activation gating via `is_active`   |
| 5% CI confidence threshold vs 1% prod target | Low      | CI threshold is higher due to artificial data gaps; document target        |

### 10.3 Recommended Next Steps

1. **Add `pg_dump` wrapper** to `RUN_REMOTE.ps1` (pre-deployment snapshot)
2. **Create `BACKUP.ps1`** for on-demand remote database backups
3. **Add GitHub Actions deployment workflow** for schema migrations (`supabase db push`)
4. **Document Supabase plan tier** and available backup features (PITR, etc.)
5. **Add user data export/import** tooling for `user_preferences` and `user_health_profiles`
6. **Add monitoring** for materialized view staleness and row count ceilings
7. **Consider EAN-based canonical keys** to eliminate `product_id` instability across environments
8. **Add rollback documentation** — steps to revert a bad deployment
9. **Create staging environment** — intermediate Supabase project for pre-production validation
