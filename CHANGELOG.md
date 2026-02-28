# Changelog

All notable changes to the **Poland Food Quality Database** are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/).
This project uses domain-specific categories aligned with the food database domain.
Adheres to [Semantic Versioning](https://semver.org/).

> **Commit convention:** [Conventional Commits](https://www.conventionalcommits.org/) —
> see [Commit Message Convention](#commit-message-convention) below.

---

## [Unreleased]

### Security

- Add API gateway Edge Function (`supabase/functions/api-gateway/`) for write-path
  defense: JWT validation, action-based routing, in-memory sliding-window rate
  limiting (100 scans/day/user), EAN format validation, structured error responses
  with graceful degradation fallback; frontend wrapper `api-gateway.ts` with
  18 Vitest tests (#478)
- Add product submission protection to API gateway (Phase 2): `submit-product`
  action with GS1 EAN checksum validation, input sanitization (field length caps,
  forbidden character rejection), 10/day rate limiting; frontend
  `submitProductViaGateway()` with graceful degradation fallback; 14 new Vitest
  tests (32 total) (#478)
- Add telemetry and search gateway protection (Phase 4): `track-event` action
  (10K/day rate limit, event_name/device_type/event_data validation, payload size
  cap) + `save-search` action (50/day rate limit, name/query sanitization, filters
  validation); frontend `trackEventViaGateway()` and `saveSearchViaGateway()` with
  graceful degradation fallback; 17 new Vitest tests (49 total) (#478)

### Schema & Migrations

- Add Nutri-Score country applicability: `country_ref.nutri_score_official` boolean
  (DE=true, PL=false) + `products.nutri_score_source` provenance column with CHECK
  constraint (`official_label`, `off_computed`, `manual`, `unknown`); backfill 1,128
  scored products as `off_computed`, 102 UNKNOWN as `unknown`; expose in
  `api_product_detail`, `api_category_listing`, `api_score_explanation`; add
  contextual `nutri_score_note` to score explanation; +2 QA data-consistency
  checks, +3 schema-contract tests, +8 pgTAP functional tests (#353)

### CI & Infrastructure

- Add deterministic repo hygiene enforcer: `scripts/repo_verify.ps1` — 6 checks
  (root cleanliness, docs index coverage, ADR naming, migration ordering,
  no tracked artifacts, no temp files) with CI workflow `repo-verify.yml`
  on push/PR/weekly cron (#334)
- Add automated DR drill CI workflow (`.github/workflows/dr-drill.yml`): monthly
  cron + manual dispatch, ephemeral PostgreSQL 17 container, applies all migrations
  + seed + representative pipeline SQL + QA smoke subset, produces JSON report
  artifact (#333)
- Codify monitoring alerts as `monitoring/alerts.yml` (17 alerts extracted from
  ALERT_POLICY.md); add `validate-alerts.yml` CI workflow + `scripts/validate_alerts.py`
  validation script; update ALERT_POLICY.md to reference YAML as source of truth (#332)
- Add Python linter (ruff) with `ruff.toml` config and `python-lint.yml` CI
  workflow; auto-fix 22 violations, resolve remaining 7 manually; enforce on
  PRs touching Python files (#331)

### Documentation

- Add comprehensive brand guidelines (`docs/BRAND_GUIDELINES.md`): 14-section
  visual identity reference covering brand personality, color system (complete
  hex values matching design tokens), typography scale, iconography, illustration
  style, photography direction, component patterns, spacing/layout, motion/animation,
  accessibility (WCAG contrast ratios), full dark mode mapping table, co-branding
  rules, and complete asset inventory; add to `docs/INDEX.md` (#410)
- Design shield-leaf logomark (`docs/assets/logo/`): 3 SVG variants — full-color
  (brand teal gradient + white vein structure + gold accent), dark-mode (lighter
  teal gradient, dark veins, brighter gold), monochrome (`currentColor` silhouette);
  8 PNG exports (16–512px) for favicons, app icons, and social media; add Brand
  Assets section to `docs/INDEX.md` (#407)
- Create wordmark + lockup variants (`docs/assets/logo/`): 2 wordmark SVGs
  (placeholder styled text, light + dark), 4 lockup SVGs — horizontal and
  stacked compositions embedding the logomark with clear-space-governed text
  placement (light + dark variants each); complete §2 Logo Usage in
  `docs/BRAND_GUIDELINES.md` with variant table, clear space rules, minimum
  size rules, and do's/don'ts; add Logo & Brand Mark subsection to asset
  inventory (#408)
- Generate complete favicon set (`frontend/public/`): SVG favicon with CSS
  `prefers-color-scheme` dark-mode media query, multi-size ICO (16+32+48px),
  PNG favicons (16×16, 32×32), Apple touch icon (180×180 with brand logomark
  on white background); replace placeholder emoji icons in `/icons/` with
  proper branded PNGs + SVGs (192, 512px); update `layout.tsx` icon metadata
  with favicon.svg reference and standard PNG sizes (#409)
- Create GitHub social preview image (`docs/assets/banners/`): 1280×640 OpenGraph
  image with logomark, project name, tagline, 5 key stats (1,281 products, 25
  categories, PL+DE, v3.2 engine, 733 QA checks), tech stack pills, on dark teal
  gradient; SVG source + optimized PNG (53 KB); root copy for easy GitHub upload
  (#411)
- Create README hero banner (`docs/assets/banners/`): 1200×340 banner with
  logomark, project name, tagline, abstract data-visualization motif (scattered
  dots + connecting lines), tech stack footer; SVG source + optimized PNG (94 KB);
  shields.io badges row reference markdown (9 badges: build, QA, coverage,
  products, countries, scoring, license, TypeScript, PostgreSQL) (#412)
- Update PWA manifest (`manifest.webmanifest`): correct `theme_color` from
  placeholder green (#16a34a) to brand teal (#0d7377); generate dedicated
  maskable icons (192×192, 512×512) with 40% safe-zone padding on brand teal
  background; separate "any" vs "maskable" icon entries; update `layout.tsx`
  viewport `themeColor` to match (#415)
- Create OpenGraph image (`frontend/public/og-image.png`): 1200×630 PNG (43 KB)
  for social sharing previews (Facebook, LinkedIn, Slack, Discord); centered
  logomark, tagline, 4 stat cards (1,281 products, 2,995 ingredients, 20
  categories, 733 QA checks), tech stack pills, domain URL; dark teal gradient
  matching social-preview visual language; SVG source in `docs/assets/banners/`
  (#417)
- Complete brand meta tag integration in `layout.tsx`: add dual theme-color
  with `prefers-color-scheme` media queries (light=#0d7377, dark=#095456);
  add OpenGraph image reference (og:image, og:image:width/height/alt) pointing
  to `/og-image.png`; add Twitter card image; add `msapplication-TileColor` for
  Windows tile branding (#416)
- Create 20 custom food category icons with outline and filled variants (40 SVGs
  total) in `frontend/public/icons/categories/`; rewrite `CategoryIcon` component
  to use inline SVG path data with `currentColor` support instead of Lucide icons;
  add `variant` prop (`'outline' | 'filled'`); add slug aliasing for country
  variants (chips-pl/chips-de → chips); expand test suite from 22 to 65 tests
  covering variants, aliases, viewBox, and accessibility (#419)
- Design 5 achievement badge illustrations (first-scan, list-builder,
  health-explorer, comparison-pro, profile-complete) in
  `frontend/public/illustrations/achievements/`; circular medal/badge style with
  gold ring, ribbon, and brand-colored thematic center icons; CSS-driven
  locked/unlocked states (grayscale + opacity); `AchievementBadge` React component
  with `unlocked` prop, 3 size presets (32/48/96px), optional label,
  `data-achievement` and `data-unlocked` attributes; 29 Vitest tests covering
  all 5 types × 2 states, accessibility, sizing, label display, and
  utilities (#425)
- Create 8 empty-state SVG illustrations in
  `frontend/public/illustrations/empty-states/` (no-results, no-favorites,
  no-scan-history, no-comparisons, no-lists, no-products-category,
  no-submissions, no-saved-searches); flat/semi-flat style with brand palette,
  dark mode via `prefers-color-scheme` media queries, all under 2.1 KB;
  `EmptyStateIllustration` React component wrapping existing `EmptyState`
  with context-specific SVG illustrations, typed to 8 states, i18n-ready;
  39 Vitest tests covering all 8 types, alt text, actions, image dimensions,
  className passthrough, and utility functions (#423)
- Create 5 onboarding step SVG illustrations (280×280) in
  `frontend/public/illustrations/onboarding/` (welcome, country, diet,
  allergens, ready) and 3 error page SVG illustrations (240×200) in
  `frontend/public/illustrations/errors/` (404, 500, offline); brand palette
  with `prefers-color-scheme` dark mode, all under 3 KB; `OnboardingIllustration`
  component (5 steps, custom dimensions, priority loading) with 32 Vitest tests;
  `ErrorIllustration` component (3 error types, HTTP status metadata) with
  30 Vitest tests; LoadingSpinner and Skeleton components already exist (#424)
- Create 6 feature showcase card SVGs in `docs/marketing/` (400×300 viewBox):
  scoring engine (gauge + 5 factor bars), ingredient analysis (concern tier
  badges), product comparison (side-by-side grid with VS badge), allergen
  filtering (8-allergen status matrix), barcode scanner (phone mockup with
  product result card), smart search (search bar with pg_trgm + filter chips
  + fuzzy results); white card style with brand-colored border, dark mode
  via `prefers-color-scheme` media queries, all under 6 KB (#432)
- Redesign README.md as 15-section showcase-quality layout: hero banner, 9
  shields.io badges, elevator pitch, 4 feature highlight cards (HTML table),
  comparison table, 3-column quick start with collapsible command reference,
  ASCII architecture diagram, scoring engine summary with color-coded bands,
  stats dashboard (12 key metrics), tech stack logo badges (12 tools),
  collapsible project structure, testing overview table + CI pipeline tiers,
  contributing guide, 4 collapsible documentation sections (30+ linked docs),
  license with acknowledgments, branded footer with logomark (#413)
- Harden copilot-instructions.md: rewrite §16 as discovery-driven (script-first),
  extract 240-line issue template to `.github/ISSUE_TEMPLATE/feature.md`,
  reduce from 1,668 to 1,418 lines (under 1,500 cap) (#334)
- Add `API_CONVENTIONS.md` to `docs/INDEX.md` (#334)

### CI & Infrastructure

- Add branch protection as code: `.github/branch-protection.md` documents canonical
  `main` branch protection rules (required reviews, status checks, merge strategy,
  push restrictions) with step-by-step restoration procedure (#325)
- Add structured YAML issue templates: bug report, feature request, and
  data/schema change forms with dropdowns, validation, and template chooser
  config (#324)
- Pin Python dependencies exactly with SHA-256 hashes via pip-compile; add
  `requirements.in` as human-editable source constraints (#323)

### Documentation

- Add ADR framework: `docs/decisions/` with MADR 3.0 template + 7 retroactive
  Architecture Decision Records covering PostgreSQL-only stack, scoring formula,
  country isolation, pipeline architecture, API versioning, append-only migrations,
  and English canonical ingredients (#322)

### Schema & Migrations

- Add alert escalation & query regression detection: `query_performance_snapshots` table,
  `snapshot_query_performance()` function (SECURITY DEFINER), `v_query_regressions` view,
  `v_unused_indexes` / `v_missing_indexes` / `v_index_bloat_estimate` index drift monitoring
  views, RLS Pattern B on snapshot table (#211)
- Add structured log schema & error taxonomy: `log_level_ref` table (5 severity levels with
  retention/escalation policy), `error_code_registry` table (13 starter error codes across 8
  domains), `validate_log_entry()` validation function (SECURITY DEFINER), RLS Pattern B
  (service-write / auth-read) (#210)
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

- Add trust & transparency components: `TrustBadge` (data confidence level),
  `FreshnessIndicator` (data age with fresh/aging/stale thresholds),
  `ScoringVersionBadge` (formula version display), `SearchRelevanceHint`
  (match type indicator), `SourceAttribution` (expandable per-field source
  panel). All components degrade gracefully when backend data is unavailable.
  Includes i18n (en + pl), barrel export, and 70+ co-located Vitest tests (#205)

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

- Sync `README.md` project structure with actual repo layout: remove phantom `db/migrations/`,
  fix `chips/` → `chips-pl/` + add `chips-de/`, expand QA listing from 15 → 45 files,
  expand docs listing from 19 → 49 entries, update migration count 130 → 137, add supabase
  sub-dirs (seed/, sanity/, tests/), add pipeline/, scripts/, .github/workflows/ entries,
  consolidate duplicate supabase/ section, add missing root files (#318)
- Sync `copilot-instructions.md` §3 project layout with actual file tree: add `scripts/` directory
  (7 utility scripts), `trust/` component directory, 6 missing root files (`BACKUP.ps1`,
  `RUN_DR_DRILL.ps1`, `run_data_audit.py`, `test_data_audit.py`, `requirements.txt`,
  `.editorconfig`), 10 missing workflow files, 2 missing pipeline files (`image_importer.py`,
  `test_validator.py`), `REPO_GOVERNANCE.md` to docs listing, supabase sub-directories
  (`seed/`, `sanity/`, `tests/`, `functions/`, `dr-drill/`, `seed.sql`) (#318)
- Add `docs/REPO_GOVERNANCE.md`: 6-section governance standard covering structure rules,
  doc update checklists, root cleanliness, CI integrity, Copilot enforcement, maintenance
  cadence (#316)
- Add `copilot-instructions.md` §16 Repo Hygiene Checklist: 5 enforcement subsections
  (structural changes, API changes, root cleanliness, CI green, PR discipline) (#316)
- Fix stale QA check counts in README: 429/421 → 460 across 33 suites, add 11 missing
  suite listings to Additional Suites section (#316)
- Add `docs/ALERT_POLICY.md`: alert escalation policy with P0–P3 severity tiers,
  escalation chain, on-call rules, slow query thresholds, query regression detection
  architecture, index drift monitoring cadence and action matrix (#211)
- Add `docs/ON_CALL_POLICY.md`: on-call & alert ownership policy — alert source inventory
  (8 sources), alert-to-severity mapping matrix, acknowledgment time targets (SEV-1 through
  SEV-4 with business/off-hours/holiday rules), GitHub issue label taxonomy (severity, source,
  domain labels), quiet hours & deferral policy, ownership transfer protocol (#233)
- Add `docs/LOG_SCHEMA.md`: structured log schema specification, error code format
  (`{DOMAIN}_{CATEGORY}_{NNN}`), 8 registered domains, severity/escalation matrix,
  retention policy (0d–indefinite), domain-specific logging conventions (#210)
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
