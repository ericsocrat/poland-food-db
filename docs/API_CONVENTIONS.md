# API Conventions — RPC Naming & Contract Standards

> **Last updated:** 2026-02-28
> **Status:** Active — enforced for all new functions
> **Related:** [API_CONTRACTS.md](API_CONTRACTS.md) · [FRONTEND_API_MAP.md](FRONTEND_API_MAP.md) · [api-registry.yaml](api-registry.yaml) · [API_VERSIONING.md](API_VERSIONING.md)

---

## 1. Naming Convention

All public schema functions follow a strict naming pattern:

```
{visibility}_{domain}_{action}[_{version}]
```

### 1.1 Visibility Prefixes

| Prefix        | Meaning                                    | Auth Requirement     | Example                          |
| ------------- | ------------------------------------------ | -------------------- | -------------------------------- |
| `api_`        | Public-facing, called by frontend          | `authenticated`      | `api_search_products`            |
| `api_admin_`  | Admin-only, called by admin panel          | `authenticated` + admin check | `api_admin_get_submissions` |
| `admin_`      | Admin/ops tooling (not exposed via PostgREST) | Direct DB access  | `admin_rescore_batch`            |
| `metric_`     | Analytics/metrics aggregation              | Direct DB access     | `metric_dau`                     |
| `trg_`        | Trigger functions (not callable directly)  | N/A (trigger-fired)  | `trg_set_updated_at`             |
| _(none/internal)_ | Internal helpers, not exposed as RPC   | N/A                  | `compute_unhealthiness_v32`      |

### 1.2 Domain Names

| Domain         | Scope                                               | Examples                                                |
| -------------- | --------------------------------------------------- | ------------------------------------------------------- |
| `products`     | Product identity, detail, listing, alternatives      | `api_product_detail`, `api_better_alternatives`         |
| `category`     | Category listing, overview, statistics               | `api_category_listing`, `api_category_overview`         |
| `scoring`      | Score computation, explanation, history               | `api_score_explanation`, `api_score_history`             |
| `search`       | Full-text search, autocomplete, filters               | `api_search_products`, `api_search_autocomplete`        |
| `health`       | Health profiles, warnings, daily values               | `api_create_health_profile`, `api_product_health_warnings` |
| `lists`        | User product lists (CRUD, sharing)                    | `api_create_list`, `api_get_lists`, `api_add_to_list`   |
| `compare`      | Product comparisons                                   | `api_get_products_for_compare`, `api_save_comparison`   |
| `scanner`      | Barcode scanning, scan history                        | `api_record_scan`, `api_get_scan_history`               |
| `preferences`  | User preferences, onboarding                          | `api_get_user_preferences`, `api_complete_onboarding`   |
| `submissions`  | User product submissions                              | `api_submit_product`, `api_get_my_submissions`          |
| `telemetry`    | Event tracking, analytics                             | `api_track_event`, `api_admin_get_event_summary`        |
| `dashboard`    | Dashboard data, recently viewed                       | `api_get_dashboard_data`, `api_get_recently_viewed`     |
| `confidence`   | Data confidence scoring                               | `api_data_confidence`                                   |
| `provenance`   | Data source tracking, cross-validation                | `admin_provenance_dashboard`                            |
| `infrastructure` | MV refresh, staleness, search vectors               | `refresh_all_materialized_views`, `mv_staleness_check`  |
| `flags`        | Feature flags, rollout                                | `admin_toggle_flag`, `expire_stale_flags`               |

### 1.3 Action Naming

Actions use descriptive verb-noun or verb patterns:

| Pattern          | Usage                       | Examples                                        |
| ---------------- | --------------------------- | ----------------------------------------------- |
| `get_*`          | Retrieve single/list        | `api_get_lists`, `api_get_scan_history`          |
| `create_*`       | Insert new record           | `api_create_list`, `api_create_health_profile`   |
| `update_*`       | Modify existing record      | `api_update_list`, `api_update_health_profile`   |
| `delete_*`       | Remove record               | `api_delete_list`, `api_delete_comparison`        |
| `search_*`       | Full-text/fuzzy search      | `api_search_products`, `api_search_autocomplete` |
| `record_*`       | Log an event/action         | `api_record_scan`, `api_record_product_view`     |
| `toggle_*`       | Flip boolean state          | `api_toggle_share`, `admin_toggle_flag`          |
| `compute_*`      | Calculate derived value     | `compute_unhealthiness_v32`, `compute_score`     |
| `find_*`         | Discovery/similarity        | `find_better_alternatives`, `find_similar_products` |
| `resolve_*`      | Multi-tier resolution       | `resolve_effective_country`, `resolve_language`   |

