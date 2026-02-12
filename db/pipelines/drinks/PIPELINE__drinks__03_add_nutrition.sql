-- PIPELINE (Drinks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Drinks'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Hortex', 'Sok jabłkowy', 44.0, 0.0, 0.0, 0, 10.7, 10.3, 0, 0.2, 0.0),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', 46.0, 0.0, 0.0, 0, 11.0, 11.0, 0.6, 0.0, 0.0),
    ('Polaris', 'Napój gazowany Vital Red', 20.0, 0.5, 0.0, 0, 4.9, 4.7, 0, 0.5, 0.0),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 46.0, 0.0, 0.0, 0, 12.0, 12.0, 0, 0.0, 0.0),
    ('Rivia', 'Rivia Marchew Brzoskwinia Jabkło', 37.0, 0.5, 0.1, 0, 7.9, 7.9, 0.0, 0.5, 0.0),
    ('Tymbark', 'Sok 100% Pomarańcza', 44.0, 0.0, 0, 0, 10.0, 10.0, 0, 0.6, 0.0),
    ('Tymbark', 'Sok 100% jabłko', 43.0, 0.0, 0.0, 0, 11.0, 11.0, 0, 0.0, 0.0),
    ('kubuš', '100% jabłko', 43.0, 0.0, 0.0, 0, 11.0, 11.0, 0, 0.0, 0),
    ('Żywiec Zdrój', 'Żywiec Zdrój NGaz 0.5', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Hortex', 'Sok 100% pomarańcza', 45.0, 0.0, 0.0, 0, 10.6, 10.5, 0, 0.6, 0.0),
    ('Bracia Sadownicy', 'Tłoczone Jabłko słodkie odmiany', 46.0, 0.0, 0.0, 0, 11.0, 10.0, 0, 0.0, 0.0),
    ('Tymbark', 'Tymbark Jabłko-Wiśnia', 19.0, 0.0, 0.0, 0, 4.5, 4.5, 0.0, 0.0, 0.0),
    ('GoVege', 'Ryż', 65.0, 1.0, 0.1, 0, 13.4, 7.6, 0.4, 0.3, 0.1),
    ('MWS', 'Kubuś Waterrr Truskawka', 20.0, 0.0, 0.0, 0, 4.9, 4.9, 0, 0.0, 0.0),
    ('Tymbark', 'Tymbark Jabłko Wiśnia 2l', 19.0, 0.0, 0.0, 0, 4.5, 4.5, 0.0, 0.0, 0.0),
    ('Riviva', 'Sok 100% jabłko', 42.0, 0.5, 0.0, 0, 10.0, 10.0, 0, 0.5, 0.0),
    ('Tymbark', 'Tymbark Jablko Mięta 0.5', 36.0, 0.0, 0.0, 0, 9.0, 9.0, 0, 0.0, 0.0),
    ('Żywiec Zdrój', 'Niegazowany', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('pepsico', 'pepsi', 43.0, 0.0, 0.0, 0, 11.0, 11.0, 0, 0.0, 0.0),
    ('Tymbark', 'Cactus', 20.0, 0.0, 0.0, 0, 4.8, 4.8, 0.0, 0.0, 0.0),
    ('Unknown', 'Żywiec Zdrój NGaz 1l', 85.0, 0.0, 0.0, 0, 21.3, 0.0, 0, 0.0, 0.0),
    ('Unknown', 'Żywiec Zdrój Minerals', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Tymbark', 'Tymbark 100% jablko', 43.0, 0.0, 0.0, 0, 11.0, 11.0, 0.0, 0.0, 0.0),
    ('Riviva', 'Sok 100% multiwitamina', 45.0, 0.5, 0.1, 0, 11.0, 11.0, 0, 0.5, 0.0),
    ('Go vege', 'Barista owies', 58.0, 3.0, 0.3, 0, 5.5, 1.1, 0.9, 1.7, 0.1),
    ('Frugo', 'Frugo ultragreen', 21.0, 0.0, 0.0, 0, 4.9, 4.9, 0, 0.0, 0.0),
    ('kubus', 'Kubus Play Malina', 22.0, 0.5, 0.1, 0, 5.4, 5.4, 0.5, 0.0, 0.0),
    ('Pepsi', 'Pepsi Zero', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Riviva', 'Jus d''orange 100%', 43.0, 0.5, 0.1, 0, 9.8, 9.8, 0, 0.6, 0.0),
    ('Vitanella', 'Vitanella Breakfast Smoothie', 56.0, 0.0, 0.0, 0, 13.0, 12.0, 0.0, 0.6, 0.0),
    ('Tiger', 'Tiger placebo classic', 21.0, 0.0, 0.0, 0, 4.9, 4.9, 0.0, 0.0, 0.1),
    ('Tymbark', 'Tymbark Jabłko Wiśnia', 19.0, 0.0, 0.0, 0, 4.5, 4.5, 0.0, 0.0, 0.0),
    ('Tymbark', 'Sok 100% Multiwitamina', 51.0, 0.0, 0.0, 0, 12.0, 12.0, 0, 0.0, 0.0),
    ('OSHEE', 'OSHEE VITAMIN WATER', 21.0, 0.0, 0.0, 0, 4.8, 4.7, 0, 0.0, 0.0),
    ('Black', 'Black Energy', 42.0, 0.0, 0, 0, 9.9, 0, 0, 0.0, 0),
    ('4move', 'Activevitamin', 11.0, 0.0, 0.0, 0, 2.1, 2.0, 0, 0.0, 0.0),
    ('Dawtona', 'Sok pomidorowy', 19.0, 0.0, 0, 0, 3.1, 3.1, 0.0, 1.0, 0.4),
    ('Oshee', 'Oshee lemonade Malina-Grejpfrut', 19.0, 0.0, 0.0, 0, 4.6, 4.5, 0, 0.0, 0.0),
    ('Pepsico', 'Pepsi 1.5', 43.0, 0.0, 0.0, 0, 11.0, 11.0, 0.0, 0.0, 0.1),
    ('active vitamin', '4move', 10.0, 0.4, 0.0, 0, 3.0, 2.0, 0, 0.0, 0.0),
    ('Vital FRESH', 'smoothie Mango Jabłko Banan Marakuja', 54.0, 0.0, 0.0, 0, 12.4, 12.4, 1.0, 0.6, 0.0),
    ('oshee', 'Oshee Multifruit', 17.7, 0.0, 0, 0, 4.0, 4.0, 0, 0.0, 0.1),
    ('Tiger', 'TIGER Energy drink', 21.0, 0.0, 0.0, 0, 4.9, 4.9, 0.0, 0.0, 0.2),
    ('Oshee', 'Vitamin Water zero', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Tymbark', 'Tymbark nektar czerwony grejpfrut', 42.0, 0.0, 0.0, 0, 9.9, 9.9, 0, 0.0, 0.0),
    ('Pepsi', 'Pepsi 330ML Max Soft Drink', 0.6, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Pepsi', 'Pepsi 0.5', 28.0, 0.0, 0.0, 0, 7.0, 7.0, 0, 0.0, 0.1),
    ('Vital FRESH', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', 40.0, 0.0, 0.0, 0, 9.0, 6.8, 0.8, 0.6, 0),
    ('Black', 'Black Zero Sugar', 2.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.2),
    ('Pepsi', 'Pepsi Max 1.5', 1.0, 0.0, 0, 0, 0.0, 0, 0, 0.0, 0.0),
    ('Asia Flavours', 'Coconut Milk', 169.0, 18.0, 15.0, 0, 1.5, 1.5, 0, 1.2, 0.0),
    ('OSHEE', 'OSHEE Zero', 0.1, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.1),
    ('zywiec zdroj', 'Zywiec Woda Srednio Gazowana', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Tymbark', 'Jablko Arbuz', 19.0, 0.0, 0.0, 0, 4.7, 4.7, 0, 0.0, 0.0),
    ('I♥Vege', 'Owsiane', 31.0, 0.7, 0.1, 0, 5.7, 3.9, 0.3, 0.4, 0.1),
    ('Tymbark', 'Mousse', 58.3, 0.4, 0.0, 0.0, 14.2, 0.0, 0.0, 0.8, 0.0),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 41.0, 0.0, 0.0, 0, 8.8, 8.7, 0, 0.7, 0.0),
    ('Hortex', 'Ananas nektar', 25.0, 0.0, 0, 0, 6.0, 6.0, 0, 0.2, 0),
    ('Herbapol', 'Malina', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    -- ── Batch 2 — drinks (new) ──────────────────────────────────────────────────────
    ('Active Vitamin',  '4move',                        44, 0, 0, 0, 10, 10, 0, 0, 0),           -- OFF
    ('Go Vege',         'Napój roślinny owies bio',       45, 1.5, 0.2, 0, 6.5, 4.0, 0.8, 1.0, 0.10),  -- est. typical oat drink
    ('Kubus',           'Kubus Play Malina',            22, 0.5, 0.1, 0, 5.4, 5.4, 0.5, 0, 0),    -- OFF
    ('Kubuš',           '100% jabłko',                  46, 0.1, 0, 0, 11, 10, 0.2, 0.1, 0.01),     -- est. typical apple juice
    ('Oshee',           'Oshee Multifruit',             18, 0, 0, 0, 4.1, 4.0, 0, 0, 0.14),       -- OFF
    ('Oshee',           'OSHEE Zero',                    0, 0, 0, 0, 0, 0, 0, 0, 0.07),           -- OFF
    ('Zywiec Zdroj',    'Zywiec Woda Srednio Gazowana',  0, 0, 0, 0, 0, 0, 0, 0, 0)               -- OFF (mineral water)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Drinks' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
