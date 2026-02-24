# UX Impact Metrics Standard

> **Last updated:** 2026-02-28
> **Issue:** #230 (GOV-H3)
> **Parent:** #195 (Execution Governance Blueprint)
> **Status:** Active — metric catalog defined; measurement pending #190 (Event Analytics)

---

## 1. Overview

Every UX issue MUST define exactly **1 primary impact metric**. Correctness criteria ("feature works") are acceptance criteria — they are necessary but insufficient. Impact metrics answer: **"Did this feature improve the user experience?"**

**Rule:** No UX issue is considered validated until its impact metric is measured post-deploy.

---

## 2. UX Impact Metric Template

Every UX issue (current and future) must include this section:

```markdown
## UX Impact Metric

| Field | Value |
|---|---|
| Metric name | {e.g., "Autocomplete selection rate"} |
| Event type | {e.g., `search_autocomplete_select`} |
| Definition | {What exactly is measured} |
| Baseline | {Current value or "N/A — new feature"} |
| Target | {Expected improvement after shipping} |
| Measurement method | {SQL query / dashboard / Lighthouse / manual} |
| Measurement cadence | {Daily / weekly / on-demand} |
```

**Rules:**
- Exactly **1 metric per issue** (not zero, not five — one)
- Metric must be telemetry-trackable (maps to an `analytics_events` event type)
- Metric must have a target (even if estimated or "track baseline")
- "Ships correctly" is NOT a metric — that is acceptance criteria
- Web Vitals (LCP, CLS, INP) are acceptable metrics for performance-focused issues

---

## 3. Event Naming Convention

All UX events follow the pattern: **`{domain}_{object}_{action}`**

| Domain | Scope |
|--------|-------|
| `search` | Search input, autocomplete, results, saved searches |
| `filter` | Filter panel, active chips, allergen/diet/category filters |
| `category` | Category browsing, subcategory drill-down |
| `product` | Product detail views, interactions |
| `score` | Score bar, breakdown animation, "why this score?" |
| `compare` | Comparison grid, share, add-to-list from comparison |
| `badge` | Badge icons, Nova indicators, traffic lights |
| `page` | Page-level metrics: LCP, bounce, pull-to-refresh |
| `list` | Product lists, sharing, reordering |
| `scan` | Barcode scanner, manual EAN entry |

| Action | Meaning |
|--------|---------|
| `select` | User chose an item from options |
| `view` | User viewed a component/page |
| `apply` | User applied a setting/filter |
| `remove` | User removed/dismissed something |
| `share` | User initiated sharing |
| `complete` | User reached end of a flow |
| `interact` | General interaction (hover, tap, click) |
| `retry` | User retried after failure |

**Examples:** `search_autocomplete_select`, `filter_allergen_apply`, `compare_share`, `score_explanation_view`

### Alignment with Existing Event Schema

The `analytics_events` table (see `20260223000000_business_metrics_dashboard.sql`) currently defines 34 event types via `chk_ae_event_name`. The UX metric events listed below are **future additions** — they will be added to the CHECK constraint and `AnalyticsEventName` TypeScript union when #190 (Event Analytics) ships.

Existing events that already serve as UX metrics:
| Existing Event | Reused For |
|----------------|------------|
| `search_performed` | #121 filter engagement (denominator) |
| `filter_applied` | #121 filter engagement, #122 filter clarity |
| `compare_opened` | #133 comparison completion (start) |
| `category_viewed` | #125 category entry (existing) |
| `product_viewed` | #130 score engagement (denominator) |

---

## 4. Metric Catalog — UX Issues #118–#137

Every closed UX issue has a defined impact metric. These are measured once #190 event infrastructure ships.

### Search & Discovery (#118–#123)

| Issue | Feature | Primary Metric | Event Type | Target | Measurement |
|-------|---------|---------------|------------|--------|-------------|
| #118 | Search autocomplete | **Autocomplete selection rate** — % of searches where user selects a suggestion | `search_autocomplete_select` | >30% of searches use autocomplete | `count(autocomplete_select) / count(search_performed)` |
| #119 | Recent searches | **Recent search re-use rate** — % of searches initiated from history | `search_recent_select` | >15% of returning users | `count(recent_select) / count(DISTINCT user_id WHERE visit > 1)` |
| #120 | Saved searches | **Saved search re-execution rate** — % of saved searches re-run within 7 days | `search_saved_execute` | >50% of saved searches re-used | `count(saved_execute) / count(search_saved)` over 7d window |
| #121 | Filter panel | **Filter engagement rate** — % of search sessions applying ≥1 filter | `filter_apply` (reuses `filter_applied`) | >20% of search sessions | `sessions_with_filter / total_search_sessions` |
| #122 | Active filter chips | **Filter clarity rate** — % of filter interactions that are removals | `filter_remove` | <30% removal rate (low = clear) | `count(filter_remove) / count(filter_applied + filter_remove)` |
| #123 | No-results state | **Zero-result recovery rate** — % of zero-result screens leading to modified search | `search_no_results_retry` | >40% retry after zero results | `count(retry_after_zero) / count(zero_result_shown)` |

