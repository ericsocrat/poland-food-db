-- PIPELINE (Oils & Vinegars): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-12

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Carrefour', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'Carrefour'),
    ('Biedronka', 'Wyborny olej słonecznikowy', 'Biedronka'),
    ('Wielkopolski', 'Wielkopolski olej słonecznikowy rafinowany', 'Kaufland'),
    ('OEL Polska', 'Wielkopolski olej rzepakowy tłoczony tylko raz, rafinowany.', 'Auchan'),
    ('House of Asia', 'Ocet ryżowy', 'Auchan'),
    ('Slonecznikowy', 'Olej wyborny', 'Biedronka'),
    ('Komagra', 'Polski olej rzepakowy', 'Biedronka'),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 'Biedronka'),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 'Biedronka'),
    ('Wyborny', 'Olej rzepakowy', 'Biedronka'),
    ('Unknown', 'Olej wyborny rzepakowy', 'Biedronka'),
    ('Auchan', 'Rafinowany olej rzepakowy', 'Auchan'),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 'Biedronka'),
    ('Bunge', 'Optima Cardio', 'Biedronka'),
    ('Intenson', 'Olej kokosowy rafinowany', 'Kaufland'),
    ('Look Food', 'Olej lniany ekologiczny', 'Netto'),
    ('Lewiatan', 'Olej kokosowy', 'Lewiatan'),
    ('Coosur', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'Kaufland'),
    ('Lidl Primadonna', 'Bio Hiszpańska oliwa z oliwek.', 'Lidl'),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 'Biedronka'),
    ('Olejarnia Świecie', 'Naturalny olej konopny', 'Delikatesy Centrum'),
    ('Primadonna', 'Extra Virgin Olive Oil', 'Lidl'),
    ('Casa de Azeite', 'Oliwa z oliwek', 'Biedronka'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 'Carrefour'),
    ('Casa de Azeite', 'Casa de Azeite', 'Biedronka'),
    ('Auchan', 'Auchan huile d''olive extra vierge verre 0.75l pack b', 'Auchan'),
    ('Vita D''or', 'Sonnenblumenöl', 'Lidl'),
    ('Vita D´or', 'Sonnenblumenöl', 'Lidl'),
    ('Carrefour', 'Huile De Tournesol', 'Carrefour'),
    ('Vita d''Or', 'Rapsöl', 'Lidl'),
    ('Vita D''or', 'Olej rzepakowy', 'Lidl'),
    ('Kaufland', 'Rapsöl', 'Kaufland'),
    ('SimplCarrefour', 'Huile de Colza', 'Carrefour'),
    ('Złote Łany', 'Olej rzepakowy', 'Dino'),
    ('Vitasia', 'Vinagre de arroz', 'Lidl'),
    ('Lidl', 'Olej kokosowy', 'Lidl'),
    ('Carrefour', 'Huile pour friture', 'Carrefour'),
    ('K-Classic', 'Extra virgin olive oil', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Oils & Vinegars' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
