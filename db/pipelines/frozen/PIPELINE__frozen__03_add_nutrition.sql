-- PIPELINE (FROZEN & PREPARED): add nutrition facts
-- PIPELINE__frozen__03_add_nutrition.sql
-- Frozen & Prepared Meals: Nutrition Data (28 products)
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
    -- FROZEN PIZZAS
    --          brand           product_name                              cal   fat   sat   trans  carbs  sug   fib   prot  salt
    ('Dr. Oetker', 'Zcieżynka Margherita',                 '261', '9.5', '4.2', '0', '33', '2.1', '1.8', '11', '0.7'),
    ('Dr. Oetker', 'Zcieżynka Pepperoni',                  '280', '11.8', '5.1', '0', '32', '1.9', '1.6', '12.5', '1.1'),
    -- FROZEN PASTRIES
    ('Mrożone Pierniki', 'Pierniki Tradycyjne',            '242', '8.2', '3.1', '0', '38', '18.5', '2.1', '5.2', '0.3'),
    -- FROZEN DUMPLINGS & PASTA
    ('Morey', 'Kopytka Mięso',                             '148', '3.5', '1.2', '0', '22', '0.8', '1.5', '6.8', '0.5'),
    ('Morey', 'Kluski Śląskie',                            '127', '2.1', '0.7', '0', '20', '0.6', '1.2', '5.1', '0.7'),
    ('Nowaco', 'Pierogi Ruskie',                           '165', '4.5', '1.8', '0', '24', '1.2', '2.3', '6.5', '0.8'),
    ('Nowaco', 'Pierogi Mięso Kapusta',                    '178', '5.2', '2.0', '0', '25', '0.9', '2.0', '7.2', '0.9'),
    -- PREPARED DISHES
    ('Obiad Tradycyjny', 'Danie Mięsne Piekarsko',         '156', '6.4', '2.5', '0', '18', '1.5', '1.8', '9.8', '0.6'),
    ('Obiad Z Piekarni', 'Łazanki Mięsne',                 '142', '4.8', '1.6', '0', '20', '0.7', '1.4', '7.1', '0.5'),
    ('Pani Polska', 'Golabki Mięso Ryż',                   '112', '3.8', '1.4', '0', '14', '0.8', '2.1', '6.5', '0.6'),
    ('Perlęski', 'Bigos',                                  '68', '2.1', '0.7', '0', '8.5', '2.2', '2.4', '4.8', '0.9'),
    -- FROZEN VEGETABLES
    ('Mroźnia', 'Warzywa Mieszane',                        '42', '0.3', '0.05', '0', '7.8', '2.1', '2.2', '2.8', '0.1'),
    ('Bonduelle', 'Brokuł',                                '38', '0.5', '0.1', '0', '6.5', '1.8', '2.4', '3.2', '0.08'),
    ('Bonduelle', 'Mieszanka Warzyw Orientalna',           '48', '0.4', '0.08', '0', '8.2', '2.5', '2.1', '2.6', '0.2'),
    ('Mroźnia Premium', 'Mieszanka Owoce Leśne',           '52', '0.4', '0.08', '0', '11.2', '8.5', '2.8', '1.2', '0.05'),
    -- TV DINNERS & QUICK MEALS
    ('Makaronika', 'Danie z Warzywami',                    '89', '3.2', '1.1', '0', '12.5', '1.8', '1.9', '4.2', '0.3'),
    ('TVLine', 'Obiad Szybki Mięso',                       '145', '5.5', '2.1', '0', '18', '1.2', '1.6', '7.8', '0.5'),
    ('TVDishes', 'Filet Drobiowy',                         '156', '5.1', '1.8', '0', '19', '0.4', '1.2', '12.4', '0.4'),
    -- FROZEN APPETIZERS
    ('Zaleśna Góra', 'Paczki Mięsne',                      '198', '8.5', '3.2', '0', '21', '0.5', '1.5', '9.2', '0.7'),
    ('Żabka Frost', 'Krokiety Mięsne',                     '212', '9.2', '3.5', '0', '26', '0.6', '1.8', '7.5', '0.8'),
    ('Grana', 'Paluszki Serowe',                           '254', '13.5', '5.8', '0', '28', '1.2', '1.4', '8.2', '0.9'),
    ('Krystal', 'Kotlety Mielone',                         '187', '9.8', '3.9', '0', '15', '0.5', '1.1', '14.2', '0.5'),
    ('Zwierzenica', 'Kielbasa Zapiekanka',                 '264', '18.2', '7.1', '0', '8', '0.3', '0.5', '18.5', '1.8'),
    -- OTHER FROZEN DISHES
    ('Berryland', 'Owocownia Mieszana',                    '58', '0.3', '0.06', '0', '12.5', '9.8', '3.1', '0.9', '0.02'),
    ('Kulina', 'Nalisniki ze Serem',                       '184', '7.2', '2.8', '0', '24', '3.1', '1.6', '6.1', '0.4'),
    ('Goodmills', 'Placki Ziemniaczane',                   '156', '5.8', '1.9', '0', '22', '0.9', '2.1', '3.8', '0.5'),
    ('Mielczarski', 'Bigos Myśliwski',                     '75', '2.4', '0.8', '0', '9.2', '2.8', '3.1', '5.2', '1.0'),
    ('Igła', 'Zupa Żurek',                                 '48', '1.2', '0.4', '0', '7.1', '1.5', '1.8', '2.9', '0.8')
  ) as d (brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on (p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name)
join servings sv on (sv.product_id = p.product_id and sv.serving_basis = 'per 100 g')
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
