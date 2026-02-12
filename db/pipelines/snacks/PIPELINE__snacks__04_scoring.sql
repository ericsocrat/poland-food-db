-- PIPELINE (Snacks): scoring
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Pano', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 'B'),
    ('Go Active', 'Baton wysokobiałkowy Peanut Butter', 'C'),
    ('Go active', 'Baton białkowy malinowy', 'C'),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 'E'),
    ('Kupiec', 'Wafle ryżowe naturalne', 'B'),
    ('Bakalland', 'Ba! żurawina', 'D'),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 'A'),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 'D'),
    ('Pano', 'Wafle mini, zbożowe', 'B'),
    ('Dobra kaloria', 'Mini batoniki z nerkowców à la tarta malinowa', 'D'),
    ('Lubella', 'Paluszki z solą', 'E'),
    ('Dobra Kaloria', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', 'C'),
    ('Brześć', 'Słomka ptysiowa', 'D'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'NOT-APPLICABLE'),
    ('Lajkonik', 'Paluszki extra cienkie', 'E'),
    ('Wafle Dzik', 'Kukurydziane - ser', 'D'),
    ('Sante A. Kowalski sp. j', 'Crunchy Cranberry & Raspberry - Santé', 'E'),
    ('Miami', 'Paleczki', 'B'),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 'E'),
    ('Go On Nutrition', 'Protein 33% Caramel', 'NOT-APPLICABLE'),
    ('Lajkonik', 'Salted cracker', 'D'),
    ('Lorenz', 'Chrupki Curly', 'D'),
    ('Lajkonik', 'prezel', 'B'),
    ('Lajkonik', 'Krakersy mini', 'D'),
    ('San', 'San bieszczadzkie suchary', 'C'),
    ('Sante', 'Vitamin coconut bar', 'NOT-APPLICABLE'),
    ('Lajkonik', 'Junior Safari', 'D'),
    ('Dobra Kaloria', 'Kokos & Orzech', 'D'),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 'B'),
    ('TOP', 'Paluszki solone', 'D'),
    ('Baron', 'Protein BarMax Caramel', 'NOT-APPLICABLE'),
    ('Go On', 'Keto Bar', 'NOT-APPLICABLE'),
    ('Top', 'popcorn solony', 'E'),
    ('Oshee', 'Raspberry & Almond High Protein Bar PROMO', 'NOT-APPLICABLE'),
    ('lajkonik', 'dobry chrup', 'D'),
    ('Lajkonik', 'Precelki chrupkie', 'E'),
    ('Be raw', 'Energy Raspberry', 'NOT-APPLICABLE'),
    ('Go active', 'Baton Proteinowy Smak Waniliowy 50%', 'NOT-APPLICABLE'),
    ('As Babuni', 'Chrup Asy Wafle Paprykowe', 'E'),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 'NOT-APPLICABLE'),
    ('Góralki', 'Góralki mleczne', 'E'),
    ('Bob Snail', 'Jabłkowo-truskawkowe przekąski', 'C'),
    ('tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'C'),
    ('Unknown', 'Protein vanillia raspberry', 'NOT-APPLICABLE'),
    ('Go Active', 'Baton wysokobiałkowy z migdałami i kokosem', 'NOT-APPLICABLE'),
    ('7 DAYS', 'Croissant with Cocoa Filling', 'E'),
    ('Vitanella', 'Barony', 'D'),
    ('Unknown', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', 'D'),
    ('Tutti', 'Batonik twarogowy Tutti w polewie czekoladowej', 'E'),
    ('7days', '7days', 'E'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'D'),
    ('Tastino', 'Wafle Kukurydziane', 'C'),
    ('Pilos', 'Barretta al quark gusto Nocciola', 'E'),
    ('Aviko', 'Frytki karbowane Zig Zag', 'A'),
    ('7 Days', 'family', 'UNKNOWN'),
    ('Milka', 'Cake & Chock', 'E'),
    ('Wasa', 'Lekkie 7 Ziaren', 'B'),
    -- batch 2
    ('Sante A. Kowalski sp. j', 'Crunchy Cranberry & Raspberry - Santé', 'D')  -- high sugar cereal bar
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Pano', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', '3'),
    ('Go Active', 'Baton wysokobiałkowy Peanut Butter', '4'),
    ('Go active', 'Baton białkowy malinowy', '4'),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', '4'),
    ('Kupiec', 'Wafle ryżowe naturalne', '1'),
    ('Bakalland', 'Ba! żurawina', '4'),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', '4'),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', '4'),
    ('Pano', 'Wafle mini, zbożowe', '3'),
    ('Dobra kaloria', 'Mini batoniki z nerkowców à la tarta malinowa', '4'),
    ('Lubella', 'Paluszki z solą', '3'),
    ('Dobra Kaloria', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', '4'),
    ('Brześć', 'Słomka ptysiowa', '3'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', '4'),
    ('Lajkonik', 'Paluszki extra cienkie', '3'),
    ('Wafle Dzik', 'Kukurydziane - ser', '4'),
    ('Sante A. Kowalski sp. j', 'Crunchy Cranberry & Raspberry - Santé', '4'),
    ('Miami', 'Paleczki', '1'),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', '4'),
    ('Go On Nutrition', 'Protein 33% Caramel', '4'),
    ('Lajkonik', 'Salted cracker', '4'),
    ('Lorenz', 'Chrupki Curly', '4'),
    ('Lajkonik', 'prezel', '3'),
    ('Lajkonik', 'Krakersy mini', '4'),
    ('San', 'San bieszczadzkie suchary', '4'),
    ('Sante', 'Vitamin coconut bar', '4'),
    ('Lajkonik', 'Junior Safari', '4'),
    ('Dobra Kaloria', 'Kokos & Orzech', '3'),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', '4'),
    ('TOP', 'Paluszki solone', '4'),
    ('Baron', 'Protein BarMax Caramel', '4'),
    ('Go On', 'Keto Bar', '4'),
    ('Top', 'popcorn solony', '4'),
    ('Oshee', 'Raspberry & Almond High Protein Bar PROMO', '4'),
    ('lajkonik', 'dobry chrup', '4'),
    ('Lajkonik', 'Precelki chrupkie', '3'),
    ('Be raw', 'Energy Raspberry', '4'),
    ('Go active', 'Baton Proteinowy Smak Waniliowy 50%', '4'),
    ('As Babuni', 'Chrup Asy Wafle Paprykowe', '4'),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', '4'),
    ('Góralki', 'Góralki mleczne', '4'),
    ('Bob Snail', 'Jabłkowo-truskawkowe przekąski', '3'),
    ('tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', '4'),
    ('Unknown', 'Protein vanillia raspberry', '4'),
    ('Go Active', 'Baton wysokobiałkowy z migdałami i kokosem', '4'),
    ('7 DAYS', 'Croissant with Cocoa Filling', '4'),
    ('Vitanella', 'Barony', '4'),
    ('Unknown', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', '4'),
    ('Tutti', 'Batonik twarogowy Tutti w polewie czekoladowej', '4'),
    ('7days', '7days', '4'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', '4'),
    ('Tastino', 'Wafle Kukurydziane', '4'),
    ('Pilos', 'Barretta al quark gusto Nocciola', '4'),
    ('Aviko', 'Frytki karbowane Zig Zag', '4'),
    ('7 Days', 'family', '4'),
    ('Milka', 'Cake & Chock', '4'),
    ('Wasa', 'Lekkie 7 Ziaren', '3'),
    -- batch 2
    ('Sante A. Kowalski sp. j', 'Crunchy Cranberry & Raspberry - Santé', '4')  -- coated cereal bar
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;
