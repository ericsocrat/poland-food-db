-- PIPELINE (Bread): source provenance
-- Generated: 2026-02-25

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Gräfschafter', 'Eiweißreiches Weizenvollkornbrot', 'https://world.openfoodfacts.org/product/4056489206026', '4056489206026'),
    ('Harry', 'Körner Balance Sandwich', 'https://world.openfoodfacts.org/product/4071800038810', '4071800038810'),
    ('Golden Toast', 'Sandwich Körner-Harmonie', 'https://world.openfoodfacts.org/product/4009249001843', '4009249001843'),
    ('Lieken Urkorn', 'Fitnessbrot mit 5 % Ölsaaten', 'https://world.openfoodfacts.org/product/4009249002277', '4009249002277'),
    ('Harry', 'Eiweißbrot', 'https://world.openfoodfacts.org/product/4071800058269', '4071800058269'),
    ('Harry', 'Harry Dinkel Krüstchen 4071800057637', 'https://world.openfoodfacts.org/product/4071800057637', '4071800057637'),
    ('Aldi', 'Das Pure - Bio-Haferbrot mit 29% Ölsaaten', 'https://world.openfoodfacts.org/product/4061461077563', '4061461077563'),
    ('Conditorei Coppenrath & Wiese', 'Weizenbrötchen', 'https://world.openfoodfacts.org/product/4008577006315', '4008577006315'),
    ('Lieken', 'Roggenbäcker', 'https://world.openfoodfacts.org/product/4009249002550', '4009249002550'),
    ('Goldähren', 'Französisches Steinofen-Baguette', 'https://world.openfoodfacts.org/product/4061458046046', '4061458046046'),
    ('Goldähren', 'Laugen-Brioche vorgeschnitten, 6 Stück', 'https://world.openfoodfacts.org/product/4061459698992', '4061459698992'),
    ('Mestemacher', 'Westfälischen Pumpernickel', 'https://world.openfoodfacts.org/product/4000446001018', '4000446001018'),
    ('Goldähren', 'Toast-Brötchen Protein', 'https://world.openfoodfacts.org/product/4061458227650', '4061458227650'),
    ('GutBio', 'Das Pure - Haferbrot mit 27% Ölsaaten', 'https://world.openfoodfacts.org/product/4061458176323', '4061458176323'),
    ('Coppenrath & Wiese', 'Dinkelbrötchen', 'https://world.openfoodfacts.org/product/4008577006186', '4008577006186'),
    ('Aldi', 'Bio-Landbrötchen - Kernig', 'https://world.openfoodfacts.org/product/4068706471902', '4068706471902'),
    ('Sinnack', 'Brot Protein Brötchen', 'https://world.openfoodfacts.org/product/4009097010691', '4009097010691'),
    ('Harry', 'Körner Balance Toastbrötchen', 'https://world.openfoodfacts.org/product/4071800038568', '4071800038568'),
    ('Gut bio', 'Finnkorn Toastbrötchen', 'https://world.openfoodfacts.org/product/4061462968624', '4061462968624'),
    ('Grafschafter', 'Pure Kornkraft Haferbrot', 'https://world.openfoodfacts.org/product/4056489183631', '4056489183631'),
    ('Goldähren', 'Vollkorn-Sandwich', 'https://world.openfoodfacts.org/product/4061458022040', '4061458022040'),
    ('Golden Toast', 'Vollkorn-Toast', 'https://world.openfoodfacts.org/product/4009249019923', '4009249019923'),
    ('Harry', 'Harry Brot Vital + Fit', 'https://world.openfoodfacts.org/product/4071800001012', '4071800001012'),
    ('Goldähren', 'Vollkorntoast', 'https://world.openfoodfacts.org/product/4061458045759', '4061458045759'),
    ('Goldähren', 'Eiweiss Brot', 'https://world.openfoodfacts.org/product/4061458055734', '4061458055734'),
    ('Meierbaer & Albro', 'Das Pure - Bio-Haferbrot', 'https://world.openfoodfacts.org/product/4061462084256', '4061462084256'),
    ('Goldähren', 'Mehrkorn Wraps', 'https://world.openfoodfacts.org/product/4061458045797', '4061458045797'),
    ('Goldähren', 'Protein-Wraps', 'https://world.openfoodfacts.org/product/4061458236928', '4061458236928'),
    ('Nur Nur Natur', 'Bio-Roggenvollkornbrot', 'https://world.openfoodfacts.org/product/4061459425697', '4061459425697'),
    ('DmBio', 'Das Pure Hafer - und Saatenbrot', 'https://world.openfoodfacts.org/product/4067796162462', '4067796162462'),
    ('Goldähren', 'American Sandwich - Weizen', 'https://world.openfoodfacts.org/product/4061458022033', '4061458022033'),
    ('Harry', 'Vollkorn Toast', 'https://world.openfoodfacts.org/product/4071800000633', '4071800000633'),
    ('Brandt', 'Brandt Markenzwieback', 'https://world.openfoodfacts.org/product/4013752019004', '4013752019004'),
    ('Harry', 'Unser Mildes (Weizenmischbrot)', 'https://world.openfoodfacts.org/product/4071800000879', '4071800000879'),
    ('Lieken', 'Bauernmild Brot', 'https://world.openfoodfacts.org/product/4009249001171', '4009249001171'),
    ('Lieken Urkorn', 'Vollkornsaftiges fein', 'https://world.openfoodfacts.org/product/4006170001676', '4006170001676'),
    ('Goldähren', 'Mehrkornschnitten', 'https://world.openfoodfacts.org/product/4061458169066', '4061458169066'),
    ('Mestemacher', 'Dinkel Wraps', 'https://world.openfoodfacts.org/product/4000446015497', '4000446015497'),
    ('Harry', 'Toastbrot', 'https://world.openfoodfacts.org/product/4071800038803', '4071800038803'),
    ('Harry', 'Vollkorn Urtyp', 'https://world.openfoodfacts.org/product/4071800034508', '4071800034508'),
    ('Golden Toast', 'Vollkorn Toast', 'https://world.openfoodfacts.org/product/4009249022565', '4009249022565'),
    ('Harry', 'Harry 1688 Korn an Korn', 'https://world.openfoodfacts.org/product/4071800000824', '4071800000824'),
    ('Golden Toast', 'Buttertoast', 'https://world.openfoodfacts.org/product/4009249019916', '4009249019916'),
    ('Brandt', 'Der Markenzwieback', 'https://world.openfoodfacts.org/product/4013752019547', '4013752019547'),
    ('Gutes aus der Bäckerei', 'Weissbrot', 'https://world.openfoodfacts.org/product/4071800001081', '4071800001081'),
    ('Harry', 'Mischbrot Anno 1688 Klassisch, Harry', 'https://world.openfoodfacts.org/product/4071800052618', '4071800052618'),
    ('Goldähren', 'Dreisaatbrot - Roggenvollkornbrot', 'https://world.openfoodfacts.org/product/4061458054263', '4061458054263'),
    ('Golden Toast', 'Dinkel-Harmonie Sandwich', 'https://world.openfoodfacts.org/product/4009249038184', '4009249038184'),
    ('Filinchen', 'Das Knusperbrot Original', 'https://world.openfoodfacts.org/product/4015427111112', '4015427111112'),
    ('Goldähren', 'Saaten-Sandwich', 'https://world.openfoodfacts.org/product/4061458045827', '4061458045827'),
    ('Cucina', 'Pinsa', 'https://world.openfoodfacts.org/product/4061459712001', '4061459712001')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Bread' AND p.is_deprecated IS NOT TRUE;