### 1.4 Version Suffix

Append `_v{N}` **only** when shipping a breaking change to an existing endpoint:

```sql
-- Original
api_search_products(p_query text, ...)

-- Breaking change (removed parameter) → new version
api_search_products_v2(p_query text, ...)
-- Keep api_search_products as deprecated alias
```

Do **not** use version suffixes for new endpoints or non-breaking changes.

---

## 2. Parameter Conventions

### 2.1 Standard Prefixes

| Prefix | Usage                    | Example                        |
| ------ | ------------------------ | ------------------------------ |
| `p_`   | Function parameters      | `p_product_id`, `p_query`      |
| `v_`   | Local variables (plpgsql)| `v_total`, `v_rows`            |

### 2.2 Common Parameters

These parameters appear across multiple functions and must use consistent names:

| Parameter              | Type      | Default | Description                    |
| ---------------------- | --------- | ------- | ------------------------------ |
| `p_product_id`         | `bigint`  | —       | Product identifier             |
| `p_ean`                | `text`    | —       | EAN-13 barcode                 |
| `p_category`           | `text`    | `NULL`  | Category filter                |
| `p_country`            | `text`    | `NULL`  | Country code (auto-resolved)   |
| `p_limit`              | `integer` | `20`    | Result page size               |
| `p_offset`             | `integer` | `0`     | Result page offset             |
| `p_query`              | `text`    | —       | Search query text              |
| `p_sort_by`            | `text`    | `'score'` | Sort column key              |
| `p_sort_dir`           | `text`    | `'asc'` | Sort direction (asc/desc)      |
| `p_diet_preference`    | `text`    | `NULL`  | Diet filter                    |
| `p_avoid_allergens`    | `text[]`  | `NULL`  | Allergen exclusion list        |
| `p_strict_diet`        | `boolean` | `false` | Strict diet matching           |
| `p_strict_allergen`    | `boolean` | `false` | Strict allergen matching       |
| `p_treat_may_contain`  | `boolean` | `false` | Treat traces as contains       |

### 2.3 Pagination Clamping

All paginated functions must clamp:
- `p_limit`: `LEAST(GREATEST(p_limit, 1), 100)` — range 1–100
- `p_offset`: `GREATEST(p_offset, 0)` — non-negative

### 2.4 Country Resolution

Functions accepting `p_country` use `resolve_effective_country()` internally:
1. If `p_country` is non-NULL → use it directly
2. Else → look up `user_preferences.country` for `auth.uid()`
3. If neither → return `NULL` (frontend must ensure onboarding is complete)

---

## 3. Return Value Conventions

### 3.1 Standard JSONB Envelope

All `api_*` functions return structured JSONB with:

```jsonc
{
  "api_version": "1.0",
  // ... endpoint-specific fields
}
```

### 3.2 Error Handling (Auth-Required Functions)

Functions requiring authentication return:

```jsonc
{
  "api_version": "1.0",
  "error": "Authentication required"
}
```

When `auth.uid()` is `NULL`.

### 3.3 Score Bands

All score-related responses use consistent band labels:

| Band         | Score Range | Key Value     |
| ------------ | ----------- | ------------- |
| Low risk     | 1–25        | `"low"`       |
| Moderate     | 26–50       | `"moderate"`  |
| High         | 51–75       | `"high"`      |
| Very high    | 76–100      | `"very_high"` |

### 3.4 Boolean Conversion

Internal `'YES'`/`'NO'` text flags are always converted to proper JSON booleans in API responses.

---

## 4. Breaking Change Definition

A change is **breaking** if it:

1. **Removes or renames** a parameter
2. **Changes** a parameter from optional to required
3. **Removes** a key from the return JSONB
4. **Changes** the data type of a returned key
5. **Changes** auth requirements (anon → authenticated)
6. **Narrows** valid input values (e.g., smaller enum set)

A change is **non-breaking** (safe to ship without version bump):

