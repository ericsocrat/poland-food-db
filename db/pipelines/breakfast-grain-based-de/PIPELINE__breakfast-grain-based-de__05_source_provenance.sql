-- PIPELINE (Breakfast & Grain-Based): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Dr. Oetker', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'https://world.openfoodfacts.org/product/4000521662103', '4000521662103'),
    ('Kölln', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 'https://world.openfoodfacts.org/product/4000540003260', '4000540003260'),
    ('Kölln', 'Knusper Honig-Nuss Müsli', 'https://world.openfoodfacts.org/product/4000540023169', '4000540023169'),
    ('Dm', 'Bio Schokomüsli ohne Rosinen', 'https://world.openfoodfacts.org/product/4066447524413', '4066447524413'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'https://world.openfoodfacts.org/product/4000540003222', '4000540003222'),
    ('Kölln', 'Zartes Bircher Müsli', 'https://world.openfoodfacts.org/product/4000540011517', '4000540011517'),
    ('Seitenbacher', 'Kakao-Düsis', 'https://world.openfoodfacts.org/product/4008391212145', '4008391212145'),
    ('Dr. Oetker Vitalis', 'Vitalis Weniger süß Knusper Himbeere', 'https://world.openfoodfacts.org/product/4000521010423', '4000521010423'),
    ('Kölln', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 'https://world.openfoodfacts.org/product/4000540003130', '4000540003130'),
    ('Kölln', 'Hafer Müsli Beere Apfel', 'https://world.openfoodfacts.org/product/4000540001501', '4000540001501'),
    ('Dr. Oetker', 'Schoko Müsli klassisch', 'https://world.openfoodfacts.org/product/4000521041991', '4000521041991'),
    ('Dr. Oetker', 'Vitalis Knusper Schoko Müsli', 'https://world.openfoodfacts.org/product/4000521040628', '4000521040628'),
    ('Golden Bridge', 'Trauben-Nuss Müsli Vollkorn', 'https://world.openfoodfacts.org/product/4061464835504', '4061464835504'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli PLUS Nussmischung', 'https://world.openfoodfacts.org/product/4000521021894', '4000521021894'),
    ('Dr. Oetker', 'Vitalis Müsli Joghurt', 'https://world.openfoodfacts.org/product/4000521663407', '4000521663407'),
    ('Kölln', 'Crunchy Berry Hafer-Müsli', 'https://world.openfoodfacts.org/product/4000540003314', '4000540003314'),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 'https://world.openfoodfacts.org/product/4000540011364', '4000540011364'),
    ('Seitenbacher', 'Müsli 205 Für Sportliche', 'https://world.openfoodfacts.org/product/4008391008205', '4008391008205'),
    ('Dr. Oetker', 'Vitalis Knusper müsli Honeys', 'https://world.openfoodfacts.org/product/4000521661304', '4000521661304'),
    ('Golden Bridge', 'Schoko-Müsli mit 30 % weniger Zucker', 'https://world.openfoodfacts.org/product/4061464833838', '4061464833838'),
    ('Golden Bridge', 'Früchte-Müsli', 'https://world.openfoodfacts.org/product/4061464833845', '4061464833845'),
    ('DmBio', 'Beeren Müsli', 'https://world.openfoodfacts.org/product/4066447607567', '4066447607567'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli klassisch', 'https://world.openfoodfacts.org/product/4000521661205', '4000521661205'),
    ('Crownfield', 'Schoko Müsli', 'https://world.openfoodfacts.org/product/4056489255499', '4056489255499'),
    ('Dr. Oetker', 'Knusper Schoko Müsli', 'https://world.openfoodfacts.org/product/4000521040680', '4000521040680'),
    ('GUT Bio', 'Basis Müsli 5-Kornmix', 'https://world.openfoodfacts.org/product/4061464836297', '4061464836297'),
    ('Kölln', 'Crunchy Mango-Maracuja Hafer-Müsli', 'https://world.openfoodfacts.org/product/4000540003956', '4000540003956'),
    ('Aldi', 'Bio-Müsli - Urkorn-Früchte', 'https://world.openfoodfacts.org/product/4061459595079', '4061459595079'),
    ('Dr. Oetker', 'Müsli Schoko weniger süss', 'https://world.openfoodfacts.org/product/4000521041977', '4000521041977'),
    ('Kölln', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 'https://world.openfoodfacts.org/product/4000540043587', '4000540043587'),
    ('GUT bio', 'Bio Knusper-Müsli Schoko-Amaranth', 'https://world.openfoodfacts.org/product/4061458181266', '4061458181266'),
    ('Seitenbacher', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 'https://world.openfoodfacts.org/product/4008391041479', '4008391041479'),
    ('Golden Bridge', 'Früchte-Müsli Vollkorn', 'https://world.openfoodfacts.org/product/4061464835580', '4061464835580'),
    ('Kölln', 'Crunchy Hazel Hafer-Müsli', 'https://world.openfoodfacts.org/product/4000540003192', '4000540003192'),
    ('Kölln', 'Früchte Hafer-Müsli', 'https://world.openfoodfacts.org/product/4000540001341', '4000540001341'),
    ('Kölln kölln', 'Schoko Müsli', 'https://world.openfoodfacts.org/product/4000540053869', '4000540053869'),
    ('Kölln', 'Knusper Müsli', 'https://world.openfoodfacts.org/product/4000540003468', '4000540003468'),
    ('Kölln', 'Hafer Müsli', 'https://world.openfoodfacts.org/product/4000540063868', '4000540063868'),
    ('Kölln', 'Früchte Müsli ohne Zuckerzusatz', 'https://world.openfoodfacts.org/product/4000540001334', '4000540001334'),
    ('DmBio', 'Müsli Nuss', 'https://world.openfoodfacts.org/product/4067796057089', '4067796057089'),
    ('DmBio', 'Paleo Müsli', 'https://world.openfoodfacts.org/product/4067796066760', '4067796066760'),
    ('Golden Bridge', 'Premium Müsli', 'https://world.openfoodfacts.org/product/4061464835757', '4061464835757'),
    ('Dr. Oetker', 'Vitalis Müsli Knusper Schoko ohne Zuckerzusatz', 'https://world.openfoodfacts.org/product/4000521035686', '4000521035686'),
    ('DmBio', 'Basismüsli ohne Rosinen', 'https://world.openfoodfacts.org/product/4066447607598', '4066447607598'),
    ('Kölln', 'Knusper Schoko & Keks Müsli', 'https://world.openfoodfacts.org/product/4000540003246', '4000540003246'),
    ('Kölln', 'Knusper Joghurt Himbeer Müsli', 'https://world.openfoodfacts.org/product/4000540003567', '4000540003567'),
    ('Seitenbacher', 'Müsli 508 Dinos Frühstück', 'https://world.openfoodfacts.org/product/4008391051508', '4008391051508'),
    ('Dr. Oetker', 'Paula Müslispaß Schoko', 'https://world.openfoodfacts.org/product/4000521027032', '4000521027032'),
    ('DmBio', 'Früchte müsli', 'https://world.openfoodfacts.org/product/4066447524772', '4066447524772'),
    ('Bauck Mühle', 'Schoko+Flakes Hafer Müsli Bio', 'https://world.openfoodfacts.org/product/4015637018799', '4015637018799'),
    ('Brüggen', 'Schoko-Müsli', 'https://world.openfoodfacts.org/product/4061464833821', '4061464833821')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Breakfast & Grain-Based' AND p.is_deprecated IS NOT TRUE;
