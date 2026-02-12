-- PIPELINE (Nuts, Seeds & Legumes): scoring
-- Generated: 2026-02-11

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 'C'),
    ('BakaDOr', 'Pistacje niesolone prażone', 'A'),
    ('Top', 'Orzechy ziemne prażone nieslone', 'A'),
    ('Bakallino', 'Migdały', 'C'),
    ('makar bakalie', 'Migdały', 'B'),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', 'C'),
    ('BakaDOr', 'BakaDOr. Orzechy włoskie', 'B'),
    ('SPAR', 'Orzeszki ziemne prażone', 'A'),
    ('Baka D''or', 'Orzechy włoskie', 'B'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 'A'),
    ('bakador', 'migdały', 'A'),
    ('Felix', 'Orzeszki ziemne smażone i solone', 'C'),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 'D'),
    ('Bakador', 'Orzechy włoskie', 'A'),
    ('felix', 'Orzeszki długo prażone extra chrupkie', 'C'),
    ('Bakalland', 'Orzechy makadamia łuskane', 'D'),
    ('Bakallino', 'Migdały łuskane', 'A'),
    ('Unknown', 'Orzechy nerkowca połówki', 'B'),
    ('Kresto', 'Mix orzechów', 'C'),
    ('Felix', 'Carmelove z wiórkami kokosowymi', 'C'),
    ('Felix', 'Orzeszki ziemne prażone', 'A'),
    ('Aga Holtex', 'Migdały', 'A'),
    ('BakaD’Or', 'Migdały łuskane kalifornijskie', 'UNKNOWN'),
    ('Felix', 'Orzeszki z pieca z solą', 'C'),
    ('ecobi', 'Orzechy włoskie łuskane', 'A'),
    ('Green Essence', 'Migdały naturalne całe', 'A'),
    ('brat.pl', 'Orzechy brazylijskie połówki', 'C'),
    ('Carrefour Extra', 'Migdały łuskane', 'A'),
    ('Felix', 'Felix orzeszki ziemne', 'C'),
    ('BakaD''Or', 'Mieszanka egzotyczna', 'D'),
    ('felix', 'Orzeszki ziemne lekko solone', 'B'),
    ('BakaD''Or', 'Orzechy Nerkowca', 'B'),
    ('BakaDOr', 'Orzechy pekan', 'A'),
    ('Top', 'Orzeszki Top smak papryka', 'D'),
    ('Bakador', 'Mieszanka orzechowa', 'A'),
    ('Top Biedronka', 'Orzeszki ziemne prażone', 'A'),
    ('BakaDOr', 'Orzechy brazylijskie', 'B'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', 'D'),
    ('Bakador', 'Orzechy nerkowca', 'B'),
    ('Unknown', 'Migdały łuskane', 'A'),
    ('Helio S.A.', 'Mieszanka Studencka', 'D'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', 'D'),
    ('Makar', 'Orzechy Brazylijskie', 'C'),
    ('Spar', 'Mieszanka Studencka', 'C'),
    ('Felix', 'Orzeszki ziemne solone', 'C'),
    ('Bakador', 'Orzechy pekan', 'UNKNOWN'),
    ('Bakador', 'Mieszanka Orzechowa', 'C'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 'B'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 'B'),
    ('BakaDOr', 'Orzechy nerkowca', 'B')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', '1'),
    ('BakaDOr', 'Pistacje niesolone prażone', '1'),
    ('Top', 'Orzechy ziemne prażone nieslone', '1'),
    ('Bakallino', 'Migdały', '1'),
    ('makar bakalie', 'Migdały', '1'),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', '4'),
    ('BakaDOr', 'BakaDOr. Orzechy włoskie', '1'),
    ('SPAR', 'Orzeszki ziemne prażone', '1'),
    ('Baka D''or', 'Orzechy włoskie', '1'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', '1'),
    ('bakador', 'migdały', '4'),
    ('Felix', 'Orzeszki ziemne smażone i solone', '3'),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', '4'),
    ('Bakador', 'Orzechy włoskie', '1'),
    ('felix', 'Orzeszki długo prażone extra chrupkie', '4'),
    ('Bakalland', 'Orzechy makadamia łuskane', '1'),
    ('Bakallino', 'Migdały łuskane', '1'),
    ('Unknown', 'Orzechy nerkowca połówki', '1'),
    ('Kresto', 'Mix orzechów', '1'),
    ('Felix', 'Carmelove z wiórkami kokosowymi', '4'),
    ('Felix', 'Orzeszki ziemne prażone', '1'),
    ('Aga Holtex', 'Migdały', '1'),
    ('BakaD’Or', 'Migdały łuskane kalifornijskie', '1'),
    ('Felix', 'Orzeszki z pieca z solą', '4'),
    ('ecobi', 'Orzechy włoskie łuskane', '1'),
    ('Green Essence', 'Migdały naturalne całe', '1'),
    ('brat.pl', 'Orzechy brazylijskie połówki', '1'),
    ('Carrefour Extra', 'Migdały łuskane', '1'),
    ('Felix', 'Felix orzeszki ziemne', '3'),
    ('BakaD''Or', 'Mieszanka egzotyczna', '3'),
    ('felix', 'Orzeszki ziemne lekko solone', '3'),
    ('BakaD''Or', 'Orzechy Nerkowca', '1'),
    ('BakaDOr', 'Orzechy pekan', '1'),
    ('Top', 'Orzeszki Top smak papryka', '4'),
    ('Bakador', 'Mieszanka orzechowa', '4'),
    ('Top Biedronka', 'Orzeszki ziemne prażone', '4'),
    ('BakaDOr', 'Orzechy brazylijskie', '1'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', '4'),
    ('Bakador', 'Orzechy nerkowca', '1'),
    ('Unknown', 'Migdały łuskane', '4'),
    ('Helio S.A.', 'Mieszanka Studencka', '3'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', '4'),
    ('Makar', 'Orzechy Brazylijskie', '1'),
    ('Spar', 'Mieszanka Studencka', '4'),
    ('Felix', 'Orzeszki ziemne solone', '4'),
    ('Bakador', 'Orzechy pekan', '4'),
    ('Bakador', 'Mieszanka Orzechowa', '1'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', '1'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', '4'),
    ('BakaDOr', 'Orzechy nerkowca', '1')
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;
