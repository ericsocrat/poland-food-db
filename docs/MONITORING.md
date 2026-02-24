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

### UptimeRobot (Free Tier — Recommended)

UptimeRobot provides 50 free HTTP monitors with 5-minute intervals.

#### Step-by-step setup

1. Create an account at <https://uptimerobot.com> (no credit card required)
2. Go to **Dashboard → Add New Monitor**
3. Configure the monitor:

| Setting | Value |
| ------- | ----- |
| Monitor Type | HTTP(s) |
| Friendly Name | `Poland Food DB — Production` |
| URL | `https://your-domain.vercel.app/api/health` |
| Monitoring Interval | 5 minutes |
| Monitor Timeout | 10 seconds |

4. Under **Alert Contacts**, add your preferred notification method:
   - Email (included free)
   - Slack webhook (included free)
   - Discord webhook (included free)
5. Under **Advanced Settings**:
   - HTTP Method: `GET`
   - Alert after: **2 consecutive failures** (avoids false-positives from transient Vercel cold-starts)
   - HTTP status: Alert when status ≠ `200`
6. Click **Create Monitor**

#### Optional keyword monitoring

Add a keyword monitor alongside the HTTP monitor:

| Setting | Value |
| ------- | ----- |
| Monitor Type | Keyword |
| URL | Same as above |
| Keyword Value | `"status":"unhealthy"` |
| Alert When | Keyword **exists** |

This catches degraded-but-200 responses that the HTTP status check alone would miss.

### BetterStack (Alternative)

BetterStack offers a generous free tier with more granular alerting.

#### Setup

1. Create an account at <https://betterstack.com>
2. Go to **Uptime → Monitors → Create Monitor**
3. Configure:

| Setting | Value |
| ------- | ----- |
| URL | `https://your-domain.vercel.app/api/health` |
| Check period | 3 minutes |
| Request timeout | 10 seconds |
| Regions | EU West + US East (at minimum) |
| Expected status | 200 |

4. Under **On-call → Escalation Policies**, configure the escalation chain (see below)
5. Create an incident when HTTP status ≠ 200 for 2 consecutive checks

### Alert Thresholds

| Condition | Threshold | Action |
| --------- | --------- | ------ |
| HTTP status ≠ 200 | 2 consecutive failures | Trigger alert |
| Response time | > 5000 ms | Trigger warning |
| Response time | > 10000 ms | Trigger critical alert |
| Downtime duration | > 2 minutes | Escalate (see below) |
| SSL certificate expiry | < 14 days | Email warning |

### Escalation Path

| Time after alert | Channel | Contact |
| ---------------- | ------- | ------- |
| 0 min | Email | `your-email@example.com` |
| 5 min | Slack / Discord | `#alerts` channel webhook |
| 15 min | Phone / SMS | `+1-XXX-XXX-XXXX` (on-call) |

> **Note:** Replace placeholder contacts with actual values when configuring.
> Phone escalation is optional — only configure if you have a paid plan that supports it.

### SLA Target

| Metric | Target | Budget |
| ------ | ------ | ------ |
| Uptime | **99.5%** | ~3.6 hours downtime / month |
| Health endpoint response time | < 2 seconds | p95 |
| Incident acknowledgment | < 15 minutes | During business hours |
| Incident resolution | < 2 hours | For `unhealthy` status |

> The 99.5% SLA is a **documented target**, not an enforced SLO.
> It serves as a planning guide for monitoring frequency and escalation urgency.

### Post-Deploy Verification

After every deployment, the CI pipeline automatically verifies health:

1. `deploy.yml` pushes migrations to Supabase
2. Waits 30 seconds for edge functions to stabilize
3. Curls `/api/health` and asserts HTTP 200
4. If health check fails → deployment is marked as failed in GitHub Actions
5. Inspect the step summary for response body details

#### Manual verification

```bash
# Quick check
curl -s https://your-domain.vercel.app/api/health | jq '.status'
# Expected: "healthy"

# Full response
curl -s https://your-domain.vercel.app/api/health | jq .

# With timing
curl -o /dev/null -s -w "HTTP %{http_code} in %{time_total}s\n" \
  https://your-domain.vercel.app/api/health
```

If unhealthy after deploy, see [Rollback Procedures](../DEPLOYMENT.md#rollback-procedures) (Issue #121).

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

| Condition | Who | Action | SLA |
| --------- | --- | ------ | --- |
| Status `degraded` for > 1 hour | Developer | Check MV refresh schedule, run pipeline | Acknowledge < 15 min |
| Status `unhealthy` | Developer | Check DB connectivity, verify product count | Resolve < 2 hours |
| Utilization > 90% | Project lead | Plan capacity: cleanup deprecated products or upgrade Supabase tier | Plan within 24 hours |
| Post-deploy health check fails | Developer | Inspect step summary, consider rollback | Immediate |

> See [Alert Thresholds](#alert-thresholds) and [SLA Target](#sla-target) above for numeric targets.

## Files

| File | Purpose |
| ---- | ------- |
| `supabase/migrations/20260222000400_health_check_monitoring.sql` | RPC function |
| `frontend/src/app/api/health/route.ts` | Next.js API route |
| `frontend/src/app/api/health/route.test.ts` | Unit tests (15 tests) |
| `frontend/src/app/api/health/health-contract.test.ts` | Zod contract test (16 tests) |
| `frontend/src/app/app/admin/monitoring/page.tsx` | Admin dashboard |
| `frontend/src/lib/supabase/service.ts` | Service-role client |
| `.github/workflows/deploy.yml` | Deploy workflow with post-deploy health check |
| `db/qa/QA__monitoring.sql` | QA suite (7 checks) |
