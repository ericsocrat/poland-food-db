-- PIPELINE (Drinks): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Drinks'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Hortex', 'Sok jabłkowy', 'https://images.openfoodfacts.org/images/products/590/050/003/1397/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900500031397', 'front_5900500031397'),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', 'https://images.openfoodfacts.org/images/products/590/037/913/9460/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900379139460', 'front_5900379139460'),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'https://images.openfoodfacts.org/images/products/590/566/965/3534/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905669653534', 'front_5905669653534'),
    ('Polaris', 'Napój gazowany Vital Red', 'https://images.openfoodfacts.org/images/products/590/108/801/2983/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901088012983', 'front_5901088012983'),
    ('Polaris', 'Napój gazowany Vital Green', 'https://images.openfoodfacts.org/images/products/590/108/801/2990/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901088012990', 'front_5901088012990'),
    ('Tymbark', 'Sok 100% Pomarańcza', 'https://images.openfoodfacts.org/images/products/590/033/401/2685/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334012685', 'front_5900334012685'),
    ('Tymbark', 'Sok 100% jabłko', 'https://images.openfoodfacts.org/images/products/590/033/401/2753/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334012753', 'front_5900334012753'),
    ('Riviva', 'Sok 100% jabłko', 'https://images.openfoodfacts.org/images/products/590/108/801/3133/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901088013133', 'front_5901088013133'),
    ('Bracia Sadownicy', 'Tłoczone Jabłko słodkie odmiany', 'https://images.openfoodfacts.org/images/products/590/566/965/3473/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905669653473', 'front_5905669653473'),
    ('Hellena', 'Oranżada czerwona', 'https://images.openfoodfacts.org/images/products/590/035/201/5798/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900352015798', 'front_5900352015798'),
    ('Riviva', 'Napój Aloesowy z Cząstkami Aloesu', 'https://images.openfoodfacts.org/images/products/590/389/924/6434/front_pl.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903899246434', 'front_5903899246434'),
    ('Go Vege', 'Napój roślinny Owies Bio', 'https://images.openfoodfacts.org/images/products/590/000/142/1697/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900001421697', 'front_5900001421697'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia 2l', 'https://images.openfoodfacts.org/images/products/590/033/400/6233/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334006233', 'front_5900334006233'),
    ('Hortex', 'Sok 100% pomarańcza', 'https://images.openfoodfacts.org/images/products/590/050/003/1434/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900500031434', 'front_5900500031434'),
    ('MWS', 'Kubuś Waterrr Truskawka', 'https://images.openfoodfacts.org/images/products/590/106/740/6604/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901067406604', 'front_5901067406604'),
    ('Kubuš', '100% jabłko', 'https://images.openfoodfacts.org/images/products/590/106/740/1548/front_lt.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901067401548', 'front_5901067401548'),
    ('Tymbark', 'Vitamini JABŁKO MARCHEW MALINA', 'https://images.openfoodfacts.org/images/products/590/033/401/6195/front_pl.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334016195', 'front_5900334016195'),
    ('Tymbark', 'Tymbark Jabłko-Wiśnia', 'https://images.openfoodfacts.org/images/products/590/033/400/0286/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334000286', 'front_5900334000286'),
    ('Piątnica', 'Napój owsiany z wapnem i witaminami', 'https://images.openfoodfacts.org/images/products/590/193/910/5000/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939105000', 'front_5901939105000'),
    ('Tymbark', 'Tymbark Sok pomarańczowy 100% 1l', 'https://images.openfoodfacts.org/images/products/590/033/400/2242/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334002242', 'front_5900334002242'),
    ('GoVege (Biedronka)', 'Napój Roślinny - Midgał', 'https://images.openfoodfacts.org/images/products/590/000/142/1673/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900001421673', 'front_5900001421673'),
    ('Riviva', 'Napój o smaku Kaktus - Jabłko - Limonka', 'https://images.openfoodfacts.org/images/products/590/188/604/4001/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886044001', 'front_5901886044001'),
    ('Zatecky', 'Żatecky 0,0% nealko', 'https://images.openfoodfacts.org/images/products/590/001/400/3477/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014003477', 'front_5900014003477'),
    ('Tymbark', 'Sok pomarańczowy 100%', 'https://images.openfoodfacts.org/images/products/590/033/400/1733/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334001733', 'front_5900334001733'),
    ('Żywiec Zdrój', 'Z nutą truskawki', 'https://images.openfoodfacts.org/images/products/590/054/101/1181/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900541011181', 'front_5900541011181'),
    ('Riviva', '100% Coconut Water', 'https://images.openfoodfacts.org/images/products/590/389/924/6557/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903899246557', 'front_5903899246557'),
    ('Pepsico', 'Pepsi', 'https://images.openfoodfacts.org/images/products/590/049/731/2004/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497312004', 'front_5900497312004'),
    ('Pepsi', 'Pepsi Zero', 'https://images.openfoodfacts.org/images/products/590/049/730/2005/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497302005', 'front_5900497302005'),
    ('Riviva', 'Sok 100% multiwitamina', 'https://images.openfoodfacts.org/images/products/590/188/603/9427/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886039427', 'front_5901886039427'),
    ('Unknown', 'Żywiec Zdrój NGaz 1l', 'https://images.openfoodfacts.org/images/products/590/054/100/9461/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900541009461', 'front_5900541009461'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia', 'https://images.openfoodfacts.org/images/products/590/033/400/6738/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334006738', 'front_5900334006738'),
    ('Pepsi', 'Pepsi Max 0.5', 'https://images.openfoodfacts.org/images/products/590/049/730/0506/front_ru.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497300506', 'front_5900497300506'),
    ('Tymbark', 'Multifruit mango flavoured still drink', 'https://images.openfoodfacts.org/images/products/590/033/400/7780/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334007780', 'front_5900334007780'),
    ('Fortuna', 'Sok 100% pomidor', 'https://images.openfoodfacts.org/images/products/590/005/901/0317/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900059010317', 'front_5900059010317'),
    ('Unknown', 'Cola original zero', 'https://images.openfoodfacts.org/images/products/590/240/394/1674/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902403941674', 'front_5902403941674'),
    ('Frugo', 'Ultra black', 'https://images.openfoodfacts.org/images/products/590/055/205/3163/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552053163', 'front_5900552053163'),
    ('Unknown', 'Zywiec zdróy z nuta cytryny', 'https://images.openfoodfacts.org/images/products/590/054/101/1099/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900541011099', 'front_5900541011099'),
    ('Riviva', 'Jus d''orange 100%', 'https://images.openfoodfacts.org/images/products/590/188/603/8550/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886038550', 'front_5901886038550'),
    ('Unilever', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'https://images.openfoodfacts.org/images/products/590/030/055/0159/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900300550159', 'front_5900300550159'),
    ('Vemondo', 'Owsiane smoothie owoce lata', 'https://images.openfoodfacts.org/images/products/590/016/853/0959/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900168530959', 'front_5900168530959'),
    ('Cola', 'Cola original intense zero', 'https://images.openfoodfacts.org/images/products/590/044/601/9015/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900446019015', 'front_5900446019015'),
    ('Frugo', 'Frugo ultragreen', 'https://images.openfoodfacts.org/images/products/590/055/205/3156/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552053156', 'front_5900552053156'),
    ('Unknown', 'Żywiec Zdrój Minerals', 'https://images.openfoodfacts.org/images/products/590/054/101/1853/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900541011853', 'front_5900541011853'),
    ('Tymbark', 'Sok pomidorowy pikantny', 'https://images.openfoodfacts.org/images/products/590/033/400/0200/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334000200', 'front_5900334000200'),
    ('Riviva', 'Sok 100% pomidorowo-warzywny', 'https://images.openfoodfacts.org/images/products/590/188/604/1505/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886041505', 'front_5901886041505'),
    ('Inka', 'Mleko owsiane', 'https://images.openfoodfacts.org/images/products/590/115/404/3163/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901154043163', 'front_5901154043163'),
    ('Tymbark', 'Tymbark 100% jablko', 'https://images.openfoodfacts.org/images/products/590/033/400/5939/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334005939', 'front_5900334005939'),
    ('Grana', 'Owsiane', 'https://images.openfoodfacts.org/images/products/590/115/404/9387/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901154049387', 'front_5901154049387'),
    ('Heineken', 'Heineken 0.0%', 'https://images.openfoodfacts.org/images/products/590/069/910/2663/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900699102663', 'front_5900699102663'),
    ('WK Dzik', 'Dzik Energy Zero calorie', 'https://images.openfoodfacts.org/images/products/590/217/673/8655/front_pl.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902176738655', 'front_5902176738655'),
    ('Black', 'Black Energy', 'https://images.openfoodfacts.org/images/products/590/055/201/4713/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552014713', 'front_5900552014713'),
    ('Oshee', 'Oshee Vitamin Water', 'https://images.openfoodfacts.org/images/products/590/826/025/4834/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260254834', 'front_5908260254834'),
    ('Dawtona', 'Sok pomidorowy', 'https://images.openfoodfacts.org/images/products/590/171/302/0307/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713020307', 'front_5901713020307'),
    ('Tiger', 'TIGER Energy drink', 'https://images.openfoodfacts.org/images/products/590/033/400/8206/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334008206', 'front_5900334008206'),
    ('Oshee', 'Oshee Multifruit', 'https://images.openfoodfacts.org/images/products/590/826/025/1963/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260251963', 'front_5908260251963'),
    ('Pepsi', 'Pepsi puszka', 'https://images.openfoodfacts.org/images/products/590/049/703/0212/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497030212', 'front_5900497030212'),
    ('Oshee', 'Oshee Grapefruit', 'https://images.openfoodfacts.org/images/products/590/826/025/1987/front_pl.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260251987', 'front_5908260251987'),
    ('Lipton', 'Lipton Green 1,5L', 'https://images.openfoodfacts.org/images/products/590/049/704/3380/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043380', 'front_5900497043380'),
    ('Tymbark', 'Sok 100% Multiwitamina', 'https://images.openfoodfacts.org/images/products/590/033/401/3378/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334013378', 'front_5900334013378'),
    ('Pepsi', 'Pepsi 330ML Max Soft Drink', 'https://images.openfoodfacts.org/images/products/590/049/730/0339/front_fr.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497300339', 'front_5900497300339'),
    ('Oshee', 'Vitamin Water', 'https://images.openfoodfacts.org/images/products/590/826/025/3813/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260253813', 'front_5908260253813'),
    ('Pepsico', 'Pepsi 1.5', 'https://images.openfoodfacts.org/images/products/590/049/731/1502/front_pl.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497311502', 'front_5900497311502'),
    ('Pepsi', 'Pepsi 0.5', 'https://images.openfoodfacts.org/images/products/590/049/731/0505/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497310505', 'front_5900497310505'),
    ('Hellena', 'Helena zero', 'https://images.openfoodfacts.org/images/products/590/035/201/5347/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900352015347', 'front_5900352015347'),
    ('Lipton', 'Ice Tea Peach', 'https://images.openfoodfacts.org/images/products/590/049/704/3243/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043243', 'front_5900497043243'),
    ('Black', 'Black Zero Sugar', 'https://images.openfoodfacts.org/images/products/590/055/202/1865/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552021865', 'front_5900552021865'),
    ('Tymbark', 'Sok pomidorowy 100%', 'https://images.openfoodfacts.org/images/products/590/033/401/2869/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334012869', 'front_5900334012869'),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'https://images.openfoodfacts.org/images/products/405/648/931/5605/front_pl.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489315605', 'front_4056489315605'),
    ('Oshee', 'Vitamin Water zero', 'https://images.openfoodfacts.org/images/products/590/826/025/3578/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260253578', 'front_5908260253578'),
    ('Dawtona', 'Sok pomidorowy pikantny', 'https://images.openfoodfacts.org/images/products/590/171/302/0314/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713020314', 'front_5901713020314'),
    ('I♥Vege', 'Owsiane', 'https://images.openfoodfacts.org/images/products/590/061/704/1104/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617041104', 'front_5900617041104'),
    ('Schweppes', 'Indian Tonic', 'https://images.openfoodfacts.org/images/products/590/286/041/0744/front_ru.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902860410744', 'front_5902860410744'),
    ('Riviva', 'Sok Marchew Banan Jablko', 'https://images.openfoodfacts.org/images/products/590/188/604/4087/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886044087', 'front_5901886044087'),
    ('Pepsi', 'Pepsi 0.85', 'https://images.openfoodfacts.org/images/products/590/049/701/9316/front_pl.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497019316', 'front_5900497019316'),
    ('Oshee', 'OSHEE Zero', 'https://images.openfoodfacts.org/images/products/590/826/025/1574/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260251574', 'front_5908260251574'),
    ('Cisowianka', 'Cisowianka gazowana', 'https://images.openfoodfacts.org/images/products/590/207/800/1109/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902078001109', 'front_5902078001109'),
    ('Oshee', 'Vitamin Tea Zero Peach Flavour', 'https://images.openfoodfacts.org/images/products/590/826/025/3431/front_fr.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260253431', 'front_5908260253431'),
    ('Tymbark', 'Apple watermelon', 'https://images.openfoodfacts.org/images/products/590/033/400/0736/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334000736', 'front_5900334000736'),
    ('Riviva', 'Sok Pomidor Pikantny', 'https://images.openfoodfacts.org/images/products/590/188/603/8277/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901886038277', 'front_5901886038277'),
    ('4move', '4move sports wild cherry', 'https://images.openfoodfacts.org/images/products/590/055/208/5805/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552085805', 'front_5900552085805'),
    ('Tymbark', 'Just Plants Owies', 'https://images.openfoodfacts.org/images/products/590/033/402/0116/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334020116', 'front_5900334020116'),
    ('GoVege', 'Barista salted caramel', 'https://images.openfoodfacts.org/images/products/590/000/142/1635/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900001421635', 'front_5900001421635'),
    ('4move', 'Activevitamin', 'https://images.openfoodfacts.org/images/products/590/055/207/7718/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552077718', 'front_5900552077718'),
    ('Hortex', 'Nektar z czarnych porzeczek', 'https://images.openfoodfacts.org/images/products/590/050/003/1496/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900500031496', 'front_5900500031496'),
    ('Oshee', 'Oshee lemonade Malina-Grejpfrut', 'https://images.openfoodfacts.org/images/products/590/826/025/8016/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908260258016', 'front_5908260258016'),
    ('Tymbark', 'Mousse', 'https://images.openfoodfacts.org/images/products/590/033/401/4443/front_pl.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334014443', 'front_5900334014443'),
    ('Black', 'Black Energy - Mojito flavour', 'https://images.openfoodfacts.org/images/products/590/055/203/2373/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900552032373', 'front_5900552032373'),
    ('Unknown', 'Dr witt multivitamin', 'https://images.openfoodfacts.org/images/products/590/106/740/3764/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901067403764', 'front_5901067403764'),
    ('Alcalia', 'Alcalia Naturalna Woda Mineralna Naturalnie Alkaiczna', 'https://images.openfoodfacts.org/images/products/590/033/401/7468/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900334017468', 'front_5900334017468'),
    ('Lipton', 'Green Ice Tea', 'https://images.openfoodfacts.org/images/products/590/049/704/3182/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043182', 'front_5900497043182'),
    ('Lipton', 'Lipton green', 'https://images.openfoodfacts.org/images/products/590/049/704/5216/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497045216', 'front_5900497045216'),
    ('Wk Dzik', 'Dzik Vitamind Drink Cranberry', 'https://images.openfoodfacts.org/images/products/590/498/831/1071/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904988311071', 'front_5904988311071'),
    ('Energy Drink', 'Dzik', 'https://images.openfoodfacts.org/images/products/590/498/831/0524/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904988310524', 'front_5904988310524'),
    ('Swigo', 'Sok grejpfrutowy HPP', 'https://images.openfoodfacts.org/images/products/590/383/907/5933/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903839075933', 'front_5903839075933'),
    ('Pepsi', 'Pepsi', 'https://images.openfoodfacts.org/images/products/590/049/701/9323/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497019323', 'front_5900497019323')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Drinks' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
