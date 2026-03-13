-- PIPELINE (Spices & Seasonings): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-13

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Farmer''s Snack', 'Südsee-Ingwer', 'REWE'),
    ('Kania', 'Würzlinge Kräuter Italienische Art', 'Lidl'),
    ('Nestlé', 'Würzmischung Nr. 1, Gebratenes Fleisch', 'REWE'),
    ('Hügli Nahrungsmittel GmbH', 'Gewürzmischung Ofen-Gemüse (Bio)', 'Tegut'),
    ('Ostmann', 'Zimt gemahlen', 'Real'),
    ('Ostmann', 'Oregano', 'REWE'),
    ('Ostmann', 'Oregano', 'Netto'),
    ('Aldi', 'Vanilleextrakt-Zubereitung Bio-Bourbon', 'Aldi'),
    ('Le Gusto', 'Curry Pulver', 'Lidl'),
    ('Gut&günstig', 'Grüne Peperoni', 'Edeka'),
    ('Just Spices', 'Gemüse Allrounder', 'REWE'),
    ('1001 delights', 'Gewürz, Ras el Hanout', 'Lidl'),
    ('Rewe Beste Wahl', 'Paprika geräuchert', 'REWE'),
    ('Rewe', 'Jalapenos', 'REWE'),
    ('Kania', 'Persillade provençale', 'Lidl'),
    ('Edeka', 'Pfefferonen griechisch', 'Edeka'),
    ('Taylor & Colledge', 'Bourbon Bio-Vanille extrakt', 'REWE'),
    ('Backfee', 'Vanillepaste', 'Netto'),
    ('Vitasia', 'Ingwer eingelegt', 'Lidl'),
    ('Gut & Günstig', 'Pfeffer schwarz', 'Edeka'),
    ('Kania', 'Oignons', 'Lidl'),
    ('Rewe Bio', 'Zitronenschale gerieben', 'REWE'),
    ('Beltane Naturkost GmbH', 'Biofix Gebratene Nudeln (Bami Goreng)', 'Tegut'),
    ('Vitasia Lidl', 'Sushi Ingwer', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spices & Seasonings' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
