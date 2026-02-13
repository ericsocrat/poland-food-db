# Security Model

## Threat Model

This project is a **public food quality database** — there is no user-generated content, no PII, and no authentication-gated data. The primary security concerns are:

| Threat                            | Mitigation                                                                                                                                                |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Unauthorized data mutation**    | RLS enabled + FORCE on all tables; write policies only on `user_preferences` (scoped to `auth.uid()`); anon is read-only                                  |
| **Schema/data exfiltration**      | Raw table SELECT revoked from `anon` and `authenticated`; all data served via SECURITY DEFINER RPCs                                                       |
| **SQL injection via RPC args**    | All API functions use parameterized queries (no dynamic SQL with user input in `api_product_detail`, `api_search_products`, etc.)                         |
| **Function privilege escalation** | Internal functions (`compute_*`, `find_*`, `refresh_*`, `cross_validate_*`, `resolve_effective_country`) are revoked from `anon`/`authenticated`/`PUBLIC` |
| **Denial of service (query)**     | `statement_timeout = 5s` on `anon`, `authenticated`, `authenticator`; `idle_in_transaction_session_timeout = 30s`                                         |
| **Unbounded result sets**         | All list/search APIs clamp `p_limit` to max 100; `max_rows = 1000` in PostgREST config                                                                    |
| **Stale materialized views**      | `mv_staleness_check()` alerts when views exceed refresh threshold                                                                                         |

## Access Control Architecture

```
┌─────────────────────────────────────────────────────┐
│  PostgREST  (runs as `authenticator` → sets `anon`) │
├─────────────────────────────────────────────────────┤
│                                                     │
│  anon + authenticated (shared)                      │
│    ✓ EXECUTE api_product_detail(bigint)              │
│    ✓ EXECUTE api_search_products(text, ...)          │
│    ✓ EXECUTE api_category_listing(text, ...)         │
│    ✓ EXECUTE api_product_detail_by_ean(text, ...)    │
│    ✓ EXECUTE api_score_explanation(bigint)           │
│    ✓ EXECUTE api_better_alternatives(bigint, ...)    │
│    ✓ EXECUTE api_data_confidence(bigint)             │
│    ✗ SELECT on any table or view                     │
│    ✗ INSERT / UPDATE / DELETE on data tables         │
│    ✗ EXECUTE on internal functions                   │
│                                                     │
│  authenticated only                                 │
│    ✓ EXECUTE api_get_user_preferences()              │
│    ✓ EXECUTE api_set_user_preferences(...)           │
│    ✓ INSERT/UPDATE own row in user_preferences       │
│      (RLS: auth.uid() = user_id)                    │
│                                                     │
│  service_role                                       │
│    ✓ Full CRUD on all tables                        │
│    ✓ Used by data pipelines and admin scripts        │
│                                                     │
├─────────────────────────────────────────────────────┤
│  SECURITY DEFINER functions (run as `postgres`)     │
│    → Can read all tables/views regardless of        │
│      client-role privileges                         │
│    → All have `SET search_path = public`            │
│      (prevents search_path hijacking)               │
│    → Note: `postgres` is NOT superuser in Supabase  │
│      (rolsuper=false) — relies on explicit grants   │
└─────────────────────────────────────────────────────┘
```

## RPC-Only Model

Direct REST access to tables and views is **blocked** for client-facing roles (`anon`, `authenticated`). All data access is routed through nine curated API functions:

| Function                    | Purpose                               | Access      |
| --------------------------- | ------------------------------------- | ----------- |
| `api_product_detail`        | Full product view with freshness      | anon + auth |
| `api_search_products`       | Text search with diet/allergen filter | anon + auth |
| `api_category_listing`      | Browse by category with sort/page     | anon + auth |
| `api_product_detail_by_ean` | Barcode scanner lookup                | anon + auth |
| `api_score_explanation`     | Score breakdown with category context | anon + auth |
| `api_better_alternatives`   | Healthier alternatives for a product  | anon + auth |
| `api_data_confidence`       | Data quality assessment per product   | anon + auth |
| `api_get_user_preferences`  | Retrieve user's saved preferences     | auth only   |
| `api_set_user_preferences`  | Save country/diet/allergen settings   | auth only   |

This approach provides:
- **Contract stability** — API key sets and country-echo contract are locked and tested (33 API contract QA checks)
- **Performance control** — Functions apply pagination limits and optimized queries
- **Security** — No direct table access means zero risk of filter bypass or column enumeration

## Row-Level Security

RLS is enabled and forced on all 12 data tables.

**Public data tables** (11 tables): Policies are `SELECT USING (true)` — permissive by design since all data is public. These policies serve as defense-in-depth: even if SELECT privilege were accidentally re-granted, RLS would still apply. Write policies (INSERT/UPDATE/DELETE) do **not** exist, enforcing read-only access.

**`user_preferences`** (1 table): User-scoped RLS with `auth.uid() = user_id` on all operations (SELECT, INSERT, UPDATE, DELETE). Each authenticated user can only access their own row. This is the only table with user-specific write policies.

## Internal Functions

`resolve_effective_country(text)` is a **SECURITY DEFINER** internal helper with `SET search_path = public`. EXECUTE is revoked from `PUBLIC`, `anon`, and `authenticated` — it can only be called by other SECURITY DEFINER functions (the API layer). This function reads `user_preferences` to resolve the user's preferred country, and the SECURITY DEFINER attribute ensures this works regardless of the caller's role privileges.

## QA Coverage

Security posture is validated by 22 automated checks (`QA__security_posture.sql`):

1. All data tables have RLS enabled
2. All data tables have FORCE RLS enabled
3. Each data table has a SELECT policy
4. No write policies exist on public data tables (user_preferences excluded)
5. `anon` has no INSERT privilege
6. `anon` has no UPDATE privilege
7. `anon` has no DELETE privilege
8. All `api_*` functions are SECURITY DEFINER
9. `anon` can EXECUTE all `api_*` functions
10. `anon` blocked from internal functions (incl. `resolve_effective_country`)
11. `service_role` retains full privileges
12. All `api_*` functions have `search_path` set
13. `anon` has no SELECT on data tables (RPC-only)
14. New tables have RLS enabled
15. Products table has `updated_at` trigger
16. `user_preferences` has RLS enabled and forced
17. `user_preferences` has user-scoped SELECT policy
18. `user_preferences` has user-scoped INSERT policy
19. `user_preferences` has user-scoped UPDATE policy
20. `user_preferences` has `updated_at` trigger
21. `resolve_effective_country` is SECURITY DEFINER with `search_path` set
22. `resolve_effective_country` EXECUTE revoked from `authenticated`

**Total QA coverage:** 333 checks across 22 suites + 23 negative validation tests.
