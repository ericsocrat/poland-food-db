-- PIPELINE (Snacks): source provenance
-- Generated: 2026-03-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Pom-Bär', 'POM-BÄR Original', 'https://world.openfoodfacts.org/product/4000522105210', '4000522105210'),
    ('Huober', 'Original schwäbische Knusper Brezel', 'https://world.openfoodfacts.org/product/4000381003030', '4000381003030'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'https://world.openfoodfacts.org/product/4011800523312', '4011800523312'),
    ('Leicht & Cross', 'Leicht & Cross Vollkorn Knäckebrot', 'https://world.openfoodfacts.org/product/4001518104064', '4001518104064'),
    ('Corny', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'https://world.openfoodfacts.org/product/4011800523213', '4011800523213'),
    ('Leicht & Cross', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'https://world.openfoodfacts.org/product/4001518006450', '4001518006450'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'https://world.openfoodfacts.org/product/4017100706004', '4017100706004'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 'https://world.openfoodfacts.org/product/4011800593810', '4011800593810'),
    ('Lorenz', 'Clubs Cracker', 'https://world.openfoodfacts.org/product/4018077620003', '4018077620003'),
    ('Seeberger', 'Nuts''n Berries', 'https://world.openfoodfacts.org/product/4008258051030', '4008258051030'),
    ('Corny', 'Nussvoll Nuss &Traube', 'https://world.openfoodfacts.org/product/4011800549411', '4011800549411'),
    ('Corny', 'Milch Classic', 'https://world.openfoodfacts.org/product/4011800562212', '4011800562212'),
    ('Rivercote', 'Knusperbrot Weizen', 'https://world.openfoodfacts.org/product/4056489703990', '4056489703990'),
    ('Corny', 'CORNY Schoko', 'https://world.openfoodfacts.org/product/4011800521219', '4011800521219'),
    ('Corny', 'Corny - Schoko-Banane', 'https://world.openfoodfacts.org/product/4011800523220', '4011800523220'),
    ('DmBio', 'Schoko Reiswaffeln Zartbitter', 'https://world.openfoodfacts.org/product/4067796140309', '4067796140309'),
    ('Leicht & Cross', 'Knusperbrot Goldweizen', 'https://world.openfoodfacts.org/product/4008404001001', '4008404001001'),
    ('DmBio', 'Dinkel Mini brezeln', 'https://world.openfoodfacts.org/product/4066447599466', '4066447599466'),
    ('Tuc', 'Tuc Original', 'https://world.openfoodfacts.org/product/5410041001204', '5410041001204'),
    ('Pågen', 'Gifflar Cannelle', 'https://world.openfoodfacts.org/product/7311070346916', '7311070346916'),
    ('Alnatura', 'Linsenwaffeln', 'https://world.openfoodfacts.org/product/4104420231658', '4104420231658'),
    ('Alesto', 'Cruspies Paprika', 'https://world.openfoodfacts.org/product/20005702', '20005702'),
    ('Snack Day', 'Erdnuss Flips', 'https://world.openfoodfacts.org/product/20045852', '20045852'),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', 'https://world.openfoodfacts.org/product/4260654789119', '4260654789119'),
    ('KoRo', 'Protein Bar Deluxe', 'https://world.openfoodfacts.org/product/4260718295884', '4260718295884'),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', 'https://world.openfoodfacts.org/product/4337256723923', '4337256723923'),
    ('Mondelez', 'Paprika', 'https://world.openfoodfacts.org/product/5410041066005', '5410041066005'),
    ('ESN', 'Designer Protein Bar', 'https://world.openfoodfacts.org/product/4250519646527', '4250519646527'),
    ('Maretti', 'Bruschette', 'https://world.openfoodfacts.org/product/3800205872924', '3800205872924')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE;
