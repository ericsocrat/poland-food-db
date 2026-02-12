-- PIPELINE (Plant-Based & Alternatives): scoring
-- Generated: 2026-02-09

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update products p set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      p.ingredient_concern_score
  )
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Biedronka', 'Wyborny olej słonecznikowy', 'C'),
    ('Lubella', 'Makaron Lubella Pióra nr 17', 'A'),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'C'),
    ('Go Vege', 'Parówki sojowe klasyczne', 'D'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 'C'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'B'),
    ('Lubella', 'Świderki', 'A'),
    ('Plony natury', 'Mąka orkiszowa pełnoziarnista typ 2000', 'A'),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 'A'),
    ('Unknown', 'Mąka kukurydziana', 'A'),
    ('Komagra', 'Polski olej rzepakowy', 'B'),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 'E'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 'B'),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 'B'),
    ('Dr. Oetker', 'KASZKA manna z malinami', 'B'),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 'UNKNOWN'),
    ('Kujawski', 'Olej 3 ziarna', 'B'),
    ('Dawtona', 'Koncentrat pomidorowy', 'A'),
    ('Sante', 'Extra thin corn cakes', 'C'),
    ('Go Vege', 'Tofu Wędzone', 'B'),
    ('AntyBaton', 'Antybaton Choco Nuts', 'A'),
    ('AntyBaton', 'Antybaton Choco Coco', 'A'),
    ('Culineo', 'Passata klasyczna', 'B'),
    ('Kamis', 'cynamon', 'NOT-APPLICABLE'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 'A'),
    ('Plony Natury', 'Kasza bulgur', 'A'),
    ('Heinz', 'Heinz beanz', 'A'),
    ('Pudliszki', 'Koncentrat pomidorowy', 'A'),
    ('Lidl', 'Mąka pszenna typ 650', 'A'),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 'B'),
    ('Pano', 'Wafle kukurydziane', 'A'),
    ('Polsoja', 'TOFU naturalne', 'A'),
    ('Kujawski', 'Olej z lnu', 'B'),
    ('Unknown', 'Pastani Makaron', 'A'),
    ('Tymbark', 'Tymbark mus mango', 'C'),
    ('Gustobello', 'Gnocchi', 'UNKNOWN'),
    ('Vita D''or', 'Rapsöl', 'B'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'A'),
    ('Go Vege', 'Tofu sweet chili', 'C'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'B'),
    ('Vemondo', 'Tofu naturalne', 'A'),
    ('GoVege', 'Tofu naturalne', 'A'),
    ('Garden Gourmet', 'Veggie Balls', 'A'),
    ('MONINI', 'Oliwa z oliwek', 'B'),
    ('Tastino', 'Wafle Kukurydziane', 'A'),
    ('Gallo', 'Olive Oil', 'B'),
    ('Dania Express', 'Lasaña', 'C'),
    ('El toro rojo', 'oliwki zielone drylowane', 'E'),
    ('GustoBello', 'Gnocchi di patate', 'C'),
    ('Violife', 'Cheddar flavour slices', 'E'),
    ('Unknown', 'Oliwa z Oliwek', 'B')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Biedronka', 'Wyborny olej słonecznikowy', '2'),
    ('Lubella', 'Makaron Lubella Pióra nr 17', '1'),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', '3'),
    ('Go Vege', 'Parówki sojowe klasyczne', '4'),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', '4'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', '4'),
    ('Lubella', 'Świderki', '1'),
    ('Plony natury', 'Mąka orkiszowa pełnoziarnista typ 2000', '1'),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', '1'),
    ('Unknown', 'Mąka kukurydziana', '1'),
    ('Komagra', 'Polski olej rzepakowy', '2'),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', '2'),
    ('Culineo', 'Koncentrat Pomidorowy 30%', '4'),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', '4'),
    ('Dr. Oetker', 'KASZKA manna z malinami', '4'),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', '2'),
    ('Kujawski', 'Olej 3 ziarna', '2'),
    ('Dawtona', 'Koncentrat pomidorowy', '1'),
    ('Sante', 'Extra thin corn cakes', '3'),
    ('Go Vege', 'Tofu Wędzone', '4'),
    ('AntyBaton', 'Antybaton Choco Nuts', '4'),
    ('AntyBaton', 'Antybaton Choco Coco', '4'),
    ('Culineo', 'Passata klasyczna', '4'),
    ('Kamis', 'cynamon', '4'),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', '1'),
    ('Plony Natury', 'Kasza bulgur', '1'),
    ('Heinz', 'Heinz beanz', '4'),
    ('Pudliszki', 'Koncentrat pomidorowy', '1'),
    ('Lidl', 'Mąka pszenna typ 650', '1'),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', '4'),
    ('Pano', 'Wafle kukurydziane', '3'),
    ('Polsoja', 'TOFU naturalne', '4'),
    ('Kujawski', 'Olej z lnu', '2'),
    ('Unknown', 'Pastani Makaron', '4'),
    ('Tymbark', 'Tymbark mus mango', '4'),
    ('Gustobello', 'Gnocchi', '4'),
    ('Vita D''or', 'Rapsöl', '4'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', '1'),
    ('Go Vege', 'Tofu sweet chili', '4'),
    ('Primadonna', 'Olivenöl (nativ, extra)', '2'),
    ('Vemondo', 'Tofu naturalne', '4'),
    ('GoVege', 'Tofu naturalne', '4'),
    ('Garden Gourmet', 'Veggie Balls', '4'),
    ('MONINI', 'Oliwa z oliwek', '2'),
    ('Tastino', 'Wafle Kukurydziane', '3'),
    ('Gallo', 'Olive Oil', '2'),
    ('Dania Express', 'Lasaña', '4'),
    ('El toro rojo', 'oliwki zielone drylowane', '3'),
    ('GustoBello', 'Gnocchi di patate', '4'),
    ('Violife', 'Cheddar flavour slices', '4'),
    ('Unknown', 'Oliwa z Oliwek', '2')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 4. Health-risk flags
update products p set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;
