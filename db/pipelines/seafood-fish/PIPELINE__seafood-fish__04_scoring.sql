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
    ('Jantar', 'Szprot wędzony na gorąco', '0'),
    ('Dega', 'Ryba śledź po grecku', '6'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', '0'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', '0'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', '0'),
    ('Fisher King', 'Pstrąg łososiowy wędzony w plastrach', '0'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', '0'),
    ('Lisner', 'Pastella - pasta z łososia', '7'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', '2'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', '4'),
    ('Lisner', 'Marinated Herring in mushroom sauce', '7'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', '3'),
    ('Lisner', 'Herring single portion with onion', '0'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', '3'),
    ('nautica', 'Śledzie Wiejskie', '0'),
    ('Lisner', 'Herring Snack', '0'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', '0'),
    ('Graal', 'Szprot w sosie pomidorowym', '0'),
    ('CONNOISSEUR seafood collection', 'Filetti di salmone al naturale', '0'),
    ('House of Asia', 'wakame', '0'),
    ('Carrefour Discount', 'Bâtonnets saveur crabe', '1'),
    ('ocean sea', 'Paluszki surimi', '9'),
    ('Carrefour', 'Queues de crevettes CRUES', '3'),
    ('Carrefour', 'Crevettes sauvages décortiquées cuites', '3'),
    ('Carrefour', 'Filets DE MERLU BLANC', '0'),
    ('Vici', 'Classic surimi sticks', '0'),
    ('Rio Mare', 'Insalatissime Sicily Edition', '1')
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g::numeric,
      nf.sugars_g::numeric,
      nf.salt_g::numeric,
      nf.calories::numeric,
      nf.trans_fat_g::numeric,
      i.additives_count::numeric,
      p.prep_method,
      p.controversies
  )::text,
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
    ('Jantar', 'Szprot wędzony na gorąco', 'D'),
    ('Dega', 'Ryba śledź po grecku', 'C'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'E'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 'E'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', 'C'),
    ('Fisher King', 'Pstrąg łososiowy wędzony w plastrach', 'E'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 'D'),
    ('Lisner', 'Pastella - pasta z łososia', 'E'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', 'C'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 'C'),
    ('Lisner', 'Marinated Herring in mushroom sauce', 'C'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 'C'),
    ('Lisner', 'Herring single portion with onion', 'D'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 'C'),
    ('nautica', 'Śledzie Wiejskie', 'E'),
    ('Lisner', 'Herring Snack', 'D'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'D'),
    ('Graal', 'Szprot w sosie pomidorowym', 'C'),
    ('CONNOISSEUR seafood collection', 'Filetti di salmone al naturale', 'D'),
    ('House of Asia', 'wakame', 'E'),
    ('Carrefour Discount', 'Bâtonnets saveur crabe', 'C'),
    ('ocean sea', 'Paluszki surimi', 'C'),
    ('Carrefour', 'Queues de crevettes CRUES', 'A'),
    ('Carrefour', 'Crevettes sauvages décortiquées cuites', 'B'),
    ('Carrefour', 'Filets DE MERLU BLANC', 'UNKNOWN'),
    ('Vici', 'Classic surimi sticks', 'C'),
    ('Rio Mare', 'Insalatissime Sicily Edition', 'C')
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
    ('Jantar', 'Szprot wędzony na gorąco', '3'),
    ('Dega', 'Ryba śledź po grecku', '4'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', '3'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', '3'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', '4'),
    ('Fisher King', 'Pstrąg łososiowy wędzony w plastrach', '3'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', '3'),
    ('Lisner', 'Pastella - pasta z łososia', '4'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', '4'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', '4'),
    ('Lisner', 'Marinated Herring in mushroom sauce', '4'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', '4'),
    ('Lisner', 'Herring single portion with onion', '3'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', '4'),
    ('nautica', 'Śledzie Wiejskie', '3'),
    ('Lisner', 'Herring Snack', '3'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', '3'),
    ('Graal', 'Szprot w sosie pomidorowym', '4'),
    ('CONNOISSEUR seafood collection', 'Filetti di salmone al naturale', '3'),
    ('House of Asia', 'wakame', '4'),
    ('Carrefour Discount', 'Bâtonnets saveur crabe', '4'),
    ('ocean sea', 'Paluszki surimi', '4'),
    ('Carrefour', 'Queues de crevettes CRUES', '3'),
    ('Carrefour', 'Crevettes sauvages décortiquées cuites', '4'),
    ('Carrefour', 'Filets DE MERLU BLANC', '1'),
    ('Vici', 'Classic surimi sticks', '4'),
    ('Rio Mare', 'Insalatissime Sicily Edition', '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g::numeric >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count::numeric, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;
