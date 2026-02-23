# Poland Food DB — Performance Guardrails

> **Issue:** #185 — [Hardening 5/7] Query-Level Performance Guardrails
> **Last updated:** 2026-02-23
> **Database:** PostgreSQL 17 (Supabase)
> **Dataset:** ~2,500 active products, 20 categories

---

## 1. Statement Timeout Configuration

All user-facing queries are bounded by role-level timeouts to prevent runaway queries from holding connection pool slots.

| Role            | Timeout | Rationale                                                  |
| --------------- | ------- | ---------------------------------------------------------- |
| **Global**      | 30s     | Safety net — catches any unscoped role                     |
| **anon**        | 10s     | Public API — strictest. No legitimate anon query needs >10s |
| **authenticated** | 15s   | Authenticated users may run heavier queries (lists, search) |
| **authenticator** | 10s   | Proxies anon — keeps same restrictive limit                |
| **service_role** | ∞      | Pipeline operations, MV refreshes, admin                    |
| **postgres**    | ∞      | Migrations, manual admin                                    |

### Migration

Applied in `20260222050000_query_performance_guardrails.sql`:

```sql
ALTER DATABASE postgres SET statement_timeout = '30s';
ALTER ROLE anon SET statement_timeout = '10s';
ALTER ROLE authenticated SET statement_timeout = '15s';
ALTER ROLE authenticator SET statement_timeout = '10s';
```

### Verification

```sql
-- Check role-level settings
SELECT r.rolname, rs.setconfig
FROM pg_db_role_setting rs
JOIN pg_roles r ON r.oid = rs.setrole
WHERE rs.setconfig::text LIKE '%statement_timeout%';

-- Test (as anon): should cancel after 10s
SET ROLE anon;
SELECT pg_sleep(20);  -- ERROR: canceling statement due to statement timeout
RESET ROLE;
```

### Rollback

```sql
ALTER ROLE anon SET statement_timeout = '0';         -- revert to no limit
ALTER ROLE authenticated SET statement_timeout = '0';
ALTER ROLE authenticator SET statement_timeout = '0';
ALTER DATABASE postgres SET statement_timeout = '0';
```

---

## 2. Slow Query Monitoring

### pg_stat_statements

Enabled on Supabase (zero overhead, native PostgreSQL extension). Provides cumulative query statistics.

```sql
-- Top 20 slowest queries by average execution time
SELECT * FROM report_slow_queries(100);  -- threshold: 100ms
```

### report_slow_queries(threshold_ms)

| Column         | Type   | Description                      |
| -------------- | ------ | -------------------------------- |
| query_preview  | TEXT   | First 200 chars of query text    |
| calls          | BIGINT | Total number of executions       |
| avg_ms         | FLOAT  | Mean execution time              |
| max_ms         | FLOAT  | Worst-case execution time        |
| total_ms       | FLOAT  | Cumulative time spent            |
| rows_returned  | BIGINT | Total rows returned across calls |
| category       | TEXT   | `critical (>1s)` / `slow (>500ms)` / `warning (>threshold)` / `ok` |

**Access:** service_role only (SECURITY DEFINER, REVOKE from anon/authenticated).

### Monitoring Schedule

| Frequency | Action                            | Alert Threshold        |
| --------- | --------------------------------- | ---------------------- |
| Weekly    | `SELECT * FROM report_slow_queries(100)` | Any `critical` entries |
| Monthly   | Review total pg_stat_statements entries  | Growing > 20%/month    |
| On-demand | After schema changes / new RPCs         | Any new `slow` entries |

---

## 3. Query Plan Analysis

### check_plan_quality(query_text)

Runs `EXPLAIN ANALYZE` on a query and flags problematic plan nodes:

| Flag                    | Condition                          | Severity |
| ----------------------- | ---------------------------------- | -------- |
| Sequential scan         | Seq Scan with >100 estimated rows  | High     |
| Nested loop iterations  | >50 actual loops                   | Medium   |
| Row estimate inaccuracy | Actual rows > 10× estimated rows   | Low      |

