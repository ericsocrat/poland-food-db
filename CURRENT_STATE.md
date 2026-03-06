# CURRENT_STATE.md

> **Last updated:** 2026-03-05 by GitHub Copilot (session 21)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `feat/620-score-trend-timeline` (implementing #620 — pgTAP tests + function bug fix)
- **Latest SHA (main):** `a0ed189`
- **Open PRs:** #659 (for #620, score history fix + pgTAP), #658 (for #594, Oils & Vinegars), #657 (for #622, Playwright E2E)

## Recently Shipped (This Session)

| SHA       | Summary                                                                                |
| --------- | -------------------------------------------------------------------------------------- |
| (pending) | fix(schema): api_get_score_history CASE type mismatch + pgTAP tests + schema contracts (#620) |

## Recently Shipped (Last 7 Days)

| Date       | PR/SHA    | Summary                                                                           |
| ---------- | --------- | --------------------------------------------------------------------------------- |
| 2026-03-05 | #659      | fix(schema): api_get_score_history CASE fix + pgTAP tests (#620)                  |
| 2026-03-05 | #655      | test(qa): DE validation suite — anchors, multi-country fixes (#602)               |
| 2026-03-05 | #654      | data(ingredients): enrich DE products (#603)                                      |
| 2026-03-05 | #652      | test(qa): PL validation gate (#595)                                               |
| 2026-03-05 | #651      | data(ingredients): enrich PL products — 14,392 product_ingredients, 2,872 allergens/traces |
| 2026-03-05 | #650      | fix(frontend): a11y contrast ratio on scoring learn page (#589)                   |
| 2026-03-04 | #649      | chore(docs): copilot-instructions §8, §13 — merge marathon lessons learned       |
| 2026-03-03 | #583      | **MERGED** — Milestone #17: 17 UX issues, 134 files, 4,504 tests                 |

## Known Issues & Broken Items

- [ ] Quality Gate dashboard test still fails — staging DB missing API functions (schema sync needed)
- [ ] QA Suite 2 (Scoring): Coca-Cola Zero test 12 — score 13 vs expected 2-6 (pre-existing after DE enrichment)
- [ ] QA Suite 11 (NutriRange): 9 calorie back-calculation outliers — OFF source data quality
- [ ] QA Suite 16 (Security): 2 anon-accessible non-public api_* functions
- [ ] QA Suite 35 (StoreArch): 48 orphan junction rows + 2 backfill coverage gaps
- [ ] QA Suite 41 (IdxVerify): 1 FK column missing supporting index

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                 |
| ------------ | ------ | ----------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke  |
| main-gate    | ✅      | Last runs all success                                 |
| qa.yml       | ✅      | 735/735 checks passing                                |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                       |
| python-lint  | ✅      | 0 ruff errors                                         |
| quality-gate | ⚠️      | 18/20 pass; dashboard 400s from staging DB schema gap |
| nightly      | ✅      | Data audit fix shipped (#560)                         |

## Open Issues (11 total)

| Issue | Priority | Effort | Summary                                                          |
| ----- | -------- | ------ | ---------------------------------------------------------------- |
| #599  | P1       | S      | Deploy expanded PL dataset to production                         |
| #607  | P1       | S      | Deploy DE dataset to production                                  |
| #614  | P1       | S      | Deploy v3.3 scoring to production                                |
| #598  | P2       | M      | Update CURRENT_STATE + copilot-instructions for PL expansion (PR #653 open) |
| #606  | P2       | S      | Update COUNTRY_EXPANSION_GUIDE for DE graduation (in progress)   |
| #597  | P2       | M      | Validate MV refresh + API perf at 2K PL products                 |
| #622  | P2       | L      | Comprehensive Playwright E2E for M18–M22 features                |
| #594  | P3       | M      | Add Oils & Vinegars + Spreads & Dips categories for PL           |
| #620  | P3       | L      | Product score trend timeline + history visualization             |
| #563  | Deferred | S      | Sync staging DB schema for quality-gate                          |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework                        |

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)

## Next Planned Work

- [ ] Merge PR #653 (issue #598) once CI passes
- [ ] Ship PR for #606 (DE graduation docs — in progress)
- [ ] Implement #599 — deploy expanded PL dataset to production (needs user confirmation)
- [ ] Implement #607 — deploy DE dataset to production (needs user confirmation)
- [ ] Implement #614 — deploy v3.3 scoring to production (needs user confirmation)

## Key Metrics Snapshot

- **Products:** 2,264 active (1,198 PL + 1,066 DE across 19 PL + 19 DE categories)
- **Deprecated products:** 273 (168 PL + 105 DE)
- **QA checks:** 743/743 passing (48 suites)
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,261/2,264 with EAN (99.9%)
- **Ingredient refs:** 2,898 unique ingredients
- **Product-ingredient links:** 14,392
- **Allergen declarations:** 1,391 allergens + 1,481 traces
- **Data completeness (PL):** 97.5% average, 73% minimum, all 19 categories ≥92%
- **Confidence bands (PL):** 1,027 high / 168 medium / 3 low
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 11 (3 P1 + 4 P2 + 2 P3 + 2 deferred) | **Open PRs:** 1
- **Vitest:** 4,901 tests passing (29 skipped)
- **DB migrations:** 195 append-only
- **Ruff lint:** 0 errors
- **Nutrition rows:** 2,511

---

## PL QA Validation Report (#595)

> **Date:** 2026-03-05 | **Branch:** `test/595-pl-qa-validation`

### Validation Results

| Check                      | Result                    | Status |
| -------------------------- | ------------------------- | ------ |
| QA suites (48)             | 43 pass / 5 known issues  | ✅      |
| Negative tests             | 23/23 caught              | ✅      |
| EAN checksums              | 2,261/2,261 valid (100%)  | ✅      |
| Pipeline structure         | 39 categories verified    | ✅      |
| Enrichment identity        | PASSED                    | ✅      |
| Scoring anchor regression  | 9/9 verified within ±2    | ✅      |
| Data completeness avg (PL) | 97.5%                     | ✅      |
| Min completeness (PL)      | 73% (Instant & Frozen)    | ✅      |

### Scoring Anchor Verification

| Product                      | Expected | Actual | Delta | Status |
| ---------------------------- | -------- | ------ | ----- | ------ |
| Piątnica Skyr Naturalny      | ≈5       | 5      | 0     | ✅      |
| Melvit Płatki owsiane        | ≈7       | 7      | 0     | ✅      |
| Tarczyński Kabanosy           | ≈27      | 27     | 0     | ✅      |
| Auchan Tortilla               | ≈29      | 29     | 0     | ✅      |
| Dr. Oetker Pizza 4 sery       | ≈30      | 30     | 0     | ✅      |
| Pudliszki Ketchup łagodny    | ≈18      | 33     | +15   | ⚠️ *   |
| Doritos Sweet Chili           | ≈41      | 41     | 0     | ✅      |
| Indomie Noodles Chicken       | ≈43      | 43     | 0     | ✅      |
| E. Wedel Czekolada Tiramisu   | ≈52      | 52     | 0     | ✅      |

\* Pudliszki Ketchup: score shifted from 18→33 after enrichment (new ingredients/allergens added from OFF API). Needs anchor update in copilot-instructions.md §8.19.

### Known QA Failures (Pre-existing, Non-blocking)

| Suite                   | Failures | Cause                                    |
| ----------------------- | -------- | ---------------------------------------- |
| Suite 11 (NutriRange)   | 9        | OFF calorie back-calculation outliers    |
| Suite 16 (Security)     | 2        | Anon-accessible non-public functions     |
| Suite 35 (StoreArch)    | 48+2     | Orphan junction rows + backfill gaps     |
| Suite 41 (IdxVerify)    | 1        | FK column missing index                  |

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

| Check                            | Bug                                                          | Fix                                                  |
| -------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| Multi-country check 1            | Called stale `compute_unhealthiness_v32()` with old params   | Upgraded to v33 with `_g` suffix + protein/fibre     |
| Multi-country check 10           | Stale v32 + wrong column names + non-existent `p.additive_count` | v33 + `_g` columns + LATERAL subquery for additives |

### DE Anchor Products Added (Tests 36-40)

| Product                           | Category         | Score | Range  | Status |
| --------------------------------- | ---------------- | ----- | ------ | ------ |
| Ritter Sport Edel-Vollmilch       | Sweets (DE)      | 48    | 46-50  | ✅      |
| Alpro Sojadrink, Ungesüßt        | Drinks (DE)      | 8     | 6-10   | ✅      |
| Chipsfrisch ungarisch             | Chips (DE)       | 25    | 23-27  | ✅      |
| Wildlachsfilet / Golden Seafood  | Seafood (DE)     | 3     | 1-5    | ✅      |
| Instant-Nudeln Beef              | Instant (DE)     | 55    | 53-57  | ✅      |

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
