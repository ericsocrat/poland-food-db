-- PIPELINE (Meat): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Meat'
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 'A'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 'E'),
    ('Kraina Wędlin', 'Parówki z szynki', 'E'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 'C'),
    ('Morliny', 'Szynka konserwowa z galaretką', 'D'),
    ('Stoczek', 'Kiełbasa z weka', 'E'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 'D'),
    ('Biedra', 'Polędwica Wiejska Sadecka', 'B'),
    ('Krakus', 'Parówki z piersi kurczaka', 'D'),
    ('Strzała', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', 'D'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 'E'),
    ('Duda', 'Parówki wieprzowe Mediolanki', 'E'),
    ('Kraina Wędlin', 'Szynka Zawędzana', 'D'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 'D'),
    ('Szubryt', 'Kiełbasa z czosnkiem', 'D'),
    ('Morliny', 'Berlinki Classic', 'E'),
    ('tarczyński', 'Kabanosy wieprzowe', 'D'),
    ('Morliny', 'Berlinki classic', 'E'),
    ('Animex Foods', 'Berlinki Kurczak', 'D'),
    ('Podlaski', 'Pasztet drobiowy', 'C'),
    ('Krakus', 'Szynka eksportowa', 'D'),
    ('Drosed', 'Podlaski pasztet drobiowy', 'C'),
    ('Profi', 'Chicken Pâté', 'D'),
    ('Berlinki', 'Z Serem', 'E'),
    ('Morliny', 'Boczek', 'E'),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', 'D'),
    ('Tarczynski', 'Krakauer Wurst (polnische Brühwurst)', 'D'),
    ('Profi', 'Pasztet z pomidorami', 'D')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 4),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 4),
    ('Kraina Wędlin', 'Parówki z szynki', 4),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 4),
    ('Morliny', 'Szynka konserwowa z galaretką', 4),
    ('Stoczek', 'Kiełbasa z weka', 4),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 4),
    ('Biedra', 'Polędwica Wiejska Sadecka', 3),
    ('Krakus', 'Parówki z piersi kurczaka', 4),
    ('Strzała', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', 4),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 4),
    ('Duda', 'Parówki wieprzowe Mediolanki', 4),
    ('Kraina Wędlin', 'Szynka Zawędzana', 4),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 4),
    ('Szubryt', 'Kiełbasa z czosnkiem', 4),
    ('Morliny', 'Berlinki Classic', 4),
    ('tarczyński', 'Kabanosy wieprzowe', 4),
    ('Morliny', 'Berlinki classic', 4),
    ('Animex Foods', 'Berlinki Kurczak', 4),
    ('Podlaski', 'Pasztet drobiowy', 4),
    ('Krakus', 'Szynka eksportowa', 4),
    ('Drosed', 'Podlaski pasztet drobiowy', 4),
    ('Profi', 'Chicken Pâté', 4),
    ('Berlinki', 'Z Serem', 4),
    ('Morliny', 'Boczek', 4),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', 4),
    ('Tarczynski', 'Krakauer Wurst (polnische Brühwurst)', 4),
    ('Profi', 'Pasztet z pomidorami', 4)
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;
