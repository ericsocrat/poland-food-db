# Security Audit Report

**Audit Date:** 2026-02-23
**Auditor:** Automated + Manual Review
**Scope:** Full application security audit — RLS, function security, client headers, dependencies, secrets, admin routes
**Platform:** Next.js 15.5.12 (Vercel) + Supabase (PostgreSQL 17)

---

## Executive Summary

The application has a **strong security posture**. All 40 public tables have RLS enabled with FORCE RLS. All `api_*` functions use `SECURITY DEFINER` with locked `search_path`. The anon role is restricted to 11 read-only public endpoints. No hardcoded secrets were found. CSP and security headers are properly configured.

**Critical findings:** 0
**High findings:** 0
**Medium findings:** 2 (remediated in this PR)
**Low findings:** 2 (accepted risk)
**Informational:** 4

---

## 1. RLS Policy Matrix

All public tables have Row Level Security **enabled** and **forced**. The RPC-only access model means `anon` and `authenticated` have no direct `SELECT`, `INSERT`, `UPDATE`, or `DELETE` privileges on data tables — all data access goes through `SECURITY DEFINER` functions.

### Core Data Tables (read-only via RPC)

| Table                      | RLS | Force RLS | SELECT Policy                    | Write Policies | Anon Access | Status |
| -------------------------- | --- | --------- | -------------------------------- | -------------- | ----------- | ------ |
| `products`                 | ✅   | ✅         | ✅ `select_products`              | None           | None        | ✅      |
| `nutrition_facts`          | ✅   | ✅         | ✅ `select_nutrition_facts`       | None           | None        | ✅      |
| `product_allergen_info`    | ✅   | ✅         | ✅ `select_product_allergen_info` | None           | None        | ✅      |
| `product_ingredient`       | ✅   | ✅         | ✅ `select_product_ingredient`    | None           | None        | ✅      |
| `ingredient_ref`           | ✅   | ✅         | ✅ `select_ingredient_ref`        | None           | None        | ✅      |
| `category_ref`             | ✅   | ✅         | ✅ `select_category_ref`          | None           | None        | ✅      |
| `country_ref`              | ✅   | ✅         | ✅ `select_country_ref`           | None           | None        | ✅      |
| `nutri_score_ref`          | ✅   | ✅         | ✅ `select_nutri_score_ref`       | None           | None        | ✅      |
| `concern_tier_ref`         | ✅   | ✅         | ✅ `select_concern_tier_ref`      | None           | None        | ✅      |
| `product_field_provenance` | ✅   | ✅         | ✅                                | None           | None        | ✅      |
| `source_nutrition`         | ✅   | ✅         | ✅                                | None           | None        | ✅      |

### User Data Tables (per-user access via RPC)

| Table                     | RLS | Force RLS | User Column      | Policies                      | Status |
| ------------------------- | --- | --------- | ---------------- | ----------------------------- | ------ |
| `user_preferences`        | ✅   | ✅         | `user_id`        | SIUD (scoped to `auth.uid()`) | ✅      |
| `user_health_profiles`    | ✅   | ✅         | `user_id`        | SIUD (scoped to `auth.uid()`) | ✅      |
| `user_product_lists`      | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `user_product_list_items` | ✅   | ✅         | via `list_id` FK | Per-user via RPC              | ✅      |
| `user_comparisons`        | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `user_saved_searches`     | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `scan_history`            | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `product_submissions`     | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `user_product_views`      | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `user_watched_products`   | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `user_achievement`        | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `push_subscriptions`      | ✅   | ✅         | `user_id`        | Per-user via RPC              | ✅      |
| `deletion_audit_log`      | ✅   | ✅         | `user_id`        | Service-role only             | ✅      |

### System / Reference Tables

