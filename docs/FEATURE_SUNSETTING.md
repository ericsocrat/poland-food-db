# Feature Sunsetting & Cleanup Policy

> **Last updated:** 2026-02-28
> **Status:** Active policy — quarterly reviews starting Q2 2026
> **Reference:** Issue [#237](https://github.com/ericsocrat/poland-food-db/issues/237)
> **Related:** [API Versioning](API_VERSIONING.md) (deprecation windows), [Domain Boundaries](DOMAIN_BOUNDARIES.md) (ownership), [Changelog](../CHANGELOG.md) (sunset entries)

---

## Table of Contents

1. [Feature Retirement Criteria](#1-feature-retirement-criteria)
2. [Deprecation-to-Removal Lifecycle](#2-deprecation-to-removal-lifecycle)
3. [Database Object Cleanup Procedure](#3-database-object-cleanup-procedure)
4. [Tech Debt Classification](#4-tech-debt-classification)
5. [Feature Flag Expiration Policy](#5-feature-flag-expiration-policy)
6. [Quarterly Hygiene Review Checklist](#6-quarterly-hygiene-review-checklist)
7. [Known Current Candidates](#7-known-current-candidates)

---

## 1. Feature Retirement Criteria

A feature, component, or database object is a **candidate for sunsetting** when ANY of these criteria are met.

### 1.1 Quantitative Triggers

| Criterion | Threshold | Detection Method |
|---|---|---|
| **Zero usage** for N weeks | 4 weeks (feature flag), 8 weeks (API endpoint), 12 weeks (DB function) | Analytics / query logs / Sentry traces |
| **Error rate** exceeds normal operation | > 5% error rate sustained for 2+ weeks | Sentry monitoring |
| **Maintenance cost** exceeds value | > 2 bug fixes in 30 days for same feature | GitHub issue count |
| **Replaced by successor** | New version has 100% feature parity | API versioning policy (see [API_VERSIONING.md](API_VERSIONING.md)) |
| **Feature flag** past expiration | Flag created > 90 days ago without extension | Feature flag registry |
| **Deprecated product count** | > 50 deprecated products without archival | `SELECT COUNT(*) FROM products WHERE is_deprecated = true` |

### 1.2 Qualitative Triggers

| Indicator | Description |
|---|---|
| **Architectural misfit** | Component uses patterns abandoned elsewhere in the codebase |
| **Security concern** | Feature has unresolvable security issues |
| **Data quality burden** | Feature requires manual data intervention to function |
| **User confusion** | Feature causes more support questions than it delivers value |
| **Compliance blocker** | Feature conflicts with GDPR/RODO requirements (see [PRIVACY_CHECKLIST.md](PRIVACY_CHECKLIST.md)) |

---

## 2. Deprecation-to-Removal Lifecycle

Every feature removal follows four sequential phases. No phase may be skipped.

### Phase 1: CANDIDATE (Identified)

- Document in tech debt inventory (see §4)
- Assess impact: dependencies, active users, data at risk
- Decision gate: **Sunset? Refactor? Keep?**
- Owner: domain owner per [DOMAIN_BOUNDARIES.md](DOMAIN_BOUNDARIES.md)

### Phase 2: DEPRECATED (Announced)

- Mark with deprecation notice:
  - Code: `@deprecated` JSDoc / `-- DEPRECATED:` SQL comment
  - API: return `X-Deprecated: true` header or `deprecated` field in response
  - Docs: strikethrough in API_CONTRACTS.md, note in CHANGELOG.md
- Set sunset date per [API_VERSIONING.md](API_VERSIONING.md) deprecation windows:
  - Critical public APIs: 4 weeks
  - Secondary APIs: 2 weeks
  - Internal/admin functions: 1 week
  - Service-role-only: immediate
- Create migration plan for dependents
- Notify consumers via CHANGELOG entry

### Phase 3: DISABLED (Sunset Date Reached)

- Feature flag OFF (if applicable)
- API endpoint returns `410 Gone` or redirect to successor
- Frontend route removed or redirected
- **Duration:** 2 weeks of monitoring for breakage before proceeding to Phase 4

### Phase 4: REMOVED (Cleanup)

- Code deleted (frontend components, hooks, routes, stores)
- Database objects dropped via new migration (`DROP ... IF EXISTS`)
- Tests removed or updated
- Documentation updated (copilot-instructions.md, API_CONTRACTS.md, etc.)
- CHANGELOG entry added
- Tech debt inventory updated

### Lifecycle Diagram

```
  CANDIDATE ──▶ DEPRECATED ──▶ DISABLED ──▶ REMOVED
  (assess)      (announce)      (monitor)    (cleanup)
     │               │              │            │
  Decision        Set sunset    2-week        Drop code,
  gate            date +        monitoring    schema,
                  notify                      docs, tests
```

---

## 3. Database Object Cleanup Procedure

When removing any database object (function, view, table, index, trigger):

### 3.1 Pre-Removal Dependency Check

```sql
-- Step 1: Check view/table dependencies
SELECT
  dependent_ns.nspname AS dependent_schema,
  dependent_view.relname AS dependent_view
FROM pg_depend
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
JOIN pg_class AS dependent_view ON pg_rewrite.ev_class = dependent_view.oid
JOIN pg_class AS source_table ON pg_depend.refobjid = source_table.oid
JOIN pg_namespace AS dependent_ns ON dependent_view.relnamespace = dependent_ns.oid
WHERE source_table.relname = 'OBJECT_NAME';

-- Step 2: Check for function references in other functions
SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_definition LIKE '%OBJECT_NAME%';

-- Step 3: Check index usage statistics
SELECT indexrelname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
WHERE indexrelname = 'INDEX_NAME';
```

### 3.2 Drop Migration Template

```sql
-- File: supabase/migrations/YYYYMMDDHHMMSS_drop_objectname.sql
-- Purpose: Remove deprecated [object] — sunset date reached YYYY-MM-DD
-- Rollback: Re-create via original migration [filename]
-- Phase 4 of sunsetting lifecycle (see docs/FEATURE_SUNSETTING.md)

-- Verify no remaining dependencies (queries above returned 0 rows)

DROP FUNCTION IF EXISTS public.function_name(param_types);
DROP VIEW IF EXISTS public.view_name;
DROP INDEX IF EXISTS public.index_name;
-- DROP TABLE requires careful CASCADE analysis — verify no FK references first
```

### 3.3 Rules

- **Always** use `IF EXISTS` guards (idempotent)
- **Never** modify an existing migration file — create a new one
- **Always** drop functions with full parameter signature
- **Always** verify with dependency-check SQL before writing the migration
- **Test** the migration against local Supabase before committing

---

## 4. Tech Debt Classification

### 4.1 Tiers

| Tier | Description | Action | Timeline |
|---|---|---|---|
| **Tier 1: Critical** | Security risk, data corruption potential, blocks features | Fix immediately | Current sprint |
| **Tier 2: High** | Performance impact, maintenance burden, code complexity | Schedule in next 2 sprints | 1 month |
| **Tier 3: Medium** | Code smell, style inconsistency, minor cleanup | Add to backlog; address opportunistically | Quarterly |
| **Tier 4: Low** | Nice-to-have refactoring, documentation gaps | Defer; address if touching that area | As encountered |

### 4.2 Inventory Format

Track tech debt items in the quarterly hygiene review (§6) using this format:

| Object | Type | Tier | Created | Retirement Date | Owner | Notes |
|---|---|---|---|---|---|---|
| `column_metadata` table | Schema | — | 2026-02-07 | 2026-02-11 | Core | ✅ Already dropped (migration 20260211000500) |
| 38 deprecated products | Data | 3 | 2026-02-10 | TBD | Core | Review quarterly; archive or purge when > 50 |
| Unused indexes (if any) | Schema | 3 | TBD | TBD | Infrastructure | Run `pg_stat_user_indexes` audit quarterly |

---

## 5. Feature Flag Expiration Policy

Complements the Feature Flag Architecture when implemented. Every flag must have a type and expiration policy.

### 5.1 Flag Types & Expirations

| Flag Type | Default Expiration | Extension Policy |
|---|---|---|
| **Release flag** (gradual rollout) | 30 days after 100% rollout | Extend 1x for 30 days with written justification |
| **Experiment flag** (A/B test) | Duration of experiment + 14 days | Must be removed after experiment concludes |
| **Ops flag** (kill switch) | No expiration | Review quarterly; document active kill switches |
| **Permission flag** (feature gate) | No expiration | Review quarterly; migrate to role-based access when stable |

### 5.2 Flag Registry Entry Format

```json
{
  "flag_name": "enable_health_warnings",
  "type": "release",
  "created_at": "2026-02-20",
  "expires_at": "2026-03-22",
  "owner": "Frontend",
  "description": "Gradual rollout of health warning cards on product detail",
  "cleanup_issue": "#NNN"
}
```

### 5.3 Flag Lifecycle

```
Created → Active → 100% Rollout → Grace Period → Cleanup
                                      │
                              Remove flag, make
                              code permanent
```

- Flags at 100% ON for > 30 days → should become permanent code (remove flag, keep feature)
- Flags at 100% OFF for > 30 days → should be removed along with the feature code
- Expired flags without extension → create cleanup issue immediately

---

## 6. Quarterly Hygiene Review Checklist

Copy this template for each quarterly review. Complete all sections and file the results.

```markdown
## Feature Hygiene Review — Q[N] YYYY

**Reviewer:** [Name]
**Date:** YYYY-MM-DD
**Previous review:** YYYY-MM-DD (or "Initial")

### Database Object Audit

- [ ] List all functions:
      `SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' ORDER BY routine_name;`
- [ ] Identify functions not called by any API, view, or other function
- [ ] List all views:
      `SELECT viewname FROM pg_views WHERE schemaname = 'public' ORDER BY viewname;`
- [ ] Verify all views are used by at least one API function or frontend query
- [ ] List all materialized views:
      `SELECT matviewname FROM pg_matviews WHERE schemaname = 'public' ORDER BY matviewname;`
- [ ] Verify MVs are being refreshed (`mv_staleness_check()`)
- [ ] Count deprecated products:
      `SELECT COUNT(*) FROM products WHERE is_deprecated = true;`
- [ ] Review unused indexes:
      `SELECT indexrelname, idx_scan FROM pg_stat_user_indexes WHERE idx_scan = 0 ORDER BY indexrelname;`

### Frontend Dead Code Audit

- [ ] Check for unused components (no imports found via grep/IDE)
- [ ] Check for unused hooks (no imports found)
- [ ] Check for unused routes (pages with zero traffic in analytics)
- [ ] Check for commented-out code blocks (> 10 lines)
- [ ] Review SonarCloud "dead code" findings

### Feature Flag Audit

- [ ] List all active feature flags
- [ ] Identify flags past expiration date
- [ ] Identify flags at 100% ON for > 30 days (should be permanent code)
- [ ] Identify flags at 100% OFF for > 30 days (candidate for removal)

### Pipeline & Migration Audit

- [ ] Check for pipeline folders with 0 active products
- [ ] Review migration history for DROP-ready deprecated objects
- [ ] Verify `check_pipeline_structure.py` passes
- [ ] Verify `check_enrichment_identity.py` passes

### Tech Debt Inventory Update

| Object | Type | Tier | Created | Retirement Date | Notes |
|---|---|---|---|---|---|
| | | | | | |

### Actions

| Action | Owner | Deadline | Issue # |
|---|---|---|---|
| | | | |

### Sign-Off

- [ ] All checks completed
- [ ] New tech debt items documented
- [ ] Cleanup issues created for items past retirement date
- [ ] Next review scheduled: YYYY-MM-DD
```

---

## 7. Known Current Candidates

Initial audit as of 2026-02-28:

| Candidate | Type | Status | Tier | Recommendation |
|---|---|---|---|---|
| 38 deprecated products | Data | `is_deprecated = true` | 3 | Archive to separate table or purge after confirming no references. Create issue if count exceeds 50. |
| `column_metadata` table | Schema | Dropped in migration 20260211000500 | — | ✅ Already cleaned up |
| Unused indexes (if any) | Schema | Requires `pg_stat_user_indexes` audit | 3 | Run quarterly; drop indexes with 0 scans after confirming no planned usage |
| Stale MV data | Schema | Requires `mv_staleness_check()` | 3 | Verify refresh cadence is adequate; add monitoring alert |
| Early scoring functions (pre-v3.2) | Functions | May be orphaned | 3 | Verify no references via dependency SQL; drop if unused |

**Next scheduled review:** Q2 2026 (first quarterly hygiene review)

---

## References

- [API_VERSIONING.md](API_VERSIONING.md) — Deprecation windows and sunset timelines for API functions
- [DOMAIN_BOUNDARIES.md](DOMAIN_BOUNDARIES.md) — Domain ownership for retirement decision authority
- [PRIVACY_CHECKLIST.md](PRIVACY_CHECKLIST.md) — Compliance triggers for feature sunsetting
- [CHANGELOG.md](../CHANGELOG.md) — Sunset entries follow Conventional Commits convention
- Issue [#191](https://github.com/ericsocrat/poland-food-db/issues/191) — Feature Flag Architecture (complementary)
- Issue [#234](https://github.com/ericsocrat/poland-food-db/issues/234) — API Versioning Policy (deprecation alignment)
