-- PIPELINE (Canned Goods): store availability
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
    ('Nasza Spiżarnia', 'Kukurydza słodka', 'Biedronka'),
    ('Marinero', 'Tuńczyk jednolity w oliwie z oliwek', 'Biedronka'),
    ('Marineo', 'Filety śledziowe w sosie pomidorowym', 'Biedronka'),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 'Biedronka'),
    ('Graal', 'Tuńczyk kawałki w oleju roślinnym.', 'Dino'),
    ('Mariners', 'Paprykarz szczeciński z łososiem', 'Biedronka'),
    ('Marinero', 'Chili filety śledziowe', 'Biedronka'),
    ('Nasza Spiżarnia', 'Ogórki konserwowe', 'Biedronka'),
    ('Dawtona', 'Kukurydza słodka', 'Kaufland'),
    ('Marinero', 'Płaty śledziowe smażone w zalewie octowej', 'Biedronka'),
    ('Go Active', 'Proteinowa sałatka z łososiem pikantna', 'Biedronka'),
    ('Graal', 'Sałatka z makrelą pikantna', 'Auchan'),
    ('Lisner', 'Śledź atlantycki opiekamy', 'Kaufland'),
    ('Carrefour Classic', 'Pomidory całe', 'Carrefour'),
    ('Krakus', 'Ćwikła z chrzanem', 'Biedronka'),
    ('Auchan', 'Kukurydza super słodka', 'Auchan'),
    ('Nasza spiżarnia', 'Ogórki konserwowe', 'Biedronka'),
    ('Nasza spiżarnia', 'Mieszanka owoców w lekkim syropie', 'Biedronka'),
    ('Provitus', 'Ogórki konserwowe hot chili', 'Biedronka'),
    ('Mega ryba', 'Śledź w sosie pomidorowym.', 'Auchan'),
    ('Łosoś Ustka', 'Śledź w sosie pomidorowym', 'Auchan'),
    ('Biedronka', 'Ogórki ćwiartki', 'Biedronka'),
    ('Graal', 'Filety że śledzia w oleju', 'Auchan'),
    ('Auchan', 'Kiszone ogórki', 'Auchan'),
    ('King Oscar', 'Filety z makreli w sosie pomidorowym z papryką.', 'Auchan'),
    ('Helcom', 'Tuńczyk kawałki w sosie własnym.', 'Dino'),
    ('EvraFish', 'Śledzie w sosie pomidorowym.', 'Dino'),
    ('Graal', 'Tuńczyk kawałki w bulionie warzywnym.', 'Dino'),
    ('Graal S.A.', 'Śledź w oleju po gdańsku', 'Lewiatan'),
    ('Nasza Spiżarnia', 'Pomidory Krojone', 'Biedronka'),
    ('Dega', 'Fish spread with rice', 'Dino'),
    ('Dawtona', 'Kukurydza gold', 'Kaufland'),
    ('Kwidzyn', 'Canned Corn', 'Netto'),
    ('Graal', 'Makrela w sosie pomidorowym', 'Auchan'),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 'Biedronka'),
    ('Nasza Spiżarnia', 'Korniszony z chili', 'Biedronka'),
    ('Mega ryba', 'Filety z makreli w sosie pomidorowym.', 'Dino'),
    ('GustoBello', 'Carciofi', 'Biedronka'),
    ('Carrefour', 'Korniszony delitatesowe z przyprawami', 'Carrefour'),
    ('ZPH "Wojna"', 'Marchewka z groszkiem', 'Netto'),
    ('Graal', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'Auchan'),
    ('Łosoś Ustka', 'Tinned Tomato Mackerel', 'Auchan'),
    ('Greek Trade', 'Brzoskwinie w syropie', 'Auchan'),
    ('EvraFish', 'Szprot w oleju roslinnym', 'Kaufland'),
    ('Provitus', 'Kapusta kwaszona duszona', 'Biedronka'),
    ('Biedronka', 'Maliny w lekkim syropie', 'Biedronka'),
    ('Farma-świętokrzyska', 'Bio kapusta z grochem', 'Lidl'),
    ('Elios', 'Papryczki pikantne nadziewane serem', 'Biedronka'),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
