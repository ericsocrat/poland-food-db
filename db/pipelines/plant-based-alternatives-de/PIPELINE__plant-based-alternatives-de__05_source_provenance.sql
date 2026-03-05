-- PIPELINE (Plant-Based & Alternatives): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'https://world.openfoodfacts.org/product/4000405004593', '4000405004593'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'https://world.openfoodfacts.org/product/4000405005026', '4000405005026'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'https://world.openfoodfacts.org/product/4075600055039', '4075600055039'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'https://world.openfoodfacts.org/product/4000405005033', '4000405005033'),
    ('DmBio', 'Maiswaffeln', 'https://world.openfoodfacts.org/product/4066447584035', '4066447584035'),
    ('REWE Bio +vegan', 'Räucher-Tofu', 'https://world.openfoodfacts.org/product/4337256250122', '4337256250122'),
    ('Rewe', 'Falafel bällchen', 'https://world.openfoodfacts.org/product/4337256857086', '4337256857086'),
    ('Like Meat', 'Like Grilled Chicken', 'https://world.openfoodfacts.org/product/4260380665039', '4260380665039'),
    ('Like Meat', 'Like Chicken', 'https://world.openfoodfacts.org/product/4260380665015', '4260380665015'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 'https://world.openfoodfacts.org/product/20319335', '20319335'),
    ('Freshona', 'Cornichons Gurken', 'https://world.openfoodfacts.org/product/20004361', '20004361'),
    ('REWE Bio', 'Tofu Natur', 'https://world.openfoodfacts.org/product/4337256244794', '4337256244794'),
    ('Baresa', 'Tomaten passiert', 'https://world.openfoodfacts.org/product/20163402', '20163402'),
    ('Alpro', 'Hafer Milch', 'https://world.openfoodfacts.org/product/5411188124689', '5411188124689'),
    ('Oatly!', 'Haferdrink Barista Bio', 'https://world.openfoodfacts.org/product/7394376621680', '7394376621680'),
    ('Barilla', 'Spaghetti N°5', 'https://world.openfoodfacts.org/product/8076800195057', '8076800195057')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE;
