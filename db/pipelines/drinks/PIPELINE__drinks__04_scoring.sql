-- PIPELINE (Drinks): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Tymbark', 'Sok 100% Pomarańcza', 0),
    ('Mlekovita', 'Kefir', 0),
    ('Krasnystaw', 'kefir', 0),
    ('Żywiec Zdrój', 'Niegazowany', 0),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 0),
    ('Krasnystaw', 'Kefir', 0),
    ('oshee', 'Oshee Multifruit', 9),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 0),
    ('Coca-Cola', 'Napój gazowany o smaku cola', 7),
    ('Coca-Cola', 'Coca-Cola Original Taste', 3),
    ('Danone', 'Geröstete Mandel Ohne Zucker', 3),
    ('Millbona', 'HIGH PROTEIN Caramel Pudding', 4),
    ('Coca-Cola', 'Coca Cola Original taste', 2),
    ('Vemondo', 'Almond Drink', 1),
    ('Oatly', 'Haferdrink Barista', 1),
    ('alpro', 'Coco Délicieuse et Tropicale', 3),
    ('Milbona', 'High Protein Drink Cacao', 2),
    ('Vemondo', 'Bio Hafer', 0),
    ('Milbona', 'High Protein Drink Gusto Vaniglia', 2),
    ('Kikkoman', 'Kikkoman Sojasauce', 0),
    ('Kikkoman', 'Teriyakisauce', 1),
    ('Carrefour BIO', 'Avoine', 0),
    ('Vemondo', 'Boisson au soja', 0),
    ('Club Mate', 'Club-Mate Original', 2),
    ('Coca-Cola', 'coca cola 1,75', 2),
    ('Carrefour BIO', 'Amande Sans sucres', 0),
    ('Carrefour BIO', 'SOJA Sans sucres ajoutés', 0),
    ('Naturis', 'Apple Juice', 1)
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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Tymbark', 'Sok 100% Pomarańcza', 'C'),
    ('Mlekovita', 'Kefir', 'B'),
    ('Krasnystaw', 'kefir', 'B'),
    ('Żywiec Zdrój', 'Niegazowany', 'B'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'E'),
    ('Krasnystaw', 'Kefir', 'B'),
    ('oshee', 'Oshee Multifruit', 'D'),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'C'),
    ('Coca-Cola', 'Napój gazowany o smaku cola', 'C'),
    ('Coca-Cola', 'Coca-Cola Original Taste', 'E'),
    ('Danone', 'Geröstete Mandel Ohne Zucker', 'B'),
    ('Millbona', 'HIGH PROTEIN Caramel Pudding', 'C'),
    ('Coca-Cola', 'Coca Cola Original taste', 'E'),
    ('Vemondo', 'Almond Drink', 'B'),
    ('Oatly', 'Haferdrink Barista', 'D'),
    ('alpro', 'Coco Délicieuse et Tropicale', 'B'),
    ('Milbona', 'High Protein Drink Cacao', 'C'),
    ('Vemondo', 'Bio Hafer', 'C'),
    ('Milbona', 'High Protein Drink Gusto Vaniglia', 'D'),
    ('Kikkoman', 'Kikkoman Sojasauce', 'E'),
    ('Kikkoman', 'Teriyakisauce', 'E'),
    ('Carrefour BIO', 'Avoine', 'C'),
    ('Vemondo', 'Boisson au soja', 'B'),
    ('Club Mate', 'Club-Mate Original', 'C'),
    ('Coca-Cola', 'coca cola 1,75', 'E'),
    ('Carrefour BIO', 'Amande Sans sucres', 'B'),
    ('Carrefour BIO', 'SOJA Sans sucres ajoutés', 'B'),
    ('Naturis', 'Apple Juice', 'D')
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
    ('Tymbark', 'Sok 100% Pomarańcza', 1),
    ('Mlekovita', 'Kefir', 3),
    ('Krasnystaw', 'kefir', 4),
    ('Żywiec Zdrój', 'Niegazowany', 1),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 4),
    ('Krasnystaw', 'Kefir', 4),
    ('oshee', 'Oshee Multifruit', 4),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 4),
    ('Coca-Cola', 'Napój gazowany o smaku cola', 4),
    ('Coca-Cola', 'Coca-Cola Original Taste', 4),
    ('Danone', 'Geröstete Mandel Ohne Zucker', 4),
    ('Millbona', 'HIGH PROTEIN Caramel Pudding', 4),
    ('Coca-Cola', 'Coca Cola Original taste', 4),
    ('Vemondo', 'Almond Drink', 4),
    ('Oatly', 'Haferdrink Barista', 3),
    ('alpro', 'Coco Délicieuse et Tropicale', 4),
    ('Milbona', 'High Protein Drink Cacao', 4),
    ('Vemondo', 'Bio Hafer', 4),
    ('Milbona', 'High Protein Drink Gusto Vaniglia', 4),
    ('Kikkoman', 'Kikkoman Sojasauce', 3),
    ('Kikkoman', 'Teriyakisauce', 3),
    ('Carrefour BIO', 'Avoine', 3),
    ('Vemondo', 'Boisson au soja', 3),
    ('Club Mate', 'Club-Mate Original', 4),
    ('Coca-Cola', 'coca cola 1,75', 4),
    ('Carrefour BIO', 'Amande Sans sucres', 4),
    ('Carrefour BIO', 'SOJA Sans sucres ajoutés', 1),
    ('Naturis', 'Apple Juice', 1)
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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;
