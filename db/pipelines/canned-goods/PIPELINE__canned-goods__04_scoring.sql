-- PIPELINE (Canned Goods): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Canned Goods'
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
  and p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Nasza Spiżarnia', 'Kukurydza słodka', 'B'),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 'A'),
    ('Dawtona', 'Kukurydza słodka', 'B'),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'A'),
    ('Dega', 'Fish spread with rice', 'C'),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 'B'),
    ('Freshona', 'Buraczki wiórki', 'B'),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 'C'),
    ('Lidl', 'Buraczki zasmażane z cebulką', 'B'),
    ('Kaufland', 'Sardynki w oleju słonecznikowym', 'B'),
    ('Baresa', 'Azeitonas Lidl', 'D'),
    ('Freshona', 'Sonnenmais natursüß', 'B'),
    ('Freshona', 'Ananas en tranches au sirop léger', 'A'),
    ('Freshona', 'coconut milk', 'D'),
    ('Bonduelle', 'Lunch bowl Légumes & boulgour 250g', 'A'),
    ('Baresa', 'Peeled Tomatoes in tomato juice', 'A'),
    ('NIXE', 'Sardines à l''huile de tournesol', 'B'),
    ('El Tequito', 'Jalapeños', 'NOT-APPLICABLE'),
    ('Carrefour', 'Morceaux de thon', 'A'),
    ('Alpen Fest style', 'Rodekool Chou rouge', 'A'),
    ('Cirio', 'Pelati Geschälte Tomaten', 'A'),
    ('Baresa', 'Pulpe de tomates, basilic & origan', 'A'),
    ('Carrefour', 'Morceaux de thon au naturel', 'A'),
    ('SOL & MAR', 'Czosnek z chilli w oleju', 'C'),
    ('Freshona', 'Gurkensticks', 'C'),
    ('Carrefour', 'Morceaux de Thon', 'A'),
    ('Carrefour', 'Olives à la farce aux anchois', 'D'),
    ('Carrefour', 'Miettes de thon', 'A')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Nasza Spiżarnia', 'Kukurydza słodka', 3),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 4),
    ('Dawtona', 'Kukurydza słodka', 3),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym.', 1),
    ('Dega', 'Fish spread with rice', 4),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 3),
    ('Freshona', 'Buraczki wiórki', 3),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 4),
    ('Lidl', 'Buraczki zasmażane z cebulką', 4),
    ('Kaufland', 'Sardynki w oleju słonecznikowym', 3),
    ('Baresa', 'Azeitonas Lidl', 3),
    ('Freshona', 'Sonnenmais natursüß', 3),
    ('Freshona', 'Ananas en tranches au sirop léger', 1),
    ('Freshona', 'coconut milk', 4),
    ('Bonduelle', 'Lunch bowl Légumes & boulgour 250g', 3),
    ('Baresa', 'Peeled Tomatoes in tomato juice', 1),
    ('NIXE', 'Sardines à l''huile de tournesol', 3),
    ('El Tequito', 'Jalapeños', 3),
    ('Carrefour', 'Morceaux de thon', 3),
    ('Alpen Fest style', 'Rodekool Chou rouge', 3),
    ('Cirio', 'Pelati Geschälte Tomaten', 1),
    ('Baresa', 'Pulpe de tomates, basilic & origan', 3),
    ('Carrefour', 'Morceaux de thon au naturel', 3),
    ('SOL & MAR', 'Czosnek z chilli w oleju', 4),
    ('Freshona', 'Gurkensticks', 4),
    ('Carrefour', 'Morceaux de Thon', 3),
    ('Carrefour', 'Olives à la farce aux anchois', 4),
    ('Carrefour', 'Miettes de thon', 3)
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
  and p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true;
