-- PIPELINE (BREAD): add nutrition facts
-- PIPELINE__bread__03_add_nutrition.sql
-- All values per 100 g from Open Food Facts (EAN-verified).
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- UPSERT nutrition facts (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into nutrition_facts (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  sv.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- SOURDOUGH / RYE BREADS
    --                brand             product_name                                cal   fat   sat   trans  carbs  sug   fib   prot  salt
    ('Oskroba',               'Oskroba Chleb Baltonowski',              '241', '1.1', '0.1', '0', '49',   '0.8', '6.9', '1.6', '1.1'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni',            '227', '1.2', '0.3', '0', '47',   '2.9', '3.1', '6.8', '1.5'),
    ('Oskroba',               'Oskroba Chleb Graham',                   '222', '2.2', '0.3', '0', '41',   '0.5', '0',   '7.3', '1.2'),
    ('Oskroba',               'Oskroba Chleb Żytni Wieloziarnisty',     '234', '5.2', '0.4', '0', '40',   '2.5', '0',   '6.9', '1.0'),
    ('Oskroba',               'Oskroba Chleb Litewski',                 '237', '1.1', '0.3', '0', '49',   '7.2', '3.4', '6.0', '1.4'),
    ('Oskroba',               'Oskroba Chleb Żytni Pełnoziarnisty',     '199', '1.4', '0.2', '0', '37',   '5.1', '0',   '5.3', '1.5'),
    ('Oskroba',               'Oskroba Chleb Żytni Razowy',             '219', '1.8', '0.3', '0', '44',   '1.6', '0',   '4.8', '1.4'),
    -- PUMPERNICKEL / GERMAN-STYLE
    ('Mestemacher',            'Mestemacher Pumpernikiel',                '181', '1.0', '0.2', '0', '34',   '3.8', '7.5', '5.1', '1.2'),
    ('Mestemacher',            'Mestemacher Chleb Wielozbożowy Żytni',    '200', '1.9', '0.4', '0', '30.5', '4.9', '8.8', '5.8', '1.3'),
    ('Mestemacher',            'Mestemacher Chleb Razowy',                '198', '1.2', '0.2', '0', '37.9', '3.0', '7.7', '5.7', '1.2'),
    ('Mestemacher',            'Mestemacher Chleb Ziarnisty',             '264','13.8', '2.3', '0', '14.2', '0.8', '8.3','10.8', '1.1'),
    ('Mestemacher',            'Mestemacher Chleb Żytni',                 '202', '1.1', '0.2', '0', '37',   '3.7', '9.8', '5.7', '1.2'),
    -- TOAST BREADS
    ('Schulstad',              'Schulstad Toast Pszenny',                 '252', '2.6', '0.3', '0', '48',   '4.7', '3.1', '8.0', '1.28'),
    ('Klara',                  'Klara American Sandwich Toast XXL',       '273', '4.4', '0.5', '0', '49',   '2.5', '2.2', '7.8', '1.4'),
    ('Pano',                   'Pano Tost Maślany',                      '244', '1.4', '0.3', '0', '47',   '3.5', '2.8', '7.5', '1.1'),
    -- CRISPBREADS
    ('Wasa',                   'Wasa Original',                           '334', '1.5', '0.3', '0', '63.5', '1.2','17.0', '9.0', '1.3'),
    ('Wasa',                   'Wasa Pieczywo z Błonnikiem',              '333', '5.0', '0.7', '0', '46',   '2.5','26.0','14.0', '1.0'),
    ('Wasa',                   'Wasa Lekkie 7 Ziaren',                   '388', '5.3', '0.7', '0', '72',   '5.0', '5.3','10.0', '1.4'),
    ('Sonko',                  'Sonko Pieczywo Chrupkie Ryżowe',          '363', '1.0', '0.2', '0', '77',   '0.5', '6.0', '8.0', '0.98'),
    ('Carrefour',              'Carrefour Pieczywo Chrupkie Kukurydziane','370', '2.9', '0.4', '0', '76',   '1.1', '3.3', '8.1', '0.57'),
    -- WRAPS / TORTILLAS
    ('Tastino',                'Tastino Tortilla Wraps',                  '310', '7.0', '1.0', '0', '52',   '3.9', '2.0', '7.9', '1.5'),
    ('Tastino',                'Tastino Wholegrain Wraps',                '289', '5.7', '0.8', '0', '44',   '2.4', '6.4', '9.9', '1.3'),
    ('Pano',                   'Pano Tortilla',                           '327', '7.7', '1.5', '0', '56.7', '3.5', '0',   '8.2', '1.5'),
    -- ROLLS / BUNS / SEED
    ('Oskroba',               'Oskroba Bułki Hamburgerowe',              '346','11.0', '1.6', '0', '53',   '7.3', '0',   '8.4', '1.0'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni z Ziarnami', '261', '3.6', '0.5', '0', '45',   '2.3', '3.5', '9.5', '1.3'),
    ('Pano',                   'Pano Bułeczki Śniadaniowe',              '350', '7.0', '1.0', '0', '50',   '8.0', '2.5','10.0', '1.2'),
    -- RUSKS / WHOLEGRAIN TOAST
    ('Carrefour',              'Carrefour Sucharki Pełnoziarniste',        '366', '6.5', '0.5', '0', '62',   '5.5','12.0','12.0', '1.5'),
    ('Pano',                   'Pano Tost Pełnoziarnisty',               '240', '2.0', '0.3', '0', '43',   '4.5', '5.6', '9.2', '1.1')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories        = excluded.calories,
  total_fat_g     = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g     = excluded.trans_fat_g,
  carbs_g         = excluded.carbs_g,
  sugars_g        = excluded.sugars_g,
  fibre_g         = excluded.fibre_g,
  protein_g       = excluded.protein_g,
  salt_g          = excluded.salt_g;