### Category & Browse (#124–#126)

| Issue | Feature | Primary Metric | Event Type | Target | Measurement |
|-------|---------|---------------|------------|--------|-------------|
| #124 | Allergen filter chips | **Allergen filter adoption** — % of users with allergen prefs who use chips | `filter_allergen_select` | >50% of allergen-configured users | `users_using_allergen_filter / users_with_allergen_prefs` |
| #125 | Category browse | **Category entry rate** — % of sessions entering via category vs search | `category_browse_enter` (reuses `category_viewed`) | Track baseline (discovery metric) | `sessions_via_category / total_sessions` |
| #126 | Category → subcategory | **Subcategory drill-down rate** — % of category views that drill into subcategory | `category_subcategory_select` | >25% drill-down | `count(subcategory_select) / count(category_viewed)` |

### Performance & Visual (#127–#129)

| Issue | Feature | Primary Metric | Event Type | Target | Measurement |
|-------|---------|---------------|------------|--------|-------------|
| #127 | Image optimization | **LCP improvement** — Largest Contentful Paint on product detail | Web Vital: `page_lcp` | LCP ≤ 2.5s on mobile | Lighthouse CI / Web Vitals API |
| #128 | Badge icons | **Badge comprehension** — % of badge hovers/clicks (seeking explanation) | `badge_interact` | <20% click rate (low = intuitive) | `count(badge_interact) / count(product_viewed)` |
| #129 | Skeleton loaders | **Perceived load time** — bounce rate on slow connections | `page_bounce` | <5% bounce on product pages | `bounces / page_views WHERE connection = 'slow-2g\|2g\|3g'` |

### Engagement & Interaction (#130–#137)

| Issue | Feature | Primary Metric | Event Type | Target | Measurement |
|-------|---------|---------------|------------|--------|-------------|
| #130 | Score spectrum bar | **Score engagement** — % of product views with score bar interaction | `score_bar_interact` | Track baseline | `count(score_bar_interact) / count(product_viewed)` |
| #131 | Sort indicator | **Sort toggle rate** — sort changes per session (high = confusion) | `search_sort_change` | <3 changes per session | `count(sort_change) / count(DISTINCT session_id)` |
| #132 | Pull-to-refresh | **Refresh frequency** — pull-to-refresh uses per session | `page_pull_refresh` | Track baseline | `count(pull_refresh) / count(DISTINCT session_id)` |
| #133 | Product comparison | **Comparison completion rate** — % of comparison starts reaching grid view | `compare_complete` | >60% completion | `count(compare_complete) / count(compare_opened)` |
| #134 | Share comparison | **Share rate** — % of completed comparisons shared | `compare_share` | >10% share rate | `count(compare_share) / count(compare_complete)` |
| #135 | Add-to-list from compare | **List add from compare** — % resulting in ≥1 product added to list | `compare_add_to_list` | >20% conversion | `count(compare_add_to_list) / count(compare_complete)` |
| #136 | Score animation | **Animation engagement** — % of score taps that wait for full animation | `score_animation_view` | >70% view completion | `count(animation_complete) / count(animation_start)` |
| #137 | "Why this score?" | **Explanation view rate** — % of product views opening score explanation | `score_explanation_view` | >15% of product views | `count(explanation_view) / count(product_viewed)` |

---

## 5. Measurement SQL Templates

All queries return meaningful results on an empty `analytics_events` table (0 rows → 0%, not an error).

### 5.1 Rate Metric (Generic)

```sql
-- Generic rate metric template
-- Replace {numerator_event} and {denominator_event} with actual event types
SELECT
    CASE WHEN denom.total = 0 THEN 0
         ELSE ROUND(numer.total * 100.0 / denom.total, 1)
    END AS rate_pct,
    numer.total AS numerator,
    denom.total AS denominator,
    current_date AS measured_at
FROM (
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = '{numerator_event}'
      AND created_at >= current_date - interval '7 days'
) numer,
(
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = '{denominator_event}'
      AND created_at >= current_date - interval '7 days'
) denom;
```

### 5.2 Autocomplete Selection Rate (#118)

