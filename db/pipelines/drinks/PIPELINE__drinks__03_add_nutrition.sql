-- PIPELINE (Drinks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Drinks'
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
    ('Tymbark', 'Sok 100% Pomarańcza', 44.0, 0.0, 0, 0, 10.0, 10.0, 0, 0.6, 0.0),
    ('Mlekovita', 'Kefir', 20.4, 0.8, 0.5, 0, 1.9, 1.9, 0.0, 1.4, 0.0),
    ('Krasnystaw', 'kefir', 50.0, 2.0, 1.2, 0, 4.7, 4.2, 0, 3.4, 0.1),
    ('Żywiec Zdrój', 'Niegazowany', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 80.0, 1.5, 1.5, 0, 10.0, 10.0, 0, 6.5, 0.1),
    ('Krasnystaw', 'Kefir', 50.0, 2.0, 1.2, 0, 4.7, 4.2, 0, 3.4, 0.1),
    ('oshee', 'Oshee Multifruit', 17.7, 0.0, 0, 0, 4.0, 4.0, 0, 0.0, 0.1),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 41.0, 0.0, 0.0, 0, 8.8, 8.7, 0, 0.7, 0.0),
    ('Coca-Cola', 'Napój gazowany o smaku cola', 0.2, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Coca-Cola', 'Coca-Cola Original Taste', 44.0, 0.0, 0.0, 0, 10.9, 10.9, 0.0, 0.0, 0.0),
    ('Danone', 'Geröstete Mandel Ohne Zucker', 15.0, 1.1, 0.1, 0, 0.0, 0.0, 0.3, 0.5, 0.1),
    ('Millbona', 'HIGH PROTEIN Caramel Pudding', 0.2, 0.0, 0, 0, 0.0, 0, 0, 0.0, 0.0),
    ('Coca-Cola', 'Coca Cola Original taste', 45.0, 0.0, 0.0, 0, 11.2, 11.2, 0.0, 0.0, 0.0),
    ('Vemondo', 'Almond Drink', 14.0, 1.2, 0.1, 0, 0.0, 0.0, 0, 0.5, 0.1),
    ('Oatly', 'Haferdrink Barista', 61.0, 3.0, 0.3, 0, 7.1, 3.4, 0.8, 1.1, 0.1),
    ('alpro', 'Coco Délicieuse et Tropicale', 20.0, 0.8, 0.8, 0, 2.7, 1.9, 0.1, 0.1, 0.1),
    ('Milbona', 'High Protein Drink Cacao', 64.0, 0.3, 0.2, 0, 5.0, 4.9, 0.0, 10.1, 0.1),
    ('Vemondo', 'Bio Hafer', 37.0, 1.2, 0.2, 0, 5.6, 3.3, 1.0, 0.4, 0.1),
    ('Milbona', 'High Protein Drink Gusto Vaniglia', 65.0, 0.2, 0.2, 0, 5.2, 5.2, 0.0, 10.6, 0.3),
    ('Kikkoman', 'Kikkoman Sojasauce', 77.0, 0.0, 0.0, 0, 3.2, 0.6, 0.0, 10.0, 16.9),
    ('Kikkoman', 'Teriyakisauce', 99.0, 0.0, 0.0, 0, 12.0, 11.0, 0, 6.7, 10.2),
    ('Carrefour BIO', 'Avoine', 43.0, 1.2, 0.2, 0, 7.2, 5.0, 0.8, 0.5, 0.1),
    ('Vemondo', 'Boisson au soja', 32.0, 1.7, 0.2, 0, 1.0, 0.4, 0.2, 3.0, 0.1),
    ('Club Mate', 'Club-Mate Original', 20.0, 0.0, 0.0, 0, 5.0, 5.0, 0.0, 0.0, 0.0),
    ('Coca-Cola', 'coca cola 1,75', 42.0, 0.0, 0.0, 0, 10.6, 10.6, 0, 0.0, 0.0),
    ('Carrefour BIO', 'Amande Sans sucres', 26.0, 1.7, 0.2, 0, 1.7, 0.5, 0.5, 0.7, 0.1),
    ('Carrefour BIO', 'SOJA Sans sucres ajoutés', 41.0, 2.1, 0.4, 0, 1.4, 0.7, 0.6, 3.8, 0.0),
    ('Naturis', 'Apple Juice', 45.3, 0.1, 0.1, 0, 10.4, 9.9, 0.3, 0.1, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
