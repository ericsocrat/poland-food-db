-- PIPELINE (Frozen & Prepared): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Frozen & Prepared'
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
    ('Frosta', 'Bratkartoffel Hähnchen Pfanne', 98.0, 3.7, 1.3, 0, 10.4, 2.1, 2.1, 4.8, 0.7),
    ('Frosta', 'Fischstäbchen ( Frosta)', 184.0, 8.3, 1.0, 0, 13.8, 1.6, 0.9, 13.0, 2.3),
    ('Frosta', 'Hühnerfrikassee', 144.0, 8.2, 3.0, 0, 10.9, 1.1, 0.9, 6.1, 1.0),
    ('Frosta', 'Tortellini Käse-Sahne (vegetarisch)', 132.0, 7.4, 4.3, 0, 11.4, 1.9, 1.4, 4.2, 0.9),
    ('Frosta', 'Gemüse Pfanne alla Toscana', 41.0, 1.9, 0.3, 0, 3.3, 3.0, 2.4, 1.5, 1.0),
    ('Frosta', 'Hähnchen Curry', 104.0, 2.5, 0.7, 0, 14.4, 3.4, 1.3, 5.5, 0.8),
    ('Speisezeit', 'Süßkartoffel-Pommes', 140.0, 5.0, 0.5, 0, 20.0, 8.0, 0, 2.0, 0.3),
    ('Original Wagner', 'Piccolinis Drei-Käse Pizza', 291.0, 13.7, 7.0, 0, 28.9, 3.3, 1.5, 12.1, 1.1),
    ('Nur Nur Natur', 'Bio-Dinkel-Steinofenpizza - Grillgemüse', 178.5, 4.5, 2.2, 0, 26.3, 1.8, 2.0, 7.3, 0.9),
    ('Dr. Oetker', 'Die Ofenfrische Vier Käse', 217.0, 7.2, 4.6, 0, 27.0, 2.9, 1.8, 9.5, 1.2),
    ('Frosta', 'Wildlachs in Kräuterrahm', 87.0, 3.0, 0, 0, 10.2, 1.8, 0.9, 4.3, 1.0),
    ('Frosta', 'Paprika Sahne Hähnchen mit Bandnudeln', 103.0, 3.3, 2.0, 0, 12.1, 2.5, 1.3, 5.6, 0.9),
    ('Frosta', 'Gemüsepfanne a la Provence', 51.0, 1.6, 0.3, 0, 8.5, 3.6, 2.3, 1.7, 0.8),
    ('Frosta', 'Gemüse Pfanne Style Asia Curry', 57.0, 2.4, 1.3, 0, 5.8, 4.3, 2.1, 2.0, 0.0),
    ('Frosta', 'Reis Hähnchen Pfanne', 117.0, 3.6, 1.7, 0, 15.3, 2.0, 1.8, 4.9, 2.9),
    ('Golden Seafood', 'Riesengarnelenschwänze - Natur', 72.0, 0.9, 0.3, 0, 0.5, 0.5, 0, 16.0, 1.0),
    ('Freshona', 'Gemüsepfanne Bio Mediterrane Art', 57.0, 2.7, 0.4, 0, 5.4, 4.6, 0, 1.5, 0.7),
    ('Frost', 'Pfannenfisch Müllerin Art', 115.0, 0.8, 0.2, 0, 11.7, 0.5, 0, 14.9, 1.1),
    ('Frosta', 'Gemüse-Bowl - Pikanter Bulgur mit schwarzen Bohnen', 59.0, 0.5, 0.1, 0, 9.5, 3.2, 2.8, 2.6, 0.6),
    ('Frosta', 'Bami Goreng', 103.0, 1.9, 0.6, 0, 13.5, 1.4, 1.8, 7.0, 0.9),
    ('Frosta', 'Butter Chicken', 122.0, 4.5, 2.7, 0, 14.7, 1.5, 0.7, 5.2, 0.9),
    ('Original Wagner', 'Pizza Die Backfrische Mozzarella', 213.0, 7.0, 3.2, 0, 26.3, 2.9, 2.0, 10.2, 1.1),
    ('Frosta', 'Nice Rice - Korean Style', 78.0, 1.3, 0.2, 0, 13.7, 3.1, 1.6, 2.1, 1.0),
    ('Dr. Oetker', 'Ristorante PIZZA TONNO', 232.4, 10.4, 2.7, 0, 23.4, 3.1, 1.8, 10.0, 0.9),
    ('Frosta', 'Paella', 94.0, 2.4, 1.2, 0, 12.3, 1.7, 1.1, 5.2, 1.2),
    ('Dr. Oetker', 'Suprema Pizza Calabrese & ''Nduja', 231.0, 9.0, 4.0, 0, 27.1, 4.8, 2.1, 9.2, 1.3),
    ('Original Wagner', 'Steinofen-Pizza Mozzarella Vegetarisch', 230.0, 9.3, 3.7, 0, 25.3, 3.9, 2.0, 10.2, 1.0),
    ('Dr. Oetker', 'Die Ofenfrische Margherita', 225.0, 7.4, 4.6, 0, 29.0, 2.9, 1.9, 9.8, 1.3),
    ('Greenyard Frozen Langemark', 'Buckwheat & broccoli', 79.0, 2.7, 0.3, 0, 8.7, 2.6, 3.2, 3.3, 0.5),
    ('Frosta', 'Fisch Schlemmerfilet Mediterraner Art', 118.0, 6.9, 3.9, 0, 3.8, 2.4, 0.6, 9.8, 0.8),
    ('Frosta', 'Fettuccine Wildlachs', 112.0, 3.6, 1.7, 0, 13.3, 1.4, 1.6, 5.9, 0.7),
    ('Dr. Oetker', 'Pizza Tradizionale Margherita', 238.0, 7.5, 3.2, 0, 32.0, 3.2, 1.9, 9.9, 1.0),
    ('Original Wagner', 'Steinofen-Pizza - Diavolo', 231.0, 9.5, 4.0, 0, 25.5, 3.7, 2.2, 9.7, 1.0),
    ('Dr. Oetker', 'Die Ofenfrische Speciale', 206.0, 6.4, 3.4, 0, 27.0, 2.7, 1.9, 9.1, 1.3),
    ('Dr. Oetker', 'Pizza Salame Ristorante', 267.0, 13.0, 4.7, 0, 26.0, 3.0, 1.8, 10.0, 1.3),
    ('Vemondo', 'Vegan pizza Verdura', 144.6, 2.7, 0.4, 0, 24.0, 3.2, 2.4, 4.9, 0.8),
    ('Dr. Oetker', 'Die Ofenfrische Salami', 227.0, 7.8, 4.1, 0, 29.0, 2.8, 1.9, 9.6, 1.4),
    ('Frosta', 'Fisch Schlemmerfilet Brokkoli Mandel', 123.0, 8.0, 4.8, 0, 2.6, 1.0, 0.6, 9.9, 0.8),
    ('Dr. Oetker', 'La Mia Grande Rucola', 207.0, 7.2, 3.6, 0, 24.0, 3.5, 1.9, 10.0, 1.1),
    ('GiaPizza', 'Bio-Dinkel-Steinofenpizza - Spinat', 172.0, 4.0, 2.1, 0, 25.6, 1.5, 2.0, 7.5, 0.9),
    ('Nestlé', 'Pizza Speciale', 233.0, 9.6, 3.9, 0, 25.3, 3.5, 2.2, 10.4, 1.1),
    ('Dr. Oetker', 'La Mia Grande Pizza Margherita', 236.0, 8.5, 4.3, 0, 27.0, 3.6, 2.0, 12.0, 1.3),
    ('Speise Zeit', 'Wellenschnitt Pommes', 150.0, 5.1, 0.5, 0, 22.3, 0.4, 2.5, 2.5, 0.1),
    ('Frosta', 'Nom Nom Noodles', 84.0, 2.2, 1.8, 0, 12.0, 2.4, 1.6, 3.1, 0.8),
    ('Dr. Oetker', 'Pizza Traditionale Verdure Grigliate', 208.8, 6.6, 2.9, 0, 28.8, 4.1, 2.2, 7.3, 0.8),
    ('Dr. Oetker', 'Ristorante Pizza Pasta', 228.3, 8.8, 2.7, 0, 28.3, 2.9, 1.8, 8.0, 1.0),
    ('Nur Nur Natur', 'Bio-Eiscreme - Vanille', 210.0, 13.8, 8.1, 0, 18.2, 18.2, 0, 3.2, 0.1),
    ('Nestlé', 'Steinofen-Pizza Thunfisch', 219.7, 8.9, 3.0, 0, 24.1, 3.6, 2.1, 9.7, 1.1),
    ('Aldi', 'Pommes Frites', 150.0, 5.4, 0.6, 0, 21.8, 0.2, 0, 2.6, 0.0),
    ('All Seasons', 'Rahm-Spinat', 40.0, 2.3, 0.7, 0, 1.7, 1.1, 0, 2.1, 0.8),
    ('Vemondo', 'Pumpkin & quinoa', 80.0, 2.5, 0.3, 0, 8.5, 3.2, 4.3, 3.8, 0.5)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Frozen & Prepared' and p.is_deprecated is not true
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
