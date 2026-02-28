# Copilot Instructions — Poland Food Quality Database

> **Last updated:** 2026-02-28
> **Scope:** Poland (`PL`) primary + Germany (`DE`) micro-pilot (252 products across 5 categories)
> **Products:** ~1,281 active (20 PL categories + 5 DE categories), 51 deprecated
> **EAN coverage:** 1,024/1,026 (99.8%)
> **Scoring:** v3.2 — 9-factor weighted formula via `compute_unhealthiness_v32()` (added ingredient concern scoring)
> **Servings:** removed as separate table — all nutrition data is per-100g on nutrition_facts
> **Ingredient analytics:** 2,995 unique ingredients (all clean ASCII English), 1,269 allergen declarations, 1,361 trace declarations
> **Ingredient concerns:** EFSA-based 4-tier additive classification (0=none, 1=low, 2=moderate, 3=high)
> **QA:** 714 checks across 47 suites + 23 negative validation tests — all passing

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
.\.venv\Scripts\python.exe -m pipeline.run --category "Dairy" --country DE --max-products 51
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
│   ├── test_validator.py            # Validator unit tests
│   ├── utils.py                     # Shared utility helpers
│   ├── image_importer.py            # Product image import utility
│   └── categories.py               # 20 category definitions + OFF tag mappings
├── db/
│   ├── pipelines/                   # 25 category folders (20 PL + 5 DE), 4-5 SQL files each
│   │   ├── chips-pl/                # Reference PL implementation (copy for new categories)
│   │   ├── chips-de/                # Germany micro-pilot (51 products)
│   │   ├── bread-de/                # DE Bread (51 products)
│   │   ├── dairy-de/                # DE Dairy (51 products)
│   │   ├── drinks-de/               # DE Drinks (51 products)
│   │   ├── sweets-de/               # DE Sweets (51 products)
│   │   └── ... (19 more PL)         # Variable product counts per category
│   ├── qa/                          # Test suites
│   │   ├── QA__null_checks.sql      # 29 data integrity checks
│   │   ├── QA__scoring_formula_tests.sql  # 29 scoring validation checks
│   │   ├── QA__api_surfaces.sql     # 18 API surface validation checks
│   │   ├── QA__api_contract.sql     # 33 API contract checks
│   │   ├── QA__confidence_scoring.sql  # 14 confidence scoring checks
│   │   ├── QA__confidence_reporting.sql # 7 confidence reporting checks
│   │   ├── QA__data_quality.sql          # 25 data quality checks
│   │   ├── QA__data_consistency.sql      # 22 data consistency checks
│   │   ├── QA__referential_integrity.sql # 18 referential integrity checks
│   │   ├── QA__view_consistency.sql      # 13 view consistency checks
│   │   ├── QA__naming_conventions.sql    # 12 naming convention checks
│   │   ├── QA__nutrition_ranges.sql      # 16 nutrition range checks
│   │   ├── QA__allergen_integrity.sql    # 15 allergen integrity checks
│   │   ├── QA__allergen_filtering.sql    # 6 allergen filtering checks
│   │   ├── QA__serving_source_validation.sql # 16 serving & source checks
│   │   ├── QA__ingredient_quality.sql    # 14 ingredient quality checks
│   │   ├── QA__security_posture.sql      # 40 security posture checks
│   │   ├── QA__scale_guardrails.sql      # 23 scale guardrails checks
│   │   ├── QA__country_isolation.sql     # 11 country isolation checks
│   │   ├── QA__diet_filtering.sql        # 6 diet filtering checks
│   │   ├── QA__barcode_lookup.sql        # 9 barcode scanner checks
│   │   ├── QA__auth_onboarding.sql       # 8 auth & onboarding checks
│   │   ├── QA__health_profiles.sql       # 14 health profile checks
│   │   ├── QA__lists_comparisons.sql     # 15 lists & comparison checks
│   │   ├── QA__scanner_submissions.sql   # 15 scanner & submission checks
│   │   ├── QA__index_temporal.sql        # 15 index & temporal integrity checks
│   │   ├── QA__attribute_contradiction.sql # 5 attribute contradiction checks
│   │   ├── QA__monitoring.sql            # 14 monitoring & health checks
│   │   ├── QA__event_intelligence.sql    # 18 event intelligence checks
│   │   ├── QA__source_coverage.sql  # 8 informational reports (non-blocking)
│   │   └── TEST__negative_checks.sql     # 23 negative validation tests
│   └── views/
│       └── VIEW__master_product_view.sql  # v_master definition (reference copy)
├── supabase/
│   ├── config.toml
│   ├── seed.sql                     # Supabase seed entry point
│   ├── seed/                        # Reference data seeds
│   │   └── 001_reference_data.sql   # Category, country, nutri-score ref data
│   ├── sanity/                      # Sanity check SQL
│   │   └── sanity_checks.sql        # Row-count + schema assertions
│   ├── tests/                       # pgTAP integration tests
│   │   ├── schema_contracts.test.sql     # Table/view/function existence checks
│   │   ├── product_functions.test.sql    # Product detail, alternatives, score explanation
│   │   ├── category_functions.test.sql   # Category overview, listing
│   │   ├── search_functions.test.sql     # Search, autocomplete, filter options
│   │   ├── scanner_functions.test.sql    # Scan recording, history
│   │   ├── comparison_functions.test.sql # Compare, save, share comparisons
│   │   ├── dashboard_functions.test.sql  # Recently viewed, dashboard data
│   │   ├── telemetry_functions.test.sql  # Event tracking, admin summaries
│   │   ├── user_functions.test.sql       # Auth-error branches
│   │   ├── achievement_functions.test.sql    # Achievement/gamification tests
│   │   ├── business_metrics_functions.test.sql # Business metrics tests
│   │   ├── localization_functions.test.sql    # Localization/i18n tests
│   │   └── push_notification_functions.test.sql # Push notification tests
│   ├── functions/                   # Supabase Edge Functions
│   │   └── send-push-notification/  # Push notification handler
│   ├── dr-drill/                    # Disaster recovery drill artifacts
│   └── migrations/                  # 140 append-only schema migrations
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
│   ├── API_CONVENTIONS.md           # RPC naming convention, breaking change definition, security standards
│   ├── API_VERSIONING.md            # API deprecation & versioning policy
│   ├── ACCESS_AUDIT.md              # Data access pattern audit & quarterly review
│   ├── ALERT_POLICY.md              # Alert escalation, query regression, index drift monitoring
│   ├── ARCHITECTURE.md              # Unified system architecture overview (data flow, schema, scoring, API, security)
│   ├── BACKFILL_STANDARD.md         # Backfill orchestration standard & migration templates
│   ├── CI_ARCHITECTURE_PROPOSAL.md  # CI pipeline design
│   ├── CONTRACT_TESTING.md          # API contract testing strategy & pgTAP patterns
│   ├── COUNTRY_EXPANSION_GUIDE.md   # Multi-country protocol (PL active, DE micro-pilot)
│   ├── DATA_INTEGRITY_AUDITS.md     # Ongoing data integrity audit framework
│   ├── DATA_PROVENANCE.md           # Data provenance & freshness governance
│   ├── DATA_SOURCES.md              # Source hierarchy & validation workflow
│   ├── DISASTER_DRILL_REPORT.md     # Disaster recovery drill report & findings
│   ├── DOCUMENTATION_GOVERNANCE.md  # Documentation ownership, versioning, deprecation, drift prevention
│   ├── DOMAIN_BOUNDARIES.md         # Domain boundary enforcement & ownership mapping
│   ├── DRIFT_DETECTION.md           # 8-check drift detection catalog, severity levels, CI plan
│   ├── EAN_VALIDATION_STATUS.md     # 1,024/1,026 coverage (99.8%)
│   ├── ENVIRONMENT_STRATEGY.md      # Local/staging/production environment strategy
│   ├── FEATURE_FLAGS.md             # Feature flag architecture & toggle registry
│   ├── FEATURE_SUNSETTING.md        # Feature retirement criteria & cleanup policy
│   ├── FRONTEND_API_MAP.md          # Frontend ↔ API mapping reference
│   ├── GOVERNANCE_BLUEPRINT.md      # Execution governance blueprint (master GOV plan)
│   ├── INCIDENT_RESPONSE.md         # Incident response playbook (severity, escalation, runbooks)
│   ├── INDEX.md                     # Canonical documentation map (45 docs, domain-classified)
│   ├── LABELS.md                    # Labeling conventions
│   ├── LOG_SCHEMA.md                # Structured log schema & error taxonomy
│   ├── METRICS.md                   # Application, infrastructure & business metrics catalog
│   ├── MIGRATION_CONVENTIONS.md     # Migration safety, trigger naming, lock risk, idempotency
│   ├── MONITORING.md                # Runtime monitoring
│   ├── OBSERVABILITY.md             # Observability strategy
│   ├── ON_CALL_POLICY.md            # On-call & alert ownership, ack targets, triage labels
│   ├── PERFORMANCE_GUARDRAILS.md    # Performance guardrails, query budgets & scale projections
│   ├── PERFORMANCE_REPORT.md        # Performance audit, scale projections, query patterns
│   ├── PRIVACY_CHECKLIST.md         # GDPR/RODO compliance checklist & data lifecycle
│   ├── PRODUCTION_DATA.md           # Production data management
│   ├── RATE_LIMITING.md             # Rate limiting strategy & API abuse prevention
│   ├── REPO_GOVERNANCE.md           # Repo structure rules, root cleanliness, CI integrity
│   ├── RESEARCH_WORKFLOW.md         # Data collection lifecycle (manual + automated OFF pipeline)
│   ├── SCORING_ENGINE.md            # Scoring engine architecture & version management
│   ├── SCORING_METHODOLOGY.md       # v3.2 algorithm (9 factors, ceilings, bands)
│   ├── SEARCH_ARCHITECTURE.md       # Search architecture (pg_trgm, tsvector, ranking)
│   ├── SECURITY_AUDIT.md            # Full security audit report
│   ├── SLO.md                       # Service Level Objectives (availability, latency, error rate)
│   ├── SONAR.md                     # SonarCloud configuration & quality gates
│   ├── STAGING_SETUP.md             # Staging environment setup
│   ├── UX_IMPACT_METRICS.md         # UX measurement standard, metric catalog, SQL templates
│   ├── UX_UI_DESIGN.md              # UI/UX guidelines
│   ├── VIEWING_AND_TESTING.md       # Queries, Studio UI, test runner
│   ├── api-registry.yaml            # Structured registry of all 191 functions (YAML)
│   └── decisions/                   # Architecture Decision Records (MADR 3.0)
│       ├── 000-template.md          # ADR template
│       ├── 001-postgresql-only-stack.md
│       ├── 002-weighted-scoring-formula.md
│       ├── 003-country-scoped-isolation.md
│       ├── 004-pipeline-generates-sql.md
│       ├── 005-api-function-name-versioning.md
│       ├── 006-append-only-migrations.md
│       └── 007-english-canonical-ingredients.md
├── RUN_LOCAL.ps1                    # Pipeline runner (idempotent)
├── RUN_QA.ps1                       # QA test runner (714 checks across 47 suites)
├── RUN_NEGATIVE_TESTS.ps1           # Negative test runner (23 injection tests)
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
│   │   │   ├── trust/               # Trust & transparency (TrustBadge, FreshnessIndicator, SourceAttribution)
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
├── scripts/                         # Utility & governance scripts
│   ├── backfill_template.py         # Template for backfill operations
│   ├── check_doc_counts.py          # Doc count consistency checker
│   ├── check_doc_drift.py           # Doc staleness detector
│   ├── check_migration_conventions.py # Migration naming validator
│   ├── check_migration_order.py     # Migration ordering validator
│   ├── export_user_data.ps1         # User data export utility
│   └── import_user_data.ps1         # User data import utility
├── .github/workflows/
│   ├── pr-gate.yml                  # Lint → Typecheck → Build → Playwright E2E
│   ├── pr-title-lint.yml            # PR title conventional-commit validation (all PRs)
│   ├── main-gate.yml                # Build → Unit tests + coverage → SonarCloud
│   ├── qa.yml                       # Schema → Pipelines → QA (699) → Sanity
│   ├── nightly.yml                  # Full Playwright (all projects) + Data Integrity Audit
│   ├── deploy.yml                   # Manual trigger → Schema diff → Approval → db push
│   ├── sync-cloud-db.yml            # Remote DB sync
│   ├── api-contract.yml             # API contract validation
│   ├── bundle-size.yml              # Frontend bundle size guard
│   ├── codeql.yml                   # CodeQL security analysis
│   ├── dependabot-auto-merge.yml    # Auto-merge Dependabot PRs
│   ├── dependency-audit.yml         # Dependency vulnerability audit
│   ├── license-compliance.yml       # License compliance checks
│   ├── python-lint.yml               # Python linting (Ruff)
│   ├── quality-gate.yml             # SonarCloud quality gate
│   ├── repo-verify.yml              # Repo hygiene verification
│   ├── smoke-test.yml               # Post-deploy smoke test
│   ├── validate-alerts.yml          # Alert configuration validation
│   └── dr-drill.yml                 # Disaster recovery drill
├── .commitlintrc.json               # Conventional Commits config (12 types, 24 scopes)
├── .editorconfig                    # Editor configuration (indent styles per language)
├── sonar-project.properties         # SonarCloud configuration
├── requirements.txt                 # Python dependencies
├── CHANGELOG.md                     # Structured changelog (Keep a Changelog + Conventional Commits)
├── DEPLOYMENT.md                    # Deployment procedures, rollback playbook, emergency checklist
├── SECURITY.md                      # Security policy
├── .env.example
├── BACKUP.ps1                       # Pre-push database backup script
├── RUN_DR_DRILL.ps1                 # Disaster recovery drill runner
├── run_data_audit.py                # Nightly data integrity audit (used by nightly.yml)
├── test_data_audit.py               # Unit tests for data audit module
└── README.md
```

---

## 4. Database Schema

### Tables

| Table                     | Purpose                                         | Primary Key                             | Notes                                                                                                                                                    |
| ------------------------- | ----------------------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `products`                | Product identity, scores, flags, provenance     | `product_id` (identity)                 | Upsert key: `(country, brand, product_name)`. Scores, flags, source columns all inline.                                                                  |
| `nutrition_facts`         | Nutrition per product (per 100g)                | `product_id`                            | Numeric columns (calories, fat, sugar…)                                                                                                                  |
| `ingredient_ref`          | Canonical ingredient dictionary                 | `ingredient_id` (identity)              | 2,995 unique ingredients; name_en (UNIQUE), vegan/vegetarian/palm_oil/is_additive/concern_tier flags                                                     |
| `product_ingredient`      | Product ↔ ingredient junction                   | `(product_id, ingredient_id, position)` | ~13,858 rows across 913 products; tracks percent, percent_estimate, sub-ingredients, position order                                                      |
| `product_allergen_info`   | Allergens + traces per product (unified)        | `(product_id, tag, type)`               | ~2,630 rows (1,269 allergens + 1,361 traces) across 655 products; type IN ('contains','traces'); source: OFF allergens_tags / traces_tags                |
| `country_ref`             | ISO 3166-1 alpha-2 country codes                | `country_code` (text PK)                | 2 rows (PL, DE); is_active flag, nutri_score_official boolean; FK from products.country                                                                  |
| `category_ref`            | Product category master list                    | `category` (text PK)                    | 20 rows; FK from products.category; display_name, description, icon_emoji, sort_order                                                                    |
| `nutri_score_ref`         | Nutri-Score label definitions                   | `label` (text PK)                       | 7 rows (A–E + UNKNOWN + NOT-APPLICABLE); FK from scores.nutri_score_label; color_hex, description                                                        |
| `concern_tier_ref`        | EFSA ingredient concern tiers                   | `tier` (integer PK)                     | 4 rows (0–3); FK from ingredient_ref.concern_tier; score_impact, examples, EFSA guidance                                                                 |
| `user_preferences`        | User personalization (country, diet, allergens) | `user_id` (FK → auth.users)             | One row per user; diet enum, allergen arrays, strict_mode flags; RLS by user                                                                             |
| `user_health_profiles`    | Health condition profiles                       | `profile_id` (identity)                 | Conditions + nutrient thresholds (sodium, sugar, sat fat limits). One active profile per user. RLS by user                                               |
| `user_product_lists`      | User-created product lists                      | `list_id` (identity)                    | Name, description, share_token, is_public. Default lists: Favorites, Avoid. RLS by user                                                                  |
| `user_product_list_items` | Items in product lists                          | `(list_id, product_id)`                 | sort_order, notes. FK to user_product_lists + products. RLS by user                                                                                      |
| `user_comparisons`        | Saved product comparisons                       | `comparison_id` (identity)              | product_ids array (2-4), share_token, title. RLS by user                                                                                                 |
| `user_saved_searches`     | Saved search queries                            | `search_id` (identity)                  | Query text, filters JSONB, notification preferences. RLS by user                                                                                         |
| `scan_history`            | Barcode scan history                            | `scan_id` (identity)                    | user_id, ean, scanned_at, product_id (if matched). RLS by user                                                                                           |
| `product_submissions`     | User-submitted products                         | `submission_id` (identity)              | ean, product_name, brand, photo_url, review_notes, status ('pending'/'approved'/'rejected'/'merged'). EAN checksum trigger auto-rejects invalid barcodes |
| `user_trust_scores`       | Per-user submission reputation tracking         | `user_id` (FK → auth.users)             | trust_score 0-100 (default 50). Auto-adjusts: +5 approved, -15 rejected, -5 auto-reject. Counters, flag fields. RLS: service_role only                   |
| `event_schema_registry`   | Schema-versioned event definitions              | `id` (identity)                         | event_type + schema_version UNIQUE; json_schema, status(active/deprecated/retired), pii_fields, retention_days. RLS: anon-read                           |
| `backfill_registry`       | Batch data operation tracking                   | `backfill_id` (uuid PK)                 | name (unique), status, rows_processed/expected, batch_size, rollback_sql, validation_passed. RLS: service-write / auth-read                              |
| `log_level_ref`           | Severity level definitions for structured logs  | `level` (text PK)                       | 5 rows (DEBUG–CRITICAL); numeric_level, retention_days, escalation_target. RLS: service-write / auth-read                                                |
| `error_code_registry`     | Known error codes with domain/category/severity | `error_code` (text PK)                  | {DOMAIN}_{CATEGORY}_{NNN} format; FK to log_level_ref(level); 13 starter codes. RLS: service-write / auth-read                                           |
| `retention_policies`      | Audit log retention configuration               | `policy_id` (identity)                  | table_name (unique), timestamp_column, retention_days (30–3650), is_enabled. RLS: service_role only                                                      |
| `mv_refresh_log`          | Audit trail for MV refreshes                    | `refresh_id` (identity)                 | mv_name, refreshed_at, duration_ms, row_count, triggered_by. Index on (mv_name, refreshed_at DESC). RLS: service-write / auth-read                       |
| `deletion_audit_log`      | GDPR Art.17 deletion audit trail (no PII)       | `id` (uuid)                             | deleted_at (timestamptz), tables_affected (text[]). NO user_id column. RLS enabled, service-role only                                                    |
| `api_rate_limits`         | Per-endpoint rate limit configuration           | `endpoint` (text PK)                    | max_requests, window_seconds, description. 6 seeded endpoints. RLS: auth-read / service-write                                                            |
| `api_rate_limit_log`      | Ephemeral request tracking for rate limiting    | `id` (identity)                         | user_id, endpoint, called_at. Retention: 2 days. Index on (user_id, endpoint, called_at DESC). RLS: service-role only                                    |

### Products Columns (key)

| Column               | Type      | Notes                                                                      |
| -------------------- | --------- | -------------------------------------------------------------------------- |
| `product_id`         | `bigint`  | Auto-incrementing identity                                                 |
| `country`            | `text`    | `'PL'` or `'DE'` — FK to country_ref                                       |
| `brand`              | `text`    | Manufacturer or brand name                                                 |
| `product_name`       | `text`    | Full product name including variant                                        |
| `category`           | `text`    | One of 20 food categories                                                  |
| `product_type`       | `text`    | Subtype (e.g., `'yogurt'`, `'beer'`)                                       |
| `ean`                | `text`    | EAN-13 barcode (unique index)                                              |
| `prep_method`        | `text`    | Preparation method (affects scoring). NOT NULL, default `'not-applicable'` |
| `store_availability` | `text`    | Normalized Polish chain name (Biedronka, Lidl, Żabka, etc.) or NULL        |
| `controversies`      | `text`    | `'none'` or `'palm oil'` etc.                                              |
| `nutri_score_source` | `text`    | Provenance: `'official_label'`, `'off_computed'`, `'manual'`, `'unknown'`  |
| `is_deprecated`      | `boolean` | Soft-delete flag                                                           |
| `deprecated_reason`  | `text`    | Why deprecated                                                             |

### Key Functions

| Function                           | Purpose                                                                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `compute_unhealthiness_v32()`      | Scores 1–100 from 9 factors: sat fat, sugars, salt, calories, trans fat, additives, prep, controversies, ingredient concern                                         |
| `explain_score_v32()`              | Returns JSONB breakdown of score: final_score + 9 factors with name, weight, raw (0–100), weighted, input, ceiling                                                  |
| `find_similar_products()`          | Top-N products by Jaccard ingredient similarity (returns product details + similarity coefficient)                                                                  |
| `find_better_alternatives()`       | Healthier substitutes in same/any category, ranked by score improvement and ingredient overlap                                                                      |
| `assign_confidence()`              | Returns `'verified'`/`'estimated'`/`'low'` from data completeness                                                                                                   |
| `score_category()`                 | Consolidated scoring procedure: Steps 0/1/4/5 (concern defaults, unhealthiness, flags + dynamic `data_completeness_pct`, confidence) for a given category           |
| `compute_data_confidence()`        | Composite confidence score (0-100) with 6 components; band, completeness profile                                                                                    |
| `compute_data_completeness()`      | Dynamic 15-checkpoint field-coverage function for `data_completeness_pct` (EAN, 9 nutrition, Nutri-Score, NOVA, ingredients, allergens, source)                     |
| `api_data_confidence()`            | API wrapper for compute_data_confidence(); returns structured JSONB                                                                                                 |
| `api_product_detail()`             | Single product as structured JSONB (identity, scores, flags, nutrition, ingredients, allergens, trust)                                                              |
| `api_category_listing()`           | Paged category listing with sort (score\|calories\|protein\|name\|nutri_score) + pagination                                                                         |
| `api_score_explanation()`          | Score breakdown + human-readable headline + warnings + category context (rank, avg, relative position)                                                              |
| `api_better_alternatives()`        | Healthier substitutes wrapper with source product context and structured JSON                                                                                       |
| `api_search_products()`            | Full-text + trigram search across product_name and brand; uses pg_trgm GIN indexes                                                                                  |
| `refresh_all_materialized_views()` | Refreshes all MVs concurrently; returns timing report JSONB                                                                                                         |
| `mv_staleness_check()`             | Checks if MVs are stale by comparing row counts to source tables                                                                                                    |
| `check_formula_drift()`            | Compares stored SHA-256 fingerprints against recomputed hashes for active scoring/search formulas                                                                   |
| `check_function_source_drift()`    | Compares registered pg_proc source hashes against actual function bodies for critical functions                                                                     |
| `governance_drift_check()`         | Master drift detection runner — 8 checks across scoring, search, naming conventions, and feature flags                                                              |
| `log_drift_check()`                | Executes governance_drift_check() and persists results into drift_check_results; returns run_id UUID                                                                |
| `validate_log_entry()`             | Validates a structured log JSON entry against LOG_SCHEMA.md spec; returns `{valid: true}` or `{valid: false, errors: [...]}`                                        |
| `execute_retention_cleanup()`      | Deletes audit rows older than retention_policies window; SECURITY DEFINER, dry-run by default, batch deletion via ctid; returns JSONB summary                       |
| `mv_last_refresh()`                | Returns the most recent refresh per MV; columns: mv_name, refreshed_at, duration_ms, row_count, triggered_by, age_minutes                                           |
| `check_flag_readiness()`           | Returns activation readiness status for all feature flags — dependency resolution, expiry tracking, status (ready/blocked/expired/enabled)                          |
| `api_export_user_data()`           | GDPR Art.15/20 — exports all user data as structured JSONB (preferences, health profiles, lists, comparisons, searches, scans). SECURITY DEFINER                    |
| `api_delete_user_data()`           | GDPR Art.17 — cascading delete across 8 tables in FK-safe order; writes anonymized audit to `deletion_audit_log`. SECURITY DEFINER                                  |
| `is_valid_ean()`                   | GS1 checksum validation for EAN-8/EAN-13 barcodes. IMMUTABLE STRICT — returns NULL for NULL, false for invalid                                                      |
| `check_submission_rate_limit()`    | Returns rate limit status for product submissions: 10 per 24h rolling window per user. SECURITY DEFINER                                                             |
| `check_scan_rate_limit()`          | Returns rate limit status for barcode scans: 100 per 24h rolling window per user. SECURITY DEFINER                                                                  |
| `check_api_rate_limit()`           | Generic per-endpoint rate limiter: checks `api_rate_limits` config, logs to `api_rate_limit_log`. Returns `{allowed, remaining}` or blocked JSONB. SECURITY DEFINER |
| `check_share_limit()`              | Per-user share count limiter: max 50 shared items per type (comparisons/lists). Returns `{allowed, type, limit}` JSONB. SECURITY DEFINER                           |
| `score_submission_quality()`       | Scores a submission's quality (0-100) from 7 signals: account age, velocity, EAN match, photo, brand/name quality, user trust score. SECURITY DEFINER              |
| `api_admin_batch_reject_user()`    | Rejects all pending/manual_review/flag_for_review submissions from a user, flags trust score (cap at 10). SECURITY DEFINER                                         |
| `api_admin_submission_velocity()`  | Returns submission velocity stats: last_24h, last_7d, pending_count, auto_rejected_24h, status_breakdown, top_submitters with trust. SECURITY DEFINER              |

### Views

**`v_master`** — Flat denormalized join: products → nutrition_facts + ingredient analytics via LATERAL subqueries on product_ingredient + ingredient_ref (ingredient_count, additive_names, ingredients_raw, has_palm_oil, vegan_status, vegetarian_status, allergen_count/tags, trace_count/tags). Scores, flags, source provenance all inline on products. Includes `score_breakdown` (JSONB), `ingredient_data_quality`, and `nutrition_data_quality` columns. Filtered to `is_deprecated = false`. This is the primary internal query surface.

**`v_api_category_overview`** — Dashboard-ready category statistics. One row per active category (20 total). Includes product_count, avg/min/max/median score, pct_nutri_a_b, pct_nova_4, display metadata from category_ref.

**`v_product_confidence`** — Materialized view of data confidence scores for all active products. Columns: product_id, product_name, brand, category, nutrition_pts(0-30), ingredient_pts(0-25), source_pts(0-20), ean_pts(0-10), allergen_pts(0-10), serving_pts(0-5), confidence_score(0-100), confidence_band(high/medium/low). Unique index on product_id.

**`v_formula_registry`** — Unified view across `scoring_model_versions` and `search_ranking_config`. Columns: domain, version, formula_name, status, weights_config (JSONB), fingerprint (SHA-256), change_reason, is_active. Both scoring and search formulas in one query surface.

---

## 5. Categories (20 PL + 5 DE)

All categories have **variable product counts** (28–95 active products). Categories are expanded by running the pipeline with `--max-products N`. DE categories target ~51 products each.

| Category                   | Folder slug                 |
| -------------------------- | --------------------------- |
| Alcohol                    | `alcohol/`                  |
| Baby                       | `baby/`                     |
| Bread                      | `bread/`                    |
| Breakfast & Grain-Based    | `breakfast-grain-based/`    |
| Canned Goods               | `canned-goods/`             |
| Cereals                    | `cereals/`                  |
| Bread (DE)                 | `bread-de/`                 |
| Breakfast & Grain-Based    | `breakfast-grain-based/`    |
| Canned Goods               | `canned-goods/`             |
| Cereals                    | `cereals/`                  |
| Chips (PL)                 | `chips-pl/`                 |
| Chips (DE)                 | `chips-de/`                 |
| Condiments                 | `condiments/`               |
| Dairy                      | `dairy/`                    |
| Dairy (DE)                 | `dairy-de/`                 |
| Drinks                     | `drinks/`                   |
| Drinks (DE)                | `drinks-de/`                |
| Frozen & Prepared          | `frozen-prepared/`          |
| Instant & Frozen           | `instant-frozen/`           |
| Meat                       | `meat/`                     |
| Nuts, Seeds & Legumes      | `nuts-seeds-legumes/`       |
| Plant-Based & Alternatives | `plant-based-alternatives/` |
| Sauces                     | `sauces/`                   |
| Seafood & Fish             | `seafood-fish/`             |
| Snacks                     | `snacks/`                   |
| Sweets                     | `sweets/`                   |
| Sweets (DE)                | `sweets-de/`                |
| Żabka                      | `zabka/`                    |

**25 pipeline folders** (20 PL + 5 DE). Category-to-OFF tag mappings live in `pipeline/categories.py`. Each category has multiple OFF tags and search terms for comprehensive coverage.

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

**Location:** `supabase/migrations/` — managed by Supabase CLI. Currently **176 migrations**.

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
| `products`              | `chk_products_nutri_score_source`  | NULL or `IN ('official_label','off_computed','manual','unknown')`                                                                                                                                   |
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
| DB QA (714 checks)  | Raw SQL (zero rows = pass)                        | `db/qa/QA__*.sql` (47 suites)                | `.\RUN_QA.ps1`                       |
| Negative validation | SQL injection/constraint tests                    | `db/qa/TEST__negative_checks.sql`            | `.\RUN_NEGATIVE_TESTS.ps1`           |
| DB sanity           | Row-count + schema assertions                     | via `RUN_SANITY.ps1`                         | `.\RUN_SANITY.ps1 -Env local`        |
| Pipeline structure  | Python validator                                  | `check_pipeline_structure.py`                | `python check_pipeline_structure.py` |
| EAN checksum        | Python validator                                  | `validate_eans.py`                           | `python validate_eans.py`            |
| Code quality        | **SonarCloud**                                    | `sonar-project.properties`                   | CI only (main-gate.yml)              |

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
- **Enforced metric**: **Lines coverage** is the primary governance metric (baseline ≥ 88 %). Statements, branches, and functions are tracked in CI output but are not individually gated.
- SonarCloud Quality Gate enforces **coverage on new code ≥ 80 %** (lines). This is the merge-blocking gate; the repo-wide 88 % baseline is a ratchet — it must not decrease but is not a hard gate today.
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

- Use the **same entrypoints** CI uses (`.github/workflows/pr-gate.yml`, `main-gate.yml`, `qa.yml`).
- If a test needs env vars, provide defaults in test setup (not in CI-only secrets).
- If you add a new dependency/tool, ensure it's installed in CI (`package.json` or `requirements.txt`).
- CI workflows (tiered architecture):
  - **`pr-gate.yml`**: Static checks (typecheck + lint) → Unit tests + Build (parallel) → Playwright smoke E2E
  - **`pr-title-lint.yml`**: PR title conventional-commit validation (all PRs)
  - **`main-gate.yml`**: Typecheck → Lint → Build → Unit tests with coverage → Playwright smoke E2E → SonarCloud scan + BLOCKING Quality Gate → Sentry sourcemap upload
  - **`nightly.yml`**: Full Playwright (all projects incl. visual regression) + Data Integrity Audit (parallel)
  - **`qa.yml`**: Pipeline structure guard → Schema migrations → Schema drift detection → Pipelines → QA (714 checks) → Sanity (17 checks) → Confidence threshold
  - **`deploy.yml`**: Manual trigger → Schema diff → Approval gate (production) → Pre-deploy backup → `supabase db push` → Post-deploy sanity
  - **`sync-cloud-db.yml`**: Auto-sync migrations to production on merge to `main`

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
- For rollback procedures, see `DEPLOYMENT.md` → **Rollback Procedures** (5 scenarios + emergency checklist).
- Add a QA check that verifies the migration outcome (row counts, constraint behavior).
- Ensure idempotency (`IF NOT EXISTS`, `ON CONFLICT`, `DO UPDATE SET`).
- Run `.\RUN_QA.ps1` to verify all 714 checks pass + `.\RUN_NEGATIVE_TESTS.ps1` for 23 injection tests.

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

| Suite                     | File                                | Checks | Blocking? |
| ------------------------- | ----------------------------------- | -----: | --------- |
| Data Integrity            | `QA__null_checks.sql`               |     29 | Yes       |
| Scoring Formula           | `QA__scoring_formula_tests.sql`     |     31 | Yes       |
| Source Coverage           | `QA__source_coverage.sql`           |      8 | No        |
| EAN Validation            | `validate_eans.py`                  |      1 | Yes       |
| API Surfaces              | `QA__api_surfaces.sql`              |     18 | Yes       |
| API Contract              | `QA__api_contract.sql`              |     33 | Yes       |
| Confidence Scoring        | `QA__confidence_scoring.sql`        |     14 | Yes       |
| Confidence Reporting      | `QA__confidence_reporting.sql`      |      7 | Yes       |
| Data Quality              | `QA__data_quality.sql`              |     25 | Yes       |
| Ref. Integrity            | `QA__referential_integrity.sql`     |     18 | Yes       |
| View Consistency          | `QA__view_consistency.sql`          |     13 | Yes       |
| Naming Conventions        | `QA__naming_conventions.sql`        |     12 | Yes       |
| Nutrition Ranges          | `QA__nutrition_ranges.sql`          |     18 | Yes       |
| Data Consistency          | `QA__data_consistency.sql`          |     22 | Yes       |
| Allergen Integrity        | `QA__allergen_integrity.sql`        |     15 | Yes       |
| Allergen Filtering        | `QA__allergen_filtering.sql`        |      6 | Yes       |
| Serving & Source          | `QA__serving_source_validation.sql` |     16 | Yes       |
| Ingredient Quality        | `QA__ingredient_quality.sql`        |     14 | Yes       |
| Security Posture          | `QA__security_posture.sql`          |     41 | Yes       |
| Scale Guardrails          | `QA__scale_guardrails.sql`          |     23 | Yes       |
| Country Isolation         | `QA__country_isolation.sql`         |     11 | Yes       |
| Diet Filtering            | `QA__diet_filtering.sql`            |      6 | Yes       |
| Barcode Lookup            | `QA__barcode_lookup.sql`            |      9 | Yes       |
| Auth & Onboarding         | `QA__auth_onboarding.sql`           |      8 | Yes       |
| Health Profiles           | `QA__health_profiles.sql`           |     14 | Yes       |
| Lists & Comparisons       | `QA__lists_comparisons.sql`         |     15 | Yes       |
| Scanner & Submissions     | `QA__scanner_submissions.sql`       |     15 | Yes       |
| Index & Temporal          | `QA__index_temporal.sql`            |     19 | Yes       |
| Attribute Contradictions  | `QA__attribute_contradiction.sql`   |      5 | Yes       |
| Monitoring & Health       | `QA__monitoring.sql`                |     14 | Yes       |
| Scoring Determinism       | `QA__scoring_determinism.sql`       |     17 | Yes       |
| Multi-Country Consistency | `QA__multi_country_consistency.sql` |     10 | Yes       |
| Performance Regression    | `QA__performance_regression.sql`    |      6 | No        |
| Event Intelligence        | `QA__event_intelligence.sql`        |     18 | Yes       |
| Store Architecture        | `QA__store_integrity.sql`           |     12 | Yes       |
| Data Provenance           | `QA__data_provenance.sql`           |     25 | Yes       |
| Scoring Engine            | `QA__scoring_engine.sql`            |     25 | Yes       |
| Search Architecture       | `QA__search_architecture.sql`       |     26 | Yes       |
| GDPR Compliance           | `QA__gdpr_compliance.sql`           |     15 | Yes       |
| Push Notifications        | `QA__push_notifications.sql`        |     14 | Yes       |
| Index Verification        | `QA__index_verification.sql`        |     13 | No        |
| Slow Query Detection      | `QA__slow_queries.sql`              |     12 | No        |
| Explain Analysis          | `QA__explain_analysis.sql`          |     10 | No        |
| MV Refresh Cost           | `QA__mv_refresh_cost.sql`           |     10 | No        |
| Governance Drift          | `QA__governance_drift.sql`          |      8 | Yes       |
| RLS Audit                 | `QA__rls_audit.sql`                 |      7 | Yes       |
| Function Security Audit   | `QA__function_security_audit.sql`   |      6 | Yes       |
| **Negative Validation**   | `TEST__negative_checks.sql`         |     23 | Yes       |

**Run:** `.\RUN_QA.ps1` — expects **714/714 checks passing** (+ EAN validation).
**Run:** `.\RUN_NEGATIVE_TESTS.ps1` — expects **23/23 caught**.

### 8.19 Key Regression Tests (Scoring Suite)

These are **anchor products** whose scores must remain stable. If a scoring change causes drift beyond ±2 points, investigate before committing:

- Doritos Sweet Chili ≈ 45 (chips, 7 additives + high concern)
- Coca-Cola Zero (DE) ≈ 13 (zero nutrition, 8 additives + concern)
- Piątnica Skyr Naturalny ≈ 8 (healthiest dairy, fermented)
- Melvit Płatki owsiane górskie ≈ 13 (healthiest cereal)
- Auchan Tortilla Pszenno-Żytnia ≈ 30 (bread, 9 additives + concern)
- Tarczyński Kabanosy wieprzowe ≈ 31 (high-fat cured meat)
- BoboVita Kaszka Mleczna ≈ 34 (baby food, high sugars)
- Somersby Blueberry Cider ≈ 10 (alcohol regression)
- Mestemacher Chleb wielozbożowy ≈ 18 (bread regression, baked)
- Marinero Łosoś wędzony ≈ 29 (smoked salmon regression)
- Dr. Oetker Pizza 4 sery ≈ 32 (frozen pizza, palm oil)
- Lajkonik Paluszki extra cienkie ≈ 31 (snacks regression, baked)
- Naleśniki z jabłkami ≈ 16 (żabka, low score)
- Pudliszki Ketchup łagodny ≈ 18 (condiments, sugar + salt)
- E. Wedel Czekolada Tiramisu ≈ 57 (sweets, palm oil + additives)
- Indomie Noodles Chicken ≈ 55 (instant, palm oil + 10 additives)

Run QA after **every** schema change, data update, or scoring formula adjustment.

### 8.20 pgTAP Tests for API Functions & Views

If you **modify, rename, or add** any SQL function or view used by the app API (any `api_*` function, `v_*` view, or `mv_*` materialized view), you **must** add or update the corresponding pgTAP test in `supabase/tests/`.

**Current test files:**

| File                            | Covers                                                                                                                       |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `scanner_functions.test.sql`    | `api_record_scan`, `api_get_scan_history`                                                                                    |
| `product_functions.test.sql`    | `api_product_detail_by_ean`, `api_product_detail`, `api_better_alternatives`, `api_score_explanation`, `api_data_confidence` |
| `category_functions.test.sql`   | `api_category_overview`, `api_category_listing`                                                                              |
| `search_functions.test.sql`     | `api_search_products`, `api_search_autocomplete`, `api_get_filter_options`                                                   |
| `comparison_functions.test.sql` | `api_get_products_for_compare`, `api_save_comparison`, `api_get_shared_comparison`                                           |
| `telemetry_functions.test.sql`  | `api_track_event`, `api_admin_get_event_summary`, `api_admin_get_top_events`, `api_admin_get_funnel`                         |
| `dashboard_functions.test.sql`  | `api_record_product_view`, `api_get_recently_viewed`, `api_get_dashboard_data`                                               |
| `user_functions.test.sql`       | Auth-error branches for all `authenticated`-only functions                                                                   |
| `schema_contracts.test.sql`     | Table/view/function existence checks                                                                                         |

**Rules:**

1. Every new `api_*` function must have at least a `lives_ok` test and response-key assertions.
2. Auth-required functions: test the error branch (returns `{api_version, error}` when `auth.uid()` is NULL).
3. No-auth functions: test with fixture data — insert test rows, call the function, assert keys and values.
4. Schema contract tests: add `has_table` / `has_view` / `has_function` for any new schema object.
5. Run `supabase test db` to verify all pgTAP tests pass before committing.

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

**Commit convention:** [Conventional Commits](https://www.conventionalcommits.org/) — **enforced on PR titles** via `pr-title-lint.yml`. Full convention documented in `CHANGELOG.md`.

```
<type>(<scope>): <description>
```

**Types** (12, enforced at error level):
`feat` · `fix` · `schema` · `data` · `score` · `docs` · `test` · `ci` · `refactor` · `perf` · `security` · `chore`

**Scopes** (24, enforced at warning level):
`frontend` · `api` · `scoring` · `search` · `pipeline` · `qa` · `migration` · `products` · `nutrition` · `rls` · `auth` · `config` · `deps` · `v32` · `confidence` · `provenance` · `docs` · `ci` · `build` · `e2e` · `vitest` · `playwright` · `security` · `cleanup`

**Examples:**

```
feat(dairy): add Piątnica product line
fix(scoring): correct salt ceiling from 1.5 to 3.0
schema(migration): add ean column to products
data(pipeline): normalize categories to 28 products
security(rls): lock down product_submissions to authenticated users
```

**Breaking changes:** Append `!` after type/scope — `schema(migration)!: rename products.source to source_type`

**Pre-commit checklist:**

1. `.\RUN_QA.ps1` — 460/460 pass
2. No credentials in committed files
3. No modifications to existing `supabase/migrations/`
4. Docs updated if schema or methodology changed
5. `CHANGELOG.md` updated (add entry under `[Unreleased]`)

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

---

## 15. Feature Implementation Standard (Mandatory for All Major Features)

> **Gold standard:** [Issue #184 — Automated Data Integrity Audits (Nightly)](https://github.com/ericsocrat/poland-food-db/issues/184)
>
> Every significant issue must follow this structure. **No exceptions.**
> A "significant issue" is any change that introduces new tables, modifies API contracts, adds scoring dimensions, expands to new countries/languages, touches more than ~5 files, or introduces new CI/infrastructure workflows.
>
> Issue #184 was selected as the exemplar across all 89+ issues in this repo because it:
>
> - Covers **every required section** with specific, actionable content (not boilerplate)
> - Spans **multiple layers** (SQL + Python + CI + docs) demonstrating the template works for cross-cutting work
> - Was **implemented and closed** — proving the template is practical, not aspirational
> - Represents a **common issue shape** (infra + data quality) that is easily adapted to features, bugs, or governance work
>
> **When creating any new issue, start from the template in §15.18 and adapt it to your scope.**

### 15.1 Problem Statement

Every feature issue must open with:

- **What user problem does this solve?** (concrete scenario, not abstract)
- **What current limitation exists?** (link to specific code/schema gaps)
- **What measurable improvement does this introduce?** (quantifiable: new rows, faster queries, fewer clicks, new coverage %)

> Example (from #184): "No automated system to detect data quality issues — contradictions, impossible values, and orphans accumulate silently and erode trust in health recommendations."

### 15.2 Architectural Evaluation

Evaluate **at least 2–3 approaches** in a comparison table:

| Approach | Verdict     | Reason |
| -------- | ----------- | ------ |
| A. ...   | ❌ Rejected | ...    |
| B. ...   | ❌ Rejected | ...    |
| C. ...   | ✅ Chosen   | ...    |

Rules:

- **Explicitly reject** inferior approaches with rationale.
- **Reference prior art** — how do Yuka, Open Food Facts, MyFitnessPal, or similar platforms solve this?
- **Consider scale** — will this work at 10 countries, 10K products, 100K users?
- **Document assumptions** that informed the choice.
- Preference order: extend existing patterns > new pattern > new dependency > new extension.

### 15.3 Core Principles (Invariants)

Define rules that **must never be violated** during implementation:

| Category                    | Examples from this project                                                                                  |
| --------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Data integrity**          | Never invent nutrition data. `product_name` is the legal label — never modify it.                           |
| **Backward compatibility**  | All API changes must be additive. No breaking changes to response shapes.                                   |
| **Idempotency**             | Every migration safe to run 1× or 100×. Use `IF NOT EXISTS`, `ON CONFLICT DO UPDATE`.                       |
| **Test coverage**           | All new SQL functions must have pgTAP tests (§8.20). No exceptions.                                         |
| **Country isolation**       | All queries scoped by `country`. No cross-contamination between PL and DE data.                             |
| **No runtime dependencies** | No live translation APIs, no external calls at query time.                                                  |
| **Append-only migrations**  | Never modify an existing `supabase/migrations/` file.                                                       |
| **\_ref table pattern**     | Extensible domain values use `_ref` tables + FK, not CHECK constraints (unless the domain is truly closed). |

Every feature must restate **which invariants apply** and confirm they are preserved.

### 15.4 Phased Implementation Plan

Complex features must be broken into **sequential phases**. Each phase must document:

| Field                     | Required                                                  |
| ------------------------- | --------------------------------------------------------- |
| Phase title & scope       | ✅                                                        |
| Commit reference(s)       | ✅ (after shipping)                                       |
| Migration filename        | ✅ (e.g., `20260216000800_localization_phase1.sql`)       |
| Rationale                 | ✅ Why this order? What does this phase unlock?           |
| DB changes                | ✅ Tables, columns, functions, triggers, indexes          |
| API changes               | ✅ Modified `api_*` functions, new/changed parameters     |
| Frontend changes          | ✅ Components, hooks, stores, pages affected              |
| Search/index implications | ✅ `search_vector` trigger updates, new GIN indexes       |
| Performance implications  | ✅ New indexes, materialized views, query plan impact     |
| i18n implications         | ✅ New dictionary keys, translated category/product names |

**Phase ordering rules:**

1. Foundation/schema first (no data dependency)
2. Data population second (depends on schema)
3. API surface third (depends on data)
4. Frontend/UX last (depends on API)

Each phase must be **independently shippable** — the system must work correctly after each phase, even if later phases haven't been implemented.

### 15.5 Database Changes

For **every** schema change:

| Requirement                    | Details                                                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| Migration filename             | Follows `YYYYMMDDHHMMSS_description.sql` (Supabase convention)                                                      |
| Idempotent design              | `CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`, `DO UPDATE SET`                                           |
| Constraints defined explicitly | All domain constraints as CHECK or FK                                                                               |
| FK over CHECK when extensible  | Use `_ref` table + FK when the domain will grow (e.g., `language_ref` instead of `CHECK (language IN ('en','pl'))`) |
| Fallback behavior              | DEFAULT values documented, NULL semantics explained                                                                 |
| Index strategy                 | Justify every new index. GIN for JSONB/tsvector, B-tree for FK lookups, partial indexes where appropriate           |
| Rollback note                  | Comment in migration file: "To roll back: DROP TABLE/COLUMN IF EXISTS ..."                                          |

**SQL code patterns to follow (mandatory):**

```sql
-- ✅ Correct: _ref table for extensible domains
CREATE TABLE IF NOT EXISTS public.language_ref (
    code text PRIMARY KEY,
    name_en text NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true
);

