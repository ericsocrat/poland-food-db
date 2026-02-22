# Deployment Guide

## Vercel Deployment

The frontend is deployed on Vercel from the `frontend/` directory.

### Vercel Project Settings

| Setting         | Value      |
| --------------- | ---------- |
| Root Directory  | `frontend` |
| Framework       | Next.js    |
| Build Command   | (auto)     |
| Install Command | `npm ci`   |
| Output Dir      | `.next`    |

### Required Environment Variables

Set these in **Vercel > Project Settings > Environment Variables**:

| Key                             | Example Value                      |
| ------------------------------- | ---------------------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`      | `https://your-project.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6...`  |

These are public keys (embedded in the client bundle). The anon key only grants access allowed by RLS policies.

---

## Supabase Auth URL Configuration

**Critical:** Supabase must know your production domain for auth callbacks to work.

### Steps

1. Go to **Supabase Dashboard > Authentication > URL Configuration**
2. Set **Site URL** to your production domain:
   ```
   https://your-domain.vercel.app
   ```
3. Add **Redirect URLs** (at minimum):
   ```
   https://your-domain.vercel.app/auth/callback
   ```
4. Click **Save**

### Preview Deployments

For Vercel preview deployments, add a wildcard redirect URL matching your preview domain pattern:

```
https://*-<your-vercel-username>.vercel.app/auth/callback
```

Replace `<your-vercel-username>` with your actual Vercel account name (e.g., `https://*-janedoe.vercel.app/auth/callback`).

> **Note:** Supabase supports wildcard subdomains in redirect URLs. This allows all Vercel preview deployments to use auth callbacks.

If wildcards aren't supported in your Supabase plan, add each preview domain individually as needed.

### Auth Flow

```
User signs up → Supabase sends confirmation email
  → User clicks link → /auth/callback (exchanges code for session)
  → Redirect to /app/search
  → App layout checks onboarding_complete
  → If false → /onboarding/region → /onboarding/preferences → /app/search
```

The callback route (`/auth/callback`) is the only auth callback target. It exchanges the Supabase auth code for a session and redirects to `/app/search`.

Post-login redirect validation happens in the **login form** (`LoginForm.tsx`): the `redirect` query parameter is validated to prevent open-redirect attacks — only relative paths starting with `/` are accepted, and `//` prefixes are blocked.

---

## Automated Deployment (CI)

### Overview

Database deployments are automated via **GitHub Actions** using `.github/workflows/deploy.yml`. The workflow is triggered manually from the GitHub Actions UI with an environment selector (production/staging).

### Architecture

```
Developer triggers via GitHub UI
  → Pre-flight: Schema diff + dry-run option
  → Approval gate (production only — GitHub Environment protection)
  → Pre-deploy backup (supabase db dump → artifact)
  → Push migrations (supabase db push)
  → Post-deploy sanity checks (16 SQL checks)
  → Summary in GitHub Actions step summary
```

### How to Trigger a Deployment

1. Go to **GitHub → Actions → Deploy Database**
2. Click **Run workflow**
3. Select the target **environment** (production or staging)
4. Optionally check **Dry run** to only see the schema diff without deploying
5. Click **Run workflow**

For **production** deployments, a reviewer must approve the deployment in the GitHub Environment approval UI before the deploy job starts.

### Workflow Steps

| Step | Description | On Failure |
| ---- | ----------- | ---------- |
| Pre-flight: Schema diff | Shows pending migrations and drift between Git and remote | Informational — does not block |
| Dry run gate | If dry run is checked, stops after showing diff | N/A |
| Approval gate | Production requires reviewer approval via GitHub Environments | Deploy waits indefinitely |
| Pre-deploy backup | `supabase db dump --data-only` saved as artifact (30-day retention) | **Aborts deployment** |
| Push migrations | `supabase db push` applies pending migrations | Workflow fails, backup available |
| Post-deploy sanity | Runs all 16 SQL sanity checks against remote | Workflow fails with check details |

### GitHub Environment Protection Rules

