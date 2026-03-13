-- PIPELINE (Baby): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Baby'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Diamant', 'Cukier Biały', 'https://images.openfoodfacts.org/images/products/590/706/900/0017/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907069000017', 'front_5907069000017'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'https://images.openfoodfacts.org/images/products/590/195/861/2367/front_cs.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901958612367', 'front_5901958612367'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'https://images.openfoodfacts.org/images/products/590/085/204/1129/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900852041129', 'front_5900852041129'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 'https://images.openfoodfacts.org/images/products/590/193/900/6031/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939006031', 'front_5901939006031'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'https://images.openfoodfacts.org/images/products/906/230/012/6638/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 9062300126638', 'front_9062300126638'),
    ('Nestle Gerber', 'Owoce jabłka z truskawkami i jagodami', 'https://images.openfoodfacts.org/images/products/761/303/362/9303/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613033629303', 'front_7613033629303'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'https://images.openfoodfacts.org/images/products/761/303/550/7142/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613035507142', 'front_7613035507142'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'https://images.openfoodfacts.org/images/products/859/111/925/3835/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 8591119253835', 'front_8591119253835'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'https://images.openfoodfacts.org/images/products/406/230/027/9773/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300279773', 'front_4062300279773'),
    ('Nestlé', 'Nestle Sinlac', 'https://images.openfoodfacts.org/images/products/761/328/766/6819/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613287666819', 'front_7613287666819'),
    ('Hipp', 'Dynia z indykiem', 'https://images.openfoodfacts.org/images/products/906/230/010/9365/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 9062300109365', 'front_9062300109365'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'https://images.openfoodfacts.org/images/products/000/002/200/9326/front_es.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 22009326', 'front_22009326')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
