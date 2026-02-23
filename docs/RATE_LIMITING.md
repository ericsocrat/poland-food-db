# Rate Limiting & Abuse Protection

> Issue: [#182](https://github.com/user/poland-food-db/issues/182) — Hardening 3/7

## Overview

All `/api/*` routes are protected by rate limiting via Next.js middleware. The
system uses **@upstash/ratelimit** with a **sliding window** algorithm and
falls back to an **ephemeral in-memory cache** when Redis credentials are not
configured (dev / CI).

## Rate Limit Tiers

| Tier            | Limit      | Key       | Routes                                           |
| --------------- | ---------- | --------- | ------------------------------------------------ |
| **standard**    | 60 / min   | IP        | All `/api/*` (default)                           |
| **auth**        | 10 / min   | IP        | `/auth/callback`, `*/login`, `*/signup`          |
| **search**      | 30 / min   | IP        | `*/search*`, `*/rpc/search*`                     |
| **health**      | 120 / min  | IP        | `/api/health*`                                   |
| **authenticated** | 120 / min | User ID  | Any route with valid JWT (promoted from standard)|

Authenticated users are automatically upgraded from the **standard** tier to
**authenticated** (120/min keyed by user ID instead of IP). Other tiers
(auth, search, health) retain their specific limits regardless of auth status.

## Response Headers

Every API response includes rate-limit metadata:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 42
X-RateLimit-Reset: 1718300000000
```

When the limit is exceeded, the response is **HTTP 429**:

```json
{
  "error": "Too Many Requests",
  "message": "Rate limit exceeded. Try again in 30s.",
  "tier": "standard"
}
```

Additional header: `Retry-After: 30`

## Bypass Mechanism

For CI, load testing, and internal tools, set the `RATE_LIMIT_BYPASS_TOKEN`
environment variable and include it as a header:

```
x-rate-limit-bypass: <token>
```

This skips rate limiting entirely for that request.

## Environment Variables

| Variable                    | Required | Description                              |
| --------------------------- | -------- | ---------------------------------------- |
| `UPSTASH_REDIS_REST_URL`    | Prod     | Upstash Redis REST endpoint              |
| `UPSTASH_REDIS_REST_TOKEN`  | Prod     | Upstash Redis REST auth token            |
| `RATE_LIMIT_BYPASS_TOKEN`   | No       | Secret for bypassing rate limits in CI   |

When Redis env vars are missing, the system uses an in-memory cache. This is
fine for local development and CI but **must not** be used in production (no
shared state across serverless functions).

## Architecture

```
Request → middleware.ts
  ├─ /api/* route?
  │   ├─ Bypass token? → pass through
  │   ├─ resolveRateLimitTier(pathname) → tier
  │   ├─ extractUserIdFromJWT(auth header) → id or IP
  │   ├─ Promote standard → authenticated if JWT present
  │   ├─ limiter.limit(identifier)
  │   │   ├─ success → add X-RateLimit-* headers, pass through
  │   │   └─ failure → return 429 + Retry-After
  │   └─ done
  └─ Page route → auth enforcement (unchanged)
```

## Frontend 429 Handling

The RPC layer (`src/lib/rpc.ts`) detects rate-limit errors from Supabase
and normalizes them with code `RATE_LIMITED`. Consumers can check via:

```ts
import { isRateLimitError } from "@/lib/rpc";

if (!result.ok && isRateLimitError(result.error)) {
  showToast({ type: "warning", message: "Too many requests. Please wait." });
}
```

## Tuning Guide

To adjust limits, edit the `Ratelimit.slidingWindow()` parameters in
`src/lib/rate-limiter.ts`:

```ts
// Example: increase standard tier to 100 req/min
export const standardLimiter = new Ratelimit({
  redis: store as Redis,
  limiter: Ratelimit.slidingWindow(100, "60 s"),
  prefix: "rl:standard",
  analytics: false,
});
```

To add a new tier:
1. Create a new `Ratelimit` instance in `rate-limiter.ts`
2. Add the tier name to the `RateLimitTier` union type
3. Add a case to `getLimiter()`
4. Add matching logic to `resolveRateLimitTier()`

## Testing

```bash
cd frontend
npx vitest run src/lib/rate-limiter.test.ts src/middleware.test.ts src/lib/rpc.test.ts
```
