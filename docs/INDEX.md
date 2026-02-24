# Documentation Index

> **Last updated:** 2026-03-01
> **Status:** Active — update when adding, renaming, or archiving docs
> **Total documents:** 42 in `docs/` + 5 elsewhere in repo
> **Reference:** Issue [#200](https://github.com/ericsocrat/poland-food-db/issues/200), [#201](https://github.com/ericsocrat/poland-food-db/issues/201)

---

## Quick Navigation

| Domain                                                   | Count | Documents                                                                                                |
| -------------------------------------------------------- | ----- | -------------------------------------------------------------------------------------------------------- |
| [Architecture & Design](#architecture--design)           | 6     | Governance blueprint, domain boundaries, feature flags, scoring engine, search architecture, CI proposal |
| [API](#api)                                              | 4     | Contracts, versioning, frontend mapping, contract testing                                                |
| [Scoring](#scoring)                                      | 2     | Methodology (formula), engine (architecture)                                                             |
| [Data & Provenance](#data--provenance)                   | 5     | Sources, provenance, integrity audits, EAN validation, production data                                   |
| [Security & Compliance](#security--compliance)           | 5     | Root policy, audit report, access audit, privacy checklist, rate limiting                                |
| [Observability & Operations](#observability--operations) | 7     | Monitoring, observability, log schema, SLOs, metrics, incident response, disaster drill                  |
| [DevOps & Environment](#devops--environment)             | 3     | Environment strategy, staging setup, Sonar config                                                        |
| [Frontend & UX](#frontend--ux)                           | 4     | UX/UI design, UX impact metrics, design system, frontend README                                          |
| [Process & Workflow](#process--workflow)                 | 6     | Research workflow, viewing & testing, backfill standard, migration conventions, labels, country expansion |
| [Governance & Policy](#governance--policy)               | 5     | Feature sunsetting, performance guardrails, doc governance, this index, governance blueprint             |

---

## Architecture & Design

| Document                                                   | Purpose                                                                                                              | Owner Issue                                                                                                                      | Last Updated |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| [GOVERNANCE_BLUEPRINT.md](GOVERNANCE_BLUEPRINT.md)         | Execution governance blueprint — master plan for all GOV-* issues                                                    | [#195](https://github.com/ericsocrat/poland-food-db/issues/195)                                                                  | 2026-02-24   |
| [DOMAIN_BOUNDARIES.md](DOMAIN_BOUNDARIES.md)               | Domain boundary enforcement, 13 domains, ownership mapping, interface contracts                                      | [#196](https://github.com/ericsocrat/poland-food-db/issues/196)                                                                  | 2026-02-24   |
| [FEATURE_FLAGS.md](FEATURE_FLAGS.md)                       | Feature flag architecture — toggle registry, rollout strategy                                                        | [#191](https://github.com/ericsocrat/poland-food-db/issues/191)                                                                  | 2026-02-24   |
| [SCORING_ENGINE.md](SCORING_ENGINE.md)                     | Scoring engine architecture — versioned function design, formula registry, weight governance, drift detection        | [#189](https://github.com/ericsocrat/poland-food-db/issues/189), [#198](https://github.com/ericsocrat/poland-food-db/issues/198) | 2026-02-28   |
| [DRIFT_DETECTION.md](DRIFT_DETECTION.md)                   | Automated drift detection — 8-check catalog, severity levels, CI integration plan, doc freshness, migration ordering | [#199](https://github.com/ericsocrat/poland-food-db/issues/199)                                                                  | 2026-03-01   |
| [SEARCH_ARCHITECTURE.md](SEARCH_ARCHITECTURE.md)           | Search architecture — pg_trgm, tsvector, ranking, synonym management                                                 | [#192](https://github.com/ericsocrat/poland-food-db/issues/192)                                                                  | 2026-02-24   |
| [CI_ARCHITECTURE_PROPOSAL.md](CI_ARCHITECTURE_PROPOSAL.md) | CI pipeline design proposal                                                                                          | —                                                                                                                                | 2026-02-23   |

## API

| Document                                   | Purpose                                                                          | Owner Issue                                                     | Last Updated |
| ------------------------------------------ | -------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [API_CONTRACTS.md](API_CONTRACTS.md)       | API surface contracts — response shapes, hidden columns, 20+ RPC functions       | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-24   |
| [API_VERSIONING.md](API_VERSIONING.md)     | API deprecation & versioning policy — function-name versioning, sunset timelines | [#234](https://github.com/ericsocrat/poland-food-db/issues/234) | 2026-02-24   |
| [FRONTEND_API_MAP.md](FRONTEND_API_MAP.md) | Frontend-to-API mapping reference — which pages call which RPCs                  | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-13   |
| [CONTRACT_TESTING.md](CONTRACT_TESTING.md) | API contract testing strategy — pgTAP patterns, response shape validation        | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-24   |

## Scoring

| Document                                         | Purpose                                                               | Owner Issue                                                     | Last Updated |
| ------------------------------------------------ | --------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md) | v3.2 scoring formula — 9 factors, weights, ceilings, bands            | [#189](https://github.com/ericsocrat/poland-food-db/issues/189) | 2026-02-12   |
| [SCORING_ENGINE.md](SCORING_ENGINE.md)           | Scoring engine architecture — function versioning, regression testing | [#189](https://github.com/ericsocrat/poland-food-db/issues/189) | 2026-02-24   |

> **Relationship:** SCORING_METHODOLOGY.md defines the **formula** (what is computed). SCORING_ENGINE.md defines the **architecture** (how it is maintained, versioned, and tested). No redundancy — they serve different audiences.

## Data & Provenance

| Document                                             | Purpose                                                                          | Owner Issue                                                     | Last Updated |
| ---------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [DATA_SOURCES.md](DATA_SOURCES.md)                   | Source hierarchy & validation workflow — OFF API, manual entry                   | [#193](https://github.com/ericsocrat/poland-food-db/issues/193) | 2026-02-12   |
| [DATA_PROVENANCE.md](DATA_PROVENANCE.md)             | Data provenance & freshness governance — lineage tracking, staleness detection   | [#193](https://github.com/ericsocrat/poland-food-db/issues/193) | 2026-02-24   |
| [DATA_INTEGRITY_AUDITS.md](DATA_INTEGRITY_AUDITS.md) | Ongoing data integrity audit framework — nightly checks, contradiction detection | [#184](https://github.com/ericsocrat/poland-food-db/issues/184) | 2026-02-22   |
| [EAN_VALIDATION_STATUS.md](EAN_VALIDATION_STATUS.md) | EAN coverage tracking — 997/1,025 (97.3%)                                        | Data domain                                                     | 2026-02-24   |
| [PRODUCTION_DATA.md](PRODUCTION_DATA.md)             | Production data management — sync, backup, restore procedures                    | DevOps domain                                                   | 2026-02-24   |

> **Relationship:** DATA_SOURCES.md catalogs **where** data comes from. DATA_PROVENANCE.md governs **how freshness and lineage are tracked**. No redundancy.

## Security & Compliance

| Document                                     | Purpose                                                                    | Owner Issue                                                     | Last Updated |
| -------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [../SECURITY.md](../SECURITY.md)             | Root security policy — vulnerability table, reporting process              | Security domain                                                 | 2026-02-24   |
| [SECURITY_AUDIT.md](SECURITY_AUDIT.md)       | Full security audit report — RLS, function security, headers, dependencies | [#232](https://github.com/ericsocrat/poland-food-db/issues/232) | 2026-02-23   |
| [ACCESS_AUDIT.md](ACCESS_AUDIT.md)           | Data access pattern audit — table-by-role matrix, quarterly review process | [#235](https://github.com/ericsocrat/poland-food-db/issues/235) | 2026-02-24   |
| [PRIVACY_CHECKLIST.md](PRIVACY_CHECKLIST.md) | GDPR/RODO compliance checklist — data inventory, retention, subject rights | [#236](https://github.com/ericsocrat/poland-food-db/issues/236) | 2026-02-24   |
| [RATE_LIMITING.md](RATE_LIMITING.md)         | Rate limiting strategy — API abuse prevention, throttle tiers              | Security domain                                                 | 2026-02-23   |

> **Relationship:** SECURITY.md (root) is a **policy overview** (required by GitHub security features). SECURITY_AUDIT.md is a **detailed audit report**. ACCESS_AUDIT.md focuses on **access patterns**. No redundancy — each has distinct scope.

## Observability & Operations

| Document                                             | Purpose                                                                         | Owner Issue                                                     | Last Updated |
| ---------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [MONITORING.md](MONITORING.md)                       | Runtime monitoring — alerts, dashboards, health checks                          | Observability domain                                            | 2026-02-24   |
| [OBSERVABILITY.md](OBSERVABILITY.md)                 | Observability strategy — structured logging, tracing, metrics pipeline          | Observability domain                                            | 2026-02-23   |
| [SLO.md](SLO.md)                                     | Service Level Objectives — availability, latency, error rate targets            | Observability domain                                            | 2026-02-24   |
| [METRICS.md](METRICS.md)                             | Metrics catalog — application metrics, infrastructure metrics, business metrics | Observability domain                                            | 2026-02-24   |
| [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md)         | Incident response playbook — severity, escalation, runbooks, post-mortem        | [#231](https://github.com/ericsocrat/poland-food-db/issues/231) | 2026-02-24   |
| [LOG_SCHEMA.md](LOG_SCHEMA.md)                       | Structured log schema & error taxonomy — error codes, severity, retention, validation | [#210](https://github.com/ericsocrat/poland-food-db/issues/210) | 2026-03-04   |
| [DISASTER_DRILL_REPORT.md](DISASTER_DRILL_REPORT.md) | Disaster recovery drill report — test results, findings, remediation            | Observability domain                                            | 2026-02-23   |

## DevOps & Environment

| Document                                           | Purpose                                                                 | Owner Issue | Last Updated |
| -------------------------------------------------- | ----------------------------------------------------------------------- | ----------- | ------------ |
| [ENVIRONMENT_STRATEGY.md](ENVIRONMENT_STRATEGY.md) | Local/staging/production environment strategy                           | DevOps domain | 2026-02-22   |
| [STAGING_SETUP.md](STAGING_SETUP.md)               | Staging environment setup guide — scripts, sync workflow, configuration | DevOps domain | 2026-02-24   |
| [SONAR.md](SONAR.md)                               | SonarCloud configuration & quality gates                                | DevOps domain | 2026-02-23   |

> **Relationship:** ENVIRONMENT_STRATEGY.md defines the **overall strategy** (3 environments). STAGING_SETUP.md provides **operational setup steps** for staging specifically. Complementary, not redundant.

## Frontend & UX

| Document                                                               | Purpose                                                                       | Owner Issue | Last Updated |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ----------- | ------------ |
| [UX_UI_DESIGN.md](UX_UI_DESIGN.md)                                     | UI/UX design guidelines — color system, components, layouts                   | Frontend domain | 2026-02-24   |
| [UX_IMPACT_METRICS.md](UX_IMPACT_METRICS.md)                           | UX measurement standard — event catalog, metric templates, performance budget | Frontend domain | 2026-02-24   |
| [../frontend/docs/DESIGN_SYSTEM.md](../frontend/docs/DESIGN_SYSTEM.md) | Frontend design system — Tailwind tokens, component patterns                  | Frontend domain | 2026-02-17   |
| [../frontend/README.md](../frontend/README.md)                         | Frontend project overview — setup, scripts, architecture                      | Frontend domain | 2026-02-24   |

## Process & Workflow

| Document                                                 | Purpose                                                                    | Owner Issue | Last Updated |
| -------------------------------------------------------- | -------------------------------------------------------------------------- | ----------- | ------------ |
| [RESEARCH_WORKFLOW.md](RESEARCH_WORKFLOW.md)             | Data collection lifecycle — manual + automated OFF pipeline                | Process domain | 2026-02-24   |
| [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md)         | Queries, Studio UI, test runner guide                                      | Process domain | 2026-02-24   |
| [BACKFILL_STANDARD.md](BACKFILL_STANDARD.md)             | Backfill orchestration standard — migration templates, validation patterns | [#208](https://github.com/ericsocrat/poland-food-db/issues/208) | 2026-03-03   |
| [MIGRATION_CONVENTIONS.md](MIGRATION_CONVENTIONS.md)     | Migration safety, trigger naming, lock risk, idempotency standards         | [#203](https://github.com/ericsocrat/poland-food-db/issues/203), [#207](https://github.com/ericsocrat/poland-food-db/issues/207) | 2026-03-02   |
| [LABELS.md](LABELS.md)                                   | GitHub labeling conventions — issue/PR label taxonomy                      | Process domain | 2026-02-23   |
| [COUNTRY_EXPANSION_GUIDE.md](COUNTRY_EXPANSION_GUIDE.md) | Multi-country expansion protocol — PL active, DE micro-pilot               | [#148](https://github.com/ericsocrat/poland-food-db/issues/148) | 2026-02-24   |

## Governance & Policy

| Document                                               | Purpose                                                                 | Owner Issue                                                     | Last Updated |
| ------------------------------------------------------ | ----------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [FEATURE_SUNSETTING.md](FEATURE_SUNSETTING.md)         | Feature retirement criteria, cleanup policy, quarterly hygiene review   | [#237](https://github.com/ericsocrat/poland-food-db/issues/237) | 2026-02-24   |
| [PERFORMANCE_GUARDRAILS.md](PERFORMANCE_GUARDRAILS.md)                     | Performance guardrails — query budgets, index policy, scale projections    | Governance domain                                                | 2026-02-23   |
| [DOCUMENTATION_GOVERNANCE.md](DOCUMENTATION_GOVERNANCE.md)                 | Documentation ownership, versioning, deprecation, drift prevention cadence | [#201](https://github.com/ericsocrat/poland-food-db/issues/201) | 2026-03-01   |
| INDEX.md                                                                   | This file — canonical documentation map                                    | [#200](https://github.com/ericsocrat/poland-food-db/issues/200) | 2026-03-01   |

## Other Repository Documents

| Document                                                 | Purpose                                                                   | Last Updated |
| -------------------------------------------------------- | ------------------------------------------------------------------------- | ------------ |
| [../README.md](../README.md)                             | Project overview                                                          | 2026-02-24   |
| [../SECURITY.md](../SECURITY.md)                         | Security policy (root — GitHub-required location)                         | 2026-02-24   |
| [../DEPLOYMENT.md](../DEPLOYMENT.md)                     | Deployment procedures, rollback playbook                                  | 2026-02-24   |
| [../CHANGELOG.md](../CHANGELOG.md)                       | Structured changelog (Keep a Changelog + Conventional Commits)            | 2026-02-24   |
| [../copilot-instructions.md](../copilot-instructions.md) | AI agent instructions — schema, conventions, testing rules (~1,510 lines) | 2026-02-24   |
| [../supabase/seed/README.md](../supabase/seed/README.md) | Seed data documentation                                                   | 2026-02-15   |

---

## Redundancy Assessment

Pairs investigated for overlap during the 2026-02-28 audit:

| Pair                                              | Assessment                                                                       | Verdict                                                |
| ------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------ |
| SECURITY.md (root) ↔ SECURITY_AUDIT.md            | Root = policy overview; Audit = detailed report                                  | **No redundancy** — distinct scope                     |
| DATA_SOURCES.md ↔ DATA_PROVENANCE.md              | Sources = where data comes from; Provenance = freshness governance               | **No redundancy** — complements                        |
| SCORING_METHODOLOGY.md ↔ SCORING_ENGINE.md        | Methodology = formula; Engine = architecture                                     | **No redundancy** — what vs how                        |
| ENVIRONMENT_STRATEGY.md ↔ STAGING_SETUP.md        | Strategy = overall design; Setup = operational steps                             | **No redundancy** — complements                        |
| MONITORING.md ↔ OBSERVABILITY.md                  | Monitoring = alerts/dashboards; Observability = logging/tracing/metrics pipeline | **No redundancy** — overlapping domain, distinct focus |
| OBSERVABILITY.md ↔ LOG_SCHEMA.md                  | Observability = strategy/format; Log Schema = error codes/taxonomy/DB registry  | **No redundancy** — format vs taxonomy                 |
| METRICS.md ↔ UX_IMPACT_METRICS.md                 | Metrics = infra/app metrics; UX Impact = UX-specific measurement                 | **No redundancy** — different audiences                |
| PERFORMANCE_REPORT.md ↔ PERFORMANCE_GUARDRAILS.md | Report = audit findings; Guardrails = policy/budgets                             | **No redundancy** — snapshot vs policy                 |

## Obsolete Reference Check

Files checked for references to deprecated elements (`compute_unhealthiness_v31`, `scored_at`, `column_metadata`):

| File                   | Hits | Assessment                                                                      |
| ---------------------- | ---- | ------------------------------------------------------------------------------- |
| FEATURE_SUNSETTING.md  | 2    | `column_metadata` referenced as **already-cleaned-up example** — intentional    |
| SCORING_ENGINE.md      | 5    | References to v3.1 as **historical context** in version evolution — intentional |
| SCORING_METHODOLOGY.md | 4    | References to v3.1 as **previous version** in changelog section — intentional   |
| SECURITY_AUDIT.md      | 2    | References to scoring version history — intentional                             |
| UX_UI_DESIGN.md        | 1    | Minor v3.1 reference in historical context — intentional                        |

**Result:** No stale or misleading obsolete references found. All hits are intentional historical context.

## Removed Documents (No Longer Present)

The following files were referenced in early project phases but have been superseded or consolidated:

| Former File                    | Status     | Successor                                                                  |
| ------------------------------ | ---------- | -------------------------------------------------------------------------- |
| `DATA_ACQUISITION_WORKFLOW.md` | Superseded | Content merged into RESEARCH_WORKFLOW.md                                   |
| `EAN_EXPANSION_PLAN.md`        | Superseded | Content merged into EAN_VALIDATION_STATUS.md                               |
| `FULL_PROJECT_AUDIT.md`        | Superseded | One-time audit; findings incorporated into GOVERNANCE_BLUEPRINT.md         |
| `TABLE_AUDIT_2026-02-12.md`    | Superseded | One-time snapshot; findings incorporated into current schema documentation |
| `PLATFORM_MATURITY_MODEL.md`   | Superseded | Content absorbed into GOVERNANCE_BLUEPRINT.md                              |

---

## Documentation Standards

### Required Frontmatter

Every active document in `docs/` should include a header block:

```markdown
# Document Title

> **Last updated:** YYYY-MM-DD
> **Status:** Active | Deprecated | Archived
> **Owner issue:** #NNN (or "—" if no specific issue)
```

### Update Triggers

When modifying code in a domain, check the corresponding doc:

| Code Change                        | Document to Check                        |
| ---------------------------------- | ---------------------------------------- |
| Scoring formula weights/ceilings   | SCORING_METHODOLOGY.md                   |
| API function signature or response | API_CONTRACTS.md, FRONTEND_API_MAP.md    |
| New migration                      | copilot-instructions.md (schema section) |
| New country added                  | COUNTRY_EXPANSION_GUIDE.md               |
| New user-facing table              | PRIVACY_CHECKLIST.md, ACCESS_AUDIT.md    |
| Environment configuration          | ENVIRONMENT_STRATEGY.md                  |
| CI workflow changes                | CI_ARCHITECTURE_PROPOSAL.md              |

### Adding a New Document

1. Create in `docs/` with frontmatter header
2. Add entry to this INDEX.md in the appropriate domain section
3. Add entry to `copilot-instructions.md` project layout (docs section)
4. Add CHANGELOG.md entry under `[Unreleased]` → Documentation

### Archiving a Document

1. Add `> **Status:** Archived — [reason]` to the document header
2. Move the INDEX.md entry to the "Removed Documents" section
3. Optionally move the file to `docs/archive/` (create directory if needed)
4. Update `copilot-instructions.md` project layout