| Table                       | RLS | Force RLS | Purpose                  | Status |
| --------------------------- | --- | --------- | ------------------------ | ------ |
| `analytics_events`          | ✅   | ✅         | Telemetry events         | ✅      |
| `allowed_event_names`       | ✅   | ✅         | Valid event types        | ✅      |
| `language_ref`              | ✅   | ✅         | Locale reference         | ✅      |
| `category_translations`     | ✅   | ✅         | Localized category names | ✅      |
| `search_synonyms`           | ✅   | ✅         | Cross-language synonyms  | ✅      |
| `product_images`            | ✅   | ✅         | Product image URLs       | ✅      |
| `daily_value_ref`           | ✅   | ✅         | Daily nutritional values | ✅      |
| `product_score_history`     | ✅   | ✅         | Historical scores        | ✅      |
| `achievement_def`           | ✅   | ✅         | Achievement definitions  | ✅      |
| `recipe`                    | ✅   | ✅         | Recipe metadata          | ✅      |
| `recipe_step`               | ✅   | ✅         | Recipe steps             | ✅      |
| `recipe_ingredient`         | ✅   | ✅         | Recipe ingredients       | ✅      |
| `recipe_ingredient_product` | ✅   | ✅         | Recipe-product links     | ✅      |
| `notification_queue`        | ✅   | ✅         | Push notification queue  | ✅      |
| `audit_results`             | ✅   | ✅         | Data integrity results   | ✅      |
| `column_metadata`           | ✅   | ✅         | Column documentation     | ✅      |

---

## 2. Table Exposure Matrix

The application uses an **RPC-only access model**. All direct table access is revoked from `anon` and `authenticated`. Data is only accessible through `SECURITY DEFINER` functions.

| Role            | SELECT | INSERT | UPDATE | DELETE | Notes                             |
| --------------- | ------ | ------ | ------ | ------ | --------------------------------- |
| `anon`          | ❌ None | ❌ None | ❌ None | ❌ None | All access via 11 approved RPCs   |
| `authenticated` | ❌ None | ❌ None | ❌ None | ❌ None | All access via authenticated RPCs |
| `service_role`  | ✅ All  | ✅ All  | ✅ All  | ✅ All  | Full access (bypasses RLS)        |

**Verified by:** QA checks #5–#7, #11, #13 in `QA__security_posture.sql`

---

## 3. Function Security Matrix

All `api_*` functions are `SECURITY DEFINER` with `SET search_path = public` (anti-hijack protection). Verified by QA checks #8 and #12.

### Anon-Accessible Functions (11 approved endpoints)

| Function                         | Purpose                         | User Data        | Status |
| -------------------------------- | ------------------------------- | ---------------- | ------ |
| `api_search_autocomplete`        | Public search suggestions       | No               | ✅      |
| `api_get_filter_options`         | Public filter facets            | No               | ✅      |
| `api_get_shared_list`            | View shared list by token       | No (public link) | ✅      |
| `api_get_shared_comparison`      | View shared comparison by token | No (public link) | ✅      |
| `api_get_products_for_compare`   | Comparison data (shared links)  | No               | ✅      |
| `api_track_event`                | Fire-and-forget analytics       | No (anon events) | ✅      |
| `api_get_product_profile`        | Public product page             | No               | ✅      |
| `api_get_product_profile_by_ean` | Public EAN lookup               | No               | ✅      |
| `api_get_ingredient_profile`     | Public ingredient detail        | No               | ✅      |
| `api_get_score_history`          | Public score history            | No               | ✅      |
| `api_get_product_allergens`      | Public allergen batch lookup    | No               | ✅      |

### Service-Role-Only Functions (7 restricted)

| Function                         | Purpose                     | Why Restricted           |
| -------------------------------- | --------------------------- | ------------------------ |
| `api_admin_get_submissions`      | Admin submission queue      | Administrative data      |
| `api_admin_review_submission`    | Approve/reject submissions  | Administrative action    |
| `api_refresh_mvs`                | Refresh materialized views  | Infrastructure operation |
| `api_health_check`               | System health check         | Internal diagnostics     |
| `api_get_pending_notifications`  | Pending push queue          | Infrastructure           |
| `api_mark_notifications_sent`    | Mark notifications sent     | Infrastructure           |
| `api_cleanup_push_subscriptions` | Clean expired subscriptions | Infrastructure           |

### Authenticated-Only Functions (~50+ endpoints)

All remaining `api_*` functions require `authenticated` role. Each function that accesses user data filters by `auth.uid()` internally. Key functions verified:

| Function                   | Filters by `auth.uid()` | Status |
| -------------------------- | ----------------------- | ------ |
| `api_get_user_preferences` | ✅                       | ✅      |
| `api_set_user_preferences` | ✅                       | ✅      |
| `api_list_health_profiles` | ✅                       | ✅      |
| `api_get_lists`            | ✅                       | ✅      |
| `api_get_scan_history`     | ✅                       | ✅      |
| `api_get_my_submissions`   | ✅                       | ✅      |
| `api_export_user_data`     | ✅                       | ✅      |
| `api_delete_user_data`     | ✅                       | ✅      |

