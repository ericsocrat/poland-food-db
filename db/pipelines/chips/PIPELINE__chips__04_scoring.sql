-- PIPELINE (Chips): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Intersnack', 'Prażynki solone', 0),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 2),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o.', 'Wiejskie ziemniaczki - smak masło z solą', 2),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 3),
    ('Star', 'Maczugi', 3),
    ('Przysnacki', 'Chrupki o smaku keczupu', 2),
    ('Lorenz', 'Crunchips Sticks Ketchup', 2),
    ('Lay''s', 'Fromage flavoured chips', 6),
    ('Lay''s', 'Lays solone', 1),
    ('Lay''s', 'Lay''s green onion flavoured', 7),
    ('Lay''s', 'Lays Papryka', 3),
    ('Lay''s', 'Lays strong', 3),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 7),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', 5),
    ('Doritos', 'Flamingo Hot', 6),
    ('Doritos', 'Hot Corn', 5),
    ('Lay''s', 'Lays gr. priesk. zolel. sk.', 0),
    ('Cheetos', 'Cheetos Flamin Hot', 4),
    ('Lay''s', 'Cheetos Cheese', 4),
    ('Crunchips', 'Potato crisps with paprika flavour.', 2),
    ('Lay''s', 'Lays MAXX cheese & onion', 8),
    ('Top', 'Chipsy smak serek Fromage', 1),
    ('Lay''s', 'Lays Green Onion', 6),
    ('Lorenz', 'Crunchips X-CUT Chakalaka', 1),
    ('zdrowidło', 'Loopeas light o smaku papryki', 3),
    ('Lay''s', 'Flamin'' Hot', 3),
    ('Lay''s', 'Oven Baked Chanterelles in a cream sauce flavoured', 0),
    ('Lay''s', 'Chips', 0)
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;
