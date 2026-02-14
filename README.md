# Poland Food Quality Database

[![QA Tests](https://github.com/ericsocrat/poland-food-db/actions/workflows/qa.yml/badge.svg)](https://github.com/ericsocrat/poland-food-db/actions/workflows/qa.yml)

A multi-axis food quality database scoring **1,025 products** sold in Poland using a 9-factor weighted algorithm (v3.2) based on nutritional science and EU regulatory guidelines.

## What This Project Is

A **nutritional risk database** that scores packaged food products on multiple independent axes:
- **Unhealthiness Score (1-100):** 9-factor weighted penalty score — higher = more nutritional risk factors
- **Nutri-Score (A-E):** EU-style front-of-pack nutrition grade
- **NOVA (1-4):** Processing level classification
- **Data Confidence (0-100):** How complete and verified the underlying data is

This is **not** a Nutri-Score app, a calorie counter, or a "healthy/unhealthy" binary classifier. It is a transparent, multi-dimensional scoring system where every number links back to the data and methodology that produced it.

## How It Differs From Nutri-Score Apps

| Dimension               | Nutri-Score Apps | This Project                                                      |
| ----------------------- | ---------------- | ----------------------------------------------------------------- |
| Scoring axes            | 1 (A-E letter)   | 4 independent axes (unhealthiness, nutri-score, NOVA, confidence) |
| Additive analysis       | No               | Yes — EFSA concern tiers, additive count                          |
| Processing level        | No               | Yes — NOVA 1-4 integrated into score                              |
| Trans fat tracking      | No               | Yes — separate weighted factor                                    |
| Controversy tracking    | No               | Yes — palm oil, artificial sweeteners flagged                     |
| Data quality visibility | Hidden           | Explicit — confidence score per product                           |
| Score explainability    | None             | Full factor breakdown with category context                       |
| Source provenance       | Opaque           | Tracked — every product links to its data source                  |

## 🎯 Quick Start

### 1. Start Local Database
```powershell
supabase start
```

### 2. Run Pipelines
```powershell
# Run all categories
.\RUN_LOCAL.ps1 -RunQA

# Run specific category
.\RUN_LOCAL.ps1 -Category chips -RunQA
.\RUN_LOCAL.ps1 -Category zabka -RunQA
.\RUN_LOCAL.ps1 -Category cereals -RunQA
.\RUN_LOCAL.ps1 -Category drinks -RunQA
```

### 3. View Data
- **Web UI**: Open http://127.0.0.1:54323 → **Table Editor** or **SQL Editor**
- **Command-line**: See [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) for queries

### 4. Run Tests
```powershell
# All tests (333 checks across 22 suites)
.\RUN_QA.ps1

# Negative validation (23 constraint tests)
.\RUN_NEGATIVE_TESTS.ps1

# Or via pipeline runner
.\RUN_LOCAL.ps1 -RunQA
```

### 5. Frontend Development
```bash
cd frontend
npm ci               # Install dependencies (uses lockfile)
npm run dev          # Start dev server on http://localhost:3000
npm run type-check   # TypeScript check (tsc --noEmit)
npm run lint         # ESLint
npm run build        # Production build
npm test             # Unit tests (Vitest, 56 tests)
npm run test:coverage # Unit tests + v8 coverage (lcov)
npx playwright test  # E2E smoke tests (14 tests)
```

#### Running Playwright Locally
```bash
cd frontend
npx playwright install --with-deps chromium   # first time only
npx playwright test                           # runs against local dev server
npx playwright test --ui                      # interactive UI mode
npx playwright show-report                    # open last HTML report
```

### CI Pipeline

The GitHub Actions CI workflow runs automatically on pushes to `main` and pull requests:

**install → type-check → lint → build → unit tests (coverage) → Playwright e2e → SonarCloud scan → Quality Gate**

Failed Playwright runs upload screenshots and traces as artifacts for debugging. See [DEPLOYMENT.md](DEPLOYMENT.md) for full deployment configuration details.

---

## 📊 Current Status

**Database**: 1,025 active products across 20 categories (variable size, 38 deprecated products excluded)

| Category                       | Products | Brands | Score Range |
| ------------------------------ | -------: | -----: | ----------- |
| **Alcohol**                    |       30 |     25 | 4–17        |
| **Baby**                       |        9 |      4 | 8–34        |
| **Bread**                      |       60 |     33 | 9–40        |
| **Breakfast & Grain-Based**    |       94 |     34 | 6–44        |
| **Canned Goods**               |       49 |     27 | 5–30        |
| **Cereals**                    |       42 |     16 | 12–45       |
| **Chips**                      |       50 |     21 | 11–37       |
| **Condiments**                 |       55 |     28 | 9–40        |
| **Dairy**                      |       50 |     20 | 8–44        |
| **Drinks**                     |       61 |     28 | 4–30        |
| **Frozen & Prepared**          |       50 |     23 | 5–46        |
| **Instant & Frozen**           |       52 |     21 | 6–49        |
| **Meat**                       |       49 |     26 | 9–46        |
| **Nuts, Seeds & Legumes**      |       44 |     21 | 23–46       |
| **Plant-Based & Alternatives** |       48 |     33 | 6–39        |
| **Sauces**                     |       98 |     46 | 6–41        |
| **Seafood & Fish**             |       51 |     25 | 8–34        |
| **Snacks**                     |       56 |     37 | 7–49        |
| **Sweets**                     |       50 |     19 | 30–51       |
| **Żabka**                      |       27 |      3 | 13–34       |
**Test Coverage**: 333 automated checks across 22 QA suites + 23 negative validation tests
- 29 data integrity checks (nulls, orphans, FKs, duplicates, nutrition sanity, view consistency, provenance)
- 27 scoring formula checks (ranges, flags, NOVA, domains, confidence, 8 regression tests)
- 14 API surface checks (contract validation, JSON structure, listing consistency)
- 13 view consistency checks (v_master, v_api_category_overview, materialized views)
- 25 data quality checks (completeness, constraints, domains)
- 18 referential integrity checks (FK validation, domain constraints)
- 20 data consistency checks (cross-table relationships, formula verification)
- 16 nutrition range checks (physiological bounds, cross-field validation)
- 15 allergen integrity checks (FK validation, duplicate detection, coverage, schema constraint)
- 16 serving & source validation checks (basis rules, source completeness)
- 14 ingredient quality checks (naming, frequency, concern tier distribution)
- 12 naming convention checks (product names, brands, slugs)
- 10 confidence scoring checks (range, distribution, components, bands)
- 22 security posture checks (RLS, grants, SECURITY DEFINER, user_preferences isolation, resolve_effective_country)
- 33 API contract checks (key sets, api_version, SECURITY DEFINER, EAN lookup, preferences, country-echo contract)
- 15 scale guardrail checks (index presence, query plan validation)
- 11 country isolation checks (no mixed-country results, auto-country resolution)
- 6 diet filtering checks (vegan/vegetarian exclusion, strict mode)
- 6 allergen filtering checks (contains/traces exclusion, may-contain toggle)
- 6 barcode lookup checks (EAN resolution, scan metadata, error handling)
- 1 EAN checksum validation (all barcodes verified)
- 8 source coverage reports (informational, non-blocking)
- 23 negative tests (constraint violation detection)

**All tests passing**: ✅ 333/333 + 23/23 negative

**EAN Coverage**: 997/1,025 active products (97.3%) have valid EAN-8/EAN-13 barcodes

---

## 🏗️ Project Structure

```
poland-food-db/
├── db/
│   ├── migrations/          # (empty — consolidated into supabase/migrations)
│   ├── pipelines/           # Category-specific data pipelines
│   │   ├── alcohol/         # 30 alcohol products (3 SQL files)
│   │   ├── baby/            # 9 baby products (3 SQL files)
│   │   ├── bread/           # 60 bread products (3 SQL files)
│   │   ├── breakfast-grain-based/ # 94 breakfast products (3 SQL files)
│   │   ├── canned-goods/    # 49 canned goods products (4 SQL files)
│   │   ├── cereals/         # 42 cereal products (3 SQL files)
│   │   ├── chips/           # 50 chip products (4 SQL files)
│   │   ├── condiments/      # 55 condiment products (4 SQL files)
│   │   ├── dairy/           # 50 dairy products (4 SQL files)
│   │   ├── drinks/          # 61 beverage products (3 SQL files)
│   │   ├── frozen-prepared/ # 50 frozen & prepared products (4 SQL files)
│   │   ├── instant-frozen/  # 52 instant & frozen products (4 SQL files)
│   │   ├── meat/            # 49 meat & deli products (4 SQL files)
│   │   ├── nuts-seeds-legumes/ # 44 nuts, seeds & legumes products (4 SQL files)
│   │   ├── plant-based-alternatives/ # 48 plant-based products (3 SQL files)
│   │   ├── sauces/          # 98 sauce products (3 SQL files)
│   │   ├── seafood-fish/    # 51 seafood & fish products (4 SQL files)
│   │   ├── snacks/          # 56 snack products (3 SQL files)
│   │   ├── sweets/          # 50 sweets & chocolate products (4 SQL files)
│   │   └── zabka/           # 27 convenience store products (3 SQL files)
│   ├── qa/                  # Quality assurance test suites
│   │   ├── QA__null_checks.sql           # 29 integrity checks
│   │   ├── QA__scoring_formula_tests.sql # 27 algorithm tests
│   │   ├── QA__api_surfaces.sql          # 14 API contract checks
│   │   ├── QA__confidence_scoring.sql    # 10 confidence scoring checks
│   │   ├── QA__data_quality.sql          # 25 data quality checks
│   │   ├── QA__referential_integrity.sql # 18 referential integrity checks
│   │   ├── QA__view_consistency.sql      # 13 view consistency checks
│   │   ├── QA__naming_conventions.sql    # 12 naming convention checks
│   │   ├── QA__nutrition_ranges.sql      # 16 nutrition range checks
│   │   ├── QA__data_consistency.sql      # 20 data consistency checks
│   │   ├── QA__allergen_integrity.sql    # 14 allergen integrity checks
│   │   ├── QA__serving_source_validation.sql # 16 serving & source checks
│   │   ├── QA__ingredient_quality.sql    # 14 ingredient quality checks
│   │   ├── QA__source_coverage.sql       # 8 data quality reports
    │   └── TEST__negative_checks.sql     # 25 negative validation tests
│   └── views/               # Denormalized reporting views
│       └── VIEW__master_product_view.sql # Flat API view with provenance
├── supabase/
│   ├── config.toml          # Local Supabase configuration
    └── migrations/          # Schema migrations (63 files)
├── docs/                    # Project documentation
│   ├── API_CONTRACTS.md     # API surface contract documentation
│   ├── PERFORMANCE_REPORT.md # Performance audit & scale readiness
│   ├── DATA_SOURCES.md      # Multi-source data hierarchy & validation workflow
│   ├── SCORING_METHODOLOGY.md # v3.2 algorithm documentation
│   ├── RESEARCH_WORKFLOW.md # Step-by-step data collection process
│   ├── VIEWING_AND_TESTING.md # Full viewing & testing guide
│   ├── COUNTRY_EXPANSION_GUIDE.md # Future multi-country rules
│   ├── EAN_EXPANSION_PLAN.md  # EAN coverage strategy
│   ├── EAN_VALIDATION_STATUS.md # Current EAN validation status
│   └── UX_UI_DESIGN.md      # Production-ready UX specification
├── pipeline/                # Python data pipeline (OFF API v2 → SQL)
├── RUN_LOCAL.ps1            # Pipeline runner (idempotent)
├── RUN_QA.ps1               # Standalone test runner (322 checks)
├── RUN_NEGATIVE_TESTS.ps1   # Constraint violation tests (29 tests)
└── RUN_REMOTE.ps1           # Remote deployment (with confirmation)
```

---

## 🧪 Testing Philosophy

**Principle:** No data enters the database without automated verification. No scoring change ships without regression tests proving existing products are unaffected.

Every change is validated against **322 automated checks** across 22 QA suites + 25 negative validation tests:

### Data Integrity (29 checks)
- No missing required fields (product_name, brand, country, category)
- No orphaned foreign keys (nutrition)
- No duplicate products
- All active products have nutrition rows and scoring data
- Nutrition sanity (no negative values, sat_fat ≤ total_fat, sugars ≤ carbs, calories ≤ 900)
- Score fields not null for active products
- View consistency (v_master row count matches products)
- Source provenance (every product has source_type, no orphaned data)

### Scoring Formula (27 checks)
- Scores in valid range [1, 100]
- Clean products score ≤ 20
- Maximum unhealthy products score high
- Identical nutrition → identical scores
- Flag logic (salt ≥1.5g, sugar ≥5g, sat fat ≥5g)
- High additive load flag consistency
- NOVA classification valid (1–4)
- Processing risk alignment with NOVA
- Scoring version = v3.2
- Nutri-Score label domain (A–E or UNKNOWN)
- Confidence domain (verified, estimated, low)
- **Regression**: Top Chips Faliste = 51±2 (palm oil)
- **Regression**: Naleśniki = 17±2 (healthiest Żabka)
- **Regression**: Melvit Płatki Owsiane = 11±2 (healthiest cereal)
- **Regression**: Coca-Cola Zero = 8±2 (lowest-scoring drink)
- **Regression**: Piątnica Skyr Naturalny = 9±2 (healthiest dairy)
- **Regression**: Mestemacher Pumpernikiel = 17±2 (traditional rye)
- **Regression**: Tarczyński Kabanosy Klasyczne = 55±2 (high-fat cured meat)
- **Regression**: Knorr Nudle Pomidorowe Pikantne = 21±2 (instant noodle, palm oil)

### Source Coverage (8 informational reports)
- Products without source metadata
- Single-source products needing cross-validation
- High-impact products (score >40, single-source)
- EAN coverage by category
- Confidence level distribution
- Ingredient data coverage

### API Surface Validation (14 checks)
- Category overview row count matches reference table
- Product count sums match v_master
- All products return valid API JSON
- Required JSON keys present in product detail
- Score explanation covers all scored products
- Search and listing return valid structures

### Confidence Scoring (10 checks)
- Confidence scores in valid range (0-100)
- Band assignment matches score thresholds (high ≥80, medium 50-79, low <50)
- All 6 components sum to total score
- No products missing confidence data
- Distribution sanity (no impossible band values; monitor shifts after data resets)
- Component weights match formula specification

### Additional Suites
- **Naming Conventions** (12 checks): Product name format, brand consistency, slug validation
- **Nutrition Ranges** (16 checks): Physiological bounds, cross-field validation
- **Data Consistency** (20 checks): Cross-table relationships, formula verification
- **Allergen Integrity** (14 checks): FK validation, duplicate detection, valid values
- **Serving & Source Validation** (16 checks): Basis rules, source completeness
- **Ingredient Quality** (14 checks): Naming, frequency, concern tier distribution
- **Security Posture** (20 checks): RLS, grants, SECURITY DEFINER, user_preferences isolation
- **API Contract** (30 checks): Key sets, api_version, EAN lookup, preferences endpoints
- **Scale Guardrails** (15 checks): Index presence, query plan validation
- **Country Isolation** (6 checks): No mixed-country results across all API surfaces
- **Diet Filtering** (6 checks): Vegan/vegetarian exclusion, strict mode
- **Allergen Filtering** (6 checks): Contains/traces exclusion, may-contain toggle
- **Barcode Lookup** (6 checks): EAN resolution, scan metadata, error handling

### Negative Validation (29 tests)
Constraint violation tests that verify the database correctly rejects invalid data (bad EANs, out-of-range scores, invalid domains, FK violations).

**Test files**: `db/qa/QA__*.sql` + `db/qa/TEST__negative_checks.sql` — Run via `.\RUN_QA.ps1` and `.\RUN_NEGATIVE_TESTS.ps1`

**CI**: All 322 checks run on every push to `main` via GitHub Actions. Confidence coverage threshold enforced (max 5% low-confidence products).

Run tests after **every** schema change or data update.

### Database Constraints

26 CHECK constraints enforce domain rules at the database level, plus 4 FK-backed reference tables:

**Reference Tables** (FK constraints):

| FK Constraint                | Table → Reference Table           | Purpose                             |
| ---------------------------- | --------------------------------- | ----------------------------------- |
| `fk_products_country`        | products → country_ref            | ISO 3166-1 country validation       |
| `fk_products_category`       | products → category_ref           | Category master list (20 active)    |
| `fk_products_nutri_score`    | products → nutri_score_ref        | Nutri-Score label definitions (A–E) |
| `fk_ingredient_concern_tier` | ingredient_ref → concern_tier_ref | EFSA concern tiers (0–3)            |

**CHECK Constraints** (26):

| Table           | Constraint                         | Rule                                                              |
| --------------- | ---------------------------------- | ----------------------------------------------------------------- |
| products        | `chk_products_prep_method`         | Valid prep method or null                                         |
| products        | `chk_products_controversies`       | controversies IN ('none','minor','moderate','serious','palm oil') |
| products        | `chk_products_unhealthiness_range` | 0–100                                                             |
| products        | `chk_products_nutri_label`         | A–E, UNKNOWN, or NOT-APPLICABLE                                   |
| products        | `chk_products_confidence`          | verified / estimated / low                                        |
| products        | `chk_products_nova`                | 1–4                                                               |
| products        | `chk_products_*_flag`              | Y / N (4 flags)                                                   |
| products        | `chk_products_completeness`        | 0–100                                                             |
| nutrition_facts | `chk_nf_non_negative` (7 cols)     | ≥ 0                                                               |
| nutrition_facts | `chk_nf_sat_fat_le_total`          | saturated_fat ≤ total_fat                                         |
| nutrition_facts | `chk_nf_sugars_le_carbs`           | sugars ≤ carbs                                                    |

---

## 📈 Scoring Methodology

### v3.2 Formula (9 factors)

Implemented as a reusable PostgreSQL function `compute_unhealthiness_v32()` — all category pipelines call this single function.

```
unhealthiness_score =
  sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
  trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
  controversies(0.08) + ingredient_concern(0.05)
```

**Score Bands**:
- **1–20**: Low risk
- **21–40**: Moderate risk
- **41–60**: Elevated risk
- **61–80**: High risk
- **81–100**: Very high risk

**Ceilings** (per 100g): sat fat 10g, sugars 27g, salt 3g, trans fat 2g, calories 600 kcal, additives 10

Full documentation: [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md)

---

## 🔍 Data Quality & Provenance

### Confidence Levels

Every product receives an automated **data confidence** score (0-100) measuring how complete and verified the underlying data is. This is NOT a quality or healthiness score — it tells you how much to trust the displayed numbers.

| Confidence | Score | Criteria                              | Meaning                          |
| ---------- | ----- | ------------------------------------- | -------------------------------- |
| **High**   | ≥80   | Comprehensive nutrition + ingredients | Data is reliable for scoring     |
| **Medium** | 50-79 | Some gaps (allergens, serving data)   | Score may shift as data improves |
| **Low**    | <50   | Major data gaps                       | Use with caution                 |

**Current distribution**: 858 high · 139 medium · 28 low

The 6 components of confidence: nutrition data (0-30), ingredient data (0-25), source quality (0-20), EAN coverage (0-10), allergen info (0-10), serving data (0-5). Computed by `compute_data_confidence()`.

### EAN Barcode Tracking

Products include EAN-8/EAN-13 barcodes (where available) for cross-source product matching:

**Coverage**: 997/1,025 active products (97.3%)

EAN codes enable validation against:
- Manufacturer product pages
- Government nutrition databases (IŻŻ/NCEZ)
- Retailer catalogs (Biedronka, Lidl, Żabka)
- Physical product packaging

### Source Provenance

All 1,025 active products are sourced from the **Open Food Facts API** (`off_api`). Each product has `source_type`, `source_url`, and `source_ean` columns on the `products` table, providing full provenance tracking.

**Research workflow**: See [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) for step-by-step data collection process.

---

## 🔗 Useful Links

| Resource                          | URL / Command                                               |
| --------------------------------- | ----------------------------------------------------------- |
| **Supabase Studio** (Database UI) | http://127.0.0.1:54323                                      |
| **Master View** (all data)        | `SELECT * FROM v_master ORDER BY unhealthiness_score DESC;` |
| **Top 10 unhealthiest**           | See [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md)   |
| **Scoring reference**             | [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md)       |
| **All queries & tests**           | [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md)       |

---

## 🚀 Development Workflow

1. **Add products** → Edit `db/pipelines/{category}/PIPELINE__{category}__01_insert_products.sql`
2. **Add nutrition** → Edit `db/pipelines/{category}/PIPELINE__{category}__03_add_nutrition.sql`
3. **Run pipelines** → `.\RUN_LOCAL.ps1 -Category {category} -RunQA`
4. **Verify** → Open Studio UI → Query `v_master`
5. **Test** → `.\RUN_QA.ps1` (should be 322/322 pass)
6. **Commit** → All pipelines are idempotent & version-controlled

---

## 📝 Ethical Positioning

- **Education over judgment** — Scores inform, they don't prescribe. "Lower concern" not "healthy."
- **Transparency over gamification** — Every number links to its source data and computation method.
- **Multi-axis over single-number** — No single score captures nutritional reality. We show 4 independent axes.
- **Confidence over certainty** — We tell you how reliable each score is. Incomplete data gets flagged, not hidden.
- **Category context over absolutes** — A score of 25 means different things in Candy vs. Water. We always show context.

## 📝 Notes

- **All data is local** — nothing is uploaded to remote Supabase (yet)
- **Pipelines are idempotent** — safe to run repeatedly
- **Data quality tracking** — All products have confidence levels (`estimated`, `verified`, or `low`)
- **EAN barcodes** — 997/1,025 active products (97.3%) have validated EAN-8/EAN-13 codes for cross-source matching
- **Primary source**: Open Food Facts — all products pending cross-validation
- **Scoring version**: v3.2 (2026-02-10)
- **1,025 active products** across 20 categories (variable size), 38 deprecated products excluded

---

## 📚 Documentation

- [API_CONTRACTS.md](docs/API_CONTRACTS.md) — API surface contracts (6 RPC endpoints + 3 views)
- [SECURITY.md](docs/SECURITY.md) — Threat model, access control architecture, RPC-only model
- [UX_UI_DESIGN.md](docs/UX_UI_DESIGN.md) — Production-ready UX spec (score disambiguation, API mapping, misinterpretation defense)
- [PERFORMANCE_REPORT.md](docs/PERFORMANCE_REPORT.md) — Performance audit & scale projections to 50K products
- [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) — How to view data, run tests, query the DB
- [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md) — Complete v3.2 algorithm specification
- [DATA_SOURCES.md](docs/DATA_SOURCES.md) — Multi-source data hierarchy & validation workflow
- [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) — Step-by-step data collection process
- [COUNTRY_EXPANSION_GUIDE.md](docs/COUNTRY_EXPANSION_GUIDE.md) — Future multi-country rules
- [FULL_PROJECT_AUDIT.md](docs/FULL_PROJECT_AUDIT.md) — Comprehensive project audit & checklist
- `copilot-instructions.md` — AI agent context & project rules

---

## 📋 API Deprecation Policy

All API functions return `api_version` in every response (currently `"1.0"`).

| Change type                        | Version bump | Migration window |
| ---------------------------------- | ------------ | ---------------- |
| New keys added to response         | Minor (1.x)  | None — additive  |
| Key renamed or removed             | Major (x.0)  | 2 pipeline runs  |
| Response structure change          | Major (x.0)  | 2 pipeline runs  |
| New optional parameter added       | Minor (1.x)  | None — optional  |
| Required parameter changed/removed | Major (x.0)  | 2 pipeline runs  |

**Process:**
1. Bump `api_version` in the affected function
2. Update `QA__api_contract.sql` expected key arrays (23 checks enforce exact structure)
3. Document the change in the migration file header
4. Old version is never served alongside new — no multi-version routing

---

## 🖥️ Frontend (Next.js)

The `frontend/` directory contains a Next.js 14 (App Router) web application for browsing and searching products.

### Stack
- **Next.js 14** (App Router, TypeScript, Tailwind CSS)
- **@supabase/ssr** for auth (replaces deprecated auth-helpers)
- **TanStack Query v5** for data fetching with defined cache keys and stale times
- **@zxing/browser + @zxing/library** for barcode scanning (EAN-13, EAN-8, UPC)
- **sonner** for toast notifications

### Setup
```powershell
cd frontend
npm install
cp .env.local.example .env.local
# Edit .env.local with your Supabase URL + anon key
npm run dev
```
App starts at http://localhost:3000

### Architecture Rules
- **Frontend never passes `p_country`** — always `null`, backend resolves from `user_preferences.country`
- **Middleware is auth-only** — no onboarding logic (Edge runtime limitation)
- **Server-side onboarding gate** in `/app/layout.tsx` checks `onboarding_complete` via RPC
- **All RPCs go through `callRpc<T>()`** for normalized error handling
- **Session expiry** detected via `isAuthError()` → toast + redirect to `/auth/login?reason=expired`

### Smoke Test Checklist
1. Sign up → check email → confirm
2. Log in → redirected to `/onboarding/region`
3. Select country → Continue → `/onboarding/preferences`
4. Set diet/allergens (or skip) → redirected to `/app/search`
5. Search a product → see results with score badges
6. Click product → see detail tabs (Overview, Nutrition, Alternatives, Scoring)
7. Navigate to Categories → see category grid with avg scores
8. Click category → see paginated product listing with sort controls
9. Navigate to Scan → camera or manual EAN entry → product lookup
10. Navigate to Settings → change preferences → Save → verify cache invalidation
11. Sign out → redirected to login

### Page Map
| Route                     | Description                             |
| ------------------------- | --------------------------------------- |
| `/`                       | Public landing page                     |
| `/auth/login`             | Email/password login                    |
| `/auth/signup`            | Registration                            |
| `/auth/callback`          | OAuth code exchange                     |
| `/onboarding/region`      | Step 1: country selection               |
| `/onboarding/preferences` | Step 2: diet + allergens (optional)     |
| `/app/search`             | Debounced product search                |
| `/app/categories`         | Category overview grid                  |
| `/app/categories/[slug]`  | Category product listing (paginated)    |
| `/app/product/[id]`       | Product detail (4 tabs)                 |
| `/app/scan`               | Barcode scanner (ZXing camera + manual) |
| `/app/settings`           | Preferences + logout                    |
| `/contact`                | Contact page                            |
| `/privacy`                | Privacy policy                          |
| `/terms`                  | Terms of service                        |

---

**Built with**: Supabase (PostgreSQL), Open Food Facts API, PowerShell automation, Next.js
