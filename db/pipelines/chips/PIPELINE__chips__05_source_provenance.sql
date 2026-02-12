-- PIPELINE (Chips): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Intersnack', 'Prażynki solone', 'https://world.openfoodfacts.org/product/5900073020262', '5900073020262'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 'https://world.openfoodfacts.org/product/5905187114760', '5905187114760'),
    ('Miami', 'Pałeczki kukurydziane', 'https://world.openfoodfacts.org/product/5900672001693', '5900672001693'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', 'https://world.openfoodfacts.org/product/5905187108981', '5905187108981'),
    ('Przysnacki', 'Prażynki bekonowe', 'https://world.openfoodfacts.org/product/5900073020217', '5900073020217'),
    ('Przysnacki', 'Chipsy w kotle prażone', 'https://world.openfoodfacts.org/product/5900073020118', '5900073020118'),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', 'https://world.openfoodfacts.org/product/5900073020187', '5900073020187'),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', 'https://world.openfoodfacts.org/product/5900672001723', '5900672001723'),
    ('Star', 'Maczugi', 'https://world.openfoodfacts.org/product/5900259087898', '5900259087898'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 'https://world.openfoodfacts.org/product/5900073020293', '5900073020293'),
    ('Przysnacki', 'Chrupki o smaku keczupu', 'https://world.openfoodfacts.org/product/5900073020415', '5900073020415'),
    ('Crunchips', 'Crunchips X-CUT, Papryka', 'https://world.openfoodfacts.org/product/5905187114685', '5905187114685'),
    ('Lorenz', 'Crunchips Sticks Ketchup', 'https://world.openfoodfacts.org/product/5905187114883', '5905187114883'),
    ('Lorenz', 'Crunchips X-cut Chakalaka', 'https://world.openfoodfacts.org/product/5905187114708', '5905187114708'),
    ('Top', 'Tortilla', 'https://world.openfoodfacts.org/product/5900928088607', '5900928088607'),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', 'https://world.openfoodfacts.org/product/5905187114753', '5905187114753'),
    ('Miami', 'Chrupki kukurydziane', 'https://world.openfoodfacts.org/product/5900672001709', '5900672001709'),
    ('Top', 'Sticks smak ketchup', 'https://world.openfoodfacts.org/product/5900073020583', '5900073020583'),
    ('Curly', 'Curly Mexican style', 'https://world.openfoodfacts.org/product/5905187120013', '5905187120013'),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', 'https://world.openfoodfacts.org/product/5900259099686', '5900259099686'),
    ('Sunny Family', 'Trips kukurydziane', 'https://world.openfoodfacts.org/product/5902596484637', '5902596484637'),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', 'https://world.openfoodfacts.org/product/5900259071170', '5900259071170'),
    ('Top', 'Top Sticks', 'https://world.openfoodfacts.org/product/5900073020576', '5900073020576'),
    ('Lay''s', 'Chipsy ziemniaczane solone', 'https://world.openfoodfacts.org/product/5900259097552', '5900259097552'),
    ('Go Vege', 'Tortilla Chips Buraczane', 'https://world.openfoodfacts.org/product/5900928081219', '5900928081219'),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', 'https://world.openfoodfacts.org/product/5905187906259', '5905187906259'),
    ('Lay''s', 'Karbowane Papryka', 'https://world.openfoodfacts.org/product/5900259099914', '5900259099914'),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', 'https://world.openfoodfacts.org/product/5900073060152', '5900073060152'),
    ('Lay''s', 'Lay''s green onion flavoured', 'https://world.openfoodfacts.org/product/5900259128898', '5900259128898'),
    ('Lay''s', 'Fromage flavoured chips', 'https://world.openfoodfacts.org/product/5900259128409', '5900259128409'),
    ('Lay''s', 'Lay''s Oven Baked Grilled Paprika', 'https://world.openfoodfacts.org/product/5900259133366', '5900259133366'),
    ('Lay''s', 'Lays Papryka', 'https://world.openfoodfacts.org/product/5900259133311', '5900259133311'),
    ('Top', 'Chipsy smak serek Fromage', 'https://world.openfoodfacts.org/product/5900073021269', '5900073021269'),
    ('Zdrowidło', 'Loopeas light o smaku papryki', 'https://world.openfoodfacts.org/product/5904569550332', '5904569550332'),
    ('Lay''s', 'Lays strong', 'https://world.openfoodfacts.org/product/5900259127778', '5900259127778'),
    ('Lay''s', 'Lays solone', 'https://world.openfoodfacts.org/product/5900259127600', '5900259127600'),
    ('Doritos', 'Hot Corn', 'https://world.openfoodfacts.org/product/5900259094728', '5900259094728'),
    ('Lay''s', 'Oven Baked krakersy', 'https://world.openfoodfacts.org/product/5900259115355', '5900259115355'),
    ('Sonko', 'Chipsy z ciecierzycy', 'https://world.openfoodfacts.org/product/5902180000137', '5902180000137'),
    ('Crunchips', 'Potato crisps with paprika flavour', 'https://world.openfoodfacts.org/product/5905187114746', '5905187114746'),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', 'https://world.openfoodfacts.org/product/5900259099235', '5900259099235'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 'https://world.openfoodfacts.org/product/5900259117564', '5900259117564'),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', 'https://world.openfoodfacts.org/product/5900672002577', '5900672002577'),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 'https://world.openfoodfacts.org/product/5905187120990', '5905187120990'),
    ('Cheetos', 'Cheetos Flamin Hot', 'https://world.openfoodfacts.org/product/5900259135360', '5900259135360'),
    ('Lay''s', 'Flamin'' Hot', 'https://world.openfoodfacts.org/product/5900259135339', '5900259135339'),
    ('Lorenz', 'Peppies Bacon Flavour', 'https://world.openfoodfacts.org/product/5905187001985', '5905187001985'),
    ('Lorenz', 'Monster Munch Mr BIG', 'https://world.openfoodfacts.org/product/5905187003897', '5905187003897'),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', 'https://world.openfoodfacts.org/product/5905187109025', '5905187109025')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Chips' AND p.is_deprecated IS NOT TRUE;
