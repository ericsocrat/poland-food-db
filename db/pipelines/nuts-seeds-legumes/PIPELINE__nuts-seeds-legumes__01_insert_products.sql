-- PIPELINE (Nuts, Seeds & Legumes): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'BakaD''Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka orzechów prażonych', null, 'Biedronka', 'none', '5905617001561'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone bez soli', null, null, 'none', '5900571000070'),
  ('PL', 'bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'migdały', null, null, 'none', '5905617002766'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne smażone i solone', null, null, 'none', '5900571001527'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Felix orzeszki ziemne', null, 'Biedronka', 'none', '5900571000025'),
  ('PL', 'BakaD''Or', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka egzotyczna', null, 'biedronka', 'none', '5900587043122'),
  ('PL', 'felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne lekko solone', null, 'biedronka', 'none', '5900571103436'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Alesto pörkölt egészmogyoró', null, 'Lidl', 'none', '4335619014404'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne solone', null, null, 'none', '5900571001176'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy pekan', null, null, 'none', '5900587043696'),
  ('PL', 'Alesto Lidl', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzeszki ziemne prażone, niesolone', null, 'lidl', 'none', '20984205'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka Orzechowa', null, null, 'none', '5900587044105'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'FUSION Peanuts love Curry Orient Style', null, null, 'none', '5900571103948'),
  ('PL', 'Felix', 'Grocery', 'Nuts, Seeds & Legumes', 'Peanuts join BBQ-Honey Style', null, null, 'none', '5900571103924'),
  ('PL', 'Bakador', 'Grocery', 'Nuts, Seeds & Legumes', 'Orzechy Nerkowca', null, null, 'none', '5900587042521'),
  ('PL', 'Lidl', 'Grocery', 'Nuts, Seeds & Legumes', 'Mieszanka Orzechów', null, null, 'none', '4056489784289'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Almonds natural', null, 'Lidl', 'none', '20724696'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashewkerne', null, 'Lidl', 'none', '20267605'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Nussmix', null, 'Lidl', 'none', '20047238'),
  ('PL', 'Alesto Selection', 'Grocery', 'Nuts, Seeds & Legumes', 'Walnusskerne naturbelassen', null, 'Lidl', 'none', '20005733'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Noisettes grillées', null, 'Lidl,Monoprix,Auchan,Franprix', 'none', '4056489033042'),
  ('PL', 'Alesto Selection', 'Grocery', 'Nuts, Seeds & Legumes', 'Pecan Nuts natural', null, 'Lidl', 'none', '4056489682677'),
  ('PL', 'Carrefour', 'Grocery', 'Nuts, Seeds & Legumes', 'Cacahuètes grillées sans sel ajouté.', null, 'Carrefour,Carrefour market,carrefour.fr', 'none', '3560071084042'),
  ('PL', 'CARREFOUR CLASSIC''', 'Grocery', 'Nuts, Seeds & Legumes', 'CACAHUÈTES GRILLEES SALEES', null, 'Carrefour,Carrefour market', 'none', '3560071084059'),
  ('PL', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Protein Mix mit Nüssen & Sojabohnen', null, 'Lidl', 'none', '4056489357117'),
  ('PL', 'Carrefour', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistaches grillees', null, 'Carrefour Market,Dia,Carrefour,carrefour.fr', 'none', '3560070223145'),
  ('PL', 'Carrefour', 'Grocery', 'Nuts, Seeds & Legumes', 'Cacahuètes', null, 'Carrefour,Carrefour market, carrefour.fr', 'none', '3560070142224'),
  ('PL', 'Carrefour', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistaches grillées salées', null, 'Carrefour', 'none', '3560071008574')
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
  and product_name not in ('Mieszanka orzechów prażonych', 'Orzeszki ziemne prażone bez soli', 'migdały', 'Orzeszki ziemne smażone i solone', 'Felix orzeszki ziemne', 'Mieszanka egzotyczna', 'Orzeszki ziemne lekko solone', 'Alesto pörkölt egészmogyoró', 'Orzeszki ziemne solone', 'Orzechy pekan', 'Orzeszki ziemne prażone, niesolone', 'Mieszanka Orzechowa', 'FUSION Peanuts love Curry Orient Style', 'Peanuts join BBQ-Honey Style', 'Orzechy Nerkowca', 'Mieszanka Orzechów', 'Almonds natural', 'Cashewkerne', 'Nussmix', 'Walnusskerne naturbelassen', 'Noisettes grillées', 'Pecan Nuts natural', 'Cacahuètes grillées sans sel ajouté.', 'CACAHUÈTES GRILLEES SALEES', 'Protein Mix mit Nüssen & Sojabohnen', 'Pistaches grillees', 'Cacahuètes', 'Pistaches grillées salées');