**Access:** service_role only (executes arbitrary SQL).

### Usage

```sql
-- Check a specific query
SELECT * FROM check_plan_quality(
  'SELECT * FROM products WHERE category = ''dairy'' LIMIT 10'
);

-- Check the barcode scanner critical path
SELECT * FROM check_plan_quality(
  'SELECT * FROM products WHERE ean = ''5900000000000'''
);
```

---

## 4. Index Strategy

### Current Index Inventory

| Table                   | Indexes | Key Columns                                              |
| ----------------------- | ------- | -------------------------------------------------------- |
| products                | 7       | PK, category, active, EAN, country+brand+name, name_trgm, brand_trgm |
| product_ingredient      | 4       | PK, product FK, ingredient FK, sub-ingredient FK         |
| ingredient_ref          | 5       | PK, taxonomy_id, name, additive, concern                 |
| product_allergen_info   | 2       | product+type, tag+type                                   |
| servings                | 3       | PK, per-100g partial, per-serving partial                |
| v_product_confidence    | 2       | product_id unique, band+score                            |
| mv_ingredient_frequency | 3       | ingredient_id unique, count, concern                     |
| mv_product_similarity   | 1       | pair unique                                              |

### Principles

1. **Every FK column has a supporting index** — verified by `QA__index_verification.sql`
2. **All MVs have unique indexes** — required for `REFRESH CONCURRENTLY`
3. **Partial indexes for filtered lookups** — `servings` WHERE clauses
4. **Trigram indexes for text search** — `pg_trgm` GIN on products

### Adding New Indexes

When adding a new RPC function:
1. Run `check_plan_quality('your_query_here')` to verify plan quality
2. If Seq Scan flagged on > 100 rows, add an appropriate index
3. Add the index check to `QA__index_verification.sql`
4. Verify via `EXPLAIN ANALYZE` that the index is used

---

## 5. Performance Baseline

### Current Query Latencies (P50)

| Operation                   | Execution Time | Buffer Hits |
| --------------------------- | -------------- | ----------- |
| v_master (category + limit) | 4.5ms          | 569         |
| api_product_detail(id)      | ~5ms           | ~500        |
| api_better_alternatives     | 6.3ms          | 1,771       |
| api_search_products         | 7.8ms          | 422         |
| api_score_explanation       | 7.5ms          | 1,500       |
| api_category_listing        | ~5ms           | ~600        |
| compute_data_confidence     | ~3ms           | ~200        |

### Materialized View Refresh Times

| View                      | Refresh Time | Row Count |
| ------------------------- | ------------ | --------- |
| mv_ingredient_frequency   | ~27ms        | ~1,471    |
| v_product_confidence      | ~31ms        | ~2,500    |
| mv_product_similarity     | ~100ms       | varies    |

### Scale Projections

| Metric                    | Current (2.5K) | 10K Products | Action Required          |
| ------------------------- | -------------- | ------------ | ------------------------ |
| Category query            | 4.5ms          | ~20ms        | None                     |
| Text search               | 7.8ms          | ~15ms        | None (GIN scales well)   |
| Jaccard similarity        | 6.6ms          | ~50ms        | Pre-filter by category   |
| MV refresh (total)        | ~160ms         | ~1.5s        | Schedule off-peak        |
| pg_stat_statements review | Weekly         | Weekly       | Automate alerts at scale |

---

## 6. Materialized View Refresh Schedule

### Current MVs

| View                      | Unique Index | CONCURRENTLY | Refresh Trigger             |
| ------------------------- | ------------ | ------------ | --------------------------- |
| mv_ingredient_frequency   | ✅            | ✅            | After ingredient data changes |
| v_product_confidence      | ✅            | ✅            | After scoring/source updates  |
| mv_product_similarity     | ✅            | ✅            | After product/ingredient changes |

### Refresh Function

```sql
SELECT refresh_all_materialized_views();
-- Returns JSONB: { "refreshed_at": "...", "views": [...], "total_ms": N }
```

### Schedule

