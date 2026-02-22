# Environment Strategy — Phase 8

> **Last updated:** 2026-02-22
> **Status:** Active
> **Issue:** #13

---

## Decision: Two-Cloud Mode (Staging + Production)

We maintain two Supabase cloud projects:

- **Production:** `uskvezwftkkudvksmken` — live user-facing data.
- **Staging:** A separate project for pre-production validation, E2E mutation
  testing, and preview deployments.

**Implication:** Phase 8 focuses on:

1. Schema parity via migrations (no dashboard drift).
2. A repeatable seed / import pipeline to bring cloud data in line with the
   expected dataset.
3. Sanity checks + guardrails so CI / scripts cannot accidentally mutate or
   wipe the cloud DB.
4. Staging receives migrations first (via `sync-cloud-db.yml`) before production.

### 8.1 — Staging Supabase Project (Active)

| Field   | Value                                                                                                  |
| ------- | ------------------------------------------------------------------------------------------------------ |
| Status  | **Active** — staging project created and wired into scripts + CI                                       |
| Setup   | Follow [STAGING_SETUP.md](STAGING_SETUP.md) for the step-by-step guide                                 |
| Scripts | `RUN_REMOTE.ps1 -Env staging`, `RUN_SEED.ps1 -Env staging`, `RUN_SANITY.ps1 -Env staging` all work     |

### 8.1A — Cloud Mode Guardrails (Required)

| #   | Task                                                                                                                          | Status |
| --- | ----------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1   | All scripts targeting the cloud require explicit `-Env` parameter and refuse destructive actions by default                    | ✅      |
| 2   | Seed pipeline is idempotent — uses `ON CONFLICT DO UPDATE`, no accidental overwrite                                           | ✅      |
| 3   | CI / E2E uses least-privileged keys and cannot perform destructive operations                                                 | ✅      |
| 4   | All schema changes remain migrations-only — no dashboard drift allowed                                                        | ✅      |
| 5   | `RUN_REMOTE.ps1` requires mandatory `-Env staging` or `-Env production` (no default)                                          | ✅      |
| 6   | `sync-cloud-db.yml` pushes migrations to staging first, then production                                                       | ✅      |

**Acceptance criteria:**

- Running seed / sanity is safe and repeatable against both cloud projects.
- No script / CI job can reset / drop / truncate production without an
  explicit override (`-Force` + `YES` confirmation + branch check).