```sql
-- Metric: Autocomplete selection rate
-- Target: >30%
SELECT
    CASE WHEN searches.total = 0 THEN 0
         ELSE ROUND(autocomplete.total * 100.0 / searches.total, 1)
    END AS autocomplete_selection_rate_pct,
    autocomplete.total AS autocomplete_selects,
    searches.total AS total_searches,
    current_date AS measured_at
FROM (
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = 'search_autocomplete_select'
      AND created_at >= current_date - interval '7 days'
) autocomplete,
(
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = 'search_performed'
      AND created_at >= current_date - interval '7 days'
) searches;
```

### 5.3 Filter Engagement Rate (#121)

```sql
-- Metric: Filter engagement rate
-- Target: >20% of search sessions use filters
SELECT
    CASE WHEN total_sessions.cnt = 0 THEN 0
         ELSE ROUND(filtered_sessions.cnt * 100.0 / total_sessions.cnt, 1)
    END AS filter_engagement_rate_pct,
    filtered_sessions.cnt AS sessions_with_filter,
    total_sessions.cnt AS total_search_sessions,
    current_date AS measured_at
FROM (
    SELECT count(DISTINCT session_id) AS cnt
    FROM public.analytics_events
    WHERE event_name = 'filter_applied'
      AND created_at >= current_date - interval '7 days'
) filtered_sessions,
(
    SELECT count(DISTINCT session_id) AS cnt
    FROM public.analytics_events
    WHERE event_name = 'search_performed'
      AND created_at >= current_date - interval '7 days'
) total_sessions;
```

### 5.4 Comparison Completion Rate (#133)

```sql
-- Metric: Comparison completion rate
-- Target: >60%
SELECT
    CASE WHEN opens.total = 0 THEN 0
         ELSE ROUND(completes.total * 100.0 / opens.total, 1)
    END AS comparison_completion_rate_pct,
    completes.total AS comparisons_completed,
    opens.total AS comparisons_opened,
    current_date AS measured_at
FROM (
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = 'compare_complete'
      AND created_at >= current_date - interval '7 days'
) completes,
(
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = 'compare_opened'
      AND created_at >= current_date - interval '7 days'
) opens;
```

### 5.5 Per-Session Rate (Sort Toggle, Pull-to-Refresh)

```sql
-- Metric: Sort changes per session (#131)
-- Target: <3 changes per session
SELECT
    CASE WHEN sessions.cnt = 0 THEN 0
         ELSE ROUND(changes.total * 1.0 / sessions.cnt, 2)
    END AS sort_changes_per_session,
    changes.total AS total_sort_changes,
    sessions.cnt AS total_sessions,
    current_date AS measured_at
FROM (
    SELECT count(*) AS total
    FROM public.analytics_events
    WHERE event_name = 'search_sort_change'
      AND created_at >= current_date - interval '7 days'
) changes,
(
    SELECT count(DISTINCT session_id) AS cnt
    FROM public.analytics_events
    WHERE created_at >= current_date - interval '7 days'
) sessions;
```

### 5.6 Weekly Metric Summary Dashboard

```sql
-- All UX impact metrics in one query (weekly)
WITH events AS (
    SELECT event_name, session_id, user_id, created_at
    FROM public.analytics_events
    WHERE created_at >= current_date - interval '7 days'
),
counts AS (
    SELECT event_name, count(*) AS cnt
    FROM events
    GROUP BY event_name
),
sessions AS (
    SELECT count(DISTINCT session_id) AS total FROM events
)
SELECT
    'autocomplete_selection_rate' AS metric,
    COALESCE(
        ROUND((SELECT cnt FROM counts WHERE event_name = 'search_autocomplete_select') * 100.0
              / NULLIF((SELECT cnt FROM counts WHERE event_name = 'search_performed'), 0), 1),
        0
    ) AS value_pct,
    '>30%' AS target
UNION ALL
SELECT
    'filter_engagement_rate',
    COALESCE(
        ROUND((SELECT count(DISTINCT session_id) FROM events WHERE event_name = 'filter_applied') * 100.0
              / NULLIF((SELECT total FROM sessions), 0), 1),
        0
    ),
    '>20%'
UNION ALL
SELECT
    'comparison_completion_rate',
    COALESCE(
        ROUND((SELECT cnt FROM counts WHERE event_name = 'compare_complete') * 100.0
              / NULLIF((SELECT cnt FROM counts WHERE event_name = 'compare_opened'), 0), 1),
        0
    ),
    '>60%'
UNION ALL
SELECT
    'score_explanation_view_rate',
    COALESCE(
        ROUND((SELECT cnt FROM counts WHERE event_name = 'score_explanation_view') * 100.0
              / NULLIF((SELECT cnt FROM counts WHERE event_name = 'product_viewed'), 0), 1),
        0
    ),
    '>15%'
UNION ALL
SELECT
    'share_rate',
    COALESCE(
        ROUND((SELECT cnt FROM counts WHERE event_name = 'compare_share') * 100.0
              / NULLIF((SELECT cnt FROM counts WHERE event_name = 'compare_complete'), 0), 1),
        0
    ),
    '>10%';
```

