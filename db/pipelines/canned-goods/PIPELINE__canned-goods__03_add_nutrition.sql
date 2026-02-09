-- PIPELINE (Canned Goods): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Canned Goods'
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
    ('Nasza Spiżarnia', 'Kukurydza słodka', 77.0, 1.8, 0.4, 0, 11.0, 5.2, 2.8, 2.9, 0.5),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 176.0, 10.0, 1.5, 0, 3.6, 2.0, 0, 18.0, 0.6),
    ('Dawtona', 'Kukurydza słodka', 126.0, 1.2, 0.2, 0, 24.0, 2.2, 3.9, 2.9, 0.7),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym.', 18.0, 0.2, 0.1, 0, 2.9, 2.9, 0.8, 0.7, 0.0),
    ('Dega', 'Fish spread with rice', 150.0, 9.4, 1.2, 0, 11.0, 3.8, 0, 4.8, 1.3),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 64.4, 0.0, 0.0, 0, 15.1, 14.6, 1.1, 0.3, 0.1),
    ('Freshona', 'Buraczki wiórki', 50.0, 0.5, 0.1, 0, 9.5, 8.9, 0, 1.4, 0.4),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 183.0, 11.8, 2.3, 0, 6.7, 6.6, 0, 11.8, 0.8),
    ('Lidl', 'Buraczki zasmażane z cebulką', 77.0, 2.0, 0.4, 0, 13.0, 12.0, 1.4, 1.0, 0.7),
    ('Kaufland', 'Sardynki w oleju słonecznikowym', 147.0, 5.3, 3.2, 0, 0.5, 0.5, 0.0, 24.0, 0.8),
    ('Baresa', 'Azeitonas Lidl', 172.0, 18.0, 3.0, 0, 0.0, 0.0, 2.3, 1.0, 3.0),
    ('Freshona', 'Sonnenmais natursüß', 77.0, 1.7, 0.3, 0, 11.5, 5.5, 2.8, 2.6, 0.3),
    ('Freshona', 'Ananas en tranches au sirop léger', 56.0, 0.5, 0.0, 0, 13.0, 13.0, 1.0, 0.5, 0.0),
    ('Freshona', 'coconut milk', 128.0, 13.2, 11.7, 0, 1.1, 1.1, 0.5, 1.0, 0.3),
    ('Bonduelle', 'Lunch bowl Légumes & boulgour 250g', 130.0, 2.0, 0.3, 0, 22.0, 2.0, 2.4, 4.7, 0.7),
    ('Baresa', 'Peeled Tomatoes in tomato juice', 23.0, 0.4, 0.0, 0, 3.5, 2.5, 1.9, 0.8, 0.3),
    ('NIXE', 'Sardines à l''huile de tournesol', 204.0, 13.2, 2.7, 0, 0.0, 0, 0, 21.4, 1.0),
    ('El Tequito', 'Jalapeños', 12.0, 0.1, 0.1, 0, 1.6, 0.3, 0.9, 0.6, 2.0),
    ('Carrefour', 'Morceaux de thon', 99.0, 0.5, 0.1, 0, 0.5, 0.0, 0, 24.0, 0.9),
    ('Alpen Fest style', 'Rodekool Chou rouge', 59.0, 0.2, 0.1, 0, 11.1, 10.4, 2.4, 1.4, 0.5),
    ('Cirio', 'Pelati Geschälte Tomaten', 27.0, 0.2, 0.1, 0, 4.2, 3.8, 1.1, 1.1, 0.0),
    ('Baresa', 'Pulpe de tomates, basilic & origan', 24.0, 0.1, 0.1, 0, 3.7, 3.6, 1.2, 1.2, 0.5),
    ('Carrefour', 'Morceaux de thon au naturel', 99.0, 0.5, 0.1, 0, 0.5, 0.0, 0.5, 24.0, 0.9),
    ('SOL & MAR', 'Czosnek z chilli w oleju', 68.0, 6.1, 0.7, 0, 1.3, 0.2, 2.4, 0.7, 1.1),
    ('Freshona', 'Gurkensticks', 36.0, 0.1, 0.1, 0, 7.0, 7.0, 0, 0.4, 1.0),
    ('Carrefour', 'Morceaux de Thon', 99.0, 0.8, 0.3, 0, 0.0, 0.0, 0.0, 23.0, 0.8),
    ('Carrefour', 'Olives à la farce aux anchois', 155.0, 16.0, 3.0, 0, 0.0, 0.0, 2.5, 1.3, 3.2),
    ('Carrefour', 'Miettes de thon', 130.0, 6.4, 1.0, 0, 3.9, 3.4, 0.6, 14.0, 1.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
