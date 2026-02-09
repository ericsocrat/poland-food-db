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
    ('Harnaś', 'Harnaś jasne pełne', 0),
    ('Karmi', 'Karmi o smaku żurawina', 1),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 0),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 0),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 0),
    ('Lomża', 'Łomża jasne', 0),
    ('Kompania Piwowarska', 'Kozel cerny', 0),
    ('Lech', 'Lech Premium', 0),
    ('Łomża', 'Bière sans alcool', 0),
    ('Kompania Piwowarska', 'Lech free', 0),
    ('Carlsberg', 'Pilsner 0.0%', 0),
    ('Lech', 'Lech Free Lime Mint', 0),
    ('Christkindl', 'Christkindl Glühwein', 1),
    ('Heineken', 'Heineken Beer', 0),
    ('Ikea', 'Glühwein', 3),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 0)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
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
    ('Harnaś', 'Harnaś jasne pełne', 'NOT-APPLICABLE'),
    ('Karmi', 'Karmi o smaku żurawina', 'NOT-APPLICABLE'),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 'NOT-APPLICABLE'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'NOT-APPLICABLE'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'NOT-APPLICABLE'),
    ('Lomża', 'Łomża jasne', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Kozel cerny', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Premium', 'NOT-APPLICABLE'),
    ('Łomża', 'Bière sans alcool', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Lech free', 'NOT-APPLICABLE'),
    ('Carlsberg', 'Pilsner 0.0%', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Free Lime Mint', 'NOT-APPLICABLE'),
    ('Christkindl', 'Christkindl Glühwein', 'NOT-APPLICABLE'),
    ('Heineken', 'Heineken Beer', 'NOT-APPLICABLE'),
    ('Ikea', 'Glühwein', 'NOT-APPLICABLE'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'NOT-APPLICABLE')
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
    ('Harnaś', 'Harnaś jasne pełne', 3),
    ('Karmi', 'Karmi o smaku żurawina', 4),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 4),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 4),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 3),
    ('Lomża', 'Łomża jasne', 4),
    ('Kompania Piwowarska', 'Kozel cerny', 3),
    ('Lech', 'Lech Premium', 3),
    ('Łomża', 'Bière sans alcool', 4),
    ('Kompania Piwowarska', 'Lech free', 4),
    ('Carlsberg', 'Pilsner 0.0%', 4),
    ('Lech', 'Lech Free Lime Mint', 4),
    ('Christkindl', 'Christkindl Glühwein', 4),
    ('Heineken', 'Heineken Beer', 3),
    ('Ikea', 'Glühwein', 4),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 3)
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
