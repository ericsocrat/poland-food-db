-- PIPELINE (CEREALS): add nutrition facts
-- PIPELINE__cereals__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-07

-- 1) Remove existing nutrition for PL Cereals so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Cereals'
);

-- 2) Insert verified per-SKU nutrition
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
    -- brand,                    product_name,                              kcal,  fat,  sat, trans, carbs, sugar, fiber, prot, salt
    ('Nestlé',                  'Nestlé Corn Flakes',                      '382','1.4','0.5','0',  '83',  '8.8', '4.2', '7.5','1.33'),
    ('Nestlé',                  'Nestlé Chocapic',                         '389','4.8','1.3','0',  '73.6','22.4','7.7', '8.9','0.22'),
    ('Nestlé',                  'Nestlé Cini Minis',                       '410','9.3','1.1','0',  '72.6','24.9','6.5', '5.8','0.9'),
    ('Nestlé',                  'Nestlé Cheerios Owsiany',                 '381','6.6','1.3','0',  '65.7','9',   '10.3','10.4','0.7'),
    ('Nestlé',                  'Nestlé Lion Caramel & Chocolate',         '402','6.3','1.1','0',  '74.2','25',  '6.6', '8.5','0.45'),
    ('Nestlé',                  'Nestlé Ciniminis Churros',                '395','5.8','0.7','0',  '75.8','24.8','4.8', '7.3','1'),
    ('Nesquik',                 'Nesquik Mix',                             '384','4.1','1.4','0',  '74.3','22',  '8.2', '8.4','0.17'),
    ('Sante',                   'Sante Gold Granola',                      '469','18', '2.7','0',  '61',  '15',  '6.3', '9.8','0.44'),
    ('Sante',                   'Sante Fit Granola Truskawka & Wiśnia',    '412','12', '1.7','0',  '77',  '8.7', '13',  '8.8','0.59'),
    ('Vitanella (Biedronka)',   'Vitanella Miami Hopki',                   '356','2.1','0.7','0',  '73.7','24',  '7.3', '9.2','0.44'),
    ('Vitanella (Biedronka)',   'Vitanella Choki',                         '375','3.1','1.2','0',  '74.5','25.2','6.8', '8.9','0.26'),
    ('Vitanella (Biedronka)',   'Vitanella Orito Kakaowe',                 '442','17.5','7.7','0', '61.6','26.5','3.5', '7.7','0.52'),
    ('Crownfield (Lidl)',       'Crownfield Goldini',                      '409','5.1','0.9','0',  '81.2','23.2','2.3', '8.5','1.28'),
    ('Crownfield (Lidl)',       'Crownfield Choco Muszelki',               '368','2.9','1.2','0',  '73.2','23.5','6.7', '8.8','0.22'),
    ('Melvit',                  'Melvit Płatki Owsiane Górskie',           '374','6.7','1.3','0',  '61',  '1.6', '9',   '13', '0'),
    ('Lubella',                 'Lubella Corn Flakes Pełne Ziarno',        '388','3.6','0.5','0',  '77',  '4.8', '5.9', '9',  '1.6')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
