# Business Metrics Dashboard

> Issue #188 — [Hardening 7/7] Platform usage analytics and engagement tracking.

## Overview

Poland Food DB tracks **10 core business metrics** via database-native analytics.
All events flow through the existing `analytics_events` table (created in #25)
and are surfaced on the admin dashboard at `/admin/metrics`.

No external analytics service is required — all data stays in Supabase.

## Architecture

```
Frontend (track calls)
  └─ useAnalytics() → api_track_event RPC
       └─ INSERT into analytics_events

Nightly Aggregation (pg_cron 01:00 UTC)
  └─ aggregate_daily_metrics()
       └─ UPSERT into analytics_daily

Admin Dashboard (/admin/metrics)
  └─ api_admin_get_business_metrics RPC
       └─ Reads metric_*() functions + analytics_daily
```

## 10 Core Metrics

| # | Metric | Function | Description |
|---|--------|----------|-------------|
| 1 | **Daily Active Users (DAU)** | `metric_dau(date)` | Distinct authenticated users with any event on given date |
| 2 | **Searches Per Day** | `metric_searches_per_day(date)` | Total `search_performed` events on given date |
| 3 | **Top Search Queries** | `metric_top_queries(date, limit)` | Most frequent search query strings, ranked by count |
| 4 | **Failed Searches** | `metric_failed_searches(date)` | Searches that returned 0 results (`result_count = 0`) |
| 5 | **Top Viewed Products** | `metric_top_products(date, limit)` | Products ranked by `product_viewed` event count |
| 6 | **Allergen Profile Distribution** | `metric_allergen_distribution()` | Which allergens users avoid most, from `user_preferences.avoid_allergens` |
| 7 | **Feature Usage** | `metric_feature_usage(start, end)` | Event type breakdown with unique user counts |
| 8 | **Scan vs Search Ratio** | `metric_scan_vs_search(date)` | Barcode scans vs text searches as counts + percentages |
| 9 | **Onboarding Funnel** | `metric_onboarding_funnel(start, end)` | Step-by-step completion rates from `onboarding_step` events |
| 10 | **Category Popularity** | `metric_category_popularity(date)` | Categories ranked by product/category view counts |

## Event Types

Events tracked for metrics (subset of all `analytics_events` types):

| Event Name | Trigger | Key `event_data` Fields |
|------------|---------|-------------------------|
| `search_performed` | User searches | `query`, `result_count`, `has_filters` |
| `product_viewed` | Product detail page | `product_id`, `product_name`, `category` |
| `scanner_used` | Barcode scan | `ean`, `found`, `method` |
| `filter_applied` | Filter change | `filters` |
| `compare_opened` | Compare view | — |
| `category_viewed` | Category browse | `category` |
| `onboarding_step` | Wizard navigation | `step`, `step_index`, `direction` |
| `onboarding_completed` | Wizard finish/skip | `skipped`, `diet`, `allergen_count`, etc. |
| `recipe_view` | Recipe detail page | `recipe_id` |

## Pre-Aggregation

The `analytics_daily` table stores nightly-aggregated values for fast dashboard queries:

| Metric Key | Source |
|------------|--------|
| `dau` | `metric_dau()` |
| `searches` | `metric_searches_per_day()` |
| `scans` | Count of `scanner_used` events |
| `product_views` | Count of `product_viewed` events |
| `failed_searches` | Searches with `result_count = 0` |
| `onboarding_completions` | Count of `onboarding_completed` events |
| `unique_scanners` | Distinct users who used scanner |

**Schedule:** `aggregate_daily_metrics()` runs via pg_cron at 01:00 UTC daily, aggregating the previous day.

## Admin Dashboard

**Route:** `/app/admin/metrics` (protected by middleware — `ADMIN_EMAILS` allow-list)

**Features:**
- 4 summary cards: DAU, searches, failed searches, scan vs search ratio
- Top queries table (top 20)
- Top products table (top 20)
- Feature usage horizontal bar chart
- Allergen distribution bars
- Scan vs search visual split
- Onboarding funnel table with completion rates
- Category popularity table
- Date range selector: 7 / 14 / 30 / 90 days
- JSON export button
- Manual refresh button
- Trend sparklines from `analytics_daily` data

**RPC:** Single call to `api_admin_get_business_metrics(p_date, p_days)` returns all 10 metrics + trend data.

## Data Retention

- **Raw events** (`analytics_events`): Retain 90 days minimum. Archive or purge older records.
- **Daily aggregates** (`analytics_daily`): Retain indefinitely (365 rows/year per metric).
- **Event insertion overhead**: < 5ms per event, async (fire-and-forget).
- **Dashboard query time**: < 500ms via pre-aggregated data.

## Security

- **PII**: Event data never contains email, health conditions, or passwords. Only UUIDs and aggregate-safe metadata.
- **RLS**: `analytics_events` — users can INSERT own events; no SELECT for non-service-role. `analytics_daily` — no public SELECT; only via SECURITY DEFINER functions.
- **Session ID**: Client-generated, stored in `sessionStorage` (not persistent). No cross-session tracking.
- **Admin access**: Enforced by middleware (`ADMIN_EMAILS` env var) + SECURITY DEFINER on metric functions.
- **Metric functions**: All 10 use `SECURITY DEFINER` with `SET search_path = public` — callers never read raw tables directly.

## Monitoring

- Track `analytics_events` table size monthly
- Monitor pg_cron aggregation job success
- Alert if DAU drops to 0 (tracking may be broken)
- Dashboard load time target: < 2 seconds

## Rollback Plan

1. Remove `track("onboarding_step", ...)` calls from `OnboardingWizard.tsx`
2. Drop admin metrics page (`/admin/metrics`)
3. Drop migration `20260223000000_business_metrics_dashboard.sql` (tables + functions)
4. **Total rollback time**: < 15 minutes (single revert PR)

## Files

| File | Purpose |
|------|---------|
| `supabase/migrations/20260223000000_business_metrics_dashboard.sql` | Tables, functions, grants, pg_cron |
| `supabase/tests/business_metrics_functions.test.sql` | pgTAP tests for all metric functions |
| `frontend/src/app/app/admin/metrics/page.tsx` | Admin dashboard page |
| `frontend/src/app/app/admin/metrics/page.test.tsx` | Dashboard component tests |
| `frontend/src/lib/types.ts` | `BusinessMetricsResponse` type + new event names |
| `frontend/src/lib/api.ts` | `getBusinessMetrics()` RPC wrapper |
| `frontend/src/lib/query-keys.ts` | `adminMetrics` key + stale time |
| `frontend/src/app/onboarding/OnboardingWizard.tsx` | Per-step tracking (`onboarding_step`) |
| `frontend/messages/en.json` | English i18n keys |
| `frontend/messages/pl.json` | Polish i18n keys |
| `docs/METRICS.md` | This document |
