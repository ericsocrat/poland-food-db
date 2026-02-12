-- PIPELINE (Plant-Based & Alternatives): source provenance
-- Generated: 2026-02-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('AntyBaton', 'Antybaton Choco Coco', 'https://world.openfoodfacts.org/product/5900397751996', '5900397751996'),
    ('AntyBaton', 'Antybaton Choco Nuts', 'https://world.openfoodfacts.org/product/5900397751972', '5900397751972'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'https://world.openfoodfacts.org/product/8076800105056', '8076800105056'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 'https://world.openfoodfacts.org/product/20809539', '20809539'),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 'https://world.openfoodfacts.org/product/8410660081691', '8410660081691'),
    ('Biedronka', 'Wyborny olej słonecznikowy', 'https://world.openfoodfacts.org/product/5906823002342', '5906823002342'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 'https://world.openfoodfacts.org/product/5906716208707', '5906716208707'),
    ('Culineo', 'Passata klasyczna', 'https://world.openfoodfacts.org/product/5901844101685', '5901844101685'),
    ('Dania Express', 'Lasaña', 'https://world.openfoodfacts.org/product/5601009955176', '5601009955176'),
    ('Dawtona', 'Koncentrat pomidorowy', 'https://world.openfoodfacts.org/product/5901713016799', '5901713016799'),
    ('Dr. Oetker', 'KASZKA manna z malinami', 'https://world.openfoodfacts.org/product/5900437039435', '5900437039435'),
    ('Gallo', 'Olive Oil', 'https://world.openfoodfacts.org/product/5601252115983', '5601252115983'),
    ('Garden Gourmet', 'Veggie Balls', 'https://world.openfoodfacts.org/product/8445290493125', '8445290493125'),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'https://world.openfoodfacts.org/product/5904194906153', '5904194906153'),
    ('Go Vege', 'Parówki sojowe klasyczne', 'https://world.openfoodfacts.org/product/5901473560303', '5901473560303'),
    ('Go Vege', 'Tofu naturalne', 'https://world.openfoodfacts.org/product/8586024420090', '8586024420090'),
    ('Go Vege', 'Tofu sweet chili', 'https://world.openfoodfacts.org/product/8586024420113', '8586024420113'),
    ('Go Vege', 'Tofu Wędzone', 'https://world.openfoodfacts.org/product/8586024420106', '8586024420106'),
    ('GustoBello', 'Gnocchi', 'https://world.openfoodfacts.org/product/5907544131229', '5907544131229'),
    ('GustoBello', 'Gnocchi di patate', 'https://world.openfoodfacts.org/product/4028856011106', '4028856011106'),
    ('Heinz', 'Heinz beanz', 'https://world.openfoodfacts.org/product/5900783009090', '5900783009090'),
    ('Komagra', 'Polski olej rzepakowy', 'https://world.openfoodfacts.org/product/5902768584295', '5902768584295'),
    ('Kujawski', 'Olej 3 ziarna', 'https://world.openfoodfacts.org/product/5900012003196', '5900012003196'),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 'https://world.openfoodfacts.org/product/5900012004858', '5900012004858'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'https://world.openfoodfacts.org/product/5900012000232', '5900012000232'),
    ('Kujawski', 'Olej z lnu', 'https://world.openfoodfacts.org/product/5900012007866', '5900012007866'),
    ('Lidl', 'Mąka pszenna typ 650', 'https://world.openfoodfacts.org/product/20052652', '20052652'),
    ('Lubella', 'Makaron Lubella Pióra nr 17', 'https://world.openfoodfacts.org/product/5900049006375', '5900049006375'),
    ('Lubella', 'Świderki', 'https://world.openfoodfacts.org/product/5900049823026', '5900049823026'),
    ('Monini', 'Oliwa z oliwek', 'https://world.openfoodfacts.org/product/80053828', '80053828'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 'https://world.openfoodfacts.org/product/5904378645595', '5904378645595'),
    ('Pano', 'Wafle kukurydziane', 'https://world.openfoodfacts.org/product/5900125009627', '5900125009627'),
    ('Plony Natury', 'Kasza bulgur', 'https://world.openfoodfacts.org/product/5902481019197', '5902481019197'),
    ('Plony Natury', 'Mąka orkiszowa pełnoziarnista typ 2000', 'https://world.openfoodfacts.org/product/5902560393187', '5902560393187'),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 'https://world.openfoodfacts.org/product/5900766000076', '5900766000076'),
    ('Polsoja', 'TOFU naturalne', 'https://world.openfoodfacts.org/product/5901473052013', '5901473052013'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'https://world.openfoodfacts.org/product/4056489957652', '4056489957652'),
    ('Pudliszki', 'Koncentrat pomidorowy', 'https://world.openfoodfacts.org/product/5900783003968', '5900783003968'),
    ('Sante', 'Extra thin corn cakes', 'https://world.openfoodfacts.org/product/5900617031969', '5900617031969'),
    ('Tymbark', 'Tymbark mus mango', 'https://world.openfoodfacts.org/product/5900334014450', '5900334014450'),
    ('Unknown', 'Mąka kukurydziana', 'https://world.openfoodfacts.org/product/5906827022049', '5906827022049'),
    ('Unknown', 'Oliwa z Oliwek', 'https://world.openfoodfacts.org/product/5601999400014', '5601999400014'),
    ('Unknown', 'Pastani Makaron', 'https://world.openfoodfacts.org/product/5903077000841', '5903077000841'),
    ('Vemondo', 'Tofu naturalne', 'https://world.openfoodfacts.org/product/4056489067566', '4056489067566'),
    ('Violife', 'Cheddar flavour slices', 'https://world.openfoodfacts.org/product/5202390023576', '5202390023576'),
    ('Vita D''or', 'Rapsöl', 'https://world.openfoodfacts.org/product/20013578', '20013578'),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 'https://world.openfoodfacts.org/product/5904730127844', '5904730127844'),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 'https://world.openfoodfacts.org/product/5903264001460', '5903264001460')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;
