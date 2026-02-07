-- PIPELINE (MEAT): add nutrition facts
-- PIPELINE__meat__03_add_nutrition.sql
-- All values per 100 g from Open Food Facts (EAN-verified).
-- Meat/deli products tend to be high in salt, saturated fat, and calories.
-- Last updated: 2026-02-07

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
    -- KABANOSY
    --                brand          product_name                             cal   fat   sat    trans  carbs sug   fib  prot  salt
    ('Tarczyński',   'Tarczyński Kabanosy Klasyczne',       '397','28.0','11.0', '0.3', '2.0','1.0', '0','26.0', '2.8'),
    ('Tarczyński',   'Tarczyński Kabanosy Exclusive',       '370','26.0','10.0', '0.2', '1.5','0.5', '0','30.0', '2.6'),
    ('Tarczyński',   'Tarczyński Kabanosy z Serem',         '385','28.0','11.5', '0.3', '3.0','1.5', '0','25.0', '2.5'),
    -- PARÓWKI / FRANKFURTERS
    ('Berlinki',     'Berlinki Parówki Klasyczne',         '240','19.0', '7.0', '0',   '3.0','1.0', '0','14.0', '2.0'),
    ('Berlinki',     'Berlinki Parówki z Szynki',          '195','13.0', '5.0', '0',   '3.5','1.5', '0','15.0', '2.0'),
    ('Sokołów',      'Sokołów Parówki Cienkie',            '220','17.0', '6.5', '0',   '2.5','0.8', '0','13.5', '2.1'),
    ('Krakus',       'Krakus Parówki Delikatesowe',        '235','18.0', '7.0', '0',   '3.0','1.0', '0','14.5', '1.9'),
    ('Morliny',      'Morliny Parówki Polskie',            '225','17.0', '6.5', '0',   '3.5','1.2', '0','13.0', '2.0'),
    -- SZYNKA / HAM
    ('Krakus',       'Krakus Szynka Konserwowa',           '112', '4.0', '1.5', '0',   '1.0','0.5', '0','18.0', '2.0'),
    ('Sokołów',      'Sokołów Szynka Mielona',             '195','14.0', '5.0', '0',   '2.0','0.5', '0','15.0', '2.2'),
    ('Morliny',      'Morliny Szynka Tradycyjna',          '105', '2.5', '1.0', '0',   '1.0','0.5', '0','20.0', '2.0'),
    ('Madej Wróbel', 'Madej Wróbel Szynka Gotowana',       '100', '2.0', '0.8', '0',   '1.5','0.5', '0','19.0', '1.9'),
    -- KIEŁBASA / SAUSAGE
    ('Sokołów',      'Sokołów Kiełbasa Krakowska Sucha',   '375','28.0','10.5', '0.2', '1.0','0.5', '0','30.0', '2.5'),
    ('Morliny',      'Morliny Kiełbasa Podwawelska',       '265','20.0', '7.5', '0',   '2.0','0.5', '0','19.0', '2.2'),
    ('Tarczyński',   'Tarczyński Kiełbasa Śląska',         '280','22.0', '8.0', '0',   '1.5','0.5', '0','19.0', '2.2'),
    ('Krakus',       'Krakus Kiełbasa Zwyczajna',          '270','21.0', '7.5', '0',   '2.0','0.8', '0','18.0', '2.1'),
    -- BOCZEK / BACON
    ('Morliny',      'Morliny Boczek Wędzony',             '340','30.0','11.0', '0',   '0.5','0.5', '0','17.0', '2.3'),
    ('Sokołów',      'Sokołów Boczek Pieczony',            '315','26.0','10.0', '0',   '1.0','0.5', '0','19.0', '2.0'),
    -- PASZTET / PÂTÉ
    ('Drosed',       'Drosed Pasztet Podlaski',            '275','21.0', '7.5', '0',   '5.0','1.0', '0','15.0', '1.6'),
    ('Sokołów',      'Sokołów Pasztet Firmowy',            '260','19.0', '7.0', '0',   '6.0','1.5', '0','14.0', '1.8'),
    -- SALAMI
    ('Sokołów',      'Sokołów Salami Dojrzewające',        '420','34.0','13.0', '0.3', '1.0','0.5', '0','26.0', '3.0'),
    ('Tarczyński',   'Tarczyński Salami Pepperoni',         '430','35.0','14.0', '0.3', '2.0','1.0', '0','25.0', '2.8'),
    -- MIELONKA / LUNCHEON MEAT
    ('Krakus',       'Krakus Mielonka Tyrolska',           '205','15.0', '5.5', '0',   '3.0','1.0', '0','14.0', '2.0'),
    ('Sokołów',      'Sokołów Mielonka Poznańska',         '210','16.0', '6.0', '0',   '2.5','0.8', '0','14.0', '2.1'),
    -- POLĘDWICA / LOIN
    ('Krakus',       'Krakus Polędwica Sopocka',           '150', '5.5', '2.0', '0',   '1.0','0.5', '0','24.0', '2.2'),
    ('Indykpol',     'Indykpol Polędwica z Indyka',        '100', '1.5', '0.5', '0',   '1.0','0.5', '0','21.0', '2.0')
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
