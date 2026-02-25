# Repo Governance Standard

> **Last updated:** 2026-02-25
> **Status:** Active
> **Owner:** @ericsocrat
> **Enforcement:** `copilot-instructions.md` §16 (Repo Hygiene Checklist)

---

## Purpose

This document is the **single source of truth** for repository structure rules,
root cleanliness policy, CI contract integrity, and change-management checklists.

**Relationship to other governance docs:**

| Document                      | Scope                                                         |
| ----------------------------- | ------------------------------------------------------------- |
| **This file**                 | Repo structure, root hygiene, change checklists, CI alignment |
| `GOVERNANCE_BLUEPRINT.md`     | Execution governance for architecture workstreams             |
| `DOCUMENTATION_GOVERNANCE.md` | Doc ownership, update triggers, drift prevention              |
| `copilot-instructions.md`     | AI agent enforcement rules (references this doc)              |
| `MIGRATION_CONVENTIONS.md`    | Database migration safety standards                           |

No duplication — each governs a distinct domain.

---

## 1. Repository Structure Rules

### 1.1 Canonical Directory Layout

```
poland-food-db/
├── frontend/          # Next.js app (src/, e2e/, vitest, playwright)
├── pipeline/          # Python OFF API → SQL generator
├── scripts/           # Standalone utility scripts (validators, backfill tools)
├── db/
│   ├── pipelines/     # Generated SQL files (21 category folders)
│   ├── qa/            # QA test suites (SQL)
│   └── views/         # View definitions (reference copies)
├── supabase/
│   ├── migrations/    # Append-only schema migrations
│   ├── tests/         # pgTAP database tests
│   └── seed/          # Seed data
├── docs/              # All documentation (44+ files)
├── .github/
│   ├── workflows/     # CI/CD pipelines
│   ├── CODEOWNERS     # Review enforcement
│   └── PULL_REQUEST_TEMPLATE.md
└── [root files]       # See §1.3 for allowed list
```

### 1.2 Where Things Live

| Artifact type            | Correct location                   | Never in                                              |
| ------------------------ | ---------------------------------- | ----------------------------------------------------- |
| Frontend code            | `frontend/src/`                    | Root                                                  |
| Frontend tests (unit)    | Co-located `*.test.{ts,tsx}`       | Separate test dir                                     |
| Frontend tests (E2E)     | `frontend/e2e/`                    | Root                                                  |
| Python pipeline code     | `pipeline/`                        | Root                                                  |
| Utility scripts (Python) | `scripts/` or root (if entrypoint) | `frontend/`                                           |
| Database migrations      | `supabase/migrations/`             | `db/`                                                 |
| pgTAP tests              | `supabase/tests/`                  | `db/qa/`                                              |
| SQL QA suites            | `db/qa/`                           | Root                                                  |
| Pipeline SQL output      | `db/pipelines/<category>/`         | Root                                                  |
| Documentation            | `docs/`                            | Root (except README, SECURITY, DEPLOYMENT, CHANGELOG) |
| CI workflows             | `.github/workflows/`               | Root                                                  |
| Build artifacts          | NEVER committed                    | —                                                     |
| Temp/scratch files       | NEVER committed                    | —                                                     |
| Backups                  | `backups/` (gitignored)            | Root                                                  |
| Audit reports            | `audit-reports/` (gitignored)      | Root                                                  |
| Test results             | `test-results/` (gitignored)       | Root                                                  |

### 1.3 Allowed Root Files (Exhaustive)

These files are **permitted** in the repository root:

**Standard project files:**
- `README.md`, `SECURITY.md`, `DEPLOYMENT.md`, `CHANGELOG.md`
- `copilot-instructions.md`
- `.gitignore`, `.editorconfig`, `.commitlintrc.json`
- `.env.example` (never `.env`)
- `sonar-project.properties`
- `requirements.txt`

**Entrypoint scripts (PowerShell):**
- `RUN_LOCAL.ps1`, `RUN_QA.ps1`, `RUN_NEGATIVE_TESTS.ps1`
- `RUN_SANITY.ps1`, `RUN_REMOTE.ps1`, `RUN_SEED.ps1`
- `RUN_DR_DRILL.ps1`, `BACKUP.ps1`

**Entrypoint scripts (Python — validators/tools):**
- `validate_eans.py`, `check_pipeline_structure.py`
- `check_enrichment_identity.py`
- `enrich_ingredients.py`, `fetch_off_category.py`
- `run_data_audit.py`, `test_data_audit.py`

**Everything else in root is a violation.** Specifically forbidden:
- `tmp-*` files (any format)
- `qa_*.json`, `qa-test.json`
- `_func_dump.txt`, `__api_defs.txt`
- `parse_report.py` (should be in `scripts/`)
- `tmp-qa*/` directories
- `test-results/` (gitignored, but must not be committed)
- `.next/`, `node_modules/`, `__pycache__/`, `.pytest_cache/`

### 1.4 Naming Conventions

| Item               | Convention                                | Example                                   |
| ------------------ | ----------------------------------------- | ----------------------------------------- |
| Migration files    | `YYYYMMDDHHMMSS_description.sql`          | `20260225000100_add_feature.sql`          |
| Pipeline SQL       | `PIPELINE__<category>__<NN>_<action>.sql` | `PIPELINE__dairy__01_insert_products.sql` |
| QA suites          | `QA__<domain>.sql`                        | `QA__null_checks.sql`                     |
| Negative tests     | `TEST__<domain>.sql`                      | `TEST__negative_checks.sql`               |
| View files         | `VIEW__<name>.sql`                        | `VIEW__master_product_view.sql`           |
| Docs               | `UPPER_SNAKE_CASE.md`                     | `API_CONTRACTS.md`                        |
| PowerShell scripts | `UPPER_SNAKE.ps1` (root entrypoints)      | `RUN_QA.ps1`                              |
| Python scripts     | `lower_snake.py`                          | `validate_eans.py`                        |

