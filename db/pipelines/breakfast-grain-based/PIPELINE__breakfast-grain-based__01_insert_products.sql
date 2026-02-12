-- PIPELINE (Breakfast & Grain-Based): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5907437365069', '5907437367254', '5907437366158', '5907437366141', '5907437363348', '5907437365052', '5900749610377', '5907437363331', '5906827017823', '5900397006744', '5906974015741', '5900956201054', '5906716209933', '5906974015734', '5903295009893', '5900956201061', '5906974015758', '5901713009449', '5901713009494', '5900397742437', '5906747171414', '5900971000298', '5907437368114', '5907437369586', '5907437366004', '5907437367629', '5900552025016', '5906747170684', '5902884460244', '5902884460374', '5906747171971', '5907437364055', '5907437364062', '5902884460435', '5907517586766', '5901713030153', '5901534001752', '5900397749924', '5900956201009', '5900397006546', '5900397006805', '5900397754492', '5900397012455', '5900397750838', '5903295004959', '5900397735842', '5900397742079', '5902884468059', '5900749610537', '5907437367933', '5902860470014', '5907437369050', '5907437364741', '5901529083633', '5902860471479', '5903548001759', '5907437368848', '5900397006607', '5900397008601', '5900397731639', '5903295001798', '5900919005293', '5901713009463', '5900617002983', '5907437367247', '5900617002976', '5902884461890', '5902884460060', '5900617037213', '5900617002617', '5902944607626', '5900020001085', '5900020001108', '5902944607633', '5903246568684', '5902884468455', '5901529083596', '5905108801267', '5902884461319', '5906747171421', '5900617039286', '5051007108522', '5907437366967', '5906747170707', '5900617011299', '5901529083626', '5900617045133', '5900971000359', '5900749651301', '5902884465850', '5907654872234', '5907437368831', '5907437369944', '5905186304001', '5902884466024', '7300400122054', '5902609001400', '7300400481441', '5900154000350', '5900437028149')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'not-applicable', 'Biedronka', 'none', '5907437365069'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Vitanella Granola z czekoladą', 'not-applicable', 'Biedronka', 'none', '5907437367254'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'not-applicable', 'Biedronka', 'none', '5907437366158'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli prażone z suszoną, słodzoną żurawiną', 'not-applicable', 'Biedronka', 'none', '5907437366141'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 'not-applicable', 'Biedronka', 'none', '5907437363348'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 'not-applicable', 'Biedronka', 'none', '5907437365052'),
  ('PL', 'Bakalland', 'Grocery', 'Breakfast & Grain-Based', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 'not-applicable', 'Biedronka', 'none', '5900749610377'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami', 'not-applicable', 'Biedronka', 'none', '5907437363331'),
  ('PL', 'Melvit', 'Grocery', 'Breakfast & Grain-Based', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 'not-applicable', 'Lidl', 'none', '5906827017823'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem truskawkowy', 'not-applicable', 'Stokrotka', 'none', '5900397006744'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Produkt owocowy z brzoskwiń', 'not-applicable', 'Biedronka', 'none', '5906974015741'),
  ('PL', 'Herbapol', 'Grocery', 'Breakfast & Grain-Based', 'Dżem z Czarnych Porzeczek', 'not-applicable', 'Kaufland', 'none', '5900956201054'),
  ('PL', 'Raspodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem wiśniowy', 'not-applicable', 'Biedronka', 'none', '5906716209933'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem wiśniowy', 'not-applicable', 'Biedronka', 'none', '5906974015734'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Powidła węgierkowe', 'not-applicable', 'Biedronka', 'none', '5903295009893'),
  ('PL', 'Herbapol', 'Grocery', 'Breakfast & Grain-Based', 'Powidła wegierkowe', 'not-applicable', 'Auchan', 'none', '5900956201061'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem czarna porzeczka', 'not-applicable', 'Biedronka', 'none', '5906974015758'),
  ('PL', 'Dawtona', 'Grocery', 'Breakfast & Grain-Based', 'Dżem Brzoskwiniowy niskosłodzony', 'not-applicable', 'Dino', 'none', '5901713009449'),
  ('PL', 'Dawtona', 'Grocery', 'Breakfast & Grain-Based', 'Powidła śliwkowe', 'not-applicable', 'Dino', 'none', '5901713009494'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem z truskawek i limonki niskosłodzony', 'not-applicable', 'Dino', 'none', '5900397742437'),
  ('PL', 'Kupiec', 'Grocery', 'Breakfast & Grain-Based', 'Coś na ząb owsianka z jabłkiem i bananem', 'not-applicable', null, 'none', '5906747171414'),
  ('PL', 'Vivi Polska', 'Grocery', 'Breakfast & Grain-Based', 'Musli owocowe pożywne śniadanie', 'not-applicable', null, 'none', '5900971000298'),
  ('PL', 'Go Active', 'Grocery', 'Breakfast & Grain-Based', 'Musli wyobiałkowe', 'not-applicable', null, 'none', '5907437368114'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli 5 zbóż', 'not-applicable', null, 'none', '5907437369586'),
  ('PL', 'Go Bio', 'Grocery', 'Breakfast & Grain-Based', 'Musli z czekoladą i orzechami', 'not-applicable', null, 'none', '5907437366004'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Vitanella Owsianka - śliwka, migdał, żurawina', 'not-applicable', null, 'none', '5907437367629'),
  ('PL', 'Fitella', 'Grocery', 'Breakfast & Grain-Based', 'Musli chrupkie bananowe z kawałkami czekolady', 'not-applicable', null, 'none', '5900552025016'),
  ('PL', 'Kupiec', 'Grocery', 'Breakfast & Grain-Based', 'Coś na Ząb', 'not-applicable', null, 'none', '5906747170684'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi', 'not-applicable', null, 'none', '5902884460244'),
  ('PL', 'OneDayMore', 'Grocery', 'Breakfast & Grain-Based', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 'not-applicable', null, 'none', '5902884460374'),
  ('PL', 'Kupiec', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka z jabłkiem i cynamonem', 'not-applicable', null, 'none', '5906747171971'),
  ('PL', 'Brüggen', 'Grocery', 'Breakfast & Grain-Based', 'Płatki owsiane z suszonymi owocami i orzechami', 'not-applicable', null, 'none', '5907437364055'),
  ('PL', 'Brüggen', 'Grocery', 'Breakfast & Grain-Based', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin', 'not-applicable', null, 'none', '5907437364062'),
  ('PL', 'OneDayMore', 'Grocery', 'Breakfast & Grain-Based', 'Musli z malinami i jeżynami', 'not-applicable', null, 'none', '5902884460435'),
  ('PL', 'Promienie Słońca', 'Grocery', 'Breakfast & Grain-Based', 'Promienie Słońca Słoneczna granola z orzechami i miodem', 'not-applicable', null, 'none', '5907517586766'),
  ('PL', 'Dawtona', 'Grocery', 'Breakfast & Grain-Based', 'Drugie śniadanie', 'not-applicable', null, 'none', '5901713030153'),
  ('PL', 'Pano', 'Grocery', 'Breakfast & Grain-Based', 'Pieczywo żytnie chrupkie', 'not-applicable', null, 'none', '5901534001752'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem malinowy', 'not-applicable', null, 'none', '5900397749924'),
  ('PL', 'Herbapol', 'Grocery', 'Breakfast & Grain-Based', 'Dżem truskawkowy', 'not-applicable', null, 'none', '5900956201009'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Łowicz - Dżem Wiśniowy', 'not-applicable', null, 'none', '5900397006546'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem truskawkowy', 'not-applicable', null, 'none', '5900397006805'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem Malinowy', 'not-applicable', null, 'none', '5900397754492'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Extra konfitura z wiśni', 'not-applicable', null, 'none', '5900397012455'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem 100% z owoców wiśnia', 'not-applicable', null, 'none', '5900397750838'),
  ('PL', 'Lidl', 'Grocery', 'Breakfast & Grain-Based', 'Dżem truskawkowy Rapsodia', 'not-applicable', null, 'none', '5903295004959'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Konfitura z żółtych owoców', 'not-applicable', null, 'none', '5900397735842'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem brzoskwiniowy super gładki', 'not-applicable', null, 'none', '5900397742079'),
  ('PL', 'One day more', 'Grocery', 'Breakfast & Grain-Based', 'Muesli Protein', 'not-applicable', 'Lidl', 'none', '5902884468059'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Banana Chocolate musli', 'not-applicable', 'Biedronka', 'none', '5900749610537'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli z owocami i orzechami', 'not-applicable', 'Biedronka', 'none', '5907437367933'),
  ('PL', 'Inna Bajka', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka Mango i Jagody Goji', 'not-applicable', 'Żabka', 'none', '5902860470014'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Granola z czekoladą i orzechami', 'not-applicable', null, 'none', '5907437369050'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli premium', 'not-applicable', 'Biedronka', 'none', '5907437364741'),
  ('PL', 'Bell''s', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka owoce i orzechy', 'not-applicable', 'Netto', 'none', '5901529083633'),
  ('PL', 'Inna Bajka', 'Grocery', 'Breakfast & Grain-Based', 'Musli Marakuja i Pitaja', 'not-applicable', 'Biedronka', 'none', '5902860471479'),
  ('PL', 'Dobra Kaloria', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka królewska z jabłkiem', 'not-applicable', null, 'none', '5903548001759'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Muesli z owocami i siemieniem lnianym', 'not-applicable', 'Biedronka', 'none', '5907437368848'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem wiśniowy o obniżonej zawartości cukru', 'not-applicable', null, 'none', '5900397006607'),
  ('PL', 'Rapsodia', 'Grocery', 'Breakfast & Grain-Based', 'Dżem brzoskwiniowy', 'not-applicable', null, 'none', '5900397008601'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem z agrestu i kiwi', 'not-applicable', null, 'none', '5900397731639'),
  ('PL', 'Mirella', 'Grocery', 'Breakfast & Grain-Based', 'Powidła śliwkowe', 'not-applicable', null, 'none', '5903295001798'),
  ('PL', 'Rolnik', 'Grocery', 'Breakfast & Grain-Based', 'Borówka cala', 'not-applicable', null, 'none', '5900919005293'),
  ('PL', 'Dawtona', 'Grocery', 'Breakfast & Grain-Based', 'Eperdzsem', 'not-applicable', 'Dino', 'none', '5901713009463'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Granola chocolate / pieces of chocolate', 'not-applicable', null, 'none', '5900617002983'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Granola', 'not-applicable', null, 'none', '5907437367247'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Granola Nut / peanuts & peanut butter', 'not-applicable', null, 'none', '5900617002976'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Muesli chocolat', 'not-applicable', null, 'none', '5902884461890'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Muesli for focused ones', 'not-applicable', null, 'none', '5902884460060'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Sante fit granola strawberry and cherry', 'not-applicable', null, 'none', '5900617037213'),
  ('PL', 'Santé', 'Grocery', 'Breakfast & Grain-Based', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 'not-applicable', null, 'none', '5900617002617'),
  ('PL', 'Promienie słońca', 'Grocery', 'Breakfast & Grain-Based', 'Baton musli z owocami', 'not-applicable', null, 'none', '5902944607626'),
  ('PL', 'Nestlé', 'Grocery', 'Breakfast & Grain-Based', 'Musli tropical', 'not-applicable', null, 'none', '5900020001085'),
  ('PL', 'Nestlé', 'Grocery', 'Breakfast & Grain-Based', 'Musli classic', 'not-applicable', null, 'none', '5900020001108'),
  ('PL', 'Promienie słońca', 'Grocery', 'Breakfast & Grain-Based', 'Baton musli z orzechami i miodem', 'not-applicable', null, 'none', '5902944607633'),
  ('PL', 'Purella', 'Grocery', 'Breakfast & Grain-Based', 'Purella Super Musli Proteinowe', 'not-applicable', null, 'none', '5903246568684'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Porridge Orange', 'not-applicable', null, 'none', '5902884468455'),
  ('PL', 'Bell''s', 'Grocery', 'Breakfast & Grain-Based', 'Crunchy', 'not-applicable', null, 'none', '5901529083596'),
  ('PL', 'OneDayMore', 'Grocery', 'Breakfast & Grain-Based', 'Musli Keto Choco', 'not-applicable', null, 'none', '5905108801267'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Meusli Fruits et Chocolat Blanc', 'not-applicable', null, 'none', '5902884461319'),
  ('PL', 'Kupiec', 'Grocery', 'Breakfast & Grain-Based', 'Cosnazab', 'not-applicable', null, 'none', '5906747171421'),
  ('PL', 'Go On', 'Grocery', 'Breakfast & Grain-Based', 'Protein granola', 'not-applicable', null, 'none', '5900617039286'),
  ('PL', 'Tesco', 'Grocery', 'Breakfast & Grain-Based', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców', 'not-applicable', 'Tesco', 'none', '5051007108522'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka ananas, kokos', 'not-applicable', null, 'none', '5907437366967'),
  ('PL', 'Kupiec', 'Grocery', 'Breakfast & Grain-Based', 'Cos na Zab', 'not-applicable', null, 'none', '5906747170707'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Musli Lo z owocami', 'not-applicable', null, 'none', '5900617011299'),
  ('PL', 'Bell’s', 'Grocery', 'Breakfast & Grain-Based', 'Owsianka', 'not-applicable', null, 'none', '5901529083626'),
  ('PL', 'Go On', 'Grocery', 'Breakfast & Grain-Based', 'Protein Granola Go On', 'not-applicable', null, 'none', '5900617045133'),
  ('PL', 'Vivi', 'Grocery', 'Breakfast & Grain-Based', 'Musli owocowe: polskie owoce', 'not-applicable', null, 'none', '5900971000359'),
  ('PL', 'BakallanD', 'Grocery', 'Breakfast & Grain-Based', 'Granola klasyczna z kokosem', 'not-applicable', null, 'none', '5900749651301'),
  ('PL', 'One day more', 'Grocery', 'Breakfast & Grain-Based', 'Fruit Granola', 'not-applicable', null, 'none', '5902884465850'),
  ('PL', 'Bifood', 'Grocery', 'Breakfast & Grain-Based', 'Muesli crunchy', 'not-applicable', null, 'none', '5907654872234'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Muesli z owocami i orzechami', 'not-applicable', null, 'none', '5907437368831'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Granola z kakao i orzechami', 'not-applicable', null, 'none', '5907437369944'),
  ('PL', 'Purella Superfoods', 'Grocery', 'Breakfast & Grain-Based', 'Purella superfoods granola', 'not-applicable', null, 'none', '5905186304001'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Granola with salty caramel and white chocolate', 'not-applicable', null, 'none', '5902884466024'),
  ('PL', 'Wasa', 'Grocery', 'Breakfast & Grain-Based', 'Pieczywo z pełnoziarnistej mąki żytniej', 'not-applicable', 'Biedronka', 'none', '7300400122054'),
  ('PL', 'Lestello', 'Grocery', 'Breakfast & Grain-Based', 'Chickpea cakes', 'not-applicable', null, 'none', '5902609001400'),
  ('PL', 'Wasa', 'Grocery', 'Breakfast & Grain-Based', 'Wasa Pieczywo chrupkie z błonnikiem', 'not-applicable', 'Stokrotka', 'none', '7300400481441'),
  ('PL', 'Chaber', 'Grocery', 'Breakfast & Grain-Based', 'Maca razowa', 'not-applicable', null, 'none', '5900154000350'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Protein Pancakes', 'not-applicable', null, 'none', '5900437028149')
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
where country = 'PL' and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true
  and product_name not in ('Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'Vitanella Granola z czekoladą', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'Musli prażone z suszoną, słodzoną żurawiną', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 'Dżem truskawkowy', 'Produkt owocowy z brzoskwiń', 'Dżem z Czarnych Porzeczek', 'Dżem wiśniowy', 'Dżem wiśniowy', 'Powidła węgierkowe', 'Powidła wegierkowe', 'Dżem czarna porzeczka', 'Dżem Brzoskwiniowy niskosłodzony', 'Powidła śliwkowe', 'Dżem z truskawek i limonki niskosłodzony', 'Coś na ząb owsianka z jabłkiem i bananem', 'Musli owocowe pożywne śniadanie', 'Musli wyobiałkowe', 'Musli 5 zbóż', 'Musli z czekoladą i orzechami', 'Vitanella Owsianka - śliwka, migdał, żurawina', 'Musli chrupkie bananowe z kawałkami czekolady', 'Coś na Ząb', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 'Owsianka z jabłkiem i cynamonem', 'Płatki owsiane z suszonymi owocami i orzechami', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin', 'Musli z malinami i jeżynami', 'Promienie Słońca Słoneczna granola z orzechami i miodem', 'Drugie śniadanie', 'Pieczywo żytnie chrupkie', 'Dżem malinowy', 'Dżem truskawkowy', 'Łowicz - Dżem Wiśniowy', 'Dżem truskawkowy', 'Dżem Malinowy', 'Extra konfitura z wiśni', 'Dżem 100% z owoców wiśnia', 'Dżem truskawkowy Rapsodia', 'Konfitura z żółtych owoców', 'Dżem brzoskwiniowy super gładki', 'Muesli Protein', 'Banana Chocolate musli', 'Musli z owocami i orzechami', 'Owsianka Mango i Jagody Goji', 'Granola z czekoladą i orzechami', 'Musli premium', 'Owsianka owoce i orzechy', 'Musli Marakuja i Pitaja', 'Owsianka królewska z jabłkiem', 'Muesli z owocami i siemieniem lnianym', 'Dżem wiśniowy o obniżonej zawartości cukru', 'Dżem brzoskwiniowy', 'Dżem z agrestu i kiwi', 'Powidła śliwkowe', 'Borówka cala', 'Eperdzsem', 'Granola chocolate / pieces of chocolate', 'Granola', 'Granola Nut / peanuts & peanut butter', 'Muesli chocolat', 'Muesli for focused ones', 'sante fit granola strawberry and cherry', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 'Baton musli z owocami', 'Musli tropical', 'musli classic', 'Baton musli z orzechami i miodem', 'Purella Super Musli Proteinowe', 'Porridge Orange', 'Crunchy', 'Musli Keto Choco', 'Meusli Fruits et Chocolat Blanc', 'Cosnazab', 'Protein granola', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców', 'Owsianka ananas, kokos', 'Cos na Zab', 'Musli Lo z owocami', 'Owsianka', 'Protein Granola Go On', 'Musli owocowe: polskie owoce', 'Granola klasyczna z kokosem', 'Fruit Granola', 'Muesli crunchy', 'Muesli z owocami i orzechami', 'Granola z kakao i orzechami', 'purella superfoods granola', 'Granola with salty caramel and white chocolate', 'Pieczywo z pełnoziarnistej mąki żytniej', 'Chickpea cakes', 'Wasa Pieczywo chrupkie z błonnikiem', 'Maca razowa', 'Protein Pancakes');
