-- PIPELINE (Plant-Based & Alternatives): scoring
-- Generated: 2026-03-04

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'C'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'C'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'D'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'A'),
    ('DmBio', 'Maiswaffeln', 'B'),
    ('REWE Bio +vegan', 'Räucher-Tofu', 'A'),
    ('Rewe', 'Falafel bällchen', 'A'),
    ('Like Meat', 'Like Grilled Chicken', 'A'),
    ('Like Meat', 'Like Chicken', 'A'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 'A'),
    ('Freshona', 'Cornichons Gurken', 'C'),
    ('REWE Bio', 'Tofu Natur', 'A'),
    ('Baresa', 'Tomaten passiert', 'A'),
    ('Alpro', 'Hafer Milch', 'A'),
    ('Oatly!', 'Haferdrink Barista Bio', 'A'),
    ('Barilla', 'Spaghetti N°5', 'A')
) as d(brand, product_name, ns)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', '4'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', '4'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', '4'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', '4'),
    ('DmBio', 'Maiswaffeln', '1'),
    ('REWE Bio +vegan', 'Räucher-Tofu', '3'),
    ('Rewe', 'Falafel bällchen', '3'),
    ('Like Meat', 'Like Grilled Chicken', '4'),
    ('Like Meat', 'Like Chicken', '4'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', '3'),
    ('Freshona', 'Cornichons Gurken', '3'),
    ('REWE Bio', 'Tofu Natur', '3'),
    ('Baresa', 'Tomaten passiert', '3'),
    ('Alpro', 'Hafer Milch', '4'),
    ('Oatly!', 'Haferdrink Barista Bio', '3'),
    ('Barilla', 'Spaghetti N°5', '1')
) as d(brand, product_name, nova)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Plant-Based & Alternatives', 100, 'DE');
