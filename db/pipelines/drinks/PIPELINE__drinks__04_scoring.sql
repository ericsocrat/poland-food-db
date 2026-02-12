-- PIPELINE (Drinks): scoring
-- Generated: 2026-02-09

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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
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
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;
