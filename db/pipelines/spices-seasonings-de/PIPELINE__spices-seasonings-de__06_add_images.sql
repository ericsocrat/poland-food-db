-- PIPELINE (Spices & Seasonings): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Spices & Seasonings'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Farmer''s Snack', 'Südsee-Ingwer', 'https://images.openfoodfacts.org/images/products/401/044/242/1154/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4010442421154', 'front_4010442421154'),
    ('Kania', 'Würzlinge Kräuter Italienische Art', 'https://images.openfoodfacts.org/images/products/405/648/914/3215/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489143215', 'front_4056489143215'),
    ('Nestlé', 'Würzmischung Nr. 1, Gebratenes Fleisch', 'https://images.openfoodfacts.org/images/products/400/550/002/7843/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500027843', 'front_4005500027843'),
    ('Ostmann', 'Kreuzkümmel (Cumin)', 'https://images.openfoodfacts.org/images/products/400/267/404/1910/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674041910', 'front_4002674041910'),
    ('Hügli Nahrungsmittel GmbH', 'Gewürzmischung Ofen-Gemüse (Bio)', 'https://images.openfoodfacts.org/images/products/400/034/509/6351/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000345096351', 'front_4000345096351'),
    ('Ostmann', 'Paprika edelsüß', 'https://images.openfoodfacts.org/images/products/400/267/404/4072/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674044072', 'front_4002674044072'),
    ('Fuchs-Gruppe', 'Lebkuchengewürz', 'https://images.openfoodfacts.org/images/products/400/267/412/3418/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674123418', 'front_4002674123418'),
    ('Kania', 'Spice your Slice- würzmischung', 'https://images.openfoodfacts.org/images/products/405/648/982/2103/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489822103', 'front_4056489822103'),
    ('Dittmann', 'Pfeffer, Eingelegter Grüner Pfeffer', 'https://images.openfoodfacts.org/images/products/400/223/938/5008/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002239385008', 'front_4002239385008'),
    ('Le Gusto', 'Pfeffermühle mit Keramikmahlwerk - Pariser Pfeffer', 'https://images.openfoodfacts.org/images/products/406/145/809/0636/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458090636', 'front_4061458090636'),
    ('Le Gusto', 'Pfeffermühle mit Keramikmahlwerk - Steakpfeffer', 'https://images.openfoodfacts.org/images/products/406/145/809/0629/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458090629', 'front_4061458090629'),
    ('Feinkost Dittmann', 'Grüne Jalapeño Pfefferonen', 'https://images.openfoodfacts.org/images/products/400/223/963/9705/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002239639705', 'front_4002239639705'),
    ('Gewürze', 'Gewürzmischung 4', 'https://images.openfoodfacts.org/images/products/400/550/002/7898/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500027898', 'front_4005500027898'),
    ('Block House', 'Zauber Gewürz', 'https://images.openfoodfacts.org/images/products/400/928/615/0894/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009286150894', 'front_4009286150894'),
    ('Kania', 'Pommes Würzsalz', 'https://images.openfoodfacts.org/images/products/405/648/967/6171/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489676171', 'front_4056489676171'),
    ('Lebensbaum', 'Gewürzmischung Thai-Curry', 'https://images.openfoodfacts.org/images/products/401/234/617/2804/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012346172804', 'front_4012346172804'),
    ('Ostmann', 'Steak Gewürzsalz', 'https://images.openfoodfacts.org/images/products/400/267/424/5516/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674245516', 'front_4002674245516'),
    ('Ostmann', 'China Gewürz', 'https://images.openfoodfacts.org/images/products/400/267/404/1637/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674041637', 'front_4002674041637'),
    ('Grillmeister', 'Gewürzmischung BBQ Steakpfeffer', 'https://images.openfoodfacts.org/images/products/405/648/903/2243/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489032243', 'front_4056489032243'),
    ('Kluth', 'Ingwerstücke', 'https://images.openfoodfacts.org/images/products/400/808/805/0500/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008088050500', 'front_4008088050500'),
    ('Fuego', 'EDEKA GEWÜRZE Fuchs-Gruppe Fuego Fajita Seasoning Mix Verbesserte Rezeptur Vegan ohne Geschmacksverstärker und ohne PalmölB. 1.79€ 0.03 kg Beutel. 59.67€ 1kg', 'https://images.openfoodfacts.org/images/products/400/755/231/0881/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4007552310881', 'front_4007552310881'),
    ('Ostmann', 'Zimt gemahlen', 'https://images.openfoodfacts.org/images/products/400/267/404/6151/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674046151', 'front_4002674046151'),
    ('Ostmann', 'Oregano', 'https://images.openfoodfacts.org/images/products/400/267/404/3952/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674043952', 'front_4002674043952'),
    ('Aldi', 'Vanilleextrakt-Zubereitung Bio-Bourbon', 'https://images.openfoodfacts.org/images/products/406/145/972/8460/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459728460', 'front_4061459728460'),
    ('Le Gusto', 'Curry Pulver', 'https://images.openfoodfacts.org/images/products/406/145/801/8968/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458018968', 'front_4061458018968'),
    ('Bionade', 'Ingwer-Orange', 'https://images.openfoodfacts.org/images/products/401/447/200/2529/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014472002529', 'front_4014472002529'),
    ('Dr. Oetker', 'Zitronenschale', 'https://images.openfoodfacts.org/images/products/400/052/102/6110/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521026110', 'front_4000521026110'),
    ('Kühne', 'Jalapeños', 'https://images.openfoodfacts.org/images/products/000/004/012/2915/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 40122915', 'front_40122915'),
    ('Just Spices', 'Hähnchen Allrounder', 'https://images.openfoodfacts.org/images/products/426/040/117/4465/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260401174465', 'front_4260401174465'),
    ('Kania', 'Bio Curry', 'https://images.openfoodfacts.org/images/products/405/648/911/3737/front_fr.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489113737', 'front_4056489113737'),
    ('Rio d''oro', 'Bio ingwer', 'https://images.openfoodfacts.org/images/products/404/724/759/0853/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247590853', 'front_4047247590853'),
    ('DmBio', 'Ingwersaft', 'https://images.openfoodfacts.org/images/products/405/817/222/7707/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172227707', 'front_4058172227707'),
    ('Gut&günstig', 'Grüne Peperoni', 'https://images.openfoodfacts.org/images/products/431/150/173/8221/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501738221', 'front_4311501738221'),
    ('BioWagner', 'Zimt gemahlen', 'https://images.openfoodfacts.org/images/products/404/916/412/4913/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4049164124913', 'front_4049164124913'),
    ('Block House', 'Steak Pfeffer', 'https://images.openfoodfacts.org/images/products/400/928/612/1542/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009286121542', 'front_4009286121542'),
    ('Ostmann', 'Paprika Rosenscharf', 'https://images.openfoodfacts.org/images/products/400/267/404/4119/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002674044119', 'front_4002674044119'),
    ('Feinkost Dittmann', 'Pfefferonen', 'https://images.openfoodfacts.org/images/products/400/223/985/4504/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002239854504', 'front_4002239854504'),
    ('Just Spices', 'Gemüse Allrounder', 'https://images.openfoodfacts.org/images/products/426/044/609/8276/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260446098276', 'front_4260446098276'),
    ('Aldi', 'Hi! Spice - Stullengenie', 'https://images.openfoodfacts.org/images/products/406/146/497/3671/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464973671', 'front_4061464973671'),
    ('Fuego', 'Fuego Taco Seasoning Mix', 'https://images.openfoodfacts.org/images/products/400/755/231/0843/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4007552310843', 'front_4007552310843'),
    ('Unknown', 'Vanille Extract', 'https://images.openfoodfacts.org/images/products/402/250/013/7617/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4022500137617', 'front_4022500137617'),
    ('Belbake', 'Bourbon-Vanillepaste', 'https://images.openfoodfacts.org/images/products/405/648/988/6358/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489886358', 'front_4056489886358'),
    ('Kania', 'Mélanges épices sandwich', 'https://images.openfoodfacts.org/images/products/405/648/990/8500/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489908500', 'front_4056489908500'),
    ('Kclassic', 'Sushi Ingwer', 'https://images.openfoodfacts.org/images/products/401/032/130/7685/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4010321307685', 'front_4010321307685'),
    ('Kühne', 'Peperoni mild', 'https://images.openfoodfacts.org/images/products/000/004/080/4378/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 40804378', 'front_40804378'),
    ('Ankerkraut', 'Rührei Mix Gewürz', 'https://images.openfoodfacts.org/images/products/426/034/789/6827/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260347896827', 'front_4260347896827'),
    ('Ruf', 'Gourmet Vanille-Extrakt', 'https://images.openfoodfacts.org/images/products/000/004/035/2602/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 40352602', 'front_40352602'),
    ('1001 delights', 'Gewürz, Ras el Hanout', 'https://images.openfoodfacts.org/images/products/000/002/084/0013/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 20840013', 'front_20840013'),
    ('Pickerd', 'Zimt Paste', 'https://images.openfoodfacts.org/images/products/402/250/013/8935/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4022500138935', 'front_4022500138935'),
    ('Kania', 'Knoblauch granuliert', 'https://images.openfoodfacts.org/images/products/405/648/922/2859/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489222859', 'front_4056489222859'),
    ('Aldi', 'Bio-Kurkumapulver', 'https://images.openfoodfacts.org/images/products/406/145/819/7687/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458197687', 'front_4061458197687'),
    ('Kania', 'Fix fur salatsauce', 'https://images.openfoodfacts.org/images/products/405/648/949/7110/front_fr.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489497110', 'front_4056489497110'),
    ('Rewe Beste Wahl', 'Paprika geräuchert', 'https://images.openfoodfacts.org/images/products/433/725/626/3344/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256263344', 'front_4337256263344'),
    ('DmBio', 'Bourbon Vanille', 'https://images.openfoodfacts.org/images/products/405/817/292/5122/front_it.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172925122', 'front_4058172925122'),
    ('Just spices', 'Bratkartoffel Gewürz', 'https://images.openfoodfacts.org/images/products/426/040/117/4496/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260401174496', 'front_4260401174496'),
    ('Sonnentor', 'Das Beste für Reste', 'https://images.openfoodfacts.org/images/products/900/414/500/6492/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 9004145006492', 'front_9004145006492'),
    ('Kania', 'Kreuzkümmel', 'https://images.openfoodfacts.org/images/products/433/561/916/1931/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619161931', 'front_4335619161931'),
    ('Just Spices', 'Kräuter Quark Gewürz', 'https://images.openfoodfacts.org/images/products/426/040/117/3895/front_fr.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260401173895', 'front_4260401173895'),
    ('Maggi', 'Fix Jäger-Sahne Schnitzel', 'https://images.openfoodfacts.org/images/products/761/328/735/3870/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613287353870', 'front_7613287353870'),
    ('Gefro', 'Gewürz-Pfeffer', 'https://images.openfoodfacts.org/images/products/425/058/970/2123/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250589702123', 'front_4250589702123'),
    ('Sonnentor', 'Sonnentor Gewürzblüten', 'https://images.openfoodfacts.org/images/products/900/414/500/3774/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 9004145003774', 'front_9004145003774'),
    ('Lee Kum Kee', 'Premium-Pilz-Würzpulver', 'https://images.openfoodfacts.org/images/products/007/889/516/0468/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 0078895160468', 'front_0078895160468'),
    ('Rewe', 'Jalapenos', 'https://images.openfoodfacts.org/images/products/433/725/666/9825/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256669825', 'front_4337256669825'),
    ('Kania', 'Persillade provençale', 'https://images.openfoodfacts.org/images/products/000/002/022/6572/front_fr.95.400.jpg', 'off_api', 'front', true, 'Front — EAN 20226572', 'front_20226572'),
    ('Edeka', 'Pfefferonen griechisch', 'https://images.openfoodfacts.org/images/products/431/150/161/1180/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501611180', 'front_4311501611180'),
    ('Taylor & Colledge', 'Bourbon Bio-Vanille extrakt', 'https://images.openfoodfacts.org/images/products/930/064/100/3103/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 9300641003103', 'front_9300641003103'),
    ('Backfee', 'Vanillepaste', 'https://images.openfoodfacts.org/images/products/000/004/243/6195/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 42436195', 'front_42436195'),
    ('Vitasia', 'Ingwer eingelegt', 'https://images.openfoodfacts.org/images/products/433/561/911/4142/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619114142', 'front_4335619114142'),
    ('Gut & Günstig', 'Pfeffer schwarz', 'https://images.openfoodfacts.org/images/products/431/150/143/5779/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501435779', 'front_4311501435779'),
    ('Kania', 'Oignons', 'https://images.openfoodfacts.org/images/products/000/002/089/2319/front_fr.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 20892319', 'front_20892319'),
    ('Unknown', 'Bolognese Gewürz', 'https://images.openfoodfacts.org/images/products/426/043/167/3730/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260431673730', 'front_4260431673730'),
    ('Rewe Bio', 'Zitronenschale gerieben', 'https://images.openfoodfacts.org/images/products/433/725/656/2638/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256562638', 'front_4337256562638'),
    ('1001 delights', 'Gewürz, Couscous', 'https://images.openfoodfacts.org/images/products/000/002/084/0037/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 20840037', 'front_20840037'),
    ('Beltane Naturkost GmbH', 'Biofix Gebratene Nudeln (Bami Goreng)', 'https://images.openfoodfacts.org/images/products/426/013/314/1353/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260133141353', 'front_4260133141353'),
    ('Just Spices', 'Stullen Spice', 'https://images.openfoodfacts.org/images/products/426/043/167/2467/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260431672467', 'front_4260431672467'),
    ('Vitasia Lidl', 'Sushi Ingwer', 'https://images.openfoodfacts.org/images/products/433/561/911/4159/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619114159', 'front_4335619114159'),
    ('Just Spices', 'Avocado Toppimg', 'https://images.openfoodfacts.org/images/products/426/043/167/1026/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260431671026', 'front_4260431671026'),
    ('Lebepur', 'Kurkuma Shot', 'https://images.openfoodfacts.org/images/products/426/015/945/5519/front_fr.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260159455519', 'front_4260159455519'),
    ('The Coca-Cola Company', 'Cola Vanille', 'https://images.openfoodfacts.org/images/products/500/011/268/2205/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000112682205', 'front_5000112682205'),
    ('Alnatura', 'Gelbe Linse Kurkuma Aufstrich', 'https://images.openfoodfacts.org/images/products/410/442/021/9144/front_en.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420219144', 'front_4104420219144'),
    ('Just Spices', 'Italian allrounder', 'https://images.openfoodfacts.org/images/products/426/040/117/5004/front_fr.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260401175004', 'front_4260401175004'),
    ('Suntat', 'Jalapeno Scharf', 'https://images.openfoodfacts.org/images/products/869/080/402/8519/front_fr.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 8690804028519', 'front_8690804028519'),
    ('Gefro', 'Bella italia', 'https://images.openfoodfacts.org/images/products/425/058/970/1775/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250589701775', 'front_4250589701775'),
    ('Ducros', 'Curry Madras', 'https://images.openfoodfacts.org/images/products/426/040/117/5301/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260401175301', 'front_4260401175301'),
    ('Gefro', 'Mexiko Chili', 'https://images.openfoodfacts.org/images/products/425/058/970/1812/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250589701812', 'front_4250589701812'),
    ('Bissfest', 'Pasta Konfetti', 'https://images.openfoodfacts.org/images/products/426/075/783/0596/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260757830596', 'front_4260757830596'),
    ('Beltane', 'Biofix Spaghetti Bolognese', 'https://images.openfoodfacts.org/images/products/426/013/314/1131/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260133141131', 'front_4260133141131'),
    ('Batts', 'Chilimauste', 'https://images.openfoodfacts.org/images/products/000/002/043/7817/front_en.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 20437817', 'front_20437817'),
    ('Knorr', 'Broccoli Gratin', 'https://images.openfoodfacts.org/images/products/871/716/393/5187/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 8717163935187', 'front_8717163935187'),
    ('Gefro', 'Gefro Curry Indisch Bio', 'https://images.openfoodfacts.org/images/products/425/058/970/1799/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250589701799', 'front_4250589701799'),
    ('Just Spices', 'Kartoffel Allrounder', 'https://images.openfoodfacts.org/images/products/426/043/167/3297/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260431673297', 'front_4260431673297'),
    ('Vegeta', 'Vegeta', 'https://images.openfoodfacts.org/images/products/385/010/404/7046/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 3850104047046', 'front_3850104047046'),
    ('Gefro', 'Gefro Bella Italia', 'https://images.openfoodfacts.org/images/products/425/058/970/2246/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250589702246', 'front_4250589702246'),
    ('Beltane', 'Biofix', 'https://images.openfoodfacts.org/images/products/426/013/314/1889/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260133141889', 'front_4260133141889'),
    ('Santa maria', 'Fajita', 'https://images.openfoodfacts.org/images/products/731/131/031/3678/front_fr.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 7311310313678', 'front_7311310313678'),
    ('Suntat', 'Scharfe Chiliflocken', 'https://images.openfoodfacts.org/images/products/869/080/402/5310/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 8690804025310', 'front_8690804025310'),
    ('Ankerkraut', 'Chili con Carne Mild Ankerkraut', 'https://images.openfoodfacts.org/images/products/426/034/789/0290/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260347890290', 'front_4260347890290'),
    ('Podravka', 'Vegeta', 'https://images.openfoodfacts.org/images/products/385/010/421/6466/front_fr.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 3850104216466', 'front_3850104216466')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spices & Seasonings' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
