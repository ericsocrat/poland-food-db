# CURRENT_STATE.md

> **Last updated:** 2026-03-04 by GitHub Copilot (session 10)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `fix/qa-fixture-data` (implementing #553)
- **Latest SHA:** `97c9959` (chore(state): update CURRENT_STATE.md after PR #546 merge (#557))
- **Open PRs:** 4 dependabot PRs (#547, #549, #551, #552) — major version bumps needing review

## Recently Shipped (This Session)

| SHA       | Summary                                                                                   |
| --------- | ----------------------------------------------------------------------------------------- |
| `f3b1746` | chore: rename poland-food-db → TryVit + full audit cleanup (#546) — squash-merged to main |

## Recently Shipped (Last 7 Days)

| Date       | PR   | Summary                                                                                  |
| ---------- | ---- | ---------------------------------------------------------------------------------------- |
| 2026-03-04 | #546 | **MERGED** — rename poland-food-db → TryVit + 59 ruff fixes + ESLint cleanup + doc fixes |
| 2026-03-01 | #540 | fix(deps): resolve 6 high-severity npm audit vulnerabilities                             |

## Known Issues & Broken Items

- [ ] **#553** (P1): Quality Gate workflow fails — CI lacks fixture data for product detail page tests
- [ ] **#554** (P2): Nightly data integrity audit exits with critical findings
- [ ] **#555** (P3): 11 ESLint non-null assertion warnings across 8 frontend files
- [ ] 4 dependabot PRs with **major version bumps** need review: #547, #549, #551, #552

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                          |
| ------------ | ------ | -------------------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke           |
| main-gate    | ✅      | Last runs all success                                          |
| qa.yml       | ✅      | 733/733 checks passing                                         |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                                |
| python-lint  | ✅      | 0 ruff errors (59 fixed in #546)                               |
| quality-gate | ⚠️      | 7 failures — CI env data gaps (issue #553)                     |
| nightly      | ⚠️      | Intermittent timeout + data audit failures (issues #553, #554) |

## Open Issues (4 total)

| Issue | Priority | Effort | Summary                                                         |
| ----- | -------- | ------ | --------------------------------------------------------------- |
| #553  | P1       | M      | fix(ci): provision QA fixture data for quality gate and nightly |
| #554  | P2       | S      | fix(ci): resolve nightly data integrity audit critical findings |
| #555  | P3       | S      | fix(frontend): resolve 11 ESLint non-null assertion warnings    |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework                       |

## Next Planned Work

- [x] Implement #553 — QA fixture data for CI (P1, in PR)
- [ ] Implement #554 — nightly data audit findings (P2)
- [ ] Implement #555 — ESLint non-null assertions (P3)
- [ ] Review 4 dependabot major-bump PRs (#547, #549, #551, #552)

## Key Metrics Snapshot

- **Products:** 1,279 active (20 PL + 5 DE categories)
- **QA checks:** 733/733 passing
- **EAN coverage:** 1,277/1,279 with EAN (99.8%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **Open issues:** 4 | **Open PRs:** 4 (dependabot)
- **Vitest:** 4,420 tests passing (29 skipped), 259 test files
- **DB migrations:** 184 append-only
- **Ruff lint:** 0 errors
- **Local branches:** 1 (main only — all stale branches cleaned)

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
