-- PIPELINE (Canned Goods): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Nasza Spiżarnia', 'Kukurydza słodka', 'https://world.openfoodfacts.org/product/5901713008756', '5901713008756'),
    ('Dawtona', 'Kukurydza słodka', 'https://world.openfoodfacts.org/product/5901713001795', '5901713001795'),
    ('Auchan', 'Kukurydza super słodka', 'https://world.openfoodfacts.org/product/5904215141327', '5904215141327'),
    ('Marineo', 'Filety śledziowe w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895039047', '5903895039047'),
    ('Marinero', 'Płaty śledziowe smażone w zalewie octowej', 'https://world.openfoodfacts.org/product/5902353020962', '5902353020962'),
    ('Nasza Spiżarnia', 'Ogórki konserwowe', 'https://world.openfoodfacts.org/product/5900907006660', '5900907006660'),
    ('Helcom', 'Tuńczyk kawałki w sosie własnym', 'https://world.openfoodfacts.org/product/5907810102199', '5907810102199'),
    ('Provitus', 'Ogórki konserwowe hot chili', 'https://world.openfoodfacts.org/product/5900580000726', '5900580000726'),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895631913', '5903895631913'),
    ('Graal', 'Tuńczyk kawałki w oleju roślinnym', 'https://world.openfoodfacts.org/product/5903895020014', '5903895020014'),
    ('King Oscar', 'Filety z makreli w sosie pomidorowym z papryką', 'https://world.openfoodfacts.org/product/5901489124087', '5901489124087'),
    ('Krakus', 'Ćwikła z chrzanem', 'https://world.openfoodfacts.org/product/5900397738508', '5900397738508'),
    ('Graal', 'Sałatka z makrelą pikantna', 'https://world.openfoodfacts.org/product/5903895011234', '5903895011234'),
    ('MegaRyba', 'Śledź w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895080025', '5903895080025'),
    ('Łosoś Ustka', 'Śledź w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5901069001012', '5901069001012'),
    ('EvraFish', 'Śledzie w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5908241636413', '5908241636413'),
    ('Graal', 'Tuńczyk kawałki w bulionie warzywnym', 'https://world.openfoodfacts.org/product/5903895630831', '5903895630831'),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5900783002152', '5900783002152'),
    ('Lisner', 'Tuńczyk w sosie własnym', 'https://world.openfoodfacts.org/product/5900344201109', '5900344201109'),
    ('Nasza Spiżarnia', 'Pomidory całe', 'https://world.openfoodfacts.org/product/5901713002327', '5901713002327'),
    ('Pudliszki', 'Fasolka po Bretońsku', 'https://world.openfoodfacts.org/product/5900783004057', '5900783004057'),
    ('Amerigo', 'Śledź w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895039023', '5903895039023'),
    ('Asia Flavours', 'Jackfruit kawałki', 'https://world.openfoodfacts.org/product/5904378645427', '5904378645427'),
    ('Krakus', 'Ogórki Korniszony', 'https://world.openfoodfacts.org/product/5900397734586', '5900397734586'),
    ('Lisner', 'Tuńczyk kawałki w oleju roślinnym', 'https://world.openfoodfacts.org/product/5900344201406', '5900344201406'),
    ('Provitus', 'Ogórki konserwowe kozackie', 'https://world.openfoodfacts.org/product/5900580001815', '5900580001815'),
    ('Łowicz', 'Pomidory krojone bez skórki', 'https://world.openfoodfacts.org/product/5900397735286', '5900397735286'),
    ('Ole!', 'Cebulka marynowana złota', 'https://world.openfoodfacts.org/product/5900664005869', '5900664005869'),
    ('Unknown', 'Brzoskwinie połówki w lekkim syropie', 'https://world.openfoodfacts.org/product/5904947609058', '5904947609058'),
    ('Nasza Spiżarnia', 'Mieszanka warzywna z kukuyrdzą', 'https://world.openfoodfacts.org/product/5900907005922', '5900907005922'),
    ('Jamar', 'Mieszanka warzywna meksykańska', 'https://world.openfoodfacts.org/product/5906716201531', '5906716201531'),
    ('Go Vege', 'Strogonow roślinny z pieczarkami', 'https://world.openfoodfacts.org/product/5904194001766', '5904194001766'),
    ('Rolnik', 'Cebulka perłowa Premium', 'https://world.openfoodfacts.org/product/5900919001912', '5900919001912'),
    ('Neptun', 'Tuńczyk W Wodzie', 'https://world.openfoodfacts.org/product/5903895639049', '5903895639049'),
    ('EvraFish', 'Makrela po meksykańsku', 'https://world.openfoodfacts.org/product/5902335331963', '5902335331963'),
    ('Auchan', 'Tuńczyk w kawałkach w sosie własnym', 'https://world.openfoodfacts.org/product/5904215169314', '5904215169314'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 'https://world.openfoodfacts.org/product/5903895020021', '5903895020021'),
    ('Stoczek', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'https://world.openfoodfacts.org/product/5901002002991', '5901002002991'),
    ('Nasza Spiżarnia', 'Brzoskwinie w syropie', 'https://world.openfoodfacts.org/product/5904378645649', '5904378645649'),
    ('Dega', 'Fish spread with rice', 'https://world.openfoodfacts.org/product/5901960048161', '5901960048161'),
    ('Nasza Spiżarnia', 'Pomidory Krojone', 'https://world.openfoodfacts.org/product/5901713002198', '5901713002198'),
    ('Dawtona', 'Kukurydza gold', 'https://world.openfoodfacts.org/product/5901713001658', '5901713001658'),
    ('Unknown', 'Buraczki zasmażane z cebulą', 'https://world.openfoodfacts.org/product/5906716209117', '5906716209117'),
    ('Łosoś Ustka', 'Paprykarz szczeciński', 'https://world.openfoodfacts.org/product/5901069000336', '5901069000336'),
    ('MegaRyba', 'Filety z makreli w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895080056', '5903895080056'),
    ('Nasza Spiżarnia', 'Korniszony z chili', 'https://world.openfoodfacts.org/product/5904378640064', '5904378640064'),
    ('Graal', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami', 'https://world.openfoodfacts.org/product/5903895635119', '5903895635119'),
    ('Łosoś Ustka', 'Tinned Tomato Mackerel', 'https://world.openfoodfacts.org/product/5901069000817', '5901069000817'),
    ('Graal', 'Makrela w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895630541', '5903895630541'),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 'https://world.openfoodfacts.org/product/20096410', '20096410')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE;
