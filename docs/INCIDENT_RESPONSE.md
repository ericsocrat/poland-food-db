# Incident Response Playbook

> **Last updated:** 2026-02-28
> **Owner:** Eric (sole maintainer)
> **Scope:** Poland Food Quality Database — production & staging environments
> **Complements:** [DEPLOYMENT.md](../DEPLOYMENT.md) § Emergency Checklist, § Rollback Procedures

---

## 1. Purpose

This playbook defines the incident response process for the Poland Food Quality Database.
It provides severity definitions, an escalation ladder, communication templates,
a blameless post-mortem format, and scenario-specific runbooks for common failure modes.

Even as a solo-developer project, having a documented process prevents panic-driven
decisions, ensures consistent response quality, and scales naturally when contributors join.

---

## 2. Severity Classification

| Level     | Name     | Definition                                                        | Response Time     | Resolution Target |
|-----------|----------|-------------------------------------------------------------------|-------------------|-------------------|
| **SEV-1** | Critical | Complete service outage or data corruption affecting all users    | **15 min**        | **1 hour**        |
| **SEV-2** | Major    | Partial outage or degraded experience for significant user segment | **30 min**        | **4 hours**       |
| **SEV-3** | Minor    | Non-critical functionality degraded; workaround exists            | **2 hours**       | **24 hours**      |
| **SEV-4** | Low      | Cosmetic or informational; no user impact                         | **Next bus. day** | **1 week**        |

### Examples by Severity

| SEV-1 (Critical)                         | SEV-2 (Major)                               |
|------------------------------------------|---------------------------------------------|
| Database completely unreachable           | Search broken for all users                 |
| All API endpoints returning 5xx          | Category listing empty or missing products  |
| Scoring function producing wrong values  | Auth flow failing (login/signup)            |
| Data loss or corruption detected         | Materialized views stale > 24 hours         |

| SEV-3 (Minor)                            | SEV-4 (Low)                                  |
|------------------------------------------|----------------------------------------------|
| Single product detail returning 404      | Typo in UI text                              |
| Slow queries exceeding P95 SLO           | Non-blocking CI warning                      |
| One QA suite failing (non-scoring)       | Coverage dip < 1%                            |
| EAN validation mismatch on 1 product     | Stale documentation                          |

### Severity Decision Tree

```
Is the platform completely inaccessible?
├── YES → SEV-1
└── NO → Is data being corrupted or lost?
    ├── YES → SEV-1
    └── NO → Are >50% of users affected?
        ├── YES → SEV-2
        └── NO → Is a core feature broken (search, scoring, auth)?
            ├── YES → SEV-2
            └── NO → Is there a user-facing issue with a workaround?
                ├── YES → SEV-3
                └── NO → SEV-4
```

> **Judgment call:** Incidents near severity boundaries should be escalated to the
> higher severity and downgraded after investigation if appropriate. When in doubt,
> round up.

---

## 3. Escalation Ladder

### Solo Developer Model (Current)

| Step | Action                                                          | Owner | Timeframe                          |
|------|-----------------------------------------------------------------|-------|------------------------------------|
| 1    | Alert received (Sentry / Supabase / CI / manual report)        | Eric  | T+0                                |
| 2    | Acknowledge alert, classify severity                            | Eric  | T+15 min (SEV-1/2), T+2h (SEV-3/4)|
| 3    | Open GitHub issue with `incident` label + severity label        | Eric  | With acknowledgment                |
| 4    | Apply immediate mitigation (rollback, disable feature, scale)   | Eric  | Within response time               |
| 5    | Investigate root cause                                          | Eric  | Ongoing                            |
| 6    | Deploy permanent fix                                            | Eric  | Within resolution target           |
| 7    | Write post-mortem (SEV-1/2 mandatory, SEV-3 optional)           | Eric  | Within 48h of resolution           |
| 8    | Implement preventive measures (tests, alerts, guards)           | Eric  | Within 1 week                      |

### Future Team Model

When contributors join, expand the escalation ladder with role rotation:

| Role                | Responsibility                                                |
|---------------------|---------------------------------------------------------------|
| Incident Commander  | Coordinates response, makes severity/escalation decisions     |
| Investigator        | Performs root cause analysis, implements fix                   |
| Communicator        | Posts status updates, notifies stakeholders                   |

Rotate roles per incident to distribute knowledge and prevent single points of failure.

