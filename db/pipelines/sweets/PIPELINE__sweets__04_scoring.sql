-- PIPELINE (Sweets): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sweets'
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
  )
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'E'),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 'D'),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 'E'),
    ('E. Wedel', 'Mleczna klasyczna', 'E'),
    ('Wawel', 'Gorzka Extra', 'D'),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 'D'),
    ('Wawel', 'Gorzka 70%', 'D'),
    ('Unknown', 'Czekolada gorzka Luximo', 'D'),
    ('Luximo', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', 'E'),
    ('fin CARRÉ', 'Extra dark 74% Cocoa', 'E'),
    ('Lindt Excellence', 'Excellence 85% Cacao Rich Dark', 'E'),
    ('Milka', 'Chocolat au lait', 'E'),
    ('Toblerone', 'Milk Chocolate with Honey and Almond Nougat', 'E'),
    ('Storck', 'Merci Finest Selection Assorted Chocolates', 'E'),
    ('Fin Carré', 'Milk Chocolate', 'E'),
    ('fin Carré', 'Dunkle Schokolade mit ganzen Haselnüssen', 'E'),
    ('Lindt', 'Lindt Excellence Dark Orange Intense', 'E'),
    ('Fin Carré', 'Weiße Schokolade', 'E'),
    ('Milka', 'Milka chocolate Hazelnuts', 'E'),
    ('Fin Carré', 'Extra Dark 85% Cocoa', 'E'),
    ('Ritter SPORT', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', 'E'),
    ('Milka', 'Happy Cow', 'E'),
    ('Heidi', 'Dark Intense', 'E'),
    ('Schogetten', 'Schogetten alpine milk chocolate', 'E'),
    ('Milka', 'Milka Mmmax Oreo', 'E'),
    ('Milka', 'Schokolade Joghurt', 'E'),
    ('Milka', 'Strawberry', 'E'),
    ('Hatherwood', 'Salted Caramel Style', 'C')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 4),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 4),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 4),
    ('E. Wedel', 'Mleczna klasyczna', 4),
    ('Wawel', 'Gorzka Extra', 4),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 3),
    ('Wawel', 'Gorzka 70%', 4),
    ('Unknown', 'Czekolada gorzka Luximo', 4),
    ('Luximo', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', 4),
    ('fin CARRÉ', 'Extra dark 74% Cocoa', 4),
    ('Lindt Excellence', 'Excellence 85% Cacao Rich Dark', 3),
    ('Milka', 'Chocolat au lait', 4),
    ('Toblerone', 'Milk Chocolate with Honey and Almond Nougat', 4),
    ('Storck', 'Merci Finest Selection Assorted Chocolates', 4),
    ('Fin Carré', 'Milk Chocolate', 4),
    ('fin Carré', 'Dunkle Schokolade mit ganzen Haselnüssen', 4),
    ('Lindt', 'Lindt Excellence Dark Orange Intense', 4),
    ('Fin Carré', 'Weiße Schokolade', 4),
    ('Milka', 'Milka chocolate Hazelnuts', 4),
    ('Fin Carré', 'Extra Dark 85% Cocoa', 4),
    ('Ritter SPORT', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', 4),
    ('Milka', 'Happy Cow', 4),
    ('Heidi', 'Dark Intense', 4),
    ('Schogetten', 'Schogetten alpine milk chocolate', 4),
    ('Milka', 'Milka Mmmax Oreo', 4),
    ('Milka', 'Schokolade Joghurt', 4),
    ('Milka', 'Strawberry', 4),
    ('Hatherwood', 'Salted Caramel Style', 4)
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;
