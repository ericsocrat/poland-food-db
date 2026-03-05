-- PIPELINE (Instant & Frozen): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Instant & Frozen'
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
    ('Davert', 'Noodle Cup - Thailändisch', 101.0, 0.5, 0.1, 0, 20.0, 2.6, 1.8, 3.1, 0.9),
    ('Kania', 'Instant Nudeln Gemüse Geschmack', 86.6, 1.4, 1.1, 0, 15.9, 0.2, 0.6, 2.3, 0.9),
    ('Asia Green Garden', 'Instantnudeln Hühnergeschmack 5er-Pack', 59.0, 0.2, 0.0, 0, 12.3, 0.1, 0, 1.7, 0.4),
    ('Asia Green Garden', 'Udon-Nudeln mit Soja-Ingwer-Soße', 145.0, 1.3, 0.2, 0, 29.0, 0.5, 0, 3.2, 1.0),
    ('Asia Green Garden', 'Bratnudeln - Thailändische Art', 99.0, 2.2, 0.3, 0, 16.2, 2.0, 1.0, 3.0, 0.8),
    ('Davert', 'Noodle Brokkoli Käse Sauce', 112.0, 1.9, 1.1, 0, 19.0, 2.2, 1.5, 4.2, 1.1),
    ('Asia Green Garden', 'Instant Nudeln Gemüsegeschmack', 483.0, 26.0, 13.0, 0, 49.0, 2.4, 0, 11.0, 6.3),
    ('Asia Green Garden', 'Instant-Reisnudeln mit Hühnerfleischgeschmack', 70.0, 0.7, 0.3, 0, 14.0, 0.8, 0, 1.2, 1.0),
    ('Asia Green Garden', 'Pho Chat Instant-Reisnudeln mit Gemüsegeschmack', 73.0, 1.0, 0.4, 0, 15.0, 1.2, 0, 1.3, 1.3),
    ('Asia Green Garden', 'Udon-Nudel-Bowl mit Sauce nach Kimchi Art Gewürzt', 163.0, 2.0, 0.4, 0, 29.8, 6.0, 3.3, 4.9, 1.4),
    ('Aldi', 'Green Curry Noodles / Grüne Curry Nudeln', 145.0, 3.7, 1.7, 0, 23.0, 3.1, 0, 4.0, 0.9),
    ('Asia Green Garden', 'Instant-Nudeln Beef', 468.0, 23.0, 11.0, 0, 54.0, 3.0, 0, 10.0, 5.0),
    ('Asia Green Garden', 'Udon Noodle Bowl', 148.0, 1.2, 0.3, 0, 28.8, 9.2, 2.2, 4.3, 0.0),
    ('Asia Green Garden', 'Bratnudeln - Entengeschmack', 100.0, 2.1, 0.2, 0, 16.8, 1.6, 1.0, 2.9, 0.8),
    ('Asia Green Garden', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 94.0, 3.7, 1.9, 0, 12.2, 0.3, 1.0, 2.4, 0.7),
    ('Asia Green Garden', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 75.0, 1.2, 0.5, 0, 14.0, 0.9, 0, 1.4, 1.0),
    ('Asia Green Garden', 'Bratnudeln - Chili', 98.0, 2.2, 0.2, 0, 16.1, 1.7, 1.2, 2.8, 0.7),
    ('Unknown', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 132.0, 5.2, 2.0, 0, 18.6, 1.3, 0.6, 2.3, 0.8),
    ('Bamboo Garden', 'Mie Nudeln', 361.0, 1.2, 0.4, 0, 74.8, 2.1, 0, 11.1, 0.0),
    ('Nissin', 'Thai Roasted Chicken', 89.0, 3.9, 1.9, 0, 11.0, 0.5, 0, 2.1, 1.0),
    ('Knorr', 'Hühnersuppe', 31.0, 0.1, 0.0, 0, 5.9, 0.3, 0.2, 1.2, 0.8),
    ('Davert', 'Noodle Cup No. 11 Linsen Bolognese', 96.7, 0.6, 0.1, 0, 17.7, 2.2, 2.7, 4.0, 0.6),
    ('Kania', 'Instant Nudeln Rind', 84.0, 1.4, 1.1, 0, 15.8, 0.5, 0.6, 2.4, 0.0),
    ('Davert', 'Noodle Cup No. 7', 104.0, 0.6, 0.2, 0, 20.0, 4.3, 2.6, 3.7, 11.0),
    ('Lien Ying Asian-Spirit', 'Eier-Mie-Nudeln', 358.0, 3.0, 0.7, 0, 69.0, 3.5, 0, 13.0, 1.0),
    ('Aldi', 'Asia-Instant-Noodles-Cup - Curry', 396.0, 15.0, 7.6, 0, 50.0, 3.6, 0, 14.0, 2.3),
    ('Reeva', 'Instant Nudeln gebratenes Hähnchen', 67.0, 2.8, 0, 0, 8.9, 0, 0, 1.3, 2.5),
    ('Buldak', 'Buldak HOT Chicken Flavour Ramen', 338.4, 15.0, 6.0, 0, 66.0, 5.0, 2.0, 7.0, 3.0),
    ('Yum Yum', 'Instant Nudeln, Japanese Chicken Flavor', 69.0, 2.5, 1.2, 0, 10.0, 0.3, 0.0, 1.4, 0.9),
    ('Nongshim', 'Soon Veggie Ramyun Noodle', 430.0, 14.0, 6.8, 0, 67.0, 3.0, 0.0, 9.0, 4.1),
    ('Maggi', 'Saucy Noodles Teriyaki', 458.0, 18.7, 1.8, 0, 61.4, 11.6, 3.3, 9.3, 3.2),
    ('Knorr', 'Asia Noodels Beef Taste', 91.1, 4.1, 0.5, 0, 11.4, 0.7, 0.4, 1.6, 0.7),
    ('Maggi', 'Noodle Cup - Chicken Taste', 103.0, 4.9, 0.5, 0, 11.9, 0.9, 1.0, 2.2, 1.1),
    ('Knorr', 'Asia Noodles Chicken Taste', 90.8, 4.1, 0.5, 0, 11.4, 0.7, 0.4, 1.6, 0.7),
    ('Buldak', 'Buldak 2x Spicy', 375.7, 12.1, 5.7, 0, 60.7, 5.0, 2.9, 9.3, 2.4),
    ('Maggi', 'Saucy Noodles Sesame Chicken Taste', 463.0, 19.1, 1.5, 0, 62.3, 7.6, 2.4, 9.1, 0.0),
    ('Nissin', 'Soba Cup Noodles', 208.0, 8.2, 3.9, 0, 27.3, 5.8, 0, 5.1, 1.4),
    ('Nongshim', 'Nouilles Chapaghetti Nongshim', 430.0, 14.0, 5.7, 0, 68.0, 4.3, 0, 8.0, 2.0),
    ('Nissin', 'Cup Noodles Big Soba Wok Style', 204.0, 7.8, 3.6, 0, 26.7, 5.3, 0, 5.3, 1.2),
    ('Maggi', 'Gebratene Nudeln Ente', 200.0, 4.2, 0.5, 0, 33.1, 2.3, 2.3, 5.1, 1.6),
    ('Thai Chef', 'Thaisuppe, Curry Huhn', 431.0, 21.0, 10.0, 0, 52.0, 2.6, 0, 8.2, 8.2),
    ('Knorr', 'Spaghetteria Spinaci', 100.0, 2.4, 1.1, 0, 16.0, 1.3, 0.6, 3.2, 0.6),
    ('Maggi', 'Magic Asia - Gebratene Nudeln Thai-Curry', 192.0, 4.7, 0.9, 0, 31.2, 3.3, 2.3, 5.2, 1.6),
    ('Indomie', 'Noodles', 350.0, 14.0, 8.5, 0, 48.0, 2.9, 0, 7.1, 4.3),
    ('Maggi', 'Asia Noodle Cup Duck', 103.8, 5.0, 0.4, 0, 12.1, 0.8, 0.7, 2.2, 2.7),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 76.0, 3.3, 1.6, 0, 10.1, 0.5, 0.0, 1.3, 0.7),
    ('Ajinomoto', 'Pork Ramen', 91.0, 4.0, 2.2, 0, 11.0, 0.5, 0, 2.4, 0.9),
    ('Maggi', 'Saucy Noodles Sweet Chili', 117.0, 4.8, 2.7, 0, 15.8, 2.9, 0.7, 2.2, 0.6),
    ('Nongshim', 'Shin Cup Gourmet Spicy Noodle Soup', 436.0, 14.0, 6.7, 0, 70.0, 4.8, 0, 7.6, 4.8),
    ('Nissin', 'Soba Yakitori Chicken', 221.0, 10.8, 4.6, 0, 24.7, 4.3, 0.0, 4.9, 1.9),
    ('Knorr', 'Asia Noodles Currygeschmack', 96.0, 4.4, 2.1, 0, 12.0, 0.7, 0.5, 1.7, 0.8)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Instant & Frozen' and p.is_deprecated is not true
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