---

## 4. Incident Workflow

```
Alert Detected
      │
      ▼
  Acknowledge
  (classify SEV)
      │
      ▼
  Open GitHub Issue
  (label: incident, sev-N)
      │
      ├── SEV-1/2 ──→ Immediate mitigation
      │                 (rollback, disable, scale)
      │                       │
      │                       ▼
      │                 Root cause analysis
      │                       │
      │                       ▼
      │                 Deploy permanent fix
      │                       │
      │                       ▼
      │                 Post-mortem (mandatory)
      │
      └── SEV-3/4 ──→ Schedule fix
                        (within resolution target)
                              │
                              ▼
                        Deploy fix
                              │
                              ▼
                        Post-mortem (optional)
```

---

## 5. Communication Templates

### 5.1 Incident Acknowledgment

Use this template when opening a GitHub issue for a new incident:

```markdown
## 🔴 Incident: [TITLE]

**Severity:** SEV-[N]
**Detected:** [YYYY-MM-DD HH:MM UTC]
**Status:** Investigating
**Impact:** [Brief description of user impact]

### Timeline
- **[HH:MM UTC]** — Alert triggered by [source: Sentry / Supabase / CI / manual]
- **[HH:MM UTC]** — Acknowledged, classified as SEV-[N]
- **[HH:MM UTC]** — Investigating...

### Current Mitigation
[What is being done right now to reduce user impact]

### Next Update
Expected at [TIME UTC] or when status changes.
```

### 5.2 Status Update

Post as a comment on the incident issue for ongoing incidents:

```markdown
## 🟡 Update: [TITLE]

**Status:** [Investigating / Mitigating / Monitoring]
**Updated:** [HH:MM UTC]

### Progress
- [What has been discovered or done since last update]

### Next Steps
- [What will be done next]

### Next Update
Expected at [TIME UTC] or when status changes.
```

### 5.3 Resolution Notice

Post as a comment when the incident is resolved:

```markdown
## ✅ Resolved: [TITLE]

**Severity:** SEV-[N]
**Duration:** [X hours Y minutes]
**Root Cause:** [One sentence summary]
**Fix:** [PR link or deployment reference]

All services restored to normal operation.
Post-mortem will be published within 48 hours.
```

---

## 6. Post-Mortem Template

Store post-mortems in `docs/post-mortems/YYYY-MM-DD_title.md`. Create the folder
when the first post-mortem is written.

**Required for:** SEV-1, SEV-2
**Optional for:** SEV-3
**Not needed for:** SEV-4

```markdown
# Post-Mortem: [Incident Title]

**Date:** YYYY-MM-DD
**Severity:** SEV-[N]
**Duration:** [Start time – End time, total hours/minutes]
**Author:** [Name]
**Status:** [Draft / Final]

## Summary
[2-3 sentence summary of what happened and its impact]

## Impact
- **Users affected:** [count or percentage, or "all" / "none"]
- **Data integrity:** [any data loss or corruption? recovery status]
- **SLO impact:** [which SLOs breached, by how much — ref docs/SLO_REGISTRY.md if exists]
- **Duration of degradation:** [time from detection to resolution]

## Timeline (UTC)
| Time  | Event                          |
|-------|--------------------------------|
| HH:MM | Alert triggered by [source]   |
| HH:MM | Acknowledged, classified SEV-N |
| HH:MM | Investigation started          |
| HH:MM | Root cause identified          |
| HH:MM | Mitigation applied             |
| HH:MM | Full resolution confirmed      |

## Root Cause
[Detailed technical explanation — focus on systems, not individuals.
This section should answer: "What broke?" and "Why did it break?"]

## What Went Well
- [Detection was fast because...]
- [Rollback procedure worked as documented because...]

## What Went Wrong
- [Alert was delayed because...]
- [Recovery took longer than expected because...]

## Action Items
| Action                       | Owner | Deadline   | Issue |
|------------------------------|-------|------------|-------|
| [Preventive measure]         | Eric  | YYYY-MM-DD | #NNN  |
| [Detection improvement]      | Eric  | YYYY-MM-DD | #NNN  |
| [Process/doc improvement]    | Eric  | YYYY-MM-DD | #NNN  |

## Lessons Learned
[Key takeaways for future incident response]
```

> **Blameless culture:** Post-mortems focus on systems and processes, never on
> individuals. Ask "what failed?" not "who failed?"

