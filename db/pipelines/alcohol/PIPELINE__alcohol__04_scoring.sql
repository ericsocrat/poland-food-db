-- PIPELINE (Alcohol): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 4),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 1),
    ('Diamant', 'Cukier Biały', 0),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 0),
    ('Harnaś', 'Harnaś jasne pełne', 0),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 0),
    ('Karmi', 'Karmi o smaku żurawina', 1),
    ('Żywiec', 'Limonż 0%', 0),
    ('Polski Cukier', 'Cukier biały', 0),
    ('Lomża', 'Łomża jasne', 0),
    ('Kompania Piwowarska', 'Kozel cerny', 0),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 0),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 0),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 0),
    ('Książęce', 'Książęce czerwony lager', 0),
    ('Lech', 'Lech Premium', 0),
    ('Zatecky', 'Zatecky 0%', 0),
    ('Kompania Piwowarska', 'Lech free', 0),
    ('Łomża', 'Radler 0,0%', 2),
    ('Łomża', 'Bière sans alcool', 0),
    ('Warka', 'Piwo Warka Radler', 4),
    ('Nestlé', 'Przyprawa Maggi', 2),
    ('Gryzzale', 'polutry kabanos sausages', 1),
    ('Carlsberg', 'Pilsner 0.0%', 0),
    ('Lech', 'Lech Free Lime Mint', 0),
    ('Amber', 'Amber IPA zero', 0),
    ('Unknown', 'LECH FREE CITRUS SOUR', 0),
    ('Shroom', 'Shroom power', 0),
    ('Christkindl', 'Christkindl Glühwein', 1),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 4),
    ('Heineken', 'Heineken Beer', 0),
    ('Just 0.', 'Just 0 White alcoholfree', 3),
    ('Just 0.', 'Just 0. Red', 1),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 0),
    ('Ikea', 'Glühwein', 3),
    ('Choya', 'Silver', 0),
    ('Carlo Rossi', 'Vin carlo rossi', 0),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 0)
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
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
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
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;
