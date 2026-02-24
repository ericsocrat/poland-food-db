# Migration Safety & Trigger Interaction Conventions

> **Last updated:** 2026-03-01
> **Status:** Active
> **Reference:** Issues [#203](https://github.com/ericsocrat/poland-food-db/issues/203), [#207](https://github.com/ericsocrat/poland-food-db/issues/207)

---

## 1. Purpose

This document defines mandatory conventions for database migrations and trigger management.
It prevents table locks, ensures idempotency, enforces deterministic trigger ordering, and
provides rollback procedures for every schema change.

---

## 2. Trigger Naming Convention

PostgreSQL fires triggers **alphabetically** within the same timing (BEFORE/AFTER) and event.
To enforce deterministic ordering, all triggers on shared tables must follow a naming convention.

### 2.1 Pattern

```
{table}_{NN}_{domain}_{action}      — numbered ordering (preferred for shared tables)
trg_{table}_{purpose}                — legacy pattern (acceptable for single-domain tables)
```

| Component  | Description                             | Example                                   |
| ---------- | --------------------------------------- | ----------------------------------------- |
| `{table}`  | Target table name                       | `products`, `user_preferences`            |
| `{NN}`     | Two-digit ordering number (10, 20, 30…) | `10`, `20`, `30`                          |
| `{domain}` | Owning domain                           | `search`, `meta`, `provenance`, `scoring` |
| `{action}` | What the trigger does                   | `vector_update`, `updated_at`, `audit`    |

### 2.2 Ordering Numbers (products table)

| Number | Timing | Domain     | Purpose                                   |
| ------ | ------ | ---------- | ----------------------------------------- |
| 10     | BEFORE | Search     | Update search vector                      |
| 20     | BEFORE | Meta       | Set `updated_at` timestamp                |
| 30     | AFTER  | Provenance | Log field changes to `product_change_log` |
| 40     | AFTER  | Scoring    | Audit score changes to `score_audit_log`  |
| 50     | AFTER  | Scoring    | Record score history for notifications    |

**Gap between numbers:** Use increments of 10 to allow future insertions (e.g., 15, 25).

### 2.3 Validation Rule

All triggers on `products` must match the regex: `^(trg_products_|products_\d+_)`

This is enforced by `governance_drift_check()` Check 6 (see `docs/DRIFT_DETECTION.md`).

### 2.4 Trigger Function Naming

All trigger functions must use the `trg_` prefix:

```sql
CREATE OR REPLACE FUNCTION trg_my_function() RETURNS trigger ...
```

Functions without the `trg_` prefix (e.g., `record_score_change()`, `queue_score_change_notifications()`)
are legacy and documented as non-conforming (see §2.5).

### 2.5 Current Trigger Inventory (products table)

| Trigger Name                        | Timing | Event                         | Function                       | Status                                              |
| ----------------------------------- | ------ | ----------------------------- | ------------------------------ | --------------------------------------------------- |
| `trg_products_search_vector_update` | BEFORE | INSERT OR UPDATE              | `trg_products_search_vector()` | Conforming                                          |
| `trg_products_updated_at`           | BEFORE | UPDATE                        | `trg_set_updated_at()`         | Conforming                                          |
| `products_30_change_audit`          | AFTER  | UPDATE                        | `trg_product_change_log()`     | Conforming                                          |
| `trg_products_score_audit`          | AFTER  | UPDATE                        | `trg_score_audit()`            | Conforming (renamed from `score_change_audit`)      |
| `trg_products_score_history`        | AFTER  | UPDATE OF unhealthiness_score | `record_score_change()`        | Conforming (renamed from `trg_record_score_change`) |

### 2.6 All Triggers (full inventory)

| Table                    | Trigger Name                        | Timing | Event                         | Function                              |
| ------------------------ | ----------------------------------- | ------ | ----------------------------- | ------------------------------------- |
| `products`               | `trg_products_search_vector_update` | BEFORE | INSERT OR UPDATE              | `trg_products_search_vector()`        |
| `products`               | `trg_products_updated_at`           | BEFORE | UPDATE                        | `trg_set_updated_at()`                |
| `products`               | `products_30_change_audit`          | AFTER  | UPDATE                        | `trg_product_change_log()`            |
| `products`               | `trg_products_score_audit`          | AFTER  | UPDATE                        | `trg_score_audit()`                   |
| `products`               | `trg_products_score_history`        | AFTER  | UPDATE OF unhealthiness_score | `record_score_change()`               |
| `user_preferences`       | `user_preferences_updated_at`       | BEFORE | UPDATE                        | `trg_set_updated_at()`                |
| `user_preferences`       | `trg_auto_create_lists`             | AFTER  | INSERT                        | `trg_create_default_lists()`          |
| `user_preferences`       | `trg_validate_fav_cats`             | BEFORE | INSERT OR UPDATE              | `trg_validate_favorite_categories()`  |
| `user_health_profiles`   | `trg_health_profile_active`         | BEFORE | INSERT OR UPDATE              | `trg_enforce_single_active_profile()` |
| `user_product_lists`     | `trg_user_product_lists_updated_at` | BEFORE | UPDATE                        | `trg_update_list_timestamp()`         |
| `user_comparisons`       | `trg_limit_user_comparisons`        | BEFORE | INSERT                        | `trg_limit_comparisons()`             |
| `user_saved_searches`    | `trg_limit_saved_searches`          | BEFORE | INSERT                        | `trg_limit_saved_searches()`          |
| `product_score_history`  | `trg_queue_score_notifications`     | AFTER  | INSERT                        | `queue_score_change_notifications()`  |
| `feature_flags`          | `flag_changes`                      | AFTER  | INSERT OR UPDATE OR DELETE    | `trg_flag_audit()`                    |
| `scoring_model_versions` | `auto_fingerprint_smv`              | BEFORE | INSERT OR UPDATE OF config    | `trg_auto_fingerprint_smv()`          |
| `search_ranking_config`  | `auto_fingerprint_src`              | BEFORE | INSERT OR UPDATE OF weights   | `trg_auto_fingerprint_src()`          |

**Total:** 16 active triggers across 9 tables.

### 2.7 Trigger Domain Ranges (products table)

When using the numbered `products_NN_` pattern, use these reserved ranges:

| Range | Domain                 | Timing         | Purpose                                     |
| ----- | ---------------------- | -------------- | ------------------------------------------- |
| 10–19 | Search                 | BEFORE         | Search vector updates, tsvector maintenance |
| 20–29 | Meta / Provenance      | BEFORE / AFTER | Timestamps, field-level provenance tracking |
| 30–39 | Provenance / Audit     | AFTER          | Change logging, audit trail                 |
| 40–49 | Scoring                | AFTER          | Score auditing, score history               |
| 50–59 | Events / Notifications | AFTER          | Event queuing, push notifications           |
| 60–99 | Reserved               | —              | Future domains                              |

---

## 3. Migration Naming Convention

### 3.1 File Naming

```
Format: YYYYMMDDHHMMSS_{description}.sql

Timestamp: Supabase CLI format (14-digit UTC timestamp)
Description: snake_case, action-oriented

Examples:
  20260302000000_migration_safety_conventions.sql
  20260301000000_drift_detection_automation.sql
  20260228000000_formula_registry.sql
```

### 3.2 Migration Header Block

Every migration file **should** include a metadata header block:

```sql
-- Migration: YYYYMMDDHHMMSS_{description}.sql
-- Issue: #{issue_number}
-- Rollback: DROP TABLE IF EXISTS {table}; / ALTER TABLE DROP COLUMN IF EXISTS {col};
-- Runtime estimate: < {N}s
-- Lock risk: none | LOW | MEDIUM | HIGH | CRITICAL (see §7)
```

For complex migrations, include additional metadata:

```sql
-- Migration: YYYYMMDDHHMMSS_{description}.sql
-- Domain: {scoring | search | provenance | governance | ...}
-- Issue: #{issue_number}
-- Dependencies: {none | migration_names}
-- Rollback: {rollback SQL or "NOT POSSIBLE — restore from backup"}
-- Runtime estimate: < {N}s
-- Lock risk: {none | LOW | MEDIUM | HIGH | CRITICAL}
-- Idempotent: YES
-- Description: {one-line description}
```

A full template file is available at `supabase/migrations/_TEMPLATE.sql`.

---

## 4. Index Naming Convention

### 4.1 Standard Pattern

```
idx_{table}_{columns}[_{type}]

{table}     = target table name
{columns}   = column name(s), joined with underscore for composites
{type}      = index type suffix (omit for btree/default)
              gin  — GIN indexes (tsvector, JSONB, arrays)
              gist — GiST indexes (trigram similarity)
              hash — Hash indexes (exact equality only)
              brin — BRIN indexes (range-correlated data)
```

### 4.2 Examples

| Index Name                        | Type  | Columns               | Purpose            |
| --------------------------------- | ----- | --------------------- | ------------------ |
| `idx_products_ean`                | btree | `ean`                 | EAN barcode lookup |
| `idx_products_category`           | btree | `category`            | Category filtering |
| `idx_products_search_vector_gin`  | GIN   | `search_vector`       | Full-text search   |
| `idx_products_name_trgm_gist`     | GiST  | `product_name`        | Trigram similarity |
| `idx_products_category_country`   | btree | `(category, country)` | Composite filter   |
| `idx_field_provenance_product_id` | btree | `product_id`          | FK lookup          |

### 4.3 Special Patterns

- **Unique indexes**: Use `_uniq` suffix — `products_ean_uniq`, `products_country_brand_name_uniq`
- **Partial indexes**: Append condition hint — `products_active_idx` (WHERE `is_deprecated IS NOT TRUE`)
- **Primary keys**: Use `_pkey` suffix (PostgreSQL default) — `products_pkey`

### 4.4 Current Index Inventory

Existing indexes use mixed naming (legacy). New indexes **must** follow §4.1.
Renaming existing indexes is low priority and tracked in §12 (Future Work).

---

## 5. Migration Safety Checklist

Every migration **must** satisfy these checks before merge:

- [ ] **Idempotent**: Uses `IF NOT EXISTS` / `IF EXISTS` / `ON CONFLICT DO NOTHING`
- [ ] **Non-locking**: No `ALTER TABLE ... ADD COLUMN` without `IF NOT EXISTS` on large tables
- [ ] **Index safety**: All `CREATE INDEX` uses `CONCURRENTLY` (except on new empty tables)
- [ ] **Rollback defined**: Corresponding rollback SQL documented in migration header
- [ ] **Runtime estimate**: Estimated execution time documented (< 30s for production)
- [ ] **Validation query**: Post-migration validation query included
- [ ] **Trigger check**: If modifying `products` table, verified trigger ordering
- [ ] **Tested locally**: Migration run with `supabase db reset`
- [ ] **Backfill separate**: Data backfill is a separate migration from schema change
- [ ] **No data loss**: No columns dropped or data type narrowed without explicit approval

---

## 6. Migration File Template

```sql
-- Migration: YYYYMMDDHHMMSS_{description}.sql
-- Issue: #{issue_number}
-- Rollback: DROP TABLE IF EXISTS {table}; / ALTER TABLE DROP COLUMN IF EXISTS {col};
-- Runtime estimate: < {N}s
-- Lock risk: none | row | table (see §8)

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 1: Schema change (idempotent)
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE products ADD COLUMN IF NOT EXISTS new_column text;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 2: Validation (verify change applied)
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  ASSERT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'products'
      AND column_name  = 'new_column'
  ), 'Migration validation FAILED: new_column not found';
  RAISE NOTICE '✅ Migration validated: new_column exists';
END $$;

-- NOTE: Data backfills go in a SEPARATE migration file.
```

---

## 7. Idempotency Patterns

| Operation       | Idempotent Pattern                                             |
| --------------- | -------------------------------------------------------------- |
| Create table    | `CREATE TABLE IF NOT EXISTS`                                   |
| Add column      | `ALTER TABLE ADD COLUMN IF NOT EXISTS`                         |
| Drop column     | `ALTER TABLE DROP COLUMN IF EXISTS`                            |
| Create index    | `CREATE INDEX IF NOT EXISTS ... CONCURRENTLY`                  |
| Create function | `CREATE OR REPLACE FUNCTION`                                   |
| Create trigger  | `DROP TRIGGER IF EXISTS ... ; CREATE TRIGGER ...`              |
| Insert row      | `INSERT ... ON CONFLICT DO NOTHING` or `ON CONFLICT DO UPDATE` |
| Create view     | `CREATE OR REPLACE VIEW`                                       |

### Trigger Idempotency

Since `CREATE OR REPLACE TRIGGER` is not supported in all PostgreSQL versions,
use the drop-then-create pattern:

```sql
DROP TRIGGER IF EXISTS products_10_search_vector_update ON products;
CREATE TRIGGER products_10_search_vector_update
  BEFORE INSERT OR UPDATE OF product_name, brand, category
  ON products
  FOR EACH ROW
  EXECUTE FUNCTION trg_products_search_vector();
```

---

## 8. Lock Risk Analysis

| Operation                           | Lock Type                | Duration          | Risk at 2.5K rows | Risk at 50K rows |
| ----------------------------------- | ------------------------ | ----------------- | ----------------- | ---------------- |
| `ADD COLUMN` (nullable, no default) | `ACCESS EXCLUSIVE`       | ~instant          | Low               | Low              |
| `ADD COLUMN` (with DEFAULT)         | `ACCESS EXCLUSIVE`       | ~instant (PG 11+) | Low               | Low              |
| `CREATE INDEX CONCURRENTLY`         | `SHARE UPDATE EXCLUSIVE` | seconds           | Low               | Medium           |
| `CREATE INDEX` (non-concurrent)     | `SHARE`                  | seconds           | Medium            | High             |
| `ALTER COLUMN TYPE`                 | `ACCESS EXCLUSIVE`       | table rewrite     | High              | High             |
| `ADD CONSTRAINT` (with validation)  | `SHARE ROW EXCLUSIVE`    | full scan         | Medium            | High             |
| `ADD CONSTRAINT ... NOT VALID`      | `SHARE ROW EXCLUSIVE`    | ~instant          | Low               | Low              |
| `VALIDATE CONSTRAINT`               | `SHARE UPDATE EXCLUSIVE` | full scan         | Medium            | Medium           |
| `DROP COLUMN`                       | `ACCESS EXCLUSIVE`       | ~instant          | Medium            | Medium           |
| `DROP TABLE`                        | `ACCESS EXCLUSIVE`       | ~instant          | Low               | Low              |
| `CREATE TRIGGER`                    | `SHARE ROW EXCLUSIVE`    | ~instant          | Low               | Low              |
| `ALTER TABLE SET NOT NULL`          | `ACCESS EXCLUSIVE`       | scans table       | High              | High             |

### Mitigation Strategies

1. **Split constraint creation**: Use `NOT VALID` + separate `VALIDATE CONSTRAINT`
2. **Use CONCURRENTLY**: Always for indexes on existing populated tables
3. **Off-peak hours**: Run High-risk migrations during maintenance windows
4. **Short transactions**: Keep migration steps small; avoid multi-statement transactions on large tables
5. **Statement timeout**: Set `SET statement_timeout = '30s';` for safety

---

## 9. Rollback Procedures

Every migration must include rollback instructions in its header comment. Common patterns:

| Migration Type | Rollback Pattern                                        |
| -------------- | ------------------------------------------------------- |
| New table      | `DROP TABLE IF EXISTS {table} CASCADE;`                 |
| New column     | `ALTER TABLE {table} DROP COLUMN IF EXISTS {col};`      |
| New function   | `DROP FUNCTION IF EXISTS {func}();`                     |
| New trigger    | `DROP TRIGGER IF EXISTS {trigger} ON {table};`          |
| New index      | `DROP INDEX IF EXISTS {index};`                         |
| New constraint | `ALTER TABLE {table} DROP CONSTRAINT IF EXISTS {name};` |

### Rollback Testing

Before a migration is considered complete, verify:

1. Apply the migration: `supabase db reset` (runs all migrations)
2. Verify the migration took effect (validation query from migration)
3. Document the rollback SQL in the migration header
4. If the migration is complex, test the rollback on a local instance

---

## 10. Trigger Interaction Testing

When adding or modifying triggers on the `products` table:

1. **Check alphabetical ordering** — query `pg_trigger` to verify execution order
2. **Verify BEFORE triggers fire first** — search vector + updated_at before audit/scoring
3. **Test single UPDATE** — one UPDATE should fire all relevant triggers
4. **Test with scoring** — verify `score_category()` still works correctly with all triggers active

### Verify Trigger Order

```sql
SELECT tgname, tgtype,
  CASE WHEN tgtype & 2 > 0 THEN 'BEFORE' ELSE 'AFTER' END AS timing,
  CASE WHEN tgtype & 4 > 0 THEN 'INSERT' ELSE '' END ||
  CASE WHEN tgtype & 8 > 0 THEN ' DELETE' ELSE '' END ||
  CASE WHEN tgtype & 16 > 0 THEN ' UPDATE' ELSE '' END AS events
FROM pg_trigger
WHERE tgrelid = 'products'::regclass
  AND NOT tgisinternal
ORDER BY
  CASE WHEN tgtype & 2 > 0 THEN 0 ELSE 1 END,  -- BEFORE first
  tgname;  -- then alphabetical
```

---

## 11. Verified Idempotency Examples

The following existing migrations have been verified as idempotent (can be re-run safely):

| Migration                                       | Key Pattern                                                 | Safe to Re-run |
| ----------------------------------------------- | ----------------------------------------------------------- | -------------- |
| `20260207000100_create_schema.sql`              | `CREATE TABLE IF NOT EXISTS`                                | Yes            |
| `20260210001300_ingredient_normalization.sql`   | `CREATE TABLE IF NOT EXISTS` + `ON CONFLICT DO NOTHING`     | Yes            |
| `20260213001300_close_roadmap_gaps.sql`         | `ADD COLUMN IF NOT EXISTS` + `CREATE OR REPLACE FUNCTION`   | Yes            |
| `20260301000000_drift_detection_automation.sql` | `CREATE TABLE IF NOT EXISTS` + `CREATE OR REPLACE FUNCTION` | Yes            |

---

## 12. Future Work

- **Standardize all products triggers** to `products_NN_domain_action` numbered convention
  (currently 2 use `trg_products_*` pattern and 3 use numbered; both are valid per governance check)
- **Rename legacy trigger functions** missing `trg_` prefix: `record_score_change()`,
  `queue_score_change_notifications()`
- **Register all trigger functions** in `docs/api-registry.yaml` (currently only 7 of 15 listed)
- **Add CI enforcement** of migration safety checklist via pre-merge script
