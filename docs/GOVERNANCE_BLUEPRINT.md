# Execution Governance Blueprint

> **Type:** Governance · Architecture · Program Management
> **Scope:** Cross-cutting — governs all architecture issues #183, #185, #189–#193
> **Status:** Active governance document — update as execution progresses
> **Last Updated:** 2026-02-24

---

## Purpose

This blueprint is the **single source of truth** for execution governance across all architecture workstreams. It prevents architectural drift, documentation entropy, schema chaos, hidden coupling, and migration disasters by defining:

1. Formal dependency graph with hidden prerequisite analysis
2. Execution phasing with parallelization guidance
3. Cross-domain coupling risk analysis
4. Risk matrix per workstream
5. Scope discipline with over-engineering detection
6. Governance health metrics
7. Lean execution alternative

**This document governs — it does not implement.**

---

# PART 1 — FORMAL DEPENDENCY GRAPH

## 1.1 Hard Prerequisite Graph

```
Resolution Order:
  Layer 0: #183 (Observability) — zero hard prerequisites
  Layer 1: #185 (Perf Guardrails), #189 (Scoring Engine) — need #183
  Layer 2: #190 (Event Analytics) — needs #183
  Layer 2: #191 (Feature Flags) — needs #183
  Layer 3: #192 (Search) — needs #185
  Layer 3: #193 (Provenance) — needs #189, #183
```

## 1.2 Soft Prerequisite Graph

```
Event Analytics #190 ····soft····> Search #192 (quality metrics)
Event Analytics #190 ····soft····> Provenance #193 (usage tracking)
Feature Flags #191   ····soft····> Search #192 (A/B ranking)
Feature Flags #191   ····soft····> Provenance #193 (gate features)
Feature Flags #191   ····soft····> Scoring #189 (version rollout)
Scoring Engine #189  ····soft····> Search #192 (ranking signals)
Perf Guardrails #185 ····soft····> Event Analytics #190

Soft = can proceed without, but value/safety improves with
```

## 1.3 Parallelization Matrix

| | #183 | #185 | #189 | #190 | #191 | #192 | #193 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **#183 Observability** | — | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **#185 Perf Guardrails** | ⛔ | — | ✅ | ✅ | ✅ | ❎ | ✅ |
| **#189 Scoring Engine** | ⛔ | ✅ | — | ✅ | ✅ | ✅ | ❎ |
| **#190 Event Analytics** | ⛔ | ✅ | ✅ | — | ✅ | ✅ | ✅ |
| **#191 Feature Flags** | ⛔ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| **#192 Search** | ⛔ | ⛔ | ✅ | ✅ | ✅ | — | ✅ |
| **#193 Provenance** | ⛔ | ✅ | ⛔ | ✅ | ✅ | ✅ | — |

**Legend:** ✅ = safe to run in parallel | ⛔ = blocked (hard dep) | ❎ = produces dep

**Safe parallel groups:**
- **Group A:** #183 (alone — foundation)
- **Group B:** #185 + #189 + #190 + #191 (all need only #183)
- **Group C:** #192 + #193 (need Group B outputs)

## 1.4 Foundational vs Expansion Classification

| Issue | Classification | Rationale |
|-------|---------------|-----------|
| #183 Observability | **Foundational** | Required by everything; zero prerequisites |
| #185 Perf Guardrails | **Foundational** | Prevents performance regressions everywhere |
| #189 Scoring Engine | **Foundational** | Core business logic; all health data depends on it |
| #190 Event Analytics | **Strategic** | High ROI but not blocking; enables measurement |
| #191 Feature Flags | **Strategic** | Enables safe rollout but not blocking core function |
| #192 Search | **Expansion** | Current search works at 2.5K; upgrade needed at ~10K |
| #193 Provenance | **Expansion** | Critical for multi-country but current single-country works |

## 1.5 Circular Dependency Detection

**Result: No circular dependencies detected.**

