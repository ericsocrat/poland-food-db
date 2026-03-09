# CURRENT_STATE.md

> **Last updated:** 2026-03-09 by GitHub Copilot (session 36)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `data/717-coverage-thresholds` (feature branch for #717)
- **Latest SHA (main):** `fbfe57f` (PR #771 merged — #721 QA count reconciliation)
- **Open PRs:** #772 (#717 coverage thresholds, auto-merge pending conflict resolution)

## Production Deployment (2026-03-06)

**All 3 P1 deployment issues shipped to production:**
- #599 — Deploy expanded PL dataset ✅ CLOSED
- #607 — Deploy DE dataset ✅ CLOSED
- #614 — Deploy v3.3 scoring ✅ CLOSED

**Production stats:**
- 73/73 migrations applied + 1 enrichment migration (portable name-based JOINs)
- 236/236 pipelines executed successfully
- Pre-deploy backup: `backups/cloud_backup_20260306_172023.dump`

## Recently Shipped (This Session — 26-PR Merge Marathon)

All 26 open PRs merged into main in a single session:

| PR   | Summary                                                                           |
| ---- | --------------------------------------------------------------------------------- |
| #748 | fix(ci): Lighthouse CI server start                                               |
| #724 | fix(frontend): eliminate hardcoded English in error boundaries (#699)              |
| #723 | test(coverage): ratchet coverage + typecheck fix (#718)                            |
| #726 | fix(frontend): action button overflow on 320px mobile (#690)                       |
| #727 | feat(frontend): forgot password flow, password toggle (#700)                       |
| #728 | feat(frontend): landing page server component with SEO metadata (#698)             |
| #729 | fix(frontend): WCAG 2.1 AA accessibility audit fixes (#709)                        |
| #730 | fix(frontend): dark mode color violations (#708)                                   |
| #734 | feat(frontend): unsaved changes dialog + navigation guard (#707)                   |
| #739 | fix(frontend): enforce 44x44px minimum touch targets (#695)                        |
| #744 | feat(frontend): pull-to-refresh feature (#694)                                     |
| #741 | feat(frontend): responsive stats grid (#706)                                       |
| #725 | fix(frontend): restructure category listing nested interactives (#691)             |
| #747 | test(e2e): expand Playwright E2E coverage (#719)                                   |
| #742 | feat(frontend): responsive search action row (#703)                                |
| #733 | fix(frontend): keyboard nav, motion, color indicators (#711)                       |
| #746 | feat(frontend): streamline onboarding 7→3 steps (#701)                             |
| #740 | feat(frontend): swipeable tabs + responsive labels (#693)                           |
| #736 | fix(frontend): remove global overflow-x-hidden (#697)                              |
| #732 | fix(frontend): standardize focus-visible everywhere (#689)                         |
| #745 | fix(frontend): scanner camera permission recovery + scan feedback (#702)           |
| #738 | refactor(frontend): centralize score band colors into utility (#688)               |
| #735 | fix(frontend): sticky save button bar on settings pages (#696)                     |
| #743 | feat(frontend): group MoreDrawer into sections with swipe-to-dismiss (#692)        |
| #737 | fix(frontend): replace sub-10px font sizes with readable alternatives (#686)       |
| #731 | fix(frontend): eliminate 80+ hardcoded Tailwind color classes — CSS tokens (#682)  |

## Known Issues & Broken Items

- [x] Quality Gate CI — **FIXED in #679** (seed allergen tags + invariant stability)
- [x] QA Suite 2 (Scoring): Coca-Cola Zero — score anchor updated to 11-16 in PR #655
- [ ] QA Suite 11 (NutriRange): 9 calorie back-calculation outliers — OFF source data quality
- [x] QA Suite 16 (Security): 2 anon-accessible non-public api_* functions — **FIXED in #662**
- [x] QA Suite 35 (StoreArch): 48 orphan junction rows + 2 backfill coverage gaps — **FIXED**
- [x] QA Suite 41 (IdxVerify): 1 FK column missing supporting index — **FIXED**
- [x] GitHub Ruleset strict policy — temporarily disabled for merge marathon, **RESTORED to true**

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                 |
| ------------ | ------ | ----------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke  |
| main-gate    | ✅      | Last runs all success                                 |
| qa.yml       | ✅      | 752/752 checks passing                                |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                       |
| python-lint  | ✅      | 0 ruff errors                                         |
| quality-gate | ✅      | All checks passing (fixed in #679)                    |
| nightly      | ✅      | Data audit fix shipped (#560)                         |

## Open Issues (16 total)

| Issue | Priority | Summary                                                              |
| ----- | -------- | -------------------------------------------------------------------- |
| #713  | P1       | Create DE Oils & Vinegars + Spreads & Dips pipelines for DE parity   |
| #722  | P2       | Comprehensive CI/CD workflow audit and quality gate tightening        |
| #721  | P2       | Test suite reconciliation — **IN PROGRESS** (QA counts reconciled)   |
| #720  | P2       | Update stale docs — README, CHANGELOG, copilot-instructions          |
| #717  | P2       | Automated data coverage thresholds and regression detection           |
| #712  | P2       | Dark mode visual audit — every page at 320px and 1280px              |
| #705  | P2       | Recipe pages — search, active filter chips, product-ingredient links |
| #704  | P2       | Streamline compare workflow — add-from-anywhere + floating badge     |
| #687  | P2       | Standardize skeleton loading screens across all pages                |
| #685  | P2       | Replace all dark: Tailwind prefixes with CSS variable tokens         |
| #683  | P2       | Unify button pattern — eliminate 3 coexisting approaches             |
| #710  | P3       | PWA manifest completeness and install prompt i18n                    |
| #684  | P3       | Consolidate duplicate dark mode CSS variable blocks                  |
| #212  | Deferred | Infrastructure Cost Attribution Framework                            |

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)
- **26-PR Merge Marathon:** All 26 open PRs merged in a single session (2026-03-08)

## Next Planned Work

- [x] PR #770 merged — enrichment for #714/#715 (eee3a94)
- [x] #721 — Test suite reconciliation (PR #771 merged)
- [x] Implement #717 — automated data coverage thresholds (PR #772 pending)
- [ ] Deploy 26-PR changes to production (staging validation first)
- [ ] Merge PR #771 (#721 QA count reconciliation)

## Key Metrics Snapshot

- **Products (production):** 2,438 active (1,332 PL + 1,102 DE across 22 PL + 21 DE categories)
- **Deprecated products:** 286 (229 PL + 57 DE)
- **QA checks:** 756/756 passing (48 suites) — local DB
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,261/2,264 with EAN (99.9%) — local DB
- **Ingredient refs:** 5,882 (local, post-enrichment)
- **Product-ingredient links:** 31,680 (local, post-enrichment)
- **Allergen contains:** 2,977 (local, post-enrichment)
- **Allergen traces:** 3,092 (local, post-enrichment)
- **Local ingredient coverage:** ~89.8% (post-enrichment)
- **Local allergen coverage:** ~66.7% (post-enrichment)
- **Nutrition coverage (production):** 2,438/2,438 (100%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 16 | **Open PRs:** 0 (PR pending for #721)
- **Vitest:** 5,324 tests passing (29 skipped) across 318 test files
- **DB migrations:** 202 append-only (75 applied to production, 4 skipped)
- **Ruff lint:** 0 errors
- **GitHub Ruleset:** strict_required_status_checks_policy = true (restored)

---

## PL QA Validation Report (#595)

> **Date:** 2026-03-05 | **Branch:** `test/595-pl-qa-validation`

### Validation Results

| Check                      | Result                   | Status |
| -------------------------- | ------------------------ | ------ |
| QA suites (48)             | 43 pass / 5 known issues | ✅      |
| Negative tests             | 23/23 caught             | ✅      |
| EAN checksums              | 2,261/2,261 valid (100%) | ✅      |
| Pipeline structure         | 43 categories verified   | ✅      |
| Enrichment identity        | PASSED                   | ✅      |
| Scoring anchor regression  | 9/9 verified within ±2   | ✅      |
| Data completeness avg (PL) | 97.5%                    | ✅      |
| Min completeness (PL)      | 73% (Instant & Frozen)   | ✅      |

### Scoring Anchor Verification

| Product                     | Expected | Actual | Delta | Status |
| --------------------------- | -------- | ------ | ----- | ------ |
| Piątnica Skyr Naturalny     | ≈5       | 5      | 0     | ✅      |
| Melvit Płatki owsiane       | ≈7       | 7      | 0     | ✅      |
| Tarczyński Kabanosy         | ≈27      | 27     | 0     | ✅      |
| Auchan Tortilla             | ≈29      | 29     | 0     | ✅      |
| Dr. Oetker Pizza 4 sery     | ≈30      | 30     | 0     | ✅      |
| Pudliszki Ketchup łagodny   | ≈18      | 33     | +15   | ⚠️ *    |
| Doritos Sweet Chili         | ≈41      | 41     | 0     | ✅      |
| Indomie Noodles Chicken     | ≈43      | 43     | 0     | ✅      |
| E. Wedel Czekolada Tiramisu | ≈52      | 52     | 0     | ✅      |

\* Pudliszki Ketchup: score shifted from 18→33 after enrichment (new ingredients/allergens added from OFF API). Needs anchor update in copilot-instructions.md §8.19.

### Known QA Failures (Pre-existing, Non-blocking)

| Suite                 | Failures | Cause                                 |
| --------------------- | -------- | ------------------------------------- |
| Suite 11 (NutriRange) | 9        | OFF calorie back-calculation outliers |
| Suite 16 (Security)   | 2        | Anon-accessible non-public functions  |
| Suite 35 (StoreArch)  | 48+2     | Orphan junction rows + backfill gaps  |
| Suite 41 (IdxVerify)  | 1        | FK column missing index               |

---

## DE QA Validation Report (#602)

> **Date:** 2026-03-05 | **Branch:** `test/602-de-qa-validation`

### Validation Results

| Check                         | Result                    | Status |
| ----------------------------- | ------------------------- | ------ |
| Country isolation (11 checks) | 11/11 pass                | ✅      |
| Multi-country consistency     | 16/16 pass (2 bugs fixed) | ✅      |
| Scoring formula (40 checks)   | 39/40 pass (1 pre-exist)  | ✅      |
| DE anchor regression (5 new)  | 5/5 pass                  | ✅      |
| Negative tests                | 23/23 caught              | ✅      |
| EAN checksums                 | 2,261/2,261 valid (100%)  | ✅      |

### Bugs Fixed

| Check                  | Bug                                                              | Fix                                                 |
| ---------------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Multi-country check 1  | Called stale `compute_unhealthiness_v32()` with old params       | Upgraded to v33 with `_g` suffix + protein/fibre    |
| Multi-country check 10 | Stale v32 + wrong column names + non-existent `p.additive_count` | v33 + `_g` columns + LATERAL subquery for additives |

### DE Anchor Products Added (Tests 36-40)

| Product                         | Category     | Score | Range | Status |
| ------------------------------- | ------------ | ----- | ----- | ------ |
| Ritter Sport Edel-Vollmilch     | Sweets (DE)  | 48    | 46-50 | ✅      |
| Alpro Sojadrink, Ungesüßt       | Drinks (DE)  | 8     | 6-10  | ✅      |
| Chipsfrisch ungarisch           | Chips (DE)   | 25    | 23-27 | ✅      |
| Wildlachsfilet / Golden Seafood | Seafood (DE) | 3     | 1-5   | ✅      |
| Instant-Nudeln Beef             | Instant (DE) | 55    | 53-57 | ✅      |

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
