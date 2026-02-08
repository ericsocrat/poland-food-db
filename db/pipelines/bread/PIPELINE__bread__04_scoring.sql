-- PIPELINE (Bread): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Lajkonik', 'Paluszki słone', '2'),
    ('Gursz', 'Chleb Pszenno-Żytni', '1'),
    ('Pano', 'Tost pełnoziarnisty', '0'),
    ('Pano', 'Tost  maślany', '0'),
    ('Sonko', 'Lekkie żytnie', '1'),
    ('Aksam', 'Beskidzkie paluszki z solą', '3'),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', '0'),
    ('Pano', 'Chleb żytni', '0'),
    ('Pano', 'Tortilla', '5'),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', '0'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', '0'),
    ('Dijo', 'Fresh Wraps Grill Barbecue x4', '8'),
    ('Pano', 'tosty pszenny', '0'),
    ('Sonko', 'Pieczywo Sonko Lekkie 7 Ziaren', '1'),
    ('Pano', 'Chleb Wiejski', '0'),
    ('Dan Cake', 'Toast bread', '0'),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', '0'),
    ('Pano', 'Wraps lo-carb whole wheat tortilla', '5'),
    ('Lestello', 'Chickpea cakes', '0'),
    ('TOP', 'Paluszki solone', '2'),
    ('Piekarnia w sercu Lidla', 'Chleb Tostowy Z Mąką Pełnoziarnistą', '0'),
    ('Carrefour', 'Petits pains grilles', '1'),
    ('Carrefour', 'biscottes braisées', '1'),
    ('Carrefour', 'Biscottes sans sel ajouté', '1'),
    ('Carrefour', 'Biscottes Blé complet', '0'),
    ('Chabrior', 'Biscottes complètes x36', '1'),
    ('Italiamo', 'Piada sfogliata', '0'),
    ('Carrefour', 'Biscuits Nature', '1')
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
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Lajkonik', 'Paluszki słone', 'D'),
    ('Gursz', 'Chleb Pszenno-Żytni', 'C'),
    ('Pano', 'Tost pełnoziarnisty', 'B'),
    ('Pano', 'Tost  maślany', 'C'),
    ('Sonko', 'Lekkie żytnie', 'B'),
    ('Aksam', 'Beskidzkie paluszki z solą', 'E'),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 'D'),
    ('Pano', 'Chleb żytni', 'A'),
    ('Pano', 'Tortilla', 'C'),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 'A'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 'C'),
    ('Dijo', 'Fresh Wraps Grill Barbecue x4', 'D'),
    ('Pano', 'tosty pszenny', 'C'),
    ('Sonko', 'Pieczywo Sonko Lekkie 7 Ziaren', 'C'),
    ('Pano', 'Chleb Wiejski', 'C'),
    ('Dan Cake', 'Toast bread', 'C'),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', 'A'),
    ('Pano', 'Wraps lo-carb whole wheat tortilla', 'UNKNOWN'),
    ('Lestello', 'Chickpea cakes', 'B'),
    ('TOP', 'Paluszki solone', 'E'),
    ('Piekarnia w sercu Lidla', 'Chleb Tostowy Z Mąką Pełnoziarnistą', 'B'),
    ('Carrefour', 'Petits pains grilles', 'B'),
    ('Carrefour', 'biscottes braisées', 'A'),
    ('Carrefour', 'Biscottes sans sel ajouté', 'B'),
    ('Carrefour', 'Biscottes Blé complet', 'C'),
    ('Chabrior', 'Biscottes complètes x36', 'C'),
    ('Italiamo', 'Piada sfogliata', 'D'),
    ('Carrefour', 'Biscuits Nature', 'C')
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
    ('Lajkonik', 'Paluszki słone', '3'),
    ('Gursz', 'Chleb Pszenno-Żytni', '4'),
    ('Pano', 'Tost pełnoziarnisty', '4'),
    ('Pano', 'Tost  maślany', '3'),
    ('Sonko', 'Lekkie żytnie', '4'),
    ('Aksam', 'Beskidzkie paluszki z solą', '4'),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', '3'),
    ('Pano', 'Chleb żytni', '3'),
    ('Pano', 'Tortilla', '4'),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', '4'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', '3'),
    ('Dijo', 'Fresh Wraps Grill Barbecue x4', '4'),
    ('Pano', 'tosty pszenny', '3'),
    ('Sonko', 'Pieczywo Sonko Lekkie 7 Ziaren', '4'),
    ('Pano', 'Chleb Wiejski', '3'),
    ('Dan Cake', 'Toast bread', '4'),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', '1'),
    ('Pano', 'Wraps lo-carb whole wheat tortilla', '4'),
    ('Lestello', 'Chickpea cakes', '3'),
    ('TOP', 'Paluszki solone', '3'),
    ('Piekarnia w sercu Lidla', 'Chleb Tostowy Z Mąką Pełnoziarnistą', '4'),
    ('Carrefour', 'Petits pains grilles', '4'),
    ('Carrefour', 'biscottes braisées', '4'),
    ('Carrefour', 'Biscottes sans sel ajouté', '4'),
    ('Carrefour', 'Biscottes Blé complet', '4'),
    ('Chabrior', 'Biscottes complètes x36', '4'),
    ('Italiamo', 'Piada sfogliata', '3'),
    ('Carrefour', 'Biscuits Nature', '4')
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
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;
