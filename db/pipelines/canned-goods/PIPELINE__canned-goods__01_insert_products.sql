-- PIPELINE (Canned Goods): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Canned Goods'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901713008756', '5903895637786', '5903895039047', '5903895631913', '5903895020014', '5903895080933', '5903496039354', '5901713002181', '5901713001795', '5902353020962', '5902335332694', '5903895011234', '5900344600520', '5905784339283', '5900397738508', '5904215141327', '5900907006660', '5905643054999', '5900580000726', '5903895080025', '5901069001012', '5900907005847', '5903895010220', '5904215136378', '5901489124087', '5907810102199', '5908241636413', '5903895630831', '5903137887276', '5904194003753', '5901713002327', '5900344201109', '5903895020021', '5903895039023', '5900907005922', '5901713000248', '5902166748695', '5900783004057', '5900344201406', '5903895639049', '5900783002152', '5904378645427', '5906716205744', '5903895010114', '5901871002863', '5902693180234', '5902166741351', '5903895631067', '5901069005300', '5903895010190', '5900580001815', '5900397735286', '5900664005869', '5901069000916', '5904947609058', '5902020850250', '5900344403350', '5906716201531', '5900397734586', '5905162000033', '5906428000118', '5907464906747', '5900672302288', '5901002002991', '5908235946894', '5900335008502', '5901529003938', '5900783002145', '5903386070948', '5902619001032', '5900344016260', '5901713002198', '5901960048161', '5901713001658', '5901581100064', '5903895630541', '5904215169321', '5904378645649', '5904378640064', '5903895080056', '5906716209117', '5901069000336', '5904378645199', '5905784344737', '5901529054787', '5903895635119', '5901069000817', '5904215132905', '5908241636246', '5900580004861', '5905643054975', '5902537540538', '5904378645045', '20096410', '5904378645588')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Kukurydza słodka', 'not-applicable', 'Biedronka', 'none', '5901713008756'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Tuńczyk jednolity w oliwie z oliwek', 'not-applicable', 'Biedronka', 'none', '5903895637786'),
  ('PL', 'Marineo', 'Grocery', 'Canned Goods', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895039047'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Łosoś Kawałki w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895631913'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w oleju roślinnym.', 'not-applicable', 'Dino', 'none', '5903895020014'),
  ('PL', 'Mariners', 'Grocery', 'Canned Goods', 'Paprykarz szczeciński z łososiem', 'not-applicable', 'Biedronka', 'none', '5903895080933'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Chili filety śledziowe', 'not-applicable', 'Biedronka', 'none', '5903496039354'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Ogórki konserwowe', 'not-applicable', 'Biedronka', 'none', '5901713002181'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Kukurydza słodka', 'not-applicable', 'Kaufland', 'none', '5901713001795'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Płaty śledziowe smażone w zalewie octowej', 'fried', 'Biedronka', 'none', '5902353020962'),
  ('PL', 'Go Active', 'Grocery', 'Canned Goods', 'Proteinowa sałatka z łososiem pikantna', 'not-applicable', 'Biedronka', 'none', '5902335332694'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Sałatka z makrelą pikantna', 'not-applicable', 'Auchan', 'none', '5903895011234'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Śledź atlantycki opiekamy', 'not-applicable', 'Kaufland', 'none', '5900344600520'),
  ('PL', 'Carrefour Classic', 'Grocery', 'Canned Goods', 'Pomidory całe', 'not-applicable', 'Carrefour', 'none', '5905784339283'),
  ('PL', 'Krakus', 'Grocery', 'Canned Goods', 'Ćwikła z chrzanem', 'not-applicable', 'Biedronka', 'none', '5900397738508'),
  ('PL', 'Auchan', 'Grocery', 'Canned Goods', 'Kukurydza super słodka', 'not-applicable', 'Auchan', 'none', '5904215141327'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Mieszanka owoców w lekkim syropie', 'not-applicable', 'Biedronka', 'none', '5905643054999'),
  ('PL', 'Provitus', 'Grocery', 'Canned Goods', 'Ogórki konserwowe hot chili', 'not-applicable', 'Biedronka', 'none', '5900580000726'),
  ('PL', 'Mega ryba', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym.', 'not-applicable', 'Auchan', 'none', '5903895080025'),
  ('PL', 'Łosoś Ustka', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5901069001012'),
  ('PL', 'Biedronka', 'Grocery', 'Canned Goods', 'Ogórki ćwiartki', 'not-applicable', 'Biedronka', 'none', '5900907005847'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Filety że śledzia w oleju', 'not-applicable', 'Auchan', 'none', '5903895010220'),
  ('PL', 'Auchan', 'Grocery', 'Canned Goods', 'Kiszone ogórki', 'not-applicable', 'Auchan', 'none', '5904215136378'),
  ('PL', 'King Oscar', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym z papryką.', 'not-applicable', 'Auchan', 'none', '5901489124087'),
  ('PL', 'Helcom', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w sosie własnym.', 'not-applicable', 'Dino', 'none', '5907810102199'),
  ('PL', 'EvraFish', 'Grocery', 'Canned Goods', 'Śledzie w sosie pomidorowym.', 'not-applicable', 'Dino', 'none', '5908241636413'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w bulionie warzywnym.', 'not-applicable', 'Dino', 'none', '5903895630831'),
  ('PL', 'Graal S.A.', 'Grocery', 'Canned Goods', 'Śledź w oleju po gdańsku', 'not-applicable', 'Lewiatan', 'none', '5903137887276'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Ogórki kiszone', 'not-applicable', null, 'none', '5904194003753'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Pomidory całe', 'not-applicable', null, 'none', '5901713002327'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Tuńczyk w sosie własnym', 'not-applicable', null, 'none', '5900344201109'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w sosie własnym.', 'not-applicable', null, 'none', '5903895020021'),
  ('PL', 'Amerigo', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym', 'not-applicable', null, 'none', '5903895039023'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Mieszanka warzywna z kukuyrdzą', 'not-applicable', null, 'none', '5900907005922'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Pomidory skrojone z ziołami', 'not-applicable', null, 'none', '5901713000248'),
  ('PL', 'Helcom', 'Grocery', 'Canned Goods', 'Mix owoców w lekkim syropie', 'not-applicable', null, 'none', '5902166748695'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Fasolka po Bretońsku', 'not-applicable', null, 'none', '5900783004057'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w oleju roślinnym', 'not-applicable', null, 'none', '5900344201406'),
  ('PL', 'Neptun', 'Grocery', 'Canned Goods', 'Tuńczyk W Wodzie', 'not-applicable', null, 'none', '5903895639049'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'not-applicable', null, 'none', '5900783002152'),
  ('PL', 'Asia Flavours', 'Grocery', 'Canned Goods', 'Jackfruit kawałki', 'not-applicable', null, 'none', '5904378645427'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Ćwikła z chrzanem', 'not-applicable', null, 'none', '5906716205744'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Śledź w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010114'),
  ('PL', 'Smak', 'Grocery', 'Canned Goods', 'Konserwowe ogóreczki klasyczne', 'not-applicable', null, 'none', '5901871002863'),
  ('PL', 'MK', 'Grocery', 'Canned Goods', 'Szproty wędzone w sosie pomidorowym', 'smoked', null, 'none', '5902693180234'),
  ('PL', 'Helcom Premium', 'Grocery', 'Canned Goods', 'Brzoskwinie połówki', 'not-applicable', null, 'none', '5902166741351'),
  ('PL', 'Kuchnia STAROPOLSKA', 'Grocery', 'Canned Goods', 'Bigos z kiełbasą', 'not-applicable', null, 'none', '5903895631067'),
  ('PL', 'Łosoś', 'Grocery', 'Canned Goods', 'Paprykarz szczeciński', 'not-applicable', null, 'none', '5901069005300'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Winter szprot podwędzany w oleju', 'not-applicable', null, 'none', '5903895010190'),
  ('PL', 'Provitus', 'Grocery', 'Canned Goods', 'Ogórki konserwowe kozackie', 'not-applicable', null, 'none', '5900580001815'),
  ('PL', 'Łowicz', 'Grocery', 'Canned Goods', 'Pomidory krojone bez skórki', 'not-applicable', null, 'none', '5900397735286'),
  ('PL', 'Ole!', 'Grocery', 'Canned Goods', 'Cebulka marynowana złota', 'not-applicable', null, 'none', '5900664005869'),
  ('PL', 'Łosoś Ustka', 'Grocery', 'Canned Goods', 'Śledź po gdańsku w oleju', 'not-applicable', null, 'none', '5901069000916'),
  ('PL', 'Unknown', 'Grocery', 'Canned Goods', 'Brzoskwinie połówki w lekkim syropie', 'not-applicable', null, 'none', '5904947609058'),
  ('PL', 'Królewska', 'Grocery', 'Canned Goods', 'Sardynka w sosie własnym z dodatkiem oleju', 'not-applicable', null, 'none', '5902020850250'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Śledź atlantycki w sosie grzybowym', 'not-applicable', null, 'none', '5900344403350'),
  ('PL', 'Jamar', 'Grocery', 'Canned Goods', 'Mieszanka warzywna meksykańska', 'not-applicable', null, 'none', '5906716201531'),
  ('PL', 'Krakus', 'Grocery', 'Canned Goods', 'Ogórki Korniszony', 'not-applicable', null, 'none', '5900397734586'),
  ('PL', 'Kuchnia Polska', 'Grocery', 'Canned Goods', 'Ogórki kiszone', 'not-applicable', null, 'none', '5905162000033'),
  ('PL', 'Magaw', 'Grocery', 'Canned Goods', 'Ogórki kiszone', 'not-applicable', null, 'none', '5906428000118'),
  ('PL', 'Dominik', 'Grocery', 'Canned Goods', 'Kapusta kiszona z marchewką', 'not-applicable', null, 'none', '5907464906747'),
  ('PL', 'Primavika', 'Grocery', 'Canned Goods', 'Gołąbki wegetariańskie z kaszą jaglaną', 'not-applicable', null, 'none', '5900672302288'),
  ('PL', 'Stoczek', 'Grocery', 'Canned Goods', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'not-applicable', null, 'none', '5901002002991'),
  ('PL', 'Dobry wybór', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w zalewie z olejem roślinnym.', 'not-applicable', null, 'none', '5908235946894'),
  ('PL', 'Super Fish', 'Grocery', 'Canned Goods', 'Tuńczyk kawałki w oleju roślinnym', 'not-applicable', null, 'none', '5900335008502'),
  ('PL', 'Tradycyjny smak', 'Grocery', 'Canned Goods', 'Buraczki wiórki', 'not-applicable', null, 'none', '5901529003938'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Pomidory całe', 'not-applicable', null, 'none', '5900783002145'),
  ('PL', 'Victus', 'Grocery', 'Canned Goods', 'Ogórki Kiszone', 'not-applicable', null, 'none', '5903386070948'),
  ('PL', 'Kier', 'Grocery', 'Canned Goods', 'Szparagi białe', 'not-applicable', null, 'none', '5902619001032'),
  ('PL', 'Lisner', 'Grocery', 'Canned Goods', 'Śledź atlantycki filety a''la Matjas korzenne', 'not-applicable', null, 'none', '5900344016260'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Pomidory Krojone', 'not-applicable', 'Biedronka', 'none', '5901713002198'),
  ('PL', 'Dega', 'Grocery', 'Canned Goods', 'Fish spread with rice', 'not-applicable', 'Dino', 'none', '5901960048161'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Kukurydza gold', 'not-applicable', 'Kaufland', 'none', '5901713001658'),
  ('PL', 'Kwidzyn', 'Grocery', 'Canned Goods', 'Canned Corn', 'not-applicable', 'Netto', 'none', '5901581100064'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Makrela w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5903895630541'),
  ('PL', 'Auchan', 'Grocery', 'Canned Goods', 'Tuńczyk w kawałkach w sosie własnym', 'not-applicable', null, 'none', '5904215169321'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Brzoskwinie w syropie', 'not-applicable', 'Biedronka', 'none', '5904378645649'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Korniszony z chili', 'not-applicable', 'Biedronka', 'none', '5904378640064'),
  ('PL', 'Mega ryba', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym.', 'not-applicable', 'Dino', 'none', '5903895080056'),
  ('PL', 'Unknown', 'Grocery', 'Canned Goods', 'Buraczki zasmażane z cebulą', 'not-applicable', null, 'none', '5906716209117'),
  ('PL', 'Łosoś ustka', 'Grocery', 'Canned Goods', 'Paprykarz szczeciński', 'not-applicable', null, 'none', '5901069000336'),
  ('PL', 'GustoBello', 'Grocery', 'Canned Goods', 'Carciofi', 'not-applicable', 'Biedronka', 'none', '5904378645199'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Korniszony delitatesowe z przyprawami', 'not-applicable', 'Carrefour', 'none', '5905784344737'),
  ('PL', 'ZPH "Wojna"', 'Grocery', 'Canned Goods', 'Marchewka z groszkiem', 'not-applicable', 'Netto', 'none', '5901529054787'),
  ('PL', 'Graal', 'Grocery', 'Canned Goods', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'not-applicable', 'Auchan', 'none', '5903895635119'),
  ('PL', 'Łosoś Ustka', 'Grocery', 'Canned Goods', 'Tinned Tomato Mackerel', 'not-applicable', 'Auchan', 'none', '5901069000817'),
  ('PL', 'Greek Trade', 'Grocery', 'Canned Goods', 'Brzoskwinie w syropie', 'not-applicable', 'Auchan', 'none', '5904215132905'),
  ('PL', 'EvraFish', 'Grocery', 'Canned Goods', 'Szprot w oleju roslinnym', 'not-applicable', 'Kaufland', 'none', '5908241636246'),
  ('PL', 'Provitus', 'Grocery', 'Canned Goods', 'Kapusta kwaszona duszona', 'not-applicable', 'Biedronka', 'none', '5900580004861'),
  ('PL', 'Biedronka', 'Grocery', 'Canned Goods', 'Maliny w lekkim syropie', 'not-applicable', 'Biedronka', 'none', '5905643054975'),
  ('PL', 'Farma-świętokrzyska', 'Grocery', 'Canned Goods', 'Bio kapusta z grochem', 'not-applicable', 'Lidl', 'none', '5902537540538'),
  ('PL', 'Elios', 'Grocery', 'Canned Goods', 'Papryczki pikantne nadziewane serem', 'not-applicable', 'Biedronka', 'none', '5904378645045'),
  ('PL', 'Nautica', 'Grocery', 'Canned Goods', 'Makrélafilé bőrrel paradicsomos szószban', 'not-applicable', 'Lidl', 'none', '20096410'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Korniszony Delikatesowe', 'not-applicable', null, 'none', '5904378645588')
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
  and product_name not in ('Kukurydza słodka', 'Tuńczyk jednolity w oliwie z oliwek', 'Filety śledziowe w sosie pomidorowym', 'Łosoś Kawałki w sosie pomidorowym', 'Tuńczyk kawałki w oleju roślinnym.', 'Paprykarz szczeciński z łososiem', 'Chili filety śledziowe', 'Ogórki konserwowe', 'Kukurydza słodka', 'Płaty śledziowe smażone w zalewie octowej', 'Proteinowa sałatka z łososiem pikantna', 'Sałatka z makrelą pikantna', 'Śledź atlantycki opiekamy', 'Pomidory całe', 'Ćwikła z chrzanem', 'Kukurydza super słodka', 'Ogórki konserwowe', 'Mieszanka owoców w lekkim syropie', 'Ogórki konserwowe hot chili', 'Śledź w sosie pomidorowym.', 'Śledź w sosie pomidorowym', 'Ogórki ćwiartki', 'Filety że śledzia w oleju', 'Kiszone ogórki', 'Filety z makreli w sosie pomidorowym z papryką.', 'Tuńczyk kawałki w sosie własnym.', 'Śledzie w sosie pomidorowym.', 'Tuńczyk kawałki w bulionie warzywnym.', 'Śledź w oleju po gdańsku', 'Ogórki kiszone', 'Pomidory całe', 'Tuńczyk w sosie własnym', 'Tuńczyk kawałki w sosie własnym.', 'Śledź w sosie pomidorowym', 'Mieszanka warzywna z kukuyrdzą', 'Pomidory skrojone z ziołami', 'Mix owoców w lekkim syropie', 'Fasolka po Bretońsku', 'Tuńczyk kawałki w oleju roślinnym', 'Tuńczyk W Wodzie', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'Jackfruit kawałki', 'Ćwikła z chrzanem', 'Śledź w sosie pomidorowym', 'Konserwowe ogóreczki klasyczne', 'Szproty wędzone w sosie pomidorowym', 'Brzoskwinie połówki', 'Bigos z kiełbasą', 'Paprykarz szczeciński', 'Winter szprot podwędzany w oleju', 'Ogórki konserwowe kozackie', 'Pomidory krojone bez skórki', 'Cebulka marynowana złota', 'Śledź po gdańsku w oleju', 'Brzoskwinie połówki w lekkim syropie', 'Sardynka w sosie własnym z dodatkiem oleju', 'Śledź atlantycki w sosie grzybowym', 'Mieszanka warzywna meksykańska', 'Ogórki Korniszony', 'Ogórki kiszone', 'Ogórki kiszone', 'Kapusta kiszona z marchewką', 'Gołąbki wegetariańskie z kaszą jaglaną', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'Tuńczyk kawałki w zalewie z olejem roślinnym.', 'Tuńczyk kawałki w oleju roślinnym', 'Buraczki wiórki', 'Pomidory całe', 'Ogórki Kiszone', 'Szparagi białe', 'Śledź atlantycki filety a''la Matjas korzenne', 'Pomidory Krojone', 'Fish spread with rice', 'Kukurydza gold', 'Canned Corn', 'Makrela w sosie pomidorowym', 'Tuńczyk w kawałkach w sosie własnym', 'Brzoskwinie w syropie', 'Korniszony z chili', 'Filety z makreli w sosie pomidorowym.', 'Buraczki zasmażane z cebulą', 'Paprykarz szczeciński', 'Carciofi', 'Korniszony delitatesowe z przyprawami', 'Marchewka z groszkiem', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'Tinned Tomato Mackerel', 'Brzoskwinie w syropie', 'Szprot w oleju roslinnym', 'Kapusta kwaszona duszona', 'Maliny w lekkim syropie', 'Bio kapusta z grochem', 'Papryczki pikantne nadziewane serem', 'Makrélafilé bőrrel paradicsomos szószban', 'Korniszony Delikatesowe');
