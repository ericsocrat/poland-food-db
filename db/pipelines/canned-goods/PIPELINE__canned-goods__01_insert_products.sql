-- PIPELINE (Canned Goods): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Canned Goods'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901713008756', '5901713001795', '5904215141327', '5903895039047', '5902353020962', '5900907006660', '5907810102199', '5900580000726', '5903895631913', '5903895020014', '5901489124087', '5900397738508', '5903895011234', '5903895080025', '5901069001012', '5908241636413', '5903895630831', '5900783002152', '5900344201109', '5901713002327', '5900783004057', '5903895039023', '5904378645427', '5900397734586', '5900344201406', '5900580001815', '5900397735286', '5900664005869', '5904947609058', '5900907005922', '5906716201531', '5904194001766', '5900919001912', '5903895639049', '5902335331963', '5904215169314', '5903895020021', '5901002002991', '5904378645649', '5901960048161', '5901713002198', '5901713001658', '5906716209117', '5901069000336', '5903895080056', '5904378640064', '5903895635119', '5901069000817', '5903895630541', '20096410')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Kukurydza słodka', 'not-applicable', 'Biedronka', 'none', '5901713008756'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Kukurydza słodka', 'not-applicable', 'Kaufland', 'none', '5901713001795'),
  ('PL', 'Auchan', 'Grocery', 'Canned Goods', 'Kukurydza super słodka', 'not-applicable', 'Auchan', 'none', '5904215141327'),
  ('PL', 'Marineo', 'Grocery', 'Canned Goods', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895039047'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Płaty śledziowe smażone w zalewie octowej', 'fried', 'Biedronka', 'none', '5902353020962'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Ogórki konserwowe', 'not-applicable', 'Biedronka', 'none', '5900907006660'),
  ('PL', 'Helcom', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w sosie własnym.', 'not-applicable', 'Dino', 'none', '5907810102199'),
  ('PL', 'Provitus', 'Grocery', 'Canned Goods', 'Ogórki konserwowe hot chili', 'not-applicable', 'Biedronka', 'none', '5900580000726'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Łosoś Kawałki w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895631913'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w oleju roślinnym.', 'not-applicable', 'Dino', 'none', '5903895020014'),
  ('PL', 'King Oscar', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym z papryką.', 'not-applicable', 'Auchan', 'none', '5901489124087'),
  ('PL', 'Krakus', 'Grocery', 'Canned Goods', 'Ćwikła z chrzanem', 'not-applicable', 'Biedronka', 'none', '5900397738508'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Sałatka z makrelą pikantna', 'not-applicable', 'Auchan', 'none', '5903895011234'),
  ('PL', 'Mega ryba', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym.', 'not-applicable', 'Auchan', 'none', '5903895080025'),
  ('PL', 'Łosoś Ustka', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5901069001012'),
  ('PL', 'EvraFish', 'Grocery', 'Canned Goods', 'Śledzie w sosie pomidorowym.', 'not-applicable', 'Dino', 'none', '5908241636413'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w bulionie warzywnym.', 'not-applicable', 'Dino', 'none', '5903895630831'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'not-applicable', null, 'none', '5900783002152'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Tuńczyk w sosie własnym', 'not-applicable', null, 'none', '5900344201109'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Pomidory całe', 'not-applicable', null, 'none', '5901713002327'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Fasolka po Bretońsku', 'not-applicable', null, 'none', '5900783004057'),
  ('PL', 'Amerigo', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym', 'not-applicable', null, 'none', '5903895039023'),
  ('PL', 'Asia Flavours', 'Grocery', 'Canned Goods', 'Jackfruit kawałki', 'not-applicable', null, 'none', '5904378645427'),
  ('PL', 'Krakus', 'Grocery', 'Canned Goods', 'Ogórki Korniszony', 'not-applicable', null, 'none', '5900397734586'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w oleju roślinnym', 'not-applicable', null, 'none', '5900344201406'),
  ('PL', 'Provitus', 'Grocery', 'Canned Goods', 'Ogórki konserwowe kozackie', 'not-applicable', null, 'none', '5900580001815'),
  ('PL', 'Łowicz', 'Grocery', 'Canned Goods', 'Pomidory krojone bez skórki', 'not-applicable', null, 'none', '5900397735286'),
  ('PL', 'Ole!', 'Grocery', 'Canned Goods', 'Cebulka marynowana złota', 'not-applicable', null, 'none', '5900664005869'),
  ('PL', 'Unknown', 'Grocery', 'Canned Goods', 'Brzoskwinie połówki w lekkim syropie', 'not-applicable', null, 'none', '5904947609058'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Mieszanka warzywna z kukuyrdzą', 'not-applicable', null, 'none', '5900907005922'),
  ('PL', 'Jamar', 'Grocery', 'Canned Goods', 'Mieszanka warzywna meksykańska', 'not-applicable', null, 'none', '5906716201531'),
  ('PL', 'Go Vege', 'Grocery', 'Canned Goods', 'Strogonow roślinny z pieczarkami', 'not-applicable', null, 'none', '5904194001766'),
  ('PL', 'Rolnik', 'Grocery', 'Canned Goods', 'Cebulka perłowa Premium', 'not-applicable', null, 'none', '5900919001912'),
  ('PL', 'Neptun', 'Grocery', 'Canned Goods', 'Tuńczyk W Wodzie', 'not-applicable', null, 'none', '5903895639049'),
  ('PL', 'EvraFish', 'Grocery', 'Canned Goods', 'Makrela po meksykańsku', 'not-applicable', null, 'none', '5902335331963'),
  ('PL', 'Auchan', 'Grocery', 'Canned Goods', 'Tuńczyk w kawałkach w sosie własnym', 'not-applicable', 'Auchan', 'none', '5904215169314'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w sosie własnym.', 'not-applicable', null, 'none', '5903895020021'),
  ('PL', 'Stoczek', 'Grocery', 'Canned Goods', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'not-applicable', null, 'none', '5901002002991'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Brzoskwinie w syropie', 'not-applicable', 'Biedronka', 'none', '5904378645649'),
  ('PL', 'Dega', 'Grocery', 'Canned Goods', 'Fish spread with rice', 'not-applicable', 'Dino', 'none', '5901960048161'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Pomidory Krojone', 'not-applicable', 'Biedronka', 'none', '5901713002198'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Kukurydza gold', 'not-applicable', 'Kaufland', 'none', '5901713001658'),
  ('PL', 'Unknown', 'Grocery', 'Canned Goods', 'Buraczki zasmażane z cebulą', 'not-applicable', null, 'none', '5906716209117'),
  ('PL', 'Łosoś ustka', 'Grocery', 'Canned Goods', 'Paprykarz szczeciński', 'not-applicable', null, 'none', '5901069000336'),
  ('PL', 'Mega ryba', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym.', 'not-applicable', 'Dino', 'none', '5903895080056'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Korniszony z chili', 'not-applicable', 'Biedronka', 'none', '5904378640064'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'not-applicable', 'Auchan', 'none', '5903895635119'),
  ('PL', 'Łosoś Ustka', 'Grocery', 'Canned Goods', 'Tinned Tomato Mackerel', 'not-applicable', 'Auchan', 'none', '5901069000817'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Makrela w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5903895630541'),
  ('PL', 'Nautica', 'Grocery', 'Canned Goods', 'Makrélafilé bőrrel paradicsomos szószban', 'not-applicable', 'Lidl', 'none', '20096410')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Canned Goods'
  and is_deprecated is not true
  and product_name not in ('Kukurydza słodka', 'Kukurydza słodka', 'Kukurydza super słodka', 'Filety śledziowe w sosie pomidorowym', 'Płaty śledziowe smażone w zalewie octowej', 'Ogórki konserwowe', 'Tuńczyk kawałki w sosie własnym.', 'Ogórki konserwowe hot chili', 'Łosoś Kawałki w sosie pomidorowym', 'Tuńczyk kawałki w oleju roślinnym.', 'Filety z makreli w sosie pomidorowym z papryką.', 'Ćwikła z chrzanem', 'Sałatka z makrelą pikantna', 'Śledź w sosie pomidorowym.', 'Śledź w sosie pomidorowym', 'Śledzie w sosie pomidorowym.', 'Tuńczyk kawałki w bulionie warzywnym.', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'Tuńczyk w sosie własnym', 'Pomidory całe', 'Fasolka po Bretońsku', 'Śledź w sosie pomidorowym', 'Jackfruit kawałki', 'Ogórki Korniszony', 'Tuńczyk kawałki w oleju roślinnym', 'Ogórki konserwowe kozackie', 'Pomidory krojone bez skórki', 'Cebulka marynowana złota', 'Brzoskwinie połówki w lekkim syropie', 'Mieszanka warzywna z kukuyrdzą', 'Mieszanka warzywna meksykańska', 'Strogonow roślinny z pieczarkami', 'Cebulka perłowa Premium', 'Tuńczyk W Wodzie', 'Makrela po meksykańsku', 'Tuńczyk w kawałkach w sosie własnym', 'Tuńczyk kawałki w sosie własnym.', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'Brzoskwinie w syropie', 'Fish spread with rice', 'Pomidory Krojone', 'Kukurydza gold', 'Buraczki zasmażane z cebulą', 'Paprykarz szczeciński', 'Filety z makreli w sosie pomidorowym.', 'Korniszony z chili', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'Tinned Tomato Mackerel', 'Makrela w sosie pomidorowym', 'Makrélafilé bőrrel paradicsomos szószban');
