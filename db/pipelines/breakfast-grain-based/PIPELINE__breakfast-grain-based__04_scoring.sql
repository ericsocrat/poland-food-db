-- PIPELINE (Breakfast & Grain-Based): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Vitanella', 'Granola - Musli Prażone (Czekoladowe)', 0),
    ('Bakalland', 'Ba! Granola Z Żurawiną', 0),
    ('Go on', 'Granola proteinowa brownie & cherry', 0),
    ('Bakalland', 'Ba! Granola 5 bakalii', 0),
    ('Unknown', 'Étcsokis granola málnával', 0),
    ('All nutrition', 'F**king delicious Granola', 0),
    ('Unknown', 'Gyümölcsös granola', 0),
    ('All  nutrition', 'F**king delicious granola fruity', 0),
    ('Unknown', 'Granola with Fruits', 0),
    ('One Day More', 'Winter Granola', 0),
    ('One Day More', 'Protein Granola Caramel Nuts & Chocolate', 0),
    ('Sante', 'Granola o smaku rumu', 0),
    ('Vitanella', 'Granola Z Ciasteczkami', 0),
    ('Vitanella', 'Cherry granola', 0)
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
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Vitanella', 'Granola - Musli Prażone (Czekoladowe)', 'UNKNOWN'),
    ('Bakalland', 'Ba! Granola Z Żurawiną', 'UNKNOWN'),
    ('Go on', 'Granola proteinowa brownie & cherry', 'UNKNOWN'),
    ('Bakalland', 'Ba! Granola 5 bakalii', 'UNKNOWN'),
    ('Unknown', 'Étcsokis granola málnával', 'UNKNOWN'),
    ('All nutrition', 'F**king delicious Granola', 'UNKNOWN'),
    ('Unknown', 'Gyümölcsös granola', 'UNKNOWN'),
    ('All  nutrition', 'F**king delicious granola fruity', 'UNKNOWN'),
    ('Unknown', 'Granola with Fruits', 'UNKNOWN'),
    ('One Day More', 'Winter Granola', 'UNKNOWN'),
    ('One Day More', 'Protein Granola Caramel Nuts & Chocolate', 'UNKNOWN'),
    ('Sante', 'Granola o smaku rumu', 'UNKNOWN'),
    ('Vitanella', 'Granola Z Ciasteczkami', 'UNKNOWN'),
    ('Vitanella', 'Cherry granola', 'UNKNOWN')
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
    ('Vitanella', 'Granola - Musli Prażone (Czekoladowe)', 4),
    ('Bakalland', 'Ba! Granola Z Żurawiną', 4),
    ('Go on', 'Granola proteinowa brownie & cherry', 4),
    ('Bakalland', 'Ba! Granola 5 bakalii', 4),
    ('Unknown', 'Étcsokis granola málnával', 4),
    ('All nutrition', 'F**king delicious Granola', 4),
    ('Unknown', 'Gyümölcsös granola', 4),
    ('All  nutrition', 'F**king delicious granola fruity', 4),
    ('Unknown', 'Granola with Fruits', 4),
    ('One Day More', 'Winter Granola', 4),
    ('One Day More', 'Protein Granola Caramel Nuts & Chocolate', 4),
    ('Sante', 'Granola o smaku rumu', 4),
    ('Vitanella', 'Granola Z Ciasteczkami', 4),
    ('Vitanella', 'Cherry granola', 4)
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
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;
