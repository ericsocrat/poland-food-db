-- PIPELINE (Meat): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Herta', 'Hähnchenbrust', 'https://world.openfoodfacts.org/product/4000582370597', '4000582370597'),
    ('Frosta', 'Hähnchen Paella', 'https://world.openfoodfacts.org/product/4008366008704', '4008366008704'),
    ('Gut Drei Eichen', 'Herzhafte Edelsalami, geräuchert', 'https://world.openfoodfacts.org/product/4061458015219', '4061458015219'),
    ('Güldenhof', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 'https://world.openfoodfacts.org/product/4061461786533', '4061461786533'),
    ('Allfein Feinkost', 'Hähnchen-Knusper-Dinos', 'https://world.openfoodfacts.org/product/4061459187557', '4061459187557'),
    ('Güldenhof', 'Mini-Wiener - Geflügel', 'https://world.openfoodfacts.org/product/4061458015851', '4061458015851'),
    ('Güldenhof', 'Geflügel-Paprikalyoner', 'https://world.openfoodfacts.org/product/4061458014410', '4061458014410'),
    ('Adler Schwarzwald', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 'https://world.openfoodfacts.org/product/4061458016377', '4061458016377'),
    ('Bio', 'Bio-Salami - geräuchert mit grünem Pfeffer', 'https://world.openfoodfacts.org/product/4061458013024', '4061458013024'),
    ('Güldenhof', 'Geflügel-Mortadella', 'https://world.openfoodfacts.org/product/4061458014458', '4061458014458'),
    ('Böklunder', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 'https://world.openfoodfacts.org/product/4061458015035', '4061458015035'),
    ('Dulano', 'Geflügel Wiener', 'https://world.openfoodfacts.org/product/4056489205234', '4056489205234'),
    ('Familie Wein', 'Schwarzwälder Schinken', 'https://world.openfoodfacts.org/product/4003419025790', '4003419025790'),
    ('Zimmermann', 'Weißwurst', 'https://world.openfoodfacts.org/product/4006153116007', '4006153116007'),
    ('Rügenwalder Mühle', 'Mühlen Frikadellen 100% Geflügel', 'https://world.openfoodfacts.org/product/4000405002605', '4000405002605'),
    ('Gut Drei Eichen', 'Katenschinken-Würfel', 'https://world.openfoodfacts.org/product/4061458016315', '4061458016315'),
    ('Bernard Matthews Oldenburg', 'Hähnchen Filetstreifen', 'https://world.openfoodfacts.org/product/4002993071100', '4002993071100'),
    ('Gut Drei Eichen', 'Münchner Weißwurst', 'https://world.openfoodfacts.org/product/4061458015905', '4061458015905'),
    ('Gutfried', 'Geflügelwurst', 'https://world.openfoodfacts.org/product/4003171003692', '4003171003692'),
    ('Ferdi Fuchs', 'Wurst Ferdi Fuchs Mini Würstschen', 'https://world.openfoodfacts.org/product/4006639070397', '4006639070397'),
    ('Reinert', 'Bärchenwurst', 'https://world.openfoodfacts.org/product/4006229015579', '4006229015579'),
    ('Meine Metzgerei', 'Puten-Hackfleisch Frisch; gewürzt; zum Braten Aus der Frischetruhe Dauertiefpreis 2.49€ 400g Packung 1kg 6.23€', 'https://world.openfoodfacts.org/product/4061458131315', '4061458131315'),
    ('Gutfried', 'Hähnchenbrust', 'https://world.openfoodfacts.org/product/4003171096175', '4003171096175'),
    ('Meica', 'Geflügelwürstchen', 'https://world.openfoodfacts.org/product/4000503148502', '4000503148502'),
    ('Dulano', 'Delikatess Hähnchenbrust', 'https://world.openfoodfacts.org/product/4056489640158', '4056489640158'),
    ('Reinert', 'Bärchen SchlaWiener', 'https://world.openfoodfacts.org/product/4006229019041', '4006229019041'),
    ('Sprehe Feinkost', 'Hähnchen-Brustfiletstreifen', 'https://world.openfoodfacts.org/product/4061458041232', '4061458041232'),
    ('Reinert', 'Bärchen-Wurst', 'https://world.openfoodfacts.org/product/4006229710214', '4006229710214'),
    ('Gutfried', 'Gutfried - Hähnchen-Salami', 'https://world.openfoodfacts.org/product/4003171047146', '4003171047146'),
    ('Meica', 'Meica Geflügel-Wiener 4000503148601 Geflügel-Wiener im Saitling', 'https://world.openfoodfacts.org/product/4000503148601', '4000503148601'),
    ('Dulano', 'Wurst - Geflügel-Leberwurst', 'https://world.openfoodfacts.org/product/4056489619642', '4056489619642'),
    ('Aldi Meine Metzgerei', 'Hähnchenbrust', 'https://world.openfoodfacts.org/product/4061458010627', '4061458010627'),
    ('Herta', 'FARMERSCHINKEN mit Honig verfeinert und über Buchenholz geräuchert, gegart', 'https://world.openfoodfacts.org/product/4000582309290', '4000582309290'),
    ('Gutfried', 'Hähnchenbrust Kirschpaprika', 'https://world.openfoodfacts.org/product/4003171020088', '4003171020088'),
    ('Kupfer', 'Original Nürnberger Rostbratwürste', 'https://world.openfoodfacts.org/product/4018703070479', '4018703070479'),
    ('Kamar', 'Geflügelbratwurst', 'https://world.openfoodfacts.org/product/4008460266741', '4008460266741'),
    ('Meica', 'Zutat: Würstchen - Wiener Art', 'https://world.openfoodfacts.org/product/4000503102306', '4000503102306'),
    ('Gutfried', 'Hähnchenbrust, gepökelt und gebraten', 'https://world.openfoodfacts.org/product/4003171020057', '4003171020057'),
    ('Herta', 'Schinken', 'https://world.openfoodfacts.org/product/4000582185290', '4000582185290'),
    ('Gut Drei Eichen', 'Schinken-Lyoner', 'https://world.openfoodfacts.org/product/4061458015516', '4061458015516'),
    ('Herta', 'Schinken gegart ofengegrillt', 'https://world.openfoodfacts.org/product/4000582185498', '4000582185498'),
    ('Nestlé', 'Saftschinken', 'https://world.openfoodfacts.org/product/4000582309993', '4000582309993'),
    ('Ponnath Die Meistermetzger', 'Delikatess Prosciutto Cotto', 'https://world.openfoodfacts.org/product/4000930585048', '4000930585048'),
    ('Bio', 'Bio-Salami - luftgetrocknet', 'https://world.openfoodfacts.org/product/4061458012973', '4061458012973'),
    ('Abraham', 'Jamón Serrano Schinken', 'https://world.openfoodfacts.org/product/4061458016568', '4061458016568'),
    ('Zimbo', 'Schinken Zwiebelmettwurst fettreduziert', 'https://world.openfoodfacts.org/product/4063761540068', '4063761540068'),
    ('K-Classic', 'Kochhinterschinken', 'https://world.openfoodfacts.org/product/4063367225079', '4063367225079'),
    ('Herta', 'Schinken Belem Pfeffer', 'https://world.openfoodfacts.org/product/4000582185399', '4000582185399'),
    ('Steinhaus', 'Bergische Salami', 'https://world.openfoodfacts.org/product/4009337779333', '4009337779333'),
    ('Meica', 'Curryking fix & fertig', 'https://world.openfoodfacts.org/product/4000503280004', '4000503280004'),
    ('Reinert', 'Schinken Nuggets', 'https://world.openfoodfacts.org/product/4006229690219', '4006229690219')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Meat' AND p.is_deprecated IS NOT TRUE;
