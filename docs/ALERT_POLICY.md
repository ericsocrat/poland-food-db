# Alert Escalation & Query Regression Detection

> **Last updated:** 2026-03-04
> **Status:** Active
> **Owner issue:** [#211](https://github.com/ericsocrat/poland-food-db/issues/211)
> **Dependencies:** OBSERVABILITY.md (logging), LOG_SCHEMA.md (error codes), PERFORMANCE_GUARDRAILS.md (budgets)

---

## 1. Alert Escalation Policy

### Severity Tiers

| Tier              | Condition                               | Duration         | Channel                  | Response Time | Escalation                      |
| ----------------- | --------------------------------------- | ---------------- | ------------------------ | ------------- | ------------------------------- |
| **P0 — Critical** | Any CRITICAL error code (LOG_SCHEMA.md) | 1 occurrence     | Page on-call immediately | 5 min         | Automatic incident              |
| **P0 — Critical** | Migration lock > 30s                    | 1 occurrence     | Page on-call             | 5 min         | Prepare rollback                |
| **P1 — High**     | API P95 > 2000ms                        | 1 min sustained  | Page on-call             | 5 min         | Treat as incident               |
| **P1 — High**     | Database connections > 80% pool         | 5 min sustained  | Slack alert              | 15 min        | Investigate connection leaks    |
| **P2 — Medium**   | API P95 > 1000ms                        | 3 min sustained  | Slack alert              | 30 min        | → Page if no ack in 30 min      |
| **P2 — Medium**   | Search zero-result rate > 20%           | 1 hour sustained | Slack alert              | 4 hours       | Investigate query patterns      |
| **P2 — Medium**   | Provenance conflicts > 50 unresolved    | Daily check      | Slack alert              | 24 hours      | Assign to data team             |
| **P3 — Low**      | API P95 > 500ms                         | 5 min sustained  | Dashboard amber          | 1 hour        | → Slack if still amber after 1h |
| **P3 — Low**      | Scoring version drift > 5% products     | Daily check      | Dashboard amber          | 24 hours      | Schedule re-score batch         |
| **P3 — Low**      | Disk usage > 80%                        | Daily check      | Slack alert              | 24 hours      | Plan cleanup or expansion       |

### Escalation Chain

```
Dashboard amber (P3)
  ↓ (if unresolved after response time)
Slack #alerts channel (P2)
  ↓ (if unresolved after response time)
Page on-call engineer (P1/P0)
  ↓ (if unresolved in 30 min)
Incident declared → INCIDENT_RESPONSE.md playbook
```

### On-Call Rules

- **Rotation:** Weekly, starting Monday 09:00 CET
- **Response:** Acknowledge within response time or auto-escalate
- **Handoff:** Document open alerts in handoff notes at rotation boundary
- **Override:** Any team member can self-assign an alert regardless of rotation

---

## 2. Slow Query Telemetry

Slow query monitoring uses `report_slow_queries()` from migration `20260222050000_query_performance_guardrails.sql`.

### Thresholds

| Category | Mean Execution Time | Action                                |
| -------- | ------------------- | ------------------------------------- |
| OK       | < 100ms             | No action                             |
| Warning  | 100–500ms           | Log, review weekly                    |
| Slow     | 500ms–1s            | Slack alert, investigate within 24h   |
| Critical | > 1s                | Page on-call, investigate immediately |

### Existing Infrastructure

- `report_slow_queries(p_threshold_ms)` — returns queries above threshold with category classification
- `check_plan_quality(p_query_text)` — EXPLAIN ANALYZE with plan node flagging
- Both restricted to `service_role` (SECURITY DEFINER)

---

## 3. Query Regression Detection

### Architecture

```
pg_stat_statements
       │
       ▼
snapshot_query_performance()  ←── weekly cron / manual call
       │
       ▼
query_performance_snapshots   (historical data)
       │
       ▼
v_query_regressions           (compare current vs previous week)
```

### Detection Rules

| Regression Level | Condition                          | Alert           |
| ---------------- | ---------------------------------- | --------------- |
| OK               | Current mean ≤ previous mean × 1.3 | None            |
| WARNING          | Current mean > previous mean × 1.5 | Dashboard amber |
| CRITICAL         | Current mean > previous mean × 2.0 | Slack alert     |

### Retention

- Keep weekly snapshots for 12 weeks (84 days)
- After 12 weeks, aggregate to monthly summaries or delete
- Estimated storage: ~50 rows/week × 12 weeks = ~600 rows max

---

## 4. Index Drift Monitoring

### Detection Views

| View                     | Purpose                                | Alert Condition                   |
| ------------------------ | -------------------------------------- | --------------------------------- |
| `v_unused_indexes`       | Indexes with zero or very few scans    | UNUSED index > 10MB               |
| `v_missing_indexes`      | Tables with excessive sequential scans | NEEDS_INDEX status on large table |
| `v_index_bloat_estimate` | Index size vs table size ratio         | Index > 2× table size             |

### Review Cadence

- **Weekly:** Review `v_unused_indexes` for zero-scan indexes
- **Weekly:** Review `v_missing_indexes` for sequential scan patterns
- **Monthly:** Review `v_index_bloat_estimate` for fragmentation
- **After migrations:** Run all three views to verify index health

### Action Matrix

| Finding                        | Action                                          | Urgency |
| ------------------------------ | ----------------------------------------------- | ------- |
| Unused index (0 scans, > 10MB) | Consider DROP INDEX after 4 weeks of inactivity | Low     |
| Rarely used index (< 10 scans) | Monitor for 2 more weeks, then decide           | Low     |
| Missing index (high seq scans) | Create index, EXPLAIN ANALYZE to verify         | Medium  |
| Bloated index (> 2× table)     | REINDEX or DROP + CREATE                        | Low     |

---

## 5. Database Schema

### Tables

- `query_performance_snapshots` — Weekly snapshots of query performance metrics

### Functions

- `snapshot_query_performance()` — Captures current pg_stat_statements data into snapshots table (SECURITY DEFINER, service_role only)

### Views

- `v_query_regressions` — Compares current vs previous snapshot to detect performance regressions
- `v_unused_indexes` — Identifies indexes with zero or very few scans
- `v_missing_indexes` — Identifies tables with excessive sequential scans relative to index scans
- `v_index_bloat_estimate` — Estimates index bloat by comparing index size to table size

---

## 6. Integration Points

| System                    | Integration                                                            |
| ------------------------- | ---------------------------------------------------------------------- |
| LOG_SCHEMA.md             | Error codes: `SEARCH_QUERY_002` (timeout), `MIGRATION_LOCK_001` (lock) |
| OBSERVABILITY.md          | Structured log format for alert events                                 |
| PERFORMANCE_GUARDRAILS.md | Query budget definitions, statement timeouts                           |
| INCIDENT_RESPONSE.md      | Escalation leads to incident declaration                               |
| Admin Dashboard (#206)    | Views feed dashboard cards (future)                                    |
