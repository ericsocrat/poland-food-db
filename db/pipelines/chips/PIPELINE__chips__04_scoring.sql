-- PIPELINE (Chips): scoring
-- Generated: 2026-02-11

-- 0. DEFAULT concern score for products without ingredient data
update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Chips'
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Intersnack', 'Prażynki solone', 'D'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 'D'),
    ('Miami', 'Pałeczki kukurydziane', 'UNKNOWN'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', 'D'),
    ('Przysnacki', 'Prażynki bekonowe', 'E'),
    ('Przysnacki', 'Chipsy w kotle prażone', 'D'),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', 'D'),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', 'E'),
    ('Star', 'Maczugi', 'D'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 'D'),
    ('Przysnacki', 'Chrupki o smaku keczupu', 'D'),
    ('Crunchips', 'Crunchips X-CUT, Papryka', 'D'),
    ('Lorenz', 'Crunchips Sticks Ketchup', 'C'),
    ('Lorenz', 'Crunchips X-cut Chakalaka', 'D'),
    ('TOP', 'Tortilla', 'C'),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', 'D'),
    ('Miami', 'Chrupki kukurydziane', 'A'),
    ('Top', 'Sticks smak ketchup', 'D'),
    ('Curly', 'Curly Mexican style', 'D'),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', 'E'),
    ('Sunny Family', 'Trips kukurydziane', 'C'),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', 'D'),
    ('Top', 'Top Sticks', 'D'),
    ('Lay''s', 'Chipsy ziemniaczane solone', 'D'),
    ('Go Vege', 'Tortilla Chips Buraczane', 'C'),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', 'D'),
    ('Lay''s', 'Karbowane Papryka', 'D'),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', 'E'),
    ('Lay''s', 'Lay''s green onion flavoured', 'D'),
    ('Lay''s', 'Fromage flavoured chips', 'C'),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', 'C'),
    ('Lay''s', 'Lays Papryka', 'UNKNOWN'),    ('Top', 'Chipsy smak serek Fromage', 'D'),
    ('Zdrowidło', 'Loopeas light o smaku papryki', 'D'),
    ('Lay''s', 'Lays strong', 'D'),
    ('Lay''s', 'Lays solone', 'D'),
    ('Doritos', 'Hot Corn', 'D'),
    ('Lay''s', 'Oven Baked krakersy', 'D'),
    ('Sonko', 'Chipsy z ciecierzycy', 'D'),
    ('Crunchips', 'Potato crisps with paprika flavour', 'D'),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', 'D'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 'E'),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', 'D'),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 'D'),
    ('Cheetos', 'Cheetos Flamin Hot', 'D'),
    ('Lay''s', 'Flamin'' Hot', 'C'),
    ('Lorenz', 'Peppies Bacon Flavour', 'E'),
    ('Lorenz', 'Monster Munch Mr BIG', 'E'),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Intersnack', 'Prażynki solone', '3'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', '4'),
    ('Miami', 'Pałeczki kukurydziane', '3'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', '4'),
    ('Przysnacki', 'Prażynki bekonowe', '4'),
    ('Przysnacki', 'Chipsy w kotle prażone', '3'),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', '4'),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', '4'),
    ('Star', 'Maczugi', '4'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', '4'),
    ('Przysnacki', 'Chrupki o smaku keczupu', '4'),
    ('Crunchips', 'Crunchips X-CUT, Papryka', '4'),
    ('Lorenz', 'Crunchips Sticks Ketchup', '4'),
    ('Lorenz', 'Crunchips X-cut Chakalaka', '4'),
    ('TOP', 'Tortilla', '4'),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', '4'),
    ('Miami', 'Chrupki kukurydziane', '3'),
    ('Top', 'Sticks smak ketchup', '4'),
    ('Curly', 'Curly Mexican style', '4'),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', '4'),
    ('Sunny Family', 'Trips kukurydziane', '3'),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', '4'),
    ('Top', 'Top Sticks', '3'),
    ('Lay''s', 'Chipsy ziemniaczane solone', '3'),
    ('Go Vege', 'Tortilla Chips Buraczane', '3'),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', '4'),
    ('Lay''s', 'Karbowane Papryka', '4'),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', '4'),
    ('Lay''s', 'Lay''s green onion flavoured', '4'),
    ('Lay''s', 'Fromage flavoured chips', '4'),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', '4'),
    ('Lay''s', 'Lays Papryka', '4'),    ('Top', 'Chipsy smak serek Fromage', '4'),
    ('Zdrowidło', 'Loopeas light o smaku papryki', '4'),
    ('Lay''s', 'Lays strong', '4'),
    ('Lay''s', 'Lays solone', '3'),
    ('Doritos', 'Hot Corn', '4'),
    ('Lay''s', 'Oven Baked krakersy', '4'),
    ('Sonko', 'Chipsy z ciecierzycy', '4'),
    ('Crunchips', 'Potato crisps with paprika flavour', '4'),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', '4'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', '4'),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', '3'),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', '4'),
    ('Cheetos', 'Cheetos Flamin Hot', '4'),
    ('Lay''s', 'Flamin'' Hot', '4'),
    ('Lorenz', 'Peppies Bacon Flavour', '4'),
    ('Lorenz', 'Monster Munch Mr BIG', '4'),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', '4')
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;
