-- PIPELINE (Condiments): scoring
-- Generated: 2026-02-11

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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Kotlin', 'Ketchup Łagodny', 'D'),
    ('Heinz', 'Ketchup łagodny', 'D'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 'C'),
    ('Pudliszki', 'Ketchup Łagodny Premium', 'D'),
    ('Roleski', 'Ketchup łagodny markowy', 'D'),
    ('Kotliński specjał', 'Ketchup łagodny', 'D'),
    ('Pudliszki', 'Ketchup łagodny Pudliszek', 'E'),
    ('Agro Nova Food', 'Ketchup pikantny z pomidorów z Kujaw', 'D'),
    ('Dawtona', 'Ketchup łagodny', 'E'),
    ('Kamis', 'Ketchup włoski', 'D'),
    ('Tomatini', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup markowy łagodny', 'D'),
    ('Madero', 'Ketchup łagodny', 'D'),
    ('Unknown', 'Ketchup łagodny', 'D'),
    ('Pegaz', 'Musztarda stołowa', 'D'),
    ('Pudliszki', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup Premium Łagodny', 'C'),
    ('Roleski', 'Ketchup premium meksykański KETO', 'C'),
    ('Międzychód', 'Ketchup łagodny', 'C'),
    ('Na Szlaku Smaku', 'Ketchup łagodny', 'E'),
    ('Polskie przetwory', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup łagodny', 'D'),
    ('Kotlin', 'Ketchup z truskawką', 'D'),
    ('Reypol', 'Ketchup Ziołowy Premium z Nasionami Konopi', 'D'),
    ('Reypol', 'Ketchup premium łagodny', 'D'),
    ('Lewiatan', 'Ketchup Łagodny', 'C'),
    ('Kotliński', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Musztarda Stołowa', 'D'),
    ('Kotlin', 'Ketchup hot', 'D'),
    ('Madero', 'Ketchup pikantny', 'E'),
    ('Madero', 'Ketchup junior', 'D'),
    ('Roleski', 'Ketchup Premium', 'D'),
    ('Kotlin sp. z o. o', 'Ketchup kotliński', 'D'),
    ('Develey', 'Ketchup z dodatkiem miodu, czosnku i tymianku', 'D'),
    ('Dawtona', 'Ketchup pikantny', 'D'),
    ('Włocławek', 'Ketchup', 'D'),
    ('Roleski', 'Ketchup premium Pikantny', 'D'),
    ('Roleski', 'Ketchup premium jalapeño KETO', 'C'),
    ('Kotlin', 'Kotlin Ketchup Premium', 'D'),
    ('Madero', 'Premium ketchup pikantny', 'D'),
    ('Kotlin', 'Ketchup pikantny', 'D'),
    ('Madero', 'Ketchup classic', 'D'),
    ('Fenex', 'Ketchup nr. VII', 'E'),
    ('Fenex', 'Ketchup nr VII', 'E'),
    ('Włocławek', 'Ketchup pikantny', 'D'),
    ('Krajowa Spółka Cukrowa', 'Ketchup lagoduy', 'UNKNOWN'),
    ('Pudliszki', 'Ketchup Super Pikantny', 'E'),
    ('Develey', 'Ketchup Pikantny', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Kotlin', 'Ketchup Łagodny', '4'),
    ('Heinz', 'Ketchup łagodny', '3'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', '4'),
    ('Pudliszki', 'Ketchup Łagodny Premium', '4'),
    ('Roleski', 'Ketchup łagodny markowy', '3'),
    ('Kotliński specjał', 'Ketchup łagodny', '4'),
    ('Pudliszki', 'Ketchup łagodny Pudliszek', '4'),
    ('Agro Nova Food', 'Ketchup pikantny z pomidorów z Kujaw', '4'),
    ('Dawtona', 'Ketchup łagodny', '4'),
    ('Kamis', 'Ketchup włoski', '4'),
    ('Tomatini', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup markowy łagodny', '3'),
    ('Madero', 'Ketchup łagodny', '4'),
    ('Unknown', 'Ketchup łagodny', '4'),
    ('Pegaz', 'Musztarda stołowa', '3'),
    ('Pudliszki', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup Premium Łagodny', '4'),
    ('Roleski', 'Ketchup premium meksykański KETO', '4'),
    ('Międzychód', 'Ketchup łagodny', '3'),
    ('Na Szlaku Smaku', 'Ketchup łagodny', '4'),
    ('Polskie przetwory', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup łagodny', '4'),
    ('Kotlin', 'Ketchup z truskawką', '4'),
    ('Reypol', 'Ketchup Ziołowy Premium z Nasionami Konopi', '3'),
    ('Reypol', 'Ketchup premium łagodny', '4'),
    ('Lewiatan', 'Ketchup Łagodny', '4'),
    ('Kotliński', 'Ketchup łagodny', '4'),
    ('Roleski', 'Musztarda Stołowa', '3'),
    ('Kotlin', 'Ketchup hot', '4'),
    ('Madero', 'Ketchup pikantny', '4'),
    ('Madero', 'Ketchup junior', '3'),
    ('Roleski', 'Ketchup Premium', '3'),
    ('Kotlin sp. z o. o', 'Ketchup kotliński', '4'),
    ('Develey', 'Ketchup z dodatkiem miodu, czosnku i tymianku', '3'),
    ('Dawtona', 'Ketchup pikantny', '4'),
    ('Włocławek', 'Ketchup', '4'),
    ('Roleski', 'Ketchup premium Pikantny', '3'),
    ('Roleski', 'Ketchup premium jalapeño KETO', '4'),
    ('Kotlin', 'Kotlin Ketchup Premium', '4'),
    ('Madero', 'Premium ketchup pikantny', '4'),
    ('Kotlin', 'Ketchup pikantny', '4'),
    ('Madero', 'Ketchup classic', '4'),
    ('Fenex', 'Ketchup nr. VII', '4'),
    ('Fenex', 'Ketchup nr VII', '4'),
    ('Włocławek', 'Ketchup pikantny', '4'),
    ('Krajowa Spółka Cukrowa', 'Ketchup lagoduy', '4'),
    ('Pudliszki', 'Ketchup Super Pikantny', '4'),
    ('Develey', 'Ketchup Pikantny', '4')
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
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;
