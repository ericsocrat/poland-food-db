-- PIPELINE (Instant & Frozen): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Instant & Frozen'
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Ajinomoto', 'Oyakata Miso Ramen', 85.0, 3.8, 2.0, 0, 10.4, 1.1, 0, 2.1, 0.9),
    ('Vifon', 'Kurczak curry instant noodle soup', 70.0, 3.3, 0.0, 0, 8.9, 3.4, 0, 1.2, 4.4),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 242.0, 11.0, 4.7, 0, 30.0, 4.1, 0.0, 4.9, 1.8),
    ('VIFON', 'Chinese Chicken flavour instant noodle soup (mild)', '72.0', '3.3', '1.2', '0', '9.1', '0.5', '0', '1.3', '0.7'),
    ('Vifon', 'Barbecue Chicken', 70.0, 3.1, 1.2, 0, 9.1, 0.2, 0, 1.3, 0.7),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 320.0, 5.2, 0.8, 0, 63.0, 11.0, 0, 5.6, 2.9),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 242.0, 11.0, 4.7, 0, 30.0, 4.1, 2.0, 4.9, 1.8),
    ('Tan-Viet', 'Kurczak Zloty', 72.0, 3.3, 1.2, 0, 9.1, 0.5, 0, 1.3, 0.7),
    ('Oyakata', 'Yakisoba soja classique', 241.0, 13.0, 5.4, 0, 26.0, 3.1, 0, 4.2, 1.4),
    ('Oyakata', 'Nouilles de blé', 84.0, 3.5, 1.7, 0, 11.0, 0.8, 0, 1.8, 0),
    ('Oyakata', 'Ramen Miso et Légumes', 86.0, 3.6, 1.8, 0, 11.0, 1.0, 0, 2.0, 0.8),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 236.0, 11.0, 5.1, 0, 29.0, 2.9, 1.0, 4.6, 1.4),
    ('Oyakata', 'Ramen soja', 90.0, 4.1, 2.0, 0, 11.0, 0.8, 0, 2.0, 0),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 90.0, 4.5, 2.2, 0, 10.0, 0.7, 0, 2.0, 1.0),
    ('Knorr', 'Nudle ser w ziołach', 86.3, 4.3, 0.8, 0, 9.4, 0.5, 0.3, 1.7, 0.9),
    ('Goong', 'Curry Noodles', 69.0, 2.9, 0, 0, 9.7, 0.7, 0, 0.0, 0.9),
    ('Vifon', 'Kimchi', 85.0, 4.1, 1.4, 0, 10.3, 0.5, 0, 1.6, 0.7),
    ('Ajinomoto', 'Pork Ramen', 91.0, 4.0, 2.2, 0, 11.0, 0.5, 0, 2.4, 0.9),
    ('Vifon', 'Ramen Soy Souce', 72.0, 3.2, 1.0, 0, 9.3, 0.0, 0, 1.4, 0.7),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 399.0, 16.9, 8.0, 0, 53.0, 2.9, 2.7, 7.6, 5.5),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 396.0, 16.6, 7.8, 0, 51.5, 1.5, 3.8, 8.1, 4.3),
    ('Indomie', 'Noodles Chicken Flavour', 444.0, 14.3, 6.4, 0, 67.1, 2.9, 0, 9.4, 4.9),
    ('Nongshim', 'Super Spicy Red Shin', 426.0, 14.0, 6.7, 0, 67.0, 3.7, 0, 8.1, 3.2),
    ('mama', 'Mama salted egg', 191.0, 7.8, 3.4, 0, 26.3, 2.9, 0, 3.9, 1.5),
    ('NongshimSamyang', 'Ramen kimchi', 433.0, 15.8, 7.5, 0, 62.5, 2.5, 3.3, 10.0, 4.5),
    ('MAMA', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', 459.0, 18.8, 8.2, 0, 63.5, 5.9, 2.4, 9.4, 2.9),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 440.0, 17.0, 8.4, 0, 63.0, 2.0, 0, 8.8, 13.5),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 400.0, 18.3, 8.7, 0, 50.0, 4.0, 2.7, 7.3, 5.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
