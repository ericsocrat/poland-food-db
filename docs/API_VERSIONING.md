# API Deprecation & Versioning Policy

> **Last updated:** 2026-02-28
> **Scope:** All public Supabase RPC functions and API views
> **Current API version:** 1.0 (implicit — all existing functions are v1)
> **Breaking changes to date:** 0

---

## 1. Versioning Strategy

### Why Function-Name Versioning

Supabase exposes PostgreSQL functions directly via PostgREST. URL-based versioning
(`/v1/`, `/v2/`) is not natively supported without an API gateway layer. At current
scale (solo developer, single frontend consumer), a gateway is overengineering.

**Strategy:** When a breaking change is needed, create a new function with a version
suffix. The original (unversioned) function is treated as **v1 implicit**.

### Convention

```
-- Original (v1 implicit)
api_product_detail(p_product_id bigint)

-- Breaking change → create versioned successor
api_product_detail_v2(p_product_id bigint, p_include_similar boolean DEFAULT false)

-- Mark original as deprecated
COMMENT ON FUNCTION api_product_detail(bigint) IS
  'DEPRECATED: Use api_product_detail_v2(). Sunset: YYYY-MM-DD';
```

### Version Numbering

- **v1:** Current implicit version (all existing functions)
- **v2, v3, ...:** Sequential, function-specific. Only created when a breaking change occurs
- No global version counter — each function versions independently
- The `api_version` field in JSONB responses tracks the response shape version (currently `"1.0"` for all functions)

---

## 2. Current API Surface (v1)

### Public RPC Functions

| Function | Parameters | Auth | Domain |
|----------|-----------|------|--------|
| `api_product_detail(p_product_id)` | `bigint` | anon | Core |
| `api_product_detail_by_ean(p_ean, p_country)` | `text, text DEFAULT NULL` | anon | Core |
| `api_category_listing(p_category, p_country, p_sort_by, p_page, p_page_size)` | `text, text, text, int, int` | anon | Core |
| `api_score_explanation(p_product_id)` | `bigint` | anon | Scoring |
| `api_better_alternatives(p_product_id, p_same_category, p_limit)` | `bigint, bool, int` | anon | Core |
| `api_search_products(p_query, p_country, p_limit)` | `text, text, int` | anon | Search |
| `api_search_autocomplete(p_query, p_country, p_limit)` | `text, text, int` | anon | Search |
| `api_get_filter_options(p_category, p_country)` | `text, text` | anon | Search |
| `api_data_confidence(p_product_id)` | `bigint` | anon | Confidence |
| `api_product_provenance(p_product_id)` | `bigint` | anon | Provenance |
| `api_track_event(p_event_name, p_properties)` | `text, jsonb` | authenticated | Analytics |
| `api_record_scan(p_ean, p_source)` | `text, text` | authenticated | User |
| `api_get_scan_history(p_limit)` | `int` | authenticated | User |
| `api_save_comparison(p_title, p_product_ids)` | `text, bigint[]` | authenticated | User |
| `api_get_shared_comparison(p_token)` | `text` | anon | User |
| `api_get_products_for_compare(p_product_ids)` | `bigint[]` | anon | User |
| `api_record_product_view(p_product_id)` | `bigint` | authenticated | User |
| `api_get_recently_viewed(p_limit)` | `int` | authenticated | User |
| `api_get_dashboard_data()` | — | authenticated | User |
| `api_get_user_preferences()` | — | authenticated | User |
| `api_set_user_preferences(...)` | multiple | authenticated | User |

### API Views (PostgREST)

| View | Type | Auth | Domain |
|------|------|------|--------|
| `v_api_category_overview` | Regular view | anon | Shared |
| `v_api_category_overview_by_country` | Regular view | anon | Shared |

### Admin Functions (service_role only)

| Function | Purpose |
|----------|---------|
| `admin_provenance_dashboard(p_country)` | Provenance health overview |
| `api_admin_get_event_summary(...)` | Telemetry summary |
| `api_admin_get_top_events(...)` | Top events |
| `api_admin_get_funnel(...)` | Funnel analysis |

---

## 3. Breaking vs. Non-Breaking Changes

### Non-Breaking (Safe — No Version Bump)