-- ✅ Correct: FK instead of CHECK for growing domains
ALTER TABLE user_preferences
  ADD COLUMN preferred_language text NOT NULL DEFAULT 'en'
  REFERENCES language_ref(code);

-- ❌ Wrong: CHECK for domains that will grow
ALTER TABLE user_preferences
  ADD CONSTRAINT chk_language CHECK (preferred_language IN ('en','pl','de'));
```

### 15.6 API Contract Impact

For each modified `api_*` function, document:

| Field                               | Required                                               |
| ----------------------------------- | ------------------------------------------------------ |
| Function name                       | ✅                                                     |
| New/changed parameters              | ✅ (with defaults for backward compat)                 |
| Response shape changes              | ✅ (new keys are additive, never remove existing keys) |
| Backward compatibility confirmation | ✅ Explicit "existing callers unaffected" statement    |
| Fallback logic                      | ✅ What happens if new param is NULL/omitted?          |
| Auth requirement                    | ✅ `anon` vs `authenticated` — unchanged?              |
| Test coverage                       | ✅ pgTAP test file + test names                        |
| `docs/API_CONTRACTS.md` updated     | ✅                                                     |
| `docs/FRONTEND_API_MAP.md` updated  | ✅ (if frontend wiring changes)                        |

**Golden rule:** New parameters must have defaults. Existing response keys must not be removed or renamed. New keys are always safe to add.

### 15.7 Search & Indexing Impact

If the feature touches searchable fields:

| Check                            | Details                                                                                 |
| -------------------------------- | --------------------------------------------------------------------------------------- |
| `search_vector` trigger updated? | Include new columns with appropriate weights (A=names, B=brand, C=category, D=metadata) |
| Weight assignments justified?    | A for primary identifiers, B for secondary, C for categorical, D for supplementary      |
| Extensions required?             | `unaccent` (diacritic folding), `pg_trgm` (fuzzy matching) — both already enabled       |
| Synonym table updated?           | New food terms → `search_synonyms` entries for cross-language search                    |
| Index type appropriate?          | GIN for tsvector/JSONB, GiST for trigram similarity                                     |
| Performance tested?              | EXPLAIN ANALYZE on representative queries, especially with new indexes                  |

### 15.8 UX Impact Metrics

PRs touching UX-visible frontend code must include:

| Check                                            | Reference                               |
| ------------------------------------------------ | --------------------------------------- |
| UX issues have **Impact Metric** section         | `docs/UX_IMPACT_METRICS.md` §2 template |
| New event types documented in metric catalog     | `docs/UX_IMPACT_METRICS.md` §4          |
| Event names follow `{domain}_{object}_{action}`  | `docs/UX_IMPACT_METRICS.md` §3          |
| Measurement SQL template provided                | `docs/UX_IMPACT_METRICS.md` §5          |
| UI Performance Budget completed (new components) | `docs/UX_IMPACT_METRICS.md` §6          |

### 15.9 Fallback Logic Definition

Define **explicit** fallback chains. Never rely on implicit behavior.

**Standard pattern (from Issue #184):**

```
audit_severity_exit_code:
  If any critical findings exist → exit(1) → CI fails → alert triggers
  Else if warnings exist → exit(0) → CI passes → logged for review
  Else → exit(0) → clean run

