-- PIPELINE (Plant-Based & Alternatives): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Plant-Based & Alternatives'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'https://images.openfoodfacts.org/images/products/400/040/500/4593/front_de.133.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405004593', 'front_4000405004593'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'https://images.openfoodfacts.org/images/products/400/040/500/5026/front_de.102.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405005026', 'front_4000405005026'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'https://images.openfoodfacts.org/images/products/407/560/005/5039/front_de.180.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600055039', 'front_4075600055039'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'https://images.openfoodfacts.org/images/products/400/040/500/5033/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405005033', 'front_4000405005033'),
    ('DmBio', 'Maiswaffeln', 'https://images.openfoodfacts.org/images/products/406/644/758/4035/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447584035', 'front_4066447584035'),
    ('REWE Bio +vegan', 'Räucher-Tofu', 'https://images.openfoodfacts.org/images/products/433/725/625/0122/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256250122', 'front_4337256250122'),
    ('Rewe', 'Falafel bällchen', 'https://images.openfoodfacts.org/images/products/433/725/685/7086/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256857086', 'front_4337256857086'),
    ('Like Meat', 'Like Grilled Chicken', 'https://images.openfoodfacts.org/images/products/426/038/066/5039/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260380665039', 'front_4260380665039'),
    ('Like Meat', 'Like Chicken', 'https://images.openfoodfacts.org/images/products/426/038/066/5015/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260380665015', 'front_4260380665015'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 'https://images.openfoodfacts.org/images/products/000/002/031/9335/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 20319335', 'front_20319335'),
    ('Freshona', 'Cornichons Gurken', 'https://images.openfoodfacts.org/images/products/000/002/000/4361/front_en.155.400.jpg', 'off_api', 'front', true, 'Front — EAN 20004361', 'front_20004361'),
    ('REWE Bio', 'Tofu Natur', 'https://images.openfoodfacts.org/images/products/433/725/624/4794/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256244794', 'front_4337256244794'),
    ('Baresa', 'Tomaten passiert', 'https://images.openfoodfacts.org/images/products/000/002/016/3402/front_en.352.400.jpg', 'off_api', 'front', true, 'Front — EAN 20163402', 'front_20163402'),
    ('Alpro', 'Hafer Milch', 'https://images.openfoodfacts.org/images/products/541/118/812/4689/front_en.455.400.jpg', 'off_api', 'front', true, 'Front — EAN 5411188124689', 'front_5411188124689'),
    ('Oatly!', 'Haferdrink Barista Bio', 'https://images.openfoodfacts.org/images/products/739/437/662/1680/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 7394376621680', 'front_7394376621680'),
    ('Barilla', 'Spaghetti N°5', 'https://images.openfoodfacts.org/images/products/807/680/019/5057/front_en.3704.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076800195057', 'front_8076800195057')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