---

## 6. UI Performance Budget

UX issues that introduce **new UI components** must also include a performance budget:

```markdown
## UI Performance Budget

- [ ] Component render time: ≤{X}ms (React Profiler or Lighthouse user timing)
- [ ] Image payload: ≤{X}KB per image (compressed, WebP/AVIF preferred)
- [ ] Total page payload: ≤{X}KB above the fold
- [ ] LCP impact: must not regress LCP beyond 2.5s
- [ ] CLS impact: must not regress CLS beyond 0.1
- [ ] INP impact: must not regress INP beyond 200ms
- [ ] API call budget: ≤{N} RPC calls for this component
- [ ] Caching strategy: {TanStack Query staleTime / CDN headers}
```

**Reference budgets** (from Lighthouse CI quality gate):

| Metric | Mobile | Desktop |
|--------|--------|---------|
| LCP | ≤ 2.5s | ≤ 1.5s |
| CLS | ≤ 0.1 | ≤ 0.1 |
| INP | ≤ 200ms | ≤ 100ms |
| Performance score | ≥ 70 | ≥ 85 |
| Image payload (per image) | ≤ 100KB | ≤ 150KB |

---

## 7. PR Checklist Integration

Every PR that touches UX-visible frontend code must confirm:

- [ ] UX issues referenced in this PR have an **Impact Metric section** (per §2 template)
- [ ] New event types are documented in this catalog (§4)
- [ ] Event names follow the `{domain}_{object}_{action}` convention (§3)
- [ ] Measurement SQL template provided or existing template referenced (§5)
- [ ] UI Performance Budget completed (§6) if new component introduced

---

## 8. Measurement Lifecycle

```
Feature Issue → Define Metric → Ship Feature → Collect Baseline (1 week) → Set Target → Monitor Weekly
```

| Phase | Duration | Action |
|-------|----------|--------|
| Define | At issue creation | Add UX Impact Metric section using §2 template |
| Ship | During implementation | Instrument event emission in frontend |
| Baseline | First 7 days post-deploy | Measure actual rate (no target enforcement) |
| Validate | After baseline | Compare against target; decide: adjust feature, adjust target, or accept |
| Monitor | Ongoing (weekly) | Run §5.6 dashboard query; alert on >20% regression from baseline |

**Baseline-first rule:** The first month after shipping any metric is baseline collection. Targets are estimates that will be adjusted based on real data. No feature is judged against its target until at least 2 weeks of data.

---

## 9. Future UX Event Types

These event types will be added to `analytics_events.chk_ae_event_name` and `AnalyticsEventName` in TypeScript when #190 ships:

```
search_autocomplete_select
search_recent_select
search_saved_execute
search_no_results_retry
search_sort_change
filter_remove
filter_allergen_select
category_browse_enter        (may reuse category_viewed)
category_subcategory_select
badge_interact
page_lcp                     (Web Vital — may use browser API, not DB event)
page_bounce                  (derived from session duration < threshold)
page_pull_refresh
score_bar_interact
score_animation_view
score_explanation_view
compare_complete
compare_share                (may reuse share_link_opened with context)
compare_add_to_list
```

**Note:** Some events may be derived from existing events with additional `context` payloads rather than new `event_name` values. The final implementation in #190 will determine the exact schema.

---

## 10. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| #190 not shipped when UX metrics needed | High | Medium | Metrics defined now, measured when events ship |
| Too many event types to manage | Medium | Low | Start with top 10; expand incrementally |
| Targets are estimates (no baseline) | Certain | Low | First month is baseline; targets adjusted after |
| Metric gaming | Low | Medium | Metrics are diagnostic, not KPIs; no incentives tied |
| Web Vitals can't be tracked via DB events | Low | Low | Use Lighthouse CI + browser Performance API |

---

## 11. Dependencies

| Dependency | Status | Impact |
|------------|--------|--------|
| #190 — Event Analytics | Open (P1) | Required for event ingestion; metrics defined now, measured later |
| #183 — Observability | Closed | Monitoring framework available |
| #118–#137 | Closed | All UX features shipped; metrics pending measurement |
| Lighthouse CI (quality-gate.yml) | Active | Web Vital metrics collected on every PR |
