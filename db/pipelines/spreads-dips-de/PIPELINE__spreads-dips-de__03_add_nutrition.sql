-- PIPELINE (Spreads & Dips): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Spreads & Dips'
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
    ('Aldi', 'Vegane Bio-Streichcreme - Kräuter-Tomate', 323.0, 30.0, 3.2, 0, 6.6, 5.4, 4.0, 4.7, 0.6),
    ('Noa', 'Noa Brotaufstrich Hummus Kräuter', 230.0, 16.3, 2.4, 0, 11.2, 0.9, 0, 6.8, 1.7),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 214.0, 17.6, 3.0, 0, 9.0, 8.4, 4.2, 2.8, 1.2),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 164.0, 11.9, 1.5, 0, 9.0, 8.4, 5.7, 2.3, 2.8),
    ('Unknown', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 167.0, 9.3, 0.9, 0, 14.0, 6.3, 0, 5.0, 1.0),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 118.0, 7.2, 0.8, 0, 8.5, 4.7, 3.6, 3.1, 1.5),
    ('Menken Salades & Sauzen', 'Hummus - Kürbis', 149.0, 9.1, 1.1, 0, 10.0, 5.4, 0, 4.0, 1.0),
    ('Milram', 'Fein-würzige Sour Cream', 144.0, 10.3, 6.1, 0, 3.7, 3.7, 0, 8.7, 1.1),
    ('BLM', 'Bruschetta-Creme mit Paprika und Ricottakäse', 240.0, 20.0, 5.5, 0, 8.6, 5.5, 0, 6.3, 3.5),
    ('Sun Snacks', 'Salsa Dip Käse', 237.0, 20.0, 2.6, 0, 12.0, 1.5, 0, 2.1, 2.0),
    ('Kühlmann', 'Kichererbsenpüree', 253.0, 15.0, 1.7, 0, 13.0, 2.7, 0, 14.0, 1.2),
    ('W', 'Bio Hummus - Kichererbsenpüree mit Sesam und rotem Pesto', 280.0, 20.0, 2.4, 0, 15.0, 4.6, 0, 6.6, 1.1),
    ('Schätze des Orients', 'Hummus Natur', 307.0, 22.7, 2.1, 0, 15.1, 3.4, 4.9, 8.0, 1.0),
    ('NOA', 'Hummus , Natur', 332.0, 29.0, 2.5, 0, 9.0, 1.0, 0, 6.4, 1.5),
    ('Heinrich Kuhmann GmbH', 'Hummus - Pikant', 159.0, 24.6, 2.3, 0, 14.8, 4.6, 4.3, 7.3, 1.4),
    ('K Bio (Kaufland)', 'Bio Hummus Classic', 281.0, 22.0, 2.2, 0, 9.2, 1.4, 7.5, 7.7, 1.0),
    ('Noa', 'Hummus Paprika-Chili', 279.0, 22.0, 2.1, 0, 11.5, 3.0, 0, 6.0, 1.3),
    ('My Vay', 'Bio Streichcreme', 241.0, 20.0, 2.1, 0, 9.4, 4.5, 2.3, 4.6, 1.0),
    ('DmBio', 'Hummus Natur', 251.0, 22.0, 2.7, 0, 7.2, 0.6, 3.8, 3.8, 1.1),
    ('Chef Select', 'Bio Hummus Natur', 257.0, 18.5, 1.9, 0, 11.2, 2.2, 6.6, 8.2, 1.0),
    ('Kaufland', 'Veganer Hummus Classic', 256.0, 20.0, 2.0, 0, 7.5, 0.7, 8.2, 7.5, 1.2),
    ('Deluxe', 'Hummus und Guacamole', 247.0, 19.5, 2.6, 0, 7.0, 0.7, 8.9, 6.5, 0.9),
    ('Noa', 'Brotaufstrich Kichererbse Tomate-Basilikum', 174.0, 11.8, 1.1, 0, 10.3, 2.8, 0, 4.5, 1.5),
    ('Aldi', 'Vegane Bio-Streichcreme - Aubergine', 352.0, 34.0, 3.8, 0, 6.0, 3.4, 2.7, 4.1, 1.1),
    ('Chef select', 'Bio organic humus', 253.0, 18.9, 2.0, 0, 9.4, 2.4, 7.2, 7.8, 1.1),
    ('Feinkost Popp', 'Hummus Klassisch', 367.0, 29.6, 2.9, 0, 12.2, 0.9, 0, 9.2, 0.8),
    ('Milbona', 'Zaziki', 115.0, 7.6, 1.4, 0, 8.3, 5.5, 0.1, 3.2, 0.9),
    ('Aldi', 'Bio-Hummus - Natur', 223.0, 19.0, 2.8, 0, 6.5, 0.6, 0, 3.7, 1.1),
    ('Aldi', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 338.0, 32.0, 3.4, 0, 7.4, 5.5, 3.4, 3.5, 1.4),
    ('Chef Select', 'Guacamole scharf', 174.0, 14.7, 2.4, 0, 6.3, 0.8, 4.8, 1.7, 1.0),
    ('Nur Nur Natur', 'Bio Humus Paprika Kurkuma Chili', 181.0, 11.3, 1.7, 0, 10.4, 3.1, 8.6, 5.0, 0.7),
    ('Nur Nur Natur', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 198.0, 13.5, 2.0, 0, 9.4, 2.2, 9.0, 5.1, 0.8),
    ('Nabio', 'Gegrillte Paprika Cashew', 219.0, 18.0, 2.3, 0, 7.7, 5.0, 3.1, 4.7, 1.3),
    ('Chef Select', 'Guacamole Avocado-Dip mild', 147.0, 12.7, 2.9, 0, 4.6, 3.0, 0, 1.8, 0),
    ('Wonnemeyer', 'Antipasticreme - Feta', 272.0, 23.0, 12.0, 0, 6.5, 4.2, 0, 11.0, 2.3),
    ('Nur Nur Natur', 'Bio-Hummus - Tomate', 175.0, 13.0, 1.8, 0, 9.3, 3.9, 0, 3.7, 1.4),
    ('Popp', 'Brotaufstrich Bruschetta', 89.0, 7.3, 0.5, 0, 3.7, 3.0, 0, 1.1, 1.4),
    ('Kaufland', 'Guacamole', 146.0, 13.0, 3.1, 0, 2.1, 1.2, 5.7, 1.5, 0.8),
    ('Chef select', 'Hummus Nature', 255.0, 19.8, 2.0, 0, 7.5, 0.7, 8.5, 7.4, 1.2),
    ('Kühlmann', 'Hummus Trio', 289.0, 21.0, 2.1, 0, 14.0, 3.9, 0, 7.3, 1.9),
    ('Aldi', 'Bio-Hummus - Rote Beete', 190.0, 15.0, 2.2, 0, 7.8, 3.0, 0, 3.4, 1.3),
    ('Chef Select', 'Hummus bruschetta', 245.0, 19.8, 1.9, 0, 6.9, 1.6, 7.0, 6.3, 0.0),
    ('Aldi', 'Bio-Hummus - Paprika', 182.0, 13.0, 1.8, 0, 10.0, 4.8, 0, 3.7, 1.3),
    ('Grossmann', 'Knoblauch-Dip', 468.0, 46.5, 4.0, 0, 10.4, 5.3, 0, 1.5, 1.4),
    ('Kaufland', 'Hummus mit Topping Grünes Pesto', 321.0, 25.0, 24.0, 0, 14.0, 3.2, 4.6, 7.8, 1.3),
    ('Wonnemeyer', 'Antipasticreme - Dattel-Curry', 274.0, 23.0, 13.0, 0, 13.0, 11.0, 1.3, 3.5, 3.2),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 154.0, 10.7, 2.1, 0, 10.0, 9.5, 3.1, 2.8, 2.2),
    ('Chef Select', 'Kirschpaprika Antipasti-Creme', 269.0, 21.9, 13.8, 0, 12.4, 9.4, 0.3, 5.3, 1.5),
    ('Noa', 'Hummus Dattel Curry', 304.0, 23.6, 2.2, 0, 15.0, 8.5, 0, 5.5, 1.4),
    ('Chio', 'Hot Cheese Dip!', 150.0, 8.8, 2.4, 0, 15.0, 0.4, 0, 2.7, 1.7),
    ('Chio', 'Chip dip', 106.0, 1.2, 0.3, 0, 22.0, 15.0, 0, 1.1, 2.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
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
