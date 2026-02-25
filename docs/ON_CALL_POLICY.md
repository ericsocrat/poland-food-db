# On-Call & Alert Ownership Policy

> **Last updated:** 2026-03-04
> **Status:** Active
> **Owner:** Eric (sole maintainer)
> **Reference:** [#233](https://github.com/ericsocrat/poland-food-db/issues/233)

---

## 1. Purpose

This document defines **who owns which alert**, **how quickly alerts must be acknowledged**, and **when it is acceptable to defer**. It complements:

- [ALERT_POLICY.md](ALERT_POLICY.md) — alert escalation matrix, query regression detection (#211)
- [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md) — incident response playbook, post-mortem process (#231)
- [SLO.md](SLO.md) — service level objectives and thresholds (#228)
- [LOG_SCHEMA.md](LOG_SCHEMA.md) — structured log schema and error taxonomy (#210)

---

## 2. Alert Source Inventory

| Alert Source | Signal Type | Current Status | Owner |
|---|---|---|---|
| **Sentry** | Frontend errors, unhandled exceptions, performance regressions | Active (`sentry.*.config.ts`) | Eric |
| **Supabase Dashboard** | DB health, connection pool, disk usage, query performance | Active (manual checks) | Eric |
| **GitHub Actions CI** | Build failures, test failures, QA regressions, coverage drops | Active (`.github/workflows/`) | Eric |
| **SonarCloud** | Quality gate failures, new bugs/vulnerabilities, coverage regression | Active (`sonar-project.properties`) | Eric |
| **Vercel** | Deployment failures, function timeouts, edge errors | Active (`vercel.json`) | Eric |
| **Supabase Edge Functions** | Function invocation errors, cold start timeouts | Active (`supabase/functions/`) | Eric |
| **MV Staleness Check** | Materialized views out of date | Available (`mv_staleness_check()`) | Eric |
| **QA Suite Regression** | QA check count mismatch or new failures | Via `qa.yml` workflow | Eric |

---

## 3. Alert-to-Severity Mapping

Severity levels (SEV-1 through SEV-4) align with the escalation matrix in [ALERT_POLICY.md](ALERT_POLICY.md) and the incident response playbook in [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md).

| Signal | SEV-1 (Critical) | SEV-2 (Major) | SEV-3 (Minor) | SEV-4 (Low) |
|---|---|---|---|---|
| **Sentry error rate** | >50 errors/hour (any) | >10 errors/hour (same error) | >3 errors/hour | Isolated single errors |
| **API response time** | All endpoints >5s P50 | Any endpoint >P99 SLO | Any endpoint >P95 SLO | Approaching P95 threshold |
| **DB connections** | Pool exhausted (0 available) | >80% pool utilization | >60% pool utilization | — |
| **Disk usage** | >95% | >85% | >75% | — |
| **CI failure** | `main` branch red >2 hours | `main` branch red <2 hours | Feature branch failures | Flaky test (intermittent) |
| **QA regression** | >10 checks failing | 3–10 checks failing | 1–2 checks failing | Informational check warning |
| **MV staleness** | >48 hours stale | >24 hours stale | >12 hours stale | >6 hours stale |
| **SonarCloud** | Security vulnerability (blocker) | Quality gate failure | New bugs (major) | Code smell increase |
| **Scoring regression** | >5pt avg score change across category | >3pt avg score change | >1pt avg score change | Individual product outlier |

---

## 4. Acknowledgment Time Targets

**Business hours definition:** Monday–Friday, 09:00–18:00 CET/CEST.

| Severity | Ack Time (Business Hours) | Ack Time (Off Hours) | Ack Action |
|---|---|---|---|
| **SEV-1** | 15 minutes | 30 minutes | Open incident issue, begin investigation immediately |
| **SEV-2** | 30 minutes | 2 hours | Open incident issue, assess and plan response |
| **SEV-3** | 2 hours | Next business day | Triage and add to backlog with priority label |
| **SEV-4** | Next business day | Next business day | Add to backlog, schedule for next available slot |

### Acknowledgment Definition

An alert is **acknowledged** when the owner has:

1. Reviewed the alert details (source, severity, impact scope)
2. Created a GitHub issue (if not auto-created) with the appropriate severity and source labels
3. Added a brief triage note to the issue (root cause hypothesis, blast radius estimate)

Acknowledgment does **not** imply resolution — it signals that the alert has been seen and triaged.

---

## 5. GitHub Issue Label Taxonomy

### 5.1 Severity Labels (mutually exclusive)

| Label | Color | Description |
|---|---|---|
| `SEV-1-critical` | `#d73a4a` (red) | Complete outage or data corruption |
| `SEV-2-major` | `#e36209` (orange) | Partial outage or significant degradation |
| `SEV-3-minor` | `#fbca04` (yellow) | Non-critical degradation, workaround exists |
| `SEV-4-low` | `#0e8a16` (green) | Cosmetic or informational |

### 5.2 Source Labels (can stack)

| Label | Color | Description |
|---|---|---|
| `alert:sentry` | `#7057ff` (purple) | Triggered by Sentry error/performance alert |
| `alert:ci` | `#1d76db` (blue) | Triggered by CI/CD pipeline failure |
| `alert:supabase` | `#3ecf8e` (green) | Triggered by Supabase dashboard/health alert |
| `alert:sonarcloud` | `#f9826c` (salmon) | Triggered by SonarCloud quality gate |
| `alert:vercel` | `#000000` (black) | Triggered by Vercel deployment/runtime alert |
| `alert:qa-regression` | `#d4c5f9` (lavender) | Triggered by QA suite regression |
| `alert:manual` | `#bfdadc` (teal) | Manually reported by user or developer |

### 5.3 Domain Labels (can stack)

| Label | Color | Description |
|---|---|---|
| `domain:scoring` | `#c2e0c6` | Scoring formula or methodology issue |
| `domain:data` | `#bfd4f2` | Data integrity or pipeline issue |
| `domain:auth` | `#f9d0c4` | Authentication or authorization issue |
| `domain:api` | `#d4c5f9` | API endpoint or RPC function issue |
| `domain:frontend` | `#fef2c0` | Frontend/UI issue |
| `domain:infra` | `#e6e6e6` | Infrastructure or deployment issue |

### 5.4 Label Selection Guide

When creating an alert-driven issue, apply labels in this order:

1. **Exactly one** severity label (`SEV-1-critical` through `SEV-4-low`)
2. **One or more** source labels indicating which alert source triggered the issue
3. **One or more** domain labels indicating the affected subsystem

Example: A Sentry error showing scoring API timeouts would get:
`SEV-2-major` + `alert:sentry` + `domain:api` + `domain:scoring`

---

## 6. Quiet Hours & Deferral Policy

| Severity | Business Hours | Off Hours (evenings/weekends) | Holidays |
|---|---|---|---|
| **SEV-1** | Respond immediately | Respond within 30 min | Respond within 30 min |
| **SEV-2** | Respond immediately | Respond within 2 hours | Defer to next business day (unless trending to SEV-1) |
| **SEV-3** | Respond within 2 hours | Defer to next business day | Defer to next business day |
| **SEV-4** | Respond within 1 business day | Defer | Defer |

### Alert Suppression Rules

- **Duplicate alerts:** Suppress after acknowledgment — deduplicate by root cause
- **Maintenance windows:** Suppress all SEV-3/4 alerts during planned migrations or deployments
- **Non-main branch CI failures:** Do not alert; developer addresses on their own schedule
- **Known transient issues:** If an alert fires on a known flaky signal (e.g., brief Supabase connection hiccup), note in the issue and close if not reproducible within 1 hour

---

## 7. Ownership Transfer Protocol

> **When the team grows beyond one person, activate this section.**

### Transfer Checklist

- [ ] New owner has access to all alert sources (Sentry, Supabase, Vercel, GitHub)
- [ ] New owner has reviewed [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md)
- [ ] New owner has reviewed this document (ON_CALL_POLICY.md)
- [ ] New owner has reviewed [ALERT_POLICY.md](ALERT_POLICY.md)
- [ ] New owner has run `RUN_QA.ps1` and `RUN_SANITY.ps1` locally to verify environment
- [ ] Alert routing updated to include new owner's notification channels
- [ ] First week is shadow/buddy period (both old and new owner respond)

### Rotation Schedule (Future)

When multiple team members share on-call:

1. Define rotation cadence (weekly recommended)
2. Use a shared calendar with on-call slots
3. Update acknowledgment targets to use the on-call person's contact
4. Implement automated handoff notifications at rotation boundaries

---

## 8. Integration Points

| Document | Relationship |
|---|---|
| [ALERT_POLICY.md](ALERT_POLICY.md) | Defines the escalation matrix and query regression detection; this doc defines who owns alerts and ack targets |
| [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md) | Defines what to do after acknowledging; this doc defines how fast to acknowledge |
| [SLO.md](SLO.md) | Provides thresholds that define SEV-2/3 triggers for API response time and error rate |
| [LOG_SCHEMA.md](LOG_SCHEMA.md) | Defines structured error codes referenced in alert payloads |
| [OBSERVABILITY.md](OBSERVABILITY.md) | Provides the underlying monitoring signals that generate alerts |
| [MONITORING.md](MONITORING.md) | Defines dashboards and health checks that surface alert conditions |

---

## 9. Review Cadence

This document should be reviewed:

- **Quarterly** — as part of governance checks (see [GOVERNANCE_BLUEPRINT.md](GOVERNANCE_BLUEPRINT.md))
- **After any SEV-1 incident** — update thresholds if the incident revealed gaps
- **When team size changes** — activate the ownership transfer protocol and rotation sections
- **When new alert sources are added** — update the alert source inventory (§2)