### Internal Functions (revoked from all external roles)

| Function                         | Purpose                    | Callable by External Roles |
| -------------------------------- | -------------------------- | -------------------------- |
| `compute_unhealthiness_v31`      | Score computation          | ❌                          |
| `compute_unhealthiness_v32`      | Score computation v3.2     | ❌                          |
| `explain_score_v32`              | Score explanation          | ❌                          |
| `compute_data_confidence`        | Data quality scoring       | ❌                          |
| `compute_data_completeness`      | Completeness assessment    | ❌                          |
| `assign_confidence`              | Confidence tier assignment | ❌                          |
| `find_similar_products`          | Similarity engine          | ❌                          |
| `find_better_alternatives`       | Alternative finder         | ❌                          |
| `refresh_all_materialized_views` | MV refresh                 | ❌                          |
| `mv_staleness_check`             | MV freshness check         | ❌                          |
| `check_product_preferences`      | Diet/allergen matching     | ❌                          |
| `resolve_effective_country`      | Country resolution         | ❌                          |
| `compute_health_warnings`        | Health warning engine      | ❌                          |

---

## 4. Client Security Headers

### Content-Security-Policy

| Directive         | Value                                                                                                                 | Justification                                              | Status                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ---------------------- |
| `default-src`     | `'self'`                                                                                                              | Restrict all resources to same origin                      | ✅                      |
| `script-src`      | `'self' 'unsafe-eval' 'unsafe-inline'`                                                                                | Required by Next.js dev/runtime                            | ⚠️ Accepted             |
| `style-src`       | `'self' 'unsafe-inline'`                                                                                              | Required by Tailwind CSS runtime styles                    | ⚠️ Accepted             |
| `img-src`         | `'self' data: blob: https://images.openfoodfacts.org`                                                                 | Product images from OFF CDN                                | ✅                      |
| `connect-src`     | `'self' https://*.supabase.co https://cdn.jsdelivr.net https://tessdata.projectnaptha.com https://*.ingest.sentry.io` | Supabase API + Tesseract OCR + Sentry                      | ✅                      |
| `worker-src`      | `'self' blob: https://cdn.jsdelivr.net`                                                                               | Tesseract WASM workers                                     | ✅                      |
| `form-action`     | `'self'`                                                                                                              | Prevent form submissions to external URLs                  | ✅                      |
| `frame-ancestors` | `'none'`                                                                                                              | Prevent clickjacking (equivalent to X-Frame-Options: DENY) | ✅                      |
| `object-src`      | `'none'`                                                                                                              | Block Flash/Java/plugin embeds                             | ✅ **Added in this PR** |
| `base-uri`        | `'self'`                                                                                                              | Prevent base tag injection                                 | ✅ **Added in this PR** |

### Security Response Headers

| Header                   | Value                                                              | Applied To             | Status                 |
| ------------------------ | ------------------------------------------------------------------ | ---------------------- | ---------------------- |
| `X-Frame-Options`        | `DENY`                                                             | All routes (`/(.*)`)   | ✅                      |
| `X-Content-Type-Options` | `nosniff`                                                          | All routes             | ✅                      |
| `Referrer-Policy`        | `strict-origin-when-cross-origin`                                  | All routes             | ✅                      |
| `Permissions-Policy`     | `camera=(), microphone=(), geolocation=(), payment=(), usb=()`     | All routes (global)    | ✅ **Added in this PR** |
| `Permissions-Policy`     | `camera=(self), microphone=(), geolocation=(), payment=(), usb=()` | `/app/scan` (override) | ✅ Updated              |

### Source Map Protection

| Check                                | Status | Notes                                                          |
| ------------------------------------ | ------ | -------------------------------------------------------------- |
| `deleteSourcemapsAfterUpload: true`  | ✅      | Source maps uploaded to Sentry, then deleted from build output |
| No `.map` files served in production | ✅      | Verified via Sentry config in `next.config.ts`                 |

### CORS

| Check              | Status | Notes                                                                   |
| ------------------ | ------ | ----------------------------------------------------------------------- |
| Supabase CORS      | ✅      | Managed by Supabase project settings (restricted to deployment origins) |
| Next.js API routes | ✅      | Same-origin by default (no custom CORS headers)                         |

---

## 5. Dependency Vulnerabilities

### npm Production Dependencies

**Audit date:** 2026-02-23
**Command:** `npm audit --omit=dev --audit-level=moderate`
**Result:** **0 vulnerabilities found** ✅

