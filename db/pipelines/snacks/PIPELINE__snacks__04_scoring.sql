-- PIPELINE (Snacks): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('PANO', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 0),
    ('Go Active', 'Baton wysokobiałkowy Peanut Butter', 1),
    ('Go active', 'Baton białkowy malinowy', 6),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 0),
    ('Kupiec', 'Wafle ryżowe naturalne', 0),
    ('Bakalland', 'Ba! żurawina', 4),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 4),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 4),
    ('Pano', 'Wafle mini, zbożowe', 0),
    ('Dobra kaloria', 'Mini batoniki z nerkowców à la tarta malinowa', 0),
    ('Lubella', 'Paluszki z solą', 3),
    ('Dobra Kaloria', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', 0),
    ('Brześć', 'Słomka ptysiowa', 0),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 3),
    ('Lajkonik', 'Paluszki extra cienkie', 2),
    ('Wafle Dzik', 'Kukurydziane - ser', 0),
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', 3),
    ('Miami', 'Paleczki', 0),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 0),
    ('Go On Nutrition', 'Protein 33% Caramel', 4),
    ('Lajkonik', 'Salted cracker', 3),
    ('Lorenz', 'Chrupki Curly', 1),
    ('Lajkonik', 'prezel', 2),
    ('Lajkonik', 'Krakersy mini', 3),
    ('San', 'San bieszczadzkie suchary', 1),
    ('Sante', 'Vitamin coconut bar', 3),
    ('Lajkonik', 'Junior Safari', 0),
    ('Dobra Kaloria', 'Kokos & Orzech', 0),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 1),
    ('TOP', 'Paluszki solone', 0),
    ('Baron', 'Protein BarMax Caramel', 4),
    ('Go On', 'Keto Bar', 1),
    ('Top', 'popcorn solony', 0),
    ('Oshee', 'Raspberry & Almond High Protein Bar PROMO', 4),
    ('lajkonik', 'dobry chrup', 7),
    ('Lajkonik', 'Precelki chrupkie', 2),
    ('Be raw', 'Energy Raspberry', 0),
    ('Go active', 'Baton Proteinowy Smak Waniliowy 50%', 6),
    ('As Babuni', 'Chrup Asy Wafle Paprykowe', 5),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 4),
    ('Góralki', 'Góralki mleczne', 4),
    ('Bob Snail', 'Jabłkowo-truskawkowe przekąski', 0),
    ('tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 1),
    ('Unknown', 'Protein vanillia raspberry', 5),
    ('Go Active', 'Baton wysokobiałkowy z migdałami i kokosem', 3),
    ('7 DAYS', 'Croissant with Cocoa Filling', 6),
    ('Vitanella', 'Barony', 1),
    ('Unknown', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', 0),
    ('Tutti', 'Batonik twarogowy Tutti w polewie czekoladowej', 1),
    ('7days', '7days', 5),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 2),
    ('Tastino', 'Wafle Kukurydziane', 1),
    ('Pilos', 'Barretta al quark gusto Nocciola', 3),
    ('Aviko', 'Frytki karbowane Zig Zag', 0),
    ('7 Days', 'family', 0),
    ('Milka', 'Cake & Chock', 5),
    ('Wasa', 'Lekkie 7 Ziaren', 0)
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
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('PANO', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 'B'),
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
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', 'E'),
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
    ('Wasa', 'Lekkie 7 Ziaren', 'B')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('PANO', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', '3'),
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
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', '4'),
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
    ('Wasa', 'Lekkie 7 Ziaren', '3')
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;
