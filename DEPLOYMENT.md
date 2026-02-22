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
