-- PIPELINE (Nuts, Seeds & Legumes): scoring
-- Generated: 2026-02-11

-- 0. DEFAULT concern score for products without ingredient data
update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true
  and ingredient_concern_score is null;

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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 'C'),
    ('Bakador', 'Pistacje niesolone prażone', 'A'),
    ('Top', 'Orzechy ziemne prażone nieslone', 'A'),
    ('Bakallino', 'Migdały', 'C'),
    ('Makar Bakalie', 'Migdały', 'B'),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', 'C'),
    ('Bakador', 'BakaDOr. Orzechy włoskie', 'B'),
    ('Spar', 'Orzeszki ziemne prażone', 'A'),
    ('Baka D''or', 'Orzechy włoskie', 'B'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 'A'),
    ('Felix', 'Orzeszki ziemne smażone i solone', 'C'),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 'D'),
    ('Bakador', 'Orzechy włoskie', 'A'),
    ('Felix', 'Orzeszki długo prażone extra chrupkie', 'C'),
    ('Bakalland', 'Orzechy makadamia łuskane', 'D'),
    ('Bakallino', 'Migdały łuskane', 'A'),
    ('Unknown', 'Orzechy nerkowca połówki', 'B'),
    ('Kresto', 'Mix orzechów', 'C'),
    ('Felix', 'Carmelove z wiórkami kokosowymi', 'C'),
    ('Felix', 'Orzeszki ziemne prażone', 'A'),
    ('Aga Holtex', 'Migdały', 'A'),
    ('BakaD’Or', 'Migdały łuskane kalifornijskie', 'UNKNOWN'),
    ('Felix', 'Orzeszki z pieca z solą', 'C'),
    ('Ecobi', 'Orzechy włoskie łuskane', 'A'),
    ('Green Essence', 'Migdały naturalne całe', 'A'),
    ('brat.pl', 'Orzechy brazylijskie połówki', 'C'),
    ('Carrefour Extra', 'Migdały łuskane', 'A'),
    ('Felix', 'Felix orzeszki ziemne', 'C'),
    ('BakaD''Or', 'Mieszanka egzotyczna', 'D'),
    ('Felix', 'Orzeszki ziemne lekko solone', 'B'),
    ('BakaD''Or', 'Orzechy Nerkowca', 'B'),
    ('Bakador', 'Orzechy pekan', 'A'),
    ('Top', 'Orzeszki Top smak papryka', 'D'),
    ('Bakador', 'Mieszanka orzechowa', 'A'),
    ('Top Biedronka', 'Orzeszki ziemne prażone', 'A'),
    ('Bakador', 'Orzechy brazylijskie', 'B'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', 'D'),
    ('Bakador', 'Orzechy nerkowca', 'B'),
    ('Unknown', 'Migdały łuskane', 'A'),
    ('Helio S.A.', 'Mieszanka Studencka', 'D'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', 'D'),
    ('Makar', 'Orzechy Brazylijskie', 'C'),
    ('Spar', 'Mieszanka Studencka', 'C'),
    ('Felix', 'Orzeszki ziemne solone', 'C'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 'B'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 'B')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', '1'),
    ('Bakador', 'Pistacje niesolone prażone', '1'),
    ('Top', 'Orzechy ziemne prażone nieslone', '1'),
    ('Bakallino', 'Migdały', '1'),
    ('Makar Bakalie', 'Migdały', '1'),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', '4'),
    ('Bakador', 'BakaDOr. Orzechy włoskie', '1'),
    ('Spar', 'Orzeszki ziemne prażone', '1'),
    ('Baka D''or', 'Orzechy włoskie', '1'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', '1'),
    ('Felix', 'Orzeszki ziemne smażone i solone', '3'),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', '4'),
    ('Bakador', 'Orzechy włoskie', '1'),
    ('Felix', 'Orzeszki długo prażone extra chrupkie', '4'),
    ('Bakalland', 'Orzechy makadamia łuskane', '1'),
    ('Bakallino', 'Migdały łuskane', '1'),
    ('Unknown', 'Orzechy nerkowca połówki', '1'),
    ('Kresto', 'Mix orzechów', '1'),
    ('Felix', 'Carmelove z wiórkami kokosowymi', '4'),
    ('Felix', 'Orzeszki ziemne prażone', '1'),
    ('Aga Holtex', 'Migdały', '1'),
    ('BakaD’Or', 'Migdały łuskane kalifornijskie', '1'),
    ('Felix', 'Orzeszki z pieca z solą', '4'),
    ('Ecobi', 'Orzechy włoskie łuskane', '1'),
    ('Green Essence', 'Migdały naturalne całe', '1'),
    ('brat.pl', 'Orzechy brazylijskie połówki', '1'),
    ('Carrefour Extra', 'Migdały łuskane', '1'),
    ('Felix', 'Felix orzeszki ziemne', '3'),
    ('BakaD''Or', 'Mieszanka egzotyczna', '3'),
    ('Felix', 'Orzeszki ziemne lekko solone', '3'),
    ('BakaD''Or', 'Orzechy Nerkowca', '1'),
    ('Bakador', 'Orzechy pekan', '1'),
    ('Top', 'Orzeszki Top smak papryka', '4'),
    ('Bakador', 'Mieszanka orzechowa', '4'),
    ('Top Biedronka', 'Orzeszki ziemne prażone', '4'),
    ('Bakador', 'Orzechy brazylijskie', '1'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', '4'),
    ('Bakador', 'Orzechy nerkowca', '1'),
    ('Unknown', 'Migdały łuskane', '4'),
    ('Helio S.A.', 'Mieszanka Studencka', '3'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', '4'),
    ('Makar', 'Orzechy Brazylijskie', '1'),
    ('Spar', 'Mieszanka Studencka', '4'),
    ('Felix', 'Orzeszki ziemne solone', '4'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', '1'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', '4')
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;