- Staging receives migrations before production in automated workflows.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Environment Definitions](#2-environment-definitions)
3. [Data Strategy Decision](#3-data-strategy-decision)
4. [Schema Source of Truth](#4-schema-source-of-truth)
5. [Seed / Import Pipeline](#5-seed--import-pipeline)
6. [Vercel ↔ Supabase Mapping](#6-vercel--supabase-mapping)
7. [Secrets & Environment Variables](#7-secrets--environment-variables)
8. [CI / Preview E2E Guidelines](#8-ci--preview-e2e-guidelines)
9. [Deployment Checklists](#9-deployment-checklists)

---

## 1. Overview

This document defines the three-environment strategy for `poland-food-db`:

| Environment    | Purpose                   | Supabase                                      | Vercel                |
| -------------- | ------------------------- | --------------------------------------------- | --------------------- |
| **Local**      | Development & iteration   | Docker (`supabase start`)                     | `next dev`            |
| **Staging**    | Pre-production validation | Cloud `<staging-ref>` (via env var)            | Preview deployments   |
| **Production** | Live user-facing app      | Cloud `uskvezwftkkudvksmken` (single project) | Production deployment |

> **Current status — two-cloud mode:** Local, Staging, and Production all exist.
> Staging is used for pre-production validation and preview deployments.
> See the [Staging Setup Guide](STAGING_SETUP.md) for initial setup instructions.

**Why environments matter (even in single-cloud mode):**

- Local Docker DB and cloud Supabase can drift (different extensions, IDs, auth config).
- CI validates against an ephemeral PostgreSQL 17 container — fast and safe.
- All cloud-mutating operations require explicit `-Env production` + confirmation.
- A staging layer will catch migration/data issues once real users arrive.

---

## 2. Environment Definitions

### 2.1 Local (Docker)

| Setting          | Value                                 |
| ---------------- | ------------------------------------- |
| Supabase CLI     | `supabase start`                      |
| DB host          | `127.0.0.1:54322`                     |
| API URL          | `http://127.0.0.1:54321`              |
| Project ID       | `poland-food-db`                      |
| Docker container | `supabase_db_poland-food-db`          |
| Data load        | `supabase db reset` → `RUN_LOCAL.ps1` |
| QA               | `RUN_QA.ps1`                          |

**Data contents:** Full PL dataset (~1,025 products, 20 categories) + DE micro-pilot (51 products). Fresh auto-increment IDs on every `supabase db reset`.

### 2.2 Staging (Cloud) — Active

> **Status:** Active. See [STAGING_SETUP.md](STAGING_SETUP.md) for setup.

| Setting          | Value                                                   |
| ---------------- | ------------------------------------------------------- |
| Supabase project | `poland-food-db-staging` (ref via `SUPABASE_STAGING_PROJECT_REF`)  |
| DB host          | `db.<staging-ref>.supabase.co:5432`                     |
| API URL          | `https://<staging-ref>.supabase.co`                     |
| Schema source    | `supabase link --project-ref <ref> && supabase db push` |
| Data load        | `RUN_SEED.ps1 -Env staging`                             |

**Data contents:** Will mirror production — full PL dataset + DE micro-pilot.

### 2.3 Production (Cloud)

> All guardrails in §8.1A apply. Migrations go to staging first, then production.

| Setting          | Value                                                                  |
| ---------------- | ---------------------------------------------------------------------- |
| Supabase project | `uskvezwftkkudvksmken`                                                 |
| DB host          | `db.uskvezwftkkudvksmken.supabase.co:5432`                             |
| API URL          | `https://uskvezwftkkudvksmken.supabase.co`                             |
| Schema source    | `supabase link --project-ref uskvezwftkkudvksmken && supabase db push` |
| Data load        | `RUN_SEED.ps1 -Env production` or `RUN_REMOTE.ps1` (both guarded)      |

**Data contents:** Full PL dataset + DE micro-pilot. Production IDs are persistent. User-generated data (`user_preferences`, `user_health_profiles`) exists only here and is **not reproducible** from the pipeline.

---

## 3. Data Strategy Decision

### Decision: **Option A — Full Dataset in All Environments**

Both Staging and Production contain the complete PL dataset (~1,025 products across 20 categories) plus the DE micro-pilot (51 chips products). This ensures:

1. **Immediate usefulness** — the app works identically in staging and production.
2. **Confidence in deployments** — QA checks, confidence thresholds, and scoring formulas are validated against the same data volume.
3. **Realistic E2E** — Playwright tests exercise real category listings, search results, and scoring.

### What each environment contains

| Data Layer              | Local       | Staging     | Production   |
| ----------------------- | ----------- | ----------- | ------------ |
| Reference tables        | ✅           | ✅           | ✅            |
| Products (PL + DE)      | ✅           | ✅           | ✅            |
| Nutrition facts         | ✅           | ✅           | ✅            |
| Ingredients & allergens | ✅           | ✅           | ✅            |
| Scoring & confidence    | ✅           | ✅           | ✅            |
| User preferences        | 🧪 test only | 🧪 test only | ✅ real users |
| User health profiles    | 🧪 test only | 🧪 test only | ✅ real users |

### Data that is **NOT** portable

- `user_preferences` and `user_health_profiles` — these contain real user data in production and test data in staging. They are **never** seeded from pipelines.
- Auto-increment `product_id` values differ between environments. All cross-environment references must use `(country, brand, product_name)` or `ean` as portable keys.

---

## 4. Schema Source of Truth

### Rule: Migrations are the ONLY schema source of truth

```
supabase/migrations/*.sql  →  THE schema definition
```

**Do NOT:**
- Edit schema via the Supabase Dashboard (Table Editor, SQL Editor, etc.)
- Apply ad-hoc `ALTER TABLE` or `CREATE INDEX` outside a migration file
- Use `supabase db diff` as the primary schema management tool

**Do:**
- Add a new `.sql` file under `supabase/migrations/` with the naming convention `YYYYMMDDHHMMSS_description.sql`
- Apply locally via `supabase db reset`
- Apply to staging/production via `supabase db push`

### Verification

After every deployment, run the sanity check pack to verify schema expectations:

```powershell
.\RUN_SANITY.ps1 -Env staging   # Verify staging
.\RUN_SANITY.ps1 -Env production   # Verify production (read-only checks)
```

---

## 5. Seed / Import Pipeline

### Architecture

```
supabase/seed/
  README.md                     ← Usage documentation
  001_reference_data.sql        ← Reference tables (country_ref, category_ref, etc.)

db/pipelines/
  <category>/PIPELINE__*.sql    ← Full product dataset (existing)

scripts/
  RUN_SEED.ps1                  ← Unified seed runner with environment targeting
```

### Seed Execution Order

1. **Schema** — `supabase db push` (or migrations applied manually)
2. **Reference data** — `supabase/seed/001_reference_data.sql`
3. **Product pipelines** — `db/pipelines/*/PIPELINE__*.sql` (all 21 categories)
4. **Post-pipeline fixup** — `db/ci_post_pipeline.sql`
5. **Materialized view refresh** — `refresh_all_materialized_views()`
6. **Sanity checks** — `RUN_SANITY.ps1 -Env <target>`

### Production Guard Rails (§8.1A)

The following guardrails ensure cloud projects cannot be accidentally
mutated or wiped:

#### Script-level guards (`RUN_SEED.ps1`, `RUN_REMOTE.ps1`)

- **Explicit `-Env staging` or `-Env production`** required — no script defaults to a cloud target
- **Interactive "YES" confirmation** — skipped only with `-Force`
- **Interactive "YES" confirmation** — skipped only with `-Force`
- **Branch check** — warns if not on `main` (production seeds should come from main)
- **Row count display** — shows existing product count before execution
- **Idempotent writes** — all pipelines use `ON CONFLICT DO UPDATE` (upsert), never blind `INSERT`

#### CI-level guards

- CI workflows **never** connect to the cloud project — `qa.yml` uses an ephemeral PG17 container
- `ci.yml` uses **anon key** only (read-level) — no service-role mutations possible from Playwright
- No CI job runs `supabase db push`, `supabase db reset`, or any DDL against cloud
- Sanity checks (`RUN_SANITY.ps1`) are **read-only** `SELECT` queries

#### Schema drift prevention

- All schema changes go through `supabase/migrations/*.sql` files
- `supabase db push` is the only mechanism to apply schema to cloud
- Dashboard edits are prohibited — run `supabase db diff` periodically to detect drift

---

## 6. Vercel ↔ Supabase Mapping

> **Two-cloud mode:** Preview deployments point to the staging Supabase
> project. Production deployments point to the production project.

| Vercel Environment | Supabase Target                | `NEXT_PUBLIC_SUPABASE_URL`                 | `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| ------------------ | ------------------------------ | ------------------------------------------ | ------------------------------- |
| Preview            | Staging                        | `https://<staging-ref>.supabase.co`        | Staging anon key                |
| Production         | Production                     | `https://uskvezwftkkudvksmken.supabase.co` | Production anon key             |

### Vercel Configuration

In the Vercel project settings, set environment variables **per environment**:

1. **Production environment:** Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` to production values.
2. **Preview environment:** Set the same variables to staging values.
3. **Development environment:** Not applicable (developers use `.env.local` pointing to local Docker).

### Auth Redirect URLs

In both Staging and Production Supabase projects, configure:

- **Site URL:** The corresponding Vercel domain
- **Redirect URLs:**
  - Production: `https://<production-domain>/auth/callback`
  - Staging: `https://<staging-domain>/auth/callback` + wildcard for Vercel previews (`https://*-ericsocrat.vercel.app/auth/callback`)

---

## 7. Secrets & Environment Variables

### GitHub Repository Secrets

| Secret                              | Purpose                     | Used In       |
| ----------------------------------- | --------------------------- | ------------- |
| `NEXT_PUBLIC_SUPABASE_URL`          | Production Supabase URL     | `ci.yml`      |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY`     | Production anon key         | `ci.yml`      |
| `SUPABASE_SERVICE_ROLE_KEY`         | Production service role key | `ci.yml`      |
| `SUPABASE_URL_STAGING`              | Staging Supabase URL        | Future CI/E2E |
| `SUPABASE_ANON_KEY_STAGING`         | Staging anon key            | Future CI/E2E |
| `SUPABASE_SERVICE_ROLE_KEY_STAGING` | Staging service role key    | Future CI/E2E |
| `SONAR_TOKEN`                       | SonarCloud authentication   | `build.yml`   |

### Local `.env` File

```dotenv
# Remote Supabase database password (used by RUN_REMOTE.ps1 and RUN_SEED.ps1)
SUPABASE_DB_PASSWORD=

# Remote Supabase project reference (for supabase link)
SUPABASE_PROJECT_REF=

# Staging Supabase project reference (for supabase link --project-ref)
SUPABASE_STAGING_PROJECT_REF=

# Staging database password
SUPABASE_STAGING_DB_PASSWORD=
```

---

## 8. CI / Preview E2E Guidelines

### Current CI Architecture

| Workflow           | Backend                           | Purpose                                | Cloud mutation risk                    |
| ------------------ | --------------------------------- | -------------------------------------- | -------------------------------------- |
| `qa.yml`           | Ephemeral PostgreSQL 17 container | Schema + pipeline + 421 QA + 17 sanity | **None** — container only              |
| `ci.yml`           | Production keys (anon-level only) | Lint, build, Playwright E2E            | **Read-only** — anon key cannot mutate |
| `build.yml`        | N/A (build only) + SonarCloud     | Build, unit tests, coverage            | **None**                               |
| `sync-cloud-db.yml`| Staging then Production           | Auto-apply migrations on merge to main | **Schema only** — `supabase db push`   |

### Target CI Architecture (§ issue #141)

| Workflow    | Backend                             | Change                        |
| ----------- | ----------------------------------- | ----------------------------- |
| `qa.yml`    | Ephemeral PostgreSQL 17 container   | No change — fast CI remains   |
| `ci.yml`    | Staging Supabase for Playwright E2E | Swap prod keys → staging keys |
| `build.yml` | N/A                                 | No change                     |

### E2E Safety Rules

1. **CI uses anon key only** — Playwright E2E cannot perform admin/service-role operations.
2. **No CI job targets cloud with DDL** — `supabase db push`, `supabase db reset`, `DROP`, `TRUNCATE` are never run from CI.
3. **Test user cleanup** — E2E tests must clean up any users they create.
4. **Read-only sanity checks** — Only `SELECT`-based sanity checks may run against production from CI.
5. **When staging is active** — Playwright will switch to staging keys once #141 is wired; production keys will be removed from `ci.yml`.

---

## 9. Deployment Checklists

### New Migration Deployment (current workflow)

```
1. ☐ Develop migration locally (supabase db reset to test)
2. ☐ Run RUN_QA.ps1 locally — all 421+ checks pass
3. ☐ Push to branch → CI green (qa.yml + ci.yml + build.yml)
4. ☐ Merge to main → sync-cloud-db.yml applies to staging (if enabled), then production
5. ☐ Run RUN_SANITY.ps1 -Env staging — all checks pass
6. ☐ Run RUN_SANITY.ps1 -Env production — all checks pass
```

### New Migration Deployment (with manual staging-first gate)

```
1. ☐ Develop migration locally (supabase db reset to test)
2. ☐ Run RUN_QA.ps1 locally — all 421+ checks pass
3. ☐ Push to branch → CI green (qa.yml + ci.yml + build.yml)
4. ☐ Merge to main
5. ☐ Apply to staging: supabase link --project-ref <staging-ref> && supabase db push
6. ☐ Run RUN_SANITY.ps1 -Env staging — all checks pass
7. ☐ Apply to production: supabase link --project-ref uskvezwftkkudvksmken && supabase db push
8. ☐ Run RUN_SANITY.ps1 -Env production — all checks pass
```

### Data Pipeline Update

```
1. ☐ Regenerate pipeline SQL (python -m pipeline.run --category ...)
2. ☐ Run RUN_LOCAL.ps1 -Category <name>
3. ☐ Run RUN_QA.ps1 — all checks pass
4. ☐ Push to branch → CI green
5. ☐ Merge to main
6. ☐ Seed production: RUN_SEED.ps1 -Env production -Category <name>
   (or RUN_REMOTE.ps1 -Env production -Category <name>)
7. ☐ Run RUN_SANITY.ps1 -Env production
```

### New Environment Setup (from scratch)

```
1. ☐ Create Supabase project in dashboard
2. ☐ supabase link --project-ref <new-ref>
3. ☐ supabase db push (applies all migrations)
4. ☐ RUN_SEED.ps1 -Env <target> (loads reference data + full dataset)
5. ☐ RUN_SANITY.ps1 -Env <target> (validates everything)
6. ☐ Configure auth redirect URLs in Supabase dashboard
7. ☐ Set environment variables in Vercel (if applicable)
8. ☐ Run Playwright E2E against the new environment
```
