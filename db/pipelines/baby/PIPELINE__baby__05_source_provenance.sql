-- PIPELINE (Baby): source provenance
-- Generated: 2026-03-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Diamant', 'Cukier Biały', 'https://world.openfoodfacts.org/product/5907069000017', '5907069000017'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'https://world.openfoodfacts.org/product/5901958612367', '5901958612367'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'https://world.openfoodfacts.org/product/5900852041129', '5900852041129'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 'https://world.openfoodfacts.org/product/5901939006031', '5901939006031'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'https://world.openfoodfacts.org/product/9062300126638', '9062300126638'),
    ('Nestle Gerber', 'Owoce jabłka z truskawkami i jagodami', 'https://world.openfoodfacts.org/product/7613033629303', '7613033629303'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'https://world.openfoodfacts.org/product/7613035507142', '7613035507142'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'https://world.openfoodfacts.org/product/8591119253835', '8591119253835'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'https://world.openfoodfacts.org/product/4062300279773', '4062300279773'),
    ('Nestlé', 'Nestle Sinlac', 'https://world.openfoodfacts.org/product/7613287666819', '7613287666819'),
    ('Hipp', 'Dynia z indykiem', 'https://world.openfoodfacts.org/product/9062300109365', '9062300109365'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'https://world.openfoodfacts.org/product/22009326', '22009326')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE;
