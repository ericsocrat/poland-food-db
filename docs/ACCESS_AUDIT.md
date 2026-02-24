# Data Access Pattern Audit

> **Last updated:** 2026-02-28
> **Audit cadence:** Quarterly (next: 2026-06-01)
> **Current tables:** 51 public tables
> **RLS-enabled tables:** All user-facing tables
> **Last full audit:** 2026-02-28 (initial)

---

## 1. Purpose

This document provides a structured, repeatable process for auditing data access
patterns across the platform. It ensures:

- **Least-privilege compliance** — each role accesses only what it needs
- **RLS correctness** — row-level policies gate access properly
- **No privilege drift** — new migrations don't silently widen access
- **Auditability** — every access pattern is documented and verifiable

---

## 2. Role Definitions

| Role | Purpose | Access Level |
|------|---------|-------------|
| `anon` | Unauthenticated PostgREST requests (public API) | READ-ONLY on public product data + reference tables |
| `authenticated` | Logged-in users via Supabase Auth | READ on public data + CRUD on own `user_*` rows |
| `service_role` | Pipeline execution, admin operations, migrations | Unrestricted (bypasses RLS) |

---

## 3. Table-by-Role Access Matrix

### Core Product Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `products` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Public product data |
| `nutrition_facts` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Joined via v_master |
| `ingredient_ref` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Reference dictionary |
| `product_ingredient` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Junction table |
| `product_allergen_info` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Allergen/trace data |
| `product_images` | SELECT (via views/RPCs) | SELECT (via views/RPCs) | ALL | Yes | Image URLs |

### Reference Tables

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `country_ref` | SELECT | SELECT | ALL | Yes | 2 rows (PL, DE) |
| `category_ref` | SELECT | SELECT | ALL | Yes | 20 rows |
| `nutri_score_ref` | SELECT | SELECT | ALL | Yes | 7 rows (A–E + UNKNOWN + N/A) |
| `concern_tier_ref` | SELECT | SELECT | ALL | Yes | 4 rows (tiers 0–3) |
| `daily_value_ref` | SELECT | SELECT | ALL | Yes | Nutritional daily values |
| `language_ref` | SELECT | SELECT | ALL | Yes | Language codes |

### User Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `user_preferences` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `user_health_profiles` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `user_product_lists` | Public shared only | Own + public | ALL | Yes | `is_public` or own |
| `user_product_list_items` | Via public lists | Own list items | ALL | Yes | Via parent ownership |
| `user_comparisons` | Shared token only | Own + shared | ALL | Yes | `share_token` or own |
| `user_saved_searches` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `user_watched_products` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `user_product_views` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `scan_history` | NONE | Own rows only | ALL | Yes | `auth.uid() = user_id` |
| `product_submissions` | NONE | Own submissions | ALL | Yes | Insert own; admin review via service_role |
| `deletion_audit_log` | NONE | NONE | ALL | Yes | Service-only audit trail |

### Scoring Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `scoring_model_versions` | NONE | NONE | ALL | Yes | Internal scoring metadata |
| `score_audit_log` | NONE | NONE | ALL | Yes | Score change audit |
| `score_shadow_results` | NONE | NONE | ALL | Yes | A/B testing shadows |
| `score_distribution_snapshots` | NONE | NONE | ALL | Yes | Historical distributions |
| `product_score_history` | NONE | NONE | ALL | Yes | Per-product score timeline |

### Provenance Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `data_sources` | NONE | NONE | ALL | Yes | Source registry |
| `product_sources` | NONE | NONE | ALL | Yes | Product-source junction |
| `source_nutrition` | NONE | NONE | ALL | Yes | Per-source nutrition values |
| `product_field_provenance` | NONE | NONE | ALL | Yes | Field-level source tracking |
| `product_change_log` | NONE | NONE | ALL | Yes | Full change audit trail |
| `freshness_policies` | NONE | NONE | ALL | Yes | Staleness thresholds |
| `conflict_resolution_rules` | NONE | NONE | ALL | Yes | Auto-resolve priorities |
| `data_conflicts` | NONE | NONE | ALL | Yes | Conflict queue |
| `country_data_policies` | NONE | NONE | ALL | Yes | Per-country regulations |

### Analytics Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `analytics_events` | NONE | INSERT own events | ALL | Yes | `auth.uid()` tracked |
| `allowed_event_names` | NONE | NONE | ALL | Yes | Event whitelist |
| `analytics_daily` | NONE | NONE | ALL | Yes | Aggregated daily stats |

### Feature Flags Domain

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `feature_flags` | SELECT (evaluation) | SELECT (evaluation) | ALL | Yes | Read for flag evaluation |
| `flag_overrides` | NONE | SELECT own | ALL | Yes | Per-user overrides |
| `flag_audit_log` | NONE | NONE | ALL | Yes | Admin audit trail |

### Other Domains