| When                    | Action                                      |
| ----------------------- | ------------------------------------------- |
| After pipeline run      | `SELECT refresh_all_materialized_views();`  |
| After data import       | `SELECT refresh_all_materialized_views();`  |
| Nightly (if idle)       | Staleness check → refresh if needed         |

### Cost Monitoring

The `QA__mv_refresh_cost.sql` suite validates:
- Individual refresh < 5s
- Total refresh < 30s
- All MVs have unique indexes
- Post-refresh staleness = 0

---

## 7. N+1 Query Detection (Frontend)

### How It Works

The `query-observer.ts` module monitors RPC calls via `callRpc()`:
- Tracks the last 500ms of RPC calls in a circular buffer
- If the same RPC name appears ≥5 times within 500ms → console.warn

### Configuration

| Constant               | Value | Description                           |
| ---------------------- | ----- | ------------------------------------- |
| `N_PLUS_ONE_THRESHOLD` | 5     | Calls to same RPC to trigger warning  |
| `WINDOW_MS`            | 500   | Time window for detection (ms)        |

### Activation

- **Development:** Always active (`NODE_ENV=development`)
- **QA mode:** Active when `NEXT_PUBLIC_QA_MODE=true`
- **Production:** Completely disabled — zero overhead

### Example Warning

```
[N+1 DETECTED] api_product_detail called 8 times in 500ms — probable N+1 query pattern
```

### Integration

The observer is called from `callRpc()` in `src/lib/rpc.ts` — every Supabase RPC call automatically passes through it.

---

## 8. QA Suites

| File                            | Checks | Validates                                      |
| ------------------------------- | ------ | ---------------------------------------------- |
| `QA__slow_queries.sql`          | 12     | pg_stat_statements, report_slow_queries, access control |
| `QA__index_verification.sql`    | 13     | Index coverage, FK indexes, MV unique indexes  |
| `QA__explain_analysis.sql`      | 10     | Query plans for critical paths (PK, category, EAN, servings) |
| `QA__mv_refresh_cost.sql`       | 10     | Refresh times, staleness, unique index coverage |

---

## 9. Optimization Runbook

### When a Slow Query is Reported

1. **Identify:** Run `SELECT * FROM report_slow_queries(100)` to find the offender
2. **Analyze:** Run `SELECT * FROM check_plan_quality('...')` on the query
3. **Diagnose:**
   - Seq Scan on > 100 rows → Missing index
   - Nested Loop > 50 iterations → N+1 or missing join condition
   - Row estimate off by 10x → Run `ANALYZE` on affected tables
4. **Fix:** Add index / rewrite query / add `ANALYZE`
5. **Verify:** Re-run `check_plan_quality` after fix
6. **Update QA:** Add the check to `QA__explain_analysis.sql`
7. **Reset stats:** `SELECT pg_stat_statements_reset()` (optional, to measure improvement)

### When MV Refresh Takes Too Long

1. **Measure:** Check `QA__mv_refresh_cost.sql` results
2. **Diagnose:** `EXPLAIN ANALYZE` the MV's underlying query
3. **Options:**
   - Add missing indexes on source tables
   - Schedule refreshes during off-peak hours
   - Consider incremental refresh patterns
4. **Threshold alarm:** Individual MV > 5s, Total > 30s

### When Statement Timeout Fires Legitimately

1. **Identify:** Check application logs for `statement timeout` errors
2. **Options:**
   - Optimize the query (add index, rewrite)
   - If legitimately long: run with `service_role` (elevated timeout)
   - If admin operation: use `SET LOCAL statement_timeout = '60s'` in transaction
3. **Never:** Increase role-level timeouts without documenting the reason

---

## 10. Security Notes

- `report_slow_queries`: SECURITY DEFINER — accesses `pg_stat_statements` (superuser data). Restricted to service_role.
- `check_plan_quality`: SECURITY DEFINER — **executes arbitrary SQL** via `EXECUTE`. Must NEVER be callable by anon/authenticated.
- Query text in `pg_stat_statements` may contain parameter values — do not expose to untrusted users.
- N+1 observer: dev-only — never included in production bundle via `NODE_ENV` check.
