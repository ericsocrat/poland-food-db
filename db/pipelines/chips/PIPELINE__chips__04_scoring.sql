-- PIPELINE (Chips): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Chips'
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
  ),
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Intersnack', 'Prażynki solone', 'D'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 'D'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o.', 'Wiejskie ziemniaczki - smak masło z solą', 'D'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 'D'),
    ('Star', 'Maczugi', 'D'),
    ('Przysnacki', 'Chrupki o smaku keczupu', 'D'),
    ('Lorenz', 'Crunchips Sticks Ketchup', 'C'),
    ('Lay''s', 'Fromage flavoured chips', 'C'),
    ('Lay''s', 'Lays solone', 'D'),
    ('Lay''s', 'Lay''s green onion flavoured', 'D'),
    ('Lay''s', 'Lays Papryka', 'UNKNOWN'),
    ('Lay''s', 'Lays strong', 'D'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 'E'),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', 'C'),
    ('Doritos', 'Flamingo Hot', 'UNKNOWN'),
    ('Doritos', 'Hot Corn', 'D'),
    ('Lay''s', 'Lays gr. priesk. zolel. sk.', 'D'),
    ('Cheetos', 'Cheetos Flamin Hot', 'D'),
    ('Lay''s', 'Cheetos Cheese', 'E'),
    ('Crunchips', 'Potato crisps with paprika flavour.', 'D'),
    ('Lay''s', 'Lays MAXX cheese & onion', 'D'),
    ('Top', 'Chipsy smak serek Fromage', 'D'),
    ('Lay''s', 'Lays Green Onion', 'D'),
    ('Lorenz', 'Crunchips X-CUT Chakalaka', 'D'),
    ('zdrowidło', 'Loopeas light o smaku papryki', 'D'),
    ('Lay''s', 'Flamin'' Hot', 'C'),
    ('Lay''s', 'Oven Baked Chanterelles in a cream sauce flavoured', 'C'),
    ('Lay''s', 'Chips', 'E')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Intersnack', 'Prażynki solone', 3),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 4),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o.', 'Wiejskie ziemniaczki - smak masło z solą', 4),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 4),
    ('Star', 'Maczugi', 4),
    ('Przysnacki', 'Chrupki o smaku keczupu', 4),
    ('Lorenz', 'Crunchips Sticks Ketchup', 4),
    ('Lay''s', 'Fromage flavoured chips', 4),
    ('Lay''s', 'Lays solone', 3),
    ('Lay''s', 'Lay''s green onion flavoured', 4),
    ('Lay''s', 'Lays Papryka', 4),
    ('Lay''s', 'Lays strong', 4),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 4),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', 4),
    ('Doritos', 'Flamingo Hot', 4),
    ('Doritos', 'Hot Corn', 4),
    ('Lay''s', 'Lays gr. priesk. zolel. sk.', 4),
    ('Cheetos', 'Cheetos Flamin Hot', 4),
    ('Lay''s', 'Cheetos Cheese', 4),
    ('Crunchips', 'Potato crisps with paprika flavour.', 4),
    ('Lay''s', 'Lays MAXX cheese & onion', 4),
    ('Top', 'Chipsy smak serek Fromage', 4),
    ('Lay''s', 'Lays Green Onion', 4),
    ('Lorenz', 'Crunchips X-CUT Chakalaka', 4),
    ('zdrowidło', 'Loopeas light o smaku papryki', 4),
    ('Lay''s', 'Flamin'' Hot', 4),
    ('Lay''s', 'Oven Baked Chanterelles in a cream sauce flavoured', 4),
    ('Lay''s', 'Chips', 4)
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;
