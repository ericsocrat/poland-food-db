-- 20260212000100_consolidate_schema.sql
-- Purpose: Consolidate schema by merging redundant tables
--
-- Changes:
--   1. Eliminate `servings` — all rows are identical (per 100g, 100)
--      → `nutrition_facts` becomes (product_id PK) instead of (product_id, serving_id)
--   2. Merge `product_sources` into `products`
--      → Add source_url, source_type, source_ean columns to products
--   3. Merge `product_allergen` + `product_trace` into `product_allergen_info`
--      → Single table with type='contains'|'traces'
--   4. Merge `scores` into `products`
--      → All scoring columns move to products table
--   5. Clean up `category_ref` stale columns

SET search_path = public;

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 0. DROP ALL DEPENDENT VIEWS FIRST (they reference columns we're removing)
-- ═══════════════════════════════════════════════════════════════════════════
DROP MATERIALIZED VIEW IF EXISTS mv_ingredient_frequency CASCADE;
DROP MATERIALIZED VIEW IF EXISTS v_product_confidence CASCADE;
DROP VIEW IF EXISTS v_master CASCADE;
DROP VIEW IF EXISTS v_api_category_overview CASCADE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ELIMINATE servings TABLE
-- ═══════════════════════════════════════════════════════════════════════════
-- nutrition_facts currently has PK (product_id, serving_id).
-- Since serving_id is always the same "per 100g" row, we drop it.

-- 1a) Drop the FK from nutrition_facts to servings
ALTER TABLE nutrition_facts DROP CONSTRAINT IF EXISTS nutrition_facts_serving_id_fkey;

-- 1b) Drop the old composite PK
ALTER TABLE nutrition_facts DROP CONSTRAINT IF EXISTS nutrition_facts_pkey;

-- 1c) Remove the serving_id column
ALTER TABLE nutrition_facts DROP COLUMN IF EXISTS serving_id;

-- 1d) Add new PK on just product_id
ALTER TABLE nutrition_facts ADD PRIMARY KEY (product_id);

-- 1e) Drop the servings table and its FK from products
ALTER TABLE servings DROP CONSTRAINT IF EXISTS servings_product_id_fkey;
DROP TABLE IF EXISTS servings CASCADE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. MERGE product_sources INTO products
-- ═══════════════════════════════════════════════════════════════════════════

-- 2a) Add source columns to products
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS source_type text DEFAULT 'off_api',
  ADD COLUMN IF NOT EXISTS source_url  text,
  ADD COLUMN IF NOT EXISTS source_ean  text;

-- 2b) Migrate data
UPDATE products p SET
  source_type = ps.source_type,
  source_url  = ps.source_url,
  source_ean  = ps.source_ean
FROM product_sources ps
WHERE ps.product_id = p.product_id AND ps.is_primary = true;

-- 2c) Add check constraint for source_type
ALTER TABLE products ADD CONSTRAINT chk_products_source_type
  CHECK (source_type IS NULL OR source_type IN ('off_api','off_search','manual','label_scan','retailer_api'));

-- 2d) Drop product_sources table
DROP TABLE IF EXISTS product_sources CASCADE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. MERGE product_allergen + product_trace → product_allergen_info
-- ═══════════════════════════════════════════════════════════════════════════

-- 3a) Create new unified table
CREATE TABLE IF NOT EXISTS product_allergen_info (
  product_id bigint NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  tag        text   NOT NULL,
  type       text   NOT NULL CHECK (type IN ('contains','traces')),
  PRIMARY KEY (product_id, tag, type)
);

-- 3b) Migrate allergen data
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, allergen_tag, 'contains'
FROM product_allergen
ON CONFLICT DO NOTHING;

-- 3c) Migrate trace data
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, trace_tag, 'traces'
FROM product_trace
ON CONFLICT DO NOTHING;

-- 3d) Create indexes
CREATE INDEX IF NOT EXISTS idx_allergen_info_product ON product_allergen_info(product_id);
CREATE INDEX IF NOT EXISTS idx_allergen_info_tag ON product_allergen_info(tag);

