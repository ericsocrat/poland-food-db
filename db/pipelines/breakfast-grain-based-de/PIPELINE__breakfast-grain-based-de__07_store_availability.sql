-- PIPELINE (Breakfast & Grain-Based): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-04

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Dr. Oetker', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'REWE'),
    ('Kölln', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 'Edeka'),
    ('Kölln', 'Knusper Honig-Nuss Müsli', 'Lidl'),
    ('Kölln', 'Knusper Honig-Nuss Müsli', 'REWE'),
    ('Dm', 'Bio Schokomüsli ohne Rosinen', 'dm'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'Lidl'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'Edeka'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'REWE'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'Netto'),
    ('Kölln', 'Zartes Bircher Müsli', 'REWE'),
    ('Seitenbacher', 'Kakao-Düsis', 'Edeka'),
    ('Dr. Oetker Vitalis', 'Vitalis Weniger süß Knusper Himbeere', 'REWE'),
    ('Kölln', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 'Edeka'),
    ('Kölln', 'Hafer Müsli Beere Apfel', 'Edeka'),
    ('Dr. Oetker', 'Schoko Müsli klassisch', 'REWE'),
    ('Dr. Oetker', 'Vitalis Knusper Schoko Müsli', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knusper Schoko Müsli', 'REWE'),
    ('Golden Bridge', 'Trauben-Nuss Müsli Vollkorn', 'Aldi'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli PLUS Nussmischung', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli PLUS Nussmischung', 'REWE'),
    ('Dr. Oetker', 'Vitalis Müsli Joghurt', 'REWE'),
    ('Kölln', 'Crunchy Berry Hafer-Müsli', 'REWE'),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 'Edeka'),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 'Kaufland'),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 'Real'),
    ('Seitenbacher', 'Müsli 205 Für Sportliche', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knusper müsli Honeys', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knusper müsli Honeys', 'REWE'),
    ('Golden Bridge', 'Schoko-Müsli mit 30 % weniger Zucker', 'Aldi'),
    ('Golden Bridge', 'Früchte-Müsli', 'Aldi'),
    ('DmBio', 'Beeren Müsli', 'dm'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli klassisch', 'Edeka'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli klassisch', 'REWE'),
    ('Crownfield', 'Schoko Müsli', 'Lidl'),
    ('Dr. Oetker', 'Knusper Schoko Müsli', 'REWE'),
    ('GUT Bio', 'Basis Müsli 5-Kornmix', 'Aldi'),
    ('Kölln', 'Crunchy Mango-Maracuja Hafer-Müsli', 'Edeka'),
    ('Kölln', 'Crunchy Mango-Maracuja Hafer-Müsli', 'REWE'),
    ('Aldi', 'Bio-Müsli - Urkorn-Früchte', 'Aldi'),
    ('Dr. Oetker', 'Müsli Schoko weniger süss', 'REWE'),
    ('Kölln', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 'REWE'),
    ('GUT bio', 'Bio Knusper-Müsli Schoko-Amaranth', 'Aldi'),
    ('Seitenbacher', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 'Edeka'),
    ('Golden Bridge', 'Früchte-Müsli Vollkorn', 'Aldi'),
    ('Kölln', 'Crunchy Hazel Hafer-Müsli', 'REWE')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Breakfast & Grain-Based' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
