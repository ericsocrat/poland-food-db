# Domain Boundary Enforcement & Ownership Mapping

> **Last updated:** 2026-02-28
> **Owner:** Eric (sole maintainer)
> **Scope:** All database objects, API functions, frontend modules
> **Purpose:** Prevent implicit coupling between workstreams by defining explicit ownership and interaction contracts

---

## 1. Purpose

As the platform grows with multiple architecture workstreams (#183, #185, #189–#193),
overlapping surfaces (the `products` table, the RPC layer, frontend components, and the
pipeline) create risk of implicit coupling. This document defines:

1. **Domain boundaries** — which workstream owns which DB objects, functions, and frontend modules
2. **Interface contracts** — how domains communicate with each other
3. **Shared table governance** — column-level ownership for the shared `products` table
4. **Verification method** — how to audit cross-domain coupling

**Rule:** A domain may only write to objects it owns. Cross-domain interaction must use
defined interface contracts, never direct access to another domain's internals.

---

## 2. Domain Definitions

### 2.1 Core Product Domain

**Scope:** Product identity, nutrition, ingredients, allergens — the foundational data model.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `products`, `nutrition_facts`, `ingredient_ref`, `product_ingredient`, `product_allergen_info`, `product_images`    |
| Ref      | `country_ref`, `category_ref`, `nutri_score_ref`, `concern_tier_ref`, `daily_value_ref`                            |
| Views    | `v_master`                                                                                                         |
| Functions| `api_product_detail()`, `api_category_listing()`, `api_better_alternatives()`, `api_product_detail_by_ean()`       |
| Frontend | `components/product/*`, `lib/rpc-contracts/product.ts`, `lib/rpc-contracts/category.ts`, `lib/nutri-label.ts`, `lib/nutrition-banding.ts` |
| Pipeline | `pipeline/*`, `db/pipelines/*`                                                                                     |

### 2.2 Scoring Domain

**Scope:** Health score computation, score explanation, score history, audit trail.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `scoring_model_versions`, `score_audit_log`, `score_shadow_results`, `score_distribution_snapshots`, `product_score_history` |
| Functions| `compute_unhealthiness_v32()`, `explain_score_v32()`, `score_category()`, `api_score_explanation()`                 |
| Columns  | `products.unhealthiness_score`, `products.high_sugar_flag`, `products.high_salt_flag`, `products.high_fat_flag`, `products.high_calories_flag`, `products.data_completeness_pct` |
| Frontend | `components/product/ScoreBreakdownPanel`, `components/product/ScoreGauge`, `components/product/ScoreRadarChart`, `components/product/ScoreTrendChart`, `components/product/ScoreChangeIndicator`, `components/product/TrafficLightChip`, `components/product/TrafficLightStrip`, `components/dashboard/ScoreSparkline` |

### 2.3 Search & Discovery Domain

**Scope:** Product search, autocomplete, search ranking, saved searches, filter options.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `search_synonyms`, `search_ranking_config`, `user_saved_searches`                                                  |
| Functions| `api_search_products()`, `api_search_autocomplete()`, `api_get_filter_options()`                                   |
| Frontend | `components/search/*`, `lib/rpc-contracts/search.ts`, `lib/recent-searches.ts`, `hooks/use-active-route.ts`        |

### 2.4 Data Provenance Domain

**Scope:** Source tracking, field-level provenance, data freshness, conflict resolution, cross-validation.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `data_sources`, `product_sources`, `source_nutrition`, `product_field_provenance`, `product_change_log`, `freshness_policies`, `conflict_resolution_rules`, `data_conflicts`, `country_data_policies` |
| Functions| `record_field_provenance()`, `record_bulk_provenance()`, `detect_stale_products()`, `detect_conflict()`, `resolve_conflicts_auto()`, `validate_product_for_country()`, `field_to_group()`, `api_product_provenance()`, `admin_provenance_dashboard()`, `compute_provenance_confidence()` |
| Triggers | `trg_product_change_log()` on `products`                                                                           |
| Columns  | `products.source_type`, `products.source_url`, `products.last_verified_at`                                         |
| Frontend | `lib/rpc-contracts/provenance.ts`                                                                                  |

### 2.5 Confidence & Quality Domain

**Scope:** Data confidence scoring, completeness measurement, quality metrics.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Functions| `compute_data_confidence()`, `compute_data_completeness()`, `assign_confidence()`, `api_data_confidence()`         |
| Views    | `v_product_confidence` (MV), `v_confidence_distribution`, `v_data_gap_summary`, `v_completeness_by_country`        |
| Columns  | `products.confidence`                                                                                              |
| Tables   | `audit_results`                                                                                                    |

### 2.6 User Domain

**Scope:** User preferences, health profiles, product lists, comparisons, scan history, submissions.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `user_preferences`, `user_health_profiles`, `user_product_lists`, `user_product_list_items`, `user_comparisons`, `user_saved_searches`, `user_watched_products`, `user_product_views`, `scan_history`, `product_submissions`, `deletion_audit_log` |
| Functions| `api_record_scan()`, `api_get_scan_history()`, `api_save_comparison()`, `api_get_shared_comparison()`, `api_get_products_for_compare()`, `api_record_product_view()`, `api_get_recently_viewed()`, `api_get_dashboard_data()` |
| Frontend | `components/settings/*`, `components/compare/*`, `hooks/use-compare.ts`, `hooks/use-lists.ts`, `hooks/use-product-allergens.ts`, `stores/avoid-store.ts`, `stores/compare-store.ts`, `stores/favorites-store.ts`, `lib/rpc-contracts/lists.ts`, `lib/rpc-contracts/compare.ts`, `lib/rpc-contracts/health-profile.ts`, `lib/rpc-contracts/scan.ts`, `lib/rpc-contracts/user.ts`, `lib/allergen-matching.ts` |

### 2.7 Analytics & Telemetry Domain

**Scope:** Behavioral telemetry, event tracking, daily aggregates.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `analytics_events`, `allowed_event_names`, `analytics_daily`                                                       |
| Functions| `api_track_event()`, `api_admin_get_event_summary()`, `api_admin_get_top_events()`, `api_admin_get_funnel()`       |
| Frontend | `hooks/use-analytics.ts`, `lib/events/*`, `lib/api-instrumentation.ts`                                             |

### 2.8 Feature Flags Domain

**Scope:** Feature flag evaluation, per-user overrides, audit trail.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `feature_flags`, `flag_overrides`, `flag_audit_log`                                                                |
| Frontend | `lib/flags/*` (`evaluator.ts`, `hooks.tsx`, `server.ts`, `types.ts`)                                               |

### 2.9 Achievement & Gamification Domain

**Scope:** Achievement definitions, user progression.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `achievement_def`, `user_achievement`                                                                              |
| Frontend | `components/achievements/*`, `hooks/use-achievements.ts`, `lib/events/achievement-map.ts`, `lib/events/achievement-middleware.ts` |

### 2.10 Recipe Domain

**Scope:** Recipe management, ingredient-to-product linking.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `recipe`, `recipe_step`, `recipe_ingredient`, `recipe_ingredient_product`                                          |
| Frontend | `components/recipes/*`                                                                                             |

### 2.11 Localization Domain

**Scope:** Multi-language support, category translations.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `category_translations`, `language_ref`                                                                            |
| Views    | `localization_metrics`                                                                                             |
| Frontend | `components/i18n/*`, `stores/language-store.ts`, `lib/i18n.ts`, `messages/*`                                       |

### 2.12 Infrastructure & Platform Domain

**Scope:** MV management, push notifications, platform health.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Tables   | `push_subscriptions`, `notification_queue`                                                                         |
| Functions| `refresh_all_materialized_views()`, `mv_staleness_check()`                                                         |
| Frontend | `components/pwa/*`, `lib/push-manager.ts`, `lib/cache-manager.ts`, `lib/supabase/*`, `hooks/use-install-prompt.ts`, `hooks/use-online-status.ts` |

### 2.13 Shared / Cross-Cutting

**Scope:** Components, utilities, and types used by multiple domains.

| Layer    | Owned Objects                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------|
| Views    | `v_api_category_overview`, `v_api_category_overview_by_country`, `mv_ingredient_frequency`, `mv_product_similarity` |
| Frontend | `components/common/*`, `components/layout/*`, `components/dashboard/*`, `components/learn/*`, `components/desktop/*`, `components/export/*`, `components/ocr/*`, `lib/types.ts`, `lib/constants.ts`, `lib/validation/*`, `lib/query-keys.ts`, `lib/rpc.ts`, `lib/api.ts`, `lib/share.ts`, `lib/toast.ts`, `lib/download.ts`, `lib/export.ts`, `lib/error-reporter.ts`, `lib/logger.ts`, `lib/qa-mode.ts`, `lib/rate-limiter.ts`, `lib/pluralize.ts`, `lib/typography.ts`, `hooks/use-theme.ts`, `hooks/use-reduced-motion.ts`, `Providers.tsx`, `ThemeScript` |

---

## 3. Shared Table Governance: `products`

The `products` table is the most coupled object in the schema. Multiple domains read from it,
but writes must be scoped by column ownership.

### Column Ownership

| Domain          | Owned Columns                                                                                |
|-----------------|----------------------------------------------------------------------------------------------|
| **Core**        | `product_id`, `country`, `brand`, `product_name`, `category`, `product_type`, `ean`, `prep_method`, `store_availability`, `is_deprecated`, `deprecated_reason`, `controversies`, `ingredients_raw` |
| **Scoring**     | `unhealthiness_score`, `high_sugar_flag`, `high_salt_flag`, `high_fat_flag`, `high_calories_flag`, `data_completeness_pct`, `nutri_score_label`, `nova_group` |
| **Confidence**  | `confidence`                                                                                  |
| **Provenance**  | `source_type`, `source_url`, `last_verified_at`                                               |

### Write Rules

1. **Core domain** writes identity columns via pipeline SQL files (`01_insert_products.sql`).
2. **Scoring domain** writes score columns via `score_category()` procedure (`04_scoring.sql`).
3. **Confidence domain** writes `confidence` via `assign_confidence()` (called by `score_category()`).
4. **Provenance domain** writes source columns via `05_source_provenance.sql`.
5. **No other domain** writes to `products` directly.

### Read Permissions

All domains may **read** any column from `products` (and `v_master`). This is the intended
integration surface — domains communicate by reading published data, not by calling each
other's internal functions.

---

## 4. Interface Contracts

### 4.1 Provenance → Scoring

```
Direction:    Provenance publishes → Scoring reads
Interface:    products.source_type, product_field_provenance.confidence
Contract:     Provenance maintains per-field confidence as NUMERIC(3,2) [0.00, 1.00]
              Scoring reads source_type to determine base confidence in compute_data_confidence()
Constraint:   Scoring NEVER writes source_type or provenance fields
```

### 4.2 Scoring → Search

```
Direction:    Scoring publishes → Search reads
Interface:    products.unhealthiness_score (INT 1-100), products.nutri_score_label (TEXT 'A'-'E')
Contract:     Scoring publishes final scores; Search uses them as ranking signals
              in api_search_products() and api_category_listing()
Constraint:   Search NEVER modifies score columns
```

### 4.3 Scoring → Confidence

```
Direction:    Scoring orchestrates → Confidence computes
Interface:    score_category() calls compute_data_completeness() and assign_confidence()
Contract:     Confidence returns completeness % (0-100) and band ('verified'/'estimated'/'low')
              Scoring writes the result to products.data_completeness_pct and products.confidence
Constraint:   Confidence functions are pure computations; they do not write to products directly
```

### 4.4 Analytics → Search

```
Direction:    Analytics stores → Search reads asynchronously
Interface:    analytics_events WHERE event_type LIKE 'search_%'
Contract:     Analytics stores raw search events; Search quality dashboard reads them
              for reporting. Never in the hot query path.
Constraint:   Search reads events asynchronously; never blocks on event writes
```

### 4.5 Feature Flags → All Domains

```
Direction:    Flags publishes → All domains read
Interface:    lib/flags/evaluator.ts → evaluateFlag(flagKey, context) → boolean
Contract:     Pure function, no side effects, <5ms evaluation
Constraint:   Domains call evaluateFlag(); no domain writes to feature_flags directly
              (admin-only writes via flag management UI)
```

### 4.6 Core → All Domains (Read Surface)

```
Direction:    Core publishes → All domains read
Interface:    v_master (denormalized view), products table, nutrition_facts table
Contract:     v_master provides the canonical read surface for product data
              All domains read from v_master for display; write to their own tables only
Constraint:   Only Core and Pipeline write to products/nutrition_facts
```

---

## 5. Cross-Domain Coupling Audit

### Current State (as of 2026-02-28)

The following cross-domain reads are **authorized** (via interface contracts above):

| Consumer Domain | Reads From             | Interface              | Status     |
|-----------------|------------------------|------------------------|------------|
| Scoring         | products.source_type   | §4.1 Provenance→Score  | Authorized |
| Search          | products.*_score       | §4.2 Scoring→Search    | Authorized |
| Scoring         | Confidence functions   | §4.3 Scoring→Confidence| Authorized |
| All             | v_master               | §4.6 Core→All          | Authorized |
| All             | evaluateFlag()         | §4.5 Flags→All         | Authorized |

### No Known Violations

As of this writing, no unauthorized cross-domain direct imports exist. This has been
verified by auditing:

1. All `api_*` functions — each queries only tables owned by its domain (plus shared `products`/`v_master`)
2. All `compute_*` functions — each reads only its own domain's columns from `products`
3. All frontend `lib/rpc-contracts/*` — each contracts file maps to a single domain
4. Pipeline SQL files — write only to Core domain tables + call `score_category()`

---

## 6. Verification Method

### Manual Audit (Current)

Run this query to check for unexpected function-to-table dependencies:

```sql
-- Check if any function references tables outside its domain
-- Example: search functions referencing scoring-specific tables
SELECT
    p.proname  AS function_name,
    c.relname  AS table_referenced
FROM pg_proc p
JOIN pg_depend d ON d.objid = p.oid
JOIN pg_class c ON c.oid = d.refobjid
WHERE c.relnamespace = 'public'::regnamespace
  AND (
    -- Search functions touching scoring tables
    (p.proname LIKE 'api_search%' AND c.relname IN ('scoring_model_versions', 'score_audit_log'))
    -- Scoring functions touching provenance tables
    OR (p.proname LIKE 'compute_unhealthiness%' AND c.relname IN ('data_sources', 'product_field_provenance'))
    -- Provenance functions touching scoring tables
    OR (p.proname LIKE '%provenance%' AND c.relname IN ('scoring_model_versions', 'score_audit_log'))
  )
ORDER BY p.proname;
```

**Expected result:** Zero rows. Any rows indicate a domain boundary violation.

### Future CI Enforcement

When CI tooling matures, add a `pg_depend`-based check to the QA suite that:
1. Maps each function to its domain (by naming convention or metadata table)
2. Maps each table to its owning domain
3. Flags any function → table dependency that crosses domain boundaries
4. Allows explicit exceptions via a whitelist table

---

## 7. Adding a New Domain

When creating a new workstream or domain:

1. **Define scope** — list all tables, functions, views, and frontend modules
2. **Add to this document** — create a new section under §2 with the ownership map
3. **Define interface contracts** — add to §4 for any cross-domain interactions
4. **Verify no violations** — run the audit query from §6 after implementation
5. **Use naming conventions** — prefix tables and functions with the domain name
   (e.g., `recipe_*`, `achievement_*`, `analytics_*`)

### Naming Convention Guide

| Domain        | Table Prefix         | Function Prefix         | Frontend Path           |
|---------------|----------------------|-------------------------|-------------------------|
| Core          | `products`, `nutrition_facts`, `ingredient_ref`, `product_*` | `api_product_*`, `api_category_*` | `components/product/`   |
| Scoring       | `scoring_*`, `score_*`, `product_score_*` | `compute_*`, `score_*`, `api_score_*` | `components/product/Score*` |
| Search        | `search_*`           | `api_search_*`          | `components/search/`    |
| Provenance    | `data_*`, `product_field_*`, `product_change_*`, `freshness_*`, `conflict_*`, `country_data_*` | `*_provenance*`, `detect_*`, `resolve_*` | `lib/rpc-contracts/provenance.ts` |
| Confidence    | `audit_results`      | `compute_data_*`, `assign_*`, `api_data_confidence` | — |
| User          | `user_*`, `scan_*`, `product_submissions` | `api_record_*`, `api_get_*`, `api_save_*` | `components/settings/`, `components/compare/` |
| Analytics     | `analytics_*`, `allowed_event_*` | `api_track_*`, `api_admin_*` | `hooks/use-analytics.ts` |
| Flags         | `feature_flags`, `flag_*` | — (frontend-only evaluation) | `lib/flags/` |
| Achievements  | `achievement_*`, `user_achievement` | — | `components/achievements/` |
| Recipes       | `recipe*`            | — | `components/recipes/`   |
| Localization  | `category_translations`, `language_ref`, `search_synonyms` | — | `components/i18n/`, `stores/language-store.ts` |
| Infrastructure| `push_*`, `notification_*` | `refresh_*`, `mv_staleness_*` | `components/pwa/` |

---

## 8. Exception Policy

Pragmatic exceptions to domain boundaries are allowed when:

1. **Performance requires it** — a JOIN across domain tables is significantly faster than
   two separate queries. Document the exception and the performance justification.
2. **The interaction is read-only** — reading from another domain's table is lower risk
   than writing. Still document it as an authorized read.
3. **Transition period** — during a migration from one domain structure to another,
   temporary cross-domain access is acceptable with a cleanup deadline.

### Exception Format

When adding an exception, document it in §5 with:

```
| Consumer Domain | Reads From | Interface | Status | Justification |
|---|---|---|---|---|
| Search | scoring_model_versions | N/A | Exception | Performance: version lookup in hot path |
```

Include a cleanup deadline if the exception is temporary.

---

## Cross-References

- [copilot-instructions.md](../copilot-instructions.md) § 4 — Database Schema (table reference)
- [copilot-instructions.md](../copilot-instructions.md) § 5 — Categories
- [docs/API_CONTRACTS.md](API_CONTRACTS.md) — API function signatures and response shapes
- [docs/FRONTEND_API_MAP.md](FRONTEND_API_MAP.md) — Frontend ↔ API mapping
- [docs/SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md) — Scoring domain internals
