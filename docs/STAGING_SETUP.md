# Staging Setup Guide

> **Status: READY** — All scripts (`RUN_REMOTE.ps1`, `RUN_SEED.ps1`,
> `RUN_SANITY.ps1`) support `-Env staging`. The `sync-cloud-db.yml` workflow
> auto-pushes migrations to staging before production when `STAGING_ENABLED=true`
> is set as a repository variable.
>
> Follow the steps below to create the Supabase staging project and configure
> secrets. See [ENVIRONMENT_STRATEGY.md](ENVIRONMENT_STRATEGY.md) §8.1 for context.

---

> Step-by-step instructions to create and configure the Staging Supabase project.

---

## Prerequisites

- Supabase account with ability to create projects
- Supabase CLI installed (`npx supabase --version`)
- `psql` available on PATH
- GitHub repository admin access (for secrets)
- Vercel project admin access (for environment variables)

---

## Step 1: Create the Staging Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click **New project**
3. Settings:
   - **Name:** `poland-food-db-staging`
   - **Database Password:** Generate a strong password — save it securely
   - **Region:** Same as production (to minimize latency differences)
   - **Plan:** Free tier is sufficient for staging
4. Note the **Project Reference** (e.g., `abcdef123456`)

---

## Step 2: Apply Migrations

```powershell
# From the repository root
cd c:\Users\ericsocrat\Desktop\poland-food-db

# Link to the staging project
npx supabase link --project-ref <staging-ref>

# Push all migrations
npx supabase db push
```

Verify: All 85+ migrations should apply successfully.

---

## Step 3: Seed Data

```powershell
# Set staging credentials in .env
# SUPABASE_STAGING_PROJECT_REF=<staging-ref>
# SUPABASE_STAGING_DB_PASSWORD=<password>

# Run the unified seed script
.\RUN_SEED.ps1 -Env staging
```

This will:
1. Apply reference data (country_ref, category_ref, etc.)
2. Run all 21 category pipelines (~1,025+ products)
3. Apply CI post-pipeline fixup
4. Refresh materialized views

---

## Step 4: Validate with Sanity Checks

```powershell
.\RUN_SANITY.ps1 -Env staging
```

All 17 checks should pass. Fix any failures before proceeding.

---

## Step 5: Configure Auth

In the Staging Supabase Dashboard → **Authentication → URL Configuration**:

1. **Site URL:** `https://<your-staging-domain>.vercel.app` (or a Vercel preview URL)
2. **Redirect URLs:**
   - `https://<your-staging-domain>.vercel.app/auth/callback`
   - `https://*-ericsocrat.vercel.app/auth/callback` (wildcard for PR previews)
   - `http://localhost:3000/auth/callback` (for local development pointing at staging)

---

## Step 6: Store Secrets

### GitHub Repository Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret                              | Value                                                      |
| ----------------------------------- | ---------------------------------------------------------- |
| `SUPABASE_STAGING_PROJECT_REF`      | Staging project reference (e.g., `abcdef123456`)           |
| `SUPABASE_URL_STAGING`              | `https://<staging-ref>.supabase.co`                        |
| `SUPABASE_ANON_KEY_STAGING`         | Staging project anon key (from Dashboard → Settings → API) |
| `SUPABASE_SERVICE_ROLE_KEY_STAGING` | Staging project service role key                           |

### GitHub Repository Variables

Go to **Settings → Secrets and variables → Actions → Variables** and add:

| Variable            | Value  | Purpose                                         |
| ------------------- | ------ | ----------------------------------------------- |
| `STAGING_ENABLED`   | `true` | Enables staging sync in `sync-cloud-db.yml`     |

### Vercel Preview Environment

Go to **Vercel → Project Settings → Environment Variables**:

1. Set `NEXT_PUBLIC_SUPABASE_URL` for **Preview** environment to the staging URL
2. Set `NEXT_PUBLIC_SUPABASE_ANON_KEY` for **Preview** environment to the staging anon key

> **Important:** Do NOT override the Production environment variables.

### Local `.env`

Add to your `.env` file (git-ignored):

```dotenv
SUPABASE_STAGING_PROJECT_REF=<staging-ref>
SUPABASE_STAGING_DB_PASSWORD=<password>
```

---

## Step 7: Verify E2E (Optional)

Run Playwright against a staging-backed preview deployment:

```powershell
cd frontend
$env:NEXT_PUBLIC_SUPABASE_URL = "https://<staging-ref>.supabase.co"
$env:NEXT_PUBLIC_SUPABASE_ANON_KEY = "<staging-anon-key>"
npx playwright test
```

---

## Step 8: Wire CI (Issue #141)

Update `.github/workflows/pr-gate.yml` and `main-gate.yml` to use staging secrets for Playwright E2E:

```yaml
env:
  NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL_STAGING }}
  NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY_STAGING }}
```

This ensures CI never touches production and E2E tests run against staging.

---

## Maintenance

### Applying New Migrations to Staging

After merging a PR with new migrations, `sync-cloud-db.yml` auto-pushes to
staging (when `STAGING_ENABLED=true`). To apply manually:

```powershell
npx supabase link --project-ref <staging-ref>
npx supabase db push
.\RUN_SANITY.ps1 -Env staging
```

### Re-seeding Staging

If staging data drifts (e.g., after testing):

```powershell
.\RUN_SEED.ps1 -Env staging
.\RUN_SANITY.ps1 -Env staging
```

### Comparing Staging vs Production Schema

```powershell
# Link to staging and capture schema
npx supabase link --project-ref <staging-ref>
npx supabase db diff --schema public > staging_diff.sql

# Link to production and capture schema
npx supabase link --project-ref uskvezwftkkudvksmken
npx supabase db diff --schema public > prod_diff.sql

# Compare (should be identical if both are up-to-date)
```
