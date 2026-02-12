-- PIPELINE (Sweets): scoring
-- Generated: 2026-02-11

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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('E.Wedel', 'Czekolada gorzka Wiśniowa', 'E'),
    ('Choctopus', 'Czekolada bąbelkowa mleczna', 'E'),
    ('Wawel', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', 'E'),
    ('Biedronka', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', 'E'),
    ('Milano', 'Czekolada mleczna z całymi orzechami laskowymi', 'E'),
    ('Biedronka', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami', 'E'),
    ('Magnetic', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', 'E'),
    ('Magnetic', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', 'E'),
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'E'),
    ('Wedel', 'Czekolada biała', 'E'),
    ('Mella', 'Galaretka w czekoladzie o smaku wiśniowym', 'UNKNOWN'),
    ('Wawel', 'Vege now z pastą z orzecha laskowego', 'E'),
    ('Mokate', 'Czekolada biała napój o smaku białej czekolady', 'E'),
    ('E. Wedel', 'Czekolada biała', 'E'),
    ('Royal Nut', 'Czekolada mleczna z całymi orzechami laskowymi', 'E'),
    ('Wawel', 'Piernikowa ze śliwką', 'E'),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 'D'),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 'E'),
    ('E. Wedel', 'Mleczna klasyczna', 'E'),
    ('Goplana', 'Gorzka 1912', 'E'),
    ('E. Wedel', 'Mleczna Truskawkowa', 'E'),
    ('E. Wedel', 'Wedel extra dark chocolate', 'D'),
    ('E. Wedel', 'Gorzka Kokosowa', 'E'),
    ('Mellie', 'Dark Chocolate Orange', 'UNKNOWN'),
    ('E. Wedel', 'Mocno Mleczna', 'E'),
    ('E.Wedel', 'Czekolada Tiramisu', 'E'),
    ('E. Wedel', 'Mleczna malinowa', 'E'),
    ('Biedronka', 'Czekolada gorzka 95% kakao', 'D'),
    ('Unknown', 'Czekolada Biała z chrupkami kakaowymi', 'E'),
    ('Magnetic', 'Czekolada Gorzka', 'E'),
    ('Deliss', 'Czekolada mleczna z całymi orzechami laskowymi', 'E'),
    ('Wedel', 'Czekolada gorzka 70%', 'E'),
    ('Magnetic', 'Czekolada mleczna truskawkowa', 'E'),
    ('Wawel', 'Czekolada deserowa 43% cocoa', 'E'),
    ('Wawel', 'Tiramisu czekolada nadziewana', 'E'),
    ('Wawel', 'Truskawkowa czekolada nadziewana', 'E'),
    ('Wawel', 'Gorzka Extra', 'D'),
    ('Wawel', 'Gorzka 70%', 'D'),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 'D'),
    ('Wawel', 'Czekolada Gorzka 64%', 'E'),
    ('E. Wedel', 'Czekolada Gorzka O Smaku Espresso', 'E'),
    ('Wawel', 'Wawel - Kasztanki - Czekolada Nadziewana', 'E'),
    ('Wawel', 'Czekolada gorzka 70%', 'E'),
    ('Wawel', 'Mleczna', 'E'),
    ('Magnetic', 'Czekolada mleczna', 'E'),
    ('Allegro', 'Czekolada mleczna', 'UNKNOWN'),
    ('Terravita', 'Czekolada deserowa', 'E'),
    ('E. Wedel', 'Jedyna Czekolada Wyborowa', 'E')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('E.Wedel', 'Czekolada gorzka Wiśniowa', '4'),
    ('Choctopus', 'Czekolada bąbelkowa mleczna', '4'),
    ('Wawel', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', '4'),
    ('Biedronka', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', '4'),
    ('Milano', 'Czekolada mleczna z całymi orzechami laskowymi', '4'),
    ('Biedronka', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami', '4'),
    ('Magnetic', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', '4'),
    ('Magnetic', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', '4'),
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', '4'),
    ('Wedel', 'Czekolada biała', '4'),
    ('Mella', 'Galaretka w czekoladzie o smaku wiśniowym', '4'),
    ('Wawel', 'Vege now z pastą z orzecha laskowego', '4'),
    ('Mokate', 'Czekolada biała napój o smaku białej czekolady', '4'),
    ('E. Wedel', 'Czekolada biała', '4'),
    ('Royal Nut', 'Czekolada mleczna z całymi orzechami laskowymi', '4'),
    ('Wawel', 'Piernikowa ze śliwką', '4'),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', '4'),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', '4'),
    ('E. Wedel', 'Mleczna klasyczna', '4'),
    ('Goplana', 'Gorzka 1912', '4'),
    ('E. Wedel', 'Mleczna Truskawkowa', '4'),
    ('E. Wedel', 'Wedel extra dark chocolate', '4'),
    ('E. Wedel', 'Gorzka Kokosowa', '4'),
    ('Mellie', 'Dark Chocolate Orange', '4'),
    ('E. Wedel', 'Mocno Mleczna', '4'),
    ('E.Wedel', 'Czekolada Tiramisu', '4'),
    ('E. Wedel', 'Mleczna malinowa', '4'),
    ('Biedronka', 'Czekolada gorzka 95% kakao', '3'),
    ('Unknown', 'Czekolada Biała z chrupkami kakaowymi', '4'),
    ('Magnetic', 'Czekolada Gorzka', '4'),
    ('Deliss', 'Czekolada mleczna z całymi orzechami laskowymi', '4'),
    ('Wedel', 'Czekolada gorzka 70%', '4'),
    ('Magnetic', 'Czekolada mleczna truskawkowa', '4'),
    ('Wawel', 'Czekolada deserowa 43% cocoa', '4'),
    ('Wawel', 'Tiramisu czekolada nadziewana', '4'),
    ('Wawel', 'Truskawkowa czekolada nadziewana', '4'),
    ('Wawel', 'Gorzka Extra', '4'),
    ('Wawel', 'Gorzka 70%', '4'),
    ('Wawel', '100% Cocoa Ekstra Gorzka', '3'),
    ('Wawel', 'Czekolada Gorzka 64%', '4'),
    ('E. Wedel', 'Czekolada Gorzka O Smaku Espresso', '4'),
    ('Wawel', 'Wawel - Kasztanki - Czekolada Nadziewana', '4'),
    ('Wawel', 'Czekolada gorzka 70%', '4'),
    ('Wawel', 'Mleczna', '4'),
    ('Magnetic', 'Czekolada mleczna', '4'),
    ('Allegro', 'Czekolada mleczna', '4'),
    ('Terravita', 'Czekolada deserowa', '4'),
    ('E. Wedel', 'Jedyna Czekolada Wyborowa', '4')
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;
