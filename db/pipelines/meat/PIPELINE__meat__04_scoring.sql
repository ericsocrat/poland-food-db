-- PIPELINE (Meat): scoring
-- Generated: 2026-02-11

-- 0. DEFAULT concern score for products without ingredient data
update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Meat'
  and is_deprecated is not true
  and ingredient_concern_score is null;

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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 'A'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 'E'),
    ('Kraina Wędlin', 'Parówki z szynki', 'E'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 'C'),
    ('Morliny', 'Szynka konserwowa z galaretką', 'D'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 'D'),
    ('Biedra', 'Polędwica Wiejska Sadecka', 'B'),
    ('Krakus', 'Parówki z piersi kurczaka', 'D'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 'E'),
    ('Kraina Wędlin', 'Szynka Zawędzana', 'D'),
    ('Dania Express', 'Polędwiczki z kurczaka panierowane', 'C'),
    ('Kraina Wedlin', 'Polędwica drobiowa', 'C'),
    ('Kraina Wędlin', 'Kiełbasa Żywiecka z indyka', 'D'),
    ('Kraina Wędlin', 'Szynka Wędzona', 'D'),
    ('Kraina Wędlin', 'Kiełbasa Myśliwska', 'E'),
    ('Lisner', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'D'),
    ('Masarnia Strzała', 'Wołowina w sosie własnym', 'D'),
    ('Goodvalley', 'Wędzony Schab 100% polskiego mięsa', 'D'),
    ('Yeemy', 'Pikantne skrzydełka panierowane z kurczaka', 'D'),
    ('Stoczek', 'Kiełbasa z weka', 'E'),
    ('Olewnik', 'Żywiecka kiełbasa sucha z szynki', 'D'),
    ('Biedronka', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'C'),
    ('Provincja', 'Pasztet z dzika z wątróbką drobiową', 'E'),
    ('Duda', 'Parówki wieprzowe Mediolanki', 'E'),
    ('Kraina Mięs', 'Tatar wołowy', 'D'),
    ('Nasze Smaki', 'Mięsiwo w sosie własnym', 'D'),
    ('Kraina Wędlin', 'Salami ostródzkie', 'E'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 'D'),
    ('Kraina Mięs', 'Mięso Mielone Z Kurczaka Świeże', 'A'),
    ('Morliny', 'Boczek wędzony', 'E'),
    ('Sokołów', 'Salami z cebulą', 'E'),
    ('Kraina Wędlin', 'Boczek wędzony surowy', 'E'),
    ('Sokołów', 'Tatar wołowy', 'D'),
    ('Drobimex', 'Polędwica z kurcząt', 'D'),
    ('Sokołów', 'Stówki z mięsa z piersi kurczaka', 'D'),
    ('Dolina Dobra', 'Kiełbaski 100% mięsa', 'D'),
    ('Morliny', 'Mięsko ze smalczykiem', 'E'),
    ('Drobimex', 'Pierś pieczona z pomidorami i ziołami', 'D'),
    ('Sokołów', 'Boczek surowy wędzony', 'C'),
    ('Morliny', 'Berlinki classic', 'E'),
    ('Tarczyński', 'Kabanosy wieprzowe', 'D'),
    ('Krakus', 'Szynka eksportowa', 'D'),
    ('Drosed', 'Podlaski pasztet drobiowy', 'C'),
    ('Morliny', 'Boczek', 'E'),
    ('Berlinki', 'Z Serem', 'E'),
    ('Podlaski', 'Pasztet drobiowy', 'C'),
    ('Unknown', 'Polędwiczki z kurczaka panierowane łagodna', 'UNKNOWN'),
    ('Animex Foods', 'Berlinki Kurczak', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', '4'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', '4'),
    ('Kraina Wędlin', 'Parówki z szynki', '4'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', '4'),
    ('Morliny', 'Szynka konserwowa z galaretką', '4'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', '4'),
    ('Biedra', 'Polędwica Wiejska Sadecka', '3'),
    ('Krakus', 'Parówki z piersi kurczaka', '4'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', '4'),
    ('Kraina Wędlin', 'Szynka Zawędzana', '4'),
    ('Dania Express', 'Polędwiczki z kurczaka panierowane', '4'),
    ('Kraina Wedlin', 'Polędwica drobiowa', '4'),
    ('Kraina Wędlin', 'Kiełbasa Żywiecka z indyka', '3'),
    ('Kraina Wędlin', 'Szynka Wędzona', '4'),
    ('Kraina Wędlin', 'Kiełbasa Myśliwska', '3'),
    ('Lisner', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', '4'),
    ('Masarnia Strzała', 'Wołowina w sosie własnym', '4'),
    ('Goodvalley', 'Wędzony Schab 100% polskiego mięsa', '4'),
    ('Yeemy', 'Pikantne skrzydełka panierowane z kurczaka', '4'),
    ('Stoczek', 'Kiełbasa z weka', '4'),
    ('Olewnik', 'Żywiecka kiełbasa sucha z szynki', '3'),
    ('Biedronka', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', '4'),
    ('Provincja', 'Pasztet z dzika z wątróbką drobiową', '4'),
    ('Duda', 'Parówki wieprzowe Mediolanki', '4'),
    ('Kraina Mięs', 'Tatar wołowy', '4'),
    ('Nasze Smaki', 'Mięsiwo w sosie własnym', '4'),
    ('Kraina Wędlin', 'Salami ostródzkie', '4'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', '4'),
    ('Kraina Mięs', 'Mięso Mielone Z Kurczaka Świeże', '4'),
    ('Morliny', 'Boczek wędzony', '4'),
    ('Sokołów', 'Salami z cebulą', '4'),
    ('Kraina Wędlin', 'Boczek wędzony surowy', '4'),
    ('Sokołów', 'Tatar wołowy', '4'),
    ('Drobimex', 'Polędwica z kurcząt', '4'),
    ('Sokołów', 'Stówki z mięsa z piersi kurczaka', '4'),
    ('Dolina Dobra', 'Kiełbaski 100% mięsa', '3'),
    ('Morliny', 'Mięsko ze smalczykiem', '4'),
    ('Drobimex', 'Pierś pieczona z pomidorami i ziołami', '4'),
    ('Sokołów', 'Boczek surowy wędzony', '4'),
    ('Morliny', 'Berlinki classic', '4'),
    ('Tarczyński', 'Kabanosy wieprzowe', '4'),
    ('Krakus', 'Szynka eksportowa', '4'),
    ('Drosed', 'Podlaski pasztet drobiowy', '4'),
    ('Morliny', 'Boczek', '4'),
    ('Berlinki', 'Z Serem', '4'),
    ('Podlaski', 'Pasztet drobiowy', '4'),
    ('Unknown', 'Polędwiczki z kurczaka panierowane łagodna', '4'),
    ('Animex Foods', 'Berlinki Kurczak', '4')
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;
