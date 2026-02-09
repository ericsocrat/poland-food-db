-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906823002342', '5900049006375', '5904194906153', '5901473560303', '5904378645595', '5900012000232', '5900049823026', '5902560393187', '5900766000076', '5906827022049', '5902768584295', '5904730127844', '5906716208707', '5900012004858', '5900437039435', '5903264001460', '5900012003196', '5901713016799', '5900617031969', '8586024420106', '5900397751972', '5900397751996', '5901844101685', '5900084274074', '20809539', '5902481019197', '5900783009090', '5900783003968', '20052652', '8410660081691', '5900125009627', '5901473052013', '5900012007866', '5903077000841', '5900334014450', '5907544131229', '20013578', '8076800105056', '8586024420113', '4056489957652', '4056489067566', '8586024420090', '8445290493125', '80053828', '4056489587026', '5601252115983', '5601009955176', '8410791074227', '4028856011106', '5202390023576', '5601999400014')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Biedronka', 'Grocery', 'Plant-Based & Alternatives', 'Wyborny olej słonecznikowy', null, 'Biedronka', 'none', '5906823002342'),
  ('PL', 'Lubella', 'Grocery', 'Plant-Based & Alternatives', 'Makaron Lubella Pióra nr 17', null, 'Dino', 'none', '5900049006375'),
  ('PL', 'Go Active', 'Grocery', 'Plant-Based & Alternatives', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', null, 'Biedronka', 'none', '5904194906153'),
  ('PL', 'Go Vege', 'Grocery', 'Plant-Based & Alternatives', 'Parówki sojowe klasyczne', null, 'Biedronka', 'none', '5901473560303'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Plant-Based & Alternatives', 'Nasza Spiżarnia Korniszony z chilli', null, 'Biedronka', 'none', '5904378645595'),
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', null, null, 'none', '5900012000232'),
  ('PL', 'Lubella', 'Grocery', 'Plant-Based & Alternatives', 'Świderki', null, null, 'none', '5900049823026'),
  ('PL', 'Plony natury', 'Grocery', 'Plant-Based & Alternatives', 'Mąka orkiszowa pełnoziarnista typ 2000', null, null, 'none', '5902560393187'),
  ('PL', 'Polskie Mlyny', 'Grocery', 'Plant-Based & Alternatives', 'Mąka pszenna Szymanowska 480', null, null, 'none', '5900766000076'),
  ('PL', 'Unknown', 'Grocery', 'Plant-Based & Alternatives', 'Mąka kukurydziana', null, 'Biedronka', 'none', '5906827022049'),
  ('PL', 'Komagra', 'Grocery', 'Plant-Based & Alternatives', 'Polski olej rzepakowy', null, 'Biedronka', 'none', '5902768584295'),
  ('PL', 'Vitanella', 'Grocery', 'Plant-Based & Alternatives', 'Olej kokosowy, bezzapachowy', null, 'Biedronka', 'none', '5904730127844'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat Pomidorowy 30%', null, 'Biedronka', 'none', '5906716208707'),
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej rzepakowy pomidor czosnek bazylia', null, 'Biedronka', 'none', '5900012004858'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Plant-Based & Alternatives', 'KASZKA manna z malinami', null, 'Carrefour', 'none', '5900437039435'),
  ('PL', 'Wyborny Olej', 'Grocery', 'Plant-Based & Alternatives', 'Wyborny olej rzepakowy', null, 'Biedronka', 'none', '5903264001460'),
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej 3 ziarna', null, null, 'none', '5900012003196'),
  ('PL', 'Dawtona', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat pomidorowy', null, null, 'none', '5901713016799'),
  ('PL', 'Sante', 'Grocery', 'Plant-Based & Alternatives', 'Extra thin corn cakes', null, null, 'none', '5900617031969'),
  ('PL', 'Go Vege', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Wędzone', null, 'Biedronka', 'none', '8586024420106'),
  ('PL', 'AntyBaton', 'Grocery', 'Plant-Based & Alternatives', 'Antybaton Choco Nuts', null, null, 'none', '5900397751972'),
  ('PL', 'AntyBaton', 'Grocery', 'Plant-Based & Alternatives', 'Antybaton Choco Coco', null, null, 'none', '5900397751996'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Passata klasyczna', null, null, 'none', '5901844101685'),
  ('PL', 'Kamis', 'Grocery', 'Plant-Based & Alternatives', 'cynamon', null, null, 'none', '5900084274074'),
  ('PL', 'Biedronka', 'Grocery', 'Plant-Based & Alternatives', 'Borówka amerykańska odmiany Brightwell', null, 'Biedronka', 'none', '20809539'),
  ('PL', 'Plony Natury', 'Grocery', 'Plant-Based & Alternatives', 'Kasza bulgur', null, null, 'none', '5902481019197'),
  ('PL', 'Heinz', 'Grocery', 'Plant-Based & Alternatives', 'Heinz beanz', 'baked', null, 'none', '5900783009090'),
  ('PL', 'Pudliszki', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat pomidorowy', null, null, 'none', '5900783003968'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Mąka pszenna typ 650', null, 'Lidl', 'none', '20052652'),
  ('PL', 'Biedronka', 'Grocery', 'Plant-Based & Alternatives', 'Olej z awokado z pierwszego tłoczenia', null, 'Biedronka', 'none', '8410660081691'),
  ('PL', 'Pano', 'Grocery', 'Plant-Based & Alternatives', 'Wafle kukurydziane', null, null, 'none', '5900125009627'),
  ('PL', 'Polsoja', 'Grocery', 'Plant-Based & Alternatives', 'TOFU naturalne', null, null, 'none', '5901473052013'),
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej z lnu', null, null, 'none', '5900012007866'),
  ('PL', 'Unknown', 'Grocery', 'Plant-Based & Alternatives', 'Pastani Makaron', null, null, 'none', '5903077000841'),
  ('PL', 'Tymbark', 'Grocery', 'Plant-Based & Alternatives', 'Tymbark mus mango', null, null, 'none', '5900334014450'),
  ('PL', 'Gustobello', 'Grocery', 'Plant-Based & Alternatives', 'Gnocchi', null, null, 'none', '5907544131229'),
  ('PL', 'Vita D''or', 'Grocery', 'Plant-Based & Alternatives', 'Rapsöl', null, 'Lidl', 'none', '20013578'),
  ('PL', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Pâtes spaghetti n°5 1kg', null, 'Magasins U,carrefour.fr', 'none', '8076800105056'),
  ('PL', 'go VEGE', 'Grocery', 'Plant-Based & Alternatives', 'Tofu sweet chili', null, 'Biedronka', 'none', '8586024420113'),
  ('PL', 'Primadonna', 'Grocery', 'Plant-Based & Alternatives', 'Olivenöl (nativ, extra)', null, 'Lidl', 'none', '4056489957652'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu naturalne', null, 'Lidl', 'none', '4056489067566'),
  ('PL', 'GoVege', 'Grocery', 'Plant-Based & Alternatives', 'Tofu naturalne', null, 'Biedronka', 'none', '8586024420090'),
  ('PL', 'Garden Gourmet', 'Grocery', 'Plant-Based & Alternatives', 'Veggie Balls', null, null, 'none', '8445290493125'),
  ('PL', 'MONINI', 'Grocery', 'Plant-Based & Alternatives', 'Oliwa z oliwek', null, null, 'none', '80053828'),
  ('PL', 'Tastino', 'Grocery', 'Plant-Based & Alternatives', 'Wafle Kukurydziane', null, null, 'none', '4056489587026'),
  ('PL', 'Gallo', 'Grocery', 'Plant-Based & Alternatives', 'Olive Oil', null, null, 'none', '5601252115983'),
  ('PL', 'Dania Express', 'Grocery', 'Plant-Based & Alternatives', 'Lasaña', null, 'Pingo Doce', 'none', '5601009955176'),
  ('PL', 'El toro rojo', 'Grocery', 'Plant-Based & Alternatives', 'oliwki zielone drylowane', null, null, 'none', '8410791074227'),
  ('PL', 'GustoBello', 'Grocery', 'Plant-Based & Alternatives', 'Gnocchi di patate', null, null, 'none', '4028856011106'),
  ('PL', 'Violife', 'Grocery', 'Plant-Based & Alternatives', 'Cheddar flavour slices', null, null, 'none', '5202390023576'),
  ('PL', 'Unknown', 'Grocery', 'Plant-Based & Alternatives', 'Oliwa z Oliwek', null, null, 'none', '5601999400014')
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
where country = 'PL' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Wyborny olej słonecznikowy', 'Makaron Lubella Pióra nr 17', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'Parówki sojowe klasyczne', 'Nasza Spiżarnia Korniszony z chilli', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'Świderki', 'Mąka orkiszowa pełnoziarnista typ 2000', 'Mąka pszenna Szymanowska 480', 'Mąka kukurydziana', 'Polski olej rzepakowy', 'Olej kokosowy, bezzapachowy', 'Koncentrat Pomidorowy 30%', 'Olej rzepakowy pomidor czosnek bazylia', 'KASZKA manna z malinami', 'Wyborny olej rzepakowy', 'Olej 3 ziarna', 'Koncentrat pomidorowy', 'Extra thin corn cakes', 'Tofu Wędzone', 'Antybaton Choco Nuts', 'Antybaton Choco Coco', 'Passata klasyczna', 'cynamon', 'Borówka amerykańska odmiany Brightwell', 'Kasza bulgur', 'Heinz beanz', 'Koncentrat pomidorowy', 'Mąka pszenna typ 650', 'Olej z awokado z pierwszego tłoczenia', 'Wafle kukurydziane', 'TOFU naturalne', 'Olej z lnu', 'Pastani Makaron', 'Tymbark mus mango', 'Gnocchi', 'Rapsöl', 'Pâtes spaghetti n°5 1kg', 'Tofu sweet chili', 'Olivenöl (nativ, extra)', 'Tofu naturalne', 'Tofu naturalne', 'Veggie Balls', 'Oliwa z oliwek', 'Wafle Kukurydziane', 'Olive Oil', 'Lasaña', 'oliwki zielone drylowane', 'Gnocchi di patate', 'Cheddar flavour slices', 'Oliwa z Oliwek');
