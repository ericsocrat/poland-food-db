# Security Model

## Threat Model

This project is a **public food quality database** — there is no user-generated content, no PII, and no authentication-gated data. The primary security concerns are:

| Threat                          | Mitigation                                                                                |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| **Unauthorized data mutation**  | RLS enabled + FORCE on all tables; no INSERT/UPDATE/DELETE policies; anon/auth are read-only |
| **Schema/data exfiltration**    | Raw table SELECT revoked from `anon` and `authenticated`; all data served via SECURITY DEFINER RPCs |
| **SQL injection via RPC args**  | All API functions use parameterized queries (no dynamic SQL with user input in `api_product_detail`, `api_search_products`, etc.) |
| **Function privilege escalation** | Internal functions (`compute_*`, `find_*`, `refresh_*`, `cross_validate_*`) are revoked from `anon`/`authenticated` |
| **Denial of service (query)**   | `statement_timeout = 5s` on `anon`, `authenticated`, `authenticator`; `idle_in_transaction_session_timeout = 30s` |
| **Unbounded result sets**       | All list/search APIs clamp `p_limit` to max 100; `max_rows = 1000` in PostgREST config |
| **Stale materialized views**    | `mv_staleness_check()` alerts when views exceed refresh threshold |

## Access Control Architecture

```
┌─────────────────────────────────────────────────────┐
│  PostgREST  (runs as `authenticator` → sets `anon`) │
├─────────────────────────────────────────────────────┤
│                                                     │
│  anon / authenticated                               │
│    ✓ EXECUTE api_product_detail(bigint)              │
│    ✓ EXECUTE api_search_products(text, ...)          │
│    ✓ EXECUTE api_category_listing(text, ...)         │
│    ✓ EXECUTE api_score_explanation(bigint)           │
│    ✓ EXECUTE api_better_alternatives(bigint, ...)    │
│    ✓ EXECUTE api_data_confidence(bigint)             │
│    ✗ SELECT on any table or view                     │
│    ✗ INSERT / UPDATE / DELETE on any table           │
│    ✗ EXECUTE on internal functions                   │
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
└─────────────────────────────────────────────────────┘
```

## RPC-Only Model

Direct REST access to tables and views is **blocked** for client-facing roles (`anon`, `authenticated`). All data access is routed through six curated API functions:

| Function                    | Purpose                              |
| --------------------------- | ------------------------------------ |
| `api_product_detail`        | Full product view with freshness     |
| `api_search_products`       | Text search with relevance ranking   |
| `api_category_listing`      | Browse by category with sort/page    |
| `api_score_explanation`     | Score breakdown with category context|
| `api_better_alternatives`   | Healthier alternatives for a product |
| `api_data_confidence`       | Data quality assessment per product  |

This approach provides:
- **Contract stability** — API key sets are locked and tested (23 QA checks)
- **Performance control** — Functions apply pagination limits and optimized queries
- **Security** — No direct table access means zero risk of filter bypass or column enumeration

## Row-Level Security

RLS is enabled and forced on all 11 data tables. Current policies are `SELECT USING (true)` — permissive by design since all data is public. These policies serve as defense-in-depth: even if SELECT privilege were accidentally re-granted, RLS would still apply.

Write policies (INSERT/UPDATE/DELETE) do **not** exist, enforcing read-only access at the policy level in addition to the privilege level.

## QA Coverage

Security posture is validated by 15 automated checks (`QA__security_posture.sql`):

1. All data tables have RLS enabled
2. All data tables have FORCE RLS enabled
3. Each data table has a SELECT policy
4. No write policies exist on data tables
5. `anon` has no INSERT privilege
6. `anon` has no UPDATE privilege
7. `anon` has no DELETE privilege
8. All `api_*` functions are SECURITY DEFINER
9. `anon` can EXECUTE all `api_*` functions
10. `anon` blocked from internal functions
11. `service_role` retains full privileges
12. All `api_*` functions have `search_path` set
13. `anon` has no SELECT on data tables (RPC-only)
14. New tables have RLS enabled
15. Products table has `updated_at` trigger
