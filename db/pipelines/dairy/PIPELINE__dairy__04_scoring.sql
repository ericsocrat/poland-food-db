-- PIPELINE (Dairy): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Mlekpol', 'Łaciate 3,2%', 0),
    ('Mleczna Dolina', 'Masło ekstra', 0),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 0),
    ('Piatnica', 'Serek Wiejski wysokobiałkowy', 0),
    ('Łaciate', 'Łaciaty serek śmietankowy', 0),
    ('Piątnica', 'Twój Smak Serek śmietankowy', 0),
    ('Łaciate', 'Masło extra Łaciate', 0),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 0),
    ('Piątnica', 'Śmietana 18%', 0),
    ('Sierpc', 'Ser królewski', 2),
    ('Almette', 'Serek Almette z ziołami', 1),
    ('Piątnica', 'Mleko wieskie świeże 2%', 0),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 0),
    ('PIĄTNICA', 'SEREK WIEJSKI', 0),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 0),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 0),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 0),
    ('Favita', 'Favita', 1),
    ('Mleczna Dolina', 'mleko UHT 3,2%', 0),
    ('MLEKOVITA', 'Butter', 0),
    ('Almette', 'Hochland Almette Soft Cheese 150G', 1),
    ('Piątnica', 'Serek homogenizowany waniliowy', 0),
    ('Piątnica', 'Skyr jogurt pitny Naturalny', 0),
    ('Mlekovita', 'hleko', 0),
    ('Pilos', 'Mleko zagęszczone 7,5%', 2),
    ('Piątnica', 'Skyr jogurt pitny', 0),
    ('Piątnica', 'Skyr - jogurt typu islandzkiego z truskawkami', 1),
    ('Fruvita', 'Jogurt Grecki', 0)
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
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Mlekpol', 'Łaciate 3,2%', 'B'),
    ('Mleczna Dolina', 'Masło ekstra', 'E'),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 'A'),
    ('Piatnica', 'Serek Wiejski wysokobiałkowy', 'A'),
    ('Łaciate', 'Łaciaty serek śmietankowy', 'D'),
    ('Piątnica', 'Twój Smak Serek śmietankowy', 'D'),
    ('Łaciate', 'Masło extra Łaciate', 'E'),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'A'),
    ('Piątnica', 'Śmietana 18%', 'D'),
    ('Sierpc', 'Ser królewski', 'D'),
    ('Almette', 'Serek Almette z ziołami', 'D'),
    ('Piątnica', 'Mleko wieskie świeże 2%', 'B'),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 'B'),
    ('PIĄTNICA', 'SEREK WIEJSKI', 'C'),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 'C'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'B'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'B'),
    ('Favita', 'Favita', 'E'),
    ('Mleczna Dolina', 'mleko UHT 3,2%', 'C'),
    ('MLEKOVITA', 'Butter', 'E'),
    ('Almette', 'Hochland Almette Soft Cheese 150G', 'D'),
    ('Piątnica', 'Serek homogenizowany waniliowy', 'C'),
    ('Piątnica', 'Skyr jogurt pitny Naturalny', 'A'),
    ('Mlekovita', 'hleko', 'B'),
    ('Pilos', 'Mleko zagęszczone 7,5%', 'E'),
    ('Piątnica', 'Skyr jogurt pitny', 'B'),
    ('Piątnica', 'Skyr - jogurt typu islandzkiego z truskawkami', 'A'),
    ('Fruvita', 'Jogurt Grecki', 'C')
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
    ('Mlekpol', 'Łaciate 3,2%', 1),
    ('Mleczna Dolina', 'Masło ekstra', 2),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 3),
    ('Piatnica', 'Serek Wiejski wysokobiałkowy', 4),
    ('Łaciate', 'Łaciaty serek śmietankowy', 4),
    ('Piątnica', 'Twój Smak Serek śmietankowy', 4),
    ('Łaciate', 'Masło extra Łaciate', 2),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 1),
    ('Piątnica', 'Śmietana 18%', 3),
    ('Sierpc', 'Ser królewski', 4),
    ('Almette', 'Serek Almette z ziołami', 4),
    ('Piątnica', 'Mleko wieskie świeże 2%', 4),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 1),
    ('PIĄTNICA', 'SEREK WIEJSKI', 3),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 1),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 4),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 4),
    ('Favita', 'Favita', 3),
    ('Mleczna Dolina', 'mleko UHT 3,2%', 1),
    ('MLEKOVITA', 'Butter', 2),
    ('Almette', 'Hochland Almette Soft Cheese 150G', 3),
    ('Piątnica', 'Serek homogenizowany waniliowy', 4),
    ('Piątnica', 'Skyr jogurt pitny Naturalny', 1),
    ('Mlekovita', 'hleko', 4),
    ('Pilos', 'Mleko zagęszczone 7,5%', 4),
    ('Piątnica', 'Skyr jogurt pitny', 4),
    ('Piątnica', 'Skyr - jogurt typu islandzkiego z truskawkami', 4),
    ('Fruvita', 'Jogurt Grecki', 4)
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
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;
