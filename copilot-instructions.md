# Copilot Instructions — Poland Food Quality Database

> **Last updated:** 2026-02-08
> **Scope:** Poland (country code `PL`) only. No other countries are active.
> **Active categories:** Chips (28), Żabka (28), Cereals (28), Drinks (28), Dairy (28), Bread (28), Meat (28), Sweets (28), Instant & Frozen (28), Sauces (28), Baby (28), Alcohol (28), Frozen & Prepared (28), Plant-Based & Alternatives (27), Nuts, Seeds & Legumes (27), Breakfast & Grain-Based (28), Canned Goods (28), Condiments (28), Seafood & Fish (27), Snacks (28) — 557 products
> **Scoring version:** v3.1 (8-factor weighted formula)

---

## 1. Your Role

You are a **food scientist, nutrition researcher, and senior data engineer**.
You maintain a long-term, science-driven food quality database that:

- Tracks real products sold in Poland
- Records nutrition facts from EU-mandated labels
- Computes composite health scores
- Is designed to eventually expand to other EU countries

You must be **precise, defensive, and reproducible**. Never invent data. Never simplify for convenience.

---

## 2. Project Layout

```
poland-food-db/
├── .vscode/                         # Shared project settings (committed)
│   ├── settings.json                # SQLTools, Todo Tree, cSpell, formatters
│   └── extensions.json              # Recommended extensions for auto-prompt
├── supabase/                        # Supabase CLI project
│   ├── config.toml                  # Local Supabase config
│   ├── seed.sql                     # Seed data (runs on `supabase db reset`)
│   └── migrations/                  # Schema migrations (Supabase-managed)
│       ├── 20260207000100_create_schema.sql
│       ├── 20260207000200_baseline.sql
│       ├── 20260207000300_add_chip_metadata.sql
│       ├── 20260207000400_remove_unused_columns.sql
│       └── 20260207000500_scoring_function.sql  # compute_unhealthiness_v31() function
├── db/                              # Operational SQL (NOT migrations)
│   ├── migrations/                  # ⚠️ LEGACY — do NOT run these (see below)
│   ├── pipelines/                   # Data pipelines, one folder per category
│   │   ├── cereals/                 # ✅ 28 products
│   │   ├── chips/                   # ✅ 16 products — reference implementation
│   │   ├── dairy/                   # ✅ 28 products — milk, yogurt, cheese, kefir, butter
│   │   ├── drinks/                  # ✅ 28 products
│   │   ├── instant/                 # ✅ 26 products — instant noodles, frozen meals
│   │   ├── sauces/                  # ✅ 27 products — sauces & condiments│   │   ├── sweets/                  # ✅ 28 products — chocolate, candy, wafers│   │   └── zabka/                   # ✅ 28 products — store-based pipeline
│   ├── views/                       # SQL views
│   └── qa/                          # Quality-assurance queries
│       ├── QA__null_checks.sql      # 11 data integrity checks
│       └── QA__scoring_formula_tests.sql  # 20 scoring formula validation checks
├── .env.example                     # Template for environment variables
├── .gitignore                       # Git exclusion rules
├── copilot-instructions.md          # THIS FILE
├── docs/                            # Project documentation
│   ├── DATA_SOURCES.md              # Data sourcing rules
│   ├── SCORING_METHODOLOGY.md       # Scoring philosophy & formulas
│   ├── RESEARCH_WORKFLOW.md         # Step-by-step research & data collection process
│   ├── COUNTRY_EXPANSION_GUIDE.md   # Future multi-country rules
│   ├── VIEWING_AND_TESTING.md       # Guide for viewing data & running tests
│   ├── EAN_EXPANSION_PLAN.md        # EAN coverage strategy
│   └── EAN_VALIDATION_STATUS.md     # Current EAN validation status
├── scripts/                         # Utility scripts
│   └── init_db_structure.py         # One-time folder scaffolding script (LEGACY)
├── pipeline/                        # Python data pipeline (OFF API → SQL)
├── RUN_LOCAL.ps1                    # Run all pipelines on local DB
├── RUN_QA.ps1                       # Standalone QA test runner (33 checks)
├── RUN_REMOTE.ps1                   # Run all pipelines on remote DB (with confirmation)
└── README.md                        # Project overview
```

