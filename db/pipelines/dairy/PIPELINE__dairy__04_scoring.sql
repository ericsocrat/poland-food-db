-- PIPELINE (Dairy): scoring
-- Generated: 2026-02-11

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true
  and sc.product_id is null;

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  )
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Piątnica', 'Twój Smak Serek śmietankowy', 'D'),
    ('Mlekpol', 'Łaciate 3,2%', 'B'),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 'A'),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'A'),
    ('Mleczna Dolina', 'Mleko Świeże 2,0%', 'B'),
    ('Biedronka', 'Kefir naturalny 1,5 % tłuszczu', 'B'),
    ('Piątnica', 'Skyr z mango i marakują', 'A'),
    ('Wieluń', 'twarożek &quot;Mój ulubiony&quot;', 'D'),
    ('Piątnica', 'Śmietana 18%', 'D'),
    ('Sierpc', 'Ser królewski', 'D'),
    ('Piątnica', 'Mleko wieskie świeże 2%', 'B'),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 'B'),
    ('Almette', 'Serek Almette z ziołami', 'D'),
    ('Mlekpol', 'Świeże mleko', 'B'),
    ('Delikate', 'Twarożek grani klasyczny', 'C'),
    ('Ryki', 'ser żółty Active Protein Plus', 'C'),
    ('Zott', 'Primo śmietanka 30%', 'D'),
    ('Gostyńskie', 'Mleko zagęszczone słodzone', 'E'),
    ('Piątnica', 'Twarożek Domowy grani naturalny', 'C'),
    ('Piątnica', 'koktajl spożywczy', 'A'),
    ('SM Gostyń', 'Kajmak masa krówkowa gostyńska', 'E'),
    ('Piątnica', 'Koktail Białkowy malina & granat', 'D'),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', 'C'),
    ('Hochland', 'Ser żółty w plastrach Gouda', 'D'),
    ('Krasnystaw', 'kefir', 'B'),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 'C'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'B'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'E'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'B'),
    ('Piątnica', 'Skyr Wanilia', 'D'),
    ('Robico', 'Kefir Robcio', 'B'),
    ('Piątnica', 'Skyr Naturalny', 'A'),
    ('Piątnica', 'Soured cream 18%', 'D'),
    ('Zott', 'Jogurt naturalny', 'B'),
    ('Mlekpol', 'Mleko UHT 2%', 'B'),
    ('Almette', 'Puszysty Serek Jogurtowy', 'D'),
    ('Mleczna Dolina', 'mleko UHT 3,2%', 'C'),
    ('Spółdzielnia Mleczarska Ryki', 'Ser Rycki Edam kl.I', 'UNKNOWN'),
    ('Mleczna Dolina', 'Mleko 1,5% bez laktozy', 'B'),
    ('Mlekovita', '.', 'C'),
    ('Piątnica', 'Icelandic type yoghurt natural', 'A'),
    ('Favita', 'Favita', 'E'),
    ('Almette', 'Almette z chrzanem', 'D'),
    ('Mlekovita', 'Mleko 2%', 'B'),
    ('Mleczna Dolina', 'Mleko 1,5%', 'B'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 'C'),
    ('Mlekovita', 'Jogurt Grecki naturalny', 'C'),
    ('Delikate', 'Delikate Serek Smetankowy', 'D'),
    ('Mleczna dolina', 'Śmietana', 'D'),
    ('OSM Łowicz', 'Mleko UHT 3,2', 'C')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Piątnica', 'Twój Smak Serek śmietankowy', '4'),
    ('Mlekpol', 'Łaciate 3,2%', '1'),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', '3'),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', '1'),
    ('Mleczna Dolina', 'Mleko Świeże 2,0%', '1'),
    ('Biedronka', 'Kefir naturalny 1,5 % tłuszczu', '3'),
    ('Piątnica', 'Skyr z mango i marakują', '4'),
    ('Wieluń', 'twarożek &quot;Mój ulubiony&quot;', '3'),
    ('Piątnica', 'Śmietana 18%', '3'),
    ('Sierpc', 'Ser królewski', '4'),
    ('Piątnica', 'Mleko wieskie świeże 2%', '4'),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', '1'),
    ('Almette', 'Serek Almette z ziołami', '4'),
    ('Mlekpol', 'Świeże mleko', '1'),
    ('Delikate', 'Twarożek grani klasyczny', '3'),
    ('Ryki', 'ser żółty Active Protein Plus', '4'),
    ('Zott', 'Primo śmietanka 30%', '4'),
    ('Gostyńskie', 'Mleko zagęszczone słodzone', '4'),
    ('Piątnica', 'Twarożek Domowy grani naturalny', '3'),
    ('Piątnica', 'koktajl spożywczy', '4'),
    ('SM Gostyń', 'Kajmak masa krówkowa gostyńska', '3'),
    ('Piątnica', 'Koktail Białkowy malina & granat', '4'),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', '4'),
    ('Hochland', 'Ser żółty w plastrach Gouda', '4'),
    ('Krasnystaw', 'kefir', '4'),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', '1'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', '4'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', '4'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', '4'),
    ('Piątnica', 'Skyr Wanilia', '4'),
    ('Robico', 'Kefir Robcio', '1'),
    ('Piątnica', 'Skyr Naturalny', '1'),
    ('Piątnica', 'Soured cream 18%', '4'),
    ('Zott', 'Jogurt naturalny', '4'),
    ('Mlekpol', 'Mleko UHT 2%', '1'),
    ('Almette', 'Puszysty Serek Jogurtowy', '4'),
    ('Mleczna Dolina', 'mleko UHT 3,2%', '1'),
    ('Spółdzielnia Mleczarska Ryki', 'Ser Rycki Edam kl.I', '4'),
    ('Mleczna Dolina', 'Mleko 1,5% bez laktozy', '4'),
    ('Mlekovita', '.', '1'),
    ('Piątnica', 'Icelandic type yoghurt natural', '1'),
    ('Favita', 'Favita', '3'),
    ('Almette', 'Almette z chrzanem', '3'),
    ('Mlekovita', 'Mleko 2%', '4'),
    ('Mleczna Dolina', 'Mleko 1,5%', '4'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', '4'),
    ('Mlekovita', 'Jogurt Grecki naturalny', '3'),
    ('Delikate', 'Delikate Serek Smetankowy', '4'),
    ('Mleczna dolina', 'Śmietana', '4'),
    ('OSM Łowicz', 'Mleko UHT 3,2', '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;
