# Documentation Index

> **Last updated:** 2026-03-14
> **Status:** Active — update when adding, renaming, or archiving docs
> **Total documents:** 49 in `docs/` + 8 in `docs/decisions/` + 17 in `docs/assets/logo/` + 5 in `docs/assets/banners/` + 5 elsewhere in repo
> **Reference:** Issue [#200](https://github.com/ericsocrat/poland-food-db/issues/200), [#201](https://github.com/ericsocrat/poland-food-db/issues/201)

---

## Quick Navigation

| Domain                                                   | Count | Documents                                                                                                                          |
| -------------------------------------------------------- | ----- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [Architecture & Design](#architecture--design)           | 6     | Governance blueprint, domain boundaries, feature flags, scoring engine, search architecture, CI proposal                           |
| [Diagrams](#diagrams)                                    | 13    | Architecture, ERDs, pipeline flow, QA overview, CI/CD, confidence, concern tiers, country expansion, scoring infographic + headers |
| [Brand Assets](#brand-assets)                            | 17    | Logomark SVG variants + PNG exports, wordmark, lockup variants (horizontal + stacked, light + dark) |
| [Banners](#banners)                                      | 5     | Social preview, README hero banner (SVG + PNG), badges reference             |
| [API](#api)                                              | 6     | Contracts, conventions, versioning, frontend mapping, contract testing, registry                                                   |
| [Scoring](#scoring)                                      | 2     | Methodology (formula), engine (architecture)                                                                                       |
| [Data & Provenance](#data--provenance)                   | 5     | Sources, provenance, integrity audits, EAN validation, production data                                                             |
| [Security & Compliance](#security--compliance)           | 5     | Root policy, audit report, access audit, privacy checklist, rate limiting                                                          |
| [Observability & Operations](#observability--operations) | 9     | Monitoring, observability, log schema, alerts, on-call policy, SLOs, metrics, incident response, disaster drill                    |
| [DevOps & Environment](#devops--environment)             | 3     | Environment strategy, staging setup, Sonar config                                                                                  |
| [Frontend & UX](#frontend--ux)                           | 5     | UX/UI design, UX impact metrics, brand guidelines, design system, frontend README                                                  |
| [Process & Workflow](#process--workflow)                 | 6     | Research workflow, viewing & testing, backfill standard, migration conventions, labels, country expansion                          |
| [Governance & Policy](#governance--policy)               | 6     | Feature sunsetting, performance report, performance guardrails, doc governance, repo governance, this index                        |
| [Architecture Decisions](#architecture-decisions-adrs)   | 8     | MADR template + 7 retroactive ADRs (stack, scoring, country isolation, pipeline, API versioning, migrations, ingredients)          |

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

## Diagrams

> **Location:** `docs/diagrams/`
> **Toolchain:** Mermaid CLI (`@mermaid-js/mermaid-cli`) → SVGO optimization
> **Source files:** `.mmd` (Mermaid markup) — regenerate SVGs via `npx @mermaid-js/mermaid-cli -i <file>.mmd -o <file>.svg`

| File                                                                          | Purpose                                                                | Owner Issue                                                     | Last Updated |
| ----------------------------------------------------------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [architecture-overview.svg](diagrams/architecture-overview.svg)               | Architecture overview — data flow, components, key stats (light mode)  | [#426](https://github.com/ericsocrat/poland-food-db/issues/426) | 2026-03-13   |
| [architecture-overview-dark.svg](diagrams/architecture-overview-dark.svg)     | Architecture overview — dark mode variant for GitHub dark theme        | [#426](https://github.com/ericsocrat/poland-food-db/issues/426) | 2026-03-13   |
| [architecture-overview.mmd](diagrams/architecture-overview.mmd)               | Mermaid source for architecture overview (light mode)                  | [#426](https://github.com/ericsocrat/poland-food-db/issues/426) | 2026-03-13   |
| [architecture-overview-dark.mmd](diagrams/architecture-overview-dark.mmd)     | Mermaid source for architecture overview (dark mode)                   | [#426](https://github.com/ericsocrat/poland-food-db/issues/426) | 2026-03-13   |
| [erd-full.svg](diagrams/erd-full.svg)                                         | Full ERD — 30+ tables across 5 domains, Crow's foot notation (light)   | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-full-dark.svg](diagrams/erd-full-dark.svg)                               | Full ERD — dark mode variant for GitHub dark theme                     | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-core.svg](diagrams/erd-core.svg)                                         | Core ERD — 7 product-domain tables, simplified view (light)            | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-core-dark.svg](diagrams/erd-core-dark.svg)                               | Core ERD — dark mode variant for GitHub dark theme                     | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-full.mmd](diagrams/erd-full.mmd)                                         | Mermaid source for full ERD (light mode)                               | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-full-dark.mmd](diagrams/erd-full-dark.mmd)                               | Mermaid source for full ERD (dark mode)                                | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-core.mmd](diagrams/erd-core.mmd)                                         | Mermaid source for core ERD (light mode)                               | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [erd-core-dark.mmd](diagrams/erd-core-dark.mmd)                               | Mermaid source for core ERD (dark mode)                                | [#428](https://github.com/ericsocrat/poland-food-db/issues/428) | 2026-03-13   |
| [pipeline-flow.svg](diagrams/pipeline-flow.svg)                               | Pipeline flow — OFF API to SQL generation to DB execution              | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [ci-cd-pipeline.svg](diagrams/ci-cd-pipeline.svg)                             | CI/CD pipeline — 19 workflows, gates, triggers, artifact flow          | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [qa-overview.svg](diagrams/qa-overview.svg)                                   | QA overview — 47 suites, 733 checks organized by domain                | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [confidence-model.svg](diagrams/confidence-model.svg)                         | Confidence scoring — 6 components, composite 0-100, band assignment    | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [concern-tiers.svg](diagrams/concern-tiers.svg)                               | EFSA concern tiers — 4-tier additive classification with examples      | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [country-expansion.svg](diagrams/country-expansion.svg)                       | Country expansion — PL primary + DE micro-pilot architecture           | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [pipeline-flow.mmd](diagrams/pipeline-flow.mmd)                               | Mermaid source for pipeline flow                                       | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [ci-cd-pipeline.mmd](diagrams/ci-cd-pipeline.mmd)                             | Mermaid source for CI/CD pipeline                                      | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [qa-overview.mmd](diagrams/qa-overview.mmd)                                   | Mermaid source for QA overview                                         | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [confidence-model.mmd](diagrams/confidence-model.mmd)                         | Mermaid source for confidence model                                    | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [concern-tiers.mmd](diagrams/concern-tiers.mmd)                               | Mermaid source for concern tiers                                       | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [country-expansion.mmd](diagrams/country-expansion.mmd)                       | Mermaid source for country expansion                                   | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [headers/header-architecture.svg](diagrams/headers/header-architecture.svg)   | Section banner — Architecture (800x120px, brand gradient)              | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [headers/header-scoring.svg](diagrams/headers/header-scoring.svg)             | Section banner — Scoring                                               | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [headers/header-api.svg](diagrams/headers/header-api.svg)                     | Section banner — API Reference                                         | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [headers/header-qa.svg](diagrams/headers/header-qa.svg)                       | Section banner — Quality Assurance                                     | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [headers/header-deployment.svg](diagrams/headers/header-deployment.svg)       | Section banner — Deployment                                            | [#429](https://github.com/ericsocrat/poland-food-db/issues/429) | 2026-03-13   |
| [scoring-v32-infographic.svg](diagrams/scoring-v32-infographic.svg)           | Scoring v3.2 infographic — 9 factors, weights, bands, examples (light) | [#427](https://github.com/ericsocrat/poland-food-db/issues/427) | 2026-03-13   |
| [scoring-v32-infographic-dark.svg](diagrams/scoring-v32-infographic-dark.svg) | Scoring v3.2 infographic — dark mode variant                           | [#427](https://github.com/ericsocrat/poland-food-db/issues/427) | 2026-03-13   |
| [scoring-v32-breakdown.svg](diagrams/scoring-v32-breakdown.svg)               | Scoring v3.2 breakdown — factor weights stacked bar + detail table     | [#427](https://github.com/ericsocrat/poland-food-db/issues/427) | 2026-03-13   |

## Brand Assets

> **Location:** `docs/assets/logo/`
> **Source:** SVG vector originals — PNG rasters generated via `sharp`

| File                                                           | Purpose                                                                     | Owner Issue                                                     | Last Updated |
| -------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [logomark.svg](assets/logo/logomark.svg)                       | Primary logomark — shield-leaf hybrid, brand gradient, vein structure        | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-dark.svg](assets/logo/logomark-dark.svg)             | Dark-mode logomark variant — lighter teal gradient, dark interior veins     | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-mono.svg](assets/logo/logomark-mono.svg)             | Monochrome logomark — `currentColor` silhouette, no interior detail         | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-512.png](assets/logo/logomark-512.png)               | PNG export 512×512 (full color)                                             | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-256.png](assets/logo/logomark-256.png)               | PNG export 256×256                                                          | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-192.png](assets/logo/logomark-192.png)               | PNG export 192×192 (Android launcher)                                       | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-180.png](assets/logo/logomark-180.png)               | PNG export 180×180 (Apple touch icon)                                       | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-128.png](assets/logo/logomark-128.png)               | PNG export 128×128                                                          | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-64.png](assets/logo/logomark-64.png)                 | PNG export 64×64                                                            | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-32.png](assets/logo/logomark-32.png)                 | PNG export 32×32 (favicon candidate)                                        | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [logomark-16.png](assets/logo/logomark-16.png)                 | PNG export 16×16 (smallest favicon)                                         | [#407](https://github.com/ericsocrat/poland-food-db/issues/407) | 2026-03-14   |
| [wordmark.svg](assets/logo/wordmark.svg)                       | Placeholder wordmark — styled project name (brand teal, system sans-serif)  | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |
| [wordmark-dark.svg](assets/logo/wordmark-dark.svg)             | Dark-mode wordmark — white text for dark backgrounds                        | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |
| [lockup-horizontal.svg](assets/logo/lockup-horizontal.svg)     | Horizontal lockup — logomark left + wordmark right (light bg)               | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |
| [lockup-horizontal-dark.svg](assets/logo/lockup-horizontal-dark.svg) | Horizontal lockup — dark mode variant                                 | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |
| [lockup-stacked.svg](assets/logo/lockup-stacked.svg)           | Stacked lockup — logomark above + wordmark below (light bg)                 | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |
| [lockup-stacked-dark.svg](assets/logo/lockup-stacked-dark.svg) | Stacked lockup — dark mode variant                                          | [#408](https://github.com/ericsocrat/poland-food-db/issues/408) | 2026-03-14   |

## Banners

> **Location:** `docs/assets/banners/`
> **Source:** SVG vector originals — PNG rasters generated via `sharp`

| File                                                           | Purpose                                                                     | Owner Issue                                                     | Last Updated |
| -------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [social-preview.svg](assets/banners/social-preview.svg)        | GitHub social preview source — 1280×640 OpenGraph image (SVG)               | [#411](https://github.com/ericsocrat/poland-food-db/issues/411) | 2026-03-14   |
| [social-preview.png](assets/banners/social-preview.png)        | GitHub social preview — 1280×640 PNG (53 KB, optimized)                     | [#411](https://github.com/ericsocrat/poland-food-db/issues/411) | 2026-03-14   |
| [readme-banner.svg](assets/banners/readme-banner.svg)          | README hero banner source — 1200×340 with logo, tagline, data motif         | [#412](https://github.com/ericsocrat/poland-food-db/issues/412) | 2026-03-14   |
| [readme-banner.png](assets/banners/readme-banner.png)          | README hero banner — 1200×340 PNG (94 KB, optimized)                        | [#412](https://github.com/ericsocrat/poland-food-db/issues/412) | 2026-03-14   |
| [README_BANNER_REFERENCE.md](assets/banners/README_BANNER_REFERENCE.md) | Ready-to-paste banner + badges markdown for README.md            | [#412](https://github.com/ericsocrat/poland-food-db/issues/412) | 2026-03-14   |

## API

| Document                                   | Purpose                                                                          | Owner Issue                                                     | Last Updated |
| ------------------------------------------ | -------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [API_CONTRACTS.md](API_CONTRACTS.md)       | API surface contracts — response shapes, hidden columns, 20+ RPC functions       | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-24   |
| [API_CONVENTIONS.md](API_CONVENTIONS.md)   | RPC naming convention, breaking change definition, security standards            | [#234](https://github.com/ericsocrat/poland-food-db/issues/234) | 2026-02-24   |
| [API_VERSIONING.md](API_VERSIONING.md)     | API deprecation & versioning policy — function-name versioning, sunset timelines | [#234](https://github.com/ericsocrat/poland-food-db/issues/234) | 2026-02-24   |
| [FRONTEND_API_MAP.md](FRONTEND_API_MAP.md) | Frontend-to-API mapping reference — which pages call which RPCs                  | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-13   |
| [CONTRACT_TESTING.md](CONTRACT_TESTING.md) | API contract testing strategy — pgTAP patterns, response shape validation        | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-24   |
| [api-registry.yaml](api-registry.yaml)     | Structured registry of all 109 API functions (YAML machine-readable)             | [#197](https://github.com/ericsocrat/poland-food-db/issues/197) | 2026-02-24   |

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

| Document                                                              | Purpose                                                                               | Owner Issue                                                     | Last Updated |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [MONITORING.md](MONITORING.md)                                        | Runtime monitoring — alerts, dashboards, health checks                                | Observability domain                                            | 2026-02-24   |
| [OBSERVABILITY.md](OBSERVABILITY.md)                                  | Observability strategy — structured logging, tracing, metrics pipeline                | Observability domain                                            | 2026-02-23   |
| [SLO.md](SLO.md)                                                      | Service Level Objectives — availability, latency, error rate targets                  | Observability domain                                            | 2026-02-24   |
| [METRICS.md](METRICS.md)                                              | Metrics catalog — application metrics, infrastructure metrics, business metrics       | Observability domain                                            | 2026-02-24   |
| [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md)                          | Incident response playbook — severity, escalation, runbooks, post-mortem              | [#231](https://github.com/ericsocrat/poland-food-db/issues/231) | 2026-02-24   |
| [LOG_SCHEMA.md](LOG_SCHEMA.md)                                        | Structured log schema & error taxonomy — error codes, severity, retention, validation | [#210](https://github.com/ericsocrat/poland-food-db/issues/210) | 2026-03-04   |
| [ALERT_POLICY.md](ALERT_POLICY.md)                                    | Alert escalation policy, query regression detection, index drift monitoring           | [#211](https://github.com/ericsocrat/poland-food-db/issues/211) | 2026-03-04   |
| [`monitoring/alerts.yml`](../monitoring/alerts.yml)                   | Machine-readable alert definitions (source of truth for ALERT_POLICY.md)              | [#332](https://github.com/ericsocrat/poland-food-db/issues/332) | 2026-03-05   |
| [ON_CALL_POLICY.md](ON_CALL_POLICY.md)                                | On-call & alert ownership — routing, ack targets, triage labels, quiet hours          | [#233](https://github.com/ericsocrat/poland-food-db/issues/233) | 2026-03-04   |
| [DISASTER_DRILL_REPORT.md](DISASTER_DRILL_REPORT.md)                  | Disaster recovery drill report — test results, findings, remediation                  | Observability domain                                            | 2026-02-23   |
| [`.github/workflows/dr-drill.yml`](../.github/workflows/dr-drill.yml) | Automated DR drill — monthly cron + manual, disposable PostgreSQL rebuild             | [#333](https://github.com/ericsocrat/poland-food-db/issues/333) | 2026-03-05   |

## DevOps & Environment

| Document                                           | Purpose                                                                 | Owner Issue   | Last Updated |
| -------------------------------------------------- | ----------------------------------------------------------------------- | ------------- | ------------ |
| [ENVIRONMENT_STRATEGY.md](ENVIRONMENT_STRATEGY.md) | Local/staging/production environment strategy                           | DevOps domain | 2026-02-22   |
| [STAGING_SETUP.md](STAGING_SETUP.md)               | Staging environment setup guide — scripts, sync workflow, configuration | DevOps domain | 2026-02-24   |
| [SONAR.md](SONAR.md)                               | SonarCloud configuration & quality gates                                | DevOps domain | 2026-02-23   |

> **Relationship:** ENVIRONMENT_STRATEGY.md defines the **overall strategy** (3 environments). STAGING_SETUP.md provides **operational setup steps** for staging specifically. Complementary, not redundant.

## Frontend & UX

| Document                                                               | Purpose                                                                                                                | Owner Issue                                                     | Last Updated |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [UX_UI_DESIGN.md](UX_UI_DESIGN.md)                                     | UI/UX design guidelines — color system, components, layouts                                                            | Frontend domain                                                 | 2026-02-24   |
| [UX_IMPACT_METRICS.md](UX_IMPACT_METRICS.md)                           | UX measurement standard — event catalog, metric templates, performance budget                                          | Frontend domain                                                 | 2026-02-24   |
| [BRAND_GUIDELINES.md](BRAND_GUIDELINES.md)                             | Brand guidelines — 14-section visual identity reference (colors, typography, motion, accessibility, dark mode, assets) | [#410](https://github.com/ericsocrat/poland-food-db/issues/410) | 2026-03-14   |
| [../frontend/docs/DESIGN_SYSTEM.md](../frontend/docs/DESIGN_SYSTEM.md) | Frontend design system — Tailwind tokens, component patterns                                                           | Frontend domain                                                 | 2026-02-17   |
| [../frontend/README.md](../frontend/README.md)                         | Frontend project overview — setup, scripts, architecture                                                               | Frontend domain                                                 | 2026-02-24   |

## Process & Workflow

| Document                                                 | Purpose                                                                    | Owner Issue                                                                                                                      | Last Updated |
| -------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| [RESEARCH_WORKFLOW.md](RESEARCH_WORKFLOW.md)             | Data collection lifecycle — manual + automated OFF pipeline                | Process domain                                                                                                                   | 2026-02-24   |
| [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md)         | Queries, Studio UI, test runner guide                                      | Process domain                                                                                                                   | 2026-02-24   |
| [BACKFILL_STANDARD.md](BACKFILL_STANDARD.md)             | Backfill orchestration standard — migration templates, validation patterns | [#208](https://github.com/ericsocrat/poland-food-db/issues/208)                                                                  | 2026-03-03   |
| [MIGRATION_CONVENTIONS.md](MIGRATION_CONVENTIONS.md)     | Migration safety, trigger naming, lock risk, idempotency standards         | [#203](https://github.com/ericsocrat/poland-food-db/issues/203), [#207](https://github.com/ericsocrat/poland-food-db/issues/207) | 2026-03-02   |
| [LABELS.md](LABELS.md)                                   | GitHub labeling conventions — issue/PR label taxonomy                      | Process domain                                                                                                                   | 2026-02-23   |
| [COUNTRY_EXPANSION_GUIDE.md](COUNTRY_EXPANSION_GUIDE.md) | Multi-country expansion protocol — PL active, DE micro-pilot               | [#148](https://github.com/ericsocrat/poland-food-db/issues/148)                                                                  | 2026-02-24   |

## Governance & Policy

| Document                                                   | Purpose                                                                    | Owner Issue                                                     | Last Updated |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| [FEATURE_SUNSETTING.md](FEATURE_SUNSETTING.md)             | Feature retirement criteria, cleanup policy, quarterly hygiene review      | [#237](https://github.com/ericsocrat/poland-food-db/issues/237) | 2026-02-24   |
| [PERFORMANCE_REPORT.md](PERFORMANCE_REPORT.md)             | Performance audit — query patterns, scale projections, benchmark findings  | Governance domain                                               | 2026-02-24   |
| [PERFORMANCE_GUARDRAILS.md](PERFORMANCE_GUARDRAILS.md)     | Performance guardrails — query budgets, index policy, scale projections    | Governance domain                                               | 2026-02-23   |
| [REPO_GOVERNANCE.md](REPO_GOVERNANCE.md)                   | Repo structure rules, root cleanliness, change checklists, CI alignment    | Governance domain                                               | 2026-02-25   |
| [DOCUMENTATION_GOVERNANCE.md](DOCUMENTATION_GOVERNANCE.md) | Documentation ownership, versioning, deprecation, drift prevention cadence | [#201](https://github.com/ericsocrat/poland-food-db/issues/201) | 2026-03-01   |
| INDEX.md                                                   | This file — canonical documentation map                                    | [#200](https://github.com/ericsocrat/poland-food-db/issues/200) | 2026-03-01   |

## Architecture Decisions (ADRs)

> **Location:** `docs/decisions/`
> **Template:** [MADR 3.0](https://adr.github.io/madr/) (Markdown Any Decision Records)
> **Convention:** Files named `NNN-short-title.md` with sequential numbering

| Document                                                                               | Decision                                                                         | Status   | Date       |
| -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | -------- | ---------- |
| [000-template.md](decisions/000-template.md)                                           | MADR 3.0 template for new ADRs                                                   | —        | 2026-02-25 |
| [001-postgresql-only-stack.md](decisions/001-postgresql-only-stack.md)                 | Use PostgreSQL as sole backend via Supabase — no ORM, no API server              | accepted | 2026-02-07 |
| [002-weighted-scoring-formula.md](decisions/002-weighted-scoring-formula.md)           | 9-factor weighted unhealthiness score (v3.2) with EFSA-based ingredient concerns | accepted | 2026-02-10 |
| [003-country-scoped-isolation.md](decisions/003-country-scoped-isolation.md)           | Single-table country isolation with FK + CHECK + QA enforcement                  | accepted | 2026-02-13 |
| [004-pipeline-generates-sql.md](decisions/004-pipeline-generates-sql.md)               | Python pipeline generates SQL files; never writes to DB directly                 | accepted | 2026-02-07 |
| [005-api-function-name-versioning.md](decisions/005-api-function-name-versioning.md)   | API versioning via function-name suffixes, not URL paths                         | accepted | 2026-02-13 |
| [006-append-only-migrations.md](decisions/006-append-only-migrations.md)               | Strict append-only migration strategy — never modify existing files              | accepted | 2026-02-07 |
| [007-english-canonical-ingredients.md](decisions/007-english-canonical-ingredients.md) | All 2,740 ingredients stored as clean ASCII English canonical names              | accepted | 2026-02-10 |

---

## Other Repository Documents

| Document                                                 | Purpose                                                                   | Last Updated |
| -------------------------------------------------------- | ------------------------------------------------------------------------- | ------------ |
| [../README.md](../README.md)                             | Project overview                                                          | 2026-02-24   |
| [../LICENSE](../LICENSE)                                 | Source code license (AGPL-3.0)                                            | 2026-02-25   |
| [../DATA_LICENSE.md](../DATA_LICENSE.md)                 | Curated data license (CC BY-NC-SA 4.0)                                    | 2026-02-25   |
| [../SECURITY.md](../SECURITY.md)                         | Security policy (root — GitHub-required location)                         | 2026-02-24   |
| [../DEPLOYMENT.md](../DEPLOYMENT.md)                     | Deployment procedures, rollback playbook                                  | 2026-02-24   |
| [../CHANGELOG.md](../CHANGELOG.md)                       | Structured changelog (Keep a Changelog + Conventional Commits)            | 2026-02-24   |
| [../copilot-instructions.md](../copilot-instructions.md) | AI agent instructions — schema, conventions, testing rules (~1,510 lines) | 2026-02-24   |
| [../supabase/seed/README.md](../supabase/seed/README.md) | Seed data documentation                                                   | 2026-02-15   |

---

## Redundancy Assessment

Pairs investigated for overlap during the 2026-02-28 audit:

| Pair                                              | Assessment                                                                           | Verdict                                                |
| ------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| SECURITY.md (root) ↔ SECURITY_AUDIT.md            | Root = policy overview; Audit = detailed report                                      | **No redundancy** — distinct scope                     |
| DATA_SOURCES.md ↔ DATA_PROVENANCE.md              | Sources = where data comes from; Provenance = freshness governance                   | **No redundancy** — complements                        |
| SCORING_METHODOLOGY.md ↔ SCORING_ENGINE.md        | Methodology = formula; Engine = architecture                                         | **No redundancy** — what vs how                        |
| ENVIRONMENT_STRATEGY.md ↔ STAGING_SETUP.md        | Strategy = overall design; Setup = operational steps                                 | **No redundancy** — complements                        |
| MONITORING.md ↔ OBSERVABILITY.md                  | Monitoring = alerts/dashboards; Observability = logging/tracing/metrics pipeline     | **No redundancy** — overlapping domain, distinct focus |
| OBSERVABILITY.md ↔ LOG_SCHEMA.md                  | Observability = strategy/format; Log Schema = error codes/taxonomy/DB registry       | **No redundancy** — format vs taxonomy                 |
| METRICS.md ↔ UX_IMPACT_METRICS.md                 | Metrics = infra/app metrics; UX Impact = UX-specific measurement                     | **No redundancy** — different audiences                |
| PERFORMANCE_REPORT.md ↔ PERFORMANCE_GUARDRAILS.md | Report = audit findings; Guardrails = policy/budgets                                 | **No redundancy** — snapshot vs policy                 |
| ALERT_POLICY.md ↔ ON_CALL_POLICY.md               | Alert Policy = escalation matrix/thresholds; On-Call = ownership/ack targets/labels  | **No redundancy** — what triggers vs who responds      |
| REPO_GOVERNANCE.md ↔ GOVERNANCE_BLUEPRINT.md      | Repo Governance = structure/hygiene/checklists; Blueprint = execution governance     | **No redundancy** — repo rules vs project management   |
| REPO_GOVERNANCE.md ↔ DOCUMENTATION_GOVERNANCE.md  | Repo Governance = structure/root/CI; Doc Governance = doc ownership/drift/versioning | **No redundancy** — repo-wide vs doc-specific          |

## Obsolete Reference Check

Files checked for references to deprecated elements (`scored_at`, `column_metadata`). Note: `compute_unhealthiness_v31` was dropped in migration `20260314000100_remove_legacy_v31_scoring.sql`.

| File                   | Hits | Assessment                                                                      |
| ---------------------- | ---- | ------------------------------------------------------------------------------- |
| FEATURE_SUNSETTING.md  | 2    | `column_metadata` referenced as **already-cleaned-up example** — intentional    |
| SCORING_ENGINE.md      | 5    | References to v3.1 as **historical context** in version evolution — intentional |
| SCORING_METHODOLOGY.md | 4    | References to v3.1 as **previous version** in changelog section — intentional   |
| SECURITY_AUDIT.md      | 1    | v31 row removed (function dropped); remaining v3.2 reference — valid            |
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
