-- PIPELINE (Baby): source provenance
-- Generated: 2026-02-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'https://world.openfoodfacts.org/product/8591119253835', '8591119253835'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'https://world.openfoodfacts.org/product/5900852041129', '5900852041129'),
    ('BoboVita', 'Pomidorowa z kurczakiem i ryżem', 'https://world.openfoodfacts.org/product/5900852150005', '5900852150005'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'https://world.openfoodfacts.org/product/22009326', '22009326'),
    ('Hipp', 'Dynia z indykiem', 'https://world.openfoodfacts.org/product/9062300109365', '9062300109365'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'https://world.openfoodfacts.org/product/4062300279773', '4062300279773'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', 'https://world.openfoodfacts.org/product/9062300130833', '9062300130833'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'https://world.openfoodfacts.org/product/9062300126638', '9062300126638'),
    ('Nestlé', 'Nestle Sinlac', 'https://world.openfoodfacts.org/product/7613287666819', '7613287666819')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;
