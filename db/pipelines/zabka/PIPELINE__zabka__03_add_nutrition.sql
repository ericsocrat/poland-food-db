-- PIPELINE (ŻABKA): add nutrition facts
-- PIPELINE__zabka__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-07
--
-- Fiber values marked (est.) are category-typical estimates where OFF had no data.
-- Trans fat: not reported on EU labels; 0 used as conservative default.

-- 1) Remove existing nutrition for PL Żabka so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Żabka'
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
    -- brand,             product_name,                            kcal,  fat,  sat,  trans, carbs, sugar, fiber, prot,  salt
    -- ── Żabka own-brand ──────────────────────────────────────────────────────────────────────────────
    ('Żabka',            'Meksykaner',                            '242','9.7','4.6','0',   '26', '7.3', '1.5', '12',  '1.3'),   -- fiber: est.
    ('Żabka',            'Kurczaker',                             '214','7.9','2.2','0',   '21', '4.6', '1.5', '14',  '1.2'),   -- fiber: est.
    ('Żabka',            'Wołowiner Ser Kozi',                    '254','13', '5.4','0',   '20', '5.0', '2.0', '14',  '1.6'),
    ('Żabka',            'Burger Kibica',                         '223','6.8','2.8','0',   '26', '5.9', '1.9', '13',  '1.6'),
    ('Żabka',            'Falafel Rollo',                         '264','15', '1.3','0',   '23', '6.5', '4.9', '5.8', '1.1'),
    ('Żabka',            'Kajzerka Kebab',                        '306','16', '1.9','0',   '29', '4.1', '1.6', '9.8', '1.6'),
    ('Żabka',            'Panini z serem cheddar',                '330','18', '5.2','0',   '29', '1.9', '3.0', '11',  '1.5'),
    ('Żabka',            'Panini z kurczakiem',                   '241','9.1','2.9','0',   '25', '2.5', '2.0', '14',  '1.4'),
    ('Żabka',            'Kulki owsiane z czekoladą',             '440','19', '3.7','0',   '50', '26',  '6.6', '14',  '0.02'),
    -- ── Tomcio Paluch ────────────────────────────────────────────────────────────────────────────────
    ('Tomcio Paluch',    'Szynka & Jajko',                        '222','11', '2.0','0',   '22', '2.4', '1.2', '9.5', '1.1'),
    ('Tomcio Paluch',    'Pieczony bekon, sałata, jajko',         '262','17', '3.2','0',   '21', '1.9', '1.5', '6.7', '1.3'),   -- fiber: est.
    ('Tomcio Paluch',    'Bajgiel z salami',                      '329','21', '4.9','0',   '24', '4.4', '1.5', '9.7', '1.3'),   -- fiber: est.
    -- ── Szamamm ──────────────────────────────────────────────────────────────────────────────────────
    ('Szamamm',          'Naleśniki z jabłkami i cynamonem',       '135','2.7','0.4','0',   '23', '9.5', '1.6', '3.5', '0.65'),
    ('Szamamm',          'Placki ziemniaczane',                   '214','12', '1.1','0',   '21', '2.9', '2.6', '4.2', '1.0'),
    ('Szamamm',          'Penne z kurczakiem',                    '143','4.5','2.4','0',   '17', '3.0', '1.5', '7.5', '0.68'),
    ('Szamamm',          'Kotlet de Volaille',                    '115','5.4','2.9','0',   '9.1','3.2', '2.4', '6.4', '1.2')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
