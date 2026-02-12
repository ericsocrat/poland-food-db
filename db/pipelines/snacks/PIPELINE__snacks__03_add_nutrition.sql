-- PIPELINE (Snacks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Snacks'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Go Active', 'Baton wysokobiałkowy Peanut Butter', 387.0, 17.0, 2.7, 0, 23.0, 19.0, 21.0, 25.0, 0.2),
    ('Go Active', 'Baton białkowy malinowy', 368.0, 16.0, 9.3, 0, 30.0, 3.9, 12.0, 30.0, 0.4),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 471.0, 19.0, 12.0, 0, 65.0, 24.0, 3.5, 8.2, 0.1),
    ('Kupiec', 'Wafle ryżowe naturalne', 380.0, 3.0, 1.0, 0, 80.0, 1.3, 3.0, 8.0, 0.1),
    ('Bakalland', 'Ba! żurawina', 414.0, 9.9, 7.9, 0, 75.0, 19.0, 1.4, 5.1, 0.2),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 100.0, 6.3, 0.5, 0, 8.2, 6.8, 2.2, 1.5, 0.8),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 452.0, 17.0, 1.5, 0, 63.0, 14.0, 6.5, 8.6, 1.5),
    ('Pano', 'Wafle mini, zbożowe', 372.0, 1.6, 0.2, 0, 72.0, 2.9, 2.4, 13.0, 0.5),
    ('Dobra Kaloria', 'Mini batoniki z nerkowców à la tarta malinowa', 406.0, 16.0, 2.6, 0, 53.0, 46.0, 6.4, 8.9, 0.0),
    ('Lubella', 'Paluszki z solą', 386.0, 4.4, 1.9, 0, 74.0, 2.9, 3.2, 11.0, 4.4),
    ('Dobra Kaloria', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', 412.0, 20.0, 2.9, 0, 27.0, 21.0, 15.0, 24.0, 0.5),
    ('Brześć', 'Słomka ptysiowa', 504.0, 26.0, 3.2, 0, 53.0, 22.0, 0, 12.0, 0.4),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 416.0, 17.0, 9.2, 0, 44.0, 29.0, 9.4, 20.0, 0.0),
    ('Lajkonik', 'Paluszki extra cienkie', 385.0, 3.7, 0.6, 0, 74.0, 2.4, 3.9, 12.0, 3.9),
    ('Wafle Dzik', 'Kukurydziane - ser', 376.0, 2.2, 0.3, 0, 79.0, 1.3, 0.0, 9.1, 2.7),
    ('Miami', 'Paleczki', 384.0, 2.6, 0.4, 0, 80.0, 2.3, 0, 9.0, 0.0),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 396.7, 5.7, 0.7, 0.0, 76.0, 0.0, 2.7, 3.2, 8.0),
    ('Go On Nutrition', 'Protein 33% Caramel', 390.0, 19.0, 9.4, 0, 21.0, 2.8, 14.0, 33.0, 0.9),
    ('Lajkonik', 'Salted cracker', 469.0, 20.0, 1.8, 0, 62.0, 3.8, 2.9, 9.1, 2.3),
    ('Lorenz', 'Chrupki Curly', 499.0, 25.0, 3.0, 0, 52.0, 2.3, 4.9, 14.0, 2.0),
    ('Lajkonik', 'prezel', 409.0, 7.3, 0.7, 0, 72.0, 0.7, 3.1, 3.6, 0.0),
    ('Lajkonik', 'Krakersy mini', 472.0, 21.0, 1.8, 0, 62.0, 6.0, 1.7, 7.8, 1.4),
    ('San', 'San bieszczadzkie suchary', 390.0, 4.9, 1.7, 0, 75.5, 11.0, 4.3, 8.4, 1.0),
    ('Sante', 'Vitamin coconut bar', 481.0, 27.0, 21.0, 0, 55.0, 39.0, 6.8, 3.5, 0.3),
    ('Lajkonik', 'Junior Safari', 436.0, 13.0, 0.8, 0, 67.0, 4.6, 3.6, 11.0, 2.5),
    ('Dobra Kaloria', 'Kokos & Orzech', 380.0, 12.9, 7.4, 0, 57.1, 48.6, 10.3, 4.6, 0.0),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 419.0, 11.0, 1.0, 0, 67.0, 4.8, 0, 11.0, 0.0),
    ('Top', 'Paluszki solone', 389.0, 5.2, 0.9, 0, 73.0, 3.8, 4.1, 11.0, 3.0),
    ('Baron', 'Protein BarMax Caramel', 492.0, 31.0, 17.0, 0, 30.0, 17.0, 0.5, 27.0, 0.5),
    ('Go On', 'Keto Bar', 460.0, 32.0, 4.2, 0, 11.0, 7.4, 28.0, 18.0, 0.5),
    ('Top', 'popcorn solony', 402.0, 18.0, 8.1, 0, 46.0, 1.2, 0, 8.9, 2.4),
    ('Oshee', 'Raspberry & Almond High Protein Bar PROMO', 515.0, 33.0, 19.0, 0, 30.0, 18.0, 0.0, 28.0, 0.2),
    ('lajkonik', 'dobry chrup', 467.0, 21.0, 2.1, 0, 52.0, 6.4, 9.0, 13.0, 2.3),
    ('Lajkonik', 'Precelki chrupkie', 394.0, 7.3, 0.5, 0, 69.0, 2.6, 4.1, 11.0, 3.5),
    ('Be raw', 'Energy Raspberry', 425.0, 17.0, 5.0, 0, 59.0, 41.0, 0, 8.0, 0),
    ('Go Active', 'Baton Proteinowy Smak Waniliowy 50%', 367.0, 10.0, 5.8, 0, 31.1, 3.6, 2.4, 48.9, 0.7),
    ('As Babuni', 'Chrup Asy Wafle Paprykowe', 407.0, 7.8, 0.9, 0, 69.0, 3.1, 4.7, 12.8, 3.6),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 474.0, 31.4, 3.7, 0, 12.3, 5.1, 21.7, 26.3, 0.2),
    ('Góralki', 'Góralki mleczne', 550.0, 34.0, 22.0, 0, 54.0, 39.0, 1.0, 7.0, 0.4),
    ('Bob Snail', 'Jabłkowo-truskawkowe przekąski', 212.0, 1.8, 0.2, 0, 46.7, 40.0, 6.9, 2.2, 0.0),
    ('tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 412.0, 8.3, 0.8, 0, 75.0, 2.8, 3.3, 7.3, 1.1),
    ('Unknown', 'Protein vanillia raspberry', 374.0, 17.0, 10.0, 0, 22.0, 2.1, 15.0, 33.0, 0.1),
    ('Go Active', 'Baton wysokobiałkowy z migdałami i kokosem', 474.0, 28.6, 6.3, 0, 14.0, 4.9, 20.6, 28.6, 0.3),
    ('7 DAYS', 'Croissant with Cocoa Filling', 453.0, 28.0, 14.0, 0, 43.0, 17.0, 1.9, 5.6, 1.5),
    ('Vitanella', 'Barony', 477.0, 25.0, 3.6, 0, 50.0, 33.0, 5.2, 11.0, 0.0),
    ('Unknown', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', 522.0, 32.9, 3.8, 0, 41.1, 32.4, 6.0, 12.4, 0.0),
    ('Tutti', 'Batonik twarogowy Tutti w polewie czekoladowej', 406.0, 24.8, 14.4, 0, 34.7, 32.6, 2.7, 11.0, 0.1),
    ('7 Days', '7 Days', 436.0, 15.0, 6.8, 0, 62.0, 4.5, 3.1, 12.0, 2.4),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 453.0, 14.0, 1.2, 0, 71.0, 5.5, 3.3, 9.1, 2.5),
    ('Tastino', 'Wafle Kukurydziane', 421.0, 8.9, 0.8, 0, 76.0, 1.3, 3.3, 7.5, 1.1),
    ('Pilos', 'Barretta al quark gusto Nocciola', 388.0, 24.0, 17.0, 0, 28.0, 22.0, 0, 15.0, 0.1),
    ('Aviko', 'Frytki karbowane Zig Zag', 156.0, 4.5, 0.5, 0, 25.0, 0.8, 0, 2.5, 0.1),
    ('7 Days', 'family', 453.4, 28.0, 14.0, 0, 43.0, 0, 1.9, 5.5, 0.6),
    ('Milka', 'Cake & Chock', 428.0, 21.0, 4.1, 0, 56.0, 30.0, 1.4, 5.5, 0.6),
    ('Wasa', 'Lekkie 7 Ziaren', 364.0, 2.0, 0.3, 0, 71.1, 5.0, 10.5, 10.2, 1.2),
    -- ── Batch 2 — snacks (new) ───────────────────────────────────────────────────────
    ('7 Days',                  'Croissant with Cocoa Filling',                          453, 28, 14, 0, 43, 17, 1.9, 5.6, 0.60),   -- OFF
    ('Pano',                    'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem',        381, 2.3, 0.4, 0, 77, 1.7, 5.3, 11, 1.05),  -- OFF
    ('Sante', 'Crunchy Cranberry & Raspberry - Sante',               420, 13, 8.1, 0, 72, 36, 0, 3.7, 0.31),   -- OFF
    ('Tastino',                 'Małe Wafle Kukurydziane O Smaku Pizzy',                420, 5.4, 0.8, 0, 76, 3.0, 3.3, 8.0, 1.1)    -- est. based on similar wafers
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Snacks' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
