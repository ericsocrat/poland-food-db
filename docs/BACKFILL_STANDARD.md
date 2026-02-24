# Backfill Runtime Standard

> **Governance:** Mandatory subsection for any issue whose acceptance criteria, technical plan, or scope mentions "backfill".
>
> **Parent:** [#195 — Execution Governance Blueprint](https://github.com/ericsocrat/poland-food-db/issues/195)
>
> **Extends:** #208 — Backfill Orchestration & Validation Framework

---

## Quick Reference

| Concern | What to Document |
|---------|-----------------|
| Expected runtime | How long at current data? At 10K? At 50K? |
| Batch size | Rows per batch and lock impact |
| Max lock duration | Longest row/table lock per batch |
| Rollback strategy | Per-step recovery actions |
| Blast radius | Tables, columns, indexes, triggers, views affected |

---

## 1. Mandatory Backfill Plan Template

Copy this into any issue that involves a backfill:

````markdown
## Backfill Plan

### Overview
| Field | Value |
|---|---|
| Target table(s) | `{table_name}` |
| Affected columns | `{column_list}` |
| Estimated row count | {N} rows (current), {M} projected at scale |
| Batch size | {B} rows per batch |
| Estimated runtime | {T} (current data), {T'} (at 10K products) |
| Lock type | `{lock_type}` (e.g., RowExclusiveLock via FOR UPDATE SKIP LOCKED) |
| Max lock duration per batch | {D} (e.g., <100ms per batch of 1000) |
| Blast radius | Tables: {list} · Indexes: {list} · Triggers: {list} · Views: {list} |

### Execution Steps
| Step | Operation | Reversible? | Validation |
|---|---|---|---|
| 1 | {description} | Yes/No | {how to verify} |
| 2 | {description} | Yes/No | {how to verify} |
| ... | | | |

### Rollback Strategy
| Failure Point | Database State | Recovery Action |
|---|---|---|
| After step 1, before step 2 | {state description} | {action} |
| After step 2, before step 3 | {state description} | {action} |
| Partial step N completion | {state description} | {action} |

### Runtime Estimation
- Current data: {N} rows × {avg_ms_per_row}ms ÷ {batch_size} batches × {pause_ms}ms pause = {total}
- At 10K products: {estimate}
- At 50K products: {estimate}

### Pre-flight Checks
- [ ] Backup verified (point-in-time or manual)
- [ ] Estimated runtime communicated
- [ ] Monitoring dashboard open during execution
- [ ] Rollback SQL prepared and tested on staging
- [ ] Batch size tested on representative data subset
````

### Mini Template (< 1K rows)

For small backfills under 1,000 rows, use this abbreviated version:

````markdown
## Backfill Plan (Mini)

| Field | Value |
|---|---|
| Target table(s) | `{table_name}` |
| Row count | {N} rows |
| Batch size | {B} (or single batch) |
| Estimated runtime | {T} |
| Reversible? | Yes/No — {brief description} |
````

---

## 2. Runtime Estimation Formula

All backfill runtime estimates must use this formula:

```
Total Runtime = (total_rows / batch_size) × (avg_batch_ms + pause_ms) + overhead_ms
```

| Variable | Description | Default |
|----------|-------------|---------|
| `total_rows` | `SELECT count(*) FROM target WHERE needs_backfill_condition` | — |
| `batch_size` | Rows per batch | 1,000 |
| `avg_batch_ms` | Average time per batch (measure on 3 test batches) | — |
| `pause_ms` | `pg_sleep` between batches (reduces contention) | 100ms |
| `overhead_ms` | Connection setup + validation + logging | 500ms |

### Worked Examples

**Example 1: Scoring re-computation**

```
Current:  1,076 rows / 1000 batch = 2 batches
          2 × (50ms + 100ms) + 500ms = 800ms
          → Runtime: <1 second

At 10K:   10,000 / 1000 = 10 batches
          10 × (50ms + 100ms) + 500ms = 2,000ms
          → Runtime: ~2 seconds

At 50K:   50,000 / 1000 = 50 batches
          50 × (50ms + 100ms) + 500ms = 8,000ms
          → Runtime: ~8 seconds
```

**Example 2: Search vector regeneration (tsvector is CPU-intensive)**

```
Current:  1,076 rows / 500 batch = 3 batches
          3 × (200ms + 100ms) + 500ms = 1,400ms
          → Runtime: ~1.5 seconds

At 50K:   50,000 / 500 = 100 batches
          100 × (200ms + 100ms) + 500ms = 30,500ms
          → Runtime: ~31 seconds
```

### Validation Rule

Before executing any backfill:
1. Run 3 test batches on a representative data subset
2. Measure actual `avg_batch_ms`
3. Recalculate total estimate with measured value
4. If actual > 2× estimated, investigate before proceeding

---

## 3. Blast Radius Checklist

For every backfill, document each item:

| Checklist Item | What to Document |
|----------------|-----------------|
| **Tables modified** | Which tables receive UPDATE/INSERT during backfill |
| **Columns touched** | Which specific columns are written |
| **Indexes affected** | Which indexes must be updated (GIN on JSONB is expensive) |
| **Triggers fired** | Which BEFORE/AFTER triggers fire on each UPDATE (see trigger naming convention) |
| **Views invalidated** | Which materialized views need refresh after backfill |
| **API impact** | Will users see partial/inconsistent data during backfill? |
| **Concurrent access** | Can users read/write during backfill? Any degradation? |
| **Scoring impact** | Does this backfill change `unhealthiness_score` or visible scores? |

### Trigger Awareness

When updating rows in a table with triggers, each batch fires triggers per-row. A backfill of 50K rows with a trigger that writes to an audit table means 50K audit inserts. Document this.

---

## 4. Lock Duration Reference Table

| Operation Pattern | Lock Type | Duration | Safe for Production? |
|-------------------|-----------|----------|---------------------|
| `UPDATE ... SET col = val WHERE id IN (batch)` | RowExclusiveLock | Per-row, <1ms | Yes |
| `FOR UPDATE SKIP LOCKED` batch processing | RowExclusiveLock | Per-batch, <100ms | **Yes (recommended)** |
| `ALTER TABLE ADD COLUMN` (nullable, no default expression) | AccessExclusiveLock | <1s | Yes (brief) |
| `ALTER TABLE ADD COLUMN ... DEFAULT val` (PG 11+) | AccessExclusiveLock | <1s | Yes (metadata only) |
| `CREATE INDEX CONCURRENTLY` | ShareUpdateExclusiveLock | Minutes (non-blocking) | Yes |
| `CREATE INDEX` (without CONCURRENTLY) | ShareLock | Minutes (**BLOCKING**) | **No — never do this** |
| `UPDATE ... SET col = val` (full table, no WHERE) | RowExclusiveLock | Proportional to rows | **No — always batch** |
| `REFRESH MATERIALIZED VIEW` | AccessExclusiveLock | Seconds | No — use CONCURRENTLY |
| `REFRESH MATERIALIZED VIEW CONCURRENTLY` | ExclusiveLock | Seconds | Yes |

### Rules

1. **Always batch** — Never UPDATE an entire table in one statement.
2. **Always use CONCURRENTLY** — For index creation and materialized view refreshes.
3. **Always use FOR UPDATE SKIP LOCKED** — When concurrent access is expected.
4. **Always pause between batches** — Minimum 100ms to prevent lock starvation.

---

## 5. Issue Audit — Existing Backfill Requirements

Issues that require or may require backfill plans:

| Issue | Backfill Description | Status |
|-------|---------------------|--------|
| #189 (Scoring Engine) | Re-score all products with new model version | Shipped — `rescore_batch()` implements batched re-scoring |
| #192 (Search Architecture) | Generate `search_vector` for all products | Open — needs Backfill Plan subsection |
| #193 (Data Provenance) | Populate `field_provenance` for existing products | Open — needs Backfill Plan subsection |
| #127 (Image Optimization) | Image processing/resizing for existing product images | Open — needs Backfill Plan subsection |

---

## 6. PR Checklist Convention

When reviewing PRs, reviewers should verify:

- [ ] If the PR's linked issue or migration mentions "backfill", a **Backfill Plan** subsection is present in the issue
- [ ] Runtime estimation uses the standard formula (Section 2)
- [ ] Blast radius is documented (Section 3)
- [ ] Lock-unsafe patterns are absent (Section 4)
- [ ] For > 1K rows: rollback strategy is defined
- [ ] For > 10K rows: 3-batch test run results are included

---

## 7. Patterns and Anti-Patterns

### Recommended: Batched UPDATE with SKIP LOCKED

```sql
DO $backfill$
DECLARE
    v_batch_size  integer := 1000;
    v_affected    integer;
    v_total       integer := 0;
BEGIN
    LOOP
        WITH batch AS (
            SELECT product_id
            FROM products
            WHERE needs_backfill_condition
            ORDER BY product_id
            LIMIT v_batch_size
            FOR UPDATE SKIP LOCKED
        )
        UPDATE products p
        SET    target_column = computed_value
        FROM   batch b
        WHERE  p.product_id = b.product_id;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_total := v_total + v_affected;

        EXIT WHEN v_affected = 0;

        RAISE NOTICE 'Backfill progress: % rows updated', v_total;
        PERFORM pg_sleep(0.1);  -- 100ms pause
    END LOOP;

    RAISE NOTICE 'Backfill complete: % total rows', v_total;
END
$backfill$;
```

### Anti-Pattern: Full-Table UPDATE

```sql
-- NEVER do this in production:
UPDATE products SET target_column = computed_value;
```

### Anti-Pattern: Non-Concurrent Index

```sql
-- NEVER do this in production:
CREATE INDEX idx_foo ON products (bar);

-- Always use:
CREATE INDEX CONCURRENTLY idx_foo ON products (bar);
```

---

*Last updated: 2026-03-03 — Extended for #208 (backfill registry + monitoring view)*

---

## 8. Backfill Registry

All backfills **must** register in the `backfill_registry` table before execution.
This provides audit trail, progress monitoring, and resumability.

**Migration:** `20260303000000_backfill_registry.sql`

### Table Schema

| Column | Type | Notes |
|--------|------|-------|
| `backfill_id` | `uuid` (PK) | Auto-generated |
| `name` | `text` (UNIQUE) | e.g., `provenance_field_backfill_v1` |
| `description` | `text` | Human-readable purpose |
| `source_issue` | `text` | e.g., `#193` |
| `status` | `text` | `pending` / `running` / `completed` / `failed` / `rolled_back` |
| `started_at` | `timestamptz` | Set by `start_backfill()` |
| `completed_at` | `timestamptz` | Set by `complete_backfill()` or `fail_backfill()` |
| `rows_processed` | `integer` | Updated during execution |
| `rows_expected` | `integer` | From pre-count |
| `batch_size` | `integer` | Default: 1000 |
| `error_message` | `text` | On failure |
| `executed_by` | `text` | github username or `automation` |
| `rollback_sql` | `text` | SQL to undo this backfill |
| `validation_passed` | `boolean` | Post-validation result |

### Helper Functions

| Function | Purpose |
|----------|---------|
| `register_backfill(...)` | Register (upsert) a new backfill; returns `backfill_id` |
| `start_backfill(id)` | Mark as `running`, set `started_at` |
| `update_backfill_progress(id, rows)` | Update `rows_processed` during execution |
| `complete_backfill(id, rows, passed)` | Mark as `completed`, set `completed_at` |
| `fail_backfill(id, error_msg)` | Mark as `failed`, record error |

### Monitoring View

`v_backfill_status` provides a real-time dashboard:

```sql
SELECT name, status, rows_processed, rows_expected,
       pct_complete, elapsed_seconds, validation_passed
FROM v_backfill_status
WHERE status = 'running';
```

### RLS

- `service_role`: full access (read + write)
- `authenticated`: read-only
- `anon`: no access

### Script Template

Copy `scripts/backfill_template.py` for each backfill. It handles:
registration, pre-validation, batched execution, progress updates,
post-validation, and status finalization.

```bash
python scripts/backfill_{name}.py --dry-run        # estimate only
python scripts/backfill_{name}.py --batch-size 500  # execute
```
