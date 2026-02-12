# Full Project Audit — Poland Food DB

**Date**: 2026-02-11
**Auditor**: Copilot (automated)
**Commit**: `e054423` (pre-audit baseline)
**Branch**: `main`

> **Note:** This document preserves a historical audit snapshot (2026-02-11) and includes pre-fix findings.
> For current authoritative operational metrics, use `README.md`, `copilot-instructions.md`, and the latest QA output from `RUN_QA.ps1`.

---

## Verified Baseline (live database at latest reconciliation)

> **Updated 2026-02-12** after Baby re-categorization, brand normalization, source provenance backfill, and confidence function fix.

| Metric                                  | Value                                  |
| --------------------------------------- | -------------------------------------- |
| Total products                          | 1,063 (1,025 active + 38 deprecated)  |
| Categories                              | 20                                     |
| Nutrition                               | 1,032 (1:1 with scored products)       |
| ingredient_ref                          | 2,740                                  |
| product_ingredient                      | 12,892 rows across 859 products        |
| product_allergen_info                   | 2,527 (1,218 allergens + 1,309 traces) across 655 products |
| mv_ingredient_frequency                 | 2,740                                  |
| v_product_confidence                    | 1,025                                  |
| EAN coverage                            | 997/1,025 active (97.3%)               |
| Source provenance                        | 1,025/1,025 (100%)                     |
| Score range / avg                       | 4–58 / 23.7                            |
| Confidence (products.confidence)        | 859 verified · 166 estimated · 0 low   |
| CHECK constraints                       | 26 (domain rules, excluding NOT NULLs) |
| FK constraints                          | 14                                     |
| Indexes                                 | 40                                     |
| Migration files                         | 56                                     |
| QA checks                               | 228/228 pass + 29/29 negative tests    |

---

## Audit Checklist

### Must Fix — Data Accuracy

| #   | Item                                                                                       | Status | Notes                                                                                                                                                    |
| --- | ------------------------------------------------------------------------------------------ | :----: | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Update README.md** — 15+ stale refs (560→867, 144→228 checks, category table, QA suites) |   ✅    | Fixed: product counts, category table, QA suite list (9→15), check counts, EAN coverage, project tree, constraint counts, confidence distribution, notes |
| 2   | **Regenerate EAN_VALIDATION_STATUS.md** — entire document stale                            |   ✅    | Fully regenerated: 839/867, per-category table, 28 Żabka items identified, historical note added                                                         |
| 3   | **Update VIEWING_AND_TESTING.md** — QA section incomplete (2/15 suites, 64→228)            |   ✅    | All 15 suites listed with expected output, negative tests added, product counts fixed                                                                    |
| 4   | **Fix RUN_QA.ps1 header** — says "34 checks" for Suite 1, validates 31                     |   ✅    | Fixed header (34→31), added suites 13-15 to docstring, fixed ref integrity (17→18), view consistency (10→12)                                             |
| 5   | **Fix copilot-instructions.md body** — "28/category", "39 migrations", "61/61"             |   ✅    | Fixed: variable counts, 50 migrations, 226/226 checks, full QA file list with 15 suites                                                                  |

### Should Fix — Code Hygiene

| #   | Item                                                                       | Status | Notes                                                                                                     |
| --- | -------------------------------------------------------------------------- | :----: | --------------------------------------------------------------------------------------------------------- |
| 6   | **Remove dead `_clean_text()`** in off_client.py                           |   ✅    | Removed (SQL escaping done in sql_generator._sql_text())                                                  |
| 7   | **Remove unused `resolve_category` import** in run.py                      |   ✅    | False positive — import IS used on line 75. No change needed                                              |
| 8   | **Remove unused `logger` declarations** in sql_generator.py + validator.py |   ✅    | Removed `import logging` + `logger = ...` from both files                                                 |
| 9   | **Extract shared `_slug()`** into pipeline/utils.py                        |   ✅    | Created pipeline/utils.py; updated run.py and sql_generator.py imports; verified all imports OK           |
| 10  | **Fix `sodium_mg` in `fields_populated`** in sql_generator.py              |   ✅    | Removed `sodium_mg`, fixed `carbohydrates_g`→`carbs_g` and `fiber_g`→`fibre_g` to match schema            |
| 11  | **Fix RESEARCH_WORKFLOW.md §8.1** — SQL references removed `sources` table |   ✅    | Rewrote §8.1 with correct `product_sources` schema and INSERT example; fixed EAN coverage 558/560→839/867 |

