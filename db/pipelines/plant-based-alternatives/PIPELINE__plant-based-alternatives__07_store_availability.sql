-- PIPELINE (Plant-Based & Alternatives): store availability
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
    ('Pano', 'Wafle Ryżowe Wieloziarnisty', 'Biedronka'),
    ('Pri', 'Ziemniaczki Już Gotowe z papryką', 'Biedronka'),
    ('Go Vege', 'Parówki sojowe klasyczne', 'Biedronka'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 'Biedronka'),
    ('Basia', 'Mąka Tortowa Extra typ 405 Basia', 'Dino'),
    ('Dobra-kaloria', 'Baton owocowy chrupiący orzech', 'Lidl'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Biedronka'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Lidl'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Kaufland'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Auchan'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Carrefour'),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 'Aldi'),
    ('Złote Pola', 'Mąka tortowa pszenna. Typ 450', 'Biedronka'),
    ('Sante', 'Otręby owsiane', 'Dino'),
    ('Sonko', 'Kasza jęczmienna perłowa', 'Tesco'),
    ('Pani', 'Wafle Prowansalskie', 'Biedronka'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 'Biedronka'),
    ('Madero', 'Chrzan tarty', 'Biedronka'),
    ('Dawtona', 'Sűrített paradicsom', 'Kaufland'),
    ('Melvit', 'Natural Mix', 'Biedronka'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 'Biedronka'),
    ('Anecoop', 'Włoszczyzna', 'Biedronka'),
    ('Go Vege', 'Tofu Naturalne', 'Biedronka'),
    ('Go VEGE', 'Tofu sweet chili', 'Biedronka'),
    ('Lidl', 'Avocados', 'Lidl'),
    ('Kania', 'Crispy Fried Onions', 'Lidl'),
    ('Vemondo', 'Tofu plain', 'Lidl'),
    ('Vemondo', 'Tofu naturalne', 'Lidl'),
    ('K-take it veggie', 'Tofu natur eco', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
