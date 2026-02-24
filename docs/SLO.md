# Platform Service Level Objectives

> **Status:** Active — all issues MUST reference this document for performance targets.  
> **Parent:** [#195 — Execution Governance Blueprint](https://github.com/ericsocrat/poland-food-db/issues/195)  
> **Last updated:** 2026-02-24

---

## 1. API Response Time SLOs

| Endpoint / RPC | P50 Target | P95 Target | P99 Target | Error Budget | Notes |
|---|---|---|---|---|---|
| `api_product_detail()` | ≤50ms | ≤150ms | ≤300ms | <0.1% | Core user flow |
| `api_product_detail_by_ean()` | ≤50ms | ≤150ms | ≤300ms | <0.1% | Scanner flow |
| `api_category_listing()` | ≤80ms | ≤200ms | ≤400ms | <0.1% | Pagination-dependent |
| `api_search_products()` | ≤100ms | ≤200ms | ≤500ms | <0.5% | Depends on query complexity |
| `api_search_autocomplete()` | ≤30ms | ≤80ms | ≤150ms | <0.5% | Must feel instant |
| `api_score_explanation()` | ≤60ms | ≤150ms | ≤300ms | <0.1% | Score breakdown |
| `api_better_alternatives()` | ≤100ms | ≤250ms | ≤500ms | <0.2% | Cross-join heavy |
| `api_data_confidence()` | ≤40ms | ≤100ms | ≤200ms | <0.1% | Confidence score |
| `api_get_filter_options()` | ≤30ms | ≤80ms | ≤150ms | <0.1% | Cached after first call |
| `api_category_overview()` | ≤50ms | ≤150ms | ≤300ms | <0.1% | Dashboard view |
| `api_track_event()` | ≤20ms | ≤50ms | ≤100ms | <1.0% | Fire-and-forget, non-blocking |
| `api_record_scan()` | ≤30ms | ≤80ms | ≤150ms | <0.1% | Scanner critical path |
| `api_record_product_view()` | ≤20ms | ≤50ms | ≤100ms | <1.0% | Telemetry, non-blocking |
| `api_score_history()` | ≤60ms | ≤150ms | ≤300ms | <0.1% | Score audit data |
| `admin_scoring_versions()` | ≤40ms | ≤100ms | ≤200ms | <0.1% | Admin only |
| `admin_score_drift_report()` | ≤200ms | ≤500ms | ≤1000ms | <0.5% | Analytical query |

---

## 2. Availability SLOs

| Service | Target | Measurement Window | Notes |
|---|---|---|---|
| API (all RPC endpoints) | 99.5% | Rolling 30 days | Excludes scheduled maintenance |
| Frontend (Next.js) | 99.5% | Rolling 30 days | Vercel-hosted |
| Database (Supabase) | 99.9% | Rolling 30 days | Supabase SLA passthrough |
| Auth (Supabase Auth) | 99.9% | Rolling 30 days | Supabase SLA passthrough |

### Allowed Downtime Budget

| Availability | Downtime per 30 days | Downtime per day |
|---|---|---|
| 99.5% | ~3.6 hours | ~7.2 minutes |
| 99.9% | ~43 minutes | ~1.4 minutes |
| 99.95% | ~22 minutes | ~43 seconds |

---

## 3. Error Budget Definitions

| Error Budget Level | Max Error Rate | Applies To | Meaning |
|---|---|---|---|
| **Critical path** | <0.1% | Product detail, scanner, auth | Zero tolerance — user-facing core flows |
| **Standard path** | <0.5% | Search, listing, filters, scoring | Low tolerance — primary UX |
| **Telemetry path** | <1.0% | Event tracking, view recording | Best effort — data quality |

### Error Budget Consumption Rules

1. **Budget exceeded for 1 hour:** Investigate immediately, create incident ticket.
2. **Budget exceeded for 24 hours:** All feature work pauses; focus shifts to reliability.
3. **Budget exceeded for 7 days:** Roll back last deployment; full root-cause analysis required.

---

## 4. Query Performance SLOs

| Query Type | P95 Target | Max Rows Scanned | Notes |
|---|---|---|---|
| Single product lookup (PK or EAN) | ≤5ms | 1 row | Index scan |
| Category listing (page) | ≤50ms | ≤100 rows | Paginated, indexed |
| Full-text search | ≤100ms | ≤500 rows | GIN index + pg_trgm |
| Scoring computation (single product) | ≤10ms | 1 row | Pure function, IMMUTABLE |
| Score batch (per 1K rows) | ≤500ms | 1,000 rows | Pipeline batch operation |
| Materialized view refresh (CONCURRENTLY) | ≤5s | All rows | Non-blocking |
| Autocomplete prefix search | ≤20ms | ≤50 rows | Trigram GIN index |

---

## 5. Data Retention Schedule

### Application Data

| Data Type | Location | Retention | Justification |
|---|---|---|---|
| Products (active) | `products` table | Indefinite | Core business data |
| Products (deprecated) | `products` table (`is_deprecated = true`) | Indefinite | Historical reference |
| Score audit log | `score_audit_log` table | 365 days | Scoring transparency |
| Score distribution snapshots | `score_distribution_snapshots` table | 365 days | Drift analysis |
| Scoring model versions | `scoring_model_versions` table | Indefinite | Version history |
| Feature flags | `feature_flags` table | Indefinite | Configuration |
| Feature flag audit | `feature_flag_audit_log` table | 365 days | Change tracking |
| User preferences | `user_preferences` table | Until account deletion | GDPR |
| User health profiles | `health_profiles` table | Until account deletion | GDPR |
| User product lists | `product_lists` table | Until account deletion | GDPR |
| User comparisons | `comparisons` table | Until account deletion | GDPR |
| Scan history | `scan_history` table | 365 days | User feature |
| Product submissions | `product_submissions` table | Indefinite | User content, review pipeline |
| Analytics events | `events` table (future) | 365 days | Product analytics |

### Operational Data

| Data Type | Location | Retention | Justification |
|---|---|---|---|
| Application logs (DEBUG) | Log provider | 7 days | Dev-only, high volume |
| Application logs (INFO) | Log provider | 30 days | Normal operations |
| Application logs (WARN) | Log provider | 90 days | Operational review |
| Application logs (ERROR) | Log provider | 365 days | Incident analysis |
| Application logs (CRITICAL) | Log provider + backup | Indefinite | Post-mortem evidence |
| QA run results | CI artifacts | 90 days | Compliance verification |
| Query performance snapshots | `query_performance_snapshots` (future) | 90 days (weekly) | Regression detection |
| Alert history | Monitoring provider | 180 days | Incident pattern analysis |
| Contract test artifacts | CI artifacts | 30 days | PR validation |
| Playwright screenshots/traces | CI artifacts | 14 days | Flake investigation |
| Backfill registry records | `backfill_registry` table (future) | Indefinite | Audit trail |
| CI build logs | GitHub Actions | 90 days | GitHub default |
| Database backups | Supabase | 7 days (point-in-time) | Supabase Pro plan |
| Cloud SQL backups | Manual (`backups/`) | Latest only | Emergency recovery |

### Retention Enforcement

- **> 90 day retention:** Verify quarterly that data exists and is accessible.
- **≤ 90 day retention:** Automated cleanup via scheduled function or CI job.
- **User data:** Deleted on account deletion (GDPR right to erasure).
- **Rule:** No data type should have undefined retention. If it generates data, it must appear in this table.

---

## 6. Frontend Performance SLOs

| Metric | Target | Measurement | Notes |
|---|---|---|---|
| Largest Contentful Paint (LCP) | ≤2.5s | Lighthouse CI | Core Web Vital |
| First Input Delay (FID) | ≤100ms | Lighthouse CI | Core Web Vital |
| Cumulative Layout Shift (CLS) | ≤0.1 | Lighthouse CI | Core Web Vital |
| Time to First Byte (TTFB) | ≤600ms | Lighthouse CI | Server responsiveness |
| JS Bundle Size | ≤250KB gzipped | Bundle Size Guard CI | First-load JS |
| Page load (complete) | ≤3s | Lighthouse CI | End-to-end |

---

## 7. SLO Compliance Checklist

Every new issue or PR that defines performance targets must include:

```markdown
## SLO Compliance
- [ ] Performance targets reference `docs/SLO.md` (not ad-hoc numbers)
- [ ] Error budget level specified (critical / standard / telemetry)
- [ ] Data retention specified in Retention Matrix if new data type introduced
- [ ] Alert thresholds align with SLO targets
```

---

## 8. Cross-References

Issues that define or depend on SLO thresholds:

| Issue | What It References | Alignment |
|---|---|---|
| #183 (Observability) | Measurement infrastructure for SLO tracking | Defines how SLOs are measured |
| #185 (Performance Guardrails) | P95 thresholds for QA tests | Must match Section 1 targets |
| #192 (Search Architecture) | Search P95 ≤200ms | Matches `api_search_products` target |
| #189 (Scoring Engine) | Score computation performance | Matches query SLOs (Section 4) |
| #211 (Alert Escalation) | Alert thresholds and escalation | Must map 1:1 to SLO targets |
| #210 (Log Schema) | Log retention by severity | Must match retention matrix (Section 5) |

---

## How to Reference This Document

In any issue or PR that defines performance targets:

> **SLO Reference:** See `docs/SLO.md` — `{endpoint}` P95 ≤{X}ms, error budget <{Y}%

Example:
> **SLO Reference:** See `docs/SLO.md` — `api_search_products()` P95 ≤200ms, error budget <0.5%

---

*Last updated: 2026-02-24 — Created as part of #228*
