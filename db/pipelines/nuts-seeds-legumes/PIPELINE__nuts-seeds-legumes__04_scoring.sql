-- PIPELINE (Nuts, Seeds & Legumes): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 0),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 0),
    ('bakador', 'migdały', 0),
    ('Felix', 'Orzeszki ziemne smażone i solone', 0),
    ('Felix', 'Felix orzeszki ziemne', 0),
    ('BakaD''Or', 'Mieszanka egzotyczna', 1),
    ('felix', 'Orzeszki ziemne lekko solone', 0),
    ('Alesto', 'Alesto pörkölt egészmogyoró', 0),
    ('Felix', 'Orzeszki ziemne solone', 0),
    ('Bakador', 'Orzechy pekan', 0),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 0),
    ('Bakador', 'Mieszanka Orzechowa', 0),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 1),
    ('Felix', 'Peanuts join BBQ-Honey Style', 1),
    ('Bakador', 'Orzechy Nerkowca', 0),
    ('Lidl', 'Mieszanka Orzechów', 0),
    ('Alesto', 'Almonds natural', 0),
    ('Alesto', 'Cashewkerne', 0),
    ('Alesto', 'Nussmix', 0),
    ('Alesto Selection', 'Walnusskerne naturbelassen', 0),
    ('Alesto', 'Noisettes grillées', 0),
    ('Alesto Selection', 'Pecan Nuts natural', 0),
    ('Carrefour', 'Cacahuètes grillées sans sel ajouté.', 0),
    ('CARREFOUR CLASSIC''', 'CACAHUÈTES GRILLEES SALEES', 0),
    ('Alesto', 'Protein Mix mit Nüssen & Sojabohnen', 0),
    ('Carrefour', 'Pistaches grillees', 0),
    ('Carrefour', 'Cacahuètes', 0),
    ('Carrefour', 'Pistaches grillées salées', 0)
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 'C'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 'A'),
    ('bakador', 'migdały', 'A'),
    ('Felix', 'Orzeszki ziemne smażone i solone', 'C'),
    ('Felix', 'Felix orzeszki ziemne', 'C'),
    ('BakaD''Or', 'Mieszanka egzotyczna', 'D'),
    ('felix', 'Orzeszki ziemne lekko solone', 'B'),
    ('Alesto', 'Alesto pörkölt egészmogyoró', 'A'),
    ('Felix', 'Orzeszki ziemne solone', 'C'),
    ('Bakador', 'Orzechy pekan', 'UNKNOWN'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 'B'),
    ('Bakador', 'Mieszanka Orzechowa', 'C'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 'B'),
    ('Felix', 'Peanuts join BBQ-Honey Style', 'C'),
    ('Bakador', 'Orzechy Nerkowca', 'D'),
    ('Lidl', 'Mieszanka Orzechów', 'UNKNOWN'),
    ('Alesto', 'Almonds natural', 'A'),
    ('Alesto', 'Cashewkerne', 'B'),
    ('Alesto', 'Nussmix', 'A'),
    ('Alesto Selection', 'Walnusskerne naturbelassen', 'A'),
    ('Alesto', 'Noisettes grillées', 'A'),
    ('Alesto Selection', 'Pecan Nuts natural', 'A'),
    ('Carrefour', 'Cacahuètes grillées sans sel ajouté.', 'A'),
    ('CARREFOUR CLASSIC''', 'CACAHUÈTES GRILLEES SALEES', 'A'),
    ('Alesto', 'Protein Mix mit Nüssen & Sojabohnen', 'D'),
    ('Carrefour', 'Pistaches grillees', 'A'),
    ('Carrefour', 'Cacahuètes', 'A'),
    ('Carrefour', 'Pistaches grillées salées', 'B')
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
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 1),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 1),
    ('bakador', 'migdały', 4),
    ('Felix', 'Orzeszki ziemne smażone i solone', 3),
    ('Felix', 'Felix orzeszki ziemne', 3),
    ('BakaD''Or', 'Mieszanka egzotyczna', 3),
    ('felix', 'Orzeszki ziemne lekko solone', 3),
    ('Alesto', 'Alesto pörkölt egészmogyoró', 1),
    ('Felix', 'Orzeszki ziemne solone', 4),
    ('Bakador', 'Orzechy pekan', 4),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 1),
    ('Bakador', 'Mieszanka Orzechowa', 1),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 4),
    ('Felix', 'Peanuts join BBQ-Honey Style', 4),
    ('Bakador', 'Orzechy Nerkowca', 4),
    ('Lidl', 'Mieszanka Orzechów', 4),
    ('Alesto', 'Almonds natural', 1),
    ('Alesto', 'Cashewkerne', 4),
    ('Alesto', 'Nussmix', 1),
    ('Alesto Selection', 'Walnusskerne naturbelassen', 1),
    ('Alesto', 'Noisettes grillées', 1),
    ('Alesto Selection', 'Pecan Nuts natural', 4),
    ('Carrefour', 'Cacahuètes grillées sans sel ajouté.', 3),
    ('CARREFOUR CLASSIC''', 'CACAHUÈTES GRILLEES SALEES', 3),
    ('Alesto', 'Protein Mix mit Nüssen & Sojabohnen', 3),
    ('Carrefour', 'Pistaches grillees', 3),
    ('Carrefour', 'Cacahuètes', 3),
    ('Carrefour', 'Pistaches grillées salées', 3)
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;


-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;
