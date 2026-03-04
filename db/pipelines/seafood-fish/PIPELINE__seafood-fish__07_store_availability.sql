-- PIPELINE (Seafood & Fish): store availability
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
    ('Marinero', 'Łosoś wędzony na zimno', 'Biedronka'),
    ('Marinero', 'Łosoś atlantycki marynowany plastry', 'Biedronka'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'Biedronka'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 'Biedronka'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'Biedronka'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 'Tesco'),
    ('Jantar', 'Szprot wędzony na gorąco', 'Auchan'),
    ('Lisner', 'Szybki Śledzik w sosie śmietankowym', 'Biedronka'),
    ('Fischer King', 'Stek z łososia', 'Netto'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'Biedronka'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 'Biedronka'),
    ('Auchan', 'Łosoś Pacyficzny Dziki', 'Auchan'),
    ('Marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'Biedronka'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'Auchan'),
    ('Kong Oskar', 'Tuńczyk w kawałkach w oleju roślinnym', 'Auchan'),
    ('Jantar', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'Auchan'),
    ('Northlantica', 'Śledź filet (wędzony z przyprawami)', 'Carrefour'),
    ('Dega', 'Ryba śledź po grecku', 'Lewiatan'),
    ('Lisner', 'Marinated Herring in mushroom sauce', 'Auchan'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 'Biedronka'),
    ('SuperFish', 'Smoked Salmon', 'Kaufland'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 'Auchan'),
    ('Lisner', 'Herring single portion with onion', 'Biedronka'),
    ('Vital Food', 'Chlorella', 'Auchan'),
    ('Nautica', 'Śledzie Wiejskie', 'Lidl'),
    ('Marinero', 'Tuńczyk jednolity w sosie własnym', 'Biedronka'),
    ('Marinero', 'Tuńczyk kawałki w sosie własnym', 'Biedronka'),
    ('Well done', 'Łosoś atlantycki', 'Stokrotka'),
    ('Marinero', 'Filety śledziowe a''la Matjas', 'Biedronka'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'Kaufland'),
    ('Biedronka', 'Filet z makreli wędzony z posypką', 'Biedronka'),
    ('Marinero', 'Świeży pstrąg tęczowy łososiowy filet', 'Biedronka'),
    ('Nautica', 'Opiekane filety śledziowe w zalewie octowej', 'Lidl'),
    ('Nautica', 'Filety śledziowe w sosie śmietanowym', 'Lidl'),
    ('K classic', 'Filety Śledziowe w sosie koperkowym', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
