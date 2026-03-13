-- PIPELINE (Plant-Based & Alternatives): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Plant-Based & Alternatives'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Pano', 'Wafle Ryżowe Wieloziarnisty', 'https://images.openfoodfacts.org/images/products/590/012/500/1508/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900125001508', 'front_5900125001508'),
    ('Pri', 'Ziemniaczki Już Gotowe z papryką', 'https://images.openfoodfacts.org/images/products/590/639/501/5344/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906395015344', 'front_5906395015344'),
    ('Go Vege', 'Parówki sojowe klasyczne', 'https://images.openfoodfacts.org/images/products/590/147/356/0303/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901473560303', 'front_5901473560303'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 'https://images.openfoodfacts.org/images/products/590/437/864/5595/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645595', 'front_5904378645595'),
    ('Basia', 'Mąka Tortowa Extra typ 405 Basia', 'https://images.openfoodfacts.org/images/products/590/202/016/3213/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902020163213', 'front_5902020163213'),
    ('Dobra-kaloria', 'Baton owocowy chrupiący orzech', 'https://images.openfoodfacts.org/images/products/590/354/800/2008/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903548002008', 'front_5903548002008'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'https://images.openfoodfacts.org/images/products/590/823/053/0753/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908230530753', 'front_5908230530753'),
    ('Złote Pola', 'Mąka tortowa pszenna. Typ 450', 'https://images.openfoodfacts.org/images/products/590/601/200/0852/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906012000852', 'front_5906012000852'),
    ('Sante', 'Otręby owsiane', 'https://images.openfoodfacts.org/images/products/590/061/700/2945/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617002945', 'front_5900617002945'),
    ('Sonko', 'Kasza jęczmienna perłowa', 'https://images.openfoodfacts.org/images/products/590/218/024/0106/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902180240106', 'front_5902180240106'),
    ('Pano', 'Wafle Kukurydziane sól morska', 'https://images.openfoodfacts.org/images/products/590/012/500/1478/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900125001478', 'front_5900125001478'),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 'https://images.openfoodfacts.org/images/products/590/076/600/0076/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900766000076', 'front_5900766000076'),
    ('Kupiec', 'Kasza manna błyskawiczna', 'https://images.openfoodfacts.org/images/products/590/217/200/0695/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902172000695', 'front_5902172000695'),
    ('GustoBello', 'Mąka do pizzy neapolitańskiej typ 00', 'https://images.openfoodfacts.org/images/products/590/718/031/5090/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180315090', 'front_5907180315090'),
    ('Uniflora', 'Kiełki rzodkiewki', 'https://images.openfoodfacts.org/images/products/590/777/144/3218/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907771443218', 'front_5907771443218'),
    ('Szczepanki', 'Mąka pszenna wrocławska typ 500', 'https://images.openfoodfacts.org/images/products/590/750/050/0014/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907500500014', 'front_5907500500014'),
    ('Pani', 'Wafle Prowansalskie', 'https://images.openfoodfacts.org/images/products/590/012/500/1485/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900125001485', 'front_5900125001485'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 'https://images.openfoodfacts.org/images/products/590/671/620/8707/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906716208707', 'front_5906716208707'),
    ('Madero', 'Chrzan tarty', 'https://images.openfoodfacts.org/images/products/590/464/500/1727/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904645001727', 'front_5904645001727'),
    ('Dawtona', 'Sűrített paradicsom', 'https://images.openfoodfacts.org/images/products/590/171/300/1245/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713001245', 'front_5901713001245'),
    ('Melvit', 'Natural Mix', 'https://images.openfoodfacts.org/images/products/590/682/701/8141/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906827018141', 'front_5906827018141'),
    ('Culineo', 'Koncentrat pomidorowy', 'https://images.openfoodfacts.org/images/products/590/171/302/0659/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713020659', 'front_5901713020659'),
    ('Wojan team', 'Wojanek', 'https://images.openfoodfacts.org/images/products/590/154/909/3483/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901549093483', 'front_5901549093483'),
    ('Pudliszki', 'Koncentrat pomidorowy', 'https://images.openfoodfacts.org/images/products/590/078/300/3968/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783003968', 'front_5900783003968'),
    ('Nasza Spiżarnia', 'Fasola czerwona', 'https://images.openfoodfacts.org/images/products/590/671/620/8042/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906716208042', 'front_5906716208042'),
    ('Dawtona', 'Koncentrat pomidorowy', 'https://images.openfoodfacts.org/images/products/590/171/301/6799/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713016799', 'front_5901713016799'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 'https://images.openfoodfacts.org/images/products/000/002/080/9539/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20809539', 'front_20809539'),
    ('GustoBello', 'Gnocchi Di Patate', 'https://images.openfoodfacts.org/images/products/590/754/413/2431/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907544132431', 'front_5907544132431'),
    ('Plony natury', 'Kasza manna', 'https://images.openfoodfacts.org/images/products/590/097/701/1595/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900977011595', 'front_5900977011595'),
    ('Culineo', 'Passata klasyczna', 'https://images.openfoodfacts.org/images/products/590/184/410/1685/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901844101685', 'front_5901844101685'),
    ('Anecoop', 'Włoszczyzna', 'https://images.openfoodfacts.org/images/products/000/002/035/5968/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20355968', 'front_20355968'),
    ('Vemondo', 'Tofu wędzone', 'https://images.openfoodfacts.org/images/products/405/648/971/7607/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489717607', 'front_4056489717607'),
    ('El Toro Rojo', 'Oliwki zielone nadziewane pastą paprykową', 'https://images.openfoodfacts.org/images/products/841/013/402/6876/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8410134026876', 'front_8410134026876'),
    ('Janex', 'Kasza Gryczana', 'https://images.openfoodfacts.org/images/products/590/826/710/0073/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908267100073', 'front_5908267100073'),
    ('Go Vege', 'Tofu Naturalne', 'https://images.openfoodfacts.org/images/products/858/602/442/2537/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 8586024422537', 'front_8586024422537'),
    ('Go VEGE', 'Tofu sweet chili', 'https://images.openfoodfacts.org/images/products/858/602/442/0113/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8586024420113', 'front_8586024420113'),
    ('Lidl', 'Avocados', 'https://images.openfoodfacts.org/images/products/000/002/022/9030/front_en.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 20229030', 'front_20229030'),
    ('Kania', 'Crispy Fried Onions', 'https://images.openfoodfacts.org/images/products/000/002/017/3074/front_en.258.400.jpg', 'off_api', 'front', true, 'Front — EAN 20173074', 'front_20173074'),
    ('Vemondo', 'Tofu plain', 'https://images.openfoodfacts.org/images/products/405/648/952/9712/front_pl.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489529712', 'front_4056489529712'),
    ('Vemondo', 'Tofu naturalne', 'https://images.openfoodfacts.org/images/products/405/648/906/7566/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489067566', 'front_4056489067566'),
    ('K-take it veggie', 'Tofu natur eco', 'https://images.openfoodfacts.org/images/products/433/589/675/0729/front_ro.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335896750729', 'front_4335896750729'),
    ('GustoBello', 'Polpa di pomodoro', 'https://images.openfoodfacts.org/images/products/800/292/001/6675/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8002920016675', 'front_8002920016675'),
    ('Garden Gourmet', 'Veggie Balls', 'https://images.openfoodfacts.org/images/products/844/529/049/3125/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8445290493125', 'front_8445290493125'),
    ('Vemondo', 'Tofu', 'https://images.openfoodfacts.org/images/products/405/648/971/7591/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489717591', 'front_4056489717591'),
    ('Tastino', 'Wafle Kukurydziane', 'https://images.openfoodfacts.org/images/products/405/648/958/7026/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489587026', 'front_4056489587026'),
    ('Crownfield', 'Owsianka Truskawkowa', 'https://images.openfoodfacts.org/images/products/405/648/906/4503/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489064503', 'front_4056489064503'),
    ('Bakello', 'Ciasto francuskie', 'https://images.openfoodfacts.org/images/products/400/116/311/1929/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163111929', 'front_4001163111929'),
    ('Violife', 'Cheddar flavour slices', 'https://images.openfoodfacts.org/images/products/520/239/002/3576/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5202390023576', 'front_5202390023576'),
    ('Nasza Spiżarnia', 'Ananas Plastry', 'https://images.openfoodfacts.org/images/products/843/549/339/8006/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8435493398006', 'front_8435493398006'),
    ('Unknown', 'Awokado hass', 'https://images.openfoodfacts.org/images/products/871/235/526/3178/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712355263178', 'front_8712355263178')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
