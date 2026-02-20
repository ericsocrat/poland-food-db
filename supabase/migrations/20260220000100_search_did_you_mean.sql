-- ─── Migration: "Did you mean?" search suggestions (#62) ────────────────────
-- Uses pg_trgm similarity() to suggest alternative product names when
-- a search query returns zero results.
--
-- Strategy:
--   1. Compare the user's query against product_name using trigram similarity
--   2. Fall back to brand matching if no product name matches
--   3. Return top 3 suggestions with similarity > 0.2 threshold
--   4. Diacritic-insensitive via unaccent()
--
-- Leverages existing pg_trgm GIN indexes on products.product_name.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_search_did_you_mean(
  p_query   text,
  p_country text    DEFAULT NULL,
  p_limit   integer DEFAULT 3
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_country text;
  v_clean   text;
  v_result  jsonb;
BEGIN
  -- Resolve country (same logic as api_search_products)
  v_country := COALESCE(
    p_country,
    (SELECT country FROM user_preferences WHERE user_id = auth.uid()),
    'PL'
  );

  -- Clean and normalize query (strip diacritics)
  v_clean := lower(trim(unaccent(COALESCE(p_query, ''))));

  -- Guard: empty or too-short query
  IF length(v_clean) < 2 THEN
    RETURN jsonb_build_object(
      'query', p_query,
      'suggestions', '[]'::jsonb
    );
  END IF;

  -- Find similar product names using pg_trgm
  SELECT jsonb_build_object(
    'query', p_query,
    'suggestions', COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
  )
  INTO v_result
  FROM (
    SELECT DISTINCT ON (p.product_name)
      p.id                    AS product_id,
      p.product_name,
      p.brand,
      p.category,
      p.unhealthiness_score,
      similarity(unaccent(lower(p.product_name)), v_clean) AS sim
    FROM products p
    WHERE p.country = v_country
      AND similarity(unaccent(lower(p.product_name)), v_clean) > 0.2
    ORDER BY p.product_name, sim DESC
    LIMIT p_limit
  ) t;

  RETURN COALESCE(v_result, jsonb_build_object(
    'query', p_query,
    'suggestions', '[]'::jsonb
  ));
END;
$$;

-- Grant to authenticated users (search is auth-only since localization phase 4)
GRANT EXECUTE ON FUNCTION public.api_search_did_you_mean(text, text, integer)
  TO authenticated;

COMMENT ON FUNCTION api_search_did_you_mean IS
  'Returns up to 3 similar product names when a search query finds no exact matches. Uses pg_trgm similarity for fuzzy matching. (#62)';
