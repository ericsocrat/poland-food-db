-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Add category slugs + fix category listing sort
--
-- 1. Add `slug` column to category_ref with URL-safe values
-- 2. Rebuild v_api_category_overview_by_country to expose slug
-- 3. Update api_category_overview to return slug
-- 4. Update api_category_listing: accept slug, resolve to category, fix sort LPAD
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─── 1. Add slug column ─────────────────────────────────────────────────────

ALTER TABLE public.category_ref ADD COLUMN IF NOT EXISTS slug text;

UPDATE public.category_ref SET slug = 'alcohol'                   WHERE category = 'Alcohol';
UPDATE public.category_ref SET slug = 'baby'                      WHERE category = 'Baby';
UPDATE public.category_ref SET slug = 'bread'                     WHERE category = 'Bread';
UPDATE public.category_ref SET slug = 'breakfast-grain-based'     WHERE category = 'Breakfast & Grain-Based';
UPDATE public.category_ref SET slug = 'canned-goods'              WHERE category = 'Canned Goods';
UPDATE public.category_ref SET slug = 'cereals'                   WHERE category = 'Cereals';
UPDATE public.category_ref SET slug = 'chips'                     WHERE category = 'Chips';
UPDATE public.category_ref SET slug = 'condiments'                WHERE category = 'Condiments';
UPDATE public.category_ref SET slug = 'dairy'                     WHERE category = 'Dairy';
UPDATE public.category_ref SET slug = 'drinks'                    WHERE category = 'Drinks';
UPDATE public.category_ref SET slug = 'frozen-prepared'           WHERE category = 'Frozen & Prepared';
UPDATE public.category_ref SET slug = 'instant-frozen'            WHERE category = 'Instant & Frozen';
UPDATE public.category_ref SET slug = 'meat'                      WHERE category = 'Meat';
UPDATE public.category_ref SET slug = 'nuts-seeds-legumes'        WHERE category = 'Nuts, Seeds & Legumes';
UPDATE public.category_ref SET slug = 'plant-based-alternatives'  WHERE category = 'Plant-Based & Alternatives';
UPDATE public.category_ref SET slug = 'sauces'                    WHERE category = 'Sauces';
UPDATE public.category_ref SET slug = 'seafood-fish'              WHERE category = 'Seafood & Fish';
UPDATE public.category_ref SET slug = 'snacks'                    WHERE category = 'Snacks';
UPDATE public.category_ref SET slug = 'sweets'                    WHERE category = 'Sweets';
UPDATE public.category_ref SET slug = 'zabka'                     WHERE category = 'Żabka';

ALTER TABLE public.category_ref ALTER COLUMN slug SET NOT NULL;
ALTER TABLE public.category_ref ADD CONSTRAINT uq_category_ref_slug UNIQUE (slug);

COMMENT ON COLUMN public.category_ref.slug IS
'URL-safe slug for this category (e.g. "seafood-fish"). Used in frontend routes. Unique.';

-- ─── 2. Rebuild view to include slug ────────────────────────────────────────
-- Must DROP first — CREATE OR REPLACE cannot add/reorder columns on an existing view.

DROP VIEW IF EXISTS public.v_api_category_overview_by_country;

CREATE VIEW public.v_api_category_overview_by_country AS
SELECT
    p.country                                               AS country_code,
    cr.category,
    cr.slug,
    cr.display_name,
    cr.description                                          AS category_description,
    cr.icon_emoji,
    cr.sort_order,
    COUNT(*)::int                                           AS product_count,
    ROUND(AVG(p.unhealthiness_score), 1)                   AS avg_score,
    MIN(p.unhealthiness_score)::int                        AS min_score,
    MAX(p.unhealthiness_score)::int                        AS max_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY p.unhealthiness_score)::int              AS median_score,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE p.nutri_score_label IN ('A','B')
    ) / NULLIF(COUNT(*), 0), 1)                            AS pct_nutri_a_b,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE p.nova_classification = '4'
    ) / NULLIF(COUNT(*), 0), 1)                            AS pct_nova_4
FROM public.products p
JOIN public.category_ref cr  ON cr.category = p.category
JOIN public.country_ref cref ON cref.country_code = p.country
WHERE p.is_deprecated IS NOT TRUE
  AND cr.is_active   = true
  AND cref.is_active = true
GROUP BY p.country, cr.category, cr.slug, cr.display_name, cr.description,
         cr.icon_emoji, cr.sort_order
