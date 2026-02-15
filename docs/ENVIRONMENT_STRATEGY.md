# Environment Strategy — Phase 8

> **Last updated:** 2026-02-15
> **Status:** Active
> **Issue:** #13

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

| Environment    | Purpose                   | Supabase                  | Vercel                |
| -------------- | ------------------------- | ------------------------- | --------------------- |
| **Local**      | Development & iteration   | Docker (`supabase start`) | `next dev`            |
| **Staging**    | Pre-production validation | Cloud project (staging)   | Preview deployments   |
| **Production** | Live user-facing app      | Cloud project (prod)      | Production deployment |

**Why three environments?**

- Local Docker DB and cloud Supabase can drift (different extensions, IDs, auth config).
- CI currently validates against an ephemeral PostgreSQL 17 container — not a Supabase instance.
- Preview deployments need a backend; pointing them at production is dangerous.
- A staging layer catches migration/data issues before they reach real users.

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

### 2.2 Staging (Cloud)

| Setting          | Value                                                   |
| ---------------- | ------------------------------------------------------- |
| Supabase project | `poland-food-db-staging` *(to be created)*              |
| DB host          | `db.<staging-ref>.supabase.co:5432`                     |
| API URL          | `https://<staging-ref>.supabase.co`                     |
| Schema source    | `supabase link --project-ref <ref> && supabase db push` |
| Data load        | `RUN_SEED.ps1 -Env staging`                             |

**Data contents:** Full PL dataset + DE micro-pilot (same as local). Staging is a mirror of production data to ensure confidence in deployments.

### 2.3 Production (Cloud)

| Setting          | Value                                                                  |
| ---------------- | ---------------------------------------------------------------------- |
| Supabase project | `uskvezwftkkudvksmken`                                                 |
| DB host          | `db.uskvezwftkkudvksmken.supabase.co:5432`                             |
| API URL          | `https://uskvezwftkkudvksmken.supabase.co`                             |
| Schema source    | `supabase link --project-ref uskvezwftkkudvksmken && supabase db push` |
| Data load        | `RUN_REMOTE.ps1 -Force` (manual, guarded)                              |

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

### Production Guard Rails

The `RUN_SEED.ps1` script enforces safety for production:

- **Explicit `-Env prod` flag** required (no default to production)
- **Interactive "YES" confirmation** (unless `-Force` is passed)
- **Branch check** — refuses to run against production unless on `main` branch
- **Row count threshold** — warns if products already exist (prevents accidental double-load)

---

## 6. Vercel ↔ Supabase Mapping

| Vercel Environment | Supabase Target | `NEXT_PUBLIC_SUPABASE_URL`                 | `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| ------------------ | --------------- | ------------------------------------------ | ------------------------------- |
| Preview            | Staging         | `https://<staging-ref>.supabase.co`        | Staging anon key                |
| Production         | Production      | `https://uskvezwftkkudvksmken.supabase.co` | Production anon key             |

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

| Workflow    | Backend                                           | Purpose                                |
| ----------- | ------------------------------------------------- | -------------------------------------- |
| `qa.yml`    | Ephemeral PostgreSQL 17 container                 | Schema + pipeline + 362 QA checks      |
| `ci.yml`    | N/A (build only) + Production keys for Playwright | Lint, build, E2E                       |
| `build.yml` | N/A (build only) + SonarCloud                     | Build, unit tests, coverage, SonarQube |

### Target CI Architecture (with Staging)

| Workflow    | Backend                             | Change                        |
| ----------- | ----------------------------------- | ----------------------------- |
| `qa.yml`    | Ephemeral PostgreSQL 17 container   | No change — fast CI remains   |
| `ci.yml`    | Staging Supabase for Playwright E2E | Swap prod keys → staging keys |
| `build.yml` | N/A                                 | No change                     |

### E2E Safety Rules

1. **Never point CI to production** — Playwright E2E tests must use staging Supabase.
2. **Test user cleanup** — E2E tests must clean up any users they create in staging.
3. **No admin operations** — CI must not run `supabase db push`, data pipelines, or schema modifications against any cloud project.
4. **Read-only sanity checks** — Only `SELECT`-based sanity checks may run against production from CI.

---

## 9. Deployment Checklists

### New Migration Deployment

```
1. ☐ Develop migration locally (supabase db reset to test)
2. ☐ Run RUN_QA.ps1 locally — all 362+ checks pass
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
6. ☐ Seed staging: RUN_SEED.ps1 -Env staging -Category <name>
7. ☐ Run RUN_SANITY.ps1 -Env staging
8. ☐ Seed production: RUN_REMOTE.ps1 -Category <name>
9. ☐ Run RUN_SANITY.ps1 -Env production
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