| Change Type | Example | Action Required |
|------------|---------|-----------------|
| Add optional parameter with default | `p_include_similar boolean DEFAULT false` | None — existing callers unaffected |
| Add new field to JSONB response | Add `similar_products` key | None — frontend ignores unknown keys |
| Add new RPC function | `api_product_history()` | None — new endpoint, no existing consumers |
| Performance optimization | Index addition, query rewrite | None — same results, faster |
| Add new value to CHECK domain | New `prep_method` value | None — existing values still valid |
| Bug fix correcting wrong data | Score recalculation | Document in CHANGELOG; may need frontend cache invalidation |

### Breaking (Requires Version Bump + Deprecation Window)

| Change Type | Example | Required Actions |
|------------|---------|-----------------|
| Remove parameter | Drop `p_country` from `api_category_listing` | Version bump + deprecation + migration |
| Change parameter type | `p_product_id` from `bigint` to `uuid` | Version bump + deprecation + migration |
| Remove field from JSONB response | Drop `controversies` from detail | Version bump + deprecation + migration |
| Rename response field | `unhealthiness_score` → `health_score` | Version bump + deprecation + migration |
| Change field type in response | `score` from `integer` to `float` | Version bump + deprecation + migration |
| Remove RPC function entirely | Drop `api_data_confidence()` | Deprecation window + migration |
| Change response structure | Nest `nutrition` under sub-object | Version bump + deprecation + migration |
| Remove CHECK enum value | Remove `prep_method = 'none'` | Data migration + verify no usage |

---

## 4. Deprecation Window Policy

| Change Severity | Minimum Window | Notification |
|----------------|---------------|--------------|
| **Critical path** (product detail, listing, search) | **4 weeks** | CHANGELOG breaking entry, GitHub issue, API_CONTRACTS.md update, frontend TODO comment |
| **Secondary path** (alternatives, confidence, score explanation) | **2 weeks** | CHANGELOG breaking entry, GitHub issue, API_CONTRACTS.md update |
| **Internal only** (no frontend consumer) | **1 week** | CHANGELOG entry, migration comment |
| **Admin only** (service_role functions) | **Immediate** | CHANGELOG entry |

### Deprecation Lifecycle

```
Week 0:  New versioned function created
         Old function marked DEPRECATED (COMMENT ON FUNCTION)
         → CHANGELOG.md breaking change entry (per .commitlintrc.json convention)
         → docs/API_CONTRACTS.md updated with both versions
         → GitHub issue created for frontend migration

Week 1-N: Both versions coexist
         Frontend migration in progress
         Old function remains fully functional

Week N:  Old function removed via migration (DROP FUNCTION)
         → docs/API_CONTRACTS.md updated to remove old version
         → CHANGELOG.md sunset entry
         → QA suites updated
```

---

## 5. Response Shape Stability Contract (v1)

### Guaranteed Stable Fields

These fields will NOT be removed, renamed, or have their types changed without
a major version bump and full deprecation cycle:

#### `api_product_detail` Response

```jsonc
{
  "api_version": "1.0",           // text — STABLE
  "product_id": 123,              // bigint — STABLE
  "product_name": "...",          // text — STABLE
  "brand": "...",                 // text — STABLE
  "category": "...",              // text — STABLE
  "country": "PL",               // text — STABLE
  "ean": "5900259135360",         // text|null — STABLE
  "unhealthiness_score": 42,      // integer(1-100) — STABLE
  "nutri_score_label": "C",       // text|null — STABLE
  "nova_group": "4",              // text|null — STABLE
  "nutrition": {                   // object — STABLE (all 9 fields)
    "calories_kcal": 0,
    "total_fat_g": 0,
    "saturated_fat_g": 0,
    "carbs_g": 0,
    "sugars_g": 0,
    "fiber_g": 0,
    "protein_g": 0,
    "salt_g": 0,
    "trans_fat_g": 0
  },
  "ingredients": [],               // array — STABLE (structure)
  "allergens": {                   // object — STABLE
    "contains": [],
    "traces": []
  }
}
```

#### `api_category_listing` Response Items

```jsonc
{
  "product_id": 123,              // bigint — STABLE
  "product_name": "...",          // text — STABLE
  "brand": "...",                 // text — STABLE
  "unhealthiness_score": 42,      // integer(1-100) — STABLE
  "nutri_score_label": "C"        // text|null — STABLE
}
```

#### `api_search_products` Response Items

```jsonc
{
  "product_id": 123,              // bigint — STABLE
  "product_name": "...",          // text — STABLE
  "brand": "...",                 // text — STABLE
  "category": "...",              // text — STABLE
  "unhealthiness_score": 42       // integer(1-100) — STABLE
}
```

### Unstable Fields (May Change Without Version Bump)

