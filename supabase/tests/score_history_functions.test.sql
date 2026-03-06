-- ─── pgTAP: Score history & watchlist function tests ────────────────────────
-- Tests api_get_score_history, api_watch_product, api_unwatch_product,
--       api_get_watchlist.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(30);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-score-hist', 'pgtap-score-hist', 'pgTAP Score Hist', 997, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-score-hist';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO UPDATE SET nutri_score_official = false;

-- Product with score history (multiple snapshots)
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification,
  high_salt_flag, high_sugar_flag, high_sat_fat_flag
) VALUES (
  999970, '4000000000010', 'pgTAP Score History Product', 'Hist Brand',
  'pgtap-score-hist', 'XX', 40, 'C', '3',
  'NO', 'YES', 'NO'
) ON CONFLICT (product_id) DO NOTHING;

-- Product with no history
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification,
  high_salt_flag, high_sugar_flag, high_sat_fat_flag
) VALUES (
  999971, '4000000000027', 'pgTAP No History Product', 'Hist Brand',
  'pgtap-score-hist', 'XX', 25, 'B', '2',
  'NO', 'NO', 'NO'
) ON CONFLICT (product_id) DO NOTHING;

-- Product with reformulation (large delta)
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification,
  high_salt_flag, high_sugar_flag, high_sat_fat_flag
) VALUES (
  999972, '4000000000034', 'pgTAP Reformulated Product', 'Hist Brand',
  'pgtap-score-hist', 'XX', 20, 'A', '2',
  'NO', 'NO', 'NO'
) ON CONFLICT (product_id) DO NOTHING;

-- Score history entries for product 999970 (improving trend: deltas all < 0)
INSERT INTO public.product_score_history
  (product_id, recorded_at, unhealthiness_score, nutri_score_label, nova_group, trigger_source, score_delta)
VALUES
  (999970, '2026-01-01', 55, 'D', '4', 'backfill', 0),
  (999970, '2026-01-15', 50, 'C', '3', 'pipeline', -5),
  (999970, '2026-02-01', 45, 'C', '3', 'pipeline', -5),
  (999970, '2026-02-15', 40, 'C', '3', 'pipeline', -5)
ON CONFLICT (product_id, recorded_at) DO NOTHING;

-- Score history for product 999972 (reformulation: large delta)
INSERT INTO public.product_score_history
  (product_id, recorded_at, unhealthiness_score, nutri_score_label, nova_group, trigger_source, score_delta)
VALUES
  (999972, '2026-01-01', 50, 'C', '3', 'backfill', 0),
  (999972, '2026-02-01', 20, 'A', '2', 'pipeline', -30)
ON CONFLICT (product_id, recorded_at) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_get_score_history — product with history
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_score_history(999970)$$,
  'api_get_score_history does not throw for product with history'
);

-- Response has expected top-level keys
SELECT ok(
  (public.api_get_score_history(999970)) ? 'product_id',
  'score history response has product_id key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'trend',
  'score history response has trend key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'current_score',
  'score history response has current_score key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'previous_score',
  'score history response has previous_score key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'delta',
  'score history response has delta key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'reformulation_detected',
  'score history response has reformulation_detected key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'history',
  'score history response has history key'
);

SELECT ok(
  (public.api_get_score_history(999970)) ? 'total_snapshots',
  'score history response has total_snapshots key'
);

-- Verify product_id value
SELECT is(
  ((public.api_get_score_history(999970))->>'product_id')::bigint,
  999970::bigint,
  'score history returns correct product_id'
);

-- Verify current score
SELECT is(
  ((public.api_get_score_history(999970))->>'current_score')::numeric,
  40::numeric,
  'current_score is the most recent score (40)'
);

-- Verify total snapshots (4 entries inserted)
SELECT is(
  ((public.api_get_score_history(999970))->>'total_snapshots')::int,
  4,
  'total_snapshots is 4'
);

-- Trend should be improving (all 3 recent deltas < 0)
SELECT is(
  (public.api_get_score_history(999970))->>'trend',
  'improving',
  'trend is improving when all recent deltas are negative'
);

-- History entries have expected keys
SELECT ok(
  ((public.api_get_score_history(999970))->'history'->0) ? 'date',
  'history entry has date key'
);

SELECT ok(
  ((public.api_get_score_history(999970))->'history'->0) ? 'score',
  'history entry has score key'
);

SELECT ok(
  ((public.api_get_score_history(999970))->'history'->0) ? 'delta',
  'history entry has delta key'
);

SELECT ok(
  ((public.api_get_score_history(999970))->'history'->0) ? 'source',
  'history entry has source key'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_get_score_history — empty history (product 999971)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_score_history(999971)$$,
  'api_get_score_history does not throw for product with no history'
);

SELECT is(
  (public.api_get_score_history(999971))->>'trend',
  'stable',
  'trend is stable when no history exists'
);

SELECT is(
  ((public.api_get_score_history(999971))->>'total_snapshots')::int,
  0,
  'total_snapshots is 0 for product with no history'
);

SELECT is(
  (public.api_get_score_history(999971))->'history',
  '[]'::jsonb,
  'history is empty array for product with no history'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_score_history — reformulation detection (product 999972)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  ((public.api_get_score_history(999972))->>'reformulation_detected')::boolean,
  true,
  'reformulation_detected is true when delta >= 10'
);

-- Product 999970 has no reformulation (max delta is 5)
SELECT is(
  ((public.api_get_score_history(999970))->>'reformulation_detected')::boolean,
  false,
  'reformulation_detected is false when all deltas < 10'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_get_score_history — limit parameter
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  ((public.api_get_score_history(999970, 2))->>'total_snapshots')::int,
  2,
  'limit parameter restricts history entries returned'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Auth-error branches for watchlist functions
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_watch_product(999970)$$,
  'api_watch_product does not throw without auth'
);

SELECT is(
  (public.api_watch_product(999970))->>'error',
  'not_authenticated',
  'api_watch_product returns not_authenticated error without auth'
);

SELECT lives_ok(
  $$SELECT public.api_unwatch_product(999970)$$,
  'api_unwatch_product does not throw without auth'
);

SELECT is(
  (public.api_unwatch_product(999970))->>'error',
  'not_authenticated',
  'api_unwatch_product returns not_authenticated error without auth'
);

SELECT lives_ok(
  $$SELECT public.api_get_watchlist()$$,
  'api_get_watchlist does not throw without auth'
);

SELECT is(
  (public.api_get_watchlist())->>'error',
  'not_authenticated',
  'api_get_watchlist returns not_authenticated error without auth'
);


SELECT * FROM finish();
ROLLBACK;
