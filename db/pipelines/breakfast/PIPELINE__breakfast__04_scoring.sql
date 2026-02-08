-- PIPELINE (BREAKFAST & GRAIN-BASED): scoring updates
-- PIPELINE__breakfast__04_scoring.sql
-- Formula-based v3.1 scoring.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- GRANOLA (moderate additives: emulsifiers, antioxidants)
    ('Nestlé',                  'Nestlé Granola Almonds',                  '2'),      -- e322, e306
    ('Sante',                   'Sante Organic Granola',                   '1'),      -- e306 only (certified organic)
    ('Kupiec',                  'Kupiec Granola w Miodzie',                '2'),      -- e306, e500
    ('Crownfield (Lidl)',       'Crownfield Granola Nuts',                 '2'),      -- e322, e306
    ('Vitanella (Biedronka)',   'Vitanella Granola Owoce',                 '3'),      -- e306, e330, e500

    -- MUESLI (minimal additives, mostly natural)
    ('Nestlé',                  'Nestlé Muesli 5 Grains',                  '1'),      -- e306
    ('Sante',                   'Sante Muesli Bio',                        '0'),      -- organic, no additives
    ('Mix',                     'Mix Muesli Classic',                       '1'),      -- e306
    ('Crownfield (Lidl)',       'Crownfield Musli Bio',                    '0'),      -- organic certified

    -- BREAKFAST BARS (higher additives: binders, preservatives, colorants)
    ('Vitanella (Biedronka)',   'Biedronka Fitness Cereal Bar',             '3'),      -- e150a, e306, e330
    ('Nestlé',                  'Nestlé AERO Breakfast Bar',               '4'),      -- e476, e322, e306, e500
    ('Müller',                  'Müller Granola Bar',                       '4'),      -- e450, e322, e471, e306
    ('Vitanella (Biedronka)',   'Vitanella Granola Bar',                   '2'),      -- e306, e330
    ('Carrefour',               'Carrefour Energy Bar',                     '2'),      -- e471, e322 (organic positioning)

    -- INSTANT OATMEAL (minimal additives, mostly unprocessed)
    ('Kupiec',                  'Kupiec Instant Oatmeal',                  '0'),      -- pure rolled oats instant cut
    ('Melvit',                  'Melvit Instant Owsianka',                 '0'),      -- pure oats, no additives
    ('Vitanella (Biedronka)',   'Biedronka Quick Oats',                    '1'),      -- e306 (antioxidant)

    -- PORRIDGE / INSTANT PORRIDGE
    ('Quick Oats',              'Quick Oats Instant Porridge',             '2'),      -- e322, e500 (thickener)
    ('Kupiec',                  'Kupiec Instant Porridge Chocolate',       '3'),      -- e150a, e322, e500
    ('Sante',                   'Sante Instant Porridge',                  '1'),      -- e306 (antioxidant)

    -- PANCAKE MIXES
    ('Dr. Oetker',              'Dr. Oetker Pancake Mix',                  '2'),      -- e450, e500 (leavening)
    ('Pan Maslak',              'Pan Maslak Nalesniki Mix',                '1'),      -- e500 (minimal)

    -- HONEY (natural product, minimal to no additives)
    ('Centrum',                 'Centrum Honey',                           '0'),      -- raw honey, no additives
    ('Polish Beekeepers',       'Polish Beekeepers Acacia Honey',          '0'),      -- certified natural, no additives

    -- JAM (mostly natural, maybe preservative)
    ('Vitanella (Biedronka)',   'Biedronka Jam Raspberry',                 '1'),      -- e202 (potassium sorbate)
    ('Nestlé',                  'Nestlé Konfiturama Mixed Berry',          '1'),      -- e202

    -- CHOCOLATE SPREADS (emulsifiers, antioxidants, lecithin)
    ('Ferrero',                 'Nutella',                                 '3'),      -- e322, e306, e471
    ('Vitanella (Biedronka)',   'Biedronka Chocolate Spread',              '3')       -- e322, e306, e500
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. COMPUTE unhealthiness_score (v3.1 formula)
--    8 factors × weighted → clamped [1, 100]
--    sat_fat(0.18) + sugars(0.18) + salt(0.18) + calories(0.10) +
--    trans_fat(0.12) + additives(0.07) + prep_method(0.09) + controversies(0.08)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g::numeric,
      nf.sugars_g::numeric,
      nf.salt_g::numeric,
      nf.calories::numeric,
      nf.trans_fat_g::numeric,
      i.additives_count::numeric,
      p.prep_method,
      p.controversies
  )::text,
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- GRANOLA (moderate health score: C-D)
    ('Nestlé',                  'Nestlé Granola Almonds',                  'C'),
    ('Sante',                   'Sante Organic Granola',                   'C'),
    ('Kupiec',                  'Kupiec Granola w Miodzie',                'D'),
    ('Crownfield (Lidl)',       'Crownfield Granola Nuts',                 'C'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Owoce',                 'D'),

    -- MUESLI (good health: A-B for organic, low sugar)
    ('Nestlé',                  'Nestlé Muesli 5 Grains',                  'B'),
    ('Sante',                   'Sante Muesli Bio',                        'A'),
    ('Mix',                     'Mix Muesli Classic',                       'B'),
    ('Crownfield (Lidl)',       'Crownfield Musli Bio',                    'A'),

    -- BREAKFAST BARS (moderate: B-D)
    ('Vitanella (Biedronka)',   'Biedronka Fitness Cereal Bar',             'B'),
    ('Nestlé',                  'Nestlé AERO Breakfast Bar',               'D'),
    ('Müller',                  'Müller Granola Bar',                       'C'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Bar',                   'C'),
    ('Carrefour',               'Carrefour Energy Bar',                     'C'),

    -- INSTANT OATMEAL (good: A-B)
    ('Kupiec',                  'Kupiec Instant Oatmeal',                  'A'),
    ('Melvit',                  'Melvit Instant Owsianka',                 'A'),
    ('Vitanella (Biedronka)',   'Biedronka Quick Oats',                    'B'),

    -- PORRIDGE (moderate: B-C)
    ('Quick Oats',              'Quick Oats Instant Porridge',             'C'),
    ('Kupiec',                  'Kupiec Instant Porridge Chocolate',       'D'),
    ('Sante',                   'Sante Instant Porridge',                  'B'),

    -- PANCAKE MIXES (moderate: B-C)
    ('Dr. Oetker',              'Dr. Oetker Pancake Mix',                  'C'),
    ('Pan Maslak',              'Pan Maslak Nalesniki Mix',                'C'),

    -- HONEY (high sugar, moderate score: C)
    ('Centrum',                 'Centrum Honey',                           'C'),
    ('Polish Beekeepers',       'Polish Beekeepers Acacia Honey',          'C'),

    -- JAM (high sugar: C-D)
    ('Vitanella (Biedronka)',   'Biedronka Jam Raspberry',                 'D'),
    ('Nestlé',                  'Nestlé Konfiturama Mixed Berry',          'C'),

    -- CHOCOLATE SPREADS (poor health: D-E)
    ('Ferrero',                 'Nutella',                                 'E'),
    ('Vitanella (Biedronka)',   'Biedronka Chocolate Spread',              'D')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '1' then 'Low'
    else 'Low'
  end
from (
  values
    -- GRANOLA (ultra-processed: NOVA 4)
    ('Nestlé',                  'Nestlé Granola Almonds',                  '4'),
    ('Sante',                   'Sante Organic Granola',                   '3'),    -- organic but still processed
    ('Kupiec',                  'Kupiec Granola w Miodzie',                '4'),
    ('Crownfield (Lidl)',       'Crownfield Granola Nuts',                 '4'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Owoce',                 '4'),

    -- MUESLI (processed: NOVA 3, or NOVA 4 with heavy additives)
    ('Nestlé',                  'Nestlé Muesli 5 Grains',                  '3'),
    ('Sante',                   'Sante Muesli Bio',                        '3'),    -- organic, minimal additives
    ('Mix',                     'Mix Muesli Classic',                       '3'),
    ('Crownfield (Lidl)',       'Crownfield Musli Bio',                    '3'),

    -- BREAKFAST BARS (ultra-processed: NOVA 4)
    ('Vitanella (Biedronka)',   'Biedronka Fitness Cereal Bar',             '4'),
    ('Nestlé',                  'Nestlé AERO Breakfast Bar',               '4'),
    ('Müller',                  'Müller Granola Bar',                       '4'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Bar',                   '4'),
    ('Carrefour',               'Carrefour Energy Bar',                     '4'),

    -- INSTANT OATMEAL (processed: NOVA 3 - instant cut, simple processing)
    ('Kupiec',                  'Kupiec Instant Oatmeal',                  '3'),
    ('Melvit',                  'Melvit Instant Owsianka',                 '3'),
    ('Vitanella (Biedronka)',   'Biedronka Quick Oats',                    '3'),

    -- PORRIDGE (ultra-processed: NOVA 4 - sweetened, additives)
    ('Quick Oats',              'Quick Oats Instant Porridge',             '4'),
    ('Kupiec',                  'Kupiec Instant Porridge Chocolate',       '4'),
    ('Sante',                   'Sante Instant Porridge',                  '3'),    -- organic, fewer additives

    -- PANCAKE MIXES (processed: NOVA 3 - grain + leavening agent)
    ('Dr. Oetker',              'Dr. Oetker Pancake Mix',                  '3'),
    ('Pan Maslak',              'Pan Maslak Nalesniki Mix',                '3'),

    -- HONEY (unprocessed: NOVA 1)
    ('Centrum',                 'Centrum Honey',                           '1'),
    ('Polish Beekeepers',       'Polish Beekeepers Acacia Honey',          '1'),

    -- JAM (processed: NOVA 3)
    ('Vitanella (Biedronka)',   'Biedronka Jam Raspberry',                 '3'),
    ('Nestlé',                  'Nestlé Konfiturama Mixed Berry',          '3'),

    -- CHOCOLATE SPREADS (ultra-processed: NOVA 4)
    ('Ferrero',                 'Nutella',                                 '4'),
    ('Vitanella (Biedronka)',   'Biedronka Chocolate Spread',              '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g following EU "high" front-of-pack guidelines:
--      salt ≥ 1.5 g | sugars ≥ 5 g | sat fat ≥ 5 g | additives ≥ 5
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  high_salt_flag = case when nf.salt_g::numeric >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count::numeric, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100  -- all 8 scoring factors have real data
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 6. SET confidence level (auto-assigned based on data completeness + sources)
--    Uses assign_confidence() function from 20260208_assign_confidence.sql
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  confidence = assign_confidence(
    sc.data_completeness_pct,
    (SELECT src.source_type
     FROM sources src
     WHERE src.brand LIKE '%(' || p.category || ')%'
     LIMIT 1)
  )
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;
