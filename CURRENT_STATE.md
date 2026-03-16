# CURRENT_STATE.md

> **Last updated:** 2026-03-19 by GitHub Copilot (session 48)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `main` (clean working tree)
- **Latest SHA (main):** `a4d7de11` (ci(deps): bump treosh/lighthouse-ci-action #910)
- **Open PRs:** 1 (#904 — Next.js breaking change, needs code fix)

## Recently Shipped (Session 48 — CI Baseline Restoration)

| PR   | Summary                                                                                   |
| ---- | ----------------------------------------------------------------------------------------- |
| #914 | security(frontend): prevent ReDoS in browser UA regex (SonarCloud hotspot S5852)          |
| #907 | chore(deps): bump testing group in frontend (vitest, @testing-library/react, jsdom)       |
| #908 | ci(deps): bump github-official Actions group (4 updates)                                  |
| #910 | ci(deps): bump treosh/lighthouse-ci-action from 12.6.1 to 12.6.2                         |
| #909 | **CLOSED** — @vitejs/plugin-react 6.0.1 requires vite 5-6, project uses vite 7           |
| #911 | **CLOSED** — @eslint/js 10.0.1 requires eslint 10, project uses eslint 9                 |

## Recently Shipped (Session 47 — Post-Deploy Verification)

| PR   | Summary                                                                                  |
| ---- | ---------------------------------------------------------------------------------------- |
| #913 | fix(schema): add 5 scanner event names to analytics constraint (#889)                    |
| #906 | deps(frontend): bump @supabase/supabase-js from 2.99.0 to 2.99.1 (Dependabot auto-merge) |
| #905 | deps(frontend): bump @sentry/nextjs from 10.42.0 to 10.43.0 (Dependabot auto-merge)      |

## Recently Shipped (Session 46 — Sprint Close-Out)

| PR   | Summary                                                                                 |
| ---- | --------------------------------------------------------------------------------------- |
| #912 | data(scoring): populate nutri_score_source across pipeline and existing products (#893) |
| #903 | docs(892): health-goal personalization design spec                                      |
| #902 | docs(ingredients): add ADR-010 ingredient language model (#890)                         |
| #901 | fix(frontend): consolidate above-the-fold trust layout (#891)                           |
| #900 | feat(scanner): add scanner telemetry instrumentation (#889)                             |
| #899 | fix(frontend): move hardcoded English strings into i18n system (#888)                   |
| #898 | fix(onboarding): remove dead health goals, fix threshold comparisons (#887)             |
| #897 | feat(frontend): add localized conflict warnings to score breakdown panel (#886)         |
| #896 | fix(scoring): add signal-conflict detection to api_score_explanation (#885)             |

## Recently Shipped (Session 45 — Infrastructure)

| PR   | Summary                                                                            |
| ---- | ---------------------------------------------------------------------------------- |
| #855 | chore(state): update CURRENT_STATE.md — session 44, PR #854 merged, 207 migrations |
| #856 | chore(state): mark PRODUCTION_URL secret as configured                             |

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                            |
| ------------ | ------ | ---------------------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke             |
| main-gate    | ✅      | All passing                                                      |
| qa.yml       | ✅      | 756/756 checks passing (48 suites)                               |
| deploy.yml   | ✅      | All 209 migrations on production (deployed 2026-03-16T08:24:26Z) |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                                  |
| python-lint  | ✅      | 0 ruff errors                                                    |
| quality-gate | ✅      | Passing — ReDoS hotspot resolved (PR #914)                       |
| nightly      | ✅      | Data audit passing                                               |

## Open Issues (2 total)

| Issue | Priority | Summary                                                                                                     |
| ----- | -------- | ----------------------------------------------------------------------------------------------------------- |
| #889  | P1       | Scanner error taxonomy — observation mode (constraint fix deployed PR #913, window 2026-03-16 → 2026-03-30) |
| #212  | Deferred | Infrastructure Cost Attribution Framework                                                                   |

Sprint issues #885–#895 have been shipped and closed. #889 remains open in observation mode.
**#889 observation window:** Start 2026-03-16T08:24:26Z, checkpoint 2026-03-30, threshold ≥50 `scanner_init_start` events.

## Milestones Completed

- **Milestone #17 — Elite World-Class UX v1.0:** 17/17 issues shipped in PR #583 (squash merged 2026-03-03)
- **26-PR Merge Marathon:** All 26 open PRs merged in a single session (2026-03-08)

## Next Planned Work

- [x] Playwright timeout fix + docs reconciliation (PR #829 merged)
- [x] Clean up 133 stale remote branches + 43 stale local branches (pruned)
- [x] Clean up 37 tmp-* files from repo root
- [x] Fix store integrity QA failures (migration 20260316000600)
- [x] Restore enrichment data (migration 20260313000100 BEGIN/COMMIT fix + direct piping)
- [x] Re-score all PL + DE categories after enrichment restoration
- [x] Clean up orphan ingredient_refs + deduplicate case-variant positions (migration 20260316000700)
- [x] Ship enrichment fix as PR (PR #833)
- [x] Fix 4 pre-existing QA failures — Suites 7, 10, 11, 12 (PR #834 — 47/48 pass)
- [x] Deploy latest changes to production — 205 migrations applied (PRs #835-#840)
- [x] UX Audit — 74 Playwright screenshots + 20 user screenshots analyzed → 4 issues created (#842-#845)
- [x] P0 fix: Score display consistency — TryVit Score (100−unhealthiness) for filters/stats (PR #846)
- [x] P1 fix: Category truncation, product not-found empty state, settings tab overflow (PR #847)
- [x] P2 fix: Language flags removed, scanner default to manual, QuickWin null guard, 403 page enhanced (PR #848)
- [x] P3 fix: Filter skeleton loader, category grid cleanup (PR #849)
- [x] Fix 7 broken production functions — STABLE→VOLATILE + watchlist alias (PR #854)
- [x] Configure PRODUCTION_URL secret for health endpoint verification
- [x] Set up staging environment — project `rxtaicdpnaqigowdbmsb` (eu-west-1), 207 migrations, seeded, secrets configured
- [x] Ship sprint issues #885–#895 (PRs #896–#903, #912)
- [x] Deploy migrations 20260319000400 + 20260319000500 to production (deployed 2026-03-16T08:24:26Z)
- [x] Verify scanner event constraint fix in production (PR #913 — all 3 layers confirmed)
- [x] Verify nutri_score_source backfill in production (#893 — 2,197 off_computed + 238 unknown + 3 manual)
- [ ] Review #889 observation data after 2026-03-30 checkpoint (see issue comment)
- [ ] Fix PR #904 — Next.js breaking change (remove `eslint` property from NextConfig)

## Staging Environment

- **Project:** `rxtaicdpnaqigowdbmsb` (`tryvit-staging`, eu-west-1)
- **Status:** ACTIVE_HEALTHY — schema deployed, reference data seeded, no product data
- **URL:** `https://rxtaicdpnaqigowdbmsb.supabase.co`
- **Schema:** 74 tables, 20 views, 4 materialized views, 257 functions, 128 RLS policies, 33 triggers
- **Reference data:** 2 countries, 22 categories, 7 nutri_score, 4 concern_tiers
- **GitHub secrets:** `SUPABASE_STAGING_PROJECT_REF`, `SUPABASE_URL_STAGING`, `SUPABASE_ANON_KEY_STAGING`, `SUPABASE_SERVICE_ROLE_KEY_STAGING`, `STAGING_URL`
- **GitHub variable:** `STAGING_ENABLED=true`
- **CLI note:** When running `supabase db push` against staging, set `$env:SUPABASE_DB_PASSWORD` to the staging password first — the `--password` flag does NOT override the env var.

## Key Metrics Snapshot

- **Products (local DB):** 2,602 active (1,380 PL + 1,222 DE across 21 active + 1 deactivated category)
- **Deprecated products:** 58
- **QA checks:** 756 total (48 suites) — 47 pass, 1 pre-existing failure (Suite 11 NutriRange), 1 warning (local DB)
- **Negative tests:** 23/23 caught
- **EAN coverage:** 2,261/2,264 with EAN (99.9%) — local DB
- **Ingredient refs:** 3,100 (local, after orphan cleanup from 6,279)
- **Product-ingredient links:** 14,166 (restored from 0)
- **Allergen contains:** 1,395 (restored from 0)
- **Allergen traces:** 1,465 (restored from 0)
- **Local ingredient coverage:** PL 58.4%, DE 16.3% (OFF API data gaps)
- **Local allergen coverage:** PL 44.5%, DE 13.3% (OFF API data gaps)
- **Nutrition coverage (production):** 2,438/2,438 (100%)
- **Frontend test coverage:** ~92% lines (SonarCloud Quality Gate passing)
- **ESLint warnings:** 0
- **Open issues:** 2 | **Open PRs:** 1 (Next.js breaking change)
- **Vitest:** 5,614 tests passing (29 skipped) across 343 test files
- **DB migrations:** 209 append-only (all 209 applied to production)
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

| Suite                  | Failures | Cause                                                                                                                                              |
| ---------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Suite 7 (DataQuality)  | 6        | Ingredient coverage PL 58.4%/DE 16.3%, allergen coverage PL 44.5%/DE 13.3%, completeness PL 94%/DE 88.7% (all below threshold — OFF API data gaps) |
| Suite 10 (Naming)      | 2        | Trailing punctuation (24 products), HTML entities (4 products)                                                                                     |
| Suite 11 (NutriRange)  | 4        | Calorie back-calc (21), zero-cal macros (1), extreme salt (1), extreme calories (1)                                                                |
| Suite 12 (DataConsist) | 4        | nutri_score_source (fixed by PR #912), types (2), brands (886)                                                                                     |

**Root cause:** Suite 7 failures are OFF API data coverage gaps (enrichment data only available for ~58% PL, ~16% DE products).
Suites 10, 11, 12 are pre-existing source data quality issues unrelated to enrichment.

**Session 41 fixes (migration 20260316000700 + re-scoring):**
- Suite 1 (Integrity): PASS — 3,181 orphan ingredient_ref entries removed + 18 duplicate positions deduped
- Suite 2 (Scoring): PASS — Instant-Nudeln Beef DE anchor updated (53-57 → 43-47)
- Suite 6 (Confidence): PASS — resolved by enrichment restoration
- Suite 13 (Allergen): PASS — resolved by enrichment restoration
- Suite 15 (IngredQual): PASS — resolved by orphan cleanup
- Suite 21 (AllergenFilter): PASS — resolved by enrichment restoration
- Suite 31 (Determinism): PASS — resolved by post-dedup re-scoring
- Suite 32 (MultiCountry): PASS — resolved by DE re-scoring + post-dedup re-scoring

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
| Instant-Nudeln Beef             | Instant (DE) | 45    | 43-47 | ✅      |

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
