-- PIPELINE (Spices & Seasonings): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Spices & Seasonings'
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
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', 211.0, 0.4, 0.1, 0, 42.0, 17.0, 0, 9.2, 43.8),
    ('Donatello', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 160.0, 12.0, 7.0, 0, 11.0, 10.0, 2.4, 3.0, 0.5),
    ('Prymat', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 237.0, 5.9, 0.8, 0, 29.0, 7.2, 0, 8.9, 39.0),
    ('Kamis', 'Przyprawa kuchni włoskiej', 213.0, 1.4, 0.3, 0, 32.0, 30.0, 0, 10.0, 31.5),
    ('Donatello', 'Antipasti nadziewane serkiem wiśniowe papryczki', 195.0, 15.0, 8.3, 0, 11.0, 8.9, 2.2, 3.0, 0.7),
    ('Kamis', 'Przyprawa do dań z ziemniaków', 185.0, 3.7, 0.6, 0, 23.0, 4.1, 0, 7.4, 41.2),
    ('Planteon', 'Pieprz ziołowy', 413.0, 7.9, 0.8, 0, 65.3, 3.1, 14.2, 12.9, 0.3),
    ('Prymat', 'Przyprawa do kurczaka złocista skórka', 171.0, 5.1, 0.7, 0, 19.0, 6.3, 0, 6.3, 49.6),
    ('Kucharek', 'Przyprawa do mięs', 193.0, 4.2, 0.6, 0, 28.0, 11.0, 0, 5.6, 43.7),
    ('Prymat', 'Przyprawa do mięs', 218.0, 3.7, 0.6, 0, 37.0, 12.0, 0, 5.6, 37.4),
    ('Promienie Słońca', 'Papryka słodka wędzona', 282.0, 12.9, 2.1, 0, 54.0, 10.3, 0, 14.1, 0.2),
    ('Perla', 'Pełna dobra papryczkę czerwone i pepperoni', 317.0, 33.0, 7.4, 0, 2.0, 1.1, 0, 2.2, 1.8),
    ('Kotanyi', 'Anyż cały', 386.0, 15.9, 0, 0, 35.4, 0, 0, 17.6, 0),
    ('Herbapol', 'Mięta', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Knorr', 'Przyprawa do mięs', 241.0, 2.7, 0.8, 0, 30.0, 7.8, 4.3, 18.0, 35.6),
    ('Kamis', 'Przyprawa do gyrosa', 232.0, 8.2, 0.7, 0, 23.0, 8.3, 0, 9.1, 35.4),
    ('Prymat', 'Przyprawa do sałatek sosów i dipów', 202.0, 1.7, 0.4, 0, 33.0, 24.0, 0, 5.4, 39.4),
    ('Culineo', 'Cebulka zapiekana', 590.0, 43.0, 21.0, 0, 42.0, 17.0, 6.0, 6.0, 1.0),
    ('Sainsbury''s', 'Black Peppercorns', 18.0, 0.0, 0.0, 0, 2.2, 0.9, 0, 2.4, 22.5),
    ('Casa de mexico', 'Papryka zielona krojona', 25.0, 0.9, 0.1, 0, 2.1, 2.1, 0, 0.9, 4.2),
    ('Kamis', 'Curry', 276.0, 8.5, 1.5, 0, 28.0, 1.8, 0, 12.0, 19.0),
    ('Prymat', 'Przyprawa do kurczaka', 199.0, 5.4, 0.7, 0, 26.0, 9.7, 0, 6.4, 49.7),
    ('Kamis', 'Seasoning for fish', 200.0, 3.3, 0.0, 0.0, 33.3, 33.3, 0.0, 6.7, 42.0),
    ('Kamis', 'Cynamon', 111.0, 0.1, 0, 0, 24.6, 0, 0, 3.0, 0),
    ('Prymat', 'Grill klasyczny', 226.0, 6.0, 0.9, 0, 30.0, 14.0, 0, 7.5, 37.6),
    ('Prymat', 'Kebab gyros', 240.0, 7.1, 1.0, 0, 23.0, 12.0, 0.0, 8.4, 36.9),
    ('Casa del sur', 'Pepperoni pepper imp', 27.0, 0.0, 0.0, 0, 5.4, 3.0, 0, 1.0, 4.7),
    ('Prymat', 'Przyprawa Kebab Gyros klasyczna', 219.0, 7.1, 1.0, 0, 23.0, 12.0, 0, 8.4, 37.0),
    ('Kamis', 'Przyprawa do spaghetti bolognese', 300.0, 1.6, 0.3, 0, 47.0, 47.0, 0, 15.0, 8.2),
    ('Planteon', 'Papryka ostra mielona 60 ASTA', 282.0, 13.0, 0, 0, 0, 0, 35.0, 14.0, 0.2),
    ('Prymat', 'Przyprawa do ryb', 219.0, 5.0, 0.4, 0, 28.0, 15.0, 0, 8.6, 38.9),
    ('Lewiatan', 'Chipsy paprykowe', 531.0, 33.0, 0, 0, 50.0, 0, 0, 6.3, 0),
    ('El Toro Rojo', 'Kapary w zalewie', 26.0, 0.5, 0.1, 0, 2.4, 0.5, 3.0, 2.0, 0),
    ('Lidl', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 143.0, 10.9, 6.0, 0, 7.8, 6.6, 2.2, 2.4, 0.8),
    ('Dr. Oetker', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 289.0, 0.1, 0, 0, 71.0, 0, 0, 0.1, 0),
    ('El Tequito', 'Jalapeños', 12.0, 0.1, 0.1, 0, 1.6, 0.3, 0.9, 0.6, 2.0),
    ('Lidl', 'Ground chili peppers in olive oil', 332.0, 35.0, 6.0, 0, 2.5, 0.5, 3.4, 1.0, 2.8),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 216.0, 2.6, 0.4, 0, 34.2, 5.9, 0, 8.3, 39.9),
    ('Eridanous', 'Gyros', 253.0, 6.2, 0.9, 0, 24.7, 7.0, 0, 10.4, 20.2),
    ('Knorr', 'Czosnek', 330.0, 14.0, 9.0, 0, 39.0, 3.5, 0.6, 14.0, 24.0),
    ('Vilgain', 'Koření na pizzu', 116.0, 4.7, 1.3, 0, 23.0, 16.0, 23.0, 15.0, 17.0),
    ('All Seasons', 'Papryka konserwowa', 37.0, 0.5, 0.1, 0, 6.6, 6.6, 1.7, 0.9, 0.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Spices & Seasonings' and p.is_deprecated is not true
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
