# Branch Protection Policy — `main`

> **Last updated:** 2026-02-25
> **Applies to:** `ericsocrat/poland-food-db` → `main` branch
> **Canonical source:** This file is the source of truth for branch protection settings.
> If the GitHub UI diverges from this document, restore from here.

---

## Purpose

This document codifies the branch protection rules for the `main` branch so they
are version-controlled, auditable, and reproducible. If the repository is forked,
migrated to another GitHub organization, or protection is accidentally modified,
this file serves as the single source of truth for restoration.

---

## Protection Rules

### Pull Request Requirements

| Setting                              | Value   | Rationale                                       |
| ------------------------------------ | ------- | ----------------------------------------------- |
| Require pull request before merging  | **Yes** | All changes must be reviewed                    |
| Required number of approvals         | **1**   | Single reviewer sufficient for current team size |
| Dismiss stale pull request reviews   | **Yes** | Force re-review after new pushes                |
| Require review from code owners      | **No**  | No CODEOWNERS file currently enforced            |
| Restrict who can dismiss reviews     | **No**  | Default GitHub behavior                          |

### Status Check Requirements

| Setting                             | Value   | Rationale                                    |
| ----------------------------------- | ------- | -------------------------------------------- |
| Require status checks to pass       | **Yes** | No merge without green CI                    |
| Require branches to be up to date   | **Yes** | Prevent merge skew; catch integration issues |

**Required status checks (from `pr-gate.yml` — "PR Gate" workflow):**

| Check Name          | Workflow Job     | What It Validates                          |
| ------------------- | ---------------- | ------------------------------------------ |
| `Typecheck & Lint`  | `static-checks`  | TypeScript compilation + ESLint            |
| `Unit Tests`        | `unit-tests`     | Vitest unit + component tests              |
| `Build`             | `build`          | Next.js production build                   |
| `Playwright Smoke`  | `e2e-smoke`      | Playwright smoke E2E tests (Chromium)      |

**Additional required checks (from other workflows):**

| Check Name       | Workflow              | What It Validates                 |
| ---------------- | --------------------- | --------------------------------- |
| `PR Title Lint`  | `pr-title-lint.yml`   | Conventional Commits title format |

### Merge Strategy

| Setting                    | Value            | Rationale                              |
| -------------------------- | ---------------- | -------------------------------------- |
| Require linear history     | **Yes**          | Clean, bisectable commit history       |
| Allowed merge methods      | **Squash only**  | One commit per PR for clarity          |
| Suggest updating branches  | **Yes**          | Encourage rebasing before merge        |

### Push Restrictions

| Setting                        | Value                    | Rationale                          |
| ------------------------------ | ------------------------ | ---------------------------------- |
| Allow force pushes             | **No**                   | Prevent history rewriting          |
| Allow deletions                | **No**                   | Prevent accidental branch deletion |
| Restrict who can push          | **Repository admins**    | Only admins can bypass PR flow     |
| Include administrators         | **Yes**                  | Admins subject to same rules       |

### Additional Settings

| Setting                          | Value  | Rationale                                  |
| -------------------------------- | ------ | ------------------------------------------ |
| Lock branch                      | **No** | Branch accepts PRs normally                |
| Allow fork syncing               | **No** | Not applicable (private repo operations)   |
| Require signed commits           | **No** | Not enforced yet (future consideration)    |
| Require deployments to succeed   | **No** | Deploy is manual-trigger, not PR-gated     |

---

## Restoration Procedure

If branch protection is accidentally removed or incorrectly modified, follow these
steps to restore from this document:

### Step 1 — Navigate to Settings

```
GitHub → Settings → Branches → Branch protection rules → Edit rule for "main"
```

### Step 2 — Configure Pull Request Requirements

1. ☑ **Require a pull request before merging**
2. Set **Required approving reviews** to `1`
3. ☑ **Dismiss stale pull request approvals when new commits are pushed**
4. ☐ Require review from Code Owners (leave unchecked)

### Step 3 — Configure Status Checks

1. ☑ **Require status checks to pass before merging**
2. ☑ **Require branches to be up to date before merging**
3. Search and add these required checks:
   - `Typecheck & Lint`
   - `Unit Tests`
   - `Build`
   - `Playwright Smoke`
   - `PR Title Lint`

### Step 4 — Configure Merge & Push Rules

1. ☑ **Require linear history**
2. ☐ Allow force pushes (leave unchecked)
3. ☐ Allow deletions (leave unchecked)
4. ☑ **Restrict who can push to matching branches** → Add `ericsocrat` (admin)
5. ☑ **Do not allow bypassing the above settings** (include administrators)

### Step 5 — Save

Click **Save changes** and verify the protection badge appears on the `main` branch.

### Step 6 — Verify

Run a quick test:
- Attempt to push directly to `main` (should be rejected)
- Open a PR (should show required checks)

---

## Audit Schedule

| Check                                 | Frequency  | Method                          |
| ------------------------------------- | ---------- | ------------------------------- |
| Rules match this document             | Quarterly  | Manual comparison with UI       |
| Required checks still exist in CI     | Per PR     | Automatic (GitHub validates)    |
| This document matches current policy  | Per change | PR review of `.github/` changes |

---

## Related Files

| File                              | Purpose                                     |
| --------------------------------- | ------------------------------------------- |
| `.github/workflows/pr-gate.yml`  | Defines the CI jobs that are required checks |
| `.github/workflows/pr-title-lint.yml` | PR title conventional commit validation |
| `.github/workflows/main-gate.yml` | Post-merge CI (coverage, SonarCloud)        |
| `.commitlintrc.json`             | Conventional Commits configuration           |
| `DEPLOYMENT.md`                  | Deploy workflow (manual trigger)             |

---

## Change History

| Date       | Change                                    | Author     |
| ---------- | ----------------------------------------- | ---------- |
| 2026-02-25 | Initial codification from GitHub UI rules | ericsocrat |
