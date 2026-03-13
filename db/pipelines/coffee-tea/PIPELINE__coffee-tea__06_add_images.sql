-- PIPELINE (Coffee & Tea): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Coffee & Tea'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Herbapol', 'Herbaciany ogród - Prosto z lasu.', 'https://images.openfoodfacts.org/images/products/590/095/600/0688/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956000688', 'front_5900956000688'),
    ('Herbapol', 'Herbaciany ogród, malina z żurawiną', 'https://images.openfoodfacts.org/images/products/590/095/600/3634/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956003634', 'front_5900956003634'),
    ('Cafe d''Or', 'Cappuccino o smaku śmietankowym', 'https://images.openfoodfacts.org/images/products/590/064/907/9229/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649079229', 'front_5900649079229'),
    ('Mokate', 'Mokate Cappuccino z belgijską czekoladą', 'https://images.openfoodfacts.org/images/products/590/289/128/0224/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280224', 'front_5902891280224'),
    ('PKN Orlen', 'Napój kawowy na bazie pełnego mleka i śmietanki', 'https://images.openfoodfacts.org/images/products/590/604/103/0233/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906041030233', 'front_5906041030233'),
    ('Herbapol', 'Herbapol Herbaciany Ogród Briar Rose Fruit-herbal Tea', 'https://images.openfoodfacts.org/images/products/590/095/600/0640/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956000640', 'front_5900956000640'),
    ('Big Active', 'Herbata biała tajska cytryna, kwiat granatu', 'https://images.openfoodfacts.org/images/products/590/554/835/1179/front_pl.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905548351179', 'front_5905548351179'),
    ('Big-Active', 'Early Grey & płatki róży', 'https://images.openfoodfacts.org/images/products/590/765/833/3458/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907658333458', 'front_5907658333458'),
    ('Big-Active', 'Zielona herbata z kawałkami opuncji', 'https://images.openfoodfacts.org/images/products/590/554/835/0134/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905548350134', 'front_5905548350134'),
    ('Big Active', 'Herbata biała jaśmin', 'https://images.openfoodfacts.org/images/products/590/095/670/0113/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956700113', 'front_5900956700113'),
    ('Cafe d''or', 'Kawa rozpuszczalna gold liofilizowana robusta/arabica', 'https://images.openfoodfacts.org/images/products/590/158/341/3926/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901583413926', 'front_5901583413926'),
    ('Unilever', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'https://images.openfoodfacts.org/images/products/590/030/055/0159/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900300550159', 'front_5900300550159'),
    ('Remsey', 'Herbata czarna aromatyzowana Earl Grey Strong w torebkach do zaparzania', 'https://images.openfoodfacts.org/images/products/590/039/601/5723/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900396015723', 'front_5900396015723'),
    ('Lipton', 'Yellow Label', 'https://images.openfoodfacts.org/images/products/590/030/055/0203/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900300550203', 'front_5900300550203'),
    ('Mokate', 'Cappuccino', 'https://images.openfoodfacts.org/images/products/590/289/128/0217/front_en.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280217', 'front_5902891280217'),
    ('Mokate', 'Mokate Cappuccino smak smietankowy', 'https://images.openfoodfacts.org/images/products/590/289/128/0200/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280200', 'front_5902891280200'),
    ('Mokate', 'Cappuccino o smaku orzechowym', 'https://images.openfoodfacts.org/images/products/590/289/128/0194/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280194', 'front_5902891280194'),
    ('Cafe d''Or', 'Cappuccino', 'https://images.openfoodfacts.org/images/products/590/064/907/9236/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649079236', 'front_5900649079236'),
    ('Mokate', 'Cappuccino z magnezem', 'https://images.openfoodfacts.org/images/products/590/289/128/0231/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280231', 'front_5902891280231'),
    ('Mokate', 'Cappuccino o smaku rumowym', 'https://images.openfoodfacts.org/images/products/590/289/128/0279/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280279', 'front_5902891280279'),
    ('Mokate', 'Cappuccino caffee', 'https://images.openfoodfacts.org/images/products/590/289/128/0248/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902891280248', 'front_5902891280248'),
    ('Mokate', 'Cappuccino vanilla', 'https://images.openfoodfacts.org/images/products/590/064/905/0327/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649050327', 'front_5900649050327'),
    ('Mokate', 'Cappuccino karmelowe', 'https://images.openfoodfacts.org/images/products/590/064/906/2740/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649062740', 'front_5900649062740'),
    ('Mokate', 'Mokate Gold Latte Caramel', 'https://images.openfoodfacts.org/images/products/590/064/907/7997/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649077997', 'front_5900649077997'),
    ('Senso', 'Pumpkin Spice Latte Coffe', 'https://images.openfoodfacts.org/images/products/590/444/800/0088/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904448000088', 'front_5904448000088'),
    ('Mokate Gold', 'Vanilla late', 'https://images.openfoodfacts.org/images/products/590/064/907/8659/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649078659', 'front_5900649078659'),
    ('Mokate', 'Mokate mocha double chocolate', 'https://images.openfoodfacts.org/images/products/590/064/907/8017/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649078017', 'front_5900649078017'),
    ('Cafe d''Or', 'Cappuccino o smaku orzechowym', 'https://images.openfoodfacts.org/images/products/590/064/905/7494/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900649057494', 'front_5900649057494'),
    ('Lipton', 'Ice Tea Peach', 'https://images.openfoodfacts.org/images/products/590/049/704/3243/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043243', 'front_5900497043243'),
    ('Lipton', 'Green Ice Tea', 'https://images.openfoodfacts.org/images/products/590/049/704/3182/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043182', 'front_5900497043182'),
    ('Herbapol', 'Malina', 'https://images.openfoodfacts.org/images/products/590/095/600/0633/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956000633', 'front_5900956000633'),
    ('Herbapol', 'Herbatka na zimno Truskawka Rabarbar', 'https://images.openfoodfacts.org/images/products/590/095/600/6505/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956006505', 'front_5900956006505'),
    ('Sir Adalbert''s tea', 'Herbata czarna earl grey liściasta', 'https://images.openfoodfacts.org/images/products/479/233/100/1226/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4792331001226', 'front_4792331001226'),
    ('Bifix', 'Herbata z suszu owocowego', 'https://images.openfoodfacts.org/images/products/590/148/308/1003/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901483081003', 'front_5901483081003'),
    ('Asia Flavours', 'Matcha', 'https://images.openfoodfacts.org/images/products/590/305/079/1582/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903050791582', 'front_5903050791582'),
    ('Milton', 'Herbata zielona o smaku grejpfrutowym', 'https://images.openfoodfacts.org/images/products/590/088/801/3312/front_ru.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900888013312', 'front_5900888013312'),
    ('Herbapol', 'Herb. aronia Herbapol 20SZT', 'https://images.openfoodfacts.org/images/products/590/095/600/0671/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956000671', 'front_5900956000671'),
    ('Big-active', 'Zielona herbata w torebkach', 'https://images.openfoodfacts.org/images/products/590/554/835/0370/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905548350370', 'front_5905548350370'),
    ('Lipton', 'Lipton Green 0.5', 'https://images.openfoodfacts.org/images/products/590/049/704/3267/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900497043267', 'front_5900497043267'),
    ('Lipton', 'Zielona herbata z nutą truskawki i maliny', 'https://images.openfoodfacts.org/images/products/872/060/800/9718/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720608009718', 'front_8720608009718'),
    ('Unknown', 'Herbata Bio-active Li Zielona Z Owoc Malin 100G', 'https://images.openfoodfacts.org/images/products/590/554/835/0288/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905548350288', 'front_5905548350288'),
    ('Nestlé', 'Nescafe', 'https://images.openfoodfacts.org/images/products/761/303/191/8881/front_ru.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613031918881', 'front_7613031918881'),
    ('Carrefour', 'Intenso', 'https://images.openfoodfacts.org/images/products/356/007/123/0494/front_fr.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071230494', 'front_3560071230494'),
    ('Carrefour', 'Classico', 'https://images.openfoodfacts.org/images/products/324/541/424/9950/front_fr.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 3245414249950', 'front_3245414249950'),
    ('Carrefour', 'Dolce', 'https://images.openfoodfacts.org/images/products/356/007/071/3110/front_fr.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070713110', 'front_3560070713110'),
    ('Carrefour', 'Cappuccino', 'https://images.openfoodfacts.org/images/products/356/007/075/5370/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070755370', 'front_3560070755370'),
    ('Carrefour', 'Latte Macchiato', 'https://images.openfoodfacts.org/images/products/356/007/082/6063/front_fr.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070826063', 'front_3560070826063'),
    ('Carrefour', 'Cappuccino Vanilata', 'https://images.openfoodfacts.org/images/products/356/007/101/3714/front_fr.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071013714', 'front_3560071013714'),
    ('Carrefour', 'CAPPUCCINO Decaffeinato', 'https://images.openfoodfacts.org/images/products/356/007/101/3721/front_fr.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071013721', 'front_3560071013721'),
    ('Carrefour', 'CAPPUCCINO Chocolate', 'https://images.openfoodfacts.org/images/products/356/007/101/3745/front_fr.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071013745', 'front_3560071013745'),
    ('L''Or Barista', 'L''or Barista Double Ristretto Intensity 11', 'https://images.openfoodfacts.org/images/products/871/100/042/2069/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000422069', 'front_8711000422069'),
    ('Carrefour', 'Lungo Généreux et Fruité', 'https://images.openfoodfacts.org/images/products/356/007/123/4027/front_fr.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071234027', 'front_3560071234027'),
    ('Carrefour', 'Pérou', 'https://images.openfoodfacts.org/images/products/356/007/123/0517/front_fr.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071230517', 'front_3560071230517'),
    ('Carrefour BIO', 'AMÉRIQUE LATINE GRAINS Pur Arabica', 'https://images.openfoodfacts.org/images/products/356/007/124/4057/front_fr.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071244057', 'front_3560071244057'),
    ('Carrefour BIO', 'Amérique Latine', 'https://images.openfoodfacts.org/images/products/356/007/123/0500/front_fr.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071230500', 'front_3560071230500'),
    ('Carrefour', 'Espresso nocciolita', 'https://images.openfoodfacts.org/images/products/356/007/143/2218/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071432218', 'front_3560071432218'),
    ('Carrefour', 'Espresso Colombie', 'https://images.openfoodfacts.org/images/products/356/007/143/2270/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071432270', 'front_3560071432270'),
    ('Carrefour', 'Lungo Voluptuo', 'https://images.openfoodfacts.org/images/products/356/007/143/2096/front_fr.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071432096', 'front_3560071432096'),
    ('Carrefour', 'Café Grande 100% Arabica', 'https://images.openfoodfacts.org/images/products/356/007/145/2278/front_fr.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071452278', 'front_3560071452278'),
    ('Carrefour', 'Cappuccino ORIGINAL', 'https://images.openfoodfacts.org/images/products/356/007/147/9398/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071479398', 'front_3560071479398'),
    ('Carrefour', 'Caffe latte', 'https://images.openfoodfacts.org/images/products/356/007/150/4564/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071504564', 'front_3560071504564'),
    ('Carrefour', 'Espresso decaffeinato', 'https://images.openfoodfacts.org/images/products/356/007/143/2034/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071432034', 'front_3560071432034'),
    ('Carrefour', 'Espresso', 'https://images.openfoodfacts.org/images/products/356/007/144/8561/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071448561', 'front_3560071448561'),
    ('Tian Ku Shan', 'Matcha Tea powder', 'https://images.openfoodfacts.org/images/products/692/216/361/6734/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 6922163616734', 'front_6922163616734'),
    ('Lipton', 'Herbata czarna z naturalnym aromatem', 'https://images.openfoodfacts.org/images/products/871/410/008/8944/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8714100088944', 'front_8714100088944'),
    ('Lipton', 'Pokrzywa z mango', 'https://images.openfoodfacts.org/images/products/871/716/385/6741/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 8717163856741', 'front_8717163856741'),
    ('Lipton', 'Yellow Label granulowana', 'https://images.openfoodfacts.org/images/products/871/811/482/2853/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8718114822853', 'front_8718114822853'),
    ('Lavazza', 'Qualita Oro', 'https://images.openfoodfacts.org/images/products/800/007/002/0580/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 8000070020580', 'front_8000070020580'),
    ('Jacobs', 'Kawa rozpuszczalna Jacobs Krönung', 'https://images.openfoodfacts.org/images/products/871/100/052/1045/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000521045', 'front_8711000521045'),
    ('Jacobs', 'Crema', 'https://images.openfoodfacts.org/images/products/871/100/052/1106/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000521106', 'front_8711000521106'),
    ('Vemondo', 'Kaffee Hafer', 'https://images.openfoodfacts.org/images/products/405/648/959/1528/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489591528', 'front_4056489591528'),
    ('Cafe d''or', 'Ice Coffee Macchiato', 'https://images.openfoodfacts.org/images/products/008/055/257/1807/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 0080552571807', 'front_0080552571807'),
    ('Kopiko', 'Kopiko', 'https://images.openfoodfacts.org/images/products/899/600/160/0221/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 8996001600221', 'front_8996001600221'),
    ('Nescafé', 'Frappé 3in1', 'https://images.openfoodfacts.org/images/products/761/303/888/7333/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613038887333', 'front_7613038887333'),
    ('Starbucks', 'Caramel macchiato', 'https://images.openfoodfacts.org/images/products/410/029/002/4987/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4100290024987', 'front_4100290024987'),
    ('Jacobs', 'Jacobs CAPPUCCINO ORIGINAL', 'https://images.openfoodfacts.org/images/products/871/100/068/0131/front_ro.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000680131', 'front_8711000680131'),
    ('Jacobs', 'Jacobs', 'https://images.openfoodfacts.org/images/products/871/100/045/4428/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000454428', 'front_8711000454428'),
    ('Arizona', 'Green tea', 'https://images.openfoodfacts.org/images/products/061/300/876/1615/front_fr.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 0613008761615', 'front_0613008761615'),
    ('Lipton', 'Earl Grey (classic) - Lipton', 'https://images.openfoodfacts.org/images/products/541/003/385/1336/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5410033851336', 'front_5410033851336'),
    ('FuzeTea', 'Fuze Tea Peach Hibiscus', 'https://images.openfoodfacts.org/images/products/544/900/023/6623/front_en.96.400.jpg', 'off_api', 'front', true, 'Front — EAN 5449000236623', 'front_5449000236623'),
    ('Unilever', 'Saga herbata czarna ekspresowa', 'https://images.openfoodfacts.org/images/products/871/410/080/7354/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 8714100807354', 'front_8714100807354'),
    ('Lipton', 'Lipton Herbata Green Tea Citrus', 'https://images.openfoodfacts.org/images/products/871/256/638/8141/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712566388141', 'front_8712566388141'),
    ('Lipton', 'Herbata aromatyzowana mango i czarna porzeczka', 'https://images.openfoodfacts.org/images/products/872/060/801/3661/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720608013661', 'front_8720608013661'),
    ('Lipton', 'The tropical', 'https://images.openfoodfacts.org/images/products/872/270/014/0535/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 8722700140535', 'front_8722700140535'),
    ('Unknown', 'Sir Albert''s tea', 'https://images.openfoodfacts.org/images/products/479/881/000/9646/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4798810009646', 'front_4798810009646')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Coffee & Tea' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
