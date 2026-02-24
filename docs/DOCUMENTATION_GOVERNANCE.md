# Documentation Governance

> **Last updated:** 2026-03-01
> **Status:** Active
> **Owner issue:** [#201](https://github.com/ericsocrat/poland-food-db/issues/201)

---

## 1. Purpose

This document defines the ongoing governance that prevents documentation entropy.
It establishes ownership, update triggers, versioning policy, deprecation process,
and drift prevention cadence. The canonical list of all documents lives in
[INDEX.md](INDEX.md) — this document governs *how* that index is maintained.

---

## 2. Ownership Model

Every document has an **owner** — identified by the GitHub issue that created or
most recently restructured it. The owner issue is responsible for the document's
accuracy. When an issue is closed, ownership transfers to the domain (e.g.,
"scoring domain" or "API domain").

### Domain Ownership Map

| Domain | Documents | Primary Owner |
|---|---|---|
| **Scoring** | SCORING_METHODOLOGY.md, SCORING_ENGINE.md | #189 (Scoring Engine) |
| **API** | API_CONTRACTS.md, API_VERSIONING.md, FRONTEND_API_MAP.md, CONTRACT_TESTING.md | #197 (API Registry) |
| **Search** | SEARCH_ARCHITECTURE.md | #192 (Search Architecture) |
| **Data & Provenance** | DATA_SOURCES.md, DATA_PROVENANCE.md, DATA_INTEGRITY_AUDITS.md, EAN_VALIDATION_STATUS.md, PRODUCTION_DATA.md | #193 (Data Provenance) |
| **Security** | SECURITY.md, SECURITY_AUDIT.md, ACCESS_AUDIT.md, PRIVACY_CHECKLIST.md, RATE_LIMITING.md | #235 (Access Audit) |
| **Observability** | MONITORING.md, OBSERVABILITY.md, SLO.md, METRICS.md, INCIDENT_RESPONSE.md, DISASTER_DRILL_REPORT.md | #231 (Incident Response) |
| **Architecture** | GOVERNANCE_BLUEPRINT.md, DOMAIN_BOUNDARIES.md, FEATURE_FLAGS.md, CI_ARCHITECTURE_PROPOSAL.md, DRIFT_DETECTION.md | #195 (Governance Blueprint) |
| **Frontend** | UX_UI_DESIGN.md, UX_IMPACT_METRICS.md, DESIGN_SYSTEM.md | Frontend domain |
| **DevOps** | ENVIRONMENT_STRATEGY.md, STAGING_SETUP.md, SONAR.md | DevOps domain |
| **Process** | RESEARCH_WORKFLOW.md, VIEWING_AND_TESTING.md, BACKFILL_STANDARD.md, LABELS.md, COUNTRY_EXPANSION_GUIDE.md | Process domain |
| **Governance** | FEATURE_SUNSETTING.md, PERFORMANCE_GUARDRAILS.md, INDEX.md, this file | #201 (Doc Governance) |

---

## 3. Update Triggers

When modifying code in a domain, the corresponding documents **must** be checked
and updated if affected. This is enforced via the PR checklist.

| Code Change | Documents to Check | Priority |
|---|---|---|
| Scoring formula weights or ceilings | SCORING_METHODOLOGY.md | Mandatory |
| New scoring version or factor | SCORING_ENGINE.md, SCORING_METHODOLOGY.md | Mandatory |
| New/modified `api_*` function | API_CONTRACTS.md, FRONTEND_API_MAP.md, api-registry.yaml | Mandatory |
| API parameter or response shape change | API_CONTRACTS.md | Mandatory |
| New migration | copilot-instructions.md (schema section) | Mandatory |
| New country activated | COUNTRY_EXPANSION_GUIDE.md | Mandatory |
| New user-facing table with PII | PRIVACY_CHECKLIST.md, ACCESS_AUDIT.md | Mandatory |
| RLS policy change | ACCESS_AUDIT.md, SECURITY_AUDIT.md | Mandatory |
| Environment configuration | ENVIRONMENT_STRATEGY.md | Recommended |
| CI workflow changes | CI_ARCHITECTURE_PROPOSAL.md | Recommended |
| New feature flag | FEATURE_FLAGS.md | Mandatory |
| Search ranking or synonym change | SEARCH_ARCHITECTURE.md | Mandatory |
| New QA suite or check count change | copilot-instructions.md (QA section) | Mandatory |
| Drift check addition | DRIFT_DETECTION.md | Mandatory |

---

## 4. Versioning Policy

### 4.1 Frontmatter Requirements

Every active document in `docs/` must include:

```markdown
# Document Title

> **Last updated:** YYYY-MM-DD
> **Status:** Active | Deprecated | Archived
> **Owner issue:** #NNN (or domain name)
```

### 4.2 Update Rules

1. **Every document edit** must update the `Last updated` date.
2. **Substantive changes** (new sections, policy changes) must also update the
   corresponding INDEX.md entry's `Last Updated` column.
3. **Typo/formatting fixes** update the date but do not require INDEX.md update.
4. **New documents** must be added to INDEX.md in the appropriate domain section
   and to `copilot-instructions.md` project layout.

### 4.3 Per-Document Changelog (Optional)

For complex documents (SCORING_ENGINE.md, API_CONTRACTS.md), maintain a changelog
section at the bottom:

```markdown
## Changelog

| Date | Change | Issue |
|---|---|---|
| 2026-03-01 | Added formula registry section | #198 |
| 2026-02-24 | Initial creation | #189 |
```

This is **optional** for simple policy documents but **recommended** for
technical reference documents that evolve frequently.

---

## 5. Deprecation & Archival Process

### 5.1 Deprecation (Sprint 1)

1. Add deprecation notice at the top of the document:
   ```markdown
   > **Status:** Deprecated — superseded by [NEW_DOC.md](NEW_DOC.md)
   > **Removal date:** YYYY-MM-DD (end of next sprint)
   ```
2. Update INDEX.md entry status to `Deprecated`.
3. Add CHANGELOG.md entry: `docs: deprecate OLD_DOC.md in favor of NEW_DOC.md`

### 5.2 Archival (Sprint 2)

1. Move file to `docs/archive/` (create directory if needed).
2. Move INDEX.md entry from active section to "Removed Documents" table.
3. Update all cross-references in other docs to point to the replacement.
4. Update `copilot-instructions.md` project layout.

### 5.3 Permanent Removal

Files in `docs/archive/` are kept for historical reference. They are not
actively maintained. Remove only if they cause confusion or contain outdated
security-sensitive information.

---

## 6. PR Documentation Checklist

Every PR must include the documentation checklist defined in
`.github/PULL_REQUEST_TEMPLATE.md`. The checklist is:

- [ ] No new `api_*` function without `API_CONTRACTS.md` update
- [ ] No scoring change without `SCORING_METHODOLOGY.md` update
- [ ] No new migration without `copilot-instructions.md` schema check
- [ ] `Last updated` refreshed on any modified doc
- [ ] New `.md` files added to `docs/INDEX.md`
- [ ] CHANGELOG.md updated under `[Unreleased]`

This checklist is advisory (self-attested by PR author), not CI-enforced.
The documentation freshness script (`scripts/check_doc_drift.py`) provides
the automated enforcement layer.

---

## 7. Drift Prevention Cadence

| Frequency | Action | Tool | Owner |
|---|---|---|---|
| **Every PR** | Complete documentation checklist | PR template | PR author |
| **Every QA run** | SQL drift checks pass | `QA__governance_drift.sql` | CI |
| **Weekly** | Documentation freshness check | `scripts/check_doc_drift.py` | Maintainer |
| **Weekly** | Migration ordering check | `scripts/check_migration_order.py` | Maintainer |
| **Monthly** | Full INDEX.md review — verify all entries current | Manual | Maintainer |
| **Monthly** | Run `SELECT log_drift_check()` and review trends | SQL | Maintainer |
| **Quarterly** | Archive stale deprecated docs | Manual | Maintainer |

**Automation target:** Move weekly checks to CI via `governance-drift.yml`
after all GOV-* issues are complete (see [DRIFT_DETECTION.md](DRIFT_DETECTION.md)
section 5 for the planned workflow).

---

## 8. Metrics

Track these documentation health metrics over time:

| Metric | Target | Measurement |
|---|---|---|
| Documents with owner assigned | 100% | INDEX.md `Owner Issue` column — no `—` entries |
| Documents within 90-day freshness | 100% | `scripts/check_doc_drift.py` output |
| PR documentation checklist completion | > 90% | Manual audit of merged PRs |
| INDEX.md accuracy (matches `docs/` dir) | 100% | `QA__governance_drift.sql` (future check) |
