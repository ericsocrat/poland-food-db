-- PIPELINE (Oils & Vinegars): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-06

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Oils & Vinegars'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Carrefour', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'https://images.openfoodfacts.org/images/products/590/578/431/7014/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784317014', 'front_5905784317014'),
    ('Biedronka', 'Wyborny olej słonecznikowy', 'https://images.openfoodfacts.org/images/products/590/682/300/2342/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906823002342', 'front_5906823002342'),
    ('Wielkopolski', 'Wielkopolski olej słonecznikowy rafinowany', 'https://images.openfoodfacts.org/images/products/590/326/400/0357/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264000357', 'front_5903264000357'),
    ('OEL Polska', 'Wielkopolski olej rzepakowy tłoczony tylko raz, rafinowany.', 'https://images.openfoodfacts.org/images/products/590/326/400/0555/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264000555', 'front_5903264000555'),
    ('House of Asia', 'Ocet ryżowy', 'https://images.openfoodfacts.org/images/products/590/175/270/2523/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752702523', 'front_5901752702523'),
    ('ZT Kruszwica', 'Bartek olej słonecznikowy', 'https://images.openfoodfacts.org/images/products/590/031/100/0209/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900311000209', 'front_5900311000209'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'https://images.openfoodfacts.org/images/products/590/001/200/0232/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012000232', 'front_5900012000232'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia', 'https://images.openfoodfacts.org/images/products/590/001/200/3608/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012003608', 'front_5900012003608'),
    ('Oliwa kaszubska', 'Olej rzepakowy tłoczony na zimno', 'https://images.openfoodfacts.org/images/products/590/639/563/1087/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906395631087', 'front_5906395631087'),
    ('Vifon', 'Ocet ryżowy', 'https://images.openfoodfacts.org/images/products/590/188/212/0914/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882120914', 'front_5901882120914'),
    ('Asia Kitchen', 'Ocet ryżowy', 'https://images.openfoodfacts.org/images/products/590/370/784/9857/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903707849857', 'front_5903707849857'),
    ('Mi''Ra', 'Olej z ryżu', 'https://images.openfoodfacts.org/images/products/590/527/945/8000/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905279458000', 'front_5905279458000'),
    ('Slonecznikowy', 'Olej wyborny', 'https://images.openfoodfacts.org/images/products/590/001/201/0002/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012010002', 'front_5900012010002'),
    ('Komagra', 'Polski olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/276/858/4295/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902768584295', 'front_5902768584295'),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/326/400/1460/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264001460', 'front_5903264001460'),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 'https://images.openfoodfacts.org/images/products/590/001/200/4858/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012004858', 'front_5900012004858'),
    ('Wyborny', 'Olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/326/400/0104/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264000104', 'front_5903264000104'),
    ('Unknown', 'Olej wyborny rzepakowy', 'https://images.openfoodfacts.org/images/products/590/326/400/0142/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264000142', 'front_5903264000142'),
    ('Auchan', 'Rafinowany olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/421/514/6568/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215146568', 'front_5904215146568'),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 'https://images.openfoodfacts.org/images/products/590/473/012/7844/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904730127844', 'front_5904730127844'),
    ('House of Asia', 'Olej z prażonego sezamu', 'https://images.openfoodfacts.org/images/products/590/175/270/1656/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752701656', 'front_5901752701656'),
    ('Bunge', 'Optima Cardio', 'https://images.openfoodfacts.org/images/products/590/024/700/2438/front_pl.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900247002438', 'front_5900247002438'),
    ('Intenson', 'Olej kokosowy rafinowany', 'https://images.openfoodfacts.org/images/products/590/324/027/8794/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240278794', 'front_5903240278794'),
    ('Look Food', 'Olej lniany ekologiczny', 'https://images.openfoodfacts.org/images/products/590/311/180/8037/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903111808037', 'front_5903111808037'),
    ('Lewiatan', 'Olej kokosowy', 'https://images.openfoodfacts.org/images/products/590/473/012/7912/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904730127912', 'front_5904730127912'),
    ('Coosur', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'https://images.openfoodfacts.org/images/products/841/066/005/3186/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 8410660053186', 'front_8410660053186'),
    ('Lidl Primadonna', 'Bio Hiszpańska oliwa z oliwek.', 'https://images.openfoodfacts.org/images/products/000/002/072/9783/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 20729783', 'front_20729783'),
    ('Bielmar', 'Sonnenblumen Öl', 'https://images.openfoodfacts.org/images/products/590/022/904/0984/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900229040984', 'front_5900229040984'),
    ('Oleo', 'Olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/001/200/6043/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012006043', 'front_5900012006043'),
    ('Semco', 'Olej rzepakowy', 'https://images.openfoodfacts.org/images/products/590/624/544/4324/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906245444324', 'front_5906245444324'),
    ('Culineo', 'Ocet spirytusowy 10%', 'https://images.openfoodfacts.org/images/products/590/184/410/1791/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901844101791', 'front_5901844101791'),
    ('GustoBello', 'Krem z octem balsamicznym', 'https://images.openfoodfacts.org/images/products/590/754/413/1038/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907544131038', 'front_5907544131038'),
    ('Pegaz', 'Ocet spirytusowy 10%', 'https://images.openfoodfacts.org/images/products/590/165/800/0013/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901658000013', 'front_5901658000013'),
    ('Kujawski', 'Olej 3 ziarna', 'https://images.openfoodfacts.org/images/products/590/001/200/3196/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012003196', 'front_5900012003196'),
    ('Kujawski', 'Kujawski czosnek bazylia', 'https://images.openfoodfacts.org/images/products/590/001/200/4841/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012004841', 'front_5900012004841'),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 'https://images.openfoodfacts.org/images/products/841/066/008/1691/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 8410660081691', 'front_8410660081691'),
    ('Oliver', 'Olej', 'https://images.openfoodfacts.org/images/products/590/031/100/2500/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900311002500', 'front_5900311002500'),
    ('EkoWital', 'Ekologiczny Olej Kokosowy', 'https://images.openfoodfacts.org/images/products/590/824/997/0687/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908249970687', 'front_5908249970687'),
    ('Felix', 'Orzeszki z pieca', 'https://images.openfoodfacts.org/images/products/590/057/110/0039/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900571100039', 'front_5900571100039'),
    ('LenVitol', 'Olej lniany', 'https://images.openfoodfacts.org/images/products/590/755/927/9084/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907559279084', 'front_5907559279084'),
    ('Olejowy Raj', 'Olej kokosowy', 'https://images.openfoodfacts.org/images/products/590/324/097/2135/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240972135', 'front_5903240972135'),
    ('Unknown', 'Wyborny Delio', 'https://images.openfoodfacts.org/images/products/590/326/400/0883/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903264000883', 'front_5903264000883'),
    ('Oleofarm', 'Olej z pestek dyni', 'https://images.openfoodfacts.org/images/products/590/496/001/2545/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904960012545', 'front_5904960012545'),
    ('Semco', 'Oil', 'https://images.openfoodfacts.org/images/products/590/624/544/4157/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906245444157', 'front_5906245444157'),
    ('Premium Gold Master', 'Olej kokosowy', 'https://images.openfoodfacts.org/images/products/590/473/012/7448/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904730127448', 'front_5904730127448'),
    ('Olejarnia Świecie', 'Naturalny olej konopny', 'https://images.openfoodfacts.org/images/products/590/203/700/5087/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902037005087', 'front_5902037005087'),
    ('Radix-Bis', 'Olej kokosowy rafinowany', 'https://images.openfoodfacts.org/images/products/590/756/900/5864/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907569005864', 'front_5907569005864'),
    ('Go Bio', 'Olej Kokosowy', 'https://images.openfoodfacts.org/images/products/590/215/028/4123/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902150284123', 'front_5902150284123'),
    ('Vita Natura', 'Olej kokosowy Bio', 'https://images.openfoodfacts.org/images/products/590/618/501/2744/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906185012744', 'front_5906185012744'),
    ('Nestlé', 'Przyprawa Maggi', 'https://images.openfoodfacts.org/images/products/590/008/501/1180/front_pl.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900085011180', 'front_5900085011180'),
    ('Iorgos', 'Olive Oil', 'https://images.openfoodfacts.org/images/products/590/390/094/1358/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903900941358', 'front_5903900941358'),
    ('PPHU &quot;OLMAJ&quot; Sławomir Majewski', 'Olej rzepakowy zwyczajny', 'https://images.openfoodfacts.org/images/products/590/823/594/4975/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908235944975', 'front_5908235944975'),
    ('Lyrakis Family', 'Oliwa z oliwek z pierwszego tłoczenia', 'https://images.openfoodfacts.org/images/products/520/440/158/0061/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5204401580061', 'front_5204401580061'),
    ('Suriny', 'Olej z ryżu 100%', 'https://images.openfoodfacts.org/images/products/885/104/601/0025/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 8851046010025', 'front_8851046010025'),
    ('Pudliszki', 'Pudliszki', 'https://images.openfoodfacts.org/images/products/590/078/300/9960/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783009960', 'front_5900783009960'),
    ('Primadonna', 'Extra Virgin Olive Oil', 'https://images.openfoodfacts.org/images/products/405/648/997/3010/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489973010', 'front_4056489973010'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'https://images.openfoodfacts.org/images/products/405/648/995/7652/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489957652', 'front_4056489957652'),
    ('Casa de Azeite', 'Oliwa z oliwek', 'https://images.openfoodfacts.org/images/products/841/066/007/8929/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 8410660078929', 'front_8410660078929'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 'https://images.openfoodfacts.org/images/products/356/007/097/3743/front_fr.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070973743', 'front_3560070973743'),
    ('Casa de Azeite', 'Casa de Azeite', 'https://images.openfoodfacts.org/images/products/560/185/517/9009/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5601855179009', 'front_5601855179009'),
    ('Auchan', 'Auchan huile d''olive extra vierge verre 0.75l pack b', 'https://images.openfoodfacts.org/images/products/324/567/772/6366/front_fr.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 3245677726366', 'front_3245677726366'),
    ('Vita D''or', 'Sonnenblumenöl', 'https://images.openfoodfacts.org/images/products/405/648/906/9553/front_cs.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489069553', 'front_4056489069553'),
    ('Vita D´or', 'Sonnenblumenöl', 'https://images.openfoodfacts.org/images/products/405/648/915/8196/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489158196', 'front_4056489158196'),
    ('Carrefour', 'Huile De Tournesol', 'https://images.openfoodfacts.org/images/products/356/007/034/0316/front_en.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070340316', 'front_3560070340316'),
    ('Vita d''Or', 'Rapsöl', 'https://images.openfoodfacts.org/images/products/000/002/001/3578/front_en.134.400.jpg', 'off_api', 'front', true, 'Front — EAN 20013578', 'front_20013578'),
    ('Vita D''or', 'Olej rzepakowy', 'https://images.openfoodfacts.org/images/products/000/002/075/3504/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20753504', 'front_20753504'),
    ('Kaufland', 'Rapsöl', 'https://images.openfoodfacts.org/images/products/541/055/621/3406/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5410556213406', 'front_5410556213406'),
    ('SimplCarrefour', 'Huile de Colza', 'https://images.openfoodfacts.org/images/products/356/007/034/0408/front_fr.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560070340408', 'front_3560070340408'),
    ('Złote Łany', 'Olej rzepakowy', 'https://images.openfoodfacts.org/images/products/200/000/055/2286/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 2000000552286', 'front_2000000552286'),
    ('Vitasia', 'Vinagre de arroz', 'https://images.openfoodfacts.org/images/products/000/002/056/4933/front_es.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 20564933', 'front_20564933'),
    ('Lidl', 'Olej kokosowy', 'https://images.openfoodfacts.org/images/products/000/004/087/5224/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 40875224', 'front_40875224'),
    ('Carrefour', 'Huile pour friture', 'https://images.openfoodfacts.org/images/products/356/007/126/7643/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071267643', 'front_3560071267643'),
    ('Monini', 'Oliwa z oliwek', 'https://images.openfoodfacts.org/images/products/000/008/005/3828/front_en.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 80053828', 'front_80053828'),
    ('Gallo', 'Olive Oil', 'https://images.openfoodfacts.org/images/products/560/125/211/5983/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5601252115983', 'front_5601252115983')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Oils & Vinegars' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
