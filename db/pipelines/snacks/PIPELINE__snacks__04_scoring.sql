-- PIPELINE (Snacks): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', '3'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', '3'),
    ('Sante', 'Vitamin coconut bar', '3'),
    ('nakd', 'Blueberry Muffin Myrtilles', '0'),
    ('Carrefour', 'Toast crock'' céréales complètes', '0'),
    ('7 DAYS', 'Croissant with Cocoa Filling', '6'),
    ('Favorina', 'Coeurs pain d''épices chocolat noir', '6'),
    ('Crownfield', 'Muesli Bars Chocolate & Banana', '2'),
    ('Milka', 'Cake & Chock', '5'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', '2')
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', 'E'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'NOT-APPLICABLE'),
    ('Sante', 'Vitamin coconut bar', 'NOT-APPLICABLE'),
    ('nakd', 'Blueberry Muffin Myrtilles', 'D'),
    ('Carrefour', 'Toast crock'' céréales complètes', 'C'),
    ('7 DAYS', 'Croissant with Cocoa Filling', 'E'),
    ('Favorina', 'Coeurs pain d''épices chocolat noir', 'E'),
    ('Crownfield', 'Muesli Bars Chocolate & Banana', 'E'),
    ('Milka', 'Cake & Chock', 'E'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'D')
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
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', '4'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', '4'),
    ('Sante', 'Vitamin coconut bar', '4'),
    ('nakd', 'Blueberry Muffin Myrtilles', '4'),
    ('Carrefour', 'Toast crock'' céréales complètes', '3'),
    ('7 DAYS', 'Croissant with Cocoa Filling', '4'),
    ('Favorina', 'Coeurs pain d''épices chocolat noir', '4'),
    ('Crownfield', 'Muesli Bars Chocolate & Banana', '4'),
    ('Milka', 'Cake & Chock', '4'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', '4')
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;