| Table | `anon` | `authenticated` | `service_role` | RLS | Notes |
|-------|--------|-----------------|----------------|-----|-------|
| `achievement_def` | SELECT (via RPCs) | SELECT (via RPCs) | ALL | Yes | Achievement definitions |
| `user_achievement` | NONE | Own rows | ALL | Yes | User progress |
| `recipe` | SELECT | SELECT | ALL | Yes | Public recipes |
| `recipe_step` | SELECT | SELECT | ALL | Yes | Recipe steps |
| `recipe_ingredient` | SELECT | SELECT | ALL | Yes | Recipe ingredients |
| `recipe_ingredient_product` | SELECT | SELECT | ALL | Yes | Ingredient-product links |
| `category_translations` | SELECT | SELECT | ALL | Yes | i18n translations |
| `search_synonyms` | SELECT (internal) | SELECT (internal) | ALL | Yes | Search enhancement |
| `search_ranking_config` | NONE | NONE | ALL | Yes | Internal ranking config |
| `push_subscriptions` | NONE | Own rows | ALL | Yes | Push notification subs |
| `notification_queue` | NONE | NONE | ALL | Yes | Internal queue |
| `audit_results` | NONE | NONE | ALL | Yes | Integrity audit output |

---

## 4. RPC Function Access Analysis

### Public Functions (anon + authenticated)

| Function | Tables Read | Tables Written | Least-Privilege |
|----------|------------|---------------|-----------------|
| `api_product_detail()` | products, nutrition_facts, ingredient_ref, product_ingredient, product_allergen_info | None | ✅ Read-only, public data |
| `api_product_detail_by_ean()` | products, nutrition_facts, ingredient_ref, product_ingredient, product_allergen_info | None | ✅ Read-only, public data |
| `api_category_listing()` | products, category_ref | None | ✅ Read-only, public data |
| `api_score_explanation()` | products, nutrition_facts, category_ref | None | ✅ Read-only, public data |
| `api_better_alternatives()` | products, nutrition_facts, product_ingredient | None | ✅ Read-only, public data |
| `api_search_products()` | products | None | ✅ Read-only, public data |
| `api_search_autocomplete()` | products | None | ✅ Read-only, public data |
| `api_get_filter_options()` | products, category_ref | None | ✅ Read-only, public data |
| `api_data_confidence()` | products, nutrition_facts, product_ingredient, product_allergen_info | None | ✅ Read-only, public data |
| `api_product_provenance()` | products, product_field_provenance, product_sources, data_sources | None | ✅ Read-only, trust metadata |
| `api_get_shared_comparison()` | user_comparisons, products | None | ✅ Read-only, public share token |
| `api_get_products_for_compare()` | products, nutrition_facts | None | ✅ Read-only, public data |

### Authenticated-Only Functions

| Function | Tables Read | Tables Written | Least-Privilege |
|----------|------------|---------------|-----------------|
| `api_track_event()` | allowed_event_names | analytics_events | ✅ Write own events only |
| `api_record_scan()` | products | scan_history | ✅ Write own scans only |
| `api_get_scan_history()` | scan_history, products | None | ✅ Read own scans only |
| `api_save_comparison()` | None | user_comparisons | ✅ Write own comparisons |
| `api_record_product_view()` | None | user_product_views | ✅ Write own views only |
| `api_get_recently_viewed()` | user_product_views, products | None | ✅ Read own views only |
| `api_get_dashboard_data()` | user_product_views, scan_history, products | None | ✅ Read own data only |
| `api_get_user_preferences()` | user_preferences | None | ✅ Read own preferences |
| `api_set_user_preferences()` | None | user_preferences | ✅ Write own preferences |

### Service-Role-Only Functions (Pipeline / Admin)

| Function | Tables Read | Tables Written | Restriction |
|----------|------------|---------------|-------------|
| `compute_unhealthiness_v32()` | nutrition_facts, products | products (score update) | ⚠️ Must not be callable by anon/authenticated |
| `score_category()` | products, nutrition_facts, ingredient_ref, product_ingredient | products (bulk update) | ⚠️ Procedure — restricted |
| `refresh_all_materialized_views()` | All MVs | MVs (refresh) | ⚠️ Must not be callable by anon/authenticated |
| `mv_staleness_check()` | pg_stat_user_tables | None | ⚠️ Metadata read — restrict |
| `admin_provenance_dashboard()` | Multiple provenance tables | None | ⚠️ Admin dashboard — service_role only |
| `api_admin_get_event_summary()` | analytics_events | None | ⚠️ Admin telemetry |
| `api_admin_get_top_events()` | analytics_events | None | ⚠️ Admin telemetry |
| `api_admin_get_funnel()` | analytics_events | None | ⚠️ Admin telemetry |

---

## 5. Audit SQL Templates

### Query 1: Tables Without RLS

```sql
-- Expected: zero rows (all public tables must have RLS)
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND NOT rowsecurity
  AND tablename NOT LIKE 'pg_%'
  AND tablename NOT LIKE 'spatial_%'
ORDER BY tablename;
```

