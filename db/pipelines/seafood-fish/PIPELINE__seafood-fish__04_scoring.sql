-- PIPELINE (Seafood & Fish): scoring
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'UNKNOWN'),
    ('Marinero', 'Łosoś wędzony na zimno', 'D'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 'A'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'E'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'D'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'C'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 'E'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 'E'),
    ('Jantar', 'Szprot wędzony na gorąco', 'D'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'E'),
    ('Lisner', 'Szybki Śledzik w sosie śmietankowym', 'E'),
    ('Fischer King', 'Stek z łososia', 'D'),
    ('Dega', 'Ryba śledź po grecku', 'C'),
    ('Kong Oskar', 'Tuńczyk w kawałkach w oleju roślinnym', 'B'),
    ('Auchan', 'ŁOSOŚ PACYFICZNY DZIKI', 'D'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', 'C'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 'D'),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', 'D'),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', 'D'),
    ('Śledzie od serca', 'Śledzie po żydowsku', 'D'),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'D'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'D'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'E'),
    ('Pescadero', 'Filety z pstrąga', 'C'),
    ('Contimax', 'Wiejskie filety śledziowe marynowane z cebulą', 'D'),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', 'D'),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'UNKNOWN'),
    ('Marinero', 'Łosoś łagodny', 'D'),
    ('Lisner', 'Śledzik na raz Pikantny', 'E'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', 'C'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 'C'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 'C'),
    ('Lisner', 'Marinated Herring in mushroom sauce', 'C'),
    ('Suempol', 'Gniazda z łososia', 'UNKNOWN'),
    ('Koryb', 'Łosoś atlantycki', 'A'),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', 'D'),
    ('Unknown', 'Łosoś wędzony na gorąco', 'D'),
    ('Lisner', 'Herring single portion with onion', 'D'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 'C'),
    ('Lisner', 'Herring Snack', 'D'),
    ('nautica', 'Śledzie Wiejskie', 'E'),
    ('Well done', 'Łosoś atlantycki', 'E'),
    ('Graal', 'Szprot w sosie pomidorowym', 'C'),
    ('Marinero', 'Filety śledziowe a''la Matjas', 'E'),
    ('Marinero', 'Paluszki z fileta z dorsza', 'A'),
    ('Asia Flavours', 'Sushi Nori', 'C'),
    ('House Od Asia', 'Nori', 'UNKNOWN'),
    ('Purella', 'Chlorella detoks', 'A'),
    ('Asia Flavours', 'Dried wakame', 'D'),
    ('Marinero', 'Tuńczyk kawałki w sosie własnym', 'A')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', '3'),
    ('Marinero', 'Łosoś wędzony na zimno', '3'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', '3'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', '3'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', '3'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', '4'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', '3'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', '4'),
    ('Jantar', 'Szprot wędzony na gorąco', '3'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', '3'),
    ('Lisner', 'Szybki Śledzik w sosie śmietankowym', '3'),
    ('Fischer King', 'Stek z łososia', '3'),
    ('Dega', 'Ryba śledź po grecku', '4'),
    ('Kong Oskar', 'Tuńczyk w kawałkach w oleju roślinnym', '3'),
    ('Auchan', 'ŁOSOŚ PACYFICZNY DZIKI', '3'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', '4'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', '3'),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', '4'),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', '4'),
    ('Śledzie od serca', 'Śledzie po żydowsku', '4'),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', '3'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', '3'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', '3'),
    ('Pescadero', 'Filety z pstrąga', '3'),
    ('Contimax', 'Wiejskie filety śledziowe marynowane z cebulą', '4'),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', '4'),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', '3'),
    ('Marinero', 'Łosoś łagodny', '3'),
    ('Lisner', 'Śledzik na raz Pikantny', '4'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', '4'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', '4'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', '4'),
    ('Lisner', 'Marinated Herring in mushroom sauce', '4'),
    ('Suempol', 'Gniazda z łososia', '4'),
    ('Koryb', 'Łosoś atlantycki', '4'),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', '4'),
    ('Unknown', 'Łosoś wędzony na gorąco', '3'),
    ('Lisner', 'Herring single portion with onion', '3'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', '4'),
    ('Lisner', 'Herring Snack', '3'),
    ('nautica', 'Śledzie Wiejskie', '3'),
    ('Well done', 'Łosoś atlantycki', '3'),
    ('Graal', 'Szprot w sosie pomidorowym', '4'),
    ('Marinero', 'Filety śledziowe a''la Matjas', '4'),
    ('Marinero', 'Paluszki z fileta z dorsza', '4'),
    ('Asia Flavours', 'Sushi Nori', '1'),
    ('House Od Asia', 'Nori', '4'),
    ('Purella', 'Chlorella detoks', '1'),
    ('Asia Flavours', 'Dried wakame', '1'),
    ('Marinero', 'Tuńczyk kawałki w sosie własnym', '3')
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;