-- 3e) Drop old tables
DROP TABLE IF EXISTS product_allergen CASCADE;
DROP TABLE IF EXISTS product_trace CASCADE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. MERGE scores INTO products
-- ═══════════════════════════════════════════════════════════════════════════

-- 4a) Add score columns to products
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS unhealthiness_score      numeric,
  ADD COLUMN IF NOT EXISTS nutri_score_label        text,
  ADD COLUMN IF NOT EXISTS nova_classification      text,
  ADD COLUMN IF NOT EXISTS high_salt_flag           text,
  ADD COLUMN IF NOT EXISTS high_sugar_flag          text,
  ADD COLUMN IF NOT EXISTS high_sat_fat_flag        text,
  ADD COLUMN IF NOT EXISTS high_additive_load       text,
  ADD COLUMN IF NOT EXISTS data_completeness_pct    numeric,
  ADD COLUMN IF NOT EXISTS confidence               text,
  ADD COLUMN IF NOT EXISTS ingredient_concern_score numeric;

-- 4b) Migrate data from scores
UPDATE products p SET
  unhealthiness_score      = s.unhealthiness_score,
  nutri_score_label        = s.nutri_score_label,
  nova_classification      = s.nova_classification,
  high_salt_flag           = s.high_salt_flag,
  high_sugar_flag          = s.high_sugar_flag,
  high_sat_fat_flag        = s.high_sat_fat_flag,
  high_additive_load       = s.high_additive_load,
  data_completeness_pct    = s.data_completeness_pct,
  confidence               = s.confidence,
  ingredient_concern_score = s.ingredient_concern_score
FROM scores s
WHERE s.product_id = p.product_id;

-- 4c) Add check constraints (from old scores table)
ALTER TABLE products ADD CONSTRAINT chk_products_unhealthiness_range
  CHECK (unhealthiness_score IS NULL OR (unhealthiness_score >= 1 AND unhealthiness_score <= 100));
ALTER TABLE products ADD CONSTRAINT chk_products_nutri_score_label
  CHECK (nutri_score_label IS NULL OR nutri_score_label IN ('A','B','C','D','E','UNKNOWN','NOT-APPLICABLE'));
ALTER TABLE products ADD CONSTRAINT chk_products_nova
  CHECK (nova_classification IS NULL OR nova_classification IN ('1','2','3','4'));
ALTER TABLE products ADD CONSTRAINT chk_products_confidence
  CHECK (confidence IS NULL OR confidence IN ('verified','estimated','low'));
ALTER TABLE products ADD CONSTRAINT chk_products_completeness
  CHECK (data_completeness_pct IS NULL OR (data_completeness_pct >= 0 AND data_completeness_pct <= 100));
ALTER TABLE products ADD CONSTRAINT chk_products_high_salt
  CHECK (high_salt_flag IS NULL OR high_salt_flag IN ('YES','NO'));
ALTER TABLE products ADD CONSTRAINT chk_products_high_sugar
  CHECK (high_sugar_flag IS NULL OR high_sugar_flag IN ('YES','NO'));
ALTER TABLE products ADD CONSTRAINT chk_products_high_sat_fat
  CHECK (high_sat_fat_flag IS NULL OR high_sat_fat_flag IN ('YES','NO'));
ALTER TABLE products ADD CONSTRAINT chk_products_high_additive
  CHECK (high_additive_load IS NULL OR high_additive_load IN ('YES','NO'));

-- 4d) Add FK for nutri_score_label
ALTER TABLE products ADD CONSTRAINT fk_products_nutri_score
  FOREIGN KEY (nutri_score_label) REFERENCES nutri_score_ref(label);

-- 4e) Add performance index
CREATE INDEX IF NOT EXISTS idx_products_unhealthiness ON products(unhealthiness_score)
  WHERE is_deprecated IS NOT TRUE;

-- 4f) Drop scores table
DROP TABLE IF EXISTS scores CASCADE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 5. CLEAN UP category_ref
-- ═══════════════════════════════════════════════════════════════════════════

