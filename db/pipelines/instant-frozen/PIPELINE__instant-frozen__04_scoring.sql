-- PIPELINE (Instant & Frozen): scoring
-- Generated: 2026-02-11

-- 0. DEFAULT concern score for products without ingredient data
update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Instant & Frozen'
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
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 'UNKNOWN'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', 'UNKNOWN'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'UNKNOWN'),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', 'D'),
    ('Vifon', 'Kurczak curry instant noodle soup', 'C'),
    ('Vifon', 'Chinese Chicken flavour instant noodle soup (mild)', 'C'),
    ('Vifon', 'Barbecue Chicken', 'C'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 'UNKNOWN'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'UNKNOWN'),
    ('TAN-VIET International S.A', 'Zupa z nudlami o smaku kimchi (pikantna)', 'C'),
    ('Ajinomoto', 'Oyakata Miso Ramen', 'C'),
    ('Vifon', 'Korean Hot Beef', 'UNKNOWN'),
    ('Tan-Viet', 'Kurczak Zloty', 'C'),
    ('Knorr', 'Nudle ser w ziołach', 'C'),
    ('Vifon', 'Kimchi', 'UNKNOWN'),
    ('Ajinomoto', 'Pork Ramen', 'UNKNOWN'),
    ('Goong', 'Curry Noodles', 'UNKNOWN'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', 'UNKNOWN'),
    ('Vifon', 'Ramen Soy Souce', 'UNKNOWN'),
    ('Vifon', 'Ramen Tonkotsu', 'UNKNOWN'),
    ('Oyakata', 'Ramen soja', 'UNKNOWN'),
    ('Sam Smak', 'Pomidorowa', 'UNKNOWN'),
    ('Oyakata', 'Ramen Miso et Légumes', 'UNKNOWN'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 'UNKNOWN'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 'UNKNOWN'),
    ('Oyakata', 'Nouilles de blé', 'UNKNOWN'),
    ('Oyakata', 'Yakisoba soja classique', 'D'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 'UNKNOWN'),
    ('Oyakata', 'Ramen Barbecue', 'UNKNOWN'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 'UNKNOWN'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 'UNKNOWN'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', 'UNKNOWN'),
    ('Ajinomoto', 'Tomato soup', 'UNKNOWN'),
    ('Ajinomoto', 'Mushrood soup', 'UNKNOWN'),
    ('Vifon', 'Zupka hińska', 'UNKNOWN'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'UNKNOWN'),
    ('Nongshim', 'Super Spicy Red Shin', 'UNKNOWN'),
    ('Indomie', 'Noodles Chicken Flavour', 'UNKNOWN'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 'UNKNOWN'),
    ('Nongshim', 'Kimchi Bowl Noodles', 'UNKNOWN'),
    ('NongshimSamyang', 'Ramen kimchi', 'UNKNOWN'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'UNKNOWN'),
    ('มาม่า', 'Mala Beef Instant Noodle', 'UNKNOWN'),
    ('Mama', 'Mama salted egg', 'UNKNOWN'),
    ('Knorr', 'Danie makaron Bolognese', 'C'),
    ('Nongshim', 'Shin Kimchi Noodles', 'UNKNOWN'),
    ('Reeva', 'Zupa o smaku sera i boczku', 'UNKNOWN'),
    ('Winiary', 'Saucy noodles smak sweet chili', 'C'),
    ('Knorr', 'Nudle Pieczony kurczak', 'UNKNOWN'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', 'UNKNOWN')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', '4'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', '4'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', '4'),
    ('Ajinomoto', 'Oyakata Kurczak Teriyaki', '4'),
    ('Vifon', 'Kurczak curry instant noodle soup', '4'),
    ('Vifon', 'Chinese Chicken flavour instant noodle soup (mild)', '4'),
    ('Vifon', 'Barbecue Chicken', '4'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', '4'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', '4'),
    ('TAN-VIET International S.A', 'Zupa z nudlami o smaku kimchi (pikantna)', '4'),
    ('Ajinomoto', 'Oyakata Miso Ramen', '4'),
    ('Vifon', 'Korean Hot Beef', '4'),
    ('Tan-Viet', 'Kurczak Zloty', '4'),
    ('Knorr', 'Nudle ser w ziołach', '4'),
    ('Vifon', 'Kimchi', '4'),
    ('Ajinomoto', 'Pork Ramen', '4'),
    ('Goong', 'Curry Noodles', '4'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', '4'),
    ('Vifon', 'Ramen Soy Souce', '4'),
    ('Vifon', 'Ramen Tonkotsu', '4'),
    ('Oyakata', 'Ramen soja', '4'),
    ('Sam Smak', 'Pomidorowa', '4'),
    ('Oyakata', 'Ramen Miso et Légumes', '4'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', '4'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', '4'),
    ('Oyakata', 'Nouilles de blé', '4'),
    ('Oyakata', 'Yakisoba soja classique', '4'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', '4'),
    ('Oyakata', 'Ramen Barbecue', '4'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', '4'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', '4'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', '4'),
    ('Ajinomoto', 'Tomato soup', '4'),
    ('Ajinomoto', 'Mushrood soup', '4'),
    ('Vifon', 'Zupka hińska', '4'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', '4'),
    ('Nongshim', 'Super Spicy Red Shin', '4'),
    ('Indomie', 'Noodles Chicken Flavour', '4'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', '4'),
    ('Nongshim', 'Kimchi Bowl Noodles', '4'),
    ('NongshimSamyang', 'Ramen kimchi', '4'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', '4'),
    ('มาม่า', 'Mala Beef Instant Noodle', '4'),
    ('Mama', 'Mama salted egg', '4'),
    ('Knorr', 'Danie makaron Bolognese', '4'),
    ('Nongshim', 'Shin Kimchi Noodles', '4'),
    ('Reeva', 'Zupa o smaku sera i boczku', '4'),
    ('Winiary', 'Saucy noodles smak sweet chili', '4'),
    ('Knorr', 'Nudle Pieczony kurczak', '4'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', '4')
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
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;
