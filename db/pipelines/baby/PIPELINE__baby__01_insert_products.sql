-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Baby'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900910010906', '5907069000017', '5901958612367', '5901958612343', '5900512300054', '5900449006913', '5900852150005', '5900852041129', '5906340630011', '5900531004025', '5901958614521', '5901067404440', '5901958614606', '5901939006031', '5900085010886', '5901398069974', '5900562485213', '5900672220643', '5900910010784', '5902136817550', '5900085011180', '5908230514647', '5909000920620', '5901958614408', '5908230535994', '5901958612374', '5901414204747', '9062300126638', '7613033629303', '9062300130833', '7613035507142', '8591119253835', '4062300279773', '5900783009960', '5900084237895', '5908230522598', '5908226815710', '5905741540004', '8595588201182', '5604127000216', '5201049132584', '40893358', '7613287666819', '9062300109365', '22009326', '8595588200697', '7613036599009', '8595588200727', '4056489784043')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Magnetic', 'Grocery', 'Baby', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', null, 'Biedronka', 'none', '5900910010906'),
  ('PL', 'Diamant', 'Grocery', 'Baby', 'Cukier Biały', null, 'Kaufland', 'none', '5907069000017'),
  ('PL', 'owolovo', 'Grocery', 'Baby', 'Truskawkowo Mus jabłkowo-truskawkowy', null, 'Lidl,Biedronka,Carrefour,Aldi,Selgros,Kaufland', 'none', '5901958612367'),
  ('PL', 'OwoLovo', 'Grocery', 'Baby', 'OwoLowo Jabłkowo', null, 'Biedronka', 'none', '5901958612343'),
  ('PL', 'Mlekovita', 'Grocery', 'Baby', 'Bezwodny tłuszcz mleczny, Masło klarowane', null, 'Lidl', 'none', '5900512300054'),
  ('PL', 'Vital Fresh', 'Grocery', 'Baby', 'Surówka Smakołyk', null, 'Biedronka', 'none', '5900449006913'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Pomidorowa z kurczakiem i ryżem', null, null, 'none', '5900852150005'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', null, null, 'none', '5900852041129'),
  ('PL', 'Polski Cukier', 'Grocery', 'Baby', 'Cukier biały', null, null, 'none', '5906340630011'),
  ('PL', 'Piątnica', 'Grocery', 'Baby', 'Twaróg wiejski tłusty', null, null, 'none', '5900531004025'),
  ('PL', 'Vital Fresh', 'Grocery', 'Baby', 'Mus 100% owoców jabłko gruszka', null, null, 'none', '5901958614521'),
  ('PL', 'kubuś', 'Grocery', 'Baby', 'kubuś malina', null, null, 'none', '5901067404440'),
  ('PL', 'owolovo', 'Grocery', 'Baby', 'mus jabłkowo-malinowo', null, null, 'none', '5901958614606'),
  ('PL', 'Piątnica', 'Grocery', 'Baby', 'Koktajl z białkiem serwatkowym', null, null, 'none', '5901939006031'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Barszcz czerwony', null, 'Carrefour', 'none', '5900085010886'),
  ('PL', 'Swojska Chata', 'Grocery', 'Baby', 'Pierogi ruskie', null, 'Biedronka', 'none', '5901398069974'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Baby', 'POLĘDWICA SOPOCKA', null, null, 'none', '5900562485213'),
  ('PL', 'Kapitan navi', 'Grocery', 'Baby', 'Śledzie po kołobrzesku', null, null, 'none', '5900672220643'),
  ('PL', 'Magnetic', 'Grocery', 'Baby', 'QuickCao', null, 'Biedronka', 'none', '5900910010784'),
  ('PL', 'Królewski', 'Grocery', 'Baby', 'Cukier 1 kg', null, 'Tesco', 'none', '5902136817550'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Przyprawa Maggi', null, null, 'none', '5900085011180'),
  ('PL', 'Gryzzale', 'Grocery', 'Baby', 'polutry kabanos sausages', null, null, 'none', '5908230514647'),
  ('PL', 'Dania Express Biedronka', 'Grocery', 'Baby', 'Lasagne Bolognese', null, null, 'none', '5909000920620'),
  ('PL', 'Owolovo', 'Grocery', 'Baby', 'Owolovo ananasowo', null, null, 'none', '5901958614408'),
  ('PL', 'Tarczyński', 'Grocery', 'Baby', 'Kabanosy Z Kurczaka Protein', null, null, 'none', '5908230535994'),
  ('PL', 'OWOLOVO', 'Grocery', 'Baby', 'BRZOSKWINIOWO', null, null, 'none', '5901958612374'),
  ('PL', 'Leibniz', 'Grocery', 'Baby', 'Minis classic', null, null, 'none', '5901414204747'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', null, null, 'none', '9062300126638'),
  ('PL', 'Nestle Gerber', 'Grocery', 'Baby', 'owoce jabłka z truskawkami i jagodami', null, null, 'none', '7613033629303'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Spaghetti z pomidorami i mozzarellą', null, null, 'none', '9062300130833'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Leczo z mozzarellą i kluseczkami', null, null, 'none', '7613035507142'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'BoboVita Jabłka z marchewka', null, null, 'none', '8591119253835'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Kaszka mleczna z biszkoptami i jabłkami', null, null, 'none', '4062300279773'),
  ('PL', 'Pudliszki', 'Grocery', 'Baby', 'Pudliszki', null, null, 'none', '5900783009960'),
  ('PL', 'Kamis', 'Grocery', 'Baby', 'Kamis Musztarda Kremska 185G.', null, null, 'none', '5900084237895'),
  ('PL', 'tarczyński', 'Grocery', 'Baby', 'gryzzale', null, null, 'none', '5908230522598'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Baby', '5908226815710', null, null, 'none', '5908226815710'),
  ('PL', 'Hyperfood', 'Grocery', 'Baby', 'Eatyx Wanilla', null, null, 'none', '5905741540004'),
  ('PL', 'GO ACTIVE', 'Grocery', 'Baby', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', null, 'Biedronka', 'none', '8595588201182'),
  ('PL', 'Vitanella', 'Grocery', 'Baby', 'Ciastka Czekolada & Zboża', null, null, 'none', '5604127000216'),
  ('PL', 'Vitanella', 'Grocery', 'Baby', 'Baton select orzeszki ziemne, migdały, sól morska', null, null, 'none', '5201049132584'),
  ('PL', 'Maribel', 'Grocery', 'Baby', 'Ahorn sirup', null, 'Lidl', 'none', '40893358'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Nestle Sinlac', null, null, 'none', '7613287666819'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Dynia z indykiem', null, null, 'none', '9062300109365'),
  ('PL', 'GutBio', 'Grocery', 'Baby', 'Puré de Frutas Manzana y Plátano', null, 'Aldi', 'none', '22009326'),
  ('PL', 'Go active', 'Grocery', 'Baby', 'Pudding proteinowy', null, null, 'none', '8595588200697'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Bulion drobiowy', null, null, 'none', '7613036599009'),
  ('PL', 'GO Active', 'Grocery', 'Baby', 'pudding czekolada', null, null, 'none', '8595588200727'),
  ('PL', 'Tastino', 'Grocery', 'Baby', 'Papryka Barbecue', null, null, 'none', '4056489784043')
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
where country = 'PL' and category = 'Baby'
  and is_deprecated is not true
  and product_name not in ('Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'Cukier Biały', 'Truskawkowo Mus jabłkowo-truskawkowy', 'OwoLowo Jabłkowo', 'Bezwodny tłuszcz mleczny, Masło klarowane', 'Surówka Smakołyk', 'Pomidorowa z kurczakiem i ryżem', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'Cukier biały', 'Twaróg wiejski tłusty', 'Mus 100% owoców jabłko gruszka', 'kubuś malina', 'mus jabłkowo-malinowo', 'Koktajl z białkiem serwatkowym', 'Barszcz czerwony', 'Pierogi ruskie', 'POLĘDWICA SOPOCKA', 'Śledzie po kołobrzesku', 'QuickCao', 'Cukier 1 kg', 'Przyprawa Maggi', 'polutry kabanos sausages', 'Lasagne Bolognese', 'Owolovo ananasowo', 'Kabanosy Z Kurczaka Protein', 'BRZOSKWINIOWO', 'Minis classic', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'owoce jabłka z truskawkami i jagodami', 'Spaghetti z pomidorami i mozzarellą', 'Leczo z mozzarellą i kluseczkami', 'BoboVita Jabłka z marchewka', 'Kaszka mleczna z biszkoptami i jabłkami', 'Pudliszki', 'Kamis Musztarda Kremska 185G.', 'gryzzale', '5908226815710', 'Eatyx Wanilla', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'Ciastka Czekolada & Zboża', 'Baton select orzeszki ziemne, migdały, sól morska', 'Ahorn sirup', 'Nestle Sinlac', 'Dynia z indykiem', 'Puré de Frutas Manzana y Plátano', 'Pudding proteinowy', 'Bulion drobiowy', 'pudding czekolada', 'Papryka Barbecue');
