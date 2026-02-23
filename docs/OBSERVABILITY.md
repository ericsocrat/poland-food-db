# Observability & Error Telemetry

> Issue: [#183 — Production Observability + Error Telemetry](https://github.com/ericsocrat/poland-food-db/issues/183)

## Architecture Overview

```
┌───────────────────────────────────────────────────────────┐
│                    Frontend (Next.js)                     │
│                                                           │
│  ErrorBoundary ──→ error-reporter.ts ──→ Sentry SDK       │
│  error.tsx     ──→ Sentry.captureException ──→ Sentry     │
│  global-error  ──→ Sentry.captureException ──→ Sentry     │
│                                                           │
│  API Routes ──→ withInstrumentation() ──→ Structured      │
│                   JSON logs (stdout) ──→ Vercel Logs      │
│                   Sentry.captureException ──→ Sentry      │
│                                                           │
│  Middleware ──→ X-Request-Id generation                   │
│                                                           │
├───────────────────────────────────────────────────────────┤
│                    Supabase                               │
│  RPC calls ──→ pg_stat_statements (native)                │
│  Auth events ──→ auth.audit_log (native)                  │
└───────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│                    Alerting (Sentry)                      │
│    - Error rate > 5/min → Slack/Email                     │
│    - New issue type → Notification                        │
│    - P95 latency > 3s → Warning                           │
│    - Health endpoint failure → Critical alert             │
└───────────────────────────────────────────────────────────┘
```

## Structured Log Format

All API route logs are emitted as structured JSON to stdout (captured by Vercel Logs):

```json
{
  "timestamp": "2026-02-22T12:34:56.789Z",
  "level": "info",
  "message": "API request completed",
  "environment": "production",
  "version": "a1b2c3d4",
  "requestId": "550e8400-e29b-41d4-a716-446655440000",
  "route": "/api/health",
  "method": "GET",
  "status": 200,
  "duration": 42
}
```

### Fields

| Field         | Type                                              | Required | Description                            |
| ------------- | ------------------------------------------------- | -------- | -------------------------------------- |
| `timestamp`   | string (ISO 8601)                                 | ✅        | When the log was emitted               |
| `level`       | `debug` \| `info` \| `warn` \| `error` \| `fatal` | ✅        | Severity level                         |
| `message`     | string                                            | ✅        | Human-readable description             |
| `environment` | string                                            | ✅        | `development`, `preview`, `production` |
| `version`     | string                                            | ✅        | First 8 chars of git SHA or `local`    |
| `requestId`   | string (UUID)                                     | ⬜        | Correlation ID for request tracing     |
| `route`       | string                                            | ⬜        | API route pathname                     |
| `method`      | string                                            | ⬜        | HTTP method                            |
| `status`      | number                                            | ⬜        | HTTP response status code              |
| `duration`    | number (ms)                                       | ⬜        | Request processing time                |
| `userId`      | string (UUID)                                     | ⬜        | Anonymized user ID (never email)       |
| `error`       | object                                            | ⬜        | `{ name, message, stack? }`            |
| `meta`        | object                                            | ⬜        | Arbitrary key-value context            |

### Log Levels

| Level   | Numeric | Usage                                                  |
| ------- | ------- | ------------------------------------------------------ |
| `debug` | 0       | Detailed debugging info (local dev only)               |
| `info`  | 1       | Normal operations (request completed, health check OK) |
| `warn`  | 2       | Degraded state (RPC failure with fallback, slow query) |
| `error` | 3       | Request failures, uncaught exceptions                  |
| `fatal` | 4       | System-level failures (cannot start, data corruption)  |

Configure minimum level via `LOG_LEVEL` env var (default: `info`).

## Sentry Integration

### SDK Configuration

| Config                     | Client                          | Server                     | Edge                       |
| -------------------------- | ------------------------------- | -------------------------- | -------------------------- |
| Config file                | `src/instrumentation-client.ts` | `sentry.server.config.ts`  | `sentry.edge.config.ts`    |
| DSN                        | `NEXT_PUBLIC_SENTRY_DSN`        | `NEXT_PUBLIC_SENTRY_DSN`   | `NEXT_PUBLIC_SENTRY_DSN`   |
| Sample rate (errors)       | 100%                            | 100%                       | 100%                       |
| Sample rate (transactions) | Configurable (default 10%)      | Configurable (default 10%) | Configurable (default 10%) |
| Session replay             | Disabled                        | N/A                        | N/A                        |
| Source maps                | Uploaded during build           | Uploaded during build      | Uploaded during build      |

### Environment Variables

| Variable                                | Where        | Required    | Description                              |
| --------------------------------------- | ------------ | ----------- | ---------------------------------------- |
| `NEXT_PUBLIC_SENTRY_DSN`                | `.env.local` | Yes (prod)  | Sentry project DSN (public, client-safe) |
| `SENTRY_AUTH_TOKEN`                     | CI secrets   | Yes (build) | For source map upload                    |
| `SENTRY_ORG`                            | CI secrets   | Yes (build) | Sentry organization slug                 |
| `SENTRY_PROJECT`                        | CI secrets   | Yes (build) | Sentry project slug                      |
| `NEXT_PUBLIC_SENTRY_TRACES_SAMPLE_RATE` | `.env.local` | No          | Transaction sample rate (default: `0.1`) |
| `SENTRY_TRACES_SAMPLE_RATE`             | Server env   | No          | Server-side transaction sample rate      |
| `LOG_LEVEL`                             | Server env   | No          | Minimum log level (default: `info`)      |

### PII Scrubbing

All Sentry configs include a `beforeSend` hook that:
1. **Strips email** — `delete event.user.email`
2. **Strips IP address** — `delete event.user.ip_address`
3. **Filters health data breadcrumbs** — removes any breadcrumb containing `health_profile`, `allergen`, or `health_condition`

Session replay is **disabled** (0% sample rate) to prevent capturing health-related screen content.

### Ignored Errors

The following are filtered at the SDK level to reduce noise:
- `ResizeObserver loop` — benign browser observation
- `Non-Error promise rejection` — usually third-party scripts
- `Loading chunk X failed` — transient network issues during code splitting
- `Failed to fetch dynamically imported module` — same as above
- `AbortError` — intentional request cancellation

## Request ID Correlation

Every request gets a UUID correlation ID:

1. **Middleware** generates `X-Request-Id` (or preserves incoming header)
2. **Response header** `X-Request-Id` is set on all responses
3. **Structured logs** include `requestId` for correlation
4. **Sentry events** include `requestId` as a tag for cross-referencing

## Error Reporting Flow

### Frontend Errors

```
React component throws
  → ErrorBoundary.componentDidCatch()
    → reportBoundaryError() in error-reporter.ts
      → Sentry.captureException() with component stack + context
      → console.error() in development
```

### Route Segment Errors

```
Route segment throws
  → error.tsx useEffect
    → Sentry.captureException() with boundary tag
    → console.error() in development
```

### Root Layout Errors

```
Root layout throws
  → global-error.tsx useEffect
    → Sentry.captureException() with global-error tag
```

### API Route Errors

```
API handler throws
  → logger.error() with structured JSON
  → Sentry.captureException() with request context
  → Error re-thrown for Next.js default handling
```

## Alert Rules (Sentry)

Configure these in the Sentry dashboard:

| Rule           | Condition                            | Action         | Priority |
| -------------- | ------------------------------------ | -------------- | -------- |
| Error spike    | > 5 errors/min for 5 min             | Slack + Email  | P1       |
| New issue      | First occurrence of unseen error     | Notification   | P2       |
| API latency    | P95 > 3s for 5 min                   | Warning        | P2       |
| Health failure | 3 consecutive `/api/health` failures | Critical alert | P0       |

## Source Maps

- Uploaded to Sentry during CI build via `@sentry/nextjs` webpack plugin
- **Not publicly exposed** (`hideSourceMaps: true` in `next.config.ts`)
- Requires `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` in CI environment
- Enables readable stack traces in Sentry error reports

## Incident Runbook

### 1. Error Spike Alert

1. Open Sentry → check error grouping and affected routes
2. Check if deployment-correlated (Vercel dashboard → recent deploys)
3. If regression: revert deploy, investigate locally
4. If external: check Supabase status, third-party APIs

### 2. API Latency Alert

1. Open Sentry Performance → sort by P95
2. Cross-reference with Vercel function logs (filter `level: "warn"`)
3. Check Supabase → SQL Editor → `pg_stat_statements` for slow queries
4. If DB-related: check for missing indexes, materialized view staleness

### 3. Health Endpoint Failure

1. Check `/api/health` response directly
2. Verify Supabase project status (dashboard or CLI)
3. Check Vercel function logs for structured error output
4. If Supabase paused: wake project, wait for recovery
5. If persistent: escalate to infrastructure review

### 4. New Error Type

1. Review error in Sentry with full stack trace
2. Check if reproducible locally
3. If bug: create issue, fix, deploy
4. If noise: add to `ignoreErrors` list in Sentry config

## Rollback Plan

Each component is independently removable:

| Component                | Rollback Steps                                                               | Impact                                   |
| ------------------------ | ---------------------------------------------------------------------------- | ---------------------------------------- |
| Sentry SDK               | Remove `withSentryConfig` from `next.config.ts`, delete `sentry.*.config.ts` | No telemetry, app works normally         |
| Structured logger        | Revert to `console.log` in API routes                                        | No structured logs, no behavioral change |
| Error boundary reporting | Remove `Sentry.captureException` from `error-reporter.ts`                    | Errors only logged to console            |
| Request ID middleware    | Remove UUID generation from `middleware.ts`                                  | No correlation headers                   |
| **Total rollback time**  | **< 15 minutes (single PR revert)**                                          |                                          |

## Files Modified / Created

| File                             | Type     | Description                         |
| -------------------------------- | -------- | ----------------------------------- |
| `src/lib/logger.ts`              | New      | Structured JSON logger              |
| `src/lib/api-instrumentation.ts` | New      | API route wrapper (HOF)             |
| `src/instrumentation-client.ts`  | New      | Client-side Sentry init (Turbopack) |
| `sentry.server.config.ts`        | New      | Server-side Sentry init             |
| `sentry.edge.config.ts`          | New      | Edge runtime Sentry init            |
| `src/instrumentation.ts`         | New      | Next.js instrumentation hook        |
| `src/middleware.ts`              | Modified | Added X-Request-Id                  |
| `src/lib/error-reporter.ts`      | Modified | Added Sentry reporting              |
| `src/app/error.tsx`              | Modified | Added Sentry capture                |
| `src/app/global-error.tsx`       | Modified | Added Sentry capture                |
| `src/app/api/health/route.ts`    | Modified | Added structured logging            |
| `src/app/auth/callback/route.ts` | Modified | Added logging + error handling      |
| `next.config.ts`                 | Modified | Added `withSentryConfig`, CSP       |
| `.env.local.example`             | Modified | Added Sentry DSN vars               |
| `.env.example`                   | Modified | Added Sentry build vars             |
| `docs/OBSERVABILITY.md`          | New      | This document                       |