---

## 2. Documentation Update Requirements

### 2.1 Change Checklist (Deterministic)

When files are **added, moved, or removed**, complete this checklist:

- [ ] `README.md` reviewed — does the change affect project overview?
- [ ] `docs/INDEX.md` updated — new doc added, removed doc archived
- [ ] `copilot-instructions.md` updated — schema changes, QA count changes, function list changes
- [ ] `CHANGELOG.md` updated under `[Unreleased]` if user-visible
- [ ] CI workflow path references verified — glob patterns still match
- [ ] `CODEOWNERS` reviewed — new directory has ownership rule
- [ ] `.gitignore` reviewed — new artifact patterns covered

### 2.2 Domain-Specific Update Triggers

Inherited from `DOCUMENTATION_GOVERNANCE.md` §3 — not duplicated here.
See [DOCUMENTATION_GOVERNANCE.md](DOCUMENTATION_GOVERNANCE.md) for the full
code-change → document mapping table.

---

## 3. Root Cleanliness Policy

### 3.1 Rules

1. **No temporary files in root.** All `tmp-*`, scratch, and debug output must be gitignored.
2. **No build artifacts committed.** `.next/`, `node_modules/`, `coverage/`, `test-results/` are always gitignored.
3. **No data dumps in root.** Backups → `backups/`, audit reports → `audit-reports/`.
4. **Tools must not dump to root.** Configure output paths in tool config files.
5. **`.gitignore` is the enforcement mechanism** — see §3.2.

### 3.2 Artifact Directory Policy

| Artifact type      | Correct directory                  | Gitignored? |
| ------------------ | ---------------------------------- | ----------- |
| DB backups         | `backups/`                         | Yes         |
| Audit reports      | `audit-reports/`                   | Yes         |
| Test results       | `test-results/`                    | Yes         |
| QA scratch         | `tmp-qa/`                          | Yes         |
| Playwright reports | `playwright-report/`               | Yes         |
| Coverage output    | `coverage/`                        | Yes         |
| Build output       | `.next/`, `out/`                   | Yes         |
| Lighthouse reports | `lighthouse-reports/`              | Yes         |
| QA screenshots     | `qa_screenshots/`                  | Yes         |
| Temp/scratch       | Use system temp or gitignored dirs | Yes         |
| Sonar issues       | `tmp-sonar-issues.json`            | Yes         |

### 3.3 Post-Workflow Verification

After running normal dev/test flows (`RUN_QA.ps1`, `vitest`, `playwright`, pipeline):
- `git status` should show **zero** untracked files in root (all gitignored)
- `git diff --name-only` should show only intentional changes

---

## 4. CI + Contract Integrity

### 4.1 Required CI Checks (Branch Protection)

| Check               | Workflow            | Blocking? |
| ------------------- | ------------------- | --------- |
| TypeScript compiles | `pr-gate.yml`       | Yes       |
| Lint passes         | `pr-gate.yml`       | Yes       |
| Unit tests pass     | `pr-gate.yml`       | Yes       |
| Build succeeds      | `pr-gate.yml`       | Yes       |
| PR title valid      | `pr-title-lint.yml` | Yes       |
| E2E smoke           | `pr-gate.yml`       | Yes       |
| API contract guard  | `api-contract.yml`  | Yes       |

### 4.2 API Contract Guard Expectations

- Every `api_*` function must have a contract definition in `API_CONTRACTS.md`
- Contract changes must be additive (no removing keys)
- `api-contract.yml` workflow validates generated contracts vs committed
- Breaking changes require `!` suffix in commit type and explicit approval

### 4.3 Deterministic Generation Requirement

All pipeline-generated SQL (`db/pipelines/`) must be reproducible:
- Same input → same output (given same OFF API data)
- Generated files must not contain timestamps or random values
- `check_pipeline_structure.py` validates folder/file structure

### 4.4 Branch Protection Alignment

Recommended branch protection settings for `main`:
- Require PR reviews (CODEOWNERS enforced)
- Require status checks (all blocking checks in §4.1)
- Require linear history (squash merge)
- No force pushes
- No deletions

---

## 5. Copilot Behavioral Enforcement

The following rules are enforced in `copilot-instructions.md` §16:

1. After structural change → update `docs/INDEX.md`, `copilot-instructions.md`
2. After API change → verify `API_CONTRACTS.md`, run contract tests
3. After new files → update relevant docs (per checklist §2.1)
4. **Never commit `tmp-*` artifacts** — verify with `git status` before commit
5. Keep PRs small and scoped (one concern per PR)
6. CI must remain green — run impacted suite before declaring done
7. Do not introduce silent breaking changes to API contracts
8. After scoring changes → run QA regression suite
9. After migration → run `RUN_QA.ps1` (460+ checks)

---

## 6. Review & Maintenance

- **Quarterly review:** Audit root directory, `.gitignore`, and tracked files
- **Pull request:** Every PR must pass the checklist in §2.1
- **Drift detection:** `governance_drift_check()` SQL function monitors scoring, search, and naming conventions
- **Stale doc detection:** `DOCUMENTATION_GOVERNANCE.md` §5 defines the 14-day cadence

---

## Appendix: Governance Audit Trail

| Date       | Auditor     | Findings                                                                                                                        | Actions                                                                                                |
| ---------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 2026-02-25 | @ericsocrat | Initial governance standard created. Root pollution detected (20+ tmp files, 2 committed artifacts). Gitignore gaps identified. | Created this doc, hardened .gitignore, cleaned committed artifacts, added §16 to copilot-instructions. |
