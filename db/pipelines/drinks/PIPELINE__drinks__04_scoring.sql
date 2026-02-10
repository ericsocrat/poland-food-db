-- PIPELINE (Drinks): scoring
-- Generated: 2026-02-09

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
    ('Hortex', 'Sok jabłkowy', 0),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', 0),
    ('go VEGE', 'Napój roślinny owies bio', 0),
    ('Polaris', 'Napój gazowany Vital Red', 2),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 0),
    ('Rivia', 'Rivia Marchew Brzoskwinia Jabkło', 2),
    ('Tymbark', 'Sok 100% Pomarańcza', 0),
    ('Tymbark', 'Sok 100% jabłko', 0),
    ('kubuš', '100% jabłko', 0),
    ('Żywiec Zdrój', 'Żywiec Zdrój NGaz 0.5', 0),
    ('Hortex', 'Sok 100% pomarańcza', 0),
    ('Bracia Sadownicy', 'Tłoczone Jabłko słodkie odmiany', 0),
    ('Tymbark', 'Tymbark Jabłko-Wiśnia', 3),
    ('GoVege', 'Ryż', 0),
    ('MWS', 'Kubuś Waterrr Truskawka', 0),
    ('Tymbark', 'Tymbark Jabłko Wiśnia 2l', 3),
    ('Riviva', 'Sok 100% jabłko', 0),
    ('Tymbark', 'Tymbark Jablko Mięta 0.5', 1),
    ('Żywiec Zdrój', 'Niegazowany', 0),
    ('pepsico', 'pepsi', 3),
    ('Tymbark', 'Cactus', 7),
    ('Unknown', 'Żywiec Zdrój NGaz 1l', 0),
    ('Unknown', 'Żywiec Zdrój Minerals', 0),
    ('Tymbark', 'Tymbark 100% jablko', 0),
    ('Riviva', 'Sok 100% multiwitamina', 0),
    ('Go vege', 'Barista owies', 1),
    ('Frugo', 'Frugo ultragreen', 3),
    ('kubus', 'Kubus Play Malina', 0),
    ('Pepsi', 'Pepsi Zero', 6),
    ('Riviva', 'Jus d''orange 100%', 0),
    ('Vitanella', 'Vitanella Breakfast Smoothie', 0),
    ('Tiger', 'Tiger placebo classic', 8),
    ('Tymbark', 'Tymbark Jabłko Wiśnia', 0),
    ('Tymbark', 'Sok 100% Multiwitamina', 0),
    ('OSHEE', 'OSHEE VITAMIN WATER', 0),
    ('Black', 'Black Energy', 5),
    ('4move', 'Activevitamin', 7),
    ('Dawtona', 'Sok pomidorowy', 0),
    ('Oshee', 'Oshee lemonade Malina-Grejpfrut', 1),
    ('Pepsico', 'Pepsi 1.5', 3),
    ('active vitamin', '4move', 3),
    ('Vital FRESH', 'smoothie Mango Jabłko Banan Marakuja', 0),
    ('oshee', 'Oshee Multifruit', 9),
    ('Tiger', 'TIGER Energy drink', 6),
    ('Oshee', 'Vitamin Water zero', 3),
    ('Tymbark', 'Tymbark nektar czerwony grejpfrut', 1),
    ('Pepsi', 'Pepsi 330ML Max Soft Drink', 0),
    ('Pepsi', 'Pepsi 0.5', 3),
    ('Vital FRESH', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', 0),
    ('Black', 'Black Zero Sugar', 7),
    ('Pepsi', 'Pepsi Max 1.5', 7),
    ('Asia Flavours', 'Coconut Milk', 1),
    ('OSHEE', 'OSHEE Zero', 9),
    ('zywiec zdroj', 'Zywiec Woda Srednio Gazowana', 0),
    ('Tymbark', 'Jablko Arbuz', 3),
    ('I♥Vege', 'Owsiane', 2),
    ('Tymbark', 'Mousse', 0),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 0),
    ('Hortex', 'Ananas nektar', 1),
    ('Herbapol', 'Malina', 0)
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
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.2'
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
    ('Hortex', 'Sok jabłkowy', 'C'),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', 'C'),
    ('go VEGE', 'Napój roślinny owies bio', 'C'),
    ('Polaris', 'Napój gazowany Vital Red', 'C'),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'D'),
    ('Rivia', 'Rivia Marchew Brzoskwinia Jabkło', 'D'),
    ('Tymbark', 'Sok 100% Pomarańcza', 'C'),
    ('Tymbark', 'Sok 100% jabłko', 'C'),
    ('kubuš', '100% jabłko', 'UNKNOWN'),
    ('Żywiec Zdrój', 'Żywiec Zdrój NGaz 0.5', 'A'),
    ('Hortex', 'Sok 100% pomarańcza', 'C'),
    ('Bracia Sadownicy', 'Tłoczone Jabłko słodkie odmiany', 'D'),
    ('Tymbark', 'Tymbark Jabłko-Wiśnia', 'D'),
    ('GoVege', 'Ryż', 'E'),
    ('MWS', 'Kubuś Waterrr Truskawka', 'C'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia 2l', 'D'),
    ('Riviva', 'Sok 100% jabłko', 'C'),
    ('Tymbark', 'Tymbark Jablko Mięta 0.5', 'E'),
    ('Żywiec Zdrój', 'Niegazowany', 'B'),
    ('pepsico', 'pepsi', 'E'),
    ('Tymbark', 'Cactus', 'C'),
    ('Unknown', 'Żywiec Zdrój NGaz 1l', 'B'),
    ('Unknown', 'Żywiec Zdrój Minerals', 'A'),
    ('Tymbark', 'Tymbark 100% jablko', 'C'),
    ('Riviva', 'Sok 100% multiwitamina', 'C'),
    ('Go vege', 'Barista owies', 'C'),
    ('Frugo', 'Frugo ultragreen', 'C'),
    ('kubus', 'Kubus Play Malina', 'C'),
    ('Pepsi', 'Pepsi Zero', 'C'),
    ('Riviva', 'Jus d''orange 100%', 'C'),
    ('Vitanella', 'Vitanella Breakfast Smoothie', 'D'),
    ('Tiger', 'Tiger placebo classic', 'D'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia', 'B'),
    ('Tymbark', 'Sok 100% Multiwitamina', 'D'),
    ('OSHEE', 'OSHEE VITAMIN WATER', 'C'),
    ('Black', 'Black Energy', 'UNKNOWN'),
    ('4move', 'Activevitamin', 'C'),
    ('Dawtona', 'Sok pomidorowy', 'B'),
    ('Oshee', 'Oshee lemonade Malina-Grejpfrut', 'C'),
    ('Pepsico', 'Pepsi 1.5', 'E'),
    ('active vitamin', '4move', 'C'),
    ('Vital FRESH', 'smoothie Mango Jabłko Banan Marakuja', 'D'),
    ('oshee', 'Oshee Multifruit', 'D'),
    ('Tiger', 'TIGER Energy drink', 'D'),
    ('Oshee', 'Vitamin Water zero', 'B'),
    ('Tymbark', 'Tymbark nektar czerwony grejpfrut', 'E'),
    ('Pepsi', 'Pepsi 330ML Max Soft Drink', 'B'),
    ('Pepsi', 'Pepsi 0.5', 'D'),
    ('Vital FRESH', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', 'UNKNOWN'),
    ('Black', 'Black Zero Sugar', 'C'),
    ('Pepsi', 'Pepsi Max 1.5', 'C'),
    ('Asia Flavours', 'Coconut Milk', 'E'),
    ('OSHEE', 'OSHEE Zero', 'C'),
    ('zywiec zdroj', 'Zywiec Woda Srednio Gazowana', 'B'),
    ('Tymbark', 'Jablko Arbuz', 'D'),
    ('I♥Vege', 'Owsiane', 'C'),
    ('Tymbark', 'Mousse', 'B'),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'C'),
    ('Hortex', 'Ananas nektar', 'UNKNOWN'),
    ('Herbapol', 'Malina', 'B')
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
    ('Hortex', 'Sok jabłkowy', '1'),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', '1'),
    ('go VEGE', 'Napój roślinny owies bio', '3'),
    ('Polaris', 'Napój gazowany Vital Red', '4'),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', '1'),
    ('Rivia', 'Rivia Marchew Brzoskwinia Jabkło', '4'),
    ('Tymbark', 'Sok 100% Pomarańcza', '1'),
    ('Tymbark', 'Sok 100% jabłko', '1'),
    ('kubuš', '100% jabłko', '4'),
    ('Żywiec Zdrój', 'Żywiec Zdrój NGaz 0.5', '1'),
    ('Hortex', 'Sok 100% pomarańcza', '4'),
    ('Bracia Sadownicy', 'Tłoczone Jabłko słodkie odmiany', '1'),
    ('Tymbark', 'Tymbark Jabłko-Wiśnia', '4'),
    ('GoVege', 'Ryż', '4'),
    ('MWS', 'Kubuś Waterrr Truskawka', '4'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia 2l', '4'),
    ('Riviva', 'Sok 100% jabłko', '4'),
    ('Tymbark', 'Tymbark Jablko Mięta 0.5', '4'),
    ('Żywiec Zdrój', 'Niegazowany', '1'),
    ('pepsico', 'pepsi', '4'),
    ('Tymbark', 'Cactus', '4'),
    ('Unknown', 'Żywiec Zdrój NGaz 1l', '1'),
    ('Unknown', 'Żywiec Zdrój Minerals', '1'),
    ('Tymbark', 'Tymbark 100% jablko', '1'),
    ('Riviva', 'Sok 100% multiwitamina', '4'),
    ('Go vege', 'Barista owies', '3'),
    ('Frugo', 'Frugo ultragreen', '4'),
    ('kubus', 'Kubus Play Malina', '4'),
    ('Pepsi', 'Pepsi Zero', '4'),
    ('Riviva', 'Jus d''orange 100%', '1'),
    ('Vitanella', 'Vitanella Breakfast Smoothie', '1'),
    ('Tiger', 'Tiger placebo classic', '4'),
    ('Tymbark', 'Tymbark Jabłko Wiśnia', '4'),
    ('Tymbark', 'Sok 100% Multiwitamina', '4'),
    ('OSHEE', 'OSHEE VITAMIN WATER', '1'),
    ('Black', 'Black Energy', '4'),
    ('4move', 'Activevitamin', '4'),
    ('Dawtona', 'Sok pomidorowy', '3'),
    ('Oshee', 'Oshee lemonade Malina-Grejpfrut', '4'),
    ('Pepsico', 'Pepsi 1.5', '4'),
    ('active vitamin', '4move', '4'),
    ('Vital FRESH', 'smoothie Mango Jabłko Banan Marakuja', '1'),
    ('oshee', 'Oshee Multifruit', '4'),
    ('Tiger', 'TIGER Energy drink', '4'),
    ('Oshee', 'Vitamin Water zero', '4'),
    ('Tymbark', 'Tymbark nektar czerwony grejpfrut', '4'),
    ('Pepsi', 'Pepsi 330ML Max Soft Drink', '4'),
    ('Pepsi', 'Pepsi 0.5', '4'),
    ('Vital FRESH', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', '1'),
    ('Black', 'Black Zero Sugar', '4'),
    ('Pepsi', 'Pepsi Max 1.5', '4'),
    ('Asia Flavours', 'Coconut Milk', '4'),
    ('OSHEE', 'OSHEE Zero', '4'),
    ('zywiec zdroj', 'Zywiec Woda Srednio Gazowana', '1'),
    ('Tymbark', 'Jablko Arbuz', '4'),
    ('I♥Vege', 'Owsiane', '4'),
    ('Tymbark', 'Mousse', '4'),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', '4'),
    ('Hortex', 'Ananas nektar', '3'),
    ('Herbapol', 'Malina', '4')
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

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;