ORDER BY p.country, cr.sort_order;

COMMENT ON VIEW public.v_api_category_overview_by_country IS
'Country-dimensioned dashboard stats with slug. One row per (country, category) pair.';

REVOKE SELECT ON public.v_api_category_overview_by_country FROM anon, authenticated;

-- ─── 3. Update api_category_overview to return slug ─────────────────────────

CREATE OR REPLACE FUNCTION public.api_category_overview(
    p_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_country text;
    v_rows    jsonb;
BEGIN
    v_country := resolve_effective_country(p_country);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'country_code',         ov.country_code,
            'category',             ov.category,
            'slug',                 ov.slug,
            'display_name',         ov.display_name,
            'category_description', ov.category_description,
            'icon_emoji',           ov.icon_emoji,
            'sort_order',           ov.sort_order,
            'product_count',        ov.product_count,
            'avg_score',            ov.avg_score,
            'min_score',            ov.min_score,
            'max_score',            ov.max_score,
            'median_score',         ov.median_score,
            'pct_nutri_a_b',        ov.pct_nutri_a_b,
            'pct_nova_4',           ov.pct_nova_4
        ) AS row_data,
        ov.sort_order
        FROM v_api_category_overview_by_country ov
        WHERE ov.country_code = v_country
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'country',     v_country,
        'categories',  v_rows
    );
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.api_category_overview(text) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.api_category_overview(text) TO authenticated, service_role;

-- ─── 4. Rebuild api_category_listing: slug resolution + sort fix ────────────

DROP FUNCTION IF EXISTS public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
);

CREATE OR REPLACE FUNCTION public.api_category_listing(
    p_category                text,
    p_sort_by                 text     DEFAULT 'score',
    p_sort_dir                text     DEFAULT 'asc',
    p_limit                   integer  DEFAULT 20,
    p_offset                  integer  DEFAULT 0,
    p_country                 text     DEFAULT NULL,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total     integer;
    v_rows      jsonb;
    v_country   text;
    v_category  text;
BEGIN
    -- Resolve slug → real category name (fall back to treating input as literal)
    SELECT cr.category INTO v_category
    FROM category_ref cr
    WHERE cr.slug = p_category;

    IF v_category IS NULL THEN
        -- Allow direct category name for backward compatibility
        SELECT cr.category INTO v_category
        FROM category_ref cr
        WHERE cr.category = p_category;
    END IF;

    IF v_category IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Unknown category: ' || COALESCE(p_category, 'NULL')
        );
    END IF;

    -- Clamp pagination
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    -- Resolve effective country (never NULL)
    v_country := resolve_effective_country(p_country);

    -- Get total count
    SELECT COUNT(*)::int INTO v_total
    FROM v_master m
    WHERE m.category = v_category
      AND m.country = v_country
      AND check_product_preferences(
          m.product_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
      );

    -- Build result rows with dynamic ordering
    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          m.product_id,
            'ean',                 m.ean,
            'product_name',        m.product_name,
            'brand',               m.brand,
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,
            'calories',            m.calories,
            'total_fat_g',         m.total_fat_g,
            'protein_g',           m.protein_g,
            'sugars_g',            m.sugars_g,
            'salt_g',              m.salt_g,
            'high_salt_flag',      (m.high_salt_flag = 'YES'),
            'high_sugar_flag',     (m.high_sugar_flag = 'YES'),
            'high_sat_fat_flag',   (m.high_sat_fat_flag = 'YES'),
            'confidence',          m.confidence,
            'data_completeness_pct', m.data_completeness_pct
        ) AS row_data
        FROM v_master m
        WHERE m.category = v_category
          AND m.country = v_country
          AND check_product_preferences(
              m.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
        ORDER BY
            CASE WHEN p_sort_dir = 'asc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END ASC NULLS LAST,
            CASE WHEN p_sort_dir = 'desc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END DESC NULLS LAST,
            m.product_id ASC  -- stable tiebreaker
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'category',      v_category,
        'country',       v_country,
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'sort_by',       p_sort_by,
        'sort_dir',      p_sort_dir,
        'products',      v_rows
    );
END;
$function$;

COMMENT ON FUNCTION public.api_category_listing IS
'Paged category browse. Accepts slug or category name. Country is auto-resolved. '
'Never returns mixed-country results.';

REVOKE EXECUTE ON FUNCTION public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) TO authenticated, service_role;

COMMIT;