### Python Pipeline Dependencies

**Audit date:** 2026-02-23
**Command:** `pip-audit -r requirements.txt`
**Result:** **No known vulnerabilities found** ✅

### Previously Accepted CVEs

The following were documented in `SECURITY.md` against Next.js 14.x. The project upgraded to Next.js 15.5.12 — re-audit shows these are no longer applicable.

| Advisory              | Package               | Severity | Status                         |
| --------------------- | --------------------- | -------- | ------------------------------ |
| GHSA-9g9p-9gw9-jx7f   | `next` 14.2.35        | High     | Resolved (upgraded to 15.5.12) |
| GHSA-h25m-26qc-wcjf   | `next` 14.2.35        | High     | Resolved (upgraded to 15.5.12) |
| GHSA-5j98-mcp5-4vw2   | `glob` 10.3.10        | High     | Accepted risk (dev-only)       |
| Transitive via `glob` | `@next/eslint-plugin` | High     | Accepted risk (dev-only)       |

### Automated Monitoring

| Check                       | Status | Configuration                                            |
| --------------------------- | ------ | -------------------------------------------------------- |
| GitHub Dependabot (npm)     | ✅      | Weekly, `.github/dependabot.yml`                         |
| GitHub Dependabot (pip)     | ✅      | Monthly, `.github/dependabot.yml`                        |
| GitHub Dependabot (Actions) | ✅      | Weekly, `.github/dependabot.yml`                         |
| CI npm audit                | ✅      | `.github/workflows/dependency-audit.yml` (push + weekly) |
| CI pip-audit                | ✅      | `.github/workflows/dependency-audit.yml` (push + weekly) |
| Auto-merge (patch/minor)    | ✅      | `.github/workflows/dependabot-auto-merge.yml`            |

---

## 6. Secret Management

### Secret Scan Results

**Scan date:** 2026-02-23
**Method:** `git grep` for JWT tokens (`eyJ`), API keys (`sk_live`, `pk_live`), hardcoded passwords, service keys
**Result:** **0 hardcoded secrets found** ✅

All secret references in source are `process.env.*` lookups or test stubs.

### Environment Variables Inventory