---

## 7. Scenario-Specific Runbooks

### Runbook 1: Database Unavailable (SEV-1)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Check Supabase dashboard status                   | Supabase Dashboard → Project → Database                                  |
| 2    | Verify DB connection from local                    | `echo "SELECT 1;" \| docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres` |
| 3    | Check if a migration caused the issue              | `supabase migration list` — compare to last known good state             |
| 4    | If migration broke it: identify the bad migration  | Check `supabase/migrations/` — last modified timestamp                   |
| 5    | Restore from backup if needed                      | See DEPLOYMENT.md § Rollback Procedures (Scenarios 1-5)                  |
| 6    | If infrastructure issue: check Supabase status     | https://status.supabase.com                                              |
| 7    | Run sanity checks after recovery                   | `.\RUN_SANITY.ps1 -Env local` (or `-Env production`)                    |
| 8    | Open incident issue with SEV-1 template            | Use §5.1 acknowledgment template                                        |

### Runbook 2: Scoring Regression (SEV-2)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Run QA scoring suite                               | `.\RUN_QA.ps1` — check `QA__scoring_formula_tests.sql` (27 checks)      |
| 2    | Identify which anchor products drifted             | Compare against §8.19 anchor values in copilot-instructions.md           |
| 3    | Check recent scoring-related migrations            | Review `compute_unhealthiness_v32()` and `score_category()` changes      |
| 4    | Rollback scoring function if needed                | Re-apply previous version from migration history                         |
| 5    | Re-score affected categories                       | `CALL score_category('CategoryName');` for each affected category        |
| 6    | Verify fix via QA                                  | All 27 scoring checks + all anchor products within ±2 tolerance          |

### Runbook 3: Data Corruption / Integrity Violation (SEV-1)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Run full QA suite                                  | `.\RUN_QA.ps1` — identify failing checks                                |
| 2    | Run negative validation tests                      | `.\RUN_NEGATIVE_TESTS.ps1` — verify constraints still enforced           |
| 3    | Assess blast radius                                | Which tables, how many rows, which categories affected                   |
| 4    | Check recent pipeline runs                         | `db/pipelines/*/` — last modified timestamps + git log                   |
| 5    | If pipeline-caused: re-run from clean state        | `.\RUN_LOCAL.ps1 -Category [affected]`                                   |
| 6    | If migration-caused: restore from backup           | See DEPLOYMENT.md § Rollback Procedures                                  |
| 7    | Verify referential integrity                       | `QA__referential_integrity.sql` — all 18 checks green                    |
| 8    | Refresh materialized views                         | `SELECT refresh_all_materialized_views();`                               |

### Runbook 4: Authentication / RLS Failure (SEV-2)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Check Supabase Auth dashboard                      | Dashboard → Authentication → verify service is healthy                   |
| 2    | Run security QA suite                              | `QA__security_posture.sql` — all 22 checks                              |
| 3    | Run auth QA suite                                  | `QA__auth_onboarding.sql` — all 8 checks                                |
| 4    | Check RLS policies                                 | `SELECT * FROM pg_policies WHERE tablename IN ('user_preferences', 'user_health_profiles', 'scan_history', ...);` |
| 5    | Run auth E2E tests                                 | `cd frontend && npx playwright test e2e/authenticated.spec.ts`           |
| 6    | If RLS broken: check recent migrations             | Look for `ALTER POLICY`, `DROP POLICY`, or `ENABLE/DISABLE RLS`          |
| 7    | If auth service down: escalate to Supabase support | Dashboard → Support ticket + check https://status.supabase.com           |

### Runbook 5: Performance Degradation (SEV-2/3)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Check MV staleness                                 | `SELECT mv_staleness_check();` — refresh if stale                        |
| 2    | Refresh materialized views if stale                | `SELECT refresh_all_materialized_views();`                               |
| 3    | Check scale guardrails                             | `QA__scale_guardrails.sql` — all 15 checks                              |
| 4    | Run EXPLAIN ANALYZE on slow queries                | Identify missing indexes or sequential scans                             |
| 5    | Check for N+1 queries or row bloat                 | `SELECT relname, n_dead_tup, seq_scan FROM pg_stat_user_tables ORDER BY n_dead_tup DESC;` |
| 6    | If index needed: create via migration              | New append-only migration, never modify existing                         |

