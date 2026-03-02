# CURRENT_STATE.md

> **Last updated:** 2026-03-04 by GitHub Copilot (session 8)
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `chore/rename-to-tryvit-clean` (rename PR — open, awaiting CI)
- **Latest SHA:** `4d83c13` (fix(lint): resolve 59 ruff errors + fix 17 stale doc counts)
- **Open PRs:** [#546](https://github.com/ericsocrat/tryvit/pull/546) — chore(cleanup): rename poland-food-db → TryVit across all source files + 4 dependabot PRs (#547, #549, #551, #552)
- **main SHA:** `3bd6fb3` (origin/main — stable, unmodified)

> ⚠️ **GitHub repo already renamed** — remote is now `https://github.com/ericsocrat/tryvit.git`

## Recently Shipped (This Session)

| SHA       | Summary                                                                    |
| --------- | -------------------------------------------------------------------------- |
| `4d83c13` | fix(lint): resolve 59 ruff errors + fix 17 stale doc counts across 4 files |
| `550d35f` | chore(cleanup): fix workspace debris, dup assets, stale docs               |

## Recently Shipped (Last 7 Days)

| Date       | PR   | Summary                                                                                         |
| ---------- | ---- | ----------------------------------------------------------------------------------------------- |
| 2026-03-04 | #546 | fix(lint): resolve 59 ruff errors + fix 17 stale doc counts (pending commit)                    |
| 2026-03-03 | #546 | chore(cleanup): fix workspace debris, dup assets, stale docs (550d35f)                          |
| 2026-03-03 | #546 | fix(frontend): resolve all ESLint import errors and fix page test (89a3552)                     |
| 2026-03-03 | #546 | chore(config): add copilot workspace context and .github/copilot-instructions.md (f08f80a)      |
| 2026-03-02 | #546 | chore(tooling): elite copilot-instructions §17-§20 rewrite + full dev tooling upgrade (4232c30) |
| 2026-03-02 | #546 | docs(workflow): add agent workflow reference, setup-env.ps1, §17-§20 (d0a2e0f)                  |
| 2026-03-02 | #546 | chore(cleanup): rename poland-food-db → TryVit across all source files (open PR, awaiting CI)   |
| 2026-03-01 | #540 | fix(deps): resolve 6 high-severity npm audit vulnerabilities                                    |

## Known Issues & Broken Items

- [ ] Quality Gate workflow: 7 remaining failures are CI environment/data gaps (admin auth, seed data, test user provisioning). Non-blocking check.
- [ ] Nightly Suite: Intermittent failures (Playwright timeout + data audit exit code 1). Infrastructure/env issue, not code bug.
- [ ] 4 dependabot PRs with **major version bumps** need review: #547, #549, #551, #552 (sonner 2.0, tesseract.js 7.0, @types/node 25)

## CI Gate Status (main branch)

| Gate         | Status | Notes                                                           |
| ------------ | ------ | --------------------------------------------------------------- |
| pr-gate      | ✅      | Typecheck, lint, unit tests, build, Playwright smoke            |
| main-gate    | ✅      | Last runs all success                                           |
| qa.yml       | ✅      | 733/733 checks passing                                          |
| dep-audit    | ✅      | 0 high/critical vulnerabilities                                 |
| python-lint  | ⚠️      | Was failing (59 ruff errors) — fixed this session, pending push |
| quality-gate | ⚠️      | 7 remaining failures are CI env data gaps                       |
| nightly      | ⚠️      | Intermittent timeout failures                                   |

## Open Issues (1 total)

| Issue | Priority | Effort | Summary                                   |
| ----- | -------- | ------ | ----------------------------------------- |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework |

## Next Planned Work

- [ ] Push ruff + doc-count fixes → verify Python Lint CI goes green
- [ ] Merge #546 — rename PR (awaiting CI green)
- [ ] After merge: manual external service display names (Vercel, SonarCloud, Sentry, Supabase)
- [ ] Review 4 dependabot major-bump PRs (#547, #549, #551, #552)

## Key Metrics Snapshot

- **Products:** 1,279 active (20 PL + 5 DE categories)
- **QA checks:** 733/733 passing
- **EAN coverage:** 1,277/1,279 with EAN (99.8%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **Open issues:** 1 | **Open PRs:** 5 (#546 rename + 4 dependabot)
- **Vitest:** 4,420 tests passing (29 skipped), 259 test files
- **DB migrations:** 184 append-only
- **Ruff lint:** 0 errors (59 fixed this session)

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