-- 5a) Update target_per_category to reflect actual expansion (50 products)
UPDATE category_ref SET target_per_category = 50
WHERE category IN (
  'Canned Goods','Chips','Condiments','Dairy','Frozen & Prepared',
  'Instant & Frozen','Meat','Nuts, Seeds & Legumes','Seafood & Fish','Sweets'
);

-- 5b) Drop unused parent_category column
ALTER TABLE category_ref DROP COLUMN IF EXISTS parent_category;


-- ═══════════════════════════════════════════════════════════════════════════
-- 6. REBUILD VIEWS (depend on old tables — must be recreated)
-- ═══════════════════════════════════════════════════════════════════════════

-- 6a) Drop materialized views first (already dropped at top, but be safe)
-- (Views were dropped in step 0)

-- 6c) Recreate v_master (simplified — no servings, scores, product_sources joins)
CREATE OR REPLACE VIEW v_master AS
SELECT
  p.product_id,
  p.country,
  p.brand,
  p.product_type,
  p.category,
  p.product_name,
  p.prep_method,
  p.store_availability,
  p.controversies,
  p.ean,
  -- Nutrition (direct from nutrition_facts, no serving indirection)
  nf.calories,
  nf.total_fat_g,
  nf.saturated_fat_g,
  nf.trans_fat_g,
  nf.carbs_g,
  nf.sugars_g,
  nf.fibre_g,
  nf.protein_g,
  nf.salt_g,
  -- Scores (now on products directly)
  p.unhealthiness_score,
  p.confidence,
  p.data_completeness_pct,
  p.nutri_score_label,
  p.nova_classification,
  CASE p.nova_classification
    WHEN '4' THEN 'High'
    WHEN '3' THEN 'Moderate'
    WHEN '2' THEN 'Low'
    WHEN '1' THEN 'Low'
    ELSE 'Unknown'
  END AS processing_risk,
  p.high_salt_flag,
  p.high_sugar_flag,
  p.high_sat_fat_flag,
  p.high_additive_load,
  p.ingredient_concern_score,
  -- Score breakdown
  explain_score_v32(
    nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories, nf.trans_fat_g,
    ingr.additives_count::numeric, p.prep_method, p.controversies,
    p.ingredient_concern_score
  ) AS score_breakdown,
  -- Ingredient aggregates
  ingr.additives_count,
  ingr.ingredients_text AS ingredients_raw,
  ingr.ingredient_count,
  ingr.additive_names,
  ingr.has_palm_oil,
  ingr.vegan_status,
  ingr.vegetarian_status,
  -- Allergen/trace aggregates (from unified table)
  ingr.allergen_count,
  ingr.allergen_tags,
  ingr.trace_count,
  ingr.trace_tags,
  -- Source (now on products directly)
  p.source_type,
  p.source_url,
  p.source_ean,
  -- Data quality flags
  CASE WHEN ingr.ingredient_count > 0 THEN 'complete' ELSE 'missing' END AS ingredient_data_quality,
  CASE
    WHEN nf.calories IS NOT NULL AND nf.total_fat_g IS NOT NULL
         AND nf.carbs_g IS NOT NULL AND nf.protein_g IS NOT NULL AND nf.salt_g IS NOT NULL
         AND (nf.total_fat_g IS NULL OR nf.saturated_fat_g IS NULL OR nf.saturated_fat_g <= nf.total_fat_g)
         AND (nf.carbs_g IS NULL OR nf.sugars_g IS NULL OR nf.sugars_g <= nf.carbs_g)
    THEN 'clean'
    ELSE 'suspect'
  END AS nutrition_data_quality
