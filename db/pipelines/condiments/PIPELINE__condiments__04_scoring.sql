-- PIPELINE (Condiments): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Condiments'
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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
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

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;
