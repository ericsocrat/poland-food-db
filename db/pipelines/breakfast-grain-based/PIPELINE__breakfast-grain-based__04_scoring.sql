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
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 2),
    ('Biedronka', 'Vitanella Granola z czekoladą', 2),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 3),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 2),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 3),
    ('Sante', 'Masło orzechowe', 0),
    ('Łowicz', 'Dżem truskawkowy', 3),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 0),
    ('Laciaty', 'Serek puszysty naturalny Łaciaty', 0),
    ('One day more', 'Muesli Protein', 0),
    ('Vitanella', 'Musli premium', 1),
    ('Vitanella', 'Banana Chocolate musli', 0),
    ('GO ON', 'Peanut Butter Smooth', 0),
    ('Mazurskie Miody', 'Polish Honey multiflower', 0),
    ('Piątnica', 'Low Fat Cottage Cheese', 0),
    ('Mlekovita', 'Oselka', 0),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 0),
    ('Biedronka', 'Granola', 2)
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
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'C'),
    ('Biedronka', 'Vitanella Granola z czekoladą', 'D'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 'C'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 'C'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'D'),
    ('Sante', 'Masło orzechowe', 'C'),
    ('Łowicz', 'Dżem truskawkowy', 'D'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 'A'),
    ('Laciaty', 'Serek puszysty naturalny Łaciaty', 'D'),
    ('One day more', 'Muesli Protein', 'C'),
    ('Vitanella', 'Musli premium', 'D'),
    ('Vitanella', 'Banana Chocolate musli', 'D'),
    ('GO ON', 'Peanut Butter Smooth', 'A'),
    ('Mazurskie Miody', 'Polish Honey multiflower', 'E'),
    ('Piątnica', 'Low Fat Cottage Cheese', 'B'),
    ('Mlekovita', 'Oselka', 'E'),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 'C'),
    ('Biedronka', 'Granola', 'C')
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
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', '4'),
    ('Biedronka', 'Vitanella Granola z czekoladą', '4'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', '4'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', '4'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', '4'),
    ('Sante', 'Masło orzechowe', '4'),
    ('Łowicz', 'Dżem truskawkowy', '4'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', '3'),
    ('Laciaty', 'Serek puszysty naturalny Łaciaty', '4'),
    ('One day more', 'Muesli Protein', '3'),
    ('Vitanella', 'Musli premium', '3'),
    ('Vitanella', 'Banana Chocolate musli', '4'),
    ('GO ON', 'Peanut Butter Smooth', '1'),
    ('Mazurskie Miody', 'Polish Honey multiflower', '4'),
    ('Piątnica', 'Low Fat Cottage Cheese', '4'),
    ('Mlekovita', 'Oselka', '2'),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', '4'),
    ('Biedronka', 'Granola', '4')
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
