-- PIPELINE (Nuts, Seeds & Legumes): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5905617001561', '5900749430043', '5900617041807', '5900587043504', '5900775200627', '5904917980057', '5900587042545', '5901125006296', '5905617002544', '5900571000070', '5905617002766', '5900571001039', '5908235949116', '5900749440639', '5900571100909', '5900749010337', '5900587019288', '5902115193187', '5902451106032', '5900571101975', '5900571001206', '5905027000192', '5900587042514', '5900571101005', '5902751531237', '5902315400757', '5906721136910', '5905784358062', '5900571000025', '5900587043122', '5900571103436', '5900749440646', '5905617002650', '5900571902275', '5905617001769', '5900571902299', '5905617003558', '5900571904774', '5905617002537', '5905617002520', '5905617001905', '5900571904781', '5900775200931', '5905617001127', '5900571001176', '5900587043696', '5900587044105', '20984205', '5900571103948', '5905617002780')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'BakaD''Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka orzechów prażonych', 'not-applicable', 'Biedronka', 'none', '5905617001561'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistacje niesolone prażone', 'roasted', 'Biedronka', 'none', '5900749430043'),
  ('PL', 'Top', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy ziemne prażone nieslone', 'roasted', 'Biedronka', 'none', '5900617041807'),
  ('PL', 'Bakallino', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały', 'not-applicable', 'Biedronka', 'none', '5900587043504'),
  ('PL', 'Makar Bakalie', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały', 'not-applicable', 'Auchan', 'none', '5900775200627'),
  ('PL', 'Top', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone smak ostra papryka', 'roasted', 'Biedronka', 'none', '5904917980057'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'BakaDOr. Orzechy włoskie', 'not-applicable', 'Biedronka', 'none', '5900587042545'),
  ('PL', 'Spar', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone', 'roasted', null, 'none', '5901125006296'),
  ('PL', 'Baka D''or', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy włoskie', 'not-applicable', 'Biedronka', 'none', '5905617002544'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone bez soli', 'roasted', null, 'none', '5900571000070'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne smażone i solone', 'fried', null, 'none', '5900571001039'),
  ('PL', 'DJ Snack', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 'fried', null, 'none', '5908235949116'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy włoskie', 'not-applicable', null, 'none', '5900749440639'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki długo prażone extra chrupkie', 'roasted', null, 'none', '5900571100909'),
  ('PL', 'Bakalland', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy makadamia łuskane', 'not-applicable', null, 'none', '5900749010337'),
  ('PL', 'Bakallino', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały łuskane', 'not-applicable', null, 'none', '5900587019288'),
  ('PL', 'Unknown', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy nerkowca połówki', 'not-applicable', null, 'none', '5902115193187'),
  ('PL', 'Kresto', 'Grocery', 'Nuts, Seeds & Legumes', 'Mix orzechów', 'not-applicable', null, 'none', '5902451106032'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Carmelove z wiórkami kokosowymi', 'not-applicable', null, 'none', '5900571101975'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone', 'roasted', null, 'none', '5900571001206'),
  ('PL', 'Aga Holtex', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały', 'not-applicable', null, 'none', '5905027000192'),
  ('PL', 'BakaD’Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały łuskane kalifornijskie', 'not-applicable', null, 'none', '5900587042514'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki z pieca z solą', 'not-applicable', null, 'none', '5900571101005'),
  ('PL', 'Ecobi', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy włoskie łuskane', 'dried', null, 'none', '5902751531237'),
  ('PL', 'Green Essence', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały naturalne całe', 'not-applicable', null, 'none', '5902315400757'),
  ('PL', 'brat.pl', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy brazylijskie połówki', 'not-applicable', null, 'none', '5906721136910'),
  ('PL', 'Carrefour Extra', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały łuskane', 'not-applicable', null, 'none', '5905784358062'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Felix orzeszki ziemne', 'not-applicable', 'Biedronka', 'none', '5900571000025'),
  ('PL', 'BakaD''Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka egzotyczna', 'dried', 'Biedronka', 'none', '5900587043122'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne lekko solone', 'not-applicable', 'Biedronka', 'none', '5900571103436'),
  ('PL', 'BakaD''Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy Nerkowca', 'not-applicable', 'Biedronka', 'none', '5900749440646'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy pekan', 'not-applicable', 'Biedronka', 'none', '5905617002650'),
  ('PL', 'Top', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki Top smak papryka', 'not-applicable', 'Biedronka', 'none', '5900571902275'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka orzechowa', 'not-applicable', 'Biedronka', 'none', '5905617001769'),
  ('PL', 'Top Biedronka', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone', 'roasted', null, 'none', '5900571902299'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy brazylijskie', 'not-applicable', 'Biedronka', 'none', '5905617003558'),
  ('PL', 'Asia Flavours', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne w skorupce o smaku wasabi', 'not-applicable', 'Biedronka', 'none', '5900571904774'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy nerkowca', 'not-applicable', 'Biedronka', 'none', '5905617002537'),
  ('PL', 'Unknown', 'Grocery', 'Nuts, Seeds & Legumes', 'Migdały łuskane', 'not-applicable', null, 'none', '5905617002520'),
  ('PL', 'Helio S.A.', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka Studencka', 'dried', 'Biedronka', 'none', '5905617001905'),
  ('PL', 'Asia Flavours', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne w skorupce o smaku curry', 'not-applicable', 'Biedronka', 'none', '5900571904781'),
  ('PL', 'Makar', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy Brazylijskie', 'not-applicable', 'Auchan', 'none', '5900775200931'),
  ('PL', 'Spar', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka Studencka', 'dried', null, 'none', '5905617001127'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne solone', 'not-applicable', null, 'none', '5900571001176'),
  ('PL', 'Alesto Lidl', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone, niesolone', 'not-applicable', 'Lidl', 'none', '20984205'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'FUSION Peanuts love Curry Orient Style', 'not-applicable', null, 'none', '5900571103948')
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
where country = 'PL' and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true
  and product_name not in ('Mieszanka orzechów prażonych', 'Pistacje niesolone prażone', 'Orzechy ziemne prażone nieslone', 'Migdały', 'Migdały', 'Orzeszki ziemne prażone smak ostra papryka', 'BakaDOr. Orzechy włoskie', 'Orzeszki ziemne prażone', 'Orzechy włoskie', 'Orzeszki ziemne prażone bez soli', 'migdały', 'Orzeszki ziemne smażone i solone', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 'Orzechy włoskie', 'Orzeszki długo prażone extra chrupkie', 'Orzechy makadamia łuskane', 'Migdały łuskane', 'Orzechy nerkowca połówki', 'Mix orzechów', 'Carmelove z wiórkami kokosowymi', 'Orzeszki ziemne prażone', 'Migdały', 'Migdały łuskane kalifornijskie', 'Orzeszki z pieca z solą', 'Orzechy włoskie łuskane', 'Migdały naturalne całe', 'Orzechy brazylijskie połówki', 'Migdały łuskane', 'Felix orzeszki ziemne', 'Mieszanka egzotyczna', 'Orzeszki ziemne lekko solone', 'Orzechy Nerkowca', 'Orzechy pekan', 'Orzeszki Top smak papryka', 'Mieszanka orzechowa', 'Orzeszki ziemne prażone', 'Orzechy brazylijskie', 'Orzeszki ziemne w skorupce o smaku wasabi', 'Orzechy nerkowca', 'Migdały łuskane', 'Mieszanka Studencka', 'Orzeszki ziemne w skorupce o smaku curry', 'Orzechy Brazylijskie', 'Mieszanka Studencka', 'Orzeszki ziemne solone', 'Orzechy pekan', 'Mieszanka Orzechowa', 'Orzeszki ziemne prażone, niesolone', 'FUSION Peanuts love Curry Orient Style', 'Orzechy nerkowca');
