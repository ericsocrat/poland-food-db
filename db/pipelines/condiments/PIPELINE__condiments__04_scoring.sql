-- PIPELINE (Condiments): scoring
-- Generated: 2026-02-08

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
    ('Kotlin', 'Ketchup Łagodny', '2'),
    ('Heinz', 'Ketchup łagodny', '0'),
    ('Go Vege', 'Majonez sałatkowy wegański', '2'),
    ('Pudliszki', 'Ketchup łagodny', '0'),
    ('Kotlin', 'Ketchup łagodny', '3'),
    ('Winiary', 'Majonez Dekoracyjny', '2'),
    ('Kamis', 'Musztarda sarepska ostra', '1'),
    ('Winiary', 'Mayonnaise Decorative', '2'),
    ('Kotlin', 'Ketchup hot', '2'),
    ('Społem Kielce', 'Majonez Kielecki', '0'),
    ('Roleski', 'Moutarde Dijon', '0'),
    ('Krakus', 'Chrzan', '2'),
    ('Madero', 'Majonez', '2'),
    ('Nestlé', 'Przyprawa Maggi', '2'),
    ('Heinz', 'Heinz Zero Sel Ajoute', '2'),
    ('Kielecki', 'Mayonnaise Kielecki', '0'),
    ('Pudliszki', 'ketchup pikantny', '0'),
    ('Pudliszki', 'Ketchup pikantny', '0'),
    ('Prymat', 'Musztarda sarepska ostra', '1'),
    ('Kamis', 'Musztarda delikatesowa', '1'),
    ('Pudliszki', 'Ketchup Lagodny', '0'),
    ('Madero', 'Sos czosnkowy', '2'),
    ('Barilla', 'Pesto alla Genovese', '1'),
    ('Heinz', 'Tomato Ketchup', '0'),
    ('Kikkoman', 'Kikkoman Sojasauce', '0'),
    ('Kikkoman', 'Teriyakisauce', '1'),
    ('Italiamo', 'Sugo al pomodoro con basilico', '0'),
    ('Heinz', 'Heinz Mayonesa', '1')
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g::numeric,
      nf.sugars_g::numeric,
      nf.salt_g::numeric,
      nf.calories::numeric,
      nf.trans_fat_g::numeric,
      i.additives_count::numeric,
      p.prep_method,
      p.controversies
  )::text,
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
    ('Go Vege', 'Majonez sałatkowy wegański', 'UNKNOWN'),
    ('Pudliszki', 'Ketchup łagodny', 'D'),
    ('Kotlin', 'Ketchup łagodny', 'C'),
    ('Winiary', 'Majonez Dekoracyjny', 'D'),
    ('Kamis', 'Musztarda sarepska ostra', 'D'),
    ('Winiary', 'Mayonnaise Decorative', 'D'),
    ('Kotlin', 'Ketchup hot', 'D'),
    ('Społem Kielce', 'Majonez Kielecki', 'D'),
    ('Roleski', 'Moutarde Dijon', 'E'),
    ('Krakus', 'Chrzan', 'C'),
    ('Madero', 'Majonez', 'D'),
    ('Nestlé', 'Przyprawa Maggi', 'E'),
    ('Heinz', 'Heinz Zero Sel Ajoute', 'A'),
    ('Kielecki', 'Mayonnaise Kielecki', 'D'),
    ('Pudliszki', 'ketchup pikantny', 'E'),
    ('Pudliszki', 'Ketchup pikantny', 'E'),
    ('Prymat', 'Musztarda sarepska ostra', 'D'),
    ('Kamis', 'Musztarda delikatesowa', 'D'),
    ('Pudliszki', 'Ketchup Lagodny', 'D'),
    ('Madero', 'Sos czosnkowy', 'D'),
    ('Barilla', 'Pesto alla Genovese', 'E'),
    ('Heinz', 'Tomato Ketchup', 'D'),
    ('Kikkoman', 'Kikkoman Sojasauce', 'E'),
    ('Kikkoman', 'Teriyakisauce', 'E'),
    ('Italiamo', 'Sugo al pomodoro con basilico', 'A'),
    ('Heinz', 'Heinz Mayonesa', 'D')
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
    ('Kotlin', 'Ketchup Łagodny', '4'),
    ('Heinz', 'Ketchup łagodny', '3'),
    ('Go Vege', 'Majonez sałatkowy wegański', '4'),
    ('Pudliszki', 'Ketchup łagodny', '4'),
    ('Kotlin', 'Ketchup łagodny', '4'),
    ('Winiary', 'Majonez Dekoracyjny', '4'),
    ('Kamis', 'Musztarda sarepska ostra', '4'),
    ('Winiary', 'Mayonnaise Decorative', '4'),
    ('Kotlin', 'Ketchup hot', '4'),
    ('Społem Kielce', 'Majonez Kielecki', '3'),
    ('Roleski', 'Moutarde Dijon', '3'),
    ('Krakus', 'Chrzan', '3'),
    ('Madero', 'Majonez', '3'),
    ('Nestlé', 'Przyprawa Maggi', '4'),
    ('Heinz', 'Heinz Zero Sel Ajoute', '4'),
    ('Kielecki', 'Mayonnaise Kielecki', '3'),
    ('Pudliszki', 'ketchup pikantny', '4'),
    ('Pudliszki', 'Ketchup pikantny', '4'),
    ('Prymat', 'Musztarda sarepska ostra', '4'),
    ('Kamis', 'Musztarda delikatesowa', '4'),
    ('Pudliszki', 'Ketchup Lagodny', '4'),
    ('Madero', 'Sos czosnkowy', '4'),
    ('Barilla', 'Pesto alla Genovese', '4'),
    ('Heinz', 'Tomato Ketchup', '3'),
    ('Kikkoman', 'Kikkoman Sojasauce', '3'),
    ('Kikkoman', 'Teriyakisauce', '3'),
    ('Italiamo', 'Sugo al pomodoro con basilico', '3'),
    ('Heinz', 'Heinz Mayonesa', '3')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g::numeric >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count::numeric, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Condiments'
  and p.is_deprecated is not true;
