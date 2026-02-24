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

### Scoring & Methodology

### Data & Pipeline

### API & Backend

### Frontend & UI

### Search & Discovery

### Security & Auth

### Testing & QA

### Documentation

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
