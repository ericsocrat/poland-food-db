# CURRENT_STATE.md

> **Last updated:** 2026-03-16 by GitHub Copilot (session 40)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `main` (clean working tree)
- **Latest SHA (main):** `e72635f` (fix(qa): resolve store integrity failures — orphan cleanup, Żabka reclassification, backfill #831)
- **Open PRs:** 0

## Recently Shipped (Sessions 37-40)

| PR   | Summary                                                                                     |
| ---- | ------------------------------------------------------------------------------------------- |
| #830 | chore(state): repo hygiene — branch cleanup, tmp cleanup, state update                      |
| #829 | fix(ci): Playwright timeout fix + documentation reconciliation                              |
| #828 | fix(ci): increase Playwright step timeout and fix dark mode a11y flakiness                  |
| #827 | fix(ci): resolve SonarCloud, Playwright, and Sentry CI failures                             |
| #826 | fix(frontend): remove /80 opacity modifiers failing WCAG AA contrast                        |
| #822 | fix(qa): tighten calorie back-calculation to EU FIC ±20% tolerance (#780)                   |
| #824 | data(pipeline): expand three DE categories (Plant-Based, Snacks, Cereals) (#778)            |
| #820 | feat(scan): premium scanner UX — found preview, timeout, paste, animated scan line (#784)   |
| #806 | feat(frontend): mobile-first product detail redesign — score hero, nutrition bars (#781)    |
| #818 | feat(learn): add healthy-choices topic, prev/next navigation, fix confidence sources (#792) |
| #814 | feat(frontend): Error classification & SectionError component (#791)                        |
| #805 | feat(categories): visual card grid with score distribution (#785)                           |
| #804 | feat(frontend): better alternatives with visual comparison cards (#782)                     |
| #825 | chore(frontend): migrate to Tailwind CSS v4 (#796)                                          |
| #823 | docs(scoring): band calibration investigation — ADR-009 (#779)                              |
| #821 | feat(compare): mobile-optimized comparison with winner verdict (#783)                       |
| #819 | feat(frontend): recipe page UX improvements (#788)                                          |

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                |
| ------------ | ------ | ---------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke |
| main-gate    | ✅      | All passing (d5e7021)                                |
| qa.yml       | ✅      | 756/756 checks passing (48 suites)                   |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                      |
| python-lint  | ✅      | 0 ruff errors                                        |
| quality-gate | ✅      | All checks passing                                   |
| nightly      | ✅      | Data audit passing                                   |

## Open Issues (1 total)

| Issue | Priority | Summary                                   |
| ----- | -------- | ----------------------------------------- |
| #212  | Deferred | Infrastructure Cost Attribution Framework |

All other previously-tracked issues (#683–#722) have been closed.

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)
- **26-PR Merge Marathon:** All 26 open PRs merged in a single session (2026-03-08)

## Next Planned Work

- [x] Playwright timeout fix + docs reconciliation (PR #829 merged)
- [x] Clean up 133 stale remote branches + 43 stale local branches (pruned)
- [x] Clean up 37 tmp-* files from repo root
- [x] Fix store integrity QA failures (migration 20260316000600)
- [ ] Re-run enrichment pipeline to restore product_ingredient/allergen data
- [ ] Deploy latest changes to production (staging validation first)

## Key Metrics Snapshot

- **Products (local DB):** 2,602 active (1,380 PL + 1,222 DE across 21 active + 1 deactivated category)
- **Deprecated products:** 58
- **QA checks:** 756 total (48 suites) — 35 pass, 7 pre-existing failures, 1 warning (local DB)
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,261/2,264 with EAN (99.9%) — local DB
- **Ingredient refs:** 6,279 (local)
- **Product-ingredient links:** 0 (⚠ enrichment data missing — needs re-run)
- **Allergen contains:** 0 (⚠ enrichment data missing — needs re-run)
- **Allergen traces:** 0 (⚠ enrichment data missing — needs re-run)
- **Local ingredient coverage:** 0% (enrichment data missing)
- **Local allergen coverage:** 0% (enrichment data missing)
- **Nutrition coverage (production):** 2,438/2,438 (100%)
- **Frontend test coverage:** ~92% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 1 | **Open PRs:** 0
- **Vitest:** 5,612 tests passing (29 skipped) across 343 test files
- **DB migrations:** 204 append-only (75 applied to production, 4 skipped)
- **pgTAP test files:** 17
- **Ruff lint:** 0 errors
- **GitHub Ruleset:** strict_required_status_checks_policy = true

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

| Suite                       | Failures | Cause                                                                                   |
| --------------------------- | -------- | --------------------------------------------------------------------------------------- |
| Suite 2 (Scoring)           | 1        | Instant-Nudeln Beef DE: 45 vs expected 53-57 (missing enrichment data)                  |
| Suite 6 (Confidence)        | 3        | Mono-modal confidence, verified product count, high-band threshold                       |
| Suite 7 (DataQuality)       | 2        | PL completeness 86.4%, DE completeness 86.6% (below 95% threshold)                      |
| Suite 10 (Naming)           | 2        | Trailing punctuation (24 products), HTML entities (4 products)                           |
| Suite 11 (NutriRange)       | 4        | Calorie back-calc (21), zero-cal macros (1), extreme salt (1), extreme calories (1)      |
| Suite 12 (DataConsist)      | 5        | completeness_pct (5), nutri_score_source (2258), types (4), brands (886)                 |
| Suite 21 (AllergenFilter)   | 1        | Allergen filter returns all products (enrichment data missing)                            |

**Root cause:** Most failures trace to missing enrichment data (product_ingredient = 0, product_allergen_info = 0).
Re-running enrichment pipeline will resolve suites 2, 6, 7, 12, and 21. Suites 10 and 11 are data quality items.

**Previously documented failures now RESOLVED (session 40, migration 20260316000600):**
- Suite 16 (Security): 41/41 pass — self-resolved
- Suite 35 (StoreArch): 12/12 pass — fixed by migration (orphan cleanup, Żabka reclassification, backfill)
- Suite 41 (IdxVerify): 13/13 pass — self-resolved

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
