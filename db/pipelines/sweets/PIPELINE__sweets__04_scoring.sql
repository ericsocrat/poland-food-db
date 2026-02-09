-- PIPELINE (Sweets): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 1),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 0),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 1),
    ('E. Wedel', 'Mleczna klasyczna', 0),
    ('Wawel', 'Gorzka Extra', 1),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 0),
    ('Wawel', 'Gorzka 70%', 1),
    ('Unknown', 'Czekolada gorzka Luximo', 1),
    ('Luximo', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', 0),
    ('fin CARRÉ', 'Extra dark 74% Cocoa', 1),
    ('Lindt Excellence', 'Excellence 85% Cacao Rich Dark', 0),
    ('Milka', 'Chocolat au lait', 1),
    ('Toblerone', 'Milk Chocolate with Honey and Almond Nougat', 1),
    ('Storck', 'Merci Finest Selection Assorted Chocolates', 1),
    ('Fin Carré', 'Milk Chocolate', 1),
    ('fin Carré', 'Dunkle Schokolade mit ganzen Haselnüssen', 1),
    ('Lindt', 'Lindt Excellence Dark Orange Intense', 2),
    ('Fin Carré', 'Weiße Schokolade', 1),
    ('Milka', 'Milka chocolate Hazelnuts', 1),
    ('Fin Carré', 'Extra Dark 85% Cocoa', 1),
    ('Ritter SPORT', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', 2),
    ('Milka', 'Happy Cow', 1),
    ('Heidi', 'Dark Intense', 1),
    ('Schogetten', 'Schogetten alpine milk chocolate', 0),
    ('Milka', 'Milka Mmmax Oreo', 4),
    ('Milka', 'Schokolade Joghurt', 1),
    ('Milka', 'Strawberry', 2),
    ('Hatherwood', 'Salted Caramel Style', 4)
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;
