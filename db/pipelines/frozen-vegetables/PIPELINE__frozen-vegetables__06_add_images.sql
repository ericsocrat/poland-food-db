-- PIPELINE (Frozen Vegetables): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Frozen Vegetables'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Hortex', 'Warzywa na patelnię', 'https://images.openfoodfacts.org/images/products/590/047/700/0846/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477000846', 'front_5900477000846'),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 'https://images.openfoodfacts.org/images/products/590/158/123/2413/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901581232413', 'front_5901581232413'),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 'https://images.openfoodfacts.org/images/products/590/158/123/2352/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901581232352', 'front_5901581232352'),
    ('Hortex', 'Warzywa na patelnię z przyprawą włoską', 'https://images.openfoodfacts.org/images/products/590/047/700/0853/front_pl.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477000853', 'front_5900477000853'),
    ('Mroźna Kraina', 'Szpinak w liściach, porcjowany', 'https://images.openfoodfacts.org/images/products/590/102/891/6586/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028916586', 'front_5901028916586'),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 'https://images.openfoodfacts.org/images/products/590/097/201/0647/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900972010647', 'front_5900972010647'),
    ('Hortex', 'Warzywa na patelnię ze szpinakiem', 'https://images.openfoodfacts.org/images/products/590/047/701/4027/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477014027', 'front_5900477014027'),
    ('Mroźna Kraina', 'Brokuły różyczki', 'https://images.openfoodfacts.org/images/products/590/158/121/0176/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901581210176', 'front_5901581210176'),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po hiszpańsku&quot;', 'https://images.openfoodfacts.org/images/products/590/102/891/3554/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913554', 'front_5901028913554'),
    ('Hortex', 'Warzywa Na Patelnię Z Koperkiem', 'https://images.openfoodfacts.org/images/products/590/047/700/3632/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477003632', 'front_5900477003632'),
    ('Mroźna Kraina', 'Fasola szparagowa cięta Mroźna Kraina', 'https://images.openfoodfacts.org/images/products/590/315/454/9829/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903154549829', 'front_5903154549829'),
    ('Mroźna Kraina', 'Jagody leśne', 'https://images.openfoodfacts.org/images/products/590/296/600/9002/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902966009002', 'front_5902966009002'),
    ('Mroźna Kraina', 'Borówka', 'https://images.openfoodfacts.org/images/products/590/102/891/7507/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917507', 'front_5901028917507'),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 'https://images.openfoodfacts.org/images/products/590/102/890/8055/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028908055', 'front_5901028908055'),
    ('Asia Flavours', 'Mieszanka Chińska', 'https://images.openfoodfacts.org/images/products/590/102/891/8948/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028918948', 'front_5901028918948'),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 'https://images.openfoodfacts.org/images/products/590/102/891/6616/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028916616', 'front_5901028916616'),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 'https://images.openfoodfacts.org/images/products/590/315/454/2622/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903154542622', 'front_5903154542622'),
    ('Mroźna Kraina', 'Warzywa na patelnię po grecku', 'https://images.openfoodfacts.org/images/products/590/315/454/2615/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903154542615', 'front_5903154542615'),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 'https://images.openfoodfacts.org/images/products/590/102/891/7972/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917972', 'front_5901028917972'),
    ('Poltino', 'Danie chińskie', 'https://images.openfoodfacts.org/images/products/590/743/138/9788/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907431389788', 'front_5907431389788'),
    ('Mroźna Kraina', 'Kalafior różyczki', 'https://images.openfoodfacts.org/images/products/590/102/891/7422/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917422', 'front_5901028917422'),
    ('Mroźna kraina', 'Warzywa na patelnię po turecku', 'https://images.openfoodfacts.org/images/products/590/102/891/3325/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913325', 'front_5901028913325'),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 'https://images.openfoodfacts.org/images/products/590/102/891/3479/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913479', 'front_5901028913479'),
    ('Agram', 'Szpinak liście', 'https://images.openfoodfacts.org/images/products/590/296/600/0337/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902966000337', 'front_5902966000337'),
    ('Mroźna Kraina', 'Warzywa na patelnię po azjatycku', 'https://images.openfoodfacts.org/images/products/590/102/891/3349/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913349', 'front_5901028913349'),
    ('Hortex', 'Szpinak liście', 'https://images.openfoodfacts.org/images/products/590/047/700/3267/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477003267', 'front_5900477003267'),
    ('Unknown', 'Jagody leśne', 'https://images.openfoodfacts.org/images/products/590/102/891/5541/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028915541', 'front_5901028915541'),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 'https://images.openfoodfacts.org/images/products/590/102/891/7378/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917378', 'front_5901028917378'),
    ('Hortex', 'Maliny mrożone', 'https://images.openfoodfacts.org/images/products/590/047/701/3747/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477013747', 'front_5900477013747'),
    ('Mroźna Kraina', 'Mieszanka wiosenna', 'https://images.openfoodfacts.org/images/products/590/102/891/5558/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028915558', 'front_5901028915558'),
    ('Hortex', 'Warzywa na patelnie', 'https://images.openfoodfacts.org/images/products/590/047/700/0839/front_pl.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477000839', 'front_5900477000839'),
    ('Hortex', 'Bukiet warzyw kwiatowy', 'https://images.openfoodfacts.org/images/products/590/047/700/0754/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477000754', 'front_5900477000754'),
    ('Mroźna kraina', 'Szpinak rozdrobniony porcjowany', 'https://images.openfoodfacts.org/images/products/590/743/138/9795/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907431389795', 'front_5907431389795'),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 'https://images.openfoodfacts.org/images/products/590/102/891/3103/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913103', 'front_5901028913103'),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po indyjsku&quot;', 'https://images.openfoodfacts.org/images/products/590/102/891/3592/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913592', 'front_5901028913592'),
    ('Mroźna kraina', 'Warzywa na patelnie', 'https://images.openfoodfacts.org/images/products/590/102/891/3387/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028913387', 'front_5901028913387'),
    ('Mroźna Kraina', 'Groszek zielony', 'https://images.openfoodfacts.org/images/products/590/102/891/7415/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917415', 'front_5901028917415'),
    ('Iglote', 'Warzywa na patelnię po włosku', 'https://images.openfoodfacts.org/images/products/590/216/234/5614/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162345614', 'front_5902162345614'),
    ('Iglotex', 'Warzywa na patelnię klasyczne', 'https://images.openfoodfacts.org/images/products/590/216/234/5416/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162345416', 'front_5902162345416'),
    ('Proste Historie', 'Mieszanka Chińska', 'https://images.openfoodfacts.org/images/products/590/216/234/7618/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162347618', 'front_5902162347618'),
    ('Mroźna Kraina', 'Marchew mini', 'https://images.openfoodfacts.org/images/products/590/102/891/8634/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028918634', 'front_5901028918634'),
    ('Mroźna Kraina', 'Brzoskwinia', 'https://images.openfoodfacts.org/images/products/590/102/891/7521/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028917521', 'front_5901028917521'),
    ('Harvest Best', 'Zupa jarzynowa', 'https://images.openfoodfacts.org/images/products/590/152/908/3206/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901529083206', 'front_5901529083206'),
    ('Harvest Best', 'Zupa kalafiorowa', 'https://images.openfoodfacts.org/images/products/590/152/908/3244/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901529083244', 'front_5901529083244'),
    ('Mroźna Kraina', 'Zupa jarzynowa', 'https://images.openfoodfacts.org/images/products/590/315/454/8730/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903154548730', 'front_5903154548730'),
    ('Proste Historie', 'Chopped spinach', 'https://images.openfoodfacts.org/images/products/590/216/200/1008/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162001008', 'front_5902162001008'),
    ('Hortex', 'Mieszanka Azjatycka', 'https://images.openfoodfacts.org/images/products/590/047/701/7158/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477017158', 'front_5900477017158'),
    ('Mroźna Kraina', 'Marchewka z groszkiem', 'https://images.openfoodfacts.org/images/products/590/158/121/1173/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901581211173', 'front_5901581211173'),
    ('Mroźna Kraina', 'Ananas', 'https://images.openfoodfacts.org/images/products/590/102/891/5442/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901028915442', 'front_5901028915442'),
    ('Lidl', 'Warzywa Na Patelnię Z Ziemniakami', 'https://images.openfoodfacts.org/images/products/405/648/988/1032/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489881032', 'front_4056489881032'),
    ('Freshona', 'Warzywa mrożone po hiszpańsku', 'https://images.openfoodfacts.org/images/products/000/002/086/0028/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 20860028', 'front_20860028'),
    ('World of Taste', '7 - Vegetables Mix', 'https://images.openfoodfacts.org/images/products/590/216/200/0988/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162000988', 'front_5902162000988'),
    ('Nordis', 'Warzywa na payelnie premium', 'https://images.openfoodfacts.org/images/products/590/048/800/2419/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900488002419', 'front_5900488002419'),
    ('Kuchnia Eksperta', 'Frozen spinach', 'https://images.openfoodfacts.org/images/products/590/316/100/0146/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903161000146', 'front_5903161000146'),
    ('Hortex', 'Stir-Fry Vegetables With Oriental Seasoning', 'https://images.openfoodfacts.org/images/products/590/047/700/0525/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477000525', 'front_5900477000525'),
    ('Hortex', 'Broccoli And Cauliflower Mix', 'https://images.openfoodfacts.org/images/products/590/047/701/8131/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477018131', 'front_5900477018131'),
    ('Mroźna kraina', 'Spinach', 'https://images.openfoodfacts.org/images/products/590/743/138/0549/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907431380549', 'front_5907431380549'),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'https://images.openfoodfacts.org/images/products/405/648/935/9593/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489359593', 'front_4056489359593'),
    ('Freshona', 'Mix zeleniny na čínský způsob', 'https://images.openfoodfacts.org/images/products/000/002/011/3384/front_cs.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 20113384', 'front_20113384'),
    ('Harvest Best', 'Wok mix', 'https://images.openfoodfacts.org/images/products/571/287/300/3389/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5712873003389', 'front_5712873003389'),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', 'https://images.openfoodfacts.org/images/products/308/368/083/6371/front_fr.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 3083680836371', 'front_3083680836371'),
    ('Carrefour', 'Haricots Verts Très Fins', 'https://images.openfoodfacts.org/images/products/356/007/044/4373/front_fr.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070444373', 'front_3560070444373'),
    ('Carrefour', 'CHOUX-FLEURS En fleurette', 'https://images.openfoodfacts.org/images/products/356/007/055/2498/front_fr.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070552498', 'front_3560070552498'),
    ('Spar', 'Guisantes finos', 'https://images.openfoodfacts.org/images/products/848/001/320/0291/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8480013200291', 'front_8480013200291'),
    ('Tesco', 'Mix mražené zeleniny', 'https://images.openfoodfacts.org/images/products/505/100/711/2000/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5051007112000', 'front_5051007112000'),
    ('Freshona', 'Berry Mix with Sour Cherries', 'https://images.openfoodfacts.org/images/products/000/002/013/0596/front_en.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 20130596', 'front_20130596'),
    ('Lidl', 'Szpinak Rozdrobniony W Porcjach', 'https://images.openfoodfacts.org/images/products/405/648/988/0516/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489880516', 'front_4056489880516'),
    ('Freshona', 'Fasolka szparagowa zielona', 'https://images.openfoodfacts.org/images/products/405/648/978/4845/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489784845', 'front_4056489784845'),
    ('Bonduelle', 'Špenátové listy', 'https://images.openfoodfacts.org/images/products/308/368/106/0041/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 3083681060041', 'front_3083681060041'),
    ('Bonduelle', 'Thailand Mix With Rice Frozen', 'https://images.openfoodfacts.org/images/products/308/368/114/4109/front_lt.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3083681144109', 'front_3083681144109'),
    ('Freshona', 'Groszek zielony', 'https://images.openfoodfacts.org/images/products/405/648/978/4838/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489784838', 'front_4056489784838'),
    ('Bonduelle', 'Croustis Original Brocolis 305g', 'https://images.openfoodfacts.org/images/products/308/368/114/7834/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 3083681147834', 'front_3083681147834'),
    ('Unknown', '10 Légumes POUR Minestrone', 'https://images.openfoodfacts.org/images/products/356/007/044/4366/front_fr.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070444366', 'front_3560070444366'),
    ('Freshona', 'Marchew z groszkiem', 'https://images.openfoodfacts.org/images/products/000/002/098/2959/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 20982959', 'front_20982959'),
    ('Bonduelle restauration', 'Snap peas', 'https://images.openfoodfacts.org/images/products/308/368/001/4601/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3083680014601', 'front_3083680014601'),
    ('Douceur du Verger', 'Framboises entières', 'https://images.openfoodfacts.org/images/products/356/470/045/7320/front_fr.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 3564700457320', 'front_3564700457320'),
    ('Freshona', 'Mixed vegetables Californian style', 'https://images.openfoodfacts.org/images/products/405/648/944/7832/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489447832', 'front_4056489447832')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Frozen Vegetables' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
