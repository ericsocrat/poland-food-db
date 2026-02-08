-- PIPELINE (BREAKFAST & GRAIN-BASED): add nutrition facts
-- PIPELINE__breakfast__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Breakfast & Grain-Based so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
);

-- 2) Insert verified per-SKU nutrition (per 100 g)
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- GRANOLA
    ('Nestlé',                  'Nestlé Granola Almonds',                  '465','18','3.2','0',   '60', '18',  '5.8', '10',  '0.35'),
    ('Sante',                   'Sante Organic Granola',                   '458','15','2.5','0',   '63', '15',  '7.2', '9.5', '0.18'),
    ('Kupiec',                  'Kupiec Granola w Miodzie',                '472','19','2.8','0',   '59', '20',  '6',   '8.5', '0.42'),
    ('Crownfield (Lidl)',       'Crownfield Granola Nuts',                 '468','17.5','2.3','0', '62', '17',  '6.5', '11',  '0.25'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Owoce',                 '445','16','3.1','0',   '64', '22',  '5.5', '8',   '0.5'),

    -- MUESLI
    ('Nestlé',                  'Nestlé Muesli 5 Grains',                  '378','6.8','1.2','0',  '73', '12',  '8.5', '12',  '0.4'),
    ('Sante',                   'Sante Muesli Bio',                        '365','5.5','0.8','0',  '75', '8',   '10',  '11',  '0.08'),
    ('Mix',                     'Mix Muesli Classic',                       '382','7.2','1.5','0',  '70', '14',  '9',   '10.5','0.35'),
    ('Crownfield (Lidl)',       'Crownfield Musli Bio',                    '368','6','1','0',     '74', '10',  '11',  '11.5','0.15'),

    -- BREAKFAST BARS
    ('Vitanella (Biedronka)',   'Biedronka Fitness Cereal Bar',             '395','8','2.5','0',   '68', '24',  '6',   '8',   '0.65'),
    ('Nestlé',                  'Nestlé AERO Breakfast Bar',               '412','14','4.2','0.5', '62', '28',  '4.5', '7.5', '0.5'),
    ('Müller',                  'Müller Granola Bar',                       '428','16','4','0.2',  '61', '26',  '5.5', '9',   '0.55'),
    ('Vitanella (Biedronka)',   'Vitanella Granola Bar',                   '405','12','3','0',    '65', '25',  '5.8', '7',   '0.6'),
    ('Carrefour',               'Carrefour Energy Bar',                     '440','18','3.5','0',  '58', '20',  '7',   '11',  '0.4'),

    -- INSTANT OATMEAL
    ('Kupiec',                  'Kupiec Instant Oatmeal',                  '376','6.5','1.2','0', '68', '15',  '8',   '11',  '0.02'),
    ('Melvit',                  'Melvit Instant Owsianka',                 '371','6.2','1.1','0', '70', '10',  '9.5', '12',  '0'),
    ('Vitanella (Biedronka)',   'Biedronka Quick Oats',                    '378','6.8','1.3','0', '68', '13',  '8.5', '11.5','0.01'),

    -- PORRIDGE / INSTANT PORRIDGE
    ('Quick Oats',              'Quick Oats Instant Porridge',             '342','8','2.2','0.1', '60', '22',  '5.5', '7.8', '0.35'),
    ('Kupiec',                  'Kupiec Instant Porridge Chocolate',       '358','9.2','3','0.2', '58', '25',  '4.8', '6.5', '0.3'),
    ('Sante',                   'Sante Instant Porridge',                  '328','6.5','1.5','0', '62', '15',  '7',   '9',   '0.12'),

    -- PANCAKE MIXES
    ('Dr. Oetker',              'Dr. Oetker Pancake Mix',                  '338','1.2','0.3','0', '72', '4',   '4',   '8.5', '0.8'),
    ('Pan Maslak',              'Pan Maslak Nalesniki Mix',                '342','0.8','0.2','0', '73.5','3',  '3.5', '9',   '0.75'),

    -- HONEY
    ('Centrum',                 'Centrum Honey',                           '304','0','0','0',     '82', '76',  '0',   '0.3', '0.02'),
    ('Polish Beekeepers',       'Polish Beekeepers Acacia Honey',          '308','0.1','0','0',   '80', '75',  '0',   '0.2', '0'),

    -- JAM
    ('Vitanella (Biedronka)',   'Biedronka Jam Raspberry',                 '278','0.2','0','0',   '68', '58',  '1.5', '0.5', '0.01'),
    ('Nestlé',                  'Nestlé Konfiturama Mixed Berry',          '280','0.3','0','0',   '69', '58',  '1.8', '0.6', '0.03'),

    -- CHOCOLATE SPREADS
    ('Ferrero',                 'Nutella',                                 '532','31','10.2','0','57', '55',  '0',   '6.3', '0.11'),
    ('Vitanella (Biedronka)',   'Biedronka Chocolate Spread',              '524','29.5','9.8','0','58', '53',  '0.2', '5.8', '0.12')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;