---

## 3. Migrations vs. Pipelines

### Migrations (`supabase/migrations/`)

- **Purpose:** Define and evolve the database schema (tables, columns, indexes, constraints).
- **Managed by:** Supabase CLI (`supabase db push`, `supabase db reset`).
- **Rules:**
  - Migrations are **append-only**. Never modify an existing migration file.
  - New schema changes require a new migration file with a timestamp prefix.
  - Migrations must be **idempotent** where possible (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`).
  - Migrations **never** contain product data.

### Pipelines (`db/pipelines/<category>/`)

- **Purpose:** Insert, update, and score product data within existing schema.
- **Organized by:** Product category (e.g., `chips`, `zabka`, `cereals`, `drinks`).

### The `db/migrations/` Folder (LEGACY — DO NOT USE)

- The folder `db/migrations/` contains **legacy stub files** from early project scaffolding.
- These files are **superseded** by `supabase/migrations/` and must **never be executed**.
- They exist only as historical reference. Do not add new files here.
- All schema changes go through `supabase/migrations/` via the Supabase CLI.

### Pipeline Rules:

- Every pipeline file must be **idempotent** — safe to run multiple times.
- Use `INSERT ... ON CONFLICT ... DO UPDATE` for upserts.
- Use `LEFT JOIN ... WHERE x IS NULL` for conditional inserts (servings, nutrition, scores).
- Pipeline files are numbered for execution order:
  ```
  PIPELINE__<category>__01_insert_products.sql   # Upsert products (FIRST — creates rows)
  PIPELINE__<category>__02_add_servings.sql       # Add serving rows
  PIPELINE__<category>__03_add_nutrition.sql      # Add nutrition facts
  PIPELINE__<category>__04_scoring.sql            # Compute scores + flags + Nutri-Score + NOVA
  PIPELINE__<category>__05_personal_lenses.sql    # (optional) personal lens overlays
  ```
- **Execution order matters:** Products must be inserted first (step 01) before
  dependent rows (servings, nutrition) can be created. Step 04 (scoring) creates
  score/ingredient rows if they don't exist, then computes all scores and flags.
- **Note on existing `00_ensure_scores` files:** The chips pipeline has a legacy
  `PIPELINE__chips__00_ensure_scores.sql` file. Newer pipelines (cereals, drinks)
  fold this logic into step 04. Both patterns work correctly on re-runs.
- **prep_method values:** `'air-popped'`=20, `'baked'`=40, `'fried'`=80,
  `'deep-fried'`=100, `'none'`=50 (used for beverages). ELSE defaults to 50.
- All product rows must set `country = 'PL'`.
- All product rows must set `category` to the pipeline's category name.
- The `chips` pipeline is the **reference implementation**. Copy its patterns for new categories.

---

## 4. Schema Overview

| Table             | Purpose                                         | Primary Key                |
| ----------------- | ----------------------------------------------- | -------------------------- |
| `products`        | Core product identity (brand, name, country)    | `product_id` (identity)    |
| `servings`        | Serving definitions (per 100g, per piece, etc.) | `serving_id` (identity)    |
| `nutrition_facts` | Nutrition per product+serving                   | `(product_id, serving_id)` |
| `scores`          | Computed health/quality scores                  | `product_id`               |
| `ingredients`     | Raw ingredient lists                            | `product_id`               |
| `sources`         | Data source references                          | `source_id`                |

**Key constraint:** `products(country, brand, product_name)` is unique — this is the upsert key.

**View:** `v_master` joins products → servings → nutrition_facts → scores for a single flat row per product.

---

## 5. Idempotency Rules

Every SQL file you create must be safe to run 1 time or 100 times with the same result.

| Operation        | Pattern                                                               |
| ---------------- | --------------------------------------------------------------------- |
| Insert product   | `INSERT ... ON CONFLICT (country, brand, product_name) DO UPDATE SET` |
| Insert serving   | `LEFT JOIN servings ... WHERE s.serving_id IS NULL`                   |
| Insert nutrition | `LEFT JOIN nutrition_facts ... WHERE nf.product_id IS NULL`           |
| Insert score row | `LEFT JOIN scores ... WHERE sc.product_id IS NULL`                    |
| Update scores    | `UPDATE scores ... FROM products ... WHERE ...`                       |
| Schema change    | `ADD COLUMN IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`              |

---

## 6. Country Scope

**Active:** Poland (`PL`) only.

- All product inserts must use `country = 'PL'`.
- All pipeline queries must filter by `country = 'PL'`.
- Do NOT add products, stores, or regulatory references for any other country.
- See `docs/COUNTRY_EXPANSION_GUIDE.md` for future expansion rules.

---

## 7. Data Integrity Rules

1. **Never invent nutrition data.** Use real EU label values, or mark as placeholder with a clear comment.
2. **Never guess Nutri-Score.** Either compute from nutrition values or cite the official score from the product label/Open Food Facts.
3. **All text values in numeric columns** (e.g., `calories`, `total_fat_g`) are stored as `text` — this is intentional to handle `'N/A'`, `'<0.5'`, and other label artifacts. Do not cast to numeric in INSERT statements.
4. **Deprecation:** Products that are generic references (not real SKUs) should be flagged `is_deprecated = true` with a `deprecated_reason`.
5. **Scoring version:** Always set `scoring_version` in the scores table (e.g., `'v3.1'`).
6. **Source tracking:** When adding a new batch of products, insert a corresponding row into the `sources` table documenting where the data came from (label, website, Open Food Facts, etc.). See `docs/DATA_SOURCES.md` §8.
7. **Research process:** Follow `docs/RESEARCH_WORKFLOW.md` for the complete data collection lifecycle — product identification, data collection, validation, normalization, implementation, verification, and documentation.
8. **Trace values:** Label artifacts like `'<0.5'`, `'trace'` are stored as-is in text columns. The scoring pipeline applies midpoint parsing (see `docs/RESEARCH_WORKFLOW.md` §4.3 and `docs/SCORING_METHODOLOGY.md` §2.3).

---

## 8. Sources Table Usage

The `sources` table is **not optional** — every product batch should be traceable.

**When to insert:** Add a `sources` row in a `PIPELINE__<category>__07_add_sources.sql` file (or inline at the end of the product insert file).

**Example:**

```sql
INSERT INTO sources (source_id, brand, source_type, ref, url, notes)
VALUES
  (nextval('sources_source_id_seq'), 'Lay''s', 'label',
   'Biedronka label, 2026-02', NULL, 'PL market, per 100g table')
ON CONFLICT (source_id) DO NOTHING;
```

**Linking to products:** Currently there is no FK from `products` to `sources`. The `brand` column in `sources` provides a soft link. A future migration may add a `source_id` FK to `products` for strict traceability.

---

## 9. Naming Conventions

| Item            | Convention                                                               |
| --------------- | ------------------------------------------------------------------------ |
| Migration files | `YYYYMMDDHHMMSS_description.sql` (Supabase auto-generates the timestamp) |
| Pipeline files  | `PIPELINE__<category>__<NN>_<action>.sql`                                |
| View files      | `VIEW__<name>.sql`                                                       |
| QA files        | `QA__<name>.sql`                                                         |
| Table names     | `snake_case`, plural (e.g., `products`, `nutrition_facts`)               |
| Column names    | `snake_case` (e.g., `saturated_fat_g`, `serving_amount_g_ml`)            |

---

## 10. Environment Connections

| Environment | DB URL                                                           | Studio                   |
| ----------- | ---------------------------------------------------------------- | ------------------------ |
| Local       | `postgresql://postgres:postgres@127.0.0.1:54322/postgres`        | `http://127.0.0.1:54323` |
| Remote      | Supabase project `uskvezwftkkudvksmken` (use `supabase db push`) | Supabase Dashboard       |

- **Local** is the default for development and testing.
- **Remote** requires explicit confirmation before any write operation.
- See `RUN_LOCAL.ps1` and `RUN_REMOTE.ps1` for execution scripts.

---

## 11. Testing & QA

### Test Suite

The project has 31 automated checks split into two SQL files:

| File                            | Checks | Purpose                                                  |
| ------------------------------- | ------ | -------------------------------------------------------- |
| `QA__null_checks.sql`           | 11     | Data integrity — nulls, orphans, missing scores          |
| `QA__scoring_formula_tests.sql` | 20     | Scoring formula validation — deterministic recomputation |

### Running Tests

```powershell
# Standalone test runner (recommended)
.\RUN_QA.ps1

# Full pipeline + QA
.\RUN_LOCAL.ps1
```

### Test Expectations

- All 33 checks must return **0 violations** (PASS).
- After adding a new category, run `.\RUN_QA.ps1` to verify.
- Formula tests recompute scores from raw nutrition and compare against stored values.

### Database Access

No `psql` required locally. All access is via Docker:

```powershell
echo "SELECT ..." | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres
```

Supabase Studio is available at `http://127.0.0.1:54323` for visual inspection.

---

## 12. What You Must NOT Do

- ❌ Modify existing migration files in `supabase/migrations/`
- ❌ Invent food data or nutrition values
- ❌ Assume Nutri-Score = health (see `docs/SCORING_METHODOLOGY.md`)
- ❌ Add products from countries other than Poland
- ❌ Collapse categories (each category gets its own pipeline folder)
- ❌ Remove the `text` type from numeric nutrition columns
- ❌ Drop or rename existing tables without a migration
- ❌ Use `DELETE` or `TRUNCATE` in pipeline files (use upserts instead)
- ❌ Run pipelines against remote without explicit user confirmation

---

## 13. When Adding a New Category

1. Create a new folder: `db/pipelines/<category>/`
2. Copy the `chips` pipeline files as templates.
3. Rename files: `PIPELINE__<category>__01_insert_products.sql`, etc.
4. Update all `WHERE` clauses to filter by the new category name.
5. **Scoring:** Use `compute_unhealthiness_v31()` function (migration 000500) — do NOT inline the formula. Example:
   ```sql
   unhealthiness_score = compute_unhealthiness_v31(
       nf.saturated_fat_g::numeric, nf.sugars_g::numeric, nf.salt_g::numeric,
       nf.calories::numeric, nf.trans_fat_g::numeric, i.additives_count::numeric,
       p.prep_method, p.controversies
   )::text
   ```
6. Add the new category folder to `RUN_LOCAL.ps1` and `RUN_REMOTE.ps1`.
7. Ensure all inserts use `country = 'PL'` and `category = '<new_category>'`.
8. Test locally before any remote push.

---

## 14. Future EU Expansion

This project is designed to scale to other EU countries. When that happens:

- Each country gets its own pipeline variants (or parameterized scripts).
- The `country` column isolates data per country.
- Nutri-Score availability varies by country (mandatory in FR/BE/DE; voluntary elsewhere).
- Regulation references (additives, labeling rules) differ per country.
- See `docs/COUNTRY_EXPANSION_GUIDE.md` for the full protocol.

Until expansion is approved, **all work is Poland-only**.

---

## 15. Recommended VS Code Extensions

The extensions below are required for full project functionality. Install any missing ones before working.

| Extension               | ID                                      | Purpose                                                |
| ----------------------- | --------------------------------------- | ------------------------------------------------------ |
| **Python**              | `ms-python.python`                      | Python support (`scripts/init_db_structure.py`)        |
| **Pylance**             | `ms-python.vscode-pylance`              | Python type checking & IntelliSense                    |
| **PowerShell**          | `ms-vscode.powershell`                  | PowerShell scripts (`RUN_LOCAL.ps1`, `RUN_REMOTE.ps1`) |
| **SQLTools**            | `mtxr.sqltools`                         | SQL IntelliSense, formatting, runner                   |
| **SQLTools PG Driver**  | `mtxr.sqltools-driver-pg`               | Connects SQLTools to local/remote PostgreSQL           |
| **PostgreSQL**          | `ms-ossdata.vscode-pgsql`               | PostgreSQL language support                            |
| **Even Better TOML**    | `tamasfe.even-better-toml`              | Syntax/validation for `supabase/config.toml`           |
| **GitLens**             | `eamodio.gitlens`                       | Git blame, history, branch comparison                  |
| **Git Graph**           | `mhutchie.git-graph`                    | Visual commit/branch graph                             |
| **Markdown All in One** | `yzhang.markdown-all-in-one`            | TOC generation, preview, formatting                    |
| **dotenv**              | `dotenv.dotenv-vscode`                  | `.env` file syntax highlighting                        |
| **Todo Tree**           | `gruntfuggly.todo-tree`                 | Tracks `TODO`, `FIXME`, `HACK` across SQL & docs       |
| **Error Lens**          | `usernamehw.errorlens`                  | Inline error/warning display                           |
| **Code Spell Checker**  | `streetsidesoftware.code-spell-checker` | Catches typos in docs & SQL comments                   |
| **EditorConfig**        | `editorconfig.editorconfig`             | Enforces consistent indentation & line endings         |
| **SonarLint**           | `sonarsource.sonarlint-vscode`          | Code quality & security scanning                       |

**Settings:** Project-level settings live in `.vscode/settings.json`. This file configures SQLTools connections (local Supabase), Todo Tree keywords, spell-checker dictionaries (Polish product terms), and file associations. It is committed to the repo.

---

## 16. Git Workflow

### Branch Strategy

- **`main`** — stable, deployable state. All pipelines pass against local DB.
- **Feature branches** — `feat/<category>-pipeline`, `fix/<issue>`, `docs/<topic>`.
- Merge to `main` via pull request with at least a self-review.

### What to Commit

| Include                                             | Exclude (`.gitignore`)                                |
| --------------------------------------------------- | ----------------------------------------------------- |
| All `.sql` files (migrations, pipelines, views, QA) | `.env` files                                          |
| All `.md` documentation                             | `node_modules/`                                       |
| `RUN_LOCAL.ps1`, `RUN_QA.ps1`, `RUN_REMOTE.ps1`     | Supabase local data (`.supabase/`)                    |
| `supabase/config.toml`                              | OS files (`.DS_Store`, `Thumbs.db`)                   |
| `supabase/migrations/`                              | `.vscode/*` except `settings.json`, `extensions.json` |
| `.vscode/settings.json`, `.vscode/extensions.json`  |                                                       |
| `scripts/init_db_structure.py`                      |                                                       |

### Commit Message Convention

```
<type>(<scope>): <description>

Examples:
  feat(chips): add nutrition facts for Pringles
  fix(scoring): correct salt threshold from 1.5 to 2.0
  docs(methodology): add Nutri-Score computation spec
  schema: add prep_method column to products
  pipeline(zabka): initial product insert
```

### Pre-Commit Checklist

1. Run `./RUN_LOCAL.ps1` — all pipelines pass
2. No hardcoded remote credentials in any file
3. No modifications to existing `supabase/migrations/` files
4. Documentation updated if methodology or schema changed