| Environment | Approval Required | Wait Timer | Secrets |
| ----------- | ----------------- | ---------- | ------- |
| `production` | Yes (1+ reviewer) | 5 minutes | `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, `SUPABASE_DB_PASSWORD` |
| `staging` | No | None | `SUPABASE_ACCESS_TOKEN`, `SUPABASE_STAGING_PROJECT_REF`, `SUPABASE_DB_PASSWORD` |

### Required Secrets

| Secret | Purpose | Scope |
| ------ | ------- | ----- |
| `SUPABASE_ACCESS_TOKEN` | CLI authentication | Repository |
| `SUPABASE_PROJECT_REF` | Production project reference | Environment: production |
| `SUPABASE_STAGING_PROJECT_REF` | Staging project reference | Environment: staging |
| `SUPABASE_DB_PASSWORD` | Direct DB access (backup + sanity) | Repository |

> **Security:** All secrets are accessed via `${{ secrets.* }}` — never echoed in logs or step outputs. Rotate access tokens quarterly.

### Concurrency Protection

The workflow uses `concurrency: deploy-<environment>` to prevent parallel deployments to the same environment. A new deployment to the same environment will wait for the current one to finish.

### Existing Auto-Sync

`sync-cloud-db.yml` automatically pushes migrations to production on merge to `main`. The manual `deploy.yml` workflow is intended for:
- Controlled deployments with approval gates
- Staging deployments (once #140 is implemented)
- Re-deployments after failed syncs
- Dry-run schema diff checks

### Recovery from Failed Deployment

If `deploy.yml` fails mid-push:
1. Download the backup artifact from the workflow run
2. Follow [Restore Procedures](#restore-from-dump-file) below
3. Investigate the failing migration
4. Fix and re-trigger the deployment

See also: Issue #121 (Rollback Documentation) for detailed procedures.

---

## Custom Domain

1. Go to **Vercel > Project Settings > Domains**
2. Add your custom domain (e.g., `fooddb.example.com`)
3. Configure DNS per Vercel's instructions (CNAME or A record)
4. **Update Supabase Auth URLs** to match:
   - Site URL: `https://fooddb.example.com`
   - Redirect URL: `https://fooddb.example.com/auth/callback`
5. Keep the Vercel `.vercel.app` domain in Supabase redirect URLs as a fallback

---

## GitHub Actions CI

### Required Secrets

Add these in **GitHub > Settings > Secrets and variables > Actions > Repository secrets**:

| Secret                          | Value                              |
| ------------------------------- | ---------------------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`      | `https://your-project.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Your Supabase anon key             |

### CI Pipeline

The CI workflow (`.github/workflows/ci.yml`) runs on every push to `main` and on pull requests:

1. **Install** — `npm ci` (uses lockfile for reproducible builds)
2. **Type check** — `npm run type-check` (TypeScript `tsc --noEmit`)
3. **Lint** — `npm run lint` (ESLint with Next.js rules)
4. **Build** — `npm run build` (Next.js production build)
5. **E2E Tests** — Playwright smoke tests (14 tests)

### Running CI Locally

```bash
cd frontend
npm ci
npm run type-check    # TypeScript check
npm run lint          # ESLint
npm run build         # Production build
npx playwright test   # E2E tests (auto-starts dev server via webServer config)
```

---

## Supabase Plan & PITR

| Item               | Value                                                               |
| ------------------ | ------------------------------------------------------------------- |
| Plan tier          | **Free** (verified 2026-02-22 via Supabase Dashboard > Billing)     |
| PITR availability  | **Not available** — PITR requires the Pro plan ($25/month)          |
| Daily auto-backups | Yes (Free tier: last 7 days, no PITR, no point-in-time granularity) |
| Backup granularity | Daily snapshot only — no sub-day recovery                           |

> **Implication:** Because there is no PITR, a bad migration could lose all data written since the last daily snapshot. The `BACKUP.ps1` pre-deployment dump is the primary safety net.

---

## Backup Procedures

### Pre-Deployment Backup (automatic)