Verified paths:
- #183 → #185 → #192 (linear chain, no back-edge)
- #183 → #189 → #193 (linear chain, no back-edge)
- #190 ↔ #192: soft in both directions (search quality needs events; events track searches) — **resolved by interface contract, not hard dependency**
- #189 ↔ #193: #189 hard-blocks #193, but #193's provenance confidence informs #189's scoring — **resolved by #189 Phase 1 shipping independent scoring, #193 adds provenance overlay later**

**Potential hidden circular risk:** #189 (Scoring) defines `compute_unhealthiness_v32()` → #193 (Provenance) tracks field-level confidence → confidence could feed back into scoring weight adjustments → modifies #189.
**Mitigation:** Provenance confidence is an **input signal** to scoring, not a scoring engine modification. Define interface contract: provenance publishes `field_confidence`, scoring consumes it as optional weight modifier.

## 1.6 Hidden Prerequisite Analysis

### Schema Migration Prerequisites (applies to ALL)

| Hidden Prerequisite | Affects | Action |
|---|---|---|
| Migration ordering strategy | All issues adding tables/columns | Must define migration numbering convention before any workstream ships |
| `search_vector` tsvector column (#192) | products table | Must be added BEFORE GIN index; trigger must handle NULL gracefully |
| `field_provenance` JSONB column (#193) | products table | Must be nullable; backfill is separate migration |
| `scoring_versions` table (#189) | scoring functions | Must exist before `score_category()` references version ID |
| Trigger interaction matrix | #189 (scoring trigger), #192 (search vector trigger), #193 (audit trigger) | **Three triggers on `products` UPDATE — must verify they don't conflict or create ordering issues** |

### Index Strategy Prerequisites

| Index | Issue | Interaction Risk |
|---|---|---|
| GIN on `search_vector` | #192 | Large index; monitor `pg_relation_size()` |
| GIN on `field_provenance` | #193 | JSONB GIN can bloat; consider `jsonb_path_ops` |
| Existing `pg_trgm` GIN on `product_name` | Pre-existing | **Keep alongside tsvector** — they serve different query paths |
| Partial indexes for country | Multi-country | May be needed as country count grows; design for it now |

### RLS Rule Adjustments

| Table | RLS Needed | Reason |
|---|---|---|
| `scoring_versions` (#189) | Read: public, Write: service_role | Users can see versions but not modify |
| `analytics_events` (#190) | Insert: public, Read: admin | Users write events, only admin reads |
| `feature_flags` (#191) | Read: public, Write: admin | Users evaluate flags, admin manages |
| `search_synonyms` (#192) | Read: public, Write: admin | Search uses synonyms, admin curates |
| `data_sources` (#193) | Read: public, Write: admin | Provenance display needs read access |
| `product_change_log` (#193) | Read: admin only | Audit trail is admin-only |
| `data_conflicts` (#193) | Read/write: admin | Conflict resolution is admin function |

### API Contract Updates

All workstreams modify the RPC surface. Must update `docs/API_CONTRACTS.md` atomically with each deployment. Hidden prerequisites:
- Search autocomplete endpoint → needs rate limiting (#182)
- Provenance API → needs RLS enforcement
- Scoring version API → must not leak internal version metadata
- Event ingestion → needs schema validation at edge

### Backfill Requirements (execution order)

1. `field_provenance` backfill (#193) — assign default provenance to all 2,500 products
2. `search_vector` backfill (#192) — generate tsvector for all products
3. `scoring_version_id` backfill (#189) — tag all products with current version v3.2
4. All backfills must be **idempotent** (safe to re-run)
5. All backfills must have **validation queries** (verify row counts, NULL counts)

### Cache Invalidation Strategy

| Cache | Affected By | Strategy |
|---|---|---|
| TanStack Query cache (frontend) | Scoring version changes (#189) | Invalidate `products` queries on version change; staleTime config |
| Supabase Realtime subscriptions | Product updates (all) | Realtime already handles; verify provenance column included |
| CDN / Vercel edge cache | API responses | Set cache headers per endpoint; scoring/search = short TTL |
| PostgreSQL query plan cache | Index changes (#192) | `ANALYZE` after index creation; monitor `pg_stat_user_tables` |

### Trigger Interaction Analysis

**Critical hidden risk:** Three workstreams add triggers on `products`:
1. #189: Scoring re-computation trigger (on nutrition field changes)
2. #192: `search_vector` update trigger (on name/brand/category changes)
3. #193: Audit trail trigger (on any tracked field change)

**Execution order matters:** PostgreSQL fires triggers in **alphabetical order by name** within the same timing (BEFORE/AFTER). Design trigger names to enforce correct order:

```
products_10_search_vector_update  (BEFORE UPDATE — update search_vector)
products_20_provenance_update     (BEFORE UPDATE — update provenance)
products_30_change_audit          (AFTER UPDATE — log changes, sees final state)
products_40_scoring_recompute     (AFTER UPDATE — recompute score if inputs changed)
```

**Guardrail:** Create a trigger interaction test that verifies all four triggers fire correctly on a single product update.

---

# PART 2 — EXECUTION PHASING

## Phase 1: Foundation (Sprints 8–9) — 4 weeks

**Goal:** Establish guardrails and core infrastructure that all subsequent work depends on.

| Workstream | Issue(s) | Parallel? |
|---|---|---|
| Observability core | #183 | ✅ Start immediately |
| Performance guardrails core | #185 | ✅ Start after #183 Week 1 |
| Architecture governance setup | Domain boundaries, naming conventions | ✅ Parallel |
| Documentation audit | Enumerate, classify, detect redundancy | ✅ Parallel |
| Migration governance | Convention, ordering, rollback template | ✅ Parallel |

**Exit criteria:** Error tracking live, P95 baselines established, migration conventions documented, docs audited.

## Phase 2: Stabilization (Sprints 9–11) — 4 weeks

**Goal:** Formalize scoring, begin events + flags.

| Workstream | Issue(s) | Parallel? |
|---|---|---|
| Scoring Engine | #189 Phase 1 (version registry, canonical function) | ✅ |
| Event Analytics | #190 Phase 1 (schema, table, basic ingestion) | ✅ Parallel with #189 |
| Feature Flags | #191 Phase 1 (flag store, evaluation engine) | ✅ Parallel |
| Testing governance | Unit + integration test framework | ✅ Parallel |
| Documentation cleanup | Merge, deprecate, assign owners | ✅ Parallel |

**Exit criteria:** Scoring versioned, events ingesting, flags evaluating, test coverage ≥85% on new code.

## Phase 3: Hardening (Sprints 11–12) — 3 weeks

**Goal:** Search upgrade, provenance foundation, performance validation.

| Workstream | Issue(s) | Parallel? |
|---|---|---|
| Search Architecture | #192 Phase 1 (tsvector, ranking, autocomplete) | ✅ |
| Data Provenance | #193 Phase 1 (source registry, field provenance, audit trail) | ✅ Parallel |
| Performance testing | Search + scoring benchmark suite | ✅ Parallel |
| Frontend governance | Trust badges, scoring version display | ✅ Parallel |

**Exit criteria:** Search on tsvector+trigram hybrid, provenance recording on all new imports, P95 <150ms validated.

## Phase 4: Expansion (Sprints 13–15) — 4 weeks

**Goal:** Multi-language search, conflict resolution, country policies.

| Workstream | Issue(s) | Parallel? |
|---|---|---|
| Search Phase 2 | Multi-language, synonyms | ✅ |
| Provenance Phase 2 | Conflict resolution, freshness engine, country policies | ✅ Parallel |
| Observability expansion | Structured logging, alert escalation | ✅ Parallel |
| Admin dashboards | Provenance health, search quality, scoring versions | ✅ Parallel |

**Exit criteria:** DE search config ready, provenance conflicts auto-resolving, admin dashboards operational.

## Phase 5: Scale (Sprints 16+) — Ongoing

**Goal:** 50K+ product readiness, ML hooks, cost governance.

| Workstream | Issue(s) | Parallel? |
|---|---|---|
| Search Phase 3 | Dedicated search engine evaluation | Conditional |
| Cost monitoring | Query attribution, CI tracking | ✅ |
| ML readiness | Re-ranking hooks, scoring factor ML | Conditional |
| Multi-country launch | DE + CZ data pipelines | Dependent on Phase 4 |

**Exit criteria:** Load tested at 50K, cost per query tracked, DE country live.

## Phase Transitions — Risk Points

| Transition | Risk | Mitigation |
|---|---|---|
| Phase 1 → 2 | Scoring migration changes active function | Feature flag scoring version; A/B test |
| Phase 2 → 3 | Three triggers on products table | Trigger interaction test suite |
| Phase 3 → 4 | Search ranking changes user experience | CTR/MRR monitoring; instant rollback flag |
| Phase 4 → 5 | Scale from 2.5K → 50K products | Load test gates; progressive ingestion |

---

# PART 3 — CROSS-DOMAIN COUPLING RISK ANALYSIS

## 3.1 Search ↔ Scoring

| Dimension | Analysis |
|---|---|
| **Coupling point** | `search_rank()` uses `unhealthiness_score` as ranking signal; scoring changes alter search results |
| **Risk rating** | **High** |
| **Example** | Scoring v3.3 adjusts sugar weight → product scores shift → search ranking reorders without search changes |
| **Decoupling principle** | Search ranking uses a **snapshot** of score, not live computation. Ranking weights in `search_ranking_config` table are independent of scoring formula. |
| **Guardrail** | 1) Search ranking regression test suite runs on every scoring version change. 2) `search_ranking_config` has its own version — never derived from scoring version. 3) Feature flag gates new ranking formulas independently of scoring changes. |

## 3.2 Provenance ↔ Scoring

| Dimension | Analysis |
|---|---|
| **Coupling point** | Provenance confidence per field could influence scoring weight (e.g., low-confidence sugar value weighted less) |
| **Risk rating** | **Medium** |
| **Example** | Field confidence 0.3 on `saturated_fat_100g` → scoring function adjusts weight → score changes → must be re-explained |
| **Decoupling principle** | Provenance publishes `field_confidence` as **read-only metadata**. Scoring **may consume** it as optional input but never modifies provenance. Interface is one-directional: provenance → scoring. |
| **Guardrail** | 1) Scoring function signature includes `p_use_confidence_weights BOOLEAN DEFAULT false` — feature-flagged. 2) Provenance never calls scoring functions. 3) Confidence-weighted scoring is a **separate version** (e.g., v3.3), not a patch to v3.2. |

## 3.3 Events ↔ Search

| Dimension | Analysis |
|---|---|
| **Coupling point** | Search quality metrics (CTR, MRR) depend on event analytics; search relevance feedback loop uses events |
| **Risk rating** | **Medium** |
| **Example** | Event ingestion goes down → search quality metrics stop updating → no visibility into search degradation |
| **Decoupling principle** | Search functions **never query** `analytics_events` at runtime. Quality metrics are computed **asynchronously** (batch aggregation, not inline). Search works identically whether events are flowing or not. |
| **Guardrail** | 1) `search_quality_dashboard()` is read-only, batch, admin-only — never in hot path. 2) Search autocomplete and ranking have zero event dependencies. 3) Event ingestion failure does not degrade search. |

## 3.4 Feature Flags ↔ Contract Validation

| Dimension | Analysis |
|---|---|
| **Coupling point** | Feature flags gate API behavior (e.g., new search ranking, scoring version) — clients must handle both flag states |
| **Risk rating** | **Medium** |
| **Example** | Flag `new_search_ranking` is ON for 50% of users — API returns same structure but different ordering — frontend must handle both gracefully |
| **Decoupling principle** | Flags only control **behavior selection**, never **API shape**. Response contracts are stable regardless of flag state. Flag evaluation happens at **service boundary**, not deep in business logic. |
| **Guardrail** | 1) API contract tests run with all flag combinations (on/off). 2) Flag evaluation is a pure function — no side effects. 3) New flags must pass contract validation before activation. |

## 3.5 Provenance ↔ Multi-Country Expansion

| Dimension | Analysis |
|---|---|
| **Coupling point** | Country data policies (#193) directly control which products are publishable in which country; source priorities differ per country |
| **Risk rating** | **High** |
| **Example** | Adding CZ country → requires CZ-specific freshness policies, source priorities, allergen strictness → if provenance framework isn't ready, CZ launch is blocked or ungoverned |
| **Decoupling principle** | Country is a **configuration dimension**, not a code branch. All provenance logic is country-parameterized. Adding a country = inserting rows into policy tables, not modifying functions. |
| **Guardrail** | 1) `validate_product_for_country()` is the single gate — no bypass. 2) Country policies are data (table rows), not code (if/else). 3) Adding a country requires: policy rows + source mapping + freshness config — all table inserts. 4) Country expansion checklist defined in `COUNTRY_EXPANSION_GUIDE.md`. |

## Coupling Risk Summary

| Pair | Risk | Direction | Decoupled? |
|---|---|---|---|
| Search ↔ Scoring | **High** | Scoring → Search (one-way if guardrails hold) | Needs regression tests |
| Provenance ↔ Scoring | **Medium** | Provenance → Scoring (read-only) | Needs interface contract |
| Events ↔ Search | **Medium** | Events → Search metrics (async only) | Naturally decoupled |
| Flags ↔ Contracts | **Medium** | Flags → Behavior (not shape) | Needs contract tests |
| Provenance ↔ Multi-country | **High** | Config-driven (no code branching) | Needs policy completeness check |

---

# PART 4 — RISK MATRIX

## Workstream Risk Heatmap

| Workstream | Arch Risk | Data Risk | Ops Risk | Security Risk | Complexity Risk |
|---|---|---|---|---|---|
| **#183 Observability** | Low | Low | Medium | Low | Low |
| **#185 Perf Guardrails** | Low | Low | Medium | Low | Medium |
| **#189 Scoring Engine** | Medium | **High** | Medium | Medium | **High** |
| **#190 Event Analytics** | Medium | Medium | Medium | Medium | Medium |
| **#191 Feature Flags** | Medium | Low | Medium | Medium | Medium |
| **#192 Search** | Medium | Medium | Medium | Low | Medium |
| **#193 Provenance** | **High** | **High** | Medium | Medium | **High** |

### Risk Reasoning

**#189 Scoring Engine — Data Risk: High**
Scoring is the core business logic. Version migration errors corrupt health_score for all products. Re-scoring 2,500+ products must be deterministic and idempotent. A scoring regression is a user-trust event.

**#193 Provenance — Arch Risk: High, Data Risk: High, Complexity: High**
Field-level JSONB provenance on every product is a significant schema addition. Audit trail trigger on every UPDATE adds write overhead. Conflict resolution auto-resolution rules must be correct or they silently override good data. The most complex workstream with the most tables (6 new tables).

**#189 Scoring — Complexity: High**
Version registry, re-scoring infrastructure, country profiles, drift detection — this transforms a single function into a versioned system. Most complex behavioral change.

**#183 Observability — Ops Risk: Medium**
Sentry integration, structured logging, correlation IDs affect every request path. Misconfigured error tracking can flood alerts or miss critical errors.

---

# PART 5 — SCOPE DISCIPLINE & OVER-ENGINEERING GUARD

## 5.1 Issue Classification

### Foundational (Execute Immediately)

| Issue | Reason |
|---|---|
| #183 Observability | Cannot debug or monitor anything without it |
| #185 Performance Guardrails | Cannot detect regressions without baselines |
| Migration governance conventions | All workstreams need consistent migration patterns |
| Documentation audit | Must know what exists before governing it |
| Trigger interaction tests | Three triggers on products — must verify safety |
| Scoring versioning (#189 Phase 1 only) | Core business logic needs version control |

### Strategic (High ROI)

| Issue | Reason |
|---|---|
| #189 Scoring Engine (full) | Enables safe score evolution and multi-country scoring |
| #190 Event Analytics (Phase 1) | Enables measurement of everything else |
| #191 Feature Flags (Phase 1) | Enables safe rollout of all other workstreams |
| Domain boundary enforcement | Prevents coupling that becomes expensive to fix later |
| Test coverage governance | Catches regressions before users do |
| Documentation ownership + index | Prevents entropy that slows every future contributor |
| Search tsvector migration (#192 Phase 1) | Significant performance improvement for minimal effort |

### Optional (Future Scaling)

| Issue | Reason |
|---|---|
| #192 Search Phases 2–3 | Multi-language and dedicated search engine only needed at 10K+ |
| #193 Provenance (full) | Conflict resolution and country policies needed for DE expansion, not today |
| Admin dashboards (full) | Nice to have; manual SQL queries work for now |
| Cost monitoring | Important at scale; minimal value at 2.5K products |
| Event anomaly detection | Requires historical baseline that doesn't exist yet |

### Premature (Defer)

| Issue | Reason |
|---|---|
| ML re-ranking hooks | Zero training data; no search quality baselines |
| Dedicated search engine (Typesense/Meilisearch) | PostgreSQL handles 50K easily with proper indexes |
| Feature-level cost attribution | Over-instrumentation at current scale |
| Query cost attribution | Supabase doesn't expose enough cost data today |
| Country-level cost breakdown | Only 1 country; premature |
| Event anomaly ML detection | No baseline data; standard alerting sufficient |

## 5.2 Over-Engineering Risk Detection

### ⚠️ Warning: Provenance Complexity (#193)
The full provenance framework (9 layers, 6 new tables, field-level JSONB, composite confidence with freshness decay) is architecturally sound but **exceeds current operational need**. At 2,500 products in 1 country with 1 primary source (Open Food Facts), the full conflict resolution engine has almost no data to resolve.

**Recommendation:** Implement Layers 1–3 (source registry, field provenance, audit trail) now. Defer Layers 4–9 (freshness engine, conflict resolution, composite confidence, country policies) until multi-country expansion begins.

### ⚠️ Warning: Event Analytics Scope (#190)
Schema registry, event versioning, partition strategy, A/B testing infrastructure — this is a data platform within a data platform. At current traffic (hundreds of users, not thousands), a simple `analytics_events` table with JSONB payload is sufficient.

**Recommendation:** Ship Phase 1 (table + basic ingestion + simple frontend tracker). Defer schema registry, partitioning, and A/B testing until event volume exceeds 100K/month.

### ✅ Appropriate: Scoring Engine (#189)
The scoring engine consolidation is justified. Multiple version histories, 9 scoring factors, country-specific weight profiles — this complexity exists today in the codebase and needs formalization, not invention.

### ✅ Appropriate: Search Upgrade (#192 Phase 1)
tsvector + trigram hybrid is standard PostgreSQL best practice. The autocomplete endpoint is high user value. Multi-language search can wait.

### 🔴 Risk: Governance Layer Itself
**This governance initiative risks creating more issues than the team can execute.** The 7 architecture issues + governance issues + child issues could exceed 60 issues total. This is management overhead for a 1–2 person team.

## 5.3 Lean Mode Roadmap

### 80% Benefit Version (16 issues, 8 weeks)

Execute ONLY:
1. #183 Observability (core only — Sentry + structured logging)
2. #185 Performance Guardrails (P95 baselines + slow query alerts)
3. #189 Scoring Engine Phase 1 (version registry + canonical function)
4. #192 Search Phase 1 (tsvector + ranking model + autocomplete)
5. Migration conventions (document-only — no tool)
6. Documentation audit + index (one-time cleanup)
7. Trigger interaction test
8. Basic test coverage enforcement (≥80% on new code)

### 40% Work Version (8 issues, 4 weeks)

Execute ONLY:
1. #183 Observability (Sentry only)
2. #185 Performance Guardrails (P95 baselines only)
3. #189 Scoring versioning (version table + migration, no re-scoring infra)
4. Documentation index (master list only)
5. Trigger naming convention (document, no enforcement tool)

### Minimal Governance Version (4 issues, 2 weeks)

1. Migration naming convention document
2. Trigger interaction test
3. Documentation index file
4. Scoring version table + current version recorded

## 5.4 Governance Health Metrics

| Metric | Measurement | Target | Alert Threshold |
|---|---|---|---|
| **Documentation entropy rate** | % of docs with `last_updated` > 90 days | <20% | >40% |
| **Migration defect rate** | Failed/rolled-back migrations per quarter | 0 | >1 |
| **Scoring version churn** | Scoring version changes per quarter | ≤2 | >4 |
| **Search regression rate** | CTR drops >10% after changes, per quarter | 0 | >1 |
| **Provenance conflict rate** | Unresolved conflicts >48h / total conflicts | <10% | >25% |
| **Mean Time To Recovery (MTTR)** | Avg time from incident detection to resolution | <30min | >2h |
| **Query regression incidents** | P95 regressions >50% detected per quarter | 0 | >2 |
| **Cross-country divergence** | Country-specific function overrides | 0 | >3 |
| **Test coverage** | Line coverage on changed files | ≥85% | <75% |
| **Trigger interaction failures** | Trigger conflicts detected in CI | 0 | >0 |

## 5.5 Maximum Issue Threshold

| Constraint | Recommendation | Reasoning |
|---|---|---|
| **First execution phase** | **≤12 issues** | Foundation phase must be tight and completable in 4 weeks by 1–2 engineers |
| **Total active issues** | **≤25 at any time** | Beyond 25, issues become noise; prioritization breaks down |
| **Parallel workstreams** | **≤3 simultaneously** | 1–2 person team cannot context-switch across more than 3 workstreams |
| **Child issues per epic** | **≤7** | Beyond 7, decomposition is too fine-grained for actionability |

---

# PART 6 — OVER-ENGINEERING DETECTION

## Explicit Warnings

### ⚠️ WARNING 1: Platform Bloat Risk
The combined architecture issues (#183, #185, #189–#193) plus this governance layer could generate 50+ issues. For a platform with 2,500 products, 1 country, and likely 1–2 engineers, this is **governance overhead exceeding product complexity**. The governance layer must remain a lightweight coordination mechanism, not a bureaucratic framework.

### ⚠️ WARNING 2: Complexity Exceeding Product Maturity
Full provenance (6 tables), full event analytics (partitioned table, schema registry), full feature flags (evaluation engine, targeting rules) — these are patterns from platforms serving millions of users. TryVit serves hundreds. **Ship the simplest version that solves the immediate problem, then iterate.**

### ⚠️ WARNING 3: Workstreams That Should Be Delayed

| Workstream | Delay Until |
|---|---|
| Cost & Resource Monitoring (Workstream G) | Revenue justifies infrastructure spend |
| Event anomaly detection | Event volume >100K/month |
| ML re-ranking | Search CTR baseline established |
| Full conflict resolution | >1 data source per country actively conflicting |
| Country-level cost breakdown | 2+ countries live in production |
| Feature-level cost attribution | Team >3 engineers |

### ⚠️ WARNING 4: Governance Outpacing Business Need
The freshness decay model, composite confidence scoring, and dispute resolution workflow are **designed for a data platform that doesn't exist yet**. Current reality: one person imports data from Open Food Facts via pipeline. The governance should match the operational reality, not the aspirational architecture.

### Recommended Approach
**Execute the Lean Mode (80% benefit) roadmap first.** Revisit the full governance blueprint when:
- Product count exceeds 10,000
- Second country (DE) is actively onboarded
- Team exceeds 2 engineers
- User base exceeds 1,000 monthly actives

---

# PART 7 — OUTPUT SUMMARY

## Deliverables Checklist

| Deliverable | Status | Location |
|---|---|---|
| Full dependency graph | ✅ | Part 1 |
| Hidden prerequisite analysis | ✅ | Part 1.6 |
| Circular dependency detection | ✅ | Part 1.5 |
| Execution roadmap (5 phases) | ✅ | Part 2 |
| Coupling risk analysis (5 pairs) | ✅ | Part 3 |
| Risk heatmap (7 workstreams × 5 dimensions) | ✅ | Part 4 |
| Parallelization matrix | ✅ | Part 1.3 |
| Governance health metrics (10 metrics) | ✅ | Part 5.4 |
| Lean execution alternative (3 tiers) | ✅ | Part 5.3 |
| Maximum recommended issue count | ✅ | Part 5.5 |
| Over-engineering warnings (4 warnings) | ✅ | Part 6 |
| Scope classification (4 tiers) | ✅ | Part 5.1 |
| Governance issue registry | ✅ | Registry below |

## Governance Issue Registry

### Workstream A: Architecture Governance
- [ ] #196 — [GOV-A1] Domain Boundary Enforcement & Ownership Mapping
- [ ] #197 — [GOV-A2] API Contract Registry & RPC Naming Conventions
- [ ] #198 — [GOV-A3] Scoring & Search Formula Registry
- [ ] #199 — [GOV-A4] Version Drift Detection Automation

### Workstream B: Documentation Governance
- [ ] #200 — [GOV-B1] Documentation Audit & Redundancy Elimination
- [ ] #201 — [GOV-B2] Documentation Ownership, Versioning & Master Index Governance

### Workstream C: Testing & QA Governance
- [ ] #202 — [GOV-C1] Deterministic Scoring & Search Test Framework
- [ ] #203 — [GOV-C2] Migration Safety & Trigger Interaction Validation
- [ ] #204 — [GOV-C3] Multi-Country Consistency & Performance Regression Test Suite

### Workstream D: Frontend & Admin Governance
- [ ] #205 — [GOV-D1] Frontend Trust & Transparency Components
- [ ] #206 — [GOV-D2] Admin Governance Dashboard Suite

### Workstream E: Migration & Backfill Governance
- [ ] #207 — [GOV-E1] Migration Convention & Idempotent Design Standard
- [ ] #208 — [GOV-E2] Backfill Orchestration & Validation Framework

### Workstream F: Observability Expansion
- [ ] #210 — [GOV-F1] Structured Log Schema & Error Taxonomy
- [ ] #211 — [GOV-F2] Alert Escalation & Query Regression Detection

### Workstream G: Cost & Resource Monitoring
- [ ] #212 — [GOV-G1] Infrastructure Cost Attribution Framework _(Deferred — premature)_

**Total governance issues: 18** (1 blueprint + 17 child issues across 7 workstreams)

## Cross-Reference to Architecture Issues

| Architecture Issue | Governance Issues That Protect It |
|---|---|
| #183 Observability | #210 (Log Schema), #211 (Alert Escalation) |
| #185 Perf Guardrails | #202 (Test Framework), #203 (Migration Safety), #211 (Query Regression) |
| #189 Scoring Engine | #198 (Formula Registry), #199 (Drift Detection), #202 (Deterministic Tests) |
| #190 Event Analytics | #202 (Test Framework), #210 (Log Schema) |
| #191 Feature Flags | #196 (Domain Boundaries), #197 (Contract Registry) |
| #192 Search | #198 (Formula Registry), #202 (Deterministic Tests), #204 (Multi-Country) |
| #193 Provenance | #204 (Multi-Country), #207 (Migration Convention), #208 (Backfill) |
