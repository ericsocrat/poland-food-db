# CURRENT_STATE.md

> **Last updated:** 2026-03-09 by GitHub Copilot (session 37)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `main`
- **Latest SHA (main):** `17f70c2` — fix(ci): qualify digest() as extensions.digest() (#773) (#797)
- **Open PRs:** PR #798 — fix(ci): add extensions to CI search_path before migrations (#773) — auto-merge set, CI running

## Production Deployment (2026-03-06)

**All 3 P1 deployment issues shipped to production:**
- #599 — Deploy expanded PL dataset ✅ CLOSED
- #607 — Deploy DE dataset ✅ CLOSED
- #614 — Deploy v3.3 scoring ✅ CLOSED

**Production stats:**
- 73/73 migrations applied + 1 enrichment migration (portable name-based JOINs)
- 236/236 pipelines executed successfully
- Pre-deploy backup: `backups/cloud_backup_20260306_172023.dump`

## Recently Shipped

| PR   | Summary                                                                          |
| ---- | -------------------------------------------------------------------------------- |
| #797 | fix(ci): qualify digest() as extensions.digest() (#773)                          |
| #772 | feat(qa): automated data coverage thresholds (#717)                              |
| #771 | chore(qa): reconcile QA suite check counts (#721)                                |
| #770 | data(enrichment): enrich ingredients + allergens for #714/#715                    |
| #748 | fix(ci): Lighthouse CI server start                                              |
| #724–#747 | 26-PR merge marathon — Elite UX v1.0 (accessibility, mobile, design tokens) |

## Known Issues & Broken Items

- [ ] QA Suite 11 (NutriRange): 9 calorie back-calculation outliers — OFF source data quality (tracked as #780)
- [ ] CI `DB Integrity` check: `digest()` schema qualification — fix in PR #798, pending merge
- [x] Quality Gate CI — **FIXED in #679**
- [x] QA Suite 2 (Scoring): Coca-Cola Zero — score anchor updated to 11-16 in PR #655
- [x] QA Suite 16 (Security): 2 anon-accessible non-public api_* functions — **FIXED in #662**
- [x] QA Suite 35 (StoreArch): 48 orphan junction rows + 2 backfill coverage gaps — **FIXED**
- [x] QA Suite 41 (IdxVerify): 1 FK column missing supporting index — **FIXED**
- [x] GitHub Ruleset strict policy — temporarily disabled for merge marathon, **RESTORED to true**

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                    |
| ------------ | ------ | -------------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke     |
| main-gate    | ✅      | Last runs all success                                    |
| qa.yml       | ❌      | DB Integrity broken — `digest()` not in search_path (PR #798 pending) |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                          |
| python-lint  | ✅      | 0 ruff errors                                            |
| quality-gate | ✅      | All checks passing                                       |
| nightly      | ✅      | Data audit fix shipped (#560)                            |

## Open Issues (24 total)

### M29 — CI Stability & Infrastructure Foundation (2 open)

| Issue | Priority | Summary                                                   |
| ----- | -------- | --------------------------------------------------------- |
| #774  | P1       | Reconcile CURRENT_STATE.md — data severely stale          |
| #775  | P2       | Apply safe minor/patch dependency bumps — 8 packages      |

### M30 — Data Platform Perfection PL + DE (5 open)

| Issue | Priority | Summary                                                                 |
| ----- | -------- | ----------------------------------------------------------------------- |
| #776  | P1       | Enrich 262 products missing ingredient data — close the 10.2% gap       |
| #777  | P1       | Enrich 857 products missing allergen data — close the 33.3% safety gap  |
| #778  | P2       | Expand underpopulated DE categories to target density                   |
| #779  | P2       | Investigate scoring band distribution — zero products in Red/Dark Red   |
| #780  | P2       | Resolve 9 NutriRange calorie back-calculation outliers                  |

### M31 — Mobile-First Product Experience Revolution (4 open)

| Issue | Priority | Summary                                                                        |
| ----- | -------- | ------------------------------------------------------------------------------ |
| #781  | P2       | Mobile-first product detail redesign — score hero, nutrition bars              |
| #782  | P2       | Better alternatives with visual comparison cards                               |
| #783  | P2       | Mobile-optimized product comparison — winner verdict, swipe nav                |
| #784  | P2       | Premium barcode scanner UX — haptic feedback, batch mode                       |

### M32 — Mobile-First Navigation & Discovery (4 open)

| Issue | Priority | Summary                                                                        |
| ----- | -------- | ------------------------------------------------------------------------------ |
| #785  | P2       | Category browsing — visual card grid with score distribution                   |
| #786  | P2       | Mobile search experience — instant results, smart filter chips                 |
| #787  | P2       | Dashboard redesign — actionable health insights, quick-win swaps               |
| #788  | P2       | Recipe pages — functional browsing, product-linked ingredients                 |

### M33 — Visual Polish & Design System Maturity (5 open)

| Issue | Priority | Summary                                                                        |
| ----- | -------- | ------------------------------------------------------------------------------ |
| #789  | P2       | Standardize skeleton loading screens — unified primitives, zero CLS            |
| #790  | P2       | Design meaningful empty states for every page                                  |
| #791  | P2       | Consumer-friendly error boundaries — offline banner, component recovery        |
| #792  | P2       | Learn Hub — fix broken rendering, enhance content                              |
| #793  | P2       | Mobile typography, spacing, and visual consistency audit                        |

### M34 — Testing & Quality Assurance Excellence (3 open)

| Issue | Priority | Summary                                                                        |
| ----- | -------- | ------------------------------------------------------------------------------ |
| #794  | P2       | Debug and fix 18 broken Playwright screenshot renders                          |
| #795  | P2       | Comprehensive Playwright E2E test expansion — 7 critical user flow suites      |
| #796  | P3       | Tailwind CSS v4 migration — PostCSS configuration overhaul                     |

### Deferred

| Issue | Priority | Summary                                    |
| ----- | -------- | ------------------------------------------ |
| #212  | Deferred | Infrastructure Cost Attribution Framework  |

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)
- **26-PR Merge Marathon:** All 26 open PRs merged in a single session (2026-03-08)
- **Issue #773 CLOSED:** PR #797 merged (fix migration) + PR #798 pending (CI qa.yml fix)

## Next Planned Work

- [x] #773 — Fix DB Integrity CI (PR #797 merged, PR #798 pending)
- [x] #774 — Reconcile CURRENT_STATE.md (this PR)
- [ ] #775 — Apply safe dependency bumps (8 packages)
- [ ] #776 — Enrich 262 products missing ingredients
- [ ] #777 — Enrich 857 products missing allergens
- [ ] Deploy 26-PR + post-marathon changes to production

## Key Metrics Snapshot

- **Products (local):** 2,576 active (1,373 PL + 1,203 DE across 21 PL + 21 DE categories)
- **Products (production):** 2,438 active (1,332 PL + 1,102 DE across 22 PL + 21 DE categories)
- **Deprecated products:** 37 (27 PL + 10 DE) — local DB
- **QA checks:** 756/756 passing (48 suites) — local DB
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,569/2,576 with EAN (99.7%) — local DB
- **Ingredient refs:** 5,882
- **Product-ingredient links:** 31,680
- **Allergen contains:** 2,977
- **Allergen traces:** 3,092
- **Ingredient coverage:** ~89.8% (262 products missing)
- **Allergen coverage:** ~66.7% (857 products missing)
- **Nutrition coverage:** 2,576/2,576 (100%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 24 | **Open PRs:** 1 (#798)
- **Vitest:** ~5,430 tests across 322 test files
- **DB migrations:** 203 append-only (75 applied to production, 4 skipped)
- **Ruff lint:** 0 errors
- **GitHub Ruleset:** strict_required_status_checks_policy = true

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