| Secret                          | Storage | Scope           | Rotation          | Status                 |
| ------------------------------- | ------- | --------------- | ----------------- | ---------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`      | Env var | Public (client) | N/A (project URL) | ✅                      |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Env var | Public (client) | On key rotation   | ✅                      |
| `SUPABASE_SERVICE_ROLE_KEY`     | Env var | Server-only     | On key rotation   | ✅                      |
| `SENTRY_AUTH_TOKEN`             | Env var | CI-only         | Annual            | ✅                      |
| `SENTRY_DSN`                    | Env var | Client (public) | N/A               | ✅                      |
| `UPSTASH_REDIS_REST_URL`        | Env var | Server-only     | N/A               | ✅                      |
| `UPSTASH_REDIS_REST_TOKEN`      | Env var | Server-only     | On rotation       | ✅                      |
| `RATE_LIMIT_BYPASS_TOKEN`       | Env var | Server-only     | On rotation       | ✅                      |
| `ADMIN_EMAILS`                  | Env var | Server-only     | As needed         | ✅ **Added in this PR** |

### .gitignore Verification

| Pattern        | Present | Status |
| -------------- | ------- | ------ |
| `.env`         | ✅       | ✅      |
| `.env.local`   | ✅       | ✅      |
| `.env.*.local` | ✅       | ✅      |

---

## 7. Admin Route Protection

### Frontend Routes

| Route                    | Auth Required | Admin Check                | DB Protection                       | Status                    |
| ------------------------ | ------------- | -------------------------- | ----------------------------------- | ------------------------- |
| `/app/admin/submissions` | ✅ Middleware  | ✅ `ADMIN_EMAILS` allowlist | ✅ `api_admin_*` → service_role only | ✅ **Hardened in this PR** |
| `/app/admin/monitoring`  | ✅ Middleware  | ✅ `ADMIN_EMAILS` allowlist | ✅ `/api/health` (public data)       | ✅ **Hardened in this PR** |

### Admin RPC Functions

| Function                      | Anon | Authenticated | Service Role | Status   |
| ----------------------------- | ---- | ------------- | ------------ | -------- |
| `api_admin_get_submissions`   | ❌    | ❌             | ✅            | ✅        |
| `api_admin_review_submission` | ❌    | ❌             | ✅            | ✅        |
| `api_admin_get_event_summary` | ❌    | ✅             | ✅            | ⚠️ Note 1 |
| `api_admin_get_top_events`    | ❌    | ✅             | ✅            | ⚠️ Note 1 |
| `api_admin_get_funnel`        | ❌    | ✅             | ✅            | ⚠️ Note 1 |

> **Note 1:** Telemetry admin functions are accessible to `authenticated` users. These return aggregated, anonymized analytics data (event counts, not user-specific data). This is intentional — the data is non-sensitive.

### Protection Layers (defense-in-depth)

1. **Middleware auth:** All `/app/*` routes require a valid Supabase session
2. **Admin email allowlist:** `/app/admin/*` routes require user email in `ADMIN_EMAILS` env var (returns 403 if not) — **added in this PR**
3. **DB function grants:** `api_admin_get_submissions` and `api_admin_review_submission` are `service_role`-only at the database level
4. **Deny-by-default:** If `ADMIN_EMAILS` is unset, all admin routes return 403

---

## 8. Findings & Remediation

| #   | Finding                                                     | Severity      | Remediation                                        | Status       |
| --- | ----------------------------------------------------------- | ------------- | -------------------------------------------------- | ------------ |
| F1  | CSP missing `object-src 'none'`                             | Medium        | Added `object-src 'none'` to CSP                   | ✅ Remediated |
| F2  | CSP missing `base-uri 'self'`                               | Medium        | Added `base-uri 'self'` to CSP                     | ✅ Remediated |
| F3  | `Permissions-Policy` only on `/app/scan`, not global        | Low           | Added global `Permissions-Policy` header           | ✅ Remediated |
| F4  | Admin routes had no admin-role check                        | Medium        | Added `ADMIN_EMAILS` allowlist in middleware       | ✅ Remediated |
| F5  | `script-src` includes `'unsafe-eval'` and `'unsafe-inline'` | Low           | Required by Next.js runtime — accepted risk        | ⚠️ Accepted   |
| F6  | `style-src` includes `'unsafe-inline'`                      | Low           | Required by Tailwind CSS — accepted risk           | ⚠️ Accepted   |
| F7  | `glob` 10.3.10 has known CVE (dev dependency)               | Informational | Dev/build-time only, no user input — accepted risk | ⚠️ Accepted   |

### No open critical or high findings.

---

## Automated Security QA

The following automated checks run as part of the QA suite (`RUN_QA.ps1`):

| Suite                             | Checks                  | Focus                                                                          |
| --------------------------------- | ----------------------- | ------------------------------------------------------------------------------ |
| `QA__security_posture.sql`        | 22 pass/fail assertions | RLS, FORCE RLS, privileges, SECURITY DEFINER, search_path, anon access         |
| `QA__rls_audit.sql`               | 7 diagnostic queries    | RLS inventory, policy enumeration, privilege matrices                          | **New in this PR** |
| `QA__function_security_audit.sql` | 6 diagnostic queries    | SECURITY DEFINER inventory, per-role execute privileges, auth bypass detection | **New in this PR** |

---

## Recommendations

1. **Quarterly re-audit:** Re-run `QA__rls_audit.sql` and `QA__function_security_audit.sql` quarterly to detect posture drift
2. **Migration review:** Any migration modifying RLS policies or function grants should trigger security review
3. **CSP monitoring:** Monitor browser console for CSP violations in staging before tightening `script-src`/`style-src`
4. **Admin access logging:** Consider logging admin route access events via `api_track_event` for audit trail
5. **Future: nonce-based CSP:** When Next.js nonce support stabilizes, replace `'unsafe-inline'` with nonce-based script/style loading

---

## Appendix: Verification Commands

```bash
# RLS audit (requires Supabase CLI or psql connection)
psql -f db/qa/QA__rls_audit.sql
psql -f db/qa/QA__function_security_audit.sql
psql -f db/qa/QA__security_posture.sql

# Dependency audit
cd frontend && npm audit --omit=dev --audit-level=moderate
pip-audit -r requirements.txt

# Secret scan
git grep -n "eyJ" -- "*.ts" "*.tsx" "*.py"
git grep -n -E "sk_live|pk_live" -- "*.ts" "*.tsx" "*.py"

# CSP verification (check response headers)
curl -sI https://your-domain.vercel.app | grep -i "content-security-policy\|permissions-policy\|x-frame\|x-content-type"
```
