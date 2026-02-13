-- Fix: v_api_category_overview should only include products from active countries
-- Bug exposed by DE micro-pilot: inactive-country products were counted in global stats

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
  JOIN country_ref cref ON cref.country_code = p.country AND cref.is_active = true
  WHERE p.category = cr.category AND p.is_deprecated IS NOT TRUE
) stats ON true
WHERE cr.is_active = true
ORDER BY cr.sort_order;
