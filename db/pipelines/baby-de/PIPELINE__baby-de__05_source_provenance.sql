-- PIPELINE (Baby): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Hipp', 'Reine Bio-Karotten mild-süßlich', 'https://world.openfoodfacts.org/product/4062300020719', '4062300020719'),
    ('Hipp', 'Früchte Riegel Joghurt-Kirsch in Banane', 'https://world.openfoodfacts.org/product/4062300362215', '4062300362215'),
    ('Mamia Bio', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'https://world.openfoodfacts.org/product/4061459751420', '4061459751420'),
    ('Hipp', 'Gemüse Allerlei', 'https://world.openfoodfacts.org/product/4062300020313', '4062300020313'),
    ('DmBio', 'Kürbis pur', 'https://world.openfoodfacts.org/product/4067796017090', '4067796017090'),
    ('Bebivita', 'Mini-Makkaroni mit buntem Rahmgemüse', 'https://world.openfoodfacts.org/product/4018852014959', '4018852014959'),
    ('Hipp', 'Reiner Butternut Kürbis', 'https://world.openfoodfacts.org/product/4062300381971', '4062300381971'),
    ('Hipp', 'Menü Karotten, Kartoffeln, Wildlachs', 'https://world.openfoodfacts.org/product/4062300255142', '4062300255142'),
    ('Hipp', 'Gemüse Kürbis Nach Dem 4. Monat', 'https://world.openfoodfacts.org/product/4062300257597', '4062300257597'),
    ('Puttkammer', 'Schinkenröllchen in Aspik', 'https://world.openfoodfacts.org/product/4004176100539', '4004176100539'),
    ('Hipp', 'Mango-Bananen-Grieß', 'https://world.openfoodfacts.org/product/4062300406476', '4062300406476'),
    ('Hipp', 'Spinatgemüse in Kartoffeln', 'https://world.openfoodfacts.org/product/4062300350403', '4062300350403'),
    ('Bebivita', 'Abendbrei Grieß-Vanille', 'https://world.openfoodfacts.org/product/4018852035855', '4018852035855'),
    ('Hipp', 'Grießbrei', 'https://world.openfoodfacts.org/product/4062300123175', '4062300123175'),
    ('Hipp', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 'https://world.openfoodfacts.org/product/4062300266179', '4062300266179'),
    ('Hipp', 'Gemüse Lasagne', 'https://world.openfoodfacts.org/product/4062300265967', '4062300265967'),
    ('Bebivita', 'Gemüse-Spätzle-Pfanne', 'https://world.openfoodfacts.org/product/4018852030577', '4018852030577'),
    ('DmBio', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 'https://world.openfoodfacts.org/product/4067796081381', '4067796081381'),
    ('Hipp', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 'https://world.openfoodfacts.org/product/4062300265998', '4062300265998'),
    ('Hipp', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 'https://world.openfoodfacts.org/product/4062300166738', '4062300166738'),
    ('Hipp', 'Erdbeere in Apfel-Joghurt-Müsli', 'https://world.openfoodfacts.org/product/4062300262652', '4062300262652'),
    ('Hipp', 'Gartengemüse Mit Pute Und Rosmarin', 'https://world.openfoodfacts.org/product/4062300265608', '4062300265608'),
    ('Hipp', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 'https://world.openfoodfacts.org/product/4062300266025', '4062300266025'),
    ('Hipp', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 'https://world.openfoodfacts.org/product/4062300261303', '4062300261303'),
    ('Hipp', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 'https://world.openfoodfacts.org/product/4062300349445', '4062300349445'),
    ('Hipp', 'Hippis Pfirsich Banane Mango Joghurt', 'https://world.openfoodfacts.org/product/4062300432123', '4062300432123'),
    ('DmBio', 'Hirse Getreidebrei', 'https://world.openfoodfacts.org/product/4066447398649', '4066447398649'),
    ('Hipp', 'Pfirsich in Apfel (ab 5. Monat)', 'https://world.openfoodfacts.org/product/4062300297104', '4062300297104'),
    ('Hipp', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'https://world.openfoodfacts.org/product/4062300290136', '4062300290136'),
    ('Unknown', 'Apfel Bananen müesli', 'https://world.openfoodfacts.org/product/4062300406490', '4062300406490'),
    ('DmBio', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'https://world.openfoodfacts.org/product/4058172437892', '4058172437892'),
    ('Hipp', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'https://world.openfoodfacts.org/product/4062300269842', '4062300269842'),
    ('Bebivita', 'Anfangsmilch', 'https://world.openfoodfacts.org/product/4018852026655', '4018852026655'),
    ('Hipp Bio', 'Himbeer Reiswaffeln', 'https://world.openfoodfacts.org/product/4062300376182', '4062300376182'),
    ('Hipp', 'Bio Combiotik Pre', 'https://world.openfoodfacts.org/product/4062300398894', '4062300398894'),
    ('Dr. Oetker', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 'https://world.openfoodfacts.org/product/4062300297081', '4062300297081'),
    ('Hipp', 'Urkorn Dinos', 'https://world.openfoodfacts.org/product/4062300429710', '4062300429710'),
    ('Bebivita', 'Reis mit Karotten und Pute', 'https://world.openfoodfacts.org/product/4018852035343', '4018852035343'),
    ('Hipp', 'Hipp', 'https://world.openfoodfacts.org/product/4062300375260', '4062300375260'),
    ('Hipp', 'Hippis Apfel-Birne-Banane', 'https://world.openfoodfacts.org/product/4062300278530', '4062300278530'),
    ('Milupa', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 'https://world.openfoodfacts.org/product/4008976091271', '4008976091271'),
    ('Hipp', 'Apfel Banane in Babykeks', 'https://world.openfoodfacts.org/product/4062300269811', '4062300269811'),
    ('Hipp', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 'https://world.openfoodfacts.org/product/4062300379503', '4062300379503'),
    ('Hipp', 'Hipp Guten Morgen', 'https://world.openfoodfacts.org/product/4062300379657', '4062300379657'),
    ('DmBio', 'Babyobst', 'https://world.openfoodfacts.org/product/4058172438011', '4058172438011'),
    ('Kölln', 'Schmelzflocken 5 korn 6. Monat', 'https://world.openfoodfacts.org/product/4000540002560', '4000540002560'),
    ('Hipp', 'Heidelbeer reiswaffeln', 'https://world.openfoodfacts.org/product/4062300376205', '4062300376205'),
    ('Hipp', 'BIO Getreidebrei 5-Korn', 'https://world.openfoodfacts.org/product/4062300344877', '4062300344877'),
    ('Hipp', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'https://world.openfoodfacts.org/product/4062300289406', '4062300289406'),
    ('Hipp', 'Hipp, Karotten Mit Reis Und Wildlachs', 'https://world.openfoodfacts.org/product/4062300208254', '4062300208254'),
    ('Bebivita', 'Pfirsich mit Maracuja in Apfel', 'https://world.openfoodfacts.org/product/4018852029083', '4018852029083')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE;
