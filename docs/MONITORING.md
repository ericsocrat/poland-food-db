# Monitoring & Health Check

> Issue #119 — Automated health monitoring for the Poland Food DB.

## Architecture

```
UptimeRobot / cron ──► GET /api/health ──► service_role client ──► api_health_check() RPC
                            │
                            ▼
                       200 or 503 JSON

Admin dashboard ──► /app/admin/monitoring ──► fetch(/api/health) ──► auto-refresh 60 s
```

## Health Endpoint

**URL:** `GET /api/health`

**Authentication:** None required (the endpoint calls Supabase via `service_role` key server-side).

**Cache:** `Cache-Control: no-store` — every request is live.

### Response Shape

```json
{
  "status": "healthy",
  "checks": {
    "connectivity": true,
    "mv_staleness": {
      "mv_ingredient_frequency": {
        "mv_rows": 487,
        "source_rows": 487,
        "stale": false
      },
      "v_product_confidence": {
        "mv_rows": 3012,
        "source_rows": 3012,
        "stale": false
      }
    },
    "row_counts": {
      "products": 3012,
      "ceiling": 15000,
      "utilization_pct": 20.1
    }
  },
  "timestamp": "2026-02-22T14:35:00Z"
}
```

### HTTP Status Codes

| Code | Meaning |
| ---- | ------- |
| 200  | `healthy` or `degraded` — system is operational |
| 503  | `unhealthy` or connection failure — investigation required |

### Status Logic

| Status     | Trigger |
| ---------- | ------- |
| `healthy`  | All checks pass, utilization < 80% |
| `degraded` | MV is stale **OR** utilization 80–95% |
| `unhealthy`| Product count = 0 **OR** utilization > 95% **OR** DB connection failure |

## Checks Explained

### Connectivity

Returns `true` if the RPC executes successfully. Returns `false` (503) if the Supabase database is unreachable.

### Materialized View Staleness

Compares row counts between:
- `mv_ingredient_frequency` vs `COUNT(DISTINCT ingredient_id)` in `product_ingredient`
- `v_product_confidence` vs active product count

If counts differ, the MV is flagged as stale. This usually means `REFRESH MATERIALIZED VIEW` hasn't run after the last pipeline execution.

**Fix:** Run the MV refresh (triggered automatically by `ci_post_pipeline.sql`).

### Row Count / Capacity

Tracks active products (non-deprecated) against a ceiling of 15,000. Designed for Supabase Free tier capacity planning.

| Utilization | Status    | Action |
| ----------- | --------- | ------ |
| < 80%       | healthy   | None |
| 80–95%      | degraded  | Plan cleanup or tier upgrade |
| > 95%       | unhealthy | Immediate action: deprecate unused products or upgrade plan |

## Admin Dashboard

**URL:** `/app/admin/monitoring`

**Access:** Requires authentication (admin role recommended). Protected by existing auth middleware.

**Features:**
- Overall status banner with color-coded indicators (green/yellow/red)
- MV staleness cards for each materialized view
- Product row count gauge with progress bar
- Auto-refresh every 60 seconds
- TanStack Query with 30 s stale time

## External Monitoring Setup

### UptimeRobot (Free Tier)

1. Create a new HTTP(s) monitor
2. URL: `https://your-domain.vercel.app/api/health`
3. Monitoring interval: 5 minutes
4. Alert contacts: Configure email/Slack/webhook
5. Keyword monitoring: Look for `"status":"unhealthy"` as a down condition, OR monitor for non-200 status code

### cURL Smoke Test

```bash
curl -s https://your-domain.vercel.app/api/health | jq '.status'
# Expected: "healthy"
```

## QA Suite

**Suite #30: Monitoring & Health Check** — 7 checks in `QA__monitoring.sql`

| # | Check |
| - | ----- |
| 1 | `api_health_check()` returns valid JSONB |
| 2 | Status is valid enum (healthy/degraded/unhealthy) |
| 3 | Top-level keys present (status, checks, timestamp) |
| 4 | MV staleness values are non-negative |
| 5 | Row count matches actual product count |
| 6 | Connectivity is true |
| 7 | Timestamp is valid ISO-8601 format |

## Environment Variables

The health endpoint requires these server-side environment variables:

| Variable | Purpose |
| -------- | ------- |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (server-side only, never exposed to client) |

Both are already configured in Vercel for production.

## Security

- `api_health_check()` is `SECURITY DEFINER` — runs as the function owner
- Access is restricted: `REVOKE ALL FROM PUBLIC/anon/authenticated`, `GRANT TO service_role` only
- The API route sanitizes the response shape to prevent data leaks
- No secrets, connection strings, or infrastructure details are exposed
- The `/api/health` route is excluded from auth middleware (matcher already excludes `/api`)

## Escalation

| Condition | Who | Action |
| --------- | --- | ------ |
| Status `degraded` for > 1 hour | Developer | Check MV refresh schedule, run pipeline |
| Status `unhealthy` | Developer | Check DB connectivity, verify product count |
| Utilization > 90% | Project lead | Plan capacity: cleanup deprecated products or upgrade Supabase tier |

## Files

| File | Purpose |
| ---- | ------- |
| `supabase/migrations/20260222000400_health_check_monitoring.sql` | RPC function |
| `frontend/src/app/api/health/route.ts` | Next.js API route |
| `frontend/src/app/app/admin/monitoring/page.tsx` | Admin dashboard |
| `frontend/src/lib/supabase/service.ts` | Service-role client |
| `db/qa/QA__monitoring.sql` | QA suite (7 checks) |