### Query 2: RLS Policy Inventory

```sql
-- Full inventory of all active RLS policies
SELECT
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  LEFT(qual::text, 120) AS using_expr,
  LEFT(with_check::text, 120) AS check_expr
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### Query 3: Grant Inventory by Role

```sql
-- What table grants exist per role?
SELECT
  grantee,
  table_name,
  string_agg(privilege_type, ', ' ORDER BY privilege_type) AS privileges
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('anon', 'authenticated', 'service_role')
GROUP BY grantee, table_name
ORDER BY grantee, table_name;
```

### Query 4: Functions Accessible by Non-Service Roles

```sql
-- Functions executable by anon or authenticated
SELECT
  routine_name,
  grantee
FROM information_schema.role_routine_grants
WHERE routine_schema = 'public'
  AND grantee IN ('anon', 'authenticated')
ORDER BY routine_name, grantee;
```

### Query 5: Materialized View Ownership

```sql
-- MVs and their owners (should be postgres/service_role)
SELECT
  matviewname,
  matviewowner,
  hasindexes
FROM pg_matviews
WHERE schemaname = 'public'
ORDER BY matviewname;
```

---

## 6. Quarterly Audit Checklist

```markdown
## Data Access Audit — Q[N] YYYY

**Auditor:** [Name]
**Date:** YYYY-MM-DD
**Previous audit:** YYYY-MM-DD (or "Initial")
**Migration range reviewed:** [from_migration] → [to_migration]

### Pre-Audit
- [ ] Run all 5 audit SQL templates (§5)
- [ ] Note tables/functions added since last audit
- [ ] Review migrations for GRANT/REVOKE/POLICY changes

### RLS Verification
- [ ] All public tables have RLS enabled (Query 1 = 0 rows)
- [ ] All user_* tables restrict to auth.uid() = user_id
- [ ] Sharing tables gate on is_public / share_token
- [ ] Product data tables allow public SELECT via views/RPCs

### Role Privilege Verification
- [ ] anon: READ-ONLY on product + reference data
- [ ] authenticated: READ public + CRUD own user_* rows
- [ ] service_role: unrestricted (pipeline + admin use)
- [ ] No unexpected WRITE grants to anon on product tables
- [ ] No unexpected WRITE grants to authenticated on product tables

### Function Privilege Verification
- [ ] Public api_* functions accessible to anon + authenticated
- [ ] Scoring/admin functions restricted to service_role
- [ ] No new functions with unintended grants

### New Objects Since Last Audit

| Object | Type | Migration | Access Verified |
|--------|------|-----------|-----------------|
| | | | |

### Findings

| Finding | Severity | Action | Issue |
|---------|----------|--------|-------|
| | | | |

### Sign-Off
- [ ] All checks passed OR findings documented
- [ ] Next audit scheduled: YYYY-MM-DD
```

---

## 7. Initial Audit Results (2026-02-28)

### Summary

- **Tables audited:** 51
- **RLS-enabled:** All user-facing tables
- **Public API functions:** 12 (all read-only on public data) ✅
- **Authenticated functions:** 9 (all scoped to own data via auth.uid()) ✅
- **Service-role functions:** 8 (scoring, admin, MV refresh) ✅
- **Least-privilege violations:** 0

### Findings

| Finding | Severity | Status |
|---------|----------|--------|
| All public API functions are read-only | — | ✅ Confirmed |
| User data functions use auth.uid() scoping | — | ✅ Confirmed |
| Scoring functions not in public API whitelist | — | ✅ Confirmed via QA__security_posture.sql |
| MV refresh restricted to service_role | — | ✅ Confirmed |

### Risk Items (Monitoring)

| Item | Current State | Review Trigger |
|------|--------------|----------------|
| `compute_unhealthiness_v32()` | Not exposed to anon/authenticated | Any new GRANT on scoring functions |
| `score_category()` | Procedure, restricted execution | Any CALL in non-service context |
| `refresh_all_materialized_views()` | Service-role only | Any new EXECUTE grant |
| Admin telemetry functions | Service-role only | Any role change |

---

## 8. Integration Points

- **QA__security_posture.sql** (22 checks) — automated verification of RLS and function restrictions
- **QA__auth_onboarding.sql** (8 checks) — auth flow and user table access
- **docs/SECURITY.md** — security policy and responsible disclosure
- **docs/DOMAIN_BOUNDARIES.md** — domain ownership of tables and functions
- **docs/API_VERSIONING.md** — API surface stability contract

---

## Cross-References

- [db/qa/QA__security_posture.sql](../db/qa/QA__security_posture.sql) — Automated security checks
- [docs/DOMAIN_BOUNDARIES.md](DOMAIN_BOUNDARIES.md) — Domain ownership mapping
- [docs/API_CONTRACTS.md](API_CONTRACTS.md) — API function signatures
- [SECURITY.md](../SECURITY.md) — Security policy