resolve_language(p_language):
  If p_language is valid and enabled in language_ref → use it
  Else if user has preferred_language set → use that
  Else → 'en' (universal fallback)
```

Every feature with conditional logic must document its fallback chain in this format:

```
If A → use X
Else if B → use Y
Else → fallback Z (always safe, always returns a value)
```

### 15.10 Test Requirements (Mandatory)

No feature is complete without **all** of these:

#### pgTAP Tests (`supabase/tests/*.test.sql`)

| Category          | Examples                                                                 |
| ----------------- | ------------------------------------------------------------------------ |
| Schema existence  | `has_table('language_ref')`, `has_column('products', 'product_name_en')` |
| Constraints       | FK validation, CHECK constraint enforcement                              |
| Function behavior | Happy path: correct inputs → expected outputs                            |
| Edge cases        | NULL inputs, empty strings, invalid codes, disabled flags                |
| Fallback logic    | `resolve_language('xx')` → falls back to `'en'`                          |
| Negative tests    | Invalid inputs rejected, auth failures return error JSONB                |
| Auth branches     | Unauthenticated calls to `authenticated`-only functions return `{error}` |

#### Schema Contract Tests (`supabase/tests/schema_contracts.test.sql`)

Add for **every** new schema object:

- `has_table('new_table')` / `has_view('new_view')`
- `has_column('table', 'new_column')`
- `has_function('new_function')`

#### Database QA Checks (`db/qa/QA__*.sql`)

- Add checks to appropriate existing suite (don't create new suites unless the domain is genuinely new).
- Update check count in header comment and §8.18 table.
- Run `.\RUN_QA.ps1` — all checks must pass.

#### Frontend Tests

| Check                     | Tool            | Command                                                                |
| ------------------------- | --------------- | ---------------------------------------------------------------------- |
| TypeScript compiles clean | `tsc`           | `cd frontend && npx tsc --noEmit`                                      |
| Dictionary parity         | Vitest          | Assert `Object.keys(en) ≡ Object.keys(pl)` for all i18n keys           |
| State management          | Vitest          | Zustand store tests for new state                                      |
| RPC contract              | Vitest          | Mock Supabase, assert request/response shapes                          |
| Component rendering       | Testing Library | New UI components have co-located `.test.tsx`                          |
| E2E flows                 | Playwright      | If new pages/routes, add to `smoke.spec.ts` or `authenticated.spec.ts` |

### 15.11 Performance & Safety

Every feature must pass these checks:

| Rule                       | Verification                                                                              |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| No N+1 queries             | `EXPLAIN ANALYZE` on new queries; use JOINs/LATERAL/CTEs, not loops                       |
| No unbounded loops         | Defensive LIMIT caps on all expansion/aggregation logic                                   |
| No unindexed JSONB lookups | GIN index required for any `jsonb @>` or `->>` filter in WHERE clauses                    |
| Defensive caps             | Scale guardrails: `QA__scale_guardrails.sql` checks pass                                  |
| Graceful degradation       | Features with `is_enabled` flags must work correctly when disabled                        |
| MV refresh considered      | If new MV added, include in `refresh_all_materialized_views()` and `mv_staleness_check()` |
| No expensive triggers      | Triggers must be O(1) per row; bulk operations must not cascade pathologically            |

### 15.12 Decision Log

Every feature must include an **Architectural Decisions Log** table:

| Decision              | Choice            | Rationale                                          |
| --------------------- | ----------------- | -------------------------------------------------- |
| Storage pattern for X | `_ref` table + FK | Follows established pattern, INSERT-only expansion |
| Translation approach  | Curated + stored  | No runtime API calls, searchable, consistent       |
| ...                   | ...               | ...                                                |

Log **all** non-trivial choices. If you debated between two approaches for more than 30 seconds, it belongs in the decision log.

### 15.13 Constraints (Restated)

Every feature must explicitly restate:

- **What must not break** — list affected API functions, views, QA suites
- **What must remain immutable** — e.g., `product_name` is legal label text
- **What must remain backward compatible** — existing callers, existing response shapes
- **What URLs must remain stable** — no slug/route changes without redirect migration

### 15.14 File Impact Summary

At the end of every feature issue, include:

```
## File Impact

**N files changed, +X / -Y lines** across all phases:
- N new DB migrations (X lines)
- N new/modified pgTAP test files (X lines)
- N new/modified QA suites (checks: before → after)
- N new/modified frontend files (X lines)
- N i18n dictionary changes (X new keys)
```

This enables quick impact assessment during code review.

### 15.15 i18n & Localization Impact

If the feature adds user-visible strings or data:

| Check                            | Action                                                                                                      |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| New UI strings?                  | Add to `/messages/en.json` (source of truth) + `/messages/pl.json`                                          |
| New category/domain labels?      | Add to `category_translations` or equivalent `_translations` table                                          |
| New product data columns?        | Consider `_en` column + provenance metadata (`_source`, `_reviewed_at`)                                     |
| New searchable text?             | Update `search_vector` trigger + add `search_synonyms` entries                                              |
| Structured data vs display text? | SQL returns structured flags/keys; frontend localizes via dictionary (never embed English in SQL responses) |

### 15.16 Expansion Checklist (If Applicable)

If the feature scales across countries, languages, or markets, provide a step-by-step addition checklist:

| Step | Action                              | Effort       |
| ---- | ----------------------------------- | ------------ |
| 1    | `INSERT INTO country_ref (...)`     | 1 row        |
| 2    | `INSERT INTO language_ref` (if new) | 1 row        |
| 3    | `INSERT INTO category_translations` | ~20 rows     |
| 4    | Create `/messages/{xx}.json`        | ~556 strings |
| ...  | ...                                 | ...          |

Include **estimated effort** (hours/days) for each step.

### 15.17 CI & Deployment Verification

Before a feature is considered complete, verify against all CI gates:

| Gate                | Command                               | Expected                        |
| ------------------- | ------------------------------------- | ------------------------------- |
| Pipeline structure  | `python check_pipeline_structure.py`  | 0 errors                        |
| DB QA               | `.\RUN_QA.ps1`                        | All checks pass (currently 699) |
| Negative tests      | `.\RUN_NEGATIVE_TESTS.ps1`            | All caught (currently 29)       |
| pgTAP tests         | `supabase test db`                    | All pass                        |
| TypeScript          | `cd frontend && npx tsc --noEmit`     | 0 errors                        |
| Unit tests          | `cd frontend && npx vitest run`       | All pass                        |
| E2E smoke           | `cd frontend && npx playwright test`  | All pass                        |
| EAN validation      | `python validate_eans.py`             | 0 failures                      |
| Enrichment identity | `python check_enrichment_identity.py` | 0 violations                    |
| SonarCloud          | CI pipeline (`main-gate.yml`)         | Quality Gate pass               |

### 15.18 Enforcement Rule

**No feature is considered complete unless ALL of the following are true:**

- [ ] All migrations are idempotent
- [ ] pgTAP coverage exists for every new function/table/view
- [ ] Schema contracts updated (`has_table`/`has_column`/`has_function`)
- [ ] Fallback logic documented with explicit chain
- [ ] API backward compatibility confirmed (no removed keys, defaults on new params)
- [ ] QA checks updated and all passing
- [ ] TypeScript compiles clean
- [ ] All test suites pass (unit + E2E + DB QA + negative)
- [ ] Decision log populated
- [ ] File impact summary included
- [ ] `copilot-instructions.md` updated (counts, tables, function list) if schema changed

### 15.19 Issue Template

Use `.github/ISSUE_TEMPLATE/feature.md` for all significant issues. **Every section is required**; mark a section `N/A — [reason]` if genuinely not applicable. Never silently omit a section.

> **Reference implementation:** [Issue #184 — Automated Data Integrity Audits (Nightly)](https://github.com/ericsocrat/poland-food-db/issues/184) — gold standard across all repo issues for structural completeness, actionable depth, and proven implementation.

---

## 16. Repo Hygiene (Enforcement)

> **Policy:** `docs/REPO_GOVERNANCE.md` — full rules and allowed-files list.
> **Automated enforcer:** `scripts/repo_verify.ps1` — 6 deterministic checks, exit 0/1.
> **CI workflow:** `.github/workflows/repo-verify.yml` — runs on push, PRs, and weekly cron.

### When to Run

| Trigger                                | Action                                         |
| -------------------------------------- | ---------------------------------------------- |
| File/directory added, removed, renamed | `pwsh scripts/repo_verify.ps1`                 |
| Doc added or removed in `docs/`        | Script verifies `docs/INDEX.md` parity         |
| New migration added                    | Script verifies timestamp ordering             |
| Before any commit                      | `git status` + `git diff --cached --name-only` |

### What the Script Checks

1. **Root cleanliness** — no `tmp-*`, `qa_*.json`, `_func_dump.txt`, `__api_defs.txt`, `*.log`
2. **Docs index coverage** — every `docs/*.md` listed in `docs/INDEX.md`
3. **ADR naming** — files in `docs/decisions/` match `NNN-*.md`
4. **Migration ordering** — timestamps in `supabase/migrations/` are monotonic
5. **No tracked artifacts** — `coverage/`, `test-results/`, `playwright-report/`, `node_modules/`, `__pycache__/`, `.next/` not in git
6. **No tracked temp files** — no `tmp-*` or `qa_*.json` committed

### Additional Manual Checks (Not Automated)

After **structural changes:**

- `copilot-instructions.md` §3 project layout updated (if directory structure changed)
- `CHANGELOG.md` updated under `[Unreleased]` (if user-visible)
- CI workflow glob patterns verified (if paths changed)

After **API changes:**

- `docs/API_CONTRACTS.md` + `docs/FRONTEND_API_MAP.md` + `docs/api-registry.yaml` updated
- pgTAP contract test added/updated in `supabase/tests/`
- No response keys removed (additive only); new parameters have defaults

### PR Discipline

- One concern per PR (single responsibility)
- Separate structural moves from logic edits; separate data from schema changes
- Include verification output (§8.17) and use conventional commit format (§13)
- CI must be green before merge — never bypass by deleting tests or lowering thresholds
