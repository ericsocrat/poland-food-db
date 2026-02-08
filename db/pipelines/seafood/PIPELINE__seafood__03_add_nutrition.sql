-- PIPELINE (SEAFOOD & FISH): add nutrition facts
-- PIPELINE__seafood__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-08
--
-- NOTE: Trans fat values are 0 for all seafood products (naturally occurring in fish is negligible).

-- 1) Remove existing nutrition for PL Seafood & Fish so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Seafood & Fish'
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
    -- brand,               product_name,                         kcal,  fat,  sat, trans, carbs, sugar, fiber, prot, salt
    -- ── CANNED TUNA ────────────────────────────────────────────
    ('Graal',              'Tuńczyk w Oleju Roślinnym',        '198', '11', '1.6', '0', '0',   '0',   '0',   '24', '0.8'),
    ('Graal',              'Tuńczyk w Sosie Własnym',          '116', '1.5', '0.4', '0', '0',   '0',   '0',   '26', '0.7'),
    ('King Oscar',         'Tuńczyk Kawałki w Oleju',          '210', '13', '2.0', '0', '0',   '0',   '0',   '25', '0.9'),
    ('Seko',               'Tuńczyk Naturalny',                '108', '0.8', '0.3', '0', '0',   '0',   '0',   '25', '0.6'),
    -- ── CANNED MACKEREL ────────────────────────────────────────
    ('Graal',              'Makrela w Oleju',                  '291', '26', '5.1', '0', '0',   '0',   '0',   '14', '0.8'),
    ('Graal',              'Makrela w Sosie Pomidorowym',      '158', '10', '2.2', '0', '2.5', '2.0', '0.4', '15', '1.0'),
    ('Seko',               'Makrela Filety w Oleju',           '287', '25', '4.9', '0', '0',   '0',   '0',   '15', '0.9'),
    -- ── CANNED SARDINES ────────────────────────────────────────
    ('Graal',              'Sardynki w Oleju Roślinnym',       '235', '18', '2.9', '0', '0',   '0',   '0',   '20', '1.2'),
    ('Graal',              'Sardynki w Sosie Pomidorowym',     '145', '8',  '1.8', '0', '2.0', '1.5', '0.3', '16', '1.1'),
    ('Seko',               'Sardynki w Oleju',                 '228', '17', '2.7', '0', '0',   '0',   '0',   '19', '1.1'),
    -- ── CANNED SALMON ──────────────────────────────────────────
    ('Graal',              'Łosoś Różowy w Sosie Własnym',     '138', '6',  '1.3', '0', '0',   '0',   '0',   '21', '0.7'),
    ('King Oscar',         'Łosoś Czerwony',                   '162', '8',  '1.8', '0', '0',   '0',   '0',   '23', '0.8'),
    -- ── SMOKED FISH ────────────────────────────────────────────
    ('Łosoś Morski',       'Łosoś Wędzony Plastry',            '142', '5',  '1.1', '0', '1.5', '0.8', '0',   '23', '3.2'),
    ('Seko',               'Makrela Wędzona',                  '262', '19', '4.3', '0', '0',   '0',   '0',   '24', '2.8'),
    ('Graal',              'Szprot Wędzony',                   '248', '18', '4.0', '0', '0',   '0',   '0',   '21', '2.5'),
    ('Graal',              'Pstrąg Wędzony',                   '148', '6',  '1.4', '0', '0',   '0',   '0',   '24', '2.6'),
    -- ── FISH SPREADS (PÂTÉ) ────────────────────────────────────
    ('Graal',              'Pasta Rybna Łosoś',                '185', '14', '2.5', '0', '6',   '1.5', '0.5', '10', '1.8'),
    ('Graal',              'Pasta Rybna Tuńczyk',              '172', '12', '2.1', '0', '7',   '2.0', '0.4', '11', '1.6'),
    ('Seko',               'Pasta z Makreli',                  '195', '15', '3.2', '0', '6.5', '1.8', '0.3', '9',  '1.9'),
    -- ── FROZEN FISH ────────────────────────────────────────────
    ('Nautica (Lidl)',     'Filety z Dorsza',                  '82',  '0.7', '0.1', '0', '0',   '0',   '0',   '18', '0.3'),
    ('Frosta',             'Filety Mintaja',                   '79',  '0.8', '0.2', '0', '0',   '0',   '0',   '17', '0.4'),
    ('Nautica (Lidl)',     'Filety z Łososia',                 '206', '13', '2.6', '0', '0',   '0',   '0',   '22', '0.5'),
    ('Seko',               'Filety Pangi',                     '92',  '2.0', '0.7', '0', '0',   '0',   '0',   '18', '0.3'),
    -- ── FISH FINGERS & BREADED FISH ────────────────────────────
    ('Frosta',             'Paluszki Rybne',                   '189', '9',  '0.8', '0', '15',  '1.2', '1.5', '12', '0.7'),
    ('Nautica (Lidl)',     'Paluszki Rybne Panierowane',       '195', '10', '0.9', '0', '16',  '1.5', '1.3', '11', '0.8'),
    -- ── SEAFOOD READY MEALS ────────────────────────────────────
    ('Graal',              'Sałatka z Tuńczykiem',             '156', '11', '1.6', '0', '6',   '3.2', '1.2', '9',  '1.4'),
    ('Seko',               'Sałatka Śledziowa',                '168', '12', '2.0', '0', '8',   '4.5', '0.8', '7',  '1.5')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
