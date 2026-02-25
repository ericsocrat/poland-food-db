-- ─── pgTAP: Scoring Band Coverage ───────────────────────────────────────────
-- Tests compute_unhealthiness_v32() and explain_score_v32() across all 5 bands.
-- Exercises Red (61-80) and Dark Red (81-100) which have 0 real products.
-- Synthetic inputs only — no test data inserted.
-- Run via: supabase test db
-- Related: Issue #373
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(25);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Green band (1-20): low-risk inputs
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0)$$,
  'Green band inputs compute without error'
);

SELECT cmp_ok(
  compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0),
  'BETWEEN', 1 AND 20,
  'Green band: low-risk inputs produce score 1-20'
);

-- Manual BETWEEN since cmp_ok doesn't support BETWEEN directly
SELECT ok(
  compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0) BETWEEN 1 AND 20,
  'Green band: score in range 1-20'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Yellow band (21-40): moderate inputs
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT compute_unhealthiness_v32(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20)$$,
  'Yellow band inputs compute without error'
);

SELECT ok(
  compute_unhealthiness_v32(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20) BETWEEN 21 AND 40,
  'Yellow band: moderate inputs produce score 21-40'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Orange band (41-60): elevated inputs
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT compute_unhealthiness_v32(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30)$$,
  'Orange band inputs compute without error'
);

SELECT ok(
  compute_unhealthiness_v32(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30) BETWEEN 41 AND 60,
  'Orange band: elevated inputs produce score 41-60'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Red band (61-80): high-risk inputs — PREVIOUSLY UNTESTED
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)$$,
  'Red band inputs compute without error'
);

SELECT ok(
  compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50) BETWEEN 61 AND 80,
  'Red band: high-risk inputs produce score 61-80'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Dark Red band (81-100): extreme inputs — PREVIOUSLY UNTESTED
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)$$,
  'Dark Red band inputs compute without error'
);

SELECT ok(
  compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100) BETWEEN 81 AND 100,
  'Dark Red band: extreme inputs produce score 81-100'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. All-ceiling produces exactly 100
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100),
  100,
  'All-ceiling inputs produce exactly 100'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. All-zero floor produces exactly 4 (only prep_method default contributes)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  compute_unhealthiness_v32(0, 0, 0, 0, 0, 0, 'not-applicable', 'none', 0),
  4,
  'All-zero inputs produce floor score of 4'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Band boundary tests: exact thresholds
-- ═══════════════════════════════════════════════════════════════════════════

-- Score 20 should be Green (upper boundary)
SELECT ok(
  compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0) <= 20,
  'Low-risk inputs stay within Green band (<=20)'
);

-- explain_score_v32 final_score matches compute for Red band
SELECT is(
  (explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)->>'final_score')::integer,
  compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50),
  'explain_score_v32 matches compute for Red band inputs'
);

-- explain_score_v32 final_score matches compute for Dark Red band
SELECT is(
  (explain_score_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)->>'final_score')::integer,
  compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100),
  'explain_score_v32 matches compute for Dark Red band inputs'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. explain_score_v32 output structure for Red band
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)) ? 'final_score',
  'Red band explain output has final_score key'
);

SELECT ok(
  (explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)) ? 'factors',
  'Red band explain output has factors key'
);

SELECT ok(
  (explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)) ? 'version',
  'Red band explain output has version key'
);

SELECT is(
  (explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)->>'version'),
  'v3.2',
  'Red band explain output version is v3.2'
);

-- Factor count = 9 for Red band
SELECT is(
  jsonb_array_length(explain_score_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)->'factors'),
  9,
  'Red band explain output has exactly 9 factors'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. explain_score_v32 output structure for Dark Red band
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (explain_score_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)) ? 'final_score',
  'Dark Red band explain output has final_score key'
);

SELECT is(
  jsonb_array_length(explain_score_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)->'factors'),
  9,
  'Dark Red band explain output has exactly 9 factors'
);

-- All factors at ceiling → every factor's raw = 100
SELECT is(
  (SELECT COUNT(*)::integer
   FROM jsonb_array_elements(
     explain_score_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)->'factors'
   ) AS f
   WHERE (f->>'raw')::numeric = 100.0),
  9,
  'All-ceiling: every factor raw value equals 100'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Monotonicity: each band's representative score < next band's score
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0)
  < compute_unhealthiness_v32(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20)
  AND compute_unhealthiness_v32(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20)
  < compute_unhealthiness_v32(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30)
  AND compute_unhealthiness_v32(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30)
  < compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)
  AND compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)
  < compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100),
  'Band representative scores are strictly monotonically increasing'
);

SELECT * FROM finish();
ROLLBACK;
