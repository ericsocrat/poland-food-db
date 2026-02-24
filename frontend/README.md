# FoodDB Frontend

Next.js 15 (App Router) + TypeScript + Tailwind CSS frontend for the Poland Food Database.

## Tech Stack

| Layer         | Choice                                          |
| ------------- | ----------------------------------------------- |
| Framework     | Next.js 15 (App Router)                         |
| Language      | TypeScript (strict)                             |
| Styling       | Tailwind CSS (custom `brand` palette)           |
| Auth          | `@supabase/ssr` (browser + server + middleware) |
| Data fetching | TanStack Query (`@tanstack/react-query`)        |
| Toasts        | Sonner                                          |
| Barcode scan  | ZXing (`@zxing/browser` + `@zxing/library`)     |
| Validation    | Zod                                             |

## Getting Started

```bash
# 1. Install dependencies
cd frontend
npm install

# 2. Create env file
cp .env.local.example .env.local
# Edit .env.local with your Supabase project URL and anon key

# 3. Run dev server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Project Structure

```
src/
├── app/
│   ├── page.tsx              # Public landing page
│   ├── contact/              # Public
│   ├── privacy/              # Public stub
│   ├── terms/                # Public stub
│   ├── auth/
│   │   ├── login/            # Login (server wrapper + LoginForm client component)
│   │   ├── signup/           # Signup (server wrapper + SignupForm client component)
│   │   └── callback/         # OAuth / magic-link callback (route handler)
│   ├── onboarding/
│   │   ├── region/           # Step 1 — country selection
│   │   └── preferences/      # Step 2 — diet & allergens (skippable)
│   └── app/                  # Protected area (onboarding gate in layout.tsx)
│       ├── search/           # Product search
│       ├── categories/       # Category overview + [slug] listing
│       ├── product/[id]/     # Product detail
│       ├── scan/             # Barcode scanner (ZXing + manual EAN)
│       └── settings/         # User preferences
├── components/
│   ├── common/               # LoadingSpinner, CountryChip, RouteGuard
│   ├── layout/               # Header, Navigation, Footer
│   └── Providers.tsx         # QueryClientProvider + Toaster
├── lib/
│   ├── supabase/             # client.ts, server.ts, middleware.ts
│   ├── api.ts                # RPC wrappers (all pass p_country: null)
│   ├── rpc.ts                # callRpc error normalization + session expiry
│   ├── query-keys.ts         # TanStack Query keys + stale times
│   ├── types.ts              # TypeScript interfaces for API responses
│   └── constants.ts          # Countries, diet options, allergen tags
├── styles/globals.css        # Tailwind base + utility classes
└── middleware.ts             # Auth-only gate (no onboarding logic here)
```

## Architecture Decisions

1. **Auth via `@supabase/ssr`** — replaces the deprecated `@supabase/auth-helpers-nextjs`. Three client factories: browser, server, middleware.
2. **Onboarding gate in `/app/app/layout.tsx`** (server component) — calls `api_get_user_preferences()` and redirects to `/onboarding/region` if `onboarding_complete === false`.
3. **Middleware** handles auth only — no onboarding logic, no DB calls.
4. **`p_country` is always `null`** — the backend resolves the user's country from their preferences.
5. **`force-dynamic`** on auth/onboarding pages — prevents SSG crashes when env vars aren't set during build.
6. **RPC error normalization** via `callRpc<T>()` — returns `{ ok, data } | { ok, error }` discriminated union. Session expiry auto-redirects to `/auth/login?reason=expired`.
7. **TanStack Query** with defined keys and stale times — no retry on 401/403/PGRST301.

## Smoke Test Checklist

After deploying or starting the dev server, verify these flows:

- [ ] **Landing page** — `/` loads without auth
- [ ] **Public pages** — `/contact`, `/privacy`, `/terms` load without auth
- [ ] **Signup** — `/auth/signup` → create account → "check email" toast
- [ ] **Login** — `/auth/login` → sign in → redirected to `/app/search`
- [ ] **Session expiry** — expired token → redirected to `/auth/login?reason=expired` → amber banner shown
- [ ] **Onboarding gate** — new user hitting `/app/*` → redirected to `/onboarding/region`
- [ ] **Region selection** — pick country → Continue → `/onboarding/preferences`
- [ ] **Preferences** — set diet/allergens → Save → `/app/search` (or Skip)
- [ ] **Search** — type query → results load → product cards render
- [ ] **Categories** — `/app/categories` → overview grid → click slug → listing
- [ ] **Product detail** — click product → full detail with scores, nutrition, alternatives
- [ ] **Barcode scan** — `/app/scan` → camera permission → scan EAN → product detail (or manual input fallback)
- [ ] **Settings** — `/app/settings` → diet/allergens editable → save → toast
- [ ] **Logout** — sign out → redirected to `/auth/login`
- [ ] **Protected routes** — unauthenticated access to `/app/*` → redirected to `/auth/login`
- [ ] **Middleware** — no DB calls in middleware, only token refresh

## Security Notes

<!-- SECURITY CHECKLIST — review before production -->
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` is the **anon** key, never the service-role key
- [ ] No secret keys in `NEXT_PUBLIC_*` variables
- [ ] All 9 API functions are `anon_can_execute = false` (enforced in DB migration `20260213200400`)
- [ ] Middleware refreshes tokens but does NOT make DB calls
- [ ] `auth/callback/route.ts` exchanges code server-side only
- [ ] Row Level Security (RLS) is the primary data access control
- [ ] No `eval()`, `dangerouslySetInnerHTML`, or dynamic script injection

## PWA Status

This is a **standard web app**, not a PWA. No service worker, manifest, or offline support is configured. The mobile-first responsive design works well when added to home screen, but there is no offline capability.

## Operations

- **Deployment guide**: [`../DEPLOYMENT.md`](../DEPLOYMENT.md)
- **DR drill runner**: [`../RUN_DR_DRILL.ps1`](../RUN_DR_DRILL.ps1) — automated disaster recovery drill (6 scenarios)
- **DR drill report**: [`../docs/DISASTER_DRILL_REPORT.md`](../docs/DISASTER_DRILL_REPORT.md)
- **Security audit**: [`../docs/SECURITY_AUDIT.md`](../docs/SECURITY_AUDIT.md)