### Runbook 6: CI/CD Pipeline Failure (SEV-3)

| Step | Action                                            | Command / Reference                                                      |
|------|---------------------------------------------------|--------------------------------------------------------------------------|
| 1    | Check GitHub Actions logs                          | `.github/workflows/` — identify the failing workflow and job             |
| 2    | If `qa.yml` fails: reproduce locally               | `.\RUN_QA.ps1` — run full QA suite                                      |
| 3    | If `pr-gate.yml` typecheck fails                   | `cd frontend && npx tsc --noEmit`                                        |
| 4    | If `pr-gate.yml` unit tests fail                   | `cd frontend && npx vitest run`                                          |
| 5    | If `pr-gate.yml` E2E fails                         | `cd frontend && npx playwright test --project=smoke`                     |
| 6    | If dependency issue                                | `cd frontend && npm ci` — check for lockfile drift                       |
| 7    | Fix and verify locally before pushing              | Run the full impacted suite per §8.7 of copilot-instructions.md          |

---

## 8. SLO Breach Response

When a service-level objective is breached, follow the corresponding procedure:

| Breach Type                       | Severity | Action                                                                                    |
|-----------------------------------|----------|-------------------------------------------------------------------------------------------|
| **Latency SLO** (P95/P99)        | SEV-2/3  | Check MV freshness → EXPLAIN ANALYZE → index review → scale guardrails QA                |
| **Availability SLO** (< 99.5%)   | SEV-1/2  | Follow Runbook 1 (DB down) or Runbook 4 (auth) depending on failure mode                 |
| **Error budget exhausted** (crit.)| SEV-2    | Feature freeze until SLO restored; focus only on reliability fixes                       |
| **Error budget exhausted** (std.) | SEV-3    | Prioritize reliability over features; no new deployments until budget recovers            |
| **Data quality SLO** (QA fails)  | SEV-2    | Follow Runbook 3 (data corruption); block pipeline runs until resolved                   |

> **Error budget policy:** When error budget for a critical SLO is exhausted,
> all non-reliability work stops until the SLO is restored. This prevents
> feature velocity from eroding platform reliability.

---

## 9. GitHub Labels for Incidents

When opening an incident issue, apply these labels:

| Label              | When to use                              |
|--------------------|------------------------------------------|
| `incident`         | All incidents (mandatory)                |
| `sev-1`            | Critical incidents                       |
| `sev-2`            | Major incidents                          |
| `sev-3`            | Minor incidents                          |
| `sev-4`            | Low-priority incidents                   |
| `post-mortem`      | Issue tracking a post-mortem document    |

> **Note:** Create these labels when the first real incident occurs. No need
> to pre-create labels for a process that hasn't been used yet.

---

## 10. Integration Points

| System                | Role in Incident Response                                               |
|-----------------------|-------------------------------------------------------------------------|
| **Sentry**            | Error tracking — triggers SEV-2/3 alerts for frontend/API errors        |
| **Supabase Dashboard**| Database health monitoring — triggers SEV-1 for connection failures      |
| **GitHub Actions**    | CI/CD health — triggers SEV-3 for pipeline failures                     |
| **Vercel**            | Frontend deployment status — triggers SEV-2 for build/deploy failures   |
| **`.\RUN_QA.ps1`**    | Data integrity verification — 429 checks across 30 suites              |
| **`.\RUN_SANITY.ps1`**| Quick health check — 17 row-count and schema assertions                 |

---

## 11. Quarterly Review

Review this playbook quarterly to ensure:

- [ ] Runbook commands still reference correct file names and paths
- [ ] QA check counts match actual suite totals
- [ ] Severity examples remain relevant to current features
- [ ] SLO thresholds are still accurate
- [ ] Communication templates match current team structure
- [ ] Post-mortem action items from past incidents have been completed

---

## Cross-References

- [DEPLOYMENT.md](../DEPLOYMENT.md) — Emergency Checklist, Rollback Procedures (5 scenarios), Break-Glass DB access
- [docs/MONITORING.md](MONITORING.md) — Runtime monitoring configuration
- [docs/OBSERVABILITY.md](OBSERVABILITY.md) — Observability strategy
- [copilot-instructions.md](../copilot-instructions.md) § 8.19 — Anchor product regression values
- [copilot-instructions.md](../copilot-instructions.md) § 8.18 — QA suite reference table
