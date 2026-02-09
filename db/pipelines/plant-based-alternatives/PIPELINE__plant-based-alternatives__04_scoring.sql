-- PIPELINE (Plant-Based & Alternatives): scoring
-- Generated: 2026-02-09

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
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 0),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', 0),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 0),
    ('Batts', 'Crispy Fried Onions', 0),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 0),
    ('DONAU SOJA', 'Tofu smoked', 2),
    ('Vitasia', 'Rice Noodles', 0),
    ('LIDL', 'ground chili peppers in olive oil', 1),
    ('Carrefour BIO', 'Galettes épeautre', 0),
    ('Baresa', 'Lasagnes', 0),
    ('Vemondo', 'Tofu naturalne', 2),
    ('Lidl', 'Avocados', 0),
    ('Vemondo', 'Tofu basil Bio', 1),
    ('Carrefour BIO', 'Galettes 4 Céréales', 0),
    ('Vita D''or', 'Rapsöl', 0),
    ('Driscoll''s', 'Framboises', 0),
    ('Lidl', 'Kalamata olive paste', 1),
    ('Carrefour', 'Spaghetti', 0),
    ('ALDI Zespri', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', 0)
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'B'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', 'A'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 'B'),
    ('Batts', 'Crispy Fried Onions', 'E'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'A'),
    ('DONAU SOJA', 'Tofu smoked', 'B'),
    ('Vitasia', 'Rice Noodles', 'B'),
    ('LIDL', 'ground chili peppers in olive oil', 'NOT-APPLICABLE'),
    ('Carrefour BIO', 'Galettes épeautre', 'A'),
    ('Baresa', 'Lasagnes', 'A'),
    ('Vemondo', 'Tofu naturalne', 'A'),
    ('Lidl', 'Avocados', 'A'),
    ('Vemondo', 'Tofu basil Bio', 'A'),
    ('Carrefour BIO', 'Galettes 4 Céréales', 'A'),
    ('Vita D''or', 'Rapsöl', 'B'),
    ('Driscoll''s', 'Framboises', 'A'),
    ('Lidl', 'Kalamata olive paste', 'UNKNOWN'),
    ('Carrefour', 'Spaghetti', 'A'),
    ('ALDI Zespri', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', 'A')
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
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', '4'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', '4'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', '2'),
    ('Batts', 'Crispy Fried Onions', '3'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', '1'),
    ('DONAU SOJA', 'Tofu smoked', '4'),
    ('Vitasia', 'Rice Noodles', '3'),
    ('LIDL', 'ground chili peppers in olive oil', '3'),
    ('Carrefour BIO', 'Galettes épeautre', '3'),
    ('Baresa', 'Lasagnes', '1'),
    ('Vemondo', 'Tofu naturalne', '4'),
    ('Lidl', 'Avocados', '1'),
    ('Vemondo', 'Tofu basil Bio', '4'),
    ('Carrefour BIO', 'Galettes 4 Céréales', '3'),
    ('Vita D''or', 'Rapsöl', '4'),
    ('Driscoll''s', 'Framboises', '1'),
    ('Lidl', 'Kalamata olive paste', '3'),
    ('Carrefour', 'Spaghetti', '1'),
    ('ALDI Zespri', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', '1')
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;
