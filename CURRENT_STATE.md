# CURRENT_STATE.md

> **Last updated:** 2026-03-05 by GitHub Copilot (session 18)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `test/595-pl-qa-validation` (PR pending)
- **Latest SHA (main):** `171cd64`
- **Open PRs:** 1 (#650 — scoring learn page)

## Recently Shipped (This Session)

| SHA       | Summary                                                                                |
| --------- | -------------------------------------------------------------------------------------- |
| `171cd64` | data(ingredients): enrich PL products with OFF API ingredient and allergen data (#651)  |

## Recently Shipped (Last 7 Days)

| Date       | PR/SHA    | Summary                                                                           |
| ---------- | --------- | --------------------------------------------------------------------------------- |
| 2026-03-05 | #651      | data(ingredients): enrich PL products — 14,392 product_ingredients, 2,872 allergens/traces |
| 2026-03-04 | #649      | chore(docs): copilot-instructions §8, §13 — merge marathon lessons learned       |
| 2026-03-03 | #583      | **MERGED** — Milestone #17: 17 UX issues, 134 files, 4,504 tests                 |

## Known Issues & Broken Items

- [ ] Quality Gate dashboard test still fails — staging DB missing API functions (schema sync needed)
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

## Open Issues (15 total)

| Issue | Priority | Effort | Summary                                                          |
| ----- | -------- | ------ | ---------------------------------------------------------------- |
| #595  | P1       | S      | PL QA validation gate (this session — PR pending)                |
| #589  | P1       | M      | Scoring learn page + v3.3 docs (PR #650 open)                   |
| #603  | P1       | M      | DE ingredient enrichment (blocked by #600/#601, now merged)      |
| #602  | P1       | M      | DE QA validation suite                                           |
| #599  | P1       | S      | Deploy expanded PL dataset to production                         |
| #607  | P1       | S      | Deploy DE dataset to production                                  |
| #614  | P1       | S      | Deploy v3.3 scoring to production                                |
| #598  | P2       | M      | Update CURRENT_STATE + copilot-instructions for PL expansion     |
| #606  | P2       | S      | Update COUNTRY_EXPANSION_GUIDE for DE graduation                 |
| #597  | P2       | M      | Validate MV refresh + API perf at 2K PL products                 |
| #622  | P2       | L      | Comprehensive Playwright E2E for M18–M22 features                |
| #594  | P3       | M      | Add Oils & Vinegars + Spreads & Dips categories for PL           |
| #620  | P3       | L      | Product score trend timeline + history visualization             |
| #563  | Deferred | S      | Sync staging DB schema for quality-gate                          |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework                        |

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)

## Next Planned Work

- [ ] Complete #595 — PL QA validation (this session)
- [ ] Implement #598 — update docs for PL expansion
- [ ] Implement #603 — DE ingredient enrichment (unblocked now)
- [ ] Implement #563 — sync staging DB schema (P2, requires staging access)

## Key Metrics Snapshot

- **Products:** 2,264 active (1,198 PL + 1,066 DE across 19 PL + 19 DE categories)
- **Deprecated products:** 273 (168 PL + 105 DE)
- **QA checks:** 735/735 passing (48 suites)
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,261/2,264 with EAN (99.9%)
- **Ingredient refs:** 2,898 unique ingredients
- **Product-ingredient links:** 14,392
- **Allergen declarations:** 1,391 allergens + 1,481 traces
- **Data completeness (PL):** 97.5% average, 73% minimum, all 19 categories ≥92%
- **Confidence bands (PL):** 1,027 high / 168 medium / 3 low
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 15 (7 P1 + 4 P2 + 2 P3 + 2 deferred) | **Open PRs:** 1
- **Vitest:** 4,504 tests passing (29 skipped)
- **DB migrations:** 186 append-only
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

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
