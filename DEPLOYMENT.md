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

| Key                            | Example Value                                    |
| ------------------------------ | ------------------------------------------------ |
| `NEXT_PUBLIC_SUPABASE_URL`     | `https://your-project.supabase.co`               |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY`| `eyJhbGciOiJIUzI1NiIsInR5cCI6...`                |

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

For Vercel preview deployments, add additional redirect URLs:

```
https://*-ericsocrat.vercel.app/auth/callback
```

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

The callback route (`/auth/callback`) is the only auth callback target. It validates the redirect parameter to prevent open-redirect attacks (only relative paths starting with `/` are accepted).

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

| Secret                         | Value                                            |
| ------------------------------ | ------------------------------------------------ |
| `NEXT_PUBLIC_SUPABASE_URL`     | `https://your-project.supabase.co`               |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY`| Your Supabase anon key                           |

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
npx playwright test   # E2E tests (requires dev server)
```
