-- PIPELINE (Baby): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 0),
    ('Nutricia', 'Kaszka zbożowa jabłko, śliwka.', 0),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 0),
    ('Bobovita', 'Kaszka ryżowa bobovita', 0),
    ('Bobovita', 'Kaszka zbożowa Jabłko Śliwka', 0),
    ('Bobovita', 'Kaszka Mleczna Ryżowa Kakao', 0),
    ('BoboVita', 'Kaszka Ryżowa Banan', 0),
    ('bobovita', 'kaszka mleczno-ryżowa straciatella', 0),
    ('Bobovita', 'Delikatne jabłka z bananem', 0),
    ('BoboVita', 'Kaszka Mleczna Ryżowa 3 Owoce', 0),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 0),
    ('Bobovita', 'Kaszka manna', 0),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 0),
    ('Nestlé', 'Bobovita', 0),
    ('Bobovita', 'Kaszka Ryzowa Malina', 0),
    ('Bobovita', 'Kasza Manna', 0),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 0),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 0),
    ('Gerber organic', 'Krakersy z pomidorem po 12 miesiącu', 0),
    ('Gerber', 'Pełnia Zbóż Owsianka 5 Zbóż', 0),
    ('Gerber', 'Bukiet warzyw z łososiem w sosie pomidorowym', 0),
    ('dada baby food', 'bio mus kokos', 0),
    ('Gerber', 'Warzywa  z delikatnym indykiem w pomidorach', 0)
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
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'NOT-APPLICABLE'),
    ('Nutricia', 'Kaszka zbożowa jabłko, śliwka.', 'B'),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 'NOT-APPLICABLE'),
    ('Bobovita', 'Kaszka ryżowa bobovita', 'UNKNOWN'),
    ('Bobovita', 'Kaszka zbożowa Jabłko Śliwka', 'UNKNOWN'),
    ('Bobovita', 'Kaszka Mleczna Ryżowa Kakao', 'UNKNOWN'),
    ('BoboVita', 'Kaszka Ryżowa Banan', 'UNKNOWN'),
    ('bobovita', 'kaszka mleczno-ryżowa straciatella', 'UNKNOWN'),
    ('Bobovita', 'Delikatne jabłka z bananem', 'UNKNOWN'),
    ('BoboVita', 'Kaszka Mleczna Ryżowa 3 Owoce', 'UNKNOWN'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'NOT-APPLICABLE'),
    ('Bobovita', 'Kaszka manna', 'UNKNOWN'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'NOT-APPLICABLE'),
    ('Nestlé', 'Bobovita', 'UNKNOWN'),
    ('Bobovita', 'Kaszka Ryzowa Malina', 'UNKNOWN'),
    ('Bobovita', 'Kasza Manna', 'UNKNOWN'),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 'NOT-APPLICABLE'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'NOT-APPLICABLE'),
    ('Gerber organic', 'Krakersy z pomidorem po 12 miesiącu', 'D'),
    ('Gerber', 'Pełnia Zbóż Owsianka 5 Zbóż', 'UNKNOWN'),
    ('Gerber', 'Bukiet warzyw z łososiem w sosie pomidorowym', 'UNKNOWN'),
    ('dada baby food', 'bio mus kokos', 'UNKNOWN'),
    ('Gerber', 'Warzywa  z delikatnym indykiem w pomidorach', 'UNKNOWN')
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
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 3),
    ('Nutricia', 'Kaszka zbożowa jabłko, śliwka.', 4),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 3),
    ('Bobovita', 'Kaszka ryżowa bobovita', 4),
    ('Bobovita', 'Kaszka zbożowa Jabłko Śliwka', 4),
    ('Bobovita', 'Kaszka Mleczna Ryżowa Kakao', 4),
    ('BoboVita', 'Kaszka Ryżowa Banan', 4),
    ('bobovita', 'kaszka mleczno-ryżowa straciatella', 4),
    ('Bobovita', 'Delikatne jabłka z bananem', 4),
    ('BoboVita', 'Kaszka Mleczna Ryżowa 3 Owoce', 4),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 4),
    ('Bobovita', 'Kaszka manna', 4),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 1),
    ('Nestlé', 'Bobovita', 4),
    ('Bobovita', 'Kaszka Ryzowa Malina', 4),
    ('Bobovita', 'Kasza Manna', 4),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 3),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 3),
    ('Gerber organic', 'Krakersy z pomidorem po 12 miesiącu', 3),
    ('Gerber', 'Pełnia Zbóż Owsianka 5 Zbóż', 4),
    ('Gerber', 'Bukiet warzyw z łososiem w sosie pomidorowym', 4),
    ('dada baby food', 'bio mus kokos', 4),
    ('Gerber', 'Warzywa  z delikatnym indykiem w pomidorach', 4)
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
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;
