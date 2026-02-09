-- PIPELINE (Sauces): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 1),
    ('Fanex', 'Sos meksykański', 5),
    ('Łowicz', 'Sos Boloński', 0),
    ('Sottile Gusto', 'Passata', 1),
    ('Międzychód', 'Sos pomidorowy', 0),
    ('ŁOWICZ', 'Sos Spaghetti', 2),
    ('Dawtona', 'Passata rustica', 0),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 1),
    ('Łowicz', 'Sos Spaghetti', 2),
    ('Italiamo', 'Sugo al pomodoro con basilico', 0),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 0),
    ('Combino', 'Sauce tomate bio à la napolitaine', 0),
    ('mondo italiano', 'passierte Tomaten', 0),
    ('Mutti', 'Passierte Tomaten', 0),
    ('Polli', 'Pesto alla calabrese poivrons et ricotta', 1),
    ('gustobello', 'Passata', 0),
    ('Baresa', 'Tomato Passata With Garlic', 0)
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
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 'C'),
    ('Fanex', 'Sos meksykański', 'C'),
    ('Łowicz', 'Sos Boloński', 'A'),
    ('Sottile Gusto', 'Passata', 'A'),
    ('Międzychód', 'Sos pomidorowy', 'C'),
    ('ŁOWICZ', 'Sos Spaghetti', 'C'),
    ('Dawtona', 'Passata rustica', 'A'),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 'B'),
    ('Łowicz', 'Sos Spaghetti', 'C'),
    ('Italiamo', 'Sugo al pomodoro con basilico', 'A'),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 'A'),
    ('Combino', 'Sauce tomate bio à la napolitaine', 'C'),
    ('mondo italiano', 'passierte Tomaten', 'A'),
    ('Mutti', 'Passierte Tomaten', 'A'),
    ('Polli', 'Pesto alla calabrese poivrons et ricotta', 'E'),
    ('gustobello', 'Passata', 'UNKNOWN'),
    ('Baresa', 'Tomato Passata With Garlic', 'B')
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
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 4),
    ('Fanex', 'Sos meksykański', 4),
    ('Łowicz', 'Sos Boloński', 4),
    ('Sottile Gusto', 'Passata', 3),
    ('Międzychód', 'Sos pomidorowy', 4),
    ('ŁOWICZ', 'Sos Spaghetti', 4),
    ('Dawtona', 'Passata rustica', 3),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 3),
    ('Łowicz', 'Sos Spaghetti', 4),
    ('Italiamo', 'Sugo al pomodoro con basilico', 3),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 4),
    ('Combino', 'Sauce tomate bio à la napolitaine', 3),
    ('mondo italiano', 'passierte Tomaten', 4),
    ('Mutti', 'Passierte Tomaten', 3),
    ('Polli', 'Pesto alla calabrese poivrons et ricotta', 4),
    ('gustobello', 'Passata', 4),
    ('Baresa', 'Tomato Passata With Garlic', 4)
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
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;
