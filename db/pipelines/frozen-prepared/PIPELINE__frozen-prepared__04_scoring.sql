-- PIPELINE (Frozen & Prepared): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', '5'),
    ('Carrefour BIO', 'Ratatouille', '0'),
    ('Vitasia', 'soba noodles', '0'),
    ('Carrefour BIO', 'Riz Sans sucres ajoutés**', '0'),
    ('Gelatelli', 'Gelatelli Chocolate', '3'),
    ('Bon Gelati', 'Premium Bourbon - Dairy ice cream', '3'),
    ('Gelatelli', 'High Protein Salted Caramel Ice Cream', '4'),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', '0'),
    ('Bon Gelati', 'Salted caramel premium ice cream', '4'),
    ('Carrefour', 'Poisson pané', '0'),
    ('Carrefour BIO', 'PIZZA Chèvre Cuite au feu de bois', '0'),
    ('Bon Gelati', 'Walnut Bon Gelati', '2'),
    ('Carrefour BIO', 'Galettes de riz chocolat au lait', '0'),
    ('Italiamo', 'Pizza Prosciutto e Mozzarella', '3'),
    ('Gelatelli', 'High protein cookies & cream', '4'),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', '0'),
    ('Harrys', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', '0'),
    ('Bon Gelati', 'Bon Gelati Eiscreme mit Schlagsahne', '3'),
    ('Carrefour', 'Pain au Chocolat', '5'),
    ('Carrefour', 'Spaghetti', '0'),
    ('Magnum', 'Magnum Crème Glacée en Pot Amande 440ml', '6'),
    ('Gelatelli', 'Creme al pistacchio', '4'),
    ('Nixe', 'Weisser Thunfish Alalunga', '0'),
    ('Mars', 'Snickers ice cream', '2'),
    ('Bon Gelati', 'Stracciatella Premium Eis', '3'),
    ('Bon Gelati', 'Glace Erdbeer Strawberry ice cream premium', '1'),
    ('Simpl', 'Tranches de filets de Colin d''Alaska', '0'),
    ('Carrefour', 'Cônes parfum vanille', '3')
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
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 'D'),
    ('Carrefour BIO', 'Ratatouille', 'A'),
    ('Vitasia', 'soba noodles', 'C'),
    ('Carrefour BIO', 'Riz Sans sucres ajoutés**', 'D'),
    ('Gelatelli', 'Gelatelli Chocolate', 'B'),
    ('Bon Gelati', 'Premium Bourbon - Dairy ice cream', 'D'),
    ('Gelatelli', 'High Protein Salted Caramel Ice Cream', 'C'),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', 'A'),
    ('Bon Gelati', 'Salted caramel premium ice cream', 'E'),
    ('Carrefour', 'Poisson pané', 'C'),
    ('Carrefour BIO', 'PIZZA Chèvre Cuite au feu de bois', 'D'),
    ('Bon Gelati', 'Walnut Bon Gelati', 'D'),
    ('Carrefour BIO', 'Galettes de riz chocolat au lait', 'E'),
    ('Italiamo', 'Pizza Prosciutto e Mozzarella', 'C'),
    ('Gelatelli', 'High protein cookies & cream', 'C'),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'A'),
    ('Harrys', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', 'D'),
    ('Bon Gelati', 'Bon Gelati Eiscreme mit Schlagsahne', 'D'),
    ('Carrefour', 'Pain au Chocolat', 'E'),
    ('Carrefour', 'Spaghetti', 'A'),
    ('Magnum', 'Magnum Crème Glacée en Pot Amande 440ml', 'D'),
    ('Gelatelli', 'Creme al pistacchio', 'E'),
    ('Nixe', 'Weisser Thunfish Alalunga', 'D'),
    ('Mars', 'Snickers ice cream', 'D'),
    ('Bon Gelati', 'Stracciatella Premium Eis', 'D'),
    ('Bon Gelati', 'Glace Erdbeer Strawberry ice cream premium', 'D'),
    ('Simpl', 'Tranches de filets de Colin d''Alaska', 'A'),
    ('Carrefour', 'Cônes parfum vanille', 'E')
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
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', '4'),
    ('Carrefour BIO', 'Ratatouille', '3'),
    ('Vitasia', 'soba noodles', '3'),
    ('Carrefour BIO', 'Riz Sans sucres ajoutés**', '4'),
    ('Gelatelli', 'Gelatelli Chocolate', '4'),
    ('Bon Gelati', 'Premium Bourbon - Dairy ice cream', '4'),
    ('Gelatelli', 'High Protein Salted Caramel Ice Cream', '4'),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', '1'),
    ('Bon Gelati', 'Salted caramel premium ice cream', '4'),
    ('Carrefour', 'Poisson pané', '3'),
    ('Carrefour BIO', 'PIZZA Chèvre Cuite au feu de bois', '3'),
    ('Bon Gelati', 'Walnut Bon Gelati', '4'),
    ('Carrefour BIO', 'Galettes de riz chocolat au lait', '3'),
    ('Italiamo', 'Pizza Prosciutto e Mozzarella', '4'),
    ('Gelatelli', 'High protein cookies & cream', '4'),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', '1'),
    ('Harrys', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', '4'),
    ('Bon Gelati', 'Bon Gelati Eiscreme mit Schlagsahne', '4'),
    ('Carrefour', 'Pain au Chocolat', '4'),
    ('Carrefour', 'Spaghetti', '1'),
    ('Magnum', 'Magnum Crème Glacée en Pot Amande 440ml', '4'),
    ('Gelatelli', 'Creme al pistacchio', '4'),
    ('Nixe', 'Weisser Thunfish Alalunga', '3'),
    ('Mars', 'Snickers ice cream', '4'),
    ('Bon Gelati', 'Stracciatella Premium Eis', '4'),
    ('Bon Gelati', 'Glace Erdbeer Strawberry ice cream premium', '4'),
    ('Simpl', 'Tranches de filets de Colin d''Alaska', '1'),
    ('Carrefour', 'Cônes parfum vanille', '4')
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
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;
