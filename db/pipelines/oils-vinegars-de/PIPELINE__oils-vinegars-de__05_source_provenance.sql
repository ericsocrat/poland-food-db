-- PIPELINE (Oils & Vinegars): source provenance
-- Generated: 2026-03-08

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Bellasan', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4061462150685', '4061462150685'),
    ('Primadonna', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4056489017479', '4056489017479'),
    ('DmBio', 'Natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4067796070255', '4067796070255'),
    ('Lyttos', 'Olivenöl', 'https://world.openfoodfacts.org/product/4061462626883', '4061462626883'),
    ('DmBio', 'Bratolivenöl', 'https://world.openfoodfacts.org/product/4066447258936', '4066447258936'),
    ('Camaletti', 'Camaletti Olivenöl', 'https://world.openfoodfacts.org/product/4028856014978', '4028856014978'),
    ('Gut Bio', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4061458029650', '4061458029650'),
    ('Lyttos', 'Griechisches natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4069365106273', '4069365106273'),
    ('Primadonna', 'Brat Olivenöl', 'https://world.openfoodfacts.org/product/4056489017493', '4056489017493'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'https://world.openfoodfacts.org/product/4056489957652', '4056489957652'),
    ('Aldi', 'Griechisches natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4061458063074', '4061458063074'),
    ('Bellasan', 'Oliven Öl', 'https://world.openfoodfacts.org/product/4047247949293', '4047247949293'),
    ('K-Classic', 'Natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4028856015272', '4028856015272'),
    ('Lidl', 'Natives Olivenöl extra aus Griechenland', 'https://world.openfoodfacts.org/product/4056489412472', '4056489412472'),
    ('DmBio', 'Natives Olivenöl extra naturtrüb', 'https://world.openfoodfacts.org/product/4058172777400', '4058172777400'),
    ('Cucina Nobile', 'Natives Olivenöl', 'https://world.openfoodfacts.org/product/4061458063470', '4061458063470'),
    ('Aldi Bellasan', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 'https://world.openfoodfacts.org/product/4047247949286', '4047247949286'),
    ('Bellasan', 'Olivenöl', 'https://world.openfoodfacts.org/product/4099200023526', '4099200023526'),
    ('Aldi', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4061459138856', '4061459138856'),
    ('Primadonna', 'Olivenöl', 'https://world.openfoodfacts.org/product/4056489166856', '4056489166856'),
    ('Rapunzel', 'Ö-Kreta Olivenöl nativ extra-10,48€/29.6.22', 'https://world.openfoodfacts.org/product/4006040002062', '4006040002062'),
    ('Ener Bio', 'Griechisches natives Olivenöl e', 'https://world.openfoodfacts.org/product/4068134060273', '4068134060273'),
    ('Deluxe', 'Olivenöl', 'https://world.openfoodfacts.org/product/4056489798552', '4056489798552'),
    ('K Favorites', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4063367000614', '4063367000614'),
    ('Rapunzel', 'Olivenöl fruchtig', 'https://world.openfoodfacts.org/product/4006040196518', '4006040196518'),
    ('Rapunzel', 'Olivenöl nativ extra mild', 'https://world.openfoodfacts.org/product/4006040205548', '4006040205548'),
    ('Rapunzel', 'Ölivenöl Finca la Torre', 'https://world.openfoodfacts.org/product/4006040112327', '4006040112327'),
    ('Biozentrsle', 'Olivenöl', 'https://world.openfoodfacts.org/product/4005009103048', '4005009103048'),
    ('Deluxe', 'Öl - Olivenöl Extra G.G.A. Chania Kritis', 'https://world.openfoodfacts.org/product/4056489639817', '4056489639817'),
    ('Dennree', 'Olivenöl nativ extra', 'https://world.openfoodfacts.org/product/4021851585139', '4021851585139'),
    ('Rapunzel', 'Rapunzel Olivenöl Fruchtig, Nativ Extra, 0,5 LTR Flasche', 'https://world.openfoodfacts.org/product/4006040205111', '4006040205111'),
    ('Bertolli', 'Natives Olivenöl Originale', 'https://world.openfoodfacts.org/product/8002470031944', '8002470031944'),
    ('Rewe', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4337256414371', '4337256414371'),
    ('Edeka Bio', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 'https://world.openfoodfacts.org/product/4311501635773', '4311501635773'),
    ('Alnatura', 'Olivenöl', 'https://world.openfoodfacts.org/product/4104420248823', '4104420248823'),
    ('Gut & Günstig', 'Olivenöl Extra Natives', 'https://world.openfoodfacts.org/product/4311596421626', '4311596421626'),
    ('D.O.P. Terra Di Bari Castel Del Monte', 'Italienisches natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4337256021654', '4337256021654'),
    ('Bertolli', 'Olivenöl Natives Extra Gentile SANFT', 'https://world.openfoodfacts.org/product/8002470031937', '8002470031937'),
    ('BioBio', 'Natives Bio-Olivenöl Extra', 'https://world.openfoodfacts.org/product/4316268576161', '4316268576161'),
    ('EDEKA Bio', 'Natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4311501311943', '4311501311943'),
    ('Rewe beste Wahl', 'Olivenöl ideal für warme Speisen', 'https://world.openfoodfacts.org/product/4337256079792', '4337256079792'),
    ('Ja!', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4337256625784', '4337256625784'),
    ('La Espaniola', 'Natives Ölivenöl extra', 'https://world.openfoodfacts.org/product/8410660101153', '8410660101153'),
    ('Las Cuarenta', 'Spanisches Natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4316268510738', '4316268510738'),
    ('Natur Gut', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/21596278', '21596278'),
    ('Bio', 'Bio natives Olivenöl', 'https://world.openfoodfacts.org/product/8002802103288', '8002802103288'),
    ('Primadonna', 'Bio natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4335619110694', '4335619110694'),
    ('Vegola', 'Natives Olivenöl extra', 'https://world.openfoodfacts.org/product/4316268393478', '4316268393478'),
    ('Fiore', 'Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/8008460004332', '8008460004332'),
    ('REWE Feine Welt', 'Natives Olivenöl Extra Lesvos g.g.A.', 'https://world.openfoodfacts.org/product/4337256876872', '4337256876872'),
    ('Edeka', 'Griechisches Natives Olivenöl Extra', 'https://world.openfoodfacts.org/product/4311501490884', '4311501490884')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Oils & Vinegars' AND p.is_deprecated IS NOT TRUE;
