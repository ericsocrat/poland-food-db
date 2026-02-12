-- PIPELINE (Plant-Based & Alternatives): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Biedronka', 'Wyborny olej słonecznikowy', 828.0, 92.0, 10.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lubella', 'Makaron Lubella Pióra nr 17', 351.0, 1.4, 0.4, 0, 70.0, 4.2, 3.0, 13.0, 0.0),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 156.0, 7.0, 2.4, 0, 15.0, 1.4, 5.1, 5.8, 1.5),
    ('Go Vege', 'Parówki sojowe klasyczne', 182.0, 10.0, 0.9, 0, 4.9, 1.0, 0.7, 18.0, 1.9),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 17.0, 0.5, 0.1, 0, 1.5, 0.5, 2.0, 1.3, 1.3),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 900.0, 100.0, 7.5, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lubella', 'Świderki', 351.0, 1.4, 0.4, 0, 70.0, 4.2, 3.0, 13.0, 0.0),
    ('Plony natury', 'Mąka orkiszowa pełnoziarnista typ 2000', 335.0, 2.3, 0.5, 0, 59.0, 1.5, 13.0, 13.0, 0.0),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 350.0, 1.5, 0.4, 0, 71.0, 2.2, 2.2, 12.0, 0.0),
    ('Unknown', 'Mąka kukurydziana', 352.0, 2.1, 0.4, 0, 73.0, 0.9, 3.8, 8.3, 0.0),
    ('Komagra', 'Polski olej rzepakowy', 818.0, 91.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 900.0, 100.0, 91.0, 0, 0.5, 0.5, 0.0, 0.5, 0.0),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 116.0, 0.0, 0.0, 0, 21.0, 15.0, 4.4, 3.9, 0.1),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 888.0, 98.0, 6.9, 0, 1.1, 0.9, 0, 0.3, 0.1),
    ('Dr. Oetker', 'KASZKA manna z malinami', 91.0, 0.4, 0.2, 0, 18.6, 9.1, 1.5, 2.8, 0.1),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0, 0, 0.0, 0),
    ('Kujawski', 'Olej 3 ziarna', 900.0, 100.0, 7.6, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Dawtona', 'Koncentrat pomidorowy', 101.0, 0.0, 0.0, 0, 19.0, 16.0, 3.9, 4.3, 0.1),
    ('Sante', 'Extra thin corn cakes', 385.0, 1.7, 0.3, 0, 83.0, 1.4, 2.0, 8.4, 0.6),
    ('Go Vege', 'Tofu Wędzone', 143.0, 8.5, 1.3, 0, 1.5, 0.5, 2.0, 14.0, 1.0),
    ('AntyBaton', 'Antybaton Choco Nuts', 92.0, 3.3, 0.3, 0, 12.0, 11.0, 0, 3.0, 0.0),
    ('AntyBaton', 'Antybaton Choco Coco', 95.0, 3.6, 0.9, 0, 12.0, 11.0, 0, 2.8, 0.0),
    ('Culineo', 'Passata klasyczna', 30.0, 0.2, 0.1, 0, 4.9, 4.1, 1.5, 1.4, 0.3),
    ('Kamis', 'cynamon', 111.0, 0.1, 0, 0, 24.6, 0, 0, 3.0, 0),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 57.0, 0.3, 0.0, 0, 15.0, 15.0, 2.5, 1.0, 0.0),
    ('Plony Natury', 'Kasza bulgur', 348.0, 1.5, 0.6, 0, 70.0, 0.8, 6.2, 11.0, 0.1),
    ('Heinz', 'Heinz beanz', 81.0, 0.4, 0.1, 0, 15.5, 4.3, 3.9, 4.8, 0.6),
    ('Pudliszki', 'Koncentrat pomidorowy', 105.0, 0.5, 0.1, 0, 19.0, 15.0, 3.6, 4.7, 0.1),
    ('Lidl', 'Mąka pszenna typ 650', 346.0, 1.5, 0.4, 0, 70.0, 2.2, 2.1, 12.0, 0.0),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 822.0, 91.4, 15.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Pano', 'Wafle kukurydziane', 380.0, 4.2, 0.6, 0, 71.0, 1.6, 9.0, 10.0, 0.5),
    ('Polsoja', 'TOFU naturalne', 121.0, 7.0, 1.2, 0, 1.4, 0.3, 0, 13.0, 0.0),
    ('Kujawski', 'Olej z lnu', 900.0, 100.0, 9.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Unknown', 'Pastani Makaron', 350.0, 2.7, 0.6, 0, 62.0, 4.3, 8.4, 15.0, 0.0),
    ('Tymbark', 'Tymbark mus mango', 65.0, 0.5, 0.1, 0, 14.0, 13.0, 1.3, 0.5, 0.0),
    ('Gustobello', 'Gnocchi', 142.0, 1.3, 0.8, 0, 28.0, 0, 2.2, 3.2, 0),
    ('Vita D''or', 'Rapsöl', 83.0, 9.2, 0.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 359.0, 2.0, 0.5, 0, 71.0, 3.5, 3.0, 13.0, 0.0),
    ('Primadonna', 'Olivenöl (nativ, extra)', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vemondo', 'Tofu naturalne', 125.0, 7.5, 1.0, 0, 2.3, 0.5, 0.1, 12.0, 0.2),
    ('GoVege', 'Tofu naturalne', 138.0, 8.0, 1.0, 0, 1.5, 0.5, 2.0, 14.0, 0.2),
    ('Garden Gourmet', 'Veggie Balls', 227.0, 14.4, 1.0, 0, 5.2, 3.3, 5.9, 16.2, 1.0),
    ('MONINI', 'Oliwa z oliwek', 828.0, 92.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Tastino', 'Wafle Kukurydziane', 390.0, 4.4, 0.7, 0, 73.0, 0.7, 8.6, 10.4, 0.6),
    ('Gallo', 'Olive Oil', 819.0, 91.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Dania Express', 'Lasaña', 162.0, 8.4, 2.8, 0, 12.8, 1.5, 0.9, 8.0, 0.8),
    ('El toro rojo', 'oliwki zielone drylowane', 82.0, 7.6, 2.0, 0, 0.0, 0.0, 3.7, 1.3, 4.9),
    ('GustoBello', 'Gnocchi di patate', 168.0, 0.2, 0.1, 0, 36.0, 0.2, 0.9, 4.4, 0.8),
    ('Violife', 'Cheddar flavour slices', 285.0, 23.0, 21.0, 0, 20.0, 0.0, 0, 0.0, 2.3),
    ('Unknown', 'Oliwa z Oliwek', 819.0, 89.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    -- ── Batch 2 — plant-based (new) ────────────────────────────────────────────────
    ('Go Vege', 'Tofu sweet chili',  138, 8.0, 1.0, 0, 2.4, 2.0, 2.0, 13, 1.5),       -- OFF
    ('Monini',  'Oliwa z oliwek',    824, 91.6, 12.8, 0, 0, 0, 0, 0, 0)                -- OFF (EVOO standard)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Plant-Based & Alternatives' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
