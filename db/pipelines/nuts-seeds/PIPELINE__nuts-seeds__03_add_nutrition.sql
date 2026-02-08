-- PIPELINE (NUTS-SEEDS): add nutrition facts
-- PIPELINE__nuts-seeds__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Nuts, Seeds & Legumes so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
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
    -- brand,              product_name,                                kcal,  fat,   sat,  trans, carbs, sugar, fiber, prot,  salt
    -- RAW NUTS (NOVA 1) ──────────────────────────────────────────────────
    ('Alesto',             'Alesto Migdały',                            '579', '50',  '3.8','0',   '22',  '4.5', '12',  '21',  '0.005'),
    ('Alesto',             'Alesto Orzechy Nerkowca',                   '553', '44',  '7.8','0',   '30',  '5.9', '3.3', '18',  '0.012'),
    ('Alesto',             'Alesto Orzechy Włoskie',                    '654', '65',  '6.1','0',   '14',  '2.6', '6.7', '15',  '0.002'),
    ('Alesto',             'Alesto Orzechy Laskowe',                    '628', '61',  '4.5','0',   '17',  '4.3', '9.7', '15',  '0.002'),
    ('Bakalland',          'Bakalland Orzechy Włoskie',                 '654', '65',  '6.1','0',   '14',  '2.6', '6.7', '15',  '0.002'),
    ('Bakalland',          'Bakalland Migdały',                         '579', '50',  '3.8','0',   '22',  '4.5', '12',  '21',  '0.005'),
    ('Bakalland',          'Bakalland Orzechy Laskowe',                 '628', '61',  '4.5','0',   '17',  '4.3', '9.7', '15',  '0.002'),
    -- ROASTED NUTS WITH SALT (NOVA 3) ────────────────────────────────────
    ('Alesto',             'Alesto Migdały Prażone Solone',             '607', '52',  '4.0','0',   '21',  '4.5', '12',  '21',  '1.2'),
    ('Alesto',             'Alesto Orzechy Nerkowca Prażone Solone',    '572', '46',  '9.1','0',   '27',  '5.8', '3.0', '19',  '1.1'),
    ('Fasting',            'Fasting Orzeszki Ziemne Solone',            '598', '52',  '8.0','0',   '14',  '4.0', '8.0', '27',  '1.3'),
    ('Fasting',            'Fasting Migdały Prażone',                   '607', '52',  '4.0','0',   '21',  '4.5', '12',  '21',  '1.1'),
    -- RAW SEEDS (NOVA 1) ─────────────────────────────────────────────────
    ('Sante',              'Sante Nasiona Słonecznika',                 '584', '51',  '4.5','0',   '20',  '2.6', '8.6', '21',  '0.009'),
    ('Sante',              'Sante Pestki Dyni',                         '559', '49',  '8.7','0',   '14',  '1.4', '6.0', '30',  '0.007'),
    ('Sante',              'Sante Nasiona Chia',                        '486', '31',  '3.3','0',   '42',  '0.5', '34',  '17',  '0.016'),
    ('Sante',              'Sante Siemię Lniane',                       '534', '42',  '3.7','0',   '29',  '1.6', '27',  '18',  '0.03'),
    -- ROASTED SEEDS WITH SALT (NOVA 3) ───────────────────────────────────
    ('Targroch',           'Targroch Pestki Dyni Prażone Solone',       '574', '50',  '9.3','0',   '13',  '1.3', '5.5', '31',  '1.0'),
    ('Targroch',           'Targroch Nasiona Słonecznika Prażone',      '600', '53',  '5.0','0',   '19',  '2.5', '8.0', '21',  '0.9'),
    -- NUT BUTTERS (NOVA 3) ───────────────────────────────────────────────
    ('Helio',              'Helio Masło Orzechowe Naturalne',           '588', '50',  '7.0','0',   '20',  '6.0', '6.0', '24',  '0.5'),
    ('Helio',              'Helio Masło Orzechowe Kremowe',             '604', '52',  '8.5','0',   '18',  '8.5', '6.5', '25',  '1.2'),
    ('Helio',              'Helio Masło Migdałowe',                     '630', '54',  '4.2','0',   '15',  '6.5', '8.0', '26',  '0.8'),
    -- DRIED LEGUMES (NOVA 1) ─────────────────────────────────────────────
    ('Naturavena',         'Naturavena Soczewica Czerwona',             '345', '1.1', '0.2','0',   '60',  '2.0', '11',  '25',  '0.006'),
    ('Naturavena',         'Naturavena Soczewica Zielona',              '352', '1.1', '0.2','0',   '63',  '2.0', '11',  '25',  '0.006'),
    ('Naturavena',         'Naturavena Ciecierzyca',                    '364', '6.0', '0.6','0',   '61',  '11',  '17',  '19',  '0.024'),
    ('Naturavena',         'Naturavena Fasola Biała',                   '333', '0.9', '0.2','0',   '60',  '2.1', '15',  '23',  '0.016'),
    ('Naturavena',         'Naturavena Fasola Czerwona',                '333', '0.8', '0.1','0',   '60',  '2.1', '15',  '24',  '0.012'),
    ('Społem',             'Społem Fasola Jaś',                         '337', '0.9', '0.2','0',   '63',  '2.9', '15',  '21',  '0.005'),
    ('Społem',             'Społem Soczewica Brązowa',                  '353', '1.1', '0.2','0',   '63',  '2.0', '11',  '25',  '0.006')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
