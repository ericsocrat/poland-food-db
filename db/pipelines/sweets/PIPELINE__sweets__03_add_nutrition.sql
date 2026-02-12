-- PIPELINE (Sweets): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Sweets'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('E.Wedel', 'Czekolada gorzka Wiśniowa', 484.0, 26.0, 14.0, 0, 56.0, 53.0, 4.8, 4.7, 0.1),
    ('Choctopus', 'Czekolada bąbelkowa mleczna', 531.0, 29.0, 18.0, 0, 59.0, 59.0, 0, 5.9, 0.2),
    ('Wawel', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', 546.0, 39.0, 24.0, 0, 35.0, 32.0, 0, 8.8, 0.0),
    ('Biedronka', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', 530.0, 29.0, 19.0, 0, 60.0, 59.0, 2.0, 5.6, 0.3),
    ('Milano', 'Czekolada mleczna z całymi orzechami laskowymi', 563.0, 40.0, 17.0, 0, 40.0, 39.0, 4.2, 9.5, 0.2),
    ('Biedronka', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami.', 527.0, 34.0, 19.0, 0, 43.0, 39.0, 9.8, 6.8, 0.1),
    ('Magnetic', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', 557.0, 35.0, 20.0, 0, 51.0, 50.0, 2.8, 7.2, 0.2),
    ('Magnetic', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', 562.0, 37.0, 22.0, 0, 50.0, 48.0, 4.1, 5.9, 0.1),
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 557.0, 36.0, 16.0, 0, 49.0, 40.0, 4.0, 7.7, 0.1),
    ('Wedel', 'Czekolada biała', 564.0, 34.6, 18.8, 0, 56.4, 56.4, 0.0, 6.0, 0.6),
    ('Mella', 'Galaretka w czekoladzie o smaku wiśniowym', 366.0, 7.2, 4.3, 0, 72.0, 60.0, 2.2, 0.8, 0.2),
    ('Wawel', 'Vege now z pastą z orzecha laskowego', 580.0, 40.0, 21.0, 0, 48.0, 47.0, 0, 3.7, 0.0),
    ('Mokate', 'Czekolada biała napój o smaku białej czekolady', 418.0, 8.4, 7.3, 0, 79.0, 61.0, 0, 6.6, 0.7),
    ('E. Wedel', 'Czekolada biała', 564.0, 35.0, 19.0, 0, 56.0, 56.0, 0.0, 6.1, 0.2),
    ('Royal Nut', 'Czekolada mleczna z całymi orzechami laskowymi', 530.0, 33.0, 16.0, 0, 49.0, 48.0, 0, 6.5, 0.2),
    ('Wawel', 'Piernikowa ze śliwką', 497.0, 26.0, 16.0, 0, 60.0, 53.0, 0, 3.9, 0.0),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 558.0, 45.0, 27.0, 0, 21.0, 16.0, 16.0, 10.0, 0.0),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 508.0, 33.0, 20.0, 0, 36.0, 32.0, 14.0, 9.1, 0.0),
    ('E. Wedel', 'Mleczna klasyczna', 534.0, 31.0, 17.0, 0, 55.0, 55.0, 2.7, 6.3, 0.2),
    ('Goplana', 'Gorzka 1912', 505.0, 32.0, 19.0, 0, 40.0, 36.0, 0, 8.0, 0.0),
    ('E. Wedel', 'Mleczna Truskawkowa', 499.0, 26.0, 13.0, 0.0, 62.0, 59.0, 1.6, 4.6, 0.1),
    ('E. Wedel', 'Wedel extra dark chocolate', 497.0, 42.0, 26.0, 0, 20.0, 17.0, 9.4, 10.0, 0.0),
    ('E. Wedel', 'Gorzka Kokosowa', 532.0, 32.0, 19.0, 0, 52.0, 50.0, 5.8, 6.0, 0.2),
    ('Mellie', 'Dark Chocolate Orange', 532.0, 36.0, 0, 0, 38.0, 32.0, 12.0, 7.7, 0.1),
    ('E. Wedel', 'Mocno Mleczna', 556.0, 33.3, 18.5, 0.0, 55.6, 55.6, 0.0, 7.4, 0.2),
    ('E.Wedel', 'Czekolada Tiramisu', 524.0, 29.0, 15.0, 0, 58.0, 57.0, 1.3, 5.5, 0.2),
    ('E. Wedel', 'Mleczna malinowa', 483.0, 26.0, 13.0, 0, 59.0, 57.0, 1.5, 3.5, 0.1),
    ('Biedronka', 'Czekolada gorzka 95% kakao', 591.0, 52.0, 32.0, 0, 10.0, 3.0, 18.0, 12.0, 0.1),
    ('Unknown', 'Czekolada Biała z chrupkami kakaowymi', 520.8, 27.1, 17.1, 0, 62.5, 58.3, 0, 5.4, 0.0),
    ('Magnetic', 'Czekolada Gorzka', 519.0, 34.0, 23.0, 0, 38.0, 34.0, 13.0, 8.2, 0.1),
    ('Deliss', 'Czekolada mleczna z całymi orzechami laskowymi', 584.0, 42.0, 17.0, 0, 40.0, 39.0, 0, 9.5, 0.2),
    ('Wedel', 'Czekolada gorzka 70%', 534.0, 38.0, 24.0, 0, 32.0, 28.0, 0, 10.0, 0.0),
    ('Magnetic', 'Czekolada mleczna truskawkowa', 517.0, 29.0, 17.0, 0, 59.0, 57.0, 1.0, 5.2, 0.2),
    ('Wawel', 'Czekolada deserowa 43% cocoa', 538.0, 32.0, 19.0, 0, 54.0, 52.0, 0, 5.4, 0.0),
    ('Wawel', 'Tiramisu czekolada nadziewana', 521.0, 30.0, 19.0, 0, 55.0, 50.0, 0, 6.3, 0.2),
    ('Wawel', 'Truskawkowa czekolada nadziewana', 500.0, 27.0, 17.0, 0, 58.0, 46.0, 0, 5.0, 0.1),
    ('Wawel', 'Gorzka Extra', 556.0, 44.4, 28.9, 0.0, 33.3, 8.9, 17.8, 15.6, 0.0),
    ('Wawel', 'Gorzka 70%', 576.0, 43.0, 27.0, 0, 32.0, 28.0, 0, 9.8, 0.0),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 647.0, 60.0, 38.0, 0, 6.3, 1.2, 0, 13.0, 0.0),
    ('Wawel', 'Czekolada Gorzka 64%', 568.0, 41.0, 26.0, 0, 36.0, 32.0, 0, 8.7, 0.0),
    ('Baron', 'whole nutty', 543.0, 34.0, 16.0, 0, 49.0, 48.0, 0, 7.6, 0.2),
    ('E. Wedel', 'Czekolada Gorzka O Smaku Espresso', 530.0, 33.0, 16.0, 0, 49.0, 47.0, 6.6, 5.9, 0.2),
    ('Wawel', 'Wawel - Kasztanki - Czekolada Nadziewana', 537.0, 31.0, 21.0, 0, 57.0, 50.0, 0, 5.3, 0.1),
    ('Wawel', 'Czekolada gorzka 70%', 576.0, 43.0, 27.0, 0, 32.0, 28.0, 0, 9.8, 0.0),
    ('Wawel', 'Mleczna', 557.0, 35.0, 21.0, 0, 53.0, 52.0, 0, 6.4, 0.2),
    ('Magnetic', 'Czekolada mleczna', 552.0, 34.0, 21.0, 0, 53.0, 53.0, 1.7, 6.6, 0.3),
    ('E. Wedel', 'chocolat noir 50%', 501.0, 28.0, 17.0, 0, 51.0, 48.0, 9.8, 6.2, 0.0),
    ('Allegro', 'Czekolada mleczna', 534.0, 31.0, 20.0, 0, 56.0, 56.0, 2.6, 5.9, 0),
    ('Terravita', 'Czekolada deserowa', 516.0, 29.0, 17.0, 0, 54.0, 50.0, 8.5, 6.1, 0.0),
    ('E. Wedel', 'Jedyna Czekolada Wyborowa', 501.0, 28.0, 18.0, 0, 52.0, 48.0, 8.9, 6.0, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Sweets' and p.is_deprecated is not true
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
