-- PIPELINE (Condiments): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Kotlin', 'Ketchup Łagodny', 2),
    ('Heinz', 'Ketchup łagodny', 0),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 0),
    ('Roleski', 'Ketchup łagodny markowy', 0),
    ('Pudliszki', 'Ketchup Łagodny Premium', 0),
    ('Kamis', 'Ketchup włoski', 1),
    ('Pudliszki', 'Ketchup łagodny', 0),
    ('Kotlin', 'Ketchup łagodny', 3),
    ('Roleski', 'Ketchup Premium Łagodny', 1),
    ('Madero', 'Ketchup Łagodny', 0),
    ('Roleski', 'Musztarda Stołowa', 0),
    ('Kotlin', 'Ketchup hot', 2),
    ('Madero', 'Ketchup junior', 0),
    ('Madero', 'Ketchup pikantny', 0),
    ('Roleski', 'Ketchup Premium', 0),
    ('Roleski', 'Ketchup premium Pikantny', 0),
    ('Madero', 'Premium ketchup pikantny', 0),
    ('Kamis', 'Musztarda sarepska ostra', 1),
    ('Firma Roleski', 'Mutarde', 0),
    ('Spolem', 'Spo?e Musztarda Delikatesowa 190Ml', 1),
    ('Unknown', 'Musztarda stołowa', 0),
    ('Heinz', 'Heinz Zero Sel Ajoute', 2),
    ('Pudliszki', 'ketchup pikantny', 0),
    ('Pudliszki', 'Ketchup pikantny', 0),
    ('Pudliszki', 'Ketchup Lagodny', 0),
    ('Roleski', 'Ketchup premium sycylijski KETO do pizzy', 1),
    ('Heinz', 'Ketchup pikantny', 0),
    ('Wloclawek', 'Wloclawek Mild Tomato Ketchup', 1)
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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Kotlin', 'Ketchup Łagodny', 'D'),
    ('Heinz', 'Ketchup łagodny', 'D'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 'C'),
    ('Roleski', 'Ketchup łagodny markowy', 'D'),
    ('Pudliszki', 'Ketchup Łagodny Premium', 'D'),
    ('Kamis', 'Ketchup włoski', 'D'),
    ('Pudliszki', 'Ketchup łagodny', 'D'),
    ('Kotlin', 'Ketchup łagodny', 'C'),
    ('Roleski', 'Ketchup Premium Łagodny', 'C'),
    ('Madero', 'Ketchup Łagodny', 'D'),
    ('Roleski', 'Musztarda Stołowa', 'D'),
    ('Kotlin', 'Ketchup hot', 'D'),
    ('Madero', 'Ketchup junior', 'D'),
    ('Madero', 'Ketchup pikantny', 'E'),
    ('Roleski', 'Ketchup Premium', 'D'),
    ('Roleski', 'Ketchup premium Pikantny', 'D'),
    ('Madero', 'Premium ketchup pikantny', 'D'),
    ('Kamis', 'Musztarda sarepska ostra', 'D'),
    ('Firma Roleski', 'Mutarde', 'D'),
    ('Spolem', 'Spo?e Musztarda Delikatesowa 190Ml', 'D'),
    ('Unknown', 'Musztarda stołowa', 'E'),
    ('Heinz', 'Heinz Zero Sel Ajoute', 'A'),
    ('Pudliszki', 'ketchup pikantny', 'E'),
    ('Pudliszki', 'Ketchup pikantny', 'E'),
    ('Pudliszki', 'Ketchup Lagodny', 'D'),
    ('Roleski', 'Ketchup premium sycylijski KETO do pizzy', 'C'),
    ('Heinz', 'Ketchup pikantny', 'UNKNOWN'),
    ('Wloclawek', 'Wloclawek Mild Tomato Ketchup', 'D')
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
    ('Kotlin', 'Ketchup Łagodny', 4),
    ('Heinz', 'Ketchup łagodny', 3),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 4),
    ('Roleski', 'Ketchup łagodny markowy', 3),
    ('Pudliszki', 'Ketchup Łagodny Premium', 4),
    ('Kamis', 'Ketchup włoski', 4),
    ('Pudliszki', 'Ketchup łagodny', 4),
    ('Kotlin', 'Ketchup łagodny', 4),
    ('Roleski', 'Ketchup Premium Łagodny', 4),
    ('Madero', 'Ketchup Łagodny', 4),
    ('Roleski', 'Musztarda Stołowa', 3),
    ('Kotlin', 'Ketchup hot', 4),
    ('Madero', 'Ketchup junior', 3),
    ('Madero', 'Ketchup pikantny', 4),
    ('Roleski', 'Ketchup Premium', 3),
    ('Roleski', 'Ketchup premium Pikantny', 3),
    ('Madero', 'Premium ketchup pikantny', 4),
    ('Kamis', 'Musztarda sarepska ostra', 4),
    ('Firma Roleski', 'Mutarde', 3),
    ('Spolem', 'Spo?e Musztarda Delikatesowa 190Ml', 4),
    ('Unknown', 'Musztarda stołowa', 4),
    ('Heinz', 'Heinz Zero Sel Ajoute', 4),
    ('Pudliszki', 'ketchup pikantny', 4),
    ('Pudliszki', 'Ketchup pikantny', 4),
    ('Pudliszki', 'Ketchup Lagodny', 4),
    ('Roleski', 'Ketchup premium sycylijski KETO do pizzy', 4),
    ('Heinz', 'Ketchup pikantny', 4),
    ('Wloclawek', 'Wloclawek Mild Tomato Ketchup', 4)
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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;
