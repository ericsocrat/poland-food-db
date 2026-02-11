-- PIPELINE (Instant & Frozen): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Ajinomoto', 'Oyakata Miso Ramen', 5),
    ('Vifon', 'Kurczak curry instant noodle soup', 9),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 7),
    ('VIFON', 'Chinese Chicken flavour instant noodle soup (mild)', 9),
    ('Vifon', 'Barbecue Chicken', 10),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 6),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 6),
    ('Tan-Viet', 'Kurczak Zloty', 9),
    ('Oyakata', 'Yakisoba soja classique', 7),
    ('Oyakata', 'Nouilles de blé', 4),
    ('Oyakata', 'Ramen Miso et Légumes', 3),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 5),
    ('Oyakata', 'Ramen soja', 0),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 6),
    ('Knorr', 'Nudle ser w ziołach', 6),
    ('Goong', 'Curry Noodles', 13),
    ('Vifon', 'Kimchi', 9),
    ('Ajinomoto', 'Pork Ramen', 5),
    ('Vifon', 'Ramen Soy Souce', 13),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 9),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 5),
    ('Indomie', 'Noodles Chicken Flavour', 10),
    ('Nongshim', 'Super Spicy Red Shin', 11),
    ('mama', 'Mama salted egg', 9),
    ('NongshimSamyang', 'Ramen kimchi', 12),
    ('MAMA', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', 7),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 8),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 10)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  ),
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Ajinomoto', 'Oyakata Miso Ramen', 'C'),
    ('Vifon', 'Kurczak curry instant noodle soup', 'C'),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 'D'),
    ('VIFON', 'Chinese Chicken flavour instant noodle soup (mild)', 'C'),
    ('Vifon', 'Barbecue Chicken', 'C'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'UNKNOWN'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 'UNKNOWN'),
    ('Tan-Viet', 'Kurczak Zloty', 'C'),
    ('Oyakata', 'Yakisoba soja classique', 'D'),
    ('Oyakata', 'Nouilles de blé', 'UNKNOWN'),
    ('Oyakata', 'Ramen Miso et Légumes', 'UNKNOWN'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 'UNKNOWN'),
    ('Oyakata', 'Ramen soja', 'UNKNOWN'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 'UNKNOWN'),
    ('Knorr', 'Nudle ser w ziołach', 'C'),
    ('Goong', 'Curry Noodles', 'UNKNOWN'),
    ('Vifon', 'Kimchi', 'UNKNOWN'),
    ('Ajinomoto', 'Pork Ramen', 'UNKNOWN'),
    ('Vifon', 'Ramen Soy Souce', 'UNKNOWN'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 'UNKNOWN'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 'UNKNOWN'),
    ('Indomie', 'Noodles Chicken Flavour', 'UNKNOWN'),
    ('Nongshim', 'Super Spicy Red Shin', 'UNKNOWN'),
    ('mama', 'Mama salted egg', 'UNKNOWN'),
    ('NongshimSamyang', 'Ramen kimchi', 'UNKNOWN'),
    ('MAMA', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', 'UNKNOWN'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'UNKNOWN'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 'UNKNOWN')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Ajinomoto', 'Oyakata Miso Ramen', 4),
    ('Vifon', 'Kurczak curry instant noodle soup', 4),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 4),
    ('VIFON', 'Chinese Chicken flavour instant noodle soup (mild)', 4),
    ('Vifon', 'Barbecue Chicken', 4),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 4),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 4),
    ('Tan-Viet', 'Kurczak Zloty', 4),
    ('Oyakata', 'Yakisoba soja classique', 4),
    ('Oyakata', 'Nouilles de blé', 4),
    ('Oyakata', 'Ramen Miso et Légumes', 4),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 4),
    ('Oyakata', 'Ramen soja', 4),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 4),
    ('Knorr', 'Nudle ser w ziołach', 4),
    ('Goong', 'Curry Noodles', 4),
    ('Vifon', 'Kimchi', 4),
    ('Ajinomoto', 'Pork Ramen', 4),
    ('Vifon', 'Ramen Soy Souce', 4),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 4),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 4),
    ('Indomie', 'Noodles Chicken Flavour', 4),
    ('Nongshim', 'Super Spicy Red Shin', 4),
    ('mama', 'Mama salted egg', 4),
    ('NongshimSamyang', 'Ramen kimchi', 4),
    ('MAMA', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', 4),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 4),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 4)
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
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;