- New enrichment fields (e.g., `ingredient_concerns`, `similar_products`)
- Computed analytics fields (e.g., `category_rank`, `relative_score`)
- Debug/internal fields (prefixed with `_`)
- Provenance metadata (added recently, shape may evolve)
- Any field explicitly marked `UNSTABLE` in API_CONTRACTS.md

**Rule:** Fields are STABLE by default once documented in API_CONTRACTS.md.
A field is UNSTABLE only if explicitly marked.

---

## 6. Sunset Checklist

Before removing any deprecated API function:

- [ ] **Replacement exists:** New versioned function is created, tested, and documented
- [ ] **API_CONTRACTS.md updated:** Migration guide for consumers documented
- [ ] **CHANGELOG.md entry:** Breaking change flagged with `!` suffix per .commitlintrc.json
- [ ] **Frontend migrated:** All `supabase.rpc('old_function')` calls removed
- [ ] **Deprecation window elapsed:** Per severity policy (§4)
- [ ] **Zero production calls:** Verify via Supabase logs (if available)
- [ ] **Migration created:** `DROP FUNCTION IF EXISTS old_function` in new migration
- [ ] **QA suites updated:** Old function tests removed, new function tests pass
- [ ] **pgTAP tests updated:** Schema contracts reflect new function names
- [ ] **Sunset log updated:** Entry added to §8 below

---

## 7. Frontend Migration Guide Template

When a breaking API change occurs, create a GitHub issue using this template:

```markdown
## API Migration: `old_function` → `new_function`

**Deprecation date:** YYYY-MM-DD
**Sunset date:** YYYY-MM-DD
**Breaking change:** [describe what changed]

### What Changed
- [Parameter changes]
- [Response shape changes]
- [Type changes]

### Migration Steps
1. Update RPC call in `frontend/src/lib/rpc.ts`:
   `supabase.rpc('old_function', {...})` → `supabase.rpc('new_function', {...})`
2. Update TypeScript types in `frontend/src/lib/types.ts`
3. Update RPC contract in `frontend/src/lib/rpc-contracts/*.ts`
4. Update TanStack Query hook in `frontend/src/hooks/use-*.ts`
5. Update components that read affected response fields
6. Run tests: `npx vitest run` + `npx playwright test`
7. Verify no remaining references: `grep -r "old_function" frontend/src/`

### Rollback
Revert to `old_function` (available until sunset date).
```

---

## 8. Sunset Log

Track all deprecated and removed API functions here:

| Function | Deprecated | Sunset | Replaced By | Reason |
|----------|-----------|--------|-------------|--------|
| *(none yet)* | — | — | — | — |

---

## 9. Changelog Integration

Breaking changes are flagged in CHANGELOG.md using conventional commit conventions
(established in .commitlintrc.json):

- **Breaking commit type:** Append `!` after type/scope
  - Example: `schema(migration)!: rename products.source to source_type`
- **CHANGELOG section:** Breaking changes appear under a dedicated `### Breaking Changes` header
- **PR title:** Must include `!` for breaking changes (enforced by `pr-title-lint.yml`)

### Breaking Change Commit Examples

```
feat(api)!: replace api_product_detail with api_product_detail_v2
fix(scoring)!: change unhealthiness_score type from float to integer
schema(migration)!: rename nutri_score to nutri_score_label
```

---

## 10. Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Versioning approach | Function-name suffix (`_v2`) | PostgREST doesn't support URL versioning; gateway overengineering at current scale |
| Global vs per-function versions | Per-function | Breaking changes are rare and function-specific; global versioning creates unnecessary coupling |
| v1 implicit (no rename) | Keep current names as v1 | Renaming all functions to `_v1` is disruptive with zero benefit |
| Deprecation windows | 4/2/1 week tiers | Matches project release cadence; critical paths get more time |
| Stable vs unstable fields | Stable by default | Conservative approach — forces explicit opt-out for experimental fields |
| Admin functions | Immediate deprecation | No external consumers; only internal tooling |

---

## Cross-References

- [docs/API_CONTRACTS.md](API_CONTRACTS.md) — Current API function signatures and response shapes
- [docs/FRONTEND_API_MAP.md](FRONTEND_API_MAP.md) — Frontend ↔ API mapping
- [docs/DOMAIN_BOUNDARIES.md](DOMAIN_BOUNDARIES.md) — Domain ownership of API functions
- [CHANGELOG.md](../CHANGELOG.md) — Breaking change history
- [.commitlintrc.json](../.commitlintrc.json) — Conventional commit types and scopes
