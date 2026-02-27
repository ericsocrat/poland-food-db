-- Drop unused indexes identified via EXPLAIN ANALYZE audit (Issue #369)
--
-- Methodology: After supabase db reset, all pg_stat_user_indexes show 0 scans.
-- Each index was validated with EXPLAIN ANALYZE against the query patterns that
-- should use it. Only indexes confirmed unused by any query plan are dropped.
--
-- Evidence summary (10 indexes dropped, ~768 kB reclaimed):
--
-- 1. idx_products_name_translations (264 kB) — GIN on JSONB column where all
--    rows contain '{}'. Functions use ->> (key access), not @> (containment),
--    so GIN would never be used even with populated data.
--
-- 2. idx_allergen_info_product (16 kB) — Redundant: the composite index
--    idx_allergen_info_product_type(product_id, type) covers product_id as its
--    leading column. EXPLAIN confirmed planner uses the composite index.
--
-- 3-6. idx_change_log_actor, idx_change_log_field, idx_change_log_product,
--    idx_change_log_source (total 328 kB) — product_change_log is audit-only.
--    Only trg_product_change_log writes to it; no API function reads from it.
--
-- 7. idx_prod_ingr_sub (64 kB) — Partial index on parent_ingredient_id.
--    No function, view, or API references parent_ingredient_id.
--
-- 8-10. idx_sal_changed, idx_sal_trigger, idx_sal_version (total 96 kB) —
--    score_audit_log is queried only by api_score_history(), which uses
--    idx_sal_product(product_id, changed_at DESC). No queries filter by
--    changed_at alone, trigger_type alone, or model_version alone.
--
-- Retained (confirmed used via EXPLAIN ANALYZE):
--   idx_products_search_vector — Bitmap Index Scan by api_search_products
--   idx_ingredient_ref_name_en_uniq — UNIQUE constraint enforcement
--   idx_mv_ingredient_freq_id — Required for REFRESH CONCURRENTLY
--   idx_sal_product — Index Scan by api_score_history
--
-- To roll back: re-create the dropped indexes (definitions in comments below).
-- ============================================================================

-- 1. GIN on empty JSONB column — no queries use containment operators
-- Was: CREATE INDEX idx_products_name_translations ON products USING gin (name_translations)
DROP INDEX IF EXISTS idx_products_name_translations;

-- 2. Redundant — covered by idx_allergen_info_product_type(product_id, type)
-- Was: CREATE INDEX idx_allergen_info_product ON product_allergen_info USING btree (product_id)
DROP INDEX IF EXISTS idx_allergen_info_product;

-- 3. Audit table — write-only, no read queries
-- Was: CREATE INDEX idx_change_log_actor ON product_change_log USING btree (actor_type, actor_id)
DROP INDEX IF EXISTS idx_change_log_actor;

-- 4. Audit table — write-only, no read queries
-- Was: CREATE INDEX idx_change_log_field ON product_change_log USING btree (field_name, created_at DESC)
DROP INDEX IF EXISTS idx_change_log_field;

-- 5. Audit table — write-only, no read queries
-- Was: CREATE INDEX idx_change_log_product ON product_change_log USING btree (product_id, created_at DESC)
DROP INDEX IF EXISTS idx_change_log_product;

-- 6. Audit table — write-only, no read queries
-- Was: CREATE INDEX idx_change_log_source ON product_change_log USING btree (source_key, created_at DESC)
DROP INDEX IF EXISTS idx_change_log_source;

-- 7. No function or view references parent_ingredient_id
-- Was: CREATE INDEX idx_prod_ingr_sub ON product_ingredient USING btree (parent_ingredient_id) WHERE (parent_ingredient_id IS NOT NULL)
DROP INDEX IF EXISTS idx_prod_ingr_sub;

-- 8. No query filters by changed_at alone; idx_sal_product covers ORDER BY
-- Was: CREATE INDEX idx_sal_changed ON score_audit_log USING btree (changed_at DESC)
DROP INDEX IF EXISTS idx_sal_changed;

-- 9. No query filters by trigger_type alone
-- Was: CREATE INDEX idx_sal_trigger ON score_audit_log USING btree (trigger_type)
DROP INDEX IF EXISTS idx_sal_trigger;

-- 10. No query filters by model_version alone
-- Was: CREATE INDEX idx_sal_version ON score_audit_log USING btree (model_version, changed_at DESC)
DROP INDEX IF EXISTS idx_sal_version;
