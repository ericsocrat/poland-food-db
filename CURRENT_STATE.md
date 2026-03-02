# CURRENT_STATE.md

> **Last updated:** 2026-03-02 by GitHub Copilot (session 11)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `main` (clean)
- **Latest SHA:** `2e31184` (deps(actions): bump github-official actions group (#556))
- **Open PRs:** 0

## Recently Shipped (This Session)

| SHA       | Summary                                                                      |
| --------- | ---------------------------------------------------------------------------- |
| `2e31184` | deps(actions): bump github-official actions group — upload-artifact v7 (#556) |

## Recently Shipped (Last 7 Days)

| Date       | PR   | Summary                                                                                  |
| ---------- | ---- | ---------------------------------------------------------------------------------------- |
| 2026-03-02 | #556 | **MERGED** — GitHub Actions bumps (upload-artifact v7, download-artifact, codeql-action) |
| 2026-03-04 | #558 | **MERGED** — QA fixture seeding for quality gate + nightly CI (closes #553)              |
| 2026-03-04 | #546 | **MERGED** — rename poland-food-db → TryVit + 59 ruff fixes + ESLint cleanup + doc fixes |
| 2026-03-01 | #540 | fix(deps): resolve 6 high-severity npm audit vulnerabilities                             |

## Closed PRs (This Session)

| PR   | Action    | Reason                                                                |
| ---- | --------- | --------------------------------------------------------------------- |
| #556 | Merged    | GitHub Actions bumps — clean CI, squash-merged                        |
| #547 | Closed    | Next.js 15→16 — major migration, 8 CI failures, needs dedicated work |
| #551 | Closed    | Tailwind CSS 3→4 — complete rewrite needed                            |
| #552 | Closed    | sonner 1→2, tesseract.js 5→7, @types/node 22→25 — multiple breaking  |

## Known Issues & Broken Items

- [x] **#553** (P1): ~~Quality Gate workflow fails~~ — CLOSED, fixed in PR #558
- [ ] **#554** (P2): Nightly data integrity audit exits with critical findings
- [ ] **#555** (P3): 11 ESLint non-null assertion warnings across 8 frontend files
- [ ] Quality Gate dashboard test still fails — staging DB missing API functions (schema sync needed)

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                              |
| ------------ | ------ | ------------------------------------------------------------------ |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke               |
| main-gate    | ✅      | Last runs all success                                              |
| qa.yml       | ✅      | 733/733 checks passing                                             |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                                    |
| python-lint  | ✅      | 0 ruff errors (59 fixed in #546)                                   |
| quality-gate | ⚠️      | 18/20 pass; dashboard 400s from staging DB schema gap              |
| nightly      | ⚠️      | Fixture seeding fixed; dashboard + data audit still pending (#554) |

## Open Issues (3 total)

| Issue | Priority | Effort | Summary                                                         |
| ----- | -------- | ------ | --------------------------------------------------------------- |
| #554  | P2       | S      | fix(ci): resolve nightly data integrity audit critical findings |
| #555  | P3       | S      | fix(frontend): resolve 11 ESLint non-null assertion warnings    |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework                       |

## Next Planned Work

- [x] Implement #553 — QA fixture data for CI (P1, merged in #558)
- [x] Clean up open PRs — merged #556, closed #547/#551/#552
- [x] Profile README rebrand — Poland Food DB → TryVit
- [x] Fix VS Code extension errors — isort disabled, Tailwind path, reopened correct folder
- [ ] Implement #554 — nightly data audit findings (P2)
- [ ] Implement #555 — ESLint non-null assertions (P3)

## Key Metrics Snapshot

- **Products:** 1,279 active (20 PL + 5 DE categories)
- **QA checks:** 733/733 passing
- **EAN coverage:** 1,277/1,279 with EAN (99.8%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **Open issues:** 3 | **Open PRs:** 0
- **Vitest:** 4,420 tests passing (29 skipped), 259 test files
- **DB migrations:** 184 append-only
- **Ruff lint:** 0 errors
- **Local branches:** 1 (main only)

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
