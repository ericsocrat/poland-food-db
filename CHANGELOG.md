# Changelog

All notable changes to the **Poland Food Quality Database** are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/).
This project uses domain-specific categories aligned with the food database domain.
Adheres to [Semantic Versioning](https://semver.org/).

> **Commit convention:** [Conventional Commits](https://www.conventionalcommits.org/) —
> see [Commit Message Convention](#commit-message-convention) below.

---

## [Unreleased]

### Schema & Migrations

- Add backfill orchestration framework: `backfill_registry` table with RLS, 5 lifecycle
  functions (`register_backfill`, `start_backfill`, `update_backfill_progress`,
  `complete_backfill`, `fail_backfill`), `v_backfill_status` monitoring view,
  `scripts/backfill_template.py` Python template (#208)
- Add migration convention standard: index naming convention `idx_{table}_{columns}[_{type}]`,
  trigger domain range assignments (10–99 by domain), migration file naming format with header
  block standard, `_TEMPLATE.sql` reference template, `check_migration_conventions.py` validation
  script (133/133 naming compliant) (#207)
- Rename non-conforming triggers on `products` table: `score_change_audit` →
  `trg_products_score_audit`, `trg_record_score_change` → `trg_products_score_history`;
  all 5 products triggers now pass `governance_drift_check()` naming validation (#203)
- Add governance drift detection automation: `governance_drift_check()` master runner (8 checks),
  `log_drift_check()` with `drift_check_results` persistence table, severity levels, and
  trigger naming convention validation (#199)
- Add unified formula registry: `v_formula_registry` view, `formula_source_hashes` table,
  fingerprint columns on `scoring_model_versions` and `search_ranking_config`, auto-fingerprint
  triggers, `check_formula_drift()` and `check_function_source_drift()` sentinel functions (#198)

### Scoring & Methodology

### Data & Pipeline

### API & Backend

### Frontend & UI

### Search & Discovery

### Security & Auth

### Testing & QA

- Add multi-country consistency & performance regression test suites:
  `QA__multi_country_consistency.sql` (10 blocking checks — cross-country scoring
  equivalence, country_ref integrity, DE micro-pilot constraints, data completeness
  parity, recomputed-vs-stored parity across all countries) and
  `QA__performance_regression.sql` (6 informational checks — CI smoke thresholds
  for search, autocomplete, category listing, product detail, score computation,
  better alternatives) (#204)
- Add scoring & search determinism test framework: `QA__scoring_determinism.sql` with 15
  pure-function checks — 5 pinned-score tests, 2 boundary tests, 2 factor-isolation tests,
  2 ordering tests, re-scoring determinism (100 iterations), explain/compute parity,
  stored-vs-recomputed parity, weight-sum verification; search stubs for #204 (#202)
- Extend `QA__scoring_engine.sql` from 17 to 25 checks: add T18-T25 for formula registry view,
  active scoring/search formulas, fingerprint population, drift detection, source hash verification,
  and auto-fingerprint trigger validation (#198)
- Add `QA__governance_drift.sql` with 8 checks: function existence, 8-check return count,
  all-pass clean state, valid severities, non-empty details, results table, logging function,
  unique check names (#199)

### Documentation

- Extend `docs/BACKFILL_STANDARD.md` with backfill registry reference (table schema,
  helper functions, monitoring view, RLS, script template usage) (#208)
- Extend `docs/MIGRATION_CONVENTIONS.md` with index naming convention, trigger domain range
  assignments, migration file naming format, header block standard, and link to `_TEMPLATE.sql`;
  add `scripts/check_migration_conventions.py` validation script (#207)
- Add documentation governance policy (`docs/DOCUMENTATION_GOVERNANCE.md`): ownership model with
  11 domains, 14 update trigger rules, versioning policy with frontmatter requirements,
  deprecation & archival process, drift prevention cadence, 4 health metrics (#201)
- Add migration safety & trigger conventions (`docs/MIGRATION_CONVENTIONS.md`): trigger naming
  standard, 16-trigger inventory, migration safety checklist, file template, idempotency patterns,
  lock risk analysis, rollback procedures (#203)
- Add PR documentation checklist template (`.github/PULL_REQUEST_TEMPLATE.md`) with
  6-item documentation compliance checklist (#201)
- Enrich `docs/INDEX.md` with owner issue assignments for all 40+ documents and add
  DOCUMENTATION_GOVERNANCE.md entry (#201)
- Add drift detection automation guide (`docs/DRIFT_DETECTION.md`): 8-check catalog, severity
  levels, CI integration plan, documentation freshness script, migration ordering validator,
  monthly cadence, historical results schema (#199)
- Add formula registry governance to `docs/SCORING_ENGINE.md`: unified registry view documentation,
  fingerprint-based drift detection guide, 7-step weight change protocol, weight change checklist
  template, and registered function source hashes reference (#198)

- Add incident response playbook (`docs/INCIDENT_RESPONSE.md`) with severity definitions (SEV-1–4),
  escalation ladder, communication templates, blameless post-mortem format, 6 scenario-specific
  runbooks, and SLO breach response procedures
- Cross-reference DEPLOYMENT.md emergency checklist to incident response playbook
- Add domain boundary enforcement and ownership mapping (`docs/DOMAIN_BOUNDARIES.md`) with
  13 domain definitions, shared `products` table column governance, 6 interface contracts,
  cross-domain coupling audit, verification SQL, and naming convention guide
- Add API deprecation and versioning policy (`docs/API_VERSIONING.md`) with function-name
  versioning convention, breaking/non-breaking classification, deprecation window tiers,
  response shape stability contract (v1), sunset checklist, and frontend migration template
- Cross-reference API_CONTRACTS.md to versioning policy
- Add data access pattern audit (`docs/ACCESS_AUDIT.md`) with table-by-role access
  matrix (51 tables), RPC function access analysis, 5 audit SQL templates, quarterly
  audit checklist, and initial audit results
- Add GDPR/RODO privacy compliance checklist (`docs/PRIVACY_CHECKLIST.md`) with
  personal data inventory (10 data categories), data subject rights gap analysis,
  Art. 9 health data special category assessment, data retention policy, cross-border
  transfer analysis, privacy policy content requirements, user data export/deletion
  SQL procedures, and country expansion privacy prerequisites
- Add feature sunsetting and cleanup policy (`docs/FEATURE_SUNSETTING.md`) with
  retirement criteria (6 quantitative + 5 qualitative triggers), 4-phase deprecation
  lifecycle, database object cleanup procedure, tech debt classification (4 tiers),
  feature flag expiration policy, quarterly hygiene review checklist template, and
  initial candidate audit
- Add canonical documentation index (`docs/INDEX.md`) with domain-classified map of
  all 44 markdown files across 10 domains, redundancy assessment (7 pairs investigated,
  no actual redundancy found), obsolete reference audit, removed documents tracking,
  and documentation standards (frontmatter, update triggers, add/archive procedures)
- Restructure `copilot-instructions.md` project layout: alphabetically sort docs
  listing, expand from 25 to 41 entries with 14 previously-unlisted documents
- Add RPC naming convention and security standards (`docs/API_CONVENTIONS.md`) with
  visibility prefix system (api/admin/metric/trg/internal), 16 domain classifications,
  parameter conventions, breaking change definition (6 breaking + 6 non-breaking rules),
  breaking change protocol, and naming compliance audit of all 107 functions
- Add structured API registry (`docs/api-registry.yaml`) with all 107 public-schema
  functions classified by domain, visibility, auth requirement, parameters, return type,
  and P95 latency targets (63 api_*, 7 admin_*, 10 metric_*, 7 trigger, 20 internal)
- Cross-reference API_CONTRACTS.md and FRONTEND_API_MAP.md to conventions and registry

### CI/CD & Infrastructure

---

## [0.1.0] — 2026-02-24 (Project Baseline)

> First structured release of the platform. Captures the cumulative state after
> 130 migrations, 21 pipeline folders, and full frontend implementation.

### Schema & Migrations
- 130 append-only migrations establishing full schema
- 17 tables: `products`, `nutrition_facts`, `ingredient_ref`, `product_ingredient`,
  `product_allergen_info`, 5 reference tables (`country_ref`, `category_ref`,
  `nutri_score_ref`, `concern_tier_ref`, `data_sources`), 6 user tables
  (`user_preferences`, `user_health_profiles`, `user_product_lists`,
  `user_product_list_items`, `user_comparisons`, `user_saved_searches`,
  `scan_history`, `product_submissions`)
- `analytics_events` table with 34 event types (CHECK constraint)
- `product_field_provenance` + `product_change_log` audit trail
- `freshness_policies` + `conflict_resolution_rules` + `country_data_policies`
- 24 CHECK constraints enforcing domain values
- RLS policies on all user-facing tables

### Scoring & Methodology
- Unhealthiness scoring v3.2 — 9-factor weighted formula via `compute_unhealthiness_v32()`
- `explain_score_v32()` returns JSONB breakdown of all 9 factors
- Confidence scoring (0–100) with 6 components via `compute_data_confidence()`
- Dynamic data completeness (15 checkpoints) via `compute_data_completeness()`
- `score_category()` consolidated scoring procedure
- EFSA-based 4-tier ingredient concern classification (0=none to 3=high)

### Data & Pipeline
- 1,076 active products across 20 PL + 1 DE categories
- 2,740 unique ingredients with EFSA concern tiers
- 997/1,025 EAN coverage (97.3%)
- Python pipeline: OFF API v2 → SQL generator → PostgreSQL
- 21 pipeline folders (20 PL + 1 DE), 4–5 SQL files each
- Automated ingredient/allergen enrichment via `enrich_ingredients.py`
- Data provenance tracking with source registry (11 sources)

### API & Backend
- 6 core API RPC functions: `api_product_detail`, `api_category_listing`,
  `api_search_products`, `api_better_alternatives`, `api_score_explanation`,
  `api_data_confidence`
- `api_category_overview` dashboard view
- `api_product_provenance` provenance endpoint
- `find_similar_products()` Jaccard similarity
- Materialized views with concurrent refresh and staleness detection
- `pg_trgm` + `tsvector` full-text search with GIN indexes

### Frontend & UI
- Next.js 15 App Router with Supabase auth
- TanStack Query data layer + Zustand stores
- Health profiles, product lists, comparisons, barcode scanner
- Search autocomplete, filter panel, category browse
- Onboarding flow, user preferences, settings
- Admin panel for product submissions

### Search & Discovery
- `api_search_products` with full-text + trigram search
- `api_search_autocomplete` for type-ahead suggestions
- `api_get_filter_options` for dynamic filter options
- Search synonym support for cross-language queries

### Security & Auth
- Supabase Auth with magic link + OAuth
- RLS on all user tables (preferences, lists, comparisons, scan history)
- `SECURITY DEFINER` functions with `REVOKE`/`GRANT` access control
- Security posture QA suite (22 checks)
- Feature flags with `data_provenance_ui` flag (disabled by default)

### Testing & QA
- 429 checks across 30 QA suites (all blocking)
- 23 negative validation tests (SQL injection, constraint violations)
- 232 frontend test files (Vitest + Testing Library)
- Playwright E2E tests (smoke + authenticated flows)
- pgTAP-style tests for API functions
- SonarCloud quality gates with coverage enforcement
- EAN checksum validator, pipeline structure validator

### Documentation
- 33 docs covering API contracts, scoring methodology, country expansion,
  data provenance, search architecture, UX impact metrics, and more
- Copilot instructions (§1–§15) with governance framework
- Execution Governance Blueprint (#195)

### CI/CD & Infrastructure
- PR Gate: Typecheck → Lint → Build → Unit Tests → Playwright Smoke
- Main Gate: Build → Tests + Coverage → Playwright → SonarCloud
- QA Gate: Pipeline structure → Schema → Pipelines → QA (429) → Sanity
- Nightly: Full Playwright + Data Integrity Audit
- Deploy: Manual trigger → Schema diff → Approval → Backup → Push → Sanity
- Lighthouse CI budgets (mobile + desktop)
- Dependabot auto-merge for safe updates

---

## Commit Message Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | Description                                     | Examples                                                       |
| ---------- | ----------------------------------------------- | -------------------------------------------------------------- |
| `feat`     | New feature or capability                       | `feat(frontend): add health profile settings page`             |
| `fix`      | Bug fix                                         | `fix(scoring): correct prep_method weight for smoked products` |
| `schema`   | Database schema change (new migration)          | `schema(migration): add user_comparisons table`                |
| `data`     | Data changes (pipeline, backfills, corrections) | `data(pipeline): expand dairy category to 85 products`         |
| `score`    | Scoring formula or methodology change           | `score(v32): add ingredient concern tier`                      |
| `docs`     | Documentation only                              | `docs(api-contracts): document response shape`                 |
| `test`     | Test additions or changes                       | `test(qa): add 14 allergen integrity checks`                   |
| `ci`       | CI/CD workflow changes                          | `ci(build): add SonarCloud coverage upload`                    |
| `refactor` | Code restructuring (no behavior change)         | `refactor(pipeline): extract validator module`                 |
| `perf`     | Performance improvement                         | `perf(index): add GIN index for allergen search`               |
| `security` | Security-related change                         | `security(rls): add policy for scan_history`                   |
| `chore`    | Maintenance tasks                               | `chore(deps): update TanStack Query to v5`                     |

### Breaking Changes

Append `!` after type/scope for breaking changes:

```
schema!(migration): drop column_metadata table

BREAKING CHANGE: column_metadata table removed. All references must use
products.data_completeness_pct instead.
```

### Breaking Change Detection Checklist

Changes that **MUST** be flagged as breaking in commits and changelog:

- Scoring formula change (`compute_unhealthiness_v32` signature or weights)
- API RPC function signature change (parameters added/removed/retyped)
- API response shape change (columns removed from views)
- Table column removed or renamed
- CHECK constraint domain changed (e.g., new `prep_method` value)
- RLS policy changed (access pattern affected)
- Category added or removed (affects `category_ref`)
- Country activated or deactivated (affects `country_ref`)
- Migration that requires data backfill

---

## Semantic Versioning Strategy

| Version Bump      | Trigger                                                  | Examples                             |
| ----------------- | -------------------------------------------------------- | ------------------------------------ |
| **Major** (X.0.0) | Breaking API change, scoring overhaul, schema redesign   | Scoring v4.0, API v2 incompatible    |
| **Minor** (0.X.0) | New feature, new category, new country, new API endpoint | Add comparison, expand to DE         |
| **Patch** (0.0.X) | Bug fix, QA fix, data correction, docs update            | Fix scoring regression, correct EANs |

**Current version:** `v0.1.0` (pre-public-release baseline)

---

[Unreleased]: https://github.com/ericsocrat/poland-food-db/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ericsocrat/poland-food-db/releases/tag/v0.1.0