FROM products p
LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN LATERAL (
  SELECT
    count(*)::integer AS ingredient_count,
    count(*) FILTER (WHERE ir.is_additive)::integer AS additives_count,
    string_agg(ir.name_en, ', ' ORDER BY pi.position) AS ingredients_text,
    string_agg(CASE WHEN ir.is_additive THEN ir.name_en END, ', ' ORDER BY pi.position) AS additive_names,
    bool_or(ir.from_palm_oil = 'yes') AS has_palm_oil,
    CASE
      WHEN bool_and(ir.vegan IN ('yes','unknown')) THEN 'yes'
      WHEN bool_or(ir.vegan = 'no') THEN 'no'
      ELSE 'maybe'
    END AS vegan_status,
    CASE
      WHEN bool_and(ir.vegetarian IN ('yes','unknown')) THEN 'yes'
      WHEN bool_or(ir.vegetarian = 'no') THEN 'no'
      ELSE 'maybe'
    END AS vegetarian_status,
    (SELECT count(*)::integer FROM product_allergen_info ai
     WHERE ai.product_id = p.product_id AND ai.type = 'contains') AS allergen_count,
    (SELECT string_agg(ai.tag, ', ' ORDER BY ai.tag) FROM product_allergen_info ai
     WHERE ai.product_id = p.product_id AND ai.type = 'contains') AS allergen_tags,
    (SELECT count(*)::integer FROM product_allergen_info ai
     WHERE ai.product_id = p.product_id AND ai.type = 'traces') AS trace_count,
    (SELECT string_agg(ai.tag, ', ' ORDER BY ai.tag) FROM product_allergen_info ai
     WHERE ai.product_id = p.product_id AND ai.type = 'traces') AS trace_tags
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  WHERE pi.product_id = p.product_id
) ingr ON true
WHERE p.is_deprecated IS NOT TRUE;

-- 6d) Recreate v_api_category_overview (simplified — scores now on products)
CREATE OR REPLACE VIEW v_api_category_overview AS
SELECT
  cr.category,
  cr.display_name,
  cr.description AS category_description,
  cr.icon_emoji,
  cr.sort_order,
  stats.product_count,
  stats.avg_score,
  stats.min_score,
  stats.max_score,
  stats.median_score,
  stats.pct_nutri_a_b,
  stats.pct_nova_4
FROM category_ref cr
LEFT JOIN LATERAL (
  SELECT
    count(*)::integer AS product_count,
    round(avg(p.unhealthiness_score), 1) AS avg_score,
    min(p.unhealthiness_score)::integer AS min_score,
    max(p.unhealthiness_score)::integer AS max_score,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY p.unhealthiness_score::double precision)::integer AS median_score,
    round(100.0 * count(*) FILTER (WHERE p.nutri_score_label IN ('A','B'))::numeric
          / NULLIF(count(*), 0)::numeric, 1) AS pct_nutri_a_b,
    round(100.0 * count(*) FILTER (WHERE p.nova_classification = '4')::numeric
          / NULLIF(count(*), 0)::numeric, 1) AS pct_nova_4
  FROM products p
  WHERE p.category = cr.category AND p.is_deprecated IS NOT TRUE
) stats ON true
WHERE cr.is_active = true
ORDER BY cr.sort_order;

-- 6e) Recreate mv_ingredient_frequency
CREATE MATERIALIZED VIEW mv_ingredient_frequency AS
SELECT
  ir.ingredient_id,
  ir.name_en,
  ir.is_additive,
  ir.concern_tier,
  ir.from_palm_oil,
  count(DISTINCT pi.product_id) AS product_count,
  round(count(DISTINCT pi.product_id)::numeric * 100.0
        / NULLIF((SELECT count(DISTINCT product_id) FROM product_ingredient), 0)::numeric, 1) AS usage_pct,
  array_agg(DISTINCT p.category ORDER BY p.category) AS categories,
  array_length(array_agg(DISTINCT p.category), 1) AS category_spread,
  round(avg(p.unhealthiness_score), 1) AS avg_score_of_products
FROM ingredient_ref ir
JOIN product_ingredient pi ON pi.ingredient_id = ir.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
GROUP BY ir.ingredient_id, ir.name_en, ir.is_additive, ir.concern_tier, ir.from_palm_oil;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_ingredient_freq_id ON mv_ingredient_frequency(ingredient_id);
CREATE INDEX IF NOT EXISTS idx_mv_ingredient_freq_count ON mv_ingredient_frequency(product_count DESC);
CREATE INDEX IF NOT EXISTS idx_mv_ingredient_freq_concern ON mv_ingredient_frequency(concern_tier DESC, product_count DESC);

