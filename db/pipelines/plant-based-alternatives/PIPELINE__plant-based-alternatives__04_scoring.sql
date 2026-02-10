-- PIPELINE (Plant-Based & Alternatives): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Biedronka', 'Wyborny olej słonecznikowy', 0),
    ('Lubella', 'Makaron Lubella Pióra nr 17', 0),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 1),
    ('Go Vege', 'Parówki sojowe klasyczne', 4),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 3),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 0),
    ('Lubella', 'Świderki', 0),
    ('Plony natury', 'Mąka orkiszowa pełnoziarnista typ 2000', 0),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 0),
    ('Unknown', 'Mąka kukurydziana', 0),
    ('Komagra', 'Polski olej rzepakowy', 0),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 0),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 0),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 0),
    ('Dr. Oetker', 'KASZKA manna z malinami', 0),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 0),
    ('Kujawski', 'Olej 3 ziarna', 0),
    ('Dawtona', 'Koncentrat pomidorowy', 0),
    ('Sante', 'Extra thin corn cakes', 0),
    ('Go Vege', 'Tofu Wędzone', 0),
    ('AntyBaton', 'Antybaton Choco Nuts', 0),
    ('AntyBaton', 'Antybaton Choco Coco', 0),
    ('Culineo', 'Passata klasyczna', 0),
    ('Kamis', 'cynamon', 0),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 0),
    ('Plony Natury', 'Kasza bulgur', 0),
    ('Heinz', 'Heinz beanz', 0),
    ('Pudliszki', 'Koncentrat pomidorowy', 0),
    ('Lidl', 'Mąka pszenna typ 650', 0),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 0),
    ('Pano', 'Wafle kukurydziane', 0),
    ('Polsoja', 'TOFU naturalne', 1),
    ('Kujawski', 'Olej z lnu', 0),
    ('Unknown', 'Pastani Makaron', 0),
    ('Tymbark', 'Tymbark mus mango', 0),
    ('Gustobello', 'Gnocchi', 0),
    ('Vita D''or', 'Rapsöl', 0),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 0),
    ('go VEGE', 'Tofu sweet chili', 2),
    ('Primadonna', 'Olivenöl (nativ, extra)', 0),
    ('Vemondo', 'Tofu naturalne', 2),
    ('GoVege', 'Tofu naturalne', 2),
    ('Garden Gourmet', 'Veggie Balls', 1),
    ('MONINI', 'Oliwa z oliwek', 0),
    ('Tastino', 'Wafle Kukurydziane', 0),
    ('Gallo', 'Olive Oil', 0),
    ('Dania Express', 'Lasaña', 2),
    ('El toro rojo', 'oliwki zielone drylowane', 3),
    ('GustoBello', 'Gnocchi di patate', 2),
    ('Violife', 'Cheddar flavour slices', 3),
    ('Unknown', 'Oliwa z Oliwek', 0)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.2'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
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
    ('go VEGE', 'Tofu sweet chili', 'C'),
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA + processing risk
update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Unknown'
  end
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
    ('go VEGE', 'Tofu sweet chili', '4'),
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;