### Nice to Have — Robustness

| #   | Item                                                                 | Status | Notes                                                                                                                                    |
| --- | -------------------------------------------------------------------- | :----: | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 12  | Close `requests.Session` objects (use `with`) in off_client.py       |   ✅    | Both `search_polish_products` and `fetch_product_by_ean` now use `with _session() as session:`                                           |
| 13  | Guard `int()` conversion of API `count` field in off_client.py       |   ✅    | Added `_safe_int()` helper; both call sites protected                                                                                    |
| 14  | Support EAN-8 in validator.py (or document restriction)              |   ⬜    | Deferred — low priority, standalone script handles both                                                                                  |
| 15  | Refactor RUN_QA.ps1 repetitive suite blocks into function            |   ⬜    | Deferred — cosmetic, ~600 lines but works correctly                                                                                      |
| 16  | Update remaining stale docs (PERFORMANCE_REPORT, DATA_SOURCES, etc.) |   ✅    | Fixed 14 stale refs across 5 docs: PERFORMANCE_REPORT (5), DATA_SOURCES (2), EAN_EXPANSION_PLAN (2), API_CONTRACTS (2), UX_UI_DESIGN (3) |

---

## 1. Schema & Constraints Audit

| Check                                                                 | Result |
| --------------------------------------------------------------------- | ------ |
| All 13 tables present with correct columns                            | ✅ Pass |
| All 14 FK constraints enforced                                        | ✅ Pass |
| 26 CHECK constraints applied (domain values, ranges)                  | ✅ Pass |
| 40 indexes present (covering queries + pg_trgm search)                | ✅ Pass |
| 3 identity columns (products, ingredient_ref, category_ref)           | ✅ Pass |
| 2 views (v_master, v_api_category_overview)                           | ✅ Pass |
| 2 materialized views (mv_ingredient_frequency, v_product_confidence)  | ✅ Pass |
| 14 custom functions + 32 pg_trgm functions                            | ✅ Pass |
| 0 orphaned nutrition rows                                            | ✅ Pass |
| 0 triggers (expected — scoring is pipeline-based)                     | ✅ Pass |

**Verdict**: Schema is clean. No issues.

---

## 2. Data Integrity Audit

| Check                                                                       | Result |
| --------------------------------------------------------------------------- | ------ |
| Every active product has nutrition_facts and scores on products      | ✅ Pass |
| EAN coverage 997/1,025 (97.3%) — 28 without (expected for some)      | ✅ Pass |
| Score range 4–57, avg 24.0 — within 0–100 constraint                        | ✅ Pass |
| 0 null brand / product_type / prep_method / controversies                   | ✅ Pass |
| 477 null store_availability — expected (only Żabka products have this)      | ✅ Pass |
| 161 products without ingredients — expected (not all OFF records have data) | ⚠️ Info |
| 389 products without allergens — expected (same reason)                     | ⚠️ Info |
| Confidence: 858 high / 139 medium / 28 low — reflects enriched ingredient + allergen data | ✅ Pass |

**Verdict**: Data is healthy. Coverage gaps are understood.

---

## 3. QA & Testing Audit

| Check                                                                                                                                                    | Result |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 15 QA suites, 228 checks — 228/228 PASS                                                                                                                  | ✅ Pass |
| 29 negative validation tests — 29/29 CAUGHT                                                                                                              | ✅ Pass |
| Coverage: data integrity, scoring, sources, EAN, API, confidence, quality, refs, views, naming, nutrition, consistency, allergens, servings, ingredients | ✅ Pass |
| RUN_QA.ps1 / RUN_NEGATIVE_TESTS.ps1 — correct exit codes                                                                                                 | ✅ Pass |

**Verdict**: Excellent test coverage.

---

## 4. CI/CD Audit