`RUN_REMOTE.ps1` automatically calls `BACKUP.ps1 -Env remote` before executing any SQL pipelines. If the backup fails, deployment is **aborted**.

To skip the backup in an emergency:

```powershell
.\RUN_REMOTE.ps1 -SkipBackup -Force
```

> **Warning:** Skipping the backup removes your safety net. Only do this if the backup itself is broken and you have another recovery path.

### On-Demand Backup

```powershell
# Remote (production)
.\BACKUP.ps1 -Env remote

# Local (Docker)
.\BACKUP.ps1 -Env local
```

Produces: `backups/cloud_backup_YYYYMMDD_HHmmss.dump` (compressed custom format)

**Prerequisites:**
- `pg_dump` and `psql` on PATH
- Remote: `SUPABASE_DB_PASSWORD` environment variable (or interactive prompt)
- Local: Docker Desktop + Supabase running (`supabase start`)

### User Data Export

```powershell
.\scripts\export_user_data.ps1 -Env remote
```

Exports 8 user tables to `backups/user_data_YYYYMMDD_HHmmss.json`:
- `user_preferences`, `user_health_profiles`, `user_product_lists`, `user_product_list_items`
- `user_comparisons`, `user_saved_searches`, `scan_history`, `product_submissions`

---

## Restore Procedures

### Restore from `.dump` File

```powershell
# Full database restore (drops and recreates objects)
pg_restore --no-owner --no-privileges --clean --if-exists -d postgres backups/cloud_backup_YYYYMMDD_HHmmss.dump
```

For remote restore, set the connection via environment:

```powershell
$env:PGPASSWORD = "your-password"
pg_restore --no-owner --no-privileges --clean --if-exists `
  -h aws-1-eu-west-1.pooler.supabase.com `
  -p 5432 `
  -U "postgres.uskvezwftkkudvksmken" `
  -d postgres `
  backups/cloud_backup_YYYYMMDD_HHmmss.dump
