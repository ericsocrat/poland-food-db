-- PIPELINE (Plant-Based & Alternatives): source provenance
-- Generated: 2026-03-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Pano', 'Wafle Ryżowe Wieloziarnisty', 'https://world.openfoodfacts.org/product/5900125001508', '5900125001508'),
    ('Pri', 'Ziemniaczki Już Gotowe z papryką', 'https://world.openfoodfacts.org/product/5906395015344', '5906395015344'),
    ('Go Vege', 'Parówki sojowe klasyczne', 'https://world.openfoodfacts.org/product/5901473560303', '5901473560303'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 'https://world.openfoodfacts.org/product/5904378645595', '5904378645595'),
    ('Basia', 'Mąka Tortowa Extra typ 405 Basia', 'https://world.openfoodfacts.org/product/5902020163213', '5902020163213'),
    ('Dobra-kaloria', 'Baton owocowy chrupiący orzech', 'https://world.openfoodfacts.org/product/5903548002008', '5903548002008'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'https://world.openfoodfacts.org/product/5908230530753', '5908230530753'),
    ('Złote Pola', 'Mąka tortowa pszenna. Typ 450', 'https://world.openfoodfacts.org/product/5906012000852', '5906012000852'),
    ('Sante', 'Otręby owsiane', 'https://world.openfoodfacts.org/product/5900617002945', '5900617002945'),
    ('Sonko', 'Kasza jęczmienna perłowa', 'https://world.openfoodfacts.org/product/5902180240106', '5902180240106'),
    ('Pano', 'Wafle Kukurydziane sól morska', 'https://world.openfoodfacts.org/product/5900125001478', '5900125001478'),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 'https://world.openfoodfacts.org/product/5900766000076', '5900766000076'),
    ('Kupiec', 'Kasza manna błyskawiczna', 'https://world.openfoodfacts.org/product/5902172000695', '5902172000695'),
    ('GustoBello', 'Mąka do pizzy neapolitańskiej typ 00', 'https://world.openfoodfacts.org/product/5907180315090', '5907180315090'),
    ('PZZ Kraków', 'Mąka pszenna tortowa', 'https://world.openfoodfacts.org/product/5904142000018', '5904142000018'),
    ('Uniflora', 'Kiełki rzodkiewki', 'https://world.openfoodfacts.org/product/5907771443218', '5907771443218'),
    ('Szczepanki', 'Mąka pszenna wrocławska typ 500', 'https://world.openfoodfacts.org/product/5907500500014', '5907500500014'),
    ('Unknown', 'Kasza gryczana prażona', 'https://world.openfoodfacts.org/product/5906827022605', '5906827022605'),
    ('Pani', 'Wafle Prowansalskie', 'https://world.openfoodfacts.org/product/5900125001485', '5900125001485'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 'https://world.openfoodfacts.org/product/5906716208707', '5906716208707'),
    ('Madero', 'Chrzan tarty', 'https://world.openfoodfacts.org/product/5904645001727', '5904645001727'),
    ('Dawtona', 'Sűrített paradicsom', 'https://world.openfoodfacts.org/product/5901713001245', '5901713001245'),
    ('Melvit', 'Natural Mix', 'https://world.openfoodfacts.org/product/5906827018141', '5906827018141'),
    ('Culineo', 'Koncentrat pomidorowy', 'https://world.openfoodfacts.org/product/5901713020659', '5901713020659'),
    ('Wojan team', 'Wojanek', 'https://world.openfoodfacts.org/product/5901549093483', '5901549093483'),
    ('Pudliszki', 'Koncentrat pomidorowy', 'https://world.openfoodfacts.org/product/5900783003968', '5900783003968'),
    ('Nasza Spiżarnia', 'Fasola czerwona', 'https://world.openfoodfacts.org/product/5906716208042', '5906716208042'),
    ('Dawtona', 'Koncentrat pomidorowy', 'https://world.openfoodfacts.org/product/5901713016799', '5901713016799'),
    ('Culineo', 'Pasta z czosnkiem', 'https://world.openfoodfacts.org/product/5901844101661', '5901844101661'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 'https://world.openfoodfacts.org/product/20809539', '20809539'),
    ('GustoBello', 'Gnocchi Di Patate', 'https://world.openfoodfacts.org/product/5907544132431', '5907544132431'),
    ('Plony natury', 'Kasza manna', 'https://world.openfoodfacts.org/product/5900977011595', '5900977011595'),
    ('Culineo', 'Passata klasyczna', 'https://world.openfoodfacts.org/product/5901844101685', '5901844101685'),
    ('Anecoop', 'Włoszczyzna', 'https://world.openfoodfacts.org/product/20355968', '20355968'),
    ('Vemondo', 'Tofu wędzone', 'https://world.openfoodfacts.org/product/4056489717607', '4056489717607'),
    ('El Toro Rojo', 'Oliwki zielone nadziewane pastą paprykową', 'https://world.openfoodfacts.org/product/8410134026876', '8410134026876'),
    ('Plony Natury', 'Kasza Gryczana Biała', 'https://world.openfoodfacts.org/product/4770205128866', '4770205128866'),
    ('Janex', 'Kasza Gryczana', 'https://world.openfoodfacts.org/product/5908267100073', '5908267100073'),
    ('Go Vege', 'Tofu Naturalne', 'https://world.openfoodfacts.org/product/8586024422537', '8586024422537'),
    ('Go VEGE', 'Tofu sweet chili', 'https://world.openfoodfacts.org/product/8586024420113', '8586024420113'),
    ('Lidl', 'Avocados', 'https://world.openfoodfacts.org/product/20229030', '20229030'),
    ('Kania', 'Crispy Fried Onions', 'https://world.openfoodfacts.org/product/20173074', '20173074'),
    ('Vemondo', 'Tofu plain', 'https://world.openfoodfacts.org/product/4056489529712', '4056489529712'),
    ('Vemondo', 'Tofu naturalne', 'https://world.openfoodfacts.org/product/4056489067566', '4056489067566'),
    ('K-take it veggie', 'Tofu natur eco', 'https://world.openfoodfacts.org/product/4335896750729', '4335896750729'),
    ('GustoBello', 'Polpa di pomodoro', 'https://world.openfoodfacts.org/product/8002920016675', '8002920016675'),
    ('Garden Gourmet', 'Veggie Balls', 'https://world.openfoodfacts.org/product/8445290493125', '8445290493125'),
    ('Vemondo', 'Tofu', 'https://world.openfoodfacts.org/product/4056489717591', '4056489717591'),
    ('Tastino', 'Wafle Kukurydziane', 'https://world.openfoodfacts.org/product/4056489587026', '4056489587026'),
    ('Crownfield', 'Owsianka Truskawkowa', 'https://world.openfoodfacts.org/product/4056489064503', '4056489064503'),
    ('Bakello', 'Ciasto francuskie', 'https://world.openfoodfacts.org/product/4001163111929', '4001163111929'),
    ('Violife', 'Cheddar flavour slices', 'https://world.openfoodfacts.org/product/5202390023576', '5202390023576'),
    ('Golden Sun Lidl', 'Kasza manna', 'https://world.openfoodfacts.org/product/20282516', '20282516'),
    ('Nasza Spiżarnia', 'Ananas Plastry', 'https://world.openfoodfacts.org/product/8435493398006', '8435493398006'),
    ('Unknown', 'Awokado hass', 'https://world.openfoodfacts.org/product/8712355263178', '8712355263178')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE;
