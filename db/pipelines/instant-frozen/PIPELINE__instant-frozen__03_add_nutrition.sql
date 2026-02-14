-- PIPELINE (Instant & Frozen): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Instant & Frozen'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select distinct on (p.product_id)
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 154.0, 6.9, 3.6, 0, 20.0, 1.6, 0, 2.8, 2.8),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', 156.0, 7.1, 0, 0, 20.0, 0, 0, 2.7, 0),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 104.0, 4.2, 2.6, 0, 14.0, 0.9, 1.5, 2.3, 0.8),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 242.0, 11.0, 4.7, 0, 30.0, 4.1, 0.0, 4.9, 1.8),
    ('Vifon', 'Kurczak curry instant noodle soup', 70.0, 3.3, 0.0, 0, 8.9, 3.4, 0, 1.2, 4.4),
    ('Vifon', 'Chinese Chicken flavour instant noodle soup (mild)', 72.0, 3.3, 1.2, 0, 9.1, 0.5, 0, 1.3, 0.7),
    ('Vifon', 'Barbecue Chicken', 70.0, 3.1, 1.2, 0, 9.1, 0.2, 0, 1.3, 0.7),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 300.0, 6.9, 1.3, 0, 50.0, 8.8, 0, 8.8, 2.7),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 320.0, 5.2, 0.8, 0, 63.0, 11.0, 0, 5.6, 2.9),
    ('TAN-VIET International S.A', 'Zupa z nudlami o smaku kimchi (pikantna)', 74.0, 3.0, 1.5, 0, 10.0, 0.7, 0, 1.4, 0.8),
    ('Ajinomoto', 'Oyakata Miso Ramen', 85.0, 3.8, 2.0, 0, 10.4, 1.1, 0, 2.1, 0.9),
    ('Vifon', 'Korean Hot Beef', 97.0, 3.2, 1.7, 0, 15.0, 1.4, 0, 2.1, 0.8),
    ('Tan-Viet', 'Kurczak Zloty', 72.0, 3.3, 1.2, 0, 9.1, 0.5, 0, 1.3, 0.7),
    ('Knorr', 'Nudle ser w ziołach', 86.3, 4.3, 0.8, 0, 9.4, 0.5, 0.3, 1.7, 0.9),
    ('Vifon', 'Kimchi', 85.0, 4.1, 1.4, 0, 10.3, 0.5, 0, 1.6, 0.7),
    ('Ajinomoto', 'Pork Ramen', 91.0, 4.0, 2.2, 0, 11.0, 0.5, 0, 2.4, 0.9),
    ('Goong', 'Curry Noodles', 69.0, 2.9, 0, 0, 9.7, 0.7, 0, 0.0, 0.9),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', 309.0, 5.4, 0.8, 0, 60.0, 3.5, 0, 4.6, 2.9),
    ('Vifon', 'Ramen Soy Souce', 72.0, 3.2, 1.0, 0, 9.3, 0.0, 0, 1.4, 0.7),
    ('Vifon', 'Ramen Tonkotsu', 87.0, 3.0, 1.6, 0, 13.0, 1.2, 0, 1.6, 0.9),
    ('Oyakata', 'Ramen soja', 90.0, 4.1, 2.0, 0, 11.0, 0.8, 0, 2.0, 0),
    ('Sam Smak', 'Pomidorowa', 77.0, 3.4, 1.7, 0, 9.6, 1.2, 0, 1.6, 0.7),
    ('Oyakata', 'Ramen Miso et Légumes', 86.0, 3.6, 1.8, 0, 11.0, 1.0, 0, 2.0, 0.8),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 90.0, 4.5, 2.2, 0, 10.0, 0.7, 0, 2.0, 1.0),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 242.0, 11.0, 4.7, 0, 30.0, 4.1, 2.0, 4.9, 1.8),
    ('Oyakata', 'Nouilles de blé', 84.0, 3.5, 1.7, 0, 11.0, 0.8, 0, 1.8, 0),
    ('Oyakata', 'Yakisoba soja classique', 241.0, 13.0, 5.4, 0, 26.0, 3.1, 0, 4.2, 1.4),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 236.0, 11.0, 5.1, 0, 29.0, 2.9, 1.0, 4.6, 1.4),
    ('Oyakata', 'Ramen Barbecue', 89.0, 3.5, 1.7, 0, 12.0, 0.5, 0, 1.9, 0.9),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 399.0, 16.9, 8.0, 0, 53.0, 2.9, 2.7, 7.6, 5.5),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 396.0, 16.6, 7.8, 0, 51.5, 1.5, 3.8, 8.1, 4.3),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', 80.0, 3.6, 1.7, 0, 9.8, 0.8, 0, 1.6, 0.8),
    ('Ajinomoto', 'Tomato soup', 60.0, 0.4, 0.0, 0, 11.0, 2.6, 2.0, 2.1, 0.6),
    ('Ajinomoto', 'Mushrood soup', 73.0, 1.5, 0.7, 0, 12.0, 1.1, 1.8, 2.0, 0.7),
    ('Vifon', 'Zupka hińska', 70.0, 3.1, 1.2, 0, 9.1, 0.5, 0, 1.5, 0.7),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 440.0, 17.0, 8.4, 0, 63.0, 2.0, 0, 8.8, 13.5),
    ('Nongshim', 'Super Spicy Red Shin', 426.0, 14.0, 6.7, 0, 67.0, 3.7, 0, 8.1, 3.2),
    ('Indomie', 'Noodles Chicken Flavour', 444.0, 14.3, 6.4, 0, 67.1, 2.9, 0, 9.4, 4.9),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 400.0, 18.3, 8.7, 0, 50.0, 4.0, 2.7, 7.3, 5.0),
    ('Nongshim', 'Kimchi Bowl Noodles', 440.0, 16.0, 7.7, 0, 66.0, 2.1, 0, 8.1, 5.5),
    ('NongshimSamyang', 'Ramen kimchi', 433.0, 15.8, 7.5, 0, 62.5, 2.5, 3.3, 10.0, 4.5),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 459.0, 18.8, 8.2, 0, 63.5, 5.9, 2.4, 9.4, 2.9),
    ('มาม่า', 'Mala Beef Instant Noodle', 94.0, 3.9, 1.7, 0.0, 13.5, 0.7, 0.5, 1.7, 0.8),
    ('Mama', 'Mama salted egg', 191.0, 7.8, 3.4, 0, 26.3, 2.9, 0, 3.9, 1.5),
    ('Knorr', 'Danie makaron Bolognese', 93.6, 1.9, 0.9, 0, 15.7, 2.8, 1.4, 3.4, 0.6),
    ('Nongshim', 'Shin Kimchi Noodles', 436.0, 15.0, 7.5, 0, 67.0, 4.8, 0, 8.2, 5.9),
    ('Reeva', 'Zupa o smaku sera i boczku', 410.0, 18.9, 8.5, 0, 51.5, 2.8, 2.4, 7.3, 5.4),
    ('Winiary', 'Saucy noodles smak sweet chili', 116.0, 4.7, 0, 0, 15.5, 0, 0, 2.2, 0),
    ('Knorr', 'Nudle Pieczony kurczak', 90.0, 4.0, 1.9, 0, 11.0, 0.6, 0, 1.9, 0.9),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', 476.0, 20.8, 8.0, 0, 60.6, 2.1, 2.2, 10.2, 1.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
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
