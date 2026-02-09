-- PIPELINE (Seafood & Fish): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 0),
    ('Marinero', 'Łosoś wędzony na zimno', 0),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 0),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 3),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 0),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 10),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 0),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 5),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', 0),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 0),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', 0),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', 0),
    ('Śledzie od serca', 'Śledzie po żydowsku', 0),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 0),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', 0),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 0),
    ('Pescadero', 'Filety z pstrąga', 0),
    ('Contimax', 'Wiejskie filety śledziowe marynowane z cebulą', 0),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', 0),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 0),
    ('Marinero', 'Łosoś łagodny', 0),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 4),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 3),
    ('Lisner', 'Marinated Herring in mushroom sauce', 7),
    ('Suempol', 'Gniazda z łososia', 0),
    ('Koryb', 'Łosoś atlantycki', 0),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', 0),
    ('Unknown', 'Łosoś wędzony na gorąco', 0),
    ('Lisner', 'Herring single portion with onion', 0),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 3),
    ('Lisner', 'Herring Snack', 0),
    ('nautica', 'Śledzie Wiejskie', 0),
    ('Well done', 'Łosoś atlantycki', 0),
    ('Graal', 'Szprot w sosie pomidorowym', 0),
    ('Marinero', 'Filety śledziowe a''la Matjas', 7)
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
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
    ('Marinero', 'Filety śledziowe a''la Matjas', 'E')
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
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', '3'),
    ('Marinero', 'Łosoś wędzony na zimno', '3'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', '3'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', '3'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', '3'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', '4'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', '3'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', '4'),
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
    ('Marinero', 'Filety śledziowe a''la Matjas', '4')
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;
