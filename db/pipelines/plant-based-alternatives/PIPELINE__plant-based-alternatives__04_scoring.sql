-- PIPELINE (Plant-Based & Alternatives): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Sante', 'Masło orzechowe', '0'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', '0'),
    ('Lidl', 'Doce Extra Fresa Morango', '2'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', '0'),
    ('Batts', 'Crispy Fried Onions', '0'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', '0'),
    ('ITALIAMO', 'Paradizniki suseni lidl', '0'),
    ('DONAU SOJA', 'Tofu smoked', '2'),
    ('Lidl Baresa', 'Aurinkokuivattuja tomaatteja', '2')
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Sante', 'Masło orzechowe', 'C'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', 'A'),
    ('Lidl', 'Doce Extra Fresa Morango', 'E'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 'B'),
    ('Batts', 'Crispy Fried Onions', 'E'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'A'),
    ('ITALIAMO', 'Paradizniki suseni lidl', 'UNKNOWN'),
    ('DONAU SOJA', 'Tofu smoked', 'B'),
    ('Lidl Baresa', 'Aurinkokuivattuja tomaatteja', 'D')
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
    ('Sante', 'Masło orzechowe', '4'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', '4'),
    ('Lidl', 'Doce Extra Fresa Morango', '4'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', '2'),
    ('Batts', 'Crispy Fried Onions', '3'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', '1'),
    ('ITALIAMO', 'Paradizniki suseni lidl', '3'),
    ('DONAU SOJA', 'Tofu smoked', '4'),
    ('Lidl Baresa', 'Aurinkokuivattuja tomaatteja', '3')
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;