```

### Restore from User Data JSON

```powershell
.\scripts\import_user_data.ps1 -Env local -File backups\user_data_YYYYMMDD_HHmmss.json
.\scripts\import_user_data.ps1 -Env remote -File backups\user_data_YYYYMMDD_HHmmss.json
```

Import uses `ON CONFLICT DO UPDATE` (upsert) — safe to run multiple times.

### Post-Restore Validation

After any restore, run the full validation suite:

1. **Sanity checks** — `.\RUN_SANITY.ps1 -Env production` (17 checks pass)
2. **QA checks** — `.\RUN_QA.ps1` (all suites pass)
3. **Row counts** — verify user table row counts match pre-backup values
4. **Frontend smoke** — load a product detail page and verify data displays correctly

---

## Estimated Backup Metrics (current scale)

| Metric          | Approximate Value |
| --------------- | ----------------- |
| Total products  | ~1,076            |
| Database size   | ~50–100 MB        |
| Dump file size  | ~10–30 MB         |
| Backup duration | ~10–30 seconds    |
| User data JSON  | < 1 MB            |

These will grow as more products and users are added.

---

## Pre-Deployment Checklist

Before running `RUN_REMOTE.ps1` against production:

1. **On `main` branch** — must be on `main` (script enforces this)
2. **All CI checks pass** — `tsc --noEmit`, lint, build, Vitest, Playwright
3. **QA checks pass locally** — `.\RUN_QA.ps1` with local Supabase
4. **Backup runs successfully** — automatic via `RUN_REMOTE.ps1`, or manual `.\BACKUP.ps1 -Env remote`
5. **Review the execution plan** — `.\RUN_REMOTE.ps1 -DryRun` to see which files will execute
6. **Confirm interactively** — type `YES` when prompted (or use `-Force` for CI)

---

## Rollback Procedures

> **Golden rule:** Always take a backup before attempting any fix. If the database is accessible, run `.\BACKUP.ps1 -Env remote` *first*.

### Scenario 1: Bad Migration Applied (DDL error)

A migration was successfully applied but introduced a schema error — e.g., dropped a column, altered a constraint incorrectly, or created a conflicting index.

**Steps:**

1. **Identify the bad migration:**
   ```sql
   SELECT version, name, statements FROM supabase_migrations.schema_migrations
   ORDER BY version DESC LIMIT 5;
   ```

2. **Take a current backup** (if DB is still accessible):
   ```powershell
   .\BACKUP.ps1 -Env remote
   ```

3. **Write a compensating migration** — a new migration that undoes the damage. Example:
   ```sql
   -- ═══════════════════════════════════════════════════════════════════════════
   -- Migration: Fix accidental column drop from migration YYYYMMDD_HHMMSS
   -- Rollback: This migration itself is forward-only; manual DROP if needed
   -- ═══════════════════════════════════════════════════════════════════════════
   BEGIN;

   -- Re-create the accidentally dropped column
   ALTER TABLE products ADD COLUMN IF NOT EXISTS product_name text;

   -- Restore data from backup if needed (backfill from last known-good dump)
   -- UPDATE products SET product_name = b.product_name
   -- FROM backup_products b WHERE products.id = b.id;

   -- Restore any constraints
   -- ALTER TABLE products ALTER COLUMN product_name SET NOT NULL;

   COMMIT;
   ```

4. **Save the compensating migration** to `supabase/migrations/` with the next timestamp.

5. **Apply:**
   ```powershell
   # Local test first
   supabase db push --local
   .\RUN_QA.ps1

   # Then production
   supabase db push --linked
   # Or via deploy.yml workflow with approval gate
   ```

6. **Verify:**
   ```powershell
   .\RUN_SANITY.ps1 -Env production   # 17 checks pass
   .\RUN_QA.ps1                        # 421 checks pass
   ```

7. **Document the incident** — write a post-mortem within 24 hours.

### Scenario 2: Full Database Restore from Backup

The database is corrupted or data integrity is compromised beyond compensating migration repair. Requires full restore from the latest `.dump` file.

**Steps:**

1. **Locate latest backup:**
   ```powershell
   Get-ChildItem backups/*.dump | Sort-Object LastWriteTime -Descending | Select-Object -First 5
   ```
   Also check GitHub Actions artifacts from `deploy.yml` runs (30-day retention).

2. **Verify backup integrity:**
   ```bash
   pg_restore --list backups/cloud_backup_YYYYMMDD_HHmmss.dump | head -20
   ```
   If this prints a table of contents, the file is valid. If it errors, the dump is corrupt — try an older backup.

3. **Take a snapshot of the current (broken) state** (if accessible):
   ```powershell
   .\BACKUP.ps1 -Env remote   # Save as evidence for post-mortem
   ```

4. **Restore the backup:**
   ```powershell
   $env:PGPASSWORD = "your-password"
   pg_restore --no-owner --no-privileges --clean --if-exists `
     -h aws-1-eu-west-1.pooler.supabase.com `
     -p 5432 `
     -U "postgres.uskvezwftkkudvksmken" `
     -d postgres `
     backups/cloud_backup_YYYYMMDD_HHmmss.dump
   ```

   **Flags explained:**
   - `--clean --if-exists` — drops objects before recreating (safe even if objects don't exist)
   - `--no-owner --no-privileges` — avoids permission errors on Supabase managed roles

5. **Re-apply migrations newer than the backup** (if any):
   ```bash
   # Check which migrations are recorded in the restored DB
   psql -c "SELECT version FROM supabase_migrations.schema_migrations ORDER BY version DESC LIMIT 10;"
   # Manually apply any missing migrations after the backup timestamp
   ```

6. **Verify:**
   ```powershell
   .\RUN_SANITY.ps1 -Env production   # 17 checks pass
   .\RUN_QA.ps1                        # 421 checks pass
   ```

7. **Verify product count:**
   ```sql
   SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE;
   -- Expected: ≥ 1,076
   ```

8. **Spot-check the frontend** — load a product detail page and verify data displays correctly.

### Scenario 3: User Data Restore Only

User-facing data (preferences, lists, scan history) was lost or corrupted, but the schema and product data are intact.

**Steps:**

1. **Locate the user data export:**
   ```powershell
   Get-ChildItem backups/user_data_*.json | Sort-Object LastWriteTime -Descending | Select-Object -First 5
   ```
   If no export exists, create one from the backup dump manually.

2. **Import user data:**
   ```powershell
   .\scripts\import_user_data.ps1 -Env remote -File backups\user_data_YYYYMMDD_HHmmss.json
   ```
   Uses `ON CONFLICT DO UPDATE` (upsert) — safe to run multiple times. FK dependency order is handled automatically.

3. **Verify user table row counts:**
   ```sql
   SELECT 'user_preferences' AS tbl, COUNT(*) FROM user_preferences
   UNION ALL SELECT 'user_health_profiles', COUNT(*) FROM user_health_profiles
   UNION ALL SELECT 'user_product_lists', COUNT(*) FROM user_product_lists
   UNION ALL SELECT 'user_product_list_items', COUNT(*) FROM user_product_list_items
   UNION ALL SELECT 'user_comparisons', COUNT(*) FROM user_comparisons
   UNION ALL SELECT 'user_saved_searches', COUNT(*) FROM user_saved_searches
   UNION ALL SELECT 'scan_history', COUNT(*) FROM scan_history
   UNION ALL SELECT 'product_submissions', COUNT(*) FROM product_submissions;
   ```

4. **Verify auth still works** — log in with a test account, view preferences, check saved lists.

### Scenario 4: Vercel Frontend Rollback

A bad frontend deployment was pushed — the site is broken, shows errors, or has a critical UX regression.

**Steps:**

1. Go to **Vercel Dashboard → Project → Deployments**
2. Find the last known-good deployment (green checkmark before the bad one)
3. Click **"..."** → **"Promote to Production"**
4. Wait ~30 seconds for the rollback to propagate
5. **Verify:**
   - Home page loads (`/`)
   - Search works (`/app/search`)
   - Product detail page renders data (`/app/product/[id]`)
   - Auth callback works (`/auth/callback`)
   - Health endpoint returns 200 (`/api/health`)
6. If the rollback needs to stay in place, revert the bad commit on `main` to prevent the next push from re-deploying the broken code.

### Scenario 5: Partial Failure (Migration Succeeded, Data Corrupt)

A migration applied successfully but introduced data corruption — e.g., an UPDATE with incorrect WHERE clause, a bad DEFAULT value, or a trigger that modified existing rows.

**Steps:**

1. **Assess the damage:**
   ```powershell
   .\RUN_QA.ps1   # Check which suites fail — this identifies affected data
   ```

2. **If damage is limited** (a few rows affected):
   - Write a compensating SQL script to fix the data
   - Apply and verify with QA

3. **If damage is widespread** (many tables/rows affected):
   - Follow **Scenario 2** (full restore from backup)

4. **If data was deleted irreversibly:**
   - Restore from backup (Scenario 2)
   - Accept data loss between backup time and incident time
   - Document the gap in the post-mortem

---

## Emergency Checklist

> Copy-paste this into your incident channel (Slack/Discord/Teams) when a production incident occurs.

```markdown
## 🚨 Production Incident — [DATE] [TIME UTC]

**Reported by:** @name
**Severity:** P1 / P2 / P3
**Impact:** [Describe what users are experiencing]

### Immediate Actions
- [ ] Stop any in-progress deployments (cancel GitHub Actions run on deploy.yml)
- [ ] Stop `sync-cloud-db.yml` if running (cancel workflow)
- [ ] Take a current backup if DB is accessible: `.\BACKUP.ps1 -Env remote`
- [ ] Export user data if schema is intact: `.\scripts\export_user_data.ps1 -Env remote`

### Investigation
- [ ] Identify root cause (check: migration logs, Supabase dashboard logs, Vercel deployment logs)
- [ ] Identify scope — which tables/data/features are affected
- [ ] Check `supabase_migrations.schema_migrations` for recently applied migrations

### Recovery
- [ ] Choose restore scenario (1–5 from DEPLOYMENT.md Rollback Procedures)
- [ ] Execute restore with a second person verifying each step
- [ ] Run `.\RUN_SANITY.ps1 -Env production` — all 17 checks pass
- [ ] Run `.\RUN_QA.ps1` against production data — all 421 checks pass
- [ ] Verify frontend loads correctly (home, search, product detail, auth)
- [ ] Verify `/api/health` returns 200

### Communication
- [ ] Notify stakeholders of impact and ETA
- [ ] Update status page (if applicable)
- [ ] Write post-mortem within 24 hours

### Post-mortem Template
- **Timeline:** When was the incident detected? When was it resolved?
- **Root cause:** What exactly went wrong?
- **Impact:** How many users were affected? For how long?
- **Recovery:** What steps were taken? How long did recovery take?
- **Prevention:** What changes will prevent recurrence?
```

---

## Break-Glass: Emergency Database Access

If normal tooling fails (Supabase CLI, scripts), use direct `psql` access:

```powershell
# Set credentials
$env:PGPASSWORD = "your-db-password"

# Direct connection (bypasses CLI, bypasses pooler)
psql -h db.uskvezwftkkudvksmken.supabase.co `
     -p 5432 `
     -U postgres `
     -d postgres
```

**When to use break-glass:**
- Supabase CLI is down or unresponsive
- GitHub Actions is not available
- `RUN_REMOTE.ps1` or `BACKUP.ps1` are failing for script-level reasons
- You need to run a manual SQL fix immediately

**Security note:** Direct database access bypasses all application-level security. Use only during incidents. Log all manual SQL commands for the post-mortem.

---

## Rollback Drill Procedure

> **Frequency:** Run this drill at least once per quarter, and after every time the backup or restore scripts change.

### Drill: Local Full Restore

**Prerequisites:** Docker Desktop running, `supabase start` active.

**Steps:**

```powershell
# 1. Create backup of healthy local DB
.\BACKUP.ps1 -Env local

# 2. Verify backup exists
Get-ChildItem backups/local_backup*.dump | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 3. Apply destructive migration to simulate disaster
psql -h 127.0.0.1 -p 54322 -U postgres -d postgres -c "ALTER TABLE products DROP COLUMN product_name;"

# 4. Confirm QA detects the breakage
.\RUN_QA.ps1
# Expected: multiple suite failures (product_name referenced in views, queries, API contract)

# 5. Restore from backup
pg_restore --clean --if-exists --no-owner --no-privileges `
  -h 127.0.0.1 -p 54322 -U postgres -d postgres `
  backups/local_backup_YYYYMMDD_HHmmss.dump

# Alternative: full reset (reapplies all migrations from scratch)
supabase db reset

# 6. Verify recovery
.\RUN_SANITY.ps1          # 17 checks pass
.\RUN_QA.ps1              # 421 checks pass
```

**Expected Results:**
| Step | Expected Duration |
|---|---|
| Backup creation (local) | ~5 seconds |
| Destructive change | < 1 second |
| QA detection of breakage | Immediate (first suite referencing `product_name`) |
| Restore from dump (local) | ~10 seconds |
| Full QA pass after restore | ~30 seconds |
| **Total drill time** | **< 2 minutes (local)** |

**For production drills**, add ~30 seconds network latency for backup and ~60 seconds for restore.

**Record your results:**

```markdown
### Drill #N — [Date]
- **Operator:** @name
- **Environment:** local / staging
- **Backup creation time:** ___
- **Breakage detection time:** ___
- **Restore time:** ___
- **Full recovery time:** ___
- **All QA checks passed after restore:** yes / no
- **Issues encountered:** ___
- **Lessons learned:** ___
```

**Key lessons from procedure design:**
- `pg_restore --clean` on a running DB with active connections requires `--if-exists` to avoid errors on missing objects
- Always verify backup integrity (`pg_restore --list`) before relying on it for restore
- QA suite catches column drops immediately — sanity + QA provides comprehensive post-restore validation
- The compensating migration approach (Scenario 1) is preferred over full restore when the issue is isolated to schema changes