1. Adds a new **optional** parameter with a default value
2. Adds a new **key** to the return JSONB
3. **Relaxes** auth requirements (authenticated → anon)
4. Improves performance or reduces latency
5. Adds new enum values to an existing parameter
6. Fixes a bug (response now matches documented contract)

### 4.1 Breaking Change Protocol

When a breaking change is necessary:

1. Create a new version: `api_function_v2(...)` with the new signature
2. Keep the old version as a deprecated alias (forward to v2 if possible)
3. Add deprecation notice to `docs/API_VERSIONING.md`
4. Set sunset window: minimum 2 releases or 30 days
5. Update `api-registry.yaml` with `deprecated: true` on old version
6. After sunset: remove old version in a new migration

### 4.2 Breaking Change Detection

Compare `docs/api-registry.yaml` between branches:
- Parameter removed/renamed → breaking
- Return key removed → breaking
- Auth requirement changed → breaking
- New optional parameter with default → non-breaking

---

## 5. Security Standards

### 5.1 SECURITY DEFINER

All `api_*` functions use `SECURITY DEFINER` with explicit `search_path`:

```sql
CREATE OR REPLACE FUNCTION public.api_example(...)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$ ... $function$;
```

### 5.2 Auth Checking

Auth-required functions must check `auth.uid()` at the top:

```sql
IF auth.uid() IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
END IF;
```

### 5.3 Input Validation

- Clamp numeric inputs (`p_limit`, `p_offset`) to safe ranges
- Validate enum inputs (`p_sort_by`, `p_sort_dir`) with `CASE` fallbacks
- Minimum length checks on search queries (typically 2 characters)

---

## 6. Documentation Requirements

When adding a new function:

1. Add entry to `docs/api-registry.yaml` (see registry format)
2. If frontend-facing: add documentation to `docs/FRONTEND_API_MAP.md`
3. If part of a contract: update `docs/API_CONTRACTS.md`
4. Whitelist in `QA__security_posture.sql` check 9
5. Add pgTAP test in `supabase/tests/`
6. Update `copilot-instructions.md` Key Functions table if significant

---

## 7. Existing Naming Compliance Audit

### 7.1 Compliant Functions (Follow Convention)

All 64 `api_*` functions, 7 `admin_*` functions, 10 `metric_*` functions,
and 7 `trg_*` functions follow the naming convention correctly.

### 7.2 Legacy Internal Functions

These internal functions predate the convention but are **not exposed as RPCs**,
so renaming is unnecessary:

| Function                        | Domain         | Notes                              |
| ------------------------------- | -------------- | ---------------------------------- |
| `compute_unhealthiness_v31`     | scoring        | Superseded by v32, kept for audit  |
| `compute_unhealthiness_v32`     | scoring        | Active scoring function            |
| `assign_confidence`             | confidence     | Called by `score_category()`       |
| `find_better_alternatives`      | products       | Called by `api_better_alternatives` |
| `find_similar_products`         | products       | Similarity engine                  |
| `build_search_vector`           | search         | Trigger helper                     |
| `expand_search_query`           | search         | Query expansion                    |
| `search_rank`                   | search         | Ranking function                   |
| `resolve_effective_country`     | preferences    | Country resolution                 |
| `resolve_language`              | preferences    | Language resolution                |
| `score_category` (PROCEDURE)    | scoring        | Batch scoring orchestrator         |
| `compute_score`                 | scoring        | Config-driven scoring              |

These are all internal helpers that follow implicit domain conventions.
No renaming action needed — the `api_*` / `admin_*` / `metric_*` / `trg_*`
prefix system provides sufficient clarity for the RPC surface.

---

## 8. Function Count Summary

| Visibility     | Count | Description                              |
| -------------- | ----: | ---------------------------------------- |
| `api_*`        |    57 | Public frontend-facing (incl. `api_admin_*`) |
| `api_admin_*`  |     7 | Admin panel (subset of `api_*`)          |
| `admin_*`      |     7 | Ops tooling (not RPC-exposed)            |
| `metric_*`     |    10 | Analytics aggregation                    |
| `trg_*`        |     7 | Trigger functions                        |
| _(internal)_   |    26 | Internal helpers, compute, resolve       |
| **Total**      | **107** |                                        |

---

> **Canonical registry:** See [api-registry.yaml](api-registry.yaml) for the structured,
> machine-readable registry of all 107 functions with parameters, return types,
> auth requirements, domain classification, and performance targets.
