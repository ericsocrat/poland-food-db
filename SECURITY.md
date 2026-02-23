# Security

## Known Vulnerabilities

Last audited: 2026-02-14 (vulnerability table below may be stale — re-run `cd frontend && npm audit --omit=dev` to refresh)

### Summary

> **Note:** The project upgraded to **Next.js 15.5.12**. The advisories below were
> originally filed against Next.js 14.x. Run `npm audit --omit=dev` to verify
> which, if any, still apply to the current version.

| Package               | Severity | Advisory                                       | Status        |
| --------------------- | -------- | ---------------------------------------------- | ------------- |
| `next` 14.2.35        | High     | [GHSA-9g9p-9gw9-jx7f][1] (Image Optimizer DoS) | Accepted risk |
| `next` 14.2.35        | High     | [GHSA-h25m-26qc-wcjf][2] (RSC deserialization) | Accepted risk |
| `glob` 10.3.10        | High     | [GHSA-5j98-mcp5-4vw2][3] (CLI injection)       | Accepted risk |
| `@next/eslint-plugin` | High     | Transitive via `glob`                          | Accepted risk |

[1]: https://github.com/advisories/GHSA-9g9p-9gw9-jx7f
[2]: https://github.com/advisories/GHSA-h25m-26qc-wcjf
[3]: https://github.com/advisories/GHSA-5j98-mcp5-4vw2

### Risk Assessment

**GHSA-9g9p-9gw9-jx7f — Image Optimizer DoS:**
- Affects self-hosted Next.js with `remotePatterns` in image config.
- We deploy on Vercel (managed infrastructure), not self-hosted.
- Our `next.config.js` does not configure `remotePatterns`.
- **Not practically exploitable in this deployment.**

**GHSA-h25m-26qc-wcjf — RSC deserialization DoS:**
- Requires "insecure React Server Components" usage patterns.
- Our RSC usage is standard (data fetching via Supabase client).
- Vercel's infrastructure provides additional request-level protections.
- **Low practical risk.** Will be resolved on Next.js 15/16 upgrade.

**GHSA-5j98-mcp5-4vw2 — glob CLI injection:**
- The `glob` CLI (`--cmd` flag) allows command injection.
- This is a **dev/build-time dependency** (via `eslint-config-next`).
- Never exposed to user input at runtime.
- **Not exploitable** — only runs during development/CI builds with trusted input.

### Remediation Plan

The project is now on **Next.js 15.5.12**. The advisories listed above were filed
against v14.x and may no longer apply. Re-run `npm audit --omit=dev` and refresh
this table when vulnerabilities change.

### Application Security Measures

- **Row Level Security (RLS):** All Supabase tables have RLS enabled.
- **SECURITY DEFINER functions:** All 10 API RPCs use `SECURITY DEFINER` with `anon_can_execute = false`.
- **Auth middleware:** All `/app/*` routes require authenticated sessions.
- **Open redirect prevention:** Login redirect param validated (relative paths only, no `//` prefix).
- **No hardcoded secrets:** All credentials via environment variables.

---

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

**Total QA coverage:** 421 checks across 30 suites + 29 negative validation tests.
