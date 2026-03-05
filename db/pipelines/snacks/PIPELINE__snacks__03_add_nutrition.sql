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
    ('Top', 'Popcorn o smaku maślanym', 408.0, 19.0, 8.6, 0, 45.0, 1.2, 12.0, 8.8, 1.9),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 452.0, 17.0, 1.5, 0, 63.0, 14.0, 6.5, 8.6, 1.5),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 471.0, 19.0, 12.0, 0, 65.0, 24.0, 3.5, 8.2, 0.1),
    ('Kupiec', 'Wafle ryżowe naturalne', 381.0, 2.6, 0.6, 0, 80.0, 1.3, 3.3, 7.7, 0.0),
    ('Zdrowidło', 'Chipsy Loopea''s O Smaku Śmietanki Z Cebulką', 396.0, 9.3, 0.7, 0, 61.0, 2.0, 7.5, 13.0, 1.9),
    ('Lubella', 'Paluszki z solą', 386.0, 4.4, 1.9, 0, 74.0, 2.9, 3.2, 11.0, 4.4),
    ('Pano', 'Wafle mini, zbożowe', 372.0, 1.6, 0.2, 0, 72.0, 2.9, 2.4, 13.0, 0.5),
    ('Bakalland', 'Ba! żurawina', 414.0, 9.9, 7.9, 0, 75.0, 19.0, 1.4, 5.1, 0.2),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 100.0, 6.3, 0.5, 0, 8.2, 6.8, 2.2, 1.5, 0.8),
    ('Lajkonik', 'Paluszki o smaku waniliowym.', 406.0, 5.9, 0.6, 0, 78.0, 5.7, 2.6, 12.0, 2.3),
    ('Delicje', 'Szampariskie pomaranczowe', 359.0, 7.1, 3.3, 0, 70.0, 51.0, 1.3, 3.4, 0.2),
    ('Vitanella', 'Superballs Kokos i kakao', 397.0, 17.0, 9.6, 0, 49.0, 44.0, 9.9, 6.8, 0.0),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 416.0, 17.0, 9.2, 0, 44.0, 29.0, 9.4, 20.0, 0.0),
    ('Lajkonik', 'Dobry chrup', 467.0, 21.0, 2.1, 0, 52.0, 6.4, 9.0, 13.0, 2.3),
    ('Lajkonik', 'Salted cracker', 469.0, 20.0, 1.8, 0, 62.0, 3.8, 2.9, 9.1, 2.3),
    ('Go On Nutrition', 'Protein 33% Caramel', 391.0, 19.0, 9.3, 0, 21.0, 2.8, 14.0, 33.0, 0.9),
    ('Lajkonik', 'Krakersy mini', 472.0, 21.0, 1.8, 0, 62.0, 6.0, 1.7, 7.8, 1.4),
    ('Bakalland', 'Barre chocolat ba', 478.0, 23.0, 8.1, 0, 55.0, 11.0, 3.5, 12.0, 0.1),
    ('Go On', 'Go On Energy', 473.3, 23.0, 6.6, 0, 56.0, 35.0, 2.8, 9.2, 0.5),
    ('Lajkonik', 'Prezel', 409.0, 7.3, 0.7, 0, 72.0, 0.7, 3.1, 3.6, 0.0),
    ('Lorenz', 'Chrupki Curly', 499.0, 25.0, 3.0, 0, 52.0, 2.3, 4.9, 14.0, 2.0),
    ('Beskidzkie', 'Beskidzkie paluchy z sezamem', 451.0, 15.0, 2.0, 0, 63.0, 9.8, 4.2, 14.0, 1.2),
    ('Purella superfoods', 'Purella ciasteczko', 393.0, 14.0, 11.0, 0, 49.0, 2.7, 1.1, 24.0, 0.9),
    ('Unknown', 'Vitanella raw', 443.0, 20.0, 18.0, 0, 56.0, 50.0, 11.0, 4.3, 0.3),
    ('Meltié Chocolatier', 'Dark Chocolate 64% Cocoa', 519.0, 34.0, 23.0, 0, 38.0, 34.0, 13.0, 8.2, 0.1),
    ('Lajkonik', 'Junior Safari', 436.0, 13.0, 0.8, 0, 67.0, 4.6, 3.6, 11.0, 2.5),
    ('Lorenz', 'Monster munch', 523.0, 28.0, 2.4, 0, 65.0, 5.4, 1.6, 1.9, 2.8),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 396.7, 5.7, 0.7, 0.0, 76.0, 0.0, 2.7, 3.2, 8.0),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 419.0, 11.0, 1.0, 0, 67.0, 4.8, 0, 11.0, 0.0),
    ('TOP', 'Paluszki solone', 389.0, 5.2, 0.9, 0, 73.0, 3.8, 4.1, 11.0, 3.0),
    ('Be raw', 'Energy Raspberry', 425.0, 17.0, 5.0, 0, 59.0, 41.0, 0, 8.0, 0),
    ('Top', 'Paluszki i precelki solone', 382.0, 4.4, 0.5, 0, 69.0, 1.6, 5.0, 14.0, 3.8),
    ('San', 'San bieszczadzkie suchary', 390.0, 4.9, 1.7, 0, 75.5, 11.0, 4.3, 8.4, 1.0),
    ('Tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 411.7, 8.3, 0.8, 0, 75.0, 2.8, 3.3, 7.3, 1.1),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 474.3, 31.4, 3.7, 0, 12.3, 5.1, 21.7, 26.3, 0.2),
    ('Lajkonik', 'Krakersy mini ser i cebula', 494.0, 21.0, 1.6, 0, 67.0, 9.6, 0, 8.2, 2.0),
    ('Delicje', 'Delicje malinowe', 358.0, 7.1, 3.3, 0, 70.0, 50.0, 1.3, 3.3, 0.2),
    ('Go On', 'Vitamin Coconut & Milk Chocolate', 475.6, 27.0, 21.0, 0, 54.0, 39.0, 7.0, 3.8, 0.4),
    ('Góralki', 'Góralki mleczne', 550.0, 34.0, 22.0, 0, 54.0, 39.0, 1.0, 7.0, 0.4),
    ('Unknown', 'Popcorn solony', 405.0, 17.0, 7.4, 0, 51.0, 1.2, 8.7, 8.5, 0),
    ('7 Days', 'Croissant with Cocoa Filling', 453.0, 28.0, 14.0, 0, 43.0, 17.0, 1.9, 5.6, 1.5),
    ('Snack Day', 'Popcorn', 433.0, 23.9, 10.1, 0, 38.5, 0.6, 9.3, 11.2, 1.6),
    ('Lorenz', 'Monster Munch Crispy Potato-Snack Original', 566.0, 28.0, 2.7, 0, 59.0, 5.7, 2.4, 1.8, 2.6),
    ('Zott', 'Monte Snack', 484.0, 33.6, 21.2, 0, 39.7, 29.2, 0.0, 5.1, 0.5),
    ('Emco', 'Vitanella Bars', 540.0, 34.3, 6.3, 0, 42.9, 26.0, 6.3, 14.0, 0.1),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 453.0, 14.0, 1.2, 0, 71.0, 5.5, 3.3, 9.1, 2.5),
    ('7days', '7days', 436.0, 15.0, 6.8, 0, 62.0, 4.5, 3.1, 12.0, 2.4),
    ('Tastino', 'Wafle Kukurydziane', 421.0, 8.9, 0.8, 0, 76.0, 1.3, 3.3, 7.5, 1.1),
    ('Eti', 'Dare with MILK CHOCOLATE', 513.0, 28.0, 14.0, 0, 57.0, 40.0, 4.2, 7.3, 0.4),
    ('Belle France', 'Brioche Tressée', 354.0, 11.0, 4.5, 0, 55.0, 12.5, 2.0, 8.0, 1.0),
    ('Happy Creations', 'Cracker Mix Classic', 507.0, 27.0, 11.0, 0, 58.0, 6.0, 3.0, 7.9, 3.5)
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