| Check                                                                    | Result |
| ------------------------------------------------------------------------ | ------ |
| GitHub Actions workflow (qa.yml) present                                 | ✅ Pass |
| Triggers on push to main for db/**, supabase/**, scripts                 | ✅ Pass |
| Postgres 15 service container                                            | ✅ Pass |
| Full pipeline: migrations → pipelines → fixup → QA → threshold → summary | ✅ Pass |
| Fails job on QA failure                                                  | ✅ Pass |
| Job name check count matches (226)                                       | ✅ Pass |

**Verdict**: CI pipeline correctly configured.

---

## 5. Code Quality Audit

> **Historical context:** Findings in this section reflect the original 2026-02-11 audit pass.
> Resolved items are tracked in the checklist above and in the fix log below.

| File                      | Lines | Findings                                                                                 |
| ------------------------- | ----: | ---------------------------------------------------------------------------------------- |
| pipeline/__init__.py      |     0 | ✅ None                                                                                   |
| pipeline/__main__.py      |     5 | ✅ None                                                                                   |
| pipeline/categories.py    |   378 | ⚠️ [Historical] Leaked loop vars; unnecessary `__future__` import                        |
| pipeline/off_client.py    |   487 | ⚠️ [Historical] Dead `_clean_text()`; unclosed sessions; `_round1()` phantom zeros; `int()` crash risk |
| pipeline/run.py           |   232 | ⚠️ [Historical] Unused `resolve_category` import; duplicate `_slug()`; `sys.exit(0)` swallows errors   |
| pipeline/sql_generator.py |   557 | ⚠️ [Historical] Unused logger; `sodium_mg` in fields_populated; duplicate `_slug()`      |
| pipeline/validator.py     |   169 | ⚠️ [Historical] EAN-8 not supported (unlike standalone script); unused logger            |
| validate_eans.py          |   118 | ⚠️ [Historical] Unhandled `FileNotFoundError` for missing docker/psql                    |

**Security**: No vulnerabilities. SQL escaping adequate. No hardcoded secrets.

---

## 6. Scripts & Config Audit

> **Historical context:** Findings here are snapshot observations from the original audit run.
> Current script behavior and check counts are reflected in `RUN_QA.ps1`, `RUN_LOCAL.ps1`, and the latest QA output.

| File                    | Lines | Findings                                               |
| ----------------------- | ----: | ------------------------------------------------------ |
| RUN_LOCAL.ps1           |   207 | ✅ Clean — dry-run, preflight, single-transaction       |
| RUN_REMOTE.ps1          |   251 | ✅ SecureString password, cleared after use             |
| RUN_QA.ps1              |   865 | ⚠️ [Historical] Header mismatch (34 vs 31); ~600 lines copy-paste |
| RUN_NEGATIVE_TESTS.ps1  |    86 | ✅ Clean                                                |
| supabase/config.toml    |   385 | ✅ Standard, no hardcoded secrets                       |
| .env.example            |    12 | ✅ Correct                                              |
| requirements.txt        |     2 | ✅ Sensible version pins                                |
| .editorconfig           |    28 | ✅ Proper                                               |
| .gitignore              |    57 | ✅ Comprehensive                                        |
| .vscode/settings.json   |   215 | ⚠️ [Historical] Duplicate cSpell word; local dev password (expected) |
| .vscode/extensions.json |    21 | ✅ Good extension list                                  |

---

## 7. Documentation Accuracy Audit

| Document                   | Lines | Grade | Key Issues                                             |
| -------------------------- | ----: | :---: | ------------------------------------------------------ |
| README.md                  |   389 | **A** | ✅ Fixed — all 15+ stale references updated             |
| SCORING_METHODOLOGY.md     |   479 | **A** | No issues — version-locked to v3.2                     |
| COUNTRY_EXPANSION_GUIDE.md |   212 | **A** | No issues — future-facing doc                          |
| UX_UI_DESIGN.md            |   761 | **A** | ✅ Fixed — product counts and QA counts updated         |
| API_CONTRACTS.md           |   545 | **A** | ✅ Fixed — product counts updated                       |
| DATA_SOURCES.md            |   431 | **A** | ✅ Fixed — product counts and EAN coverage updated      |
| RESEARCH_WORKFLOW.md       |   537 | **A** | ✅ Fixed — §8.1 SQL rewritten, EAN coverage updated     |
| PERFORMANCE_REPORT.md      |   195 | **A** | ✅ Fixed — all baseline numbers and index count updated |
| VIEWING_AND_TESTING.md     |   196 | **A** | ✅ Fixed — all 15 suites listed, negative tests added   |
| EAN_EXPANSION_PLAN.md      |    18 | **A** | ✅ Fixed — coverage and product counts updated          |
| EAN_VALIDATION_STATUS.md   |    56 | **A** | ✅ Fixed — fully regenerated with per-category data     |
| copilot-instructions.md    |   513 | **A** | ✅ Fixed — all stale numbers corrected                  |

**Root cause**: All staleness from the 560 → 867 → 1,029 expansion and schema consolidation (scores/servings/product_sources merged into products) has been resolved.

---

## Overall Project Grade: **A**

**Strengths**: Schema is rock-solid (0 orphans, all constraints enforced). QA coverage is exceptional (226 + 29 tests, 100% pass rate). CI is properly configured. No security vulnerabilities. All 12 docs are now accurate.

**Remaining (deferred)**: EAN-8 support in validator.py (item 14) and RUN_QA.ps1 refactor (item 15) — both cosmetic / low-risk.

---

## Fix Log

_Fixes are logged below as they are completed._

| #   | Date       | Item                                                  | Files Changed                                                                                                             |
| --- | ---------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 1   | 2026-02-11 | README.md — 15+ stale refs fixed                      | README.md                                                                                                                 |
| 2   | 2026-02-11 | EAN_VALIDATION_STATUS.md — fully regenerated          | docs/EAN_VALIDATION_STATUS.md                                                                                             |
| 3   | 2026-02-11 | VIEWING_AND_TESTING.md — QA section rewritten         | docs/VIEWING_AND_TESTING.md                                                                                               |
| 4   | 2026-02-11 | RUN_QA.ps1 header — check counts fixed                | RUN_QA.ps1                                                                                                                |
| 5   | 2026-02-11 | copilot-instructions.md body — stale numbers fixed    | copilot-instructions.md                                                                                                   |
| 6   | 2026-02-11 | Dead `_clean_text()` removed                          | pipeline/off_client.py                                                                                                    |
| 7   | 2026-02-11 | `resolve_category` import — false positive, no change | —                                                                                                                         |
| 8   | 2026-02-11 | Unused `logger` removed from 2 files                  | pipeline/sql_generator.py, pipeline/validator.py                                                                          |
| 9   | 2026-02-11 | Shared `slug()` extracted to utils.py                 | pipeline/utils.py, pipeline/run.py, pipeline/sql_generator.py                                                             |
| 10  | 2026-02-11 | `sodium_mg` + 2 field names fixed                     | pipeline/sql_generator.py                                                                                                 |
| 11  | 2026-02-11 | RESEARCH_WORKFLOW.md §8.1 rewritten                   | docs/RESEARCH_WORKFLOW.md                                                                                                 |
| 12  | 2026-02-11 | Session context managers added                        | pipeline/off_client.py                                                                                                    |
| 13  | 2026-02-11 | `_safe_int()` guard added                             | pipeline/off_client.py                                                                                                    |
| 16  | 2026-02-11 | 5 remaining docs updated (14 stale refs)              | docs/PERFORMANCE_REPORT.md, docs/DATA_SOURCES.md, docs/EAN_EXPANSION_PLAN.md, docs/API_CONTRACTS.md, docs/UX_UI_DESIGN.md |
| 17  | 2026-02-12 | Final consistency sweep (counts + docs alignment)     | README.md, docs/EAN_VALIDATION_STATUS.md, copilot-instructions.md, docs/FULL_PROJECT_AUDIT.md |
| 18  | 2026-02-13 | Dynamic `data_completeness_pct` (15-checkpoint formula) | supabase/migrations/20260213000800_dynamic_data_completeness.sql, docs/SCORING_METHODOLOGY.md, docs/RESEARCH_WORKFLOW.md, copilot-instructions.md, README.md |



