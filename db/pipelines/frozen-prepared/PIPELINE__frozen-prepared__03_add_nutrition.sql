-- PIPELINE (Frozen & Prepared): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Frozen & Prepared'
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
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 265.0, 9.5, 4.9, 0, 33.5, 3.7, 0, 10.2, 1.3),
    ('Carrefour BIO', 'Ratatouille', 68.0, 4.3, 0.6, 0, 5.3, 4.3, 2.0, 1.1, 0.6),
    ('Vitasia', 'soba noodles', 346.0, 1.4, 0.4, 0, 69.6, 2.1, 3.3, 12.0, 1.5),
    ('Carrefour BIO', 'Riz Sans sucres ajoutés**', 57.0, 1.3, 0.1, 0, 11.0, 4.7, 0.0, 0.5, 0.1),
    ('Gelatelli', 'Gelatelli Chocolate', 111.0, 3.0, 2.1, 0, 17.3, 8.2, 2.4, 8.4, 0.0),
    ('Bon Gelati', 'Premium Bourbon - Dairy ice cream', 213.0, 12.5, 11.4, 0, 22.0, 19.6, 0.2, 3.0, 0.1),
    ('Gelatelli', 'High Protein Salted Caramel Ice Cream', 131.0, 3.3, 2.3, 0, 22.7, 11.9, 2.7, 7.1, 0.4),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', 24.0, 0.4, 0.1, 0, 1.5, 0.7, 2.3, 2.5, 0.1),
    ('Bon Gelati', 'Salted caramel premium ice cream', 219.0, 10.5, 9.3, 0, 27.8, 23.6, 0.2, 3.1, 0.6),
    ('Carrefour', 'Poisson pané', 195.0, 8.6, 1.1, 0, 17.0, 1.7, 0.5, 12.0, 0.9),
    ('Carrefour BIO', 'PIZZA Chèvre Cuite au feu de bois', 241.0, 9.3, 4.3, 0, 29.0, 6.0, 2.6, 9.4, 0.8),
    ('Bon Gelati', 'Walnut Bon Gelati', 255.0, 16.2, 10.3, 0, 22.7, 19.9, 0.6, 4.3, 0.1),
    ('Carrefour BIO', 'Galettes de riz chocolat au lait', 501.0, 24.0, 14.0, 0, 63.0, 27.0, 3.0, 7.5, 0.1),
    ('Italiamo', 'Pizza Prosciutto e Mozzarella', 202.0, 6.3, 3.0, 0, 25.5, 2.5, 0, 9.8, 1.1),
    ('Gelatelli', 'High protein cookies & cream', 124.0, 3.7, 2.7, 0, 19.7, 9.3, 2.8, 7.2, 0.2),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 26.0, 0.0, 0, 0, 3.4, 3.0, 2.3, 2.0, 0.0),
    ('Harrys', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', 348.0, 14.0, 4.3, 0, 43.0, 14.0, 7.0, 9.2, 0.9),
    ('Bon Gelati', 'Bon Gelati Eiscreme mit Schlagsahne', 247.0, 13.2, 8.9, 0, 26.6, 23.3, 0, 4.2, 0.1),
    ('Carrefour', 'Pain au Chocolat', 401.0, 19.0, 9.7, 0, 48.0, 11.0, 3.0, 6.8, 0.9),
    ('Carrefour', 'Spaghetti', 355.0, 1.8, 0.4, 0, 71.0, 3.5, 3.6, 12.0, 0.0),
    ('Magnum', 'Magnum Crème Glacée en Pot Amande 440ml', 218.0, 13.0, 7.3, 0, 21.0, 19.0, 0.8, 3.1, 0.1),
    ('Gelatelli', 'Creme al pistacchio', 328.0, 20.5, 14.2, 0, 30.2, 28.4, 2.9, 4.3, 0.1),
    ('Nixe', 'Weisser Thunfish Alalunga', 370.0, 32.4, 5.6, 0, 0.0, 0.0, 0.0, 19.7, 0.6),
    ('Mars', 'Snickers ice cream', 272.0, 17.0, 9.0, 0, 26.0, 23.0, 0, 4.3, 0.2),
    ('Bon Gelati', 'Stracciatella Premium Eis', 231.0, 13.2, 11.6, 0, 24.8, 22.3, 0, 3.1, 0.1),
    ('Bon Gelati', 'Glace Erdbeer Strawberry ice cream premium', 192.0, 7.6, 5.2, 0, 28.0, 24.1, 0, 2.7, 0.1),
    ('Simpl', 'Tranches de filets de Colin d''Alaska', 78.0, 0.9, 0.2, 0, 0.0, 0.0, 0, 17.0, 0.3),
    ('Carrefour', 'Cônes parfum vanille', 280.0, 12.0, 10.0, 0, 39.0, 26.0, 0.8, 3.5, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