-- 6f) Recreate v_product_confidence (simplified — no servings/product_sources joins)
CREATE MATERIALIZED VIEW v_product_confidence AS
SELECT
  p.product_id,
  p.product_name,
  p.brand,
  p.category,
  -- Nutrition pts (0-30)
  (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
  (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
  (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
  (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
  (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
  (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) AS nutrition_pts,
  -- Ingredient pts (0-25)
  CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END AS ingredient_pts,
  -- Source pts (0-20): mapped from source_type on products
  CASE
    WHEN p.source_type = 'off_api' THEN 18
    WHEN p.source_type = 'manual' THEN 16
    ELSE 10
  END AS source_pts,
  -- EAN pts (0-10)
  CASE WHEN p.ean IS NOT NULL AND length(p.ean) >= 8 THEN 10 ELSE 0 END AS ean_pts,
  -- Allergen pts (0-10)
  CASE WHEN EXISTS (SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains') THEN 10 ELSE 0 END AS allergen_pts,
  -- Total confidence
  LEAST(
    (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
    (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
    (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
    (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
    (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
    (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
    CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END +
    CASE WHEN p.source_type = 'off_api' THEN 18 WHEN p.source_type = 'manual' THEN 16 ELSE 10 END +
    CASE WHEN p.ean IS NOT NULL AND length(p.ean) >= 8 THEN 10 ELSE 0 END +
    CASE WHEN EXISTS (SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains') THEN 10 ELSE 0 END,
    100
  ) AS total_confidence,
  CASE
    WHEN LEAST(
      (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
      CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END +
      CASE WHEN p.source_type = 'off_api' THEN 18 WHEN p.source_type = 'manual' THEN 16 ELSE 10 END +
      CASE WHEN p.ean IS NOT NULL AND length(p.ean) >= 8 THEN 10 ELSE 0 END +
      CASE WHEN EXISTS (SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains') THEN 10 ELSE 0 END,
      100
    ) >= 80 THEN 'high'
    WHEN LEAST(
      (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
      (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
      CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END +
      CASE WHEN p.source_type = 'off_api' THEN 18 WHEN p.source_type = 'manual' THEN 16 ELSE 10 END +
      CASE WHEN p.ean IS NOT NULL AND length(p.ean) >= 8 THEN 10 ELSE 0 END +
      CASE WHEN EXISTS (SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains') THEN 10 ELSE 0 END,
      100
    ) >= 50 THEN 'medium'
    ELSE 'low'
  END AS confidence_band
FROM products p
LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_confidence_id ON v_product_confidence(product_id);
CREATE INDEX IF NOT EXISTS idx_product_confidence_band ON v_product_confidence(confidence_band);

-- Grant permissions on new objects
GRANT ALL ON product_allergen_info TO anon, authenticated, service_role;
GRANT ALL ON v_master TO anon, authenticated, service_role;
GRANT ALL ON v_api_category_overview TO anon, authenticated, service_role;
GRANT ALL ON mv_ingredient_frequency TO anon, authenticated, service_role;
GRANT ALL ON v_product_confidence TO anon, authenticated, service_role;


-- ═══════════════════════════════════════════════════════════════════════════
-- 7. UPDATE FUNCTIONS (only those directly referencing old tables)
-- ═══════════════════════════════════════════════════════════════════════════

-- 7a) api_search_products — was joining scores, now scores are on products
CREATE OR REPLACE FUNCTION api_search_products(
  p_query text,
  p_category text DEFAULT NULL,
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0
) RETURNS jsonb LANGUAGE plpgsql STABLE AS $function$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_query   text;
BEGIN
    v_query := TRIM(p_query);
    IF LENGTH(v_query) < 2 THEN
        RETURN jsonb_build_object('error', 'Query must be at least 2 characters.');
    END IF;
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    SELECT COUNT(*)::int INTO v_total
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND (
          p.product_name ILIKE '%' || v_query || '%'
          OR p.brand ILIKE '%' || v_query || '%'
          OR similarity(p.product_name, v_query) > 0.15
      );

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'brand',               p.brand,
            'category',            p.category,
            'unhealthiness_score', p.unhealthiness_score,
            'score_band',          CASE
                                     WHEN p.unhealthiness_score <= 25 THEN 'low'
                                     WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN p.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         p.nutri_score_label,
            'nova_group',          p.nova_classification,
            'relevance',           GREATEST(
                                     similarity(p.product_name, v_query),
                                     similarity(p.brand, v_query) * 0.8
                                   )
        ) AS row_data
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND (p_category IS NULL OR p.category = p_category)
          AND (
              p.product_name ILIKE '%' || v_query || '%'
              OR p.brand ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
        ORDER BY
            CASE WHEN p.product_name ILIKE v_query || '%' THEN 0 ELSE 1 END,
            GREATEST(similarity(p.product_name, v_query), similarity(p.brand, v_query) * 0.8) DESC,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'query',       v_query,
        'category',    p_category,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$function$;

-- 7b) api_score_explanation — was joining scores, now on products
CREATE OR REPLACE FUNCTION api_score_explanation(p_product_id bigint)
RETURNS jsonb LANGUAGE sql STABLE AS $function$
    SELECT jsonb_build_object(
        'product_id',      m.product_id,
        'product_name',    m.product_name,
        'brand',           m.brand,
        'category',        m.category,
        'score_breakdown', m.score_breakdown,
        'summary', jsonb_build_object(
            'score',       m.unhealthiness_score,
            'score_band',  CASE
                             WHEN m.unhealthiness_score <= 25 THEN 'low'
                             WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                             WHEN m.unhealthiness_score <= 75 THEN 'high'
                             ELSE 'very_high'
                           END,
            'headline',    CASE
                             WHEN m.unhealthiness_score <= 15 THEN
                                 'This product scores very well. It has low levels of nutrients of concern.'
                             WHEN m.unhealthiness_score <= 30 THEN
                                 'This product has a moderate profile. Some areas could be better.'
                             WHEN m.unhealthiness_score <= 50 THEN
                                 'This product has several areas of nutritional concern.'
                             ELSE
                                 'This product has significant nutritional concerns across multiple factors.'
                           END,
            'nutri_score',    m.nutri_score_label,
            'nova_group',     m.nova_classification,
            'processing_risk',m.processing_risk
        ),
        'top_factors', (
            SELECT jsonb_agg(f ORDER BY (f->>'weighted')::numeric DESC)
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS f
            WHERE (f->>'weighted')::numeric > 0
        ),
        'warnings', (
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'message', 'Salt content exceeds 1.5g per 100g.')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'message', 'Sugar content is elevated.')             WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'message', 'Saturated fat content is elevated.')     WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'message', 'This product has a high additive load.') WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'message', 'Contains palm oil.')                     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'message', 'Classified as ultra-processed (NOVA 4).') WHERE m.nova_classification = '4'
            ) warnings
        ),
        'category_context', (
            SELECT jsonb_build_object(
                'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
                'category_rank',      (
                    SELECT COUNT(*) + 1
                    FROM v_master m2
                    WHERE m2.category = m.category
                      AND m2.unhealthiness_score < m.unhealthiness_score
                ),
                'category_total',     COUNT(*)::int,
                'relative_position',  CASE
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score)       THEN 'better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                    ELSE 'much_worse_than_average'
                END
            )
            FROM products p2
            WHERE p2.category = m.category AND p2.is_deprecated IS NOT TRUE
        )
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

-- 7c) find_better_alternatives — was joining scores, now on products
CREATE OR REPLACE FUNCTION find_better_alternatives(
  p_product_id bigint,
  p_same_category boolean DEFAULT true,
  p_limit integer DEFAULT 5
) RETURNS TABLE(
  alt_product_id bigint, product_name text, brand text, category text,
  unhealthiness_score integer, score_improvement integer, shared_ingredients integer,
  jaccard_similarity numeric, nutri_score_label text
) LANGUAGE sql STABLE AS $function$
    WITH target AS (
        SELECT p.product_id, p.category AS target_cat, p.unhealthiness_score AS target_score
        FROM products p
        WHERE p.product_id = p_product_id
    ),
    target_ingredients AS (
        SELECT ingredient_id FROM product_ingredient WHERE product_id = p_product_id
    ),
    target_count AS (
        SELECT COUNT(*)::int AS cnt FROM target_ingredients
    ),
    candidates AS (
        SELECT
            p2.product_id AS cand_id, p2.product_name, p2.brand, p2.category,
            p2.unhealthiness_score, p2.nutri_score_label,
            COUNT(DISTINCT pi2.ingredient_id) FILTER (
                WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
            )::int AS shared,
            COUNT(DISTINCT pi2.ingredient_id)::int AS cand_total
        FROM products p2
        LEFT JOIN product_ingredient pi2 ON pi2.product_id = p2.product_id
        CROSS JOIN target t
        WHERE p2.is_deprecated IS NOT TRUE
          AND p2.product_id != p_product_id
          AND p2.unhealthiness_score < t.target_score
          AND (NOT p_same_category OR p2.category = t.target_cat)
        GROUP BY p2.product_id, p2.product_name, p2.brand, p2.category, p2.unhealthiness_score, p2.nutri_score_label
    )
    SELECT c.cand_id, c.product_name, c.brand, c.category,
        c.unhealthiness_score::integer,
        (t.target_score - c.unhealthiness_score)::integer AS score_improvement,
        c.shared,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3),
        c.nutri_score_label
    FROM candidates c
    CROSS JOIN target t
    CROSS JOIN target_count tc
    ORDER BY (t.target_score - c.unhealthiness_score) DESC,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC
    LIMIT p_limit;
$function$;

-- 7d) find_similar_products — was joining scores, now on products
CREATE OR REPLACE FUNCTION find_similar_products(
  p_product_id bigint,
  p_limit integer DEFAULT 5
) RETURNS TABLE(
  similar_product_id bigint, product_name text, brand text, category text,
  unhealthiness_score integer, shared_ingredients integer,
  total_ingredients_a integer, total_ingredients_b integer, jaccard_similarity numeric
) LANGUAGE sql STABLE AS $function$
    WITH target_ingredients AS (
        SELECT ingredient_id FROM product_ingredient WHERE product_id = p_product_id
    ),
    target_count AS (
        SELECT COUNT(*)::int AS cnt FROM target_ingredients
    ),
    candidates AS (
        SELECT
            pi2.product_id AS cand_id,
            COUNT(DISTINCT pi2.ingredient_id) FILTER (
                WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
            )::int AS shared,
            COUNT(DISTINCT pi2.ingredient_id)::int AS cand_total
        FROM product_ingredient pi2
        WHERE pi2.product_id != p_product_id
          AND pi2.product_id IN (SELECT product_id FROM products WHERE is_deprecated IS NOT TRUE)
        GROUP BY pi2.product_id
        HAVING COUNT(DISTINCT pi2.ingredient_id) FILTER (
            WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
        ) > 0
    )
    SELECT c.cand_id, p.product_name, p.brand, p.category,
        p.unhealthiness_score::integer, c.shared, tc.cnt, c.cand_total,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3)
    FROM candidates c
    CROSS JOIN target_count tc
    JOIN products p ON p.product_id = c.cand_id
    ORDER BY ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC,
        p.unhealthiness_score ASC
    LIMIT p_limit;
$function$;

-- 7e) compute_data_confidence — was joining servings, product_sources, product_allergen
CREATE OR REPLACE FUNCTION compute_data_confidence(p_product_id bigint)
RETURNS jsonb LANGUAGE sql STABLE AS $function$
    WITH components AS (
        SELECT
            p.product_id,
            -- Nutrition completeness (0-30)
            (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END)
            AS nutrition_pts,
            -- Ingredient completeness (0-25)
            CASE WHEN EXISTS (
                SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
            ) THEN 25 ELSE 0 END AS ingredient_pts,
            -- Source confidence (0-20): based on source_type
            CASE
              WHEN p.source_type = 'off_api' THEN 18
              WHEN p.source_type = 'manual' THEN 16
              ELSE 10
            END AS source_pts,
            -- EAN presence (0-10)
            CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END AS ean_pts,
            -- Allergen data (0-10)
            CASE WHEN EXISTS (
                SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains'
            ) THEN 10 ELSE 0 END AS allergen_pts,
            -- Data completeness profile
            CASE WHEN EXISTS (
                SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
            ) THEN 'complete' ELSE 'missing' END AS ingredient_status,
            CASE
                WHEN nf.calories IS NOT NULL AND nf.total_fat_g IS NOT NULL AND nf.saturated_fat_g IS NOT NULL
                     AND nf.carbs_g IS NOT NULL AND nf.sugars_g IS NOT NULL AND nf.salt_g IS NOT NULL
                THEN 'full'
                WHEN nf.calories IS NOT NULL AND nf.total_fat_g IS NOT NULL
                THEN 'partial'
                ELSE 'missing'
            END AS nutrition_status,
            CASE WHEN EXISTS (
                SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = p.product_id AND ai.type = 'contains'
            ) THEN 'known' ELSE 'unknown' END AS allergen_status
        FROM products p
        LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
        WHERE p.product_id = p_product_id
          AND p.is_deprecated IS NOT TRUE
    )
    SELECT jsonb_build_object(
        'product_id', c.product_id,
        'confidence_score', LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts + c.ean_pts + c.allergen_pts, 100),
        'confidence_band', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts + c.ean_pts + c.allergen_pts, 100) >= 80 THEN 'high'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts + c.ean_pts + c.allergen_pts, 100) >= 50 THEN 'medium'
            ELSE 'low'
        END,
        'components', jsonb_build_object(
            'nutrition',   jsonb_build_object('points', c.nutrition_pts, 'max', 30),
            'ingredients', jsonb_build_object('points', c.ingredient_pts, 'max', 25),
            'source',      jsonb_build_object('points', c.source_pts, 'max', 20),
            'ean',         jsonb_build_object('points', c.ean_pts, 'max', 10),
            'allergens',   jsonb_build_object('points', c.allergen_pts, 'max', 10)
        ),
        'data_completeness_profile', jsonb_build_object(
            'nutrition',   c.nutrition_status,
            'ingredients', c.ingredient_status,
            'allergens',   c.allergen_status
        ),
        'missing_data', (
            SELECT jsonb_agg(field) FROM (
                SELECT 'calories' AS field WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.calories IS NOT NULL)
                UNION ALL SELECT 'total_fat_g' WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.total_fat_g IS NOT NULL)
                UNION ALL SELECT 'saturated_fat_g' WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.saturated_fat_g IS NOT NULL)
                UNION ALL SELECT 'carbs_g' WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.carbs_g IS NOT NULL)
                UNION ALL SELECT 'sugars_g' WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.sugars_g IS NOT NULL)
                UNION ALL SELECT 'salt_g' WHERE NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = c.product_id AND nf.salt_g IS NOT NULL)
                UNION ALL SELECT 'ingredients' WHERE NOT EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = c.product_id)
                UNION ALL SELECT 'allergens' WHERE NOT EXISTS (SELECT 1 FROM product_allergen_info ai WHERE ai.product_id = c.product_id AND ai.type = 'contains')
            ) missing
        ),
        'explanation', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts + c.ean_pts + c.allergen_pts, 100) >= 80 THEN
                'High confidence: comprehensive data from verified sources.'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts + c.ean_pts + c.allergen_pts, 100) >= 50 THEN
                'Medium confidence: core data present but some gaps.'
            ELSE
                'Low confidence: significant data gaps. Score may be unreliable.'
        END
    )
    FROM components c;
$function$;

COMMIT;
