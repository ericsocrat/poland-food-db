-- PIPELINE (Meat): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', '0'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', '0'),
    ('Kraina Wędlin', 'Parówki z szynki', '0'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', '0'),
    ('Morliny', 'Szynka konserwowa z galaretką', '5'),
    ('Stoczek', 'Kiełbasa z weka', '9'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', '2'),
    ('Biedra', 'Polędwica Wiejska Sadecka', '1'),
    ('Krakus', 'Parówki z piersi kurczaka', '3'),
    ('Strzała', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', '1'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', '2'),
    ('Duda', 'Parówki wieprzowe Mediolanki', '8'),
    ('Kraina Wędlin', 'Szynka Zawędzana', '5'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', '6'),
    ('Szubryt', 'Kiełbasa z czosnkiem', '3'),
    ('Morliny', 'Berlinki Classic', '6'),
    ('tarczyński', 'Kabanosy wieprzowe', '0'),
    ('Morliny', 'Berlinki classic', '5'),
    ('Animex Foods', 'Berlinki Kurczak', '1'),
    ('Podlaski', 'Pasztet drobiowy', '0'),
    ('Krakus', 'Szynka eksportowa', '8'),
    ('Drosed', 'Podlaski pasztet drobiowy', '1'),
    ('Profi', 'Chicken Pâté', '1'),
    ('Berlinki', 'Z Serem', '7'),
    ('Morliny', 'Boczek', '4'),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', '1'),
    ('Tarczynski', 'Krakauer Wurst (polnische Brühwurst)', '2'),
    ('Profi', 'Pasztet z pomidorami', '1')
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
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
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', '4'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', '4'),
    ('Kraina Wędlin', 'Parówki z szynki', '4'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', '4'),
    ('Morliny', 'Szynka konserwowa z galaretką', '4'),
    ('Stoczek', 'Kiełbasa z weka', '4'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', '4'),
    ('Biedra', 'Polędwica Wiejska Sadecka', '3'),
    ('Krakus', 'Parówki z piersi kurczaka', '4'),
    ('Strzała', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', '4'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', '4'),
    ('Duda', 'Parówki wieprzowe Mediolanki', '4'),
    ('Kraina Wędlin', 'Szynka Zawędzana', '4'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', '4'),
    ('Szubryt', 'Kiełbasa z czosnkiem', '4'),
    ('Morliny', 'Berlinki Classic', '4'),
    ('tarczyński', 'Kabanosy wieprzowe', '4'),
    ('Morliny', 'Berlinki classic', '4'),
    ('Animex Foods', 'Berlinki Kurczak', '4'),
    ('Podlaski', 'Pasztet drobiowy', '4'),
    ('Krakus', 'Szynka eksportowa', '4'),
    ('Drosed', 'Podlaski pasztet drobiowy', '4'),
    ('Profi', 'Chicken Pâté', '4'),
    ('Berlinki', 'Z Serem', '4'),
    ('Morliny', 'Boczek', '4'),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', '4'),
    ('Tarczynski', 'Krakauer Wurst (polnische Brühwurst)', '4'),
    ('Profi', 'Pasztet z pomidorami', '4')
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;
