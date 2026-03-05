-- PIPELINE (Snacks): scoring
-- Generated: 2026-03-04

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Pom-Bär', 'POM-BÄR Original', 'D'),
    ('Huober', 'Original schwäbische Knusper Brezel', 'E'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'D'),
    ('Leicht & Cross', 'Leicht & Cross Vollkorn Knäckebrot', 'B'),
    ('Corny', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'E'),
    ('Leicht & Cross', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'B'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'E'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 'B'),
    ('Lorenz', 'Clubs Cracker', 'D'),
    ('Corny', 'Corny Schoko', 'E'),
    ('Seeberger', 'Nuts''n Berries', 'D'),
    ('Rivercote', 'Knusperbrot Weizen', 'A'),
    ('Corny', 'Corny - Schoko-Banane', 'E'),
    ('DmBio', 'Schoko Reiswaffeln Zartbitter', 'E'),
    ('Leicht & Cross', 'Knusperbrot Goldweizen', 'C'),
    ('Tuc', 'Tuc Original', 'E'),
    ('Pågen', 'Gifflar Cannelle', 'D'),
    ('Alnatura', 'Linsenwaffeln', 'A'),
    ('Alesto', 'Cruspies Paprika', 'E'),
    ('Snack Day', 'Erdnuss Flips', 'D'),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', 'NOT-APPLICABLE'),
    ('KoRo', 'Protein Bar Deluxe', 'NOT-APPLICABLE'),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', 'D'),
    ('Mondelez', 'Paprika', 'E'),
    ('ESN', 'ESN Designer protein bar hazelnut nougat', 'A'),
    ('Maretti', 'Bruschette', 'D')
) as d(brand, product_name, ns)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Pom-Bär', 'POM-BÄR Original', '4'),
    ('Huober', 'Original schwäbische Knusper Brezel', '3'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', '4'),
    ('Leicht & Cross', 'Leicht & Cross Vollkorn Knäckebrot', '3'),
    ('Corny', 'Corny Schoko-Banane 4011800523213 Müsliriegel', '4'),
    ('Leicht & Cross', 'Knäckebrot Vital: Vitamine und Mehrkorn', '4'),
    ('Lorenz', 'Lorenz Saltletts Sticks', '3'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', '4'),
    ('Lorenz', 'Clubs Cracker', '3'),
    ('Corny', 'Corny Schoko', '4'),
    ('Seeberger', 'Nuts''n Berries', '3'),
    ('Rivercote', 'Knusperbrot Weizen', '3'),
    ('Corny', 'Corny - Schoko-Banane', '4'),
    ('DmBio', 'Schoko Reiswaffeln Zartbitter', '3'),
    ('Leicht & Cross', 'Knusperbrot Goldweizen', '3'),
    ('Tuc', 'Tuc Original', '4'),
    ('Pågen', 'Gifflar Cannelle', '4'),
    ('Alnatura', 'Linsenwaffeln', '3'),
    ('Alesto', 'Cruspies Paprika', '4'),
    ('Snack Day', 'Erdnuss Flips', '3'),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', '4'),
    ('KoRo', 'Protein Bar Deluxe', '4'),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', '3'),
    ('Mondelez', 'Paprika', '4'),
    ('ESN', 'ESN Designer protein bar hazelnut nougat', '4'),
    ('Maretti', 'Bruschette', '4')
) as d(brand, product_name, nova)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Snacks', 100, 'DE');
