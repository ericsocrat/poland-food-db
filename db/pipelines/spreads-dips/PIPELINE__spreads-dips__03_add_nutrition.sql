-- PIPELINE (Spreads & Dips): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Spreads & Dips'
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
    ('Wawrzyniec', 'Hummus z pestkami dyni i słonecznika', 324.0, 27.0, 2.3, 0, 9.2, 1.8, 6.8, 6.5, 1.0),
    ('Sensation', 'Ajvar łagodny', 66.0, 3.7, 0.6, 0, 6.1, 4.9, 1.6, 1.2, 1.3),
    ('Nasza spiżarnia', 'Ajvar łagodny', 66.0, 3.7, 0.6, 0, 6.1, 4.9, 1.6, 1.2, 1.3),
    ('Auchan', 'Hummus z solą morską', 209.0, 14.0, 2.1, 0, 12.0, 1.3, 0, 7.0, 1.1),
    ('Mlekpol', 'Dip śmietankowy z czosnkiem i ziołami', 178.0, 16.0, 11.0, 0, 6.0, 5.5, 0, 2.6, 0.8),
    ('Niewieścin', 'Pasztetowa Podwędzana', 362.0, 35.0, 12.0, 0, 1.4, 0.0, 0, 11.0, 1.8),
    ('Go Vege', 'Hummus klasyczny', 269.0, 21.0, 2.7, 0, 7.9, 0.5, 9.8, 7.3, 0.8),
    ('Go Vege', 'Hummus paprykowy', 242.0, 17.0, 1.8, 0, 12.0, 2.1, 8.1, 6.1, 1.2),
    ('Go Vege', 'Hummus pomidorowy', 224.0, 15.0, 2.1, 0, 12.0, 2.0, 7.2, 6.7, 1.3),
    ('Go Vege', 'Hummus z ciecierzycy z burakiem', 225.0, 15.0, 1.8, 0, 13.0, 4.9, 6.1, 6.5, 1.4),
    ('I&lt;3vege', 'Hummus z papryką na ostro', 315.0, 25.0, 2.1, 0, 14.0, 2.1, 0, 6.4, 1.3),
    ('Go Vege', 'Hummus', 267.0, 20.0, 1.9, 0, 13.0, 2.8, 3.7, 7.0, 1.7),
    ('Go Vege', 'Hummus z burakiem', 192.0, 13.0, 1.4, 0, 8.8, 3.0, 6.8, 6.6, 0.8),
    ('Vital Fresh', 'Hummus pomidorowy', 267.0, 20.0, 1.9, 0, 13.0, 2.8, 3.7, 7.0, 1.7),
    ('Lisner', 'Hummus z wędzonym pstrągiem', 244.0, 17.0, 0, 0, 9.0, 1.0, 6.0, 9.0, 0),
    ('Lavica Food', 'Hummus dynia & imbir', 188.0, 13.5, 0.8, 0, 9.8, 1.7, 6.4, 4.8, 1.4),
    ('SmaczneGo!', 'Hummus klasyczny z preclami', 276.4, 13.0, 1.5, 0, 26.0, 1.9, 0, 11.0, 1.9),
    ('I-love-vege', 'Hummus z suszonymi pomidorami', 305.0, 25.0, 2.1, 0, 12.0, 2.9, 4.4, 5.8, 1.5),
    ('Well Well', 'Hummus klasyczny', 281.0, 22.8, 2.6, 0, 11.8, 0.9, 1.7, 6.9, 1.7),
    ('Dega', 'Hummus', 377.0, 30.0, 2.6, 0, 13.0, 0.9, 0, 9.9, 1.0),
    ('Lovege', 'Hummus Klasyczny', 331.0, 27.0, 2.2, 0, 13.0, 1.5, 4.7, 6.6, 1.3),
    ('Perla', 'Pomidor hummus', 234.0, 18.0, 1.8, 0, 8.5, 2.3, 7.1, 5.9, 1.4),
    ('Perla', 'Hummus Trio', 265.0, 19.8, 2.1, 0, 11.2, 3.0, 6.2, 7.3, 1.2),
    ('I love vege', 'Sante Hummus With Dried Tomatoes 180 G', 305.0, 25.0, 2.1, 0, 12.0, 2.9, 4.4, 5.8, 1.5),
    ('Helcom', 'Dip in mexicana style', 52.0, 0.0, 0.0, 0, 11.0, 8.9, 1.0, 1.4, 1.0),
    ('Zdrowidło', 'Hummus kremowy z ciecierzycy klasyczny', 297.0, 22.6, 2.2, 0, 10.3, 0.8, 6.3, 10.0, 1.2),
    ('NaturAvena', 'Ekologiczny hummus oliwkowy', 256.0, 18.7, 2.2, 0, 10.0, 1.7, 6.7, 8.5, 1.1),
    ('NaturAvena', 'Ekologiczny hummus paprykowy', 256.0, 18.7, 2.2, 0, 10.0, 1.7, 6.7, 8.5, 1.1),
    ('Sensation', 'Vegetal Hummus - paprykowy', 222.0, 16.5, 1.7, 0, 7.3, 2.0, 8.6, 2.7, 0.5),
    ('Casa Del Sur', 'Salsa dip cheese', 138.0, 11.0, 2.5, 0, 6.5, 1.5, 0, 3.2, 1.4),
    ('Perla', 'SmaczneGo! - hummus klasyczny z preclami', 281.0, 15.0, 1.5, 0, 28.0, 1.9, 0, 8.5, 1.9),
    ('Perla', 'Hummus', 285.0, 23.0, 2.2, 0, 10.0, 0.5, 5.5, 6.8, 1.0),
    ('Metro chef', 'Hummus tradycyjny', 347.0, 29.0, 2.8, 0, 14.0, 3.9, 0.1, 6.4, 0),
    ('Lavica food', 'Hummus klasyczny', 238.0, 18.5, 1.2, 0, 7.2, 0.6, 8.0, 6.8, 1.4),
    ('Lavica food', 'Hummus proteinowy klasyczny', 239.0, 16.8, 1.2, 0, 7.5, 0.7, 6.0, 10.0, 1.4),
    ('Sokołów', 'Pasztet basi', 268.0, 20.0, 7.6, 0, 9.0, 2.9, 0, 12.0, 1.4),
    ('Profi', 'Pasztet Dworski Z Dzikiem', 287.0, 24.0, 8.3, 0, 2.5, 1.0, 0, 15.0, 1.7),
    ('Sokołów', 'Pasztet dzidunia', 253.0, 19.0, 7.0, 0, 7.5, 1.0, 0, 13.0, 1.5),
    ('Gzella', 'Pasztet z borowikami', 259.0, 21.0, 8.2, 0, 7.0, 1.4, 0, 9.1, 1.2),
    ('Nestlé', 'Przyprawa Maggi', 20.0, 0.0, 0.0, 0, 2.2, 0.9, 0.0, 2.8, 22.8),
    ('Unknown', 'Hummus z ciecierzycy spicy salsa go vege', 204.0, 15.0, 1.5, 0, 8.8, 0.7, 5.9, 5.5, 3.2),
    ('Vemondo', 'Hummus z pastą sezamowa i pesto bazyliowym', 305.0, 24.7, 2.9, 0, 9.5, 0.7, 7.8, 7.3, 0.9),
    ('Chef Select', 'Guacamole Z Kawałkami Awokado', 138.0, 12.2, 2.9, 0, 4.5, 2.8, 2.3, 1.5, 0.6),
    ('Unknown', 'Ekologiczny Hummus Naturalny', 256.0, 18.7, 2.2, 0, 10.0, 1.7, 6.7, 8.5, 1.0),
    ('Vital Fresh Biedronka', 'Hummus paprykowy', 277.0, 21.0, 2.0, 0, 13.0, 2.3, 3.9, 7.0, 1.3),
    ('Lisner', 'Hummus clasic', 332.0, 27.0, 2.0, 0, 9.0, 0, 2.0, 8.0, 0),
    ('Primavika', 'Humus naturalny', 272.0, 21.0, 2.1, 0, 16.0, 2.5, 4.4, 6.1, 0),
    ('Lavica Food', 'Hummus z suszonymi pomidorami', 199.0, 14.3, 1.1, 0, 10.2, 1.5, 5.4, 4.4, 0),
    ('Sobkowiak', 'Pasztet pieczony z żurawiną', 274.0, 21.0, 8.7, 0, 4.2, 0.5, 0, 17.0, 1.5),
    ('Tzatziki', 'Taziki', 227.0, 0.5, 0, 0, 45.0, 0, 0.1, 6.6, 0),
    ('Pudliszki', 'Pudliszki', 99.0, 0.5, 0, 0, 17.0, 0, 0, 5.3, 0),
    ('Vemondo', 'Hummus klasyczny', 277.0, 22.0, 2.3, 0, 9.5, 1.9, 5.0, 7.8, 0.8),
    ('Chef select', 'Hummus classic', 272.0, 21.0, 2.2, 0, 9.5, 2.2, 6.9, 7.9, 1.4),
    ('Deluxe', 'Hummus und Guacamole', 247.0, 19.5, 2.6, 0, 7.0, 0.7, 8.9, 6.5, 0.9),
    ('Chef Select', 'Hummus bruschetta', 245.0, 19.8, 1.9, 0, 6.9, 1.6, 7.0, 6.3, 0.0),
    ('K-take it veggie', 'K-take it veggie Hummus Tomato', 236.0, 17.0, 1.8, 0, 10.0, 4.0, 6.5, 7.4, 1.4),
    ('K-take it veggie', 'K-take it veggie Hummus Red Pepper 200g', 226.0, 17.0, 1.7, 0, 7.3, 2.0, 8.6, 6.7, 1.2),
    ('Taverna-Bio', 'Classic Hummus', 285.0, 24.4, 2.8, 0, 7.9, 0.0, 0, 7.0, 0.5),
    ('Vital', 'Guacamole', 154.0, 14.4, 3.2, 0, 1.4, 1.2, 5.7, 1.9, 1.5),
    ('K-take it veggie', 'K-take it veggie Hummus Classic', 256.0, 20.0, 2.0, 0, 7.5, 0.7, 8.2, 7.4, 1.2),
    ('Chef Select', 'Hummus z sosem pomidorowym', 251.0, 18.9, 2.0, 0, 10.6, 2.6, 0, 6.8, 0.9),
    ('Vitasia', 'Hummus sweet chili', 250.0, 18.0, 2.1, 0, 13.2, 8.2, 5.2, 6.3, 1.3),
    ('Athos', 'Tzatziki', 109.0, 7.6, 0.8, 0, 5.3, 3.3, 0, 4.8, 0.2),
    ('Chef select', 'Bio Hummus paprykowy', 250.0, 18.0, 0, 0, 12.0, 4.0, 4.3, 7.9, 1.1),
    ('Chef Select', 'Guacamole mild', 183.0, 15.3, 3.1, 0, 8.6, 0.6, 2.2, 1.6, 0.9),
    ('Chef select', 'Bio Hummus pomidorowy', 275.0, 20.0, 1.9, 0, 13.0, 2.8, 7.3, 7.0, 1.7),
    ('Vemondo', 'Hummus Paprykowy', 216.0, 16.0, 1.6, 0, 8.8, 2.9, 7.6, 5.4, 1.1),
    ('Vital Fresh', 'Guacamole', 146.0, 13.4, 3.1, 0, 2.1, 1.2, 5.7, 1.5, 0.8),
    ('Lidl', 'Hummus mit falafel & mango mousse', 220.0, 14.8, 1.5, 0, 9.9, 1.9, 6.8, 8.4, 1.3),
    ('Doyal', 'Humus', 164.0, 10.0, 0.0, 0, 6.7, 0.5, 0, 6.7, 1.3),
    ('Nature''s Promise', 'Hummus klasik', 247.0, 19.0, 1.9, 0, 9.0, 0.4, 5.8, 7.0, 0.8),
    ('La campagna', 'Hummus', 250.0, 19.0, 2.0, 0, 7.5, 0.7, 0, 7.4, 1.2),
    ('Meyers', 'Hummus', 286.0, 24.0, 1.7, 0, 9.4, 0.7, 0, 7.3, 1.0),
    ('Taverna', 'Hummus coriander & lemon', 359.0, 28.6, 3.5, 0, 16.8, 0.0, 0, 8.3, 1.1),
    ('Pikok', 'Pasztet z indyka', 309.0, 29.0, 3.5, 0, 2.0, 0.5, 2.0, 10.0, 1.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Spreads & Dips' and p.is_deprecated is not true
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
