# CURRENT_STATE.md

> **Last updated:** 2026-03-01 20:30 UTC by GitHub Copilot
> **Purpose:** Volatile project status for AI agent context recovery. Read this FIRST at session start.

---

## Active Branch & PR

- **Branch:** `main`
- **Latest SHA:** `a3bb704`
- **Open PRs:** None

## Recently Shipped (Last 7 Days)

| Date       | PR   | Summary                                                                 |
| ---------- | ---- | ----------------------------------------------------------------------- |
| 2026-03-01 | #540 | fix(deps): resolve 6 high-severity npm audit vulnerabilities            |
| 2026-03-01 | #537 | fix(ci): exclude script tags from quality-gate body text checks         |
| 2026-03-01 | #536 | fix(ci): add 5xx network-error allowlist for quality-gate audits        |
| 2026-03-01 | #535 | fix(ci): fix quality-gate browser overrides for mobile/desktop projects |
| 2026-03-01 | #534 | fix(ci): fix quality-gate testDir and auth-route filtering              |
| 2026-03-01 | #533 | docs: add CURRENT_STATE.md live project status tracker (closes #529)    |
| 2026-03-01 | #532 | fix(ci): move secrets out of quality-gate.yml step if condition         |
| 2026-03-01 | #531 | test(coverage): add tests for download, dashboard, product comps        |
| 2026-03-01 | #528 | test(vitest): add tests for LearnCard, SourceCitation, typography       |
| 2026-03-01 | #526 | deps(python): bump ruff from 0.15.2 to 0.15.4                          |
| 2026-03-01 | #525 | fix(ci): add secret validation step to deploy.yml preflight             |
| 2026-03-01 | #524 | test(vitest): fix flaky test timeouts (testTimeout → 15s)               |
| 2026-03-01 | #523 | ci(deploy): fix deploy.yml sanity parser, BACKUP.ps1 xpath              |
| 2026-03-01 | #522 | data(pipeline): import product images from OFF API                      |
| 2026-03-01 | #521 | ci(config): enforce Unix LF line endings for SQL files                  |

## Known Issues & Broken Items

- [ ] Quality Gate workflow: False positives eliminated (#537). Remaining 7 failures are CI environment/data gaps (admin auth, seed data, test user provisioning). Non-blocking check.
- [ ] Nightly Suite: Intermittent failures (Playwright timeout + data audit exit code 1). Infrastructure/env issue, not code bug.

## CI Gate Status (main branch)

| Gate          | Status | Notes                                                                            |
| ------------- | ------ | -------------------------------------------------------------------------------- |
| pr-gate       | ✅      | Typecheck, lint, unit tests, build, Playwright smoke                             |
| main-gate     | ✅      | Last runs all success                                                            |
| qa.yml        | ✅      | 733/733 checks passing                                                           |
| dep-audit     | ✅      | 0 high/critical vulnerabilities (fixed in #540)                                  |
| quality-gate  | ⚠️      | Code fixes complete (#532–#537); 7 remaining failures are CI env data gaps       |
| nightly       | ⚠️      | Intermittent timeout failures                                                    |

## Open Issues (7 total)

| Issue | Priority | Effort | Summary                                              |
| ----- | -------- | ------ | ---------------------------------------------------- |
| #539  | —        | High   | Full project rename — comprehensive migration plan   |
| #530  | P2       | High   | Comprehensive Playwright Functional E2E Suite        |
| #431  | P3       | Medium | Mobile/dark mode/device-framed screenshots           |
| #430  | P3       | High   | 12 polished desktop screenshots                      |
| #404  | P3       | High   | Epic: App Screenshot Mockups                         |
| #212  | Deferred | —      | Infrastructure Cost Attribution Framework            |
| #206  | Deferred | —      | Admin Governance Dashboard Suite                     |

## Next Planned Work

- [ ] #539 — Full project rename (blocked on new name decision)
- [ ] #530 — Comprehensive Playwright Functional E2E Suite (largely obsolete — ~276 E2E tests already exist; needs triage/update)
- [x] Triage #527 (Renovate) — closed, keeping Dependabot
- [x] Fix #483 (minimatch) + serialize-javascript audit — shipped as #540

## Key Metrics Snapshot

- **Products:** 1,279 active (20 PL + 5 DE categories)
- **QA checks:** 733/733 passing
- **EAN coverage:** 1,277/1,279 with EAN (99.8%)
- **Frontend test coverage:** ~88% lines (SonarCloud Quality Gate passing)
- **Open issues:** 7 | **Open PRs:** 0
- **Vitest test files:** 255 co-located unit/component tests
- **DB migrations:** 182 append-only

---

## Maintenance Protocol

- **After every PR merge:** Update "Recently Shipped" and "Active Branch" sections
- **After every session:** Update "Known Issues" and "Next Planned Work"
- **Weekly:** Refresh "Key Metrics Snapshot" and "CI Gate Status"
