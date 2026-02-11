-- PIPELINE (Alcohol): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true
  and sc.product_id is null;

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  ),
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'NOT-APPLICABLE'),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'UNKNOWN'),
    ('Diamant', 'Cukier Biały', 'E'),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'A'),
    ('Harnaś', 'Harnaś jasne pełne', 'NOT-APPLICABLE'),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 'NOT-APPLICABLE'),
    ('Karmi', 'Karmi o smaku żurawina', 'NOT-APPLICABLE'),
    ('Żywiec', 'Limonż 0%', 'NOT-APPLICABLE'),
    ('Polski Cukier', 'Cukier biały', 'E'),
    ('Lomża', 'Łomża jasne', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Kozel cerny', 'NOT-APPLICABLE'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'NOT-APPLICABLE'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'NOT-APPLICABLE'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'NOT-APPLICABLE'),
    ('Książęce', 'Książęce czerwony lager', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Premium', 'NOT-APPLICABLE'),
    ('Zatecky', 'Zatecky 0%', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Lech free', 'NOT-APPLICABLE'),
    ('Łomża', 'Radler 0,0%', 'NOT-APPLICABLE'),
    ('Łomża', 'Bière sans alcool', 'NOT-APPLICABLE'),
    ('Warka', 'Piwo Warka Radler', 'NOT-APPLICABLE'),
    ('Nestlé', 'Przyprawa Maggi', 'E'),
    ('Gryzzale', 'polutry kabanos sausages', 'UNKNOWN'),
    ('Carlsberg', 'Pilsner 0.0%', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Free Lime Mint', 'NOT-APPLICABLE'),
    ('Amber', 'Amber IPA zero', 'NOT-APPLICABLE'),
    ('Unknown', 'LECH FREE CITRUS SOUR', 'NOT-APPLICABLE'),
    ('Shroom', 'Shroom power', 'NOT-APPLICABLE'),
    ('Christkindl', 'Christkindl Glühwein', 'NOT-APPLICABLE'),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'A'),
    ('Heineken', 'Heineken Beer', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0 White alcoholfree', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0. Red', 'NOT-APPLICABLE'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'NOT-APPLICABLE'),
    ('Ikea', 'Glühwein', 'NOT-APPLICABLE'),
    ('Choya', 'Silver', 'NOT-APPLICABLE'),
    ('Carlo Rossi', 'Vin carlo rossi', 'NOT-APPLICABLE'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 'NOT-APPLICABLE')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', '4'),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', '1'),
    ('Diamant', 'Cukier Biały', '2'),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', '1'),
    ('Harnaś', 'Harnaś jasne pełne', '3'),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', '4'),
    ('Karmi', 'Karmi o smaku żurawina', '4'),
    ('Żywiec', 'Limonż 0%', '4'),
    ('Polski Cukier', 'Cukier biały', '2'),
    ('Lomża', 'Łomża jasne', '4'),
    ('Kompania Piwowarska', 'Kozel cerny', '3'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', '4'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', '3'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', '4'),
    ('Książęce', 'Książęce czerwony lager', '4'),
    ('Lech', 'Lech Premium', '3'),
    ('Zatecky', 'Zatecky 0%', '4'),
    ('Kompania Piwowarska', 'Lech free', '4'),
    ('Łomża', 'Radler 0,0%', '4'),
    ('Łomża', 'Bière sans alcool', '4'),
    ('Warka', 'Piwo Warka Radler', '4'),
    ('Nestlé', 'Przyprawa Maggi', '4'),
    ('Gryzzale', 'polutry kabanos sausages', '4'),
    ('Carlsberg', 'Pilsner 0.0%', '4'),
    ('Lech', 'Lech Free Lime Mint', '4'),
    ('Amber', 'Amber IPA zero', '4'),
    ('Unknown', 'LECH FREE CITRUS SOUR', '3'),
    ('Shroom', 'Shroom power', '4'),
    ('Christkindl', 'Christkindl Glühwein', '4'),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', '4'),
    ('Heineken', 'Heineken Beer', '3'),
    ('Just 0.', 'Just 0 White alcoholfree', '4'),
    ('Just 0.', 'Just 0. Red', '3'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', '3'),
    ('Ikea', 'Glühwein', '4'),
    ('Choya', 'Silver', '3'),
    ('Carlo Rossi', 'Vin carlo rossi', '4'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;
