-- PIPELINE (Cereals): scoring
-- Generated: 2026-02-08

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Sante', 'Granola chocolate / pieces of chocolate', '2'),
    ('sante', 'Sante gold granola', '2'),
    ('Sante', 'Granola Nut / peanuts & peanut butter', '2'),
    ('Sante', 'sante fit granola strawberry and cherry', '1'),
    ('GO ON', 'Protein granola', '4'),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', '1'),
    ('GO ON', 'granola brownie & cherry', '3'),
    ('One Day More', 'Muesli chocolat', '1'),
    ('Carrefour', 'Copos de Avena / Fiocchi d''Avena', '0'),
    ('Chabrior', 'Flocons d''avoine complète 500g', '0'),
    ('Carrefour', 'Corn flakes', '0'),
    ('Crownfield', 'Müsli Multifrucht', '0'),
    ('Carrefour BIO', 'Corn flakes', '1'),
    ('Carrefour', 'Crunchy Chocolat noir intense', '2'),
    ('Crownfield', 'Traube-Nuss Müsli 68% Vollkorn', '0'),
    ('Carrefour', 'Flocons d''avoine complete', '0'),
    ('Carrefour BIO', 'Céréales cœur fondant', '1'),
    ('Carrefour', 'Stylesse Nature', '0'),
    ('Carrefour', 'MUESLI & Co 6 FRUITS SECS', '0'),
    ('Carrefour BIO', 'Pétales au chocolat blé complet', '0'),
    ('Carrefour', 'Stylesse Chocolat Noir', '1'),
    ('Carrefour', 'Stylesse Fruits rouges', '0'),
    ('Carrefour', 'CROCKS Goût CHOCO-NOISETTE', '3'),
    ('Carrefour', 'Crunchy', '3'),
    ('Carrefour', 'Muesly croustillant cruchy chocolat noir intense', '2'),
    ('Carrefour', 'Choco Bollz', '0'),
    ('Carrefour', 'Choco Rice', '0'),
    ('Carrefour', 'Pétales de maïs', '0')
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Sante', 'Granola chocolate / pieces of chocolate', 'D'),
    ('sante', 'Sante gold granola', 'C'),
    ('Sante', 'Granola Nut / peanuts & peanut butter', 'D'),
    ('Sante', 'sante fit granola strawberry and cherry', 'B'),
    ('GO ON', 'Protein granola', 'A'),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 'D'),
    ('GO ON', 'granola brownie & cherry', 'A'),
    ('One Day More', 'Muesli chocolat', 'C'),
    ('Carrefour', 'Copos de Avena / Fiocchi d''Avena', 'A'),
    ('Chabrior', 'Flocons d''avoine complète 500g', 'A'),
    ('Carrefour', 'Corn flakes', 'C'),
    ('Crownfield', 'Müsli Multifrucht', 'B'),
    ('Carrefour BIO', 'Corn flakes', 'C'),
    ('Carrefour', 'Crunchy Chocolat noir intense', 'C'),
    ('Crownfield', 'Traube-Nuss Müsli 68% Vollkorn', 'A'),
    ('Carrefour', 'Flocons d''avoine complete', 'A'),
    ('Carrefour BIO', 'Céréales cœur fondant', 'D'),
    ('Carrefour', 'Stylesse Nature', 'C'),
    ('Carrefour', 'MUESLI & Co 6 FRUITS SECS', 'B'),
    ('Carrefour BIO', 'Pétales au chocolat blé complet', 'C'),
    ('Carrefour', 'Stylesse Chocolat Noir', 'D'),
    ('Carrefour', 'Stylesse Fruits rouges', 'C'),
    ('Carrefour', 'CROCKS Goût CHOCO-NOISETTE', 'D'),
    ('Carrefour', 'Crunchy', 'A'),
    ('Carrefour', 'Muesly croustillant cruchy chocolat noir intense', 'C'),
    ('Carrefour', 'Choco Bollz', 'C'),
    ('Carrefour', 'Choco Rice', 'C'),
    ('Carrefour', 'Pétales de maïs', 'D')
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
    ('Sante', 'Granola chocolate / pieces of chocolate', '4'),
    ('sante', 'Sante gold granola', '4'),
    ('Sante', 'Granola Nut / peanuts & peanut butter', '4'),
    ('Sante', 'sante fit granola strawberry and cherry', '4'),
    ('GO ON', 'Protein granola', '4'),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', '4'),
    ('GO ON', 'granola brownie & cherry', '4'),
    ('One Day More', 'Muesli chocolat', '4'),
    ('Carrefour', 'Copos de Avena / Fiocchi d''Avena', '1'),
    ('Chabrior', 'Flocons d''avoine complète 500g', '1'),
    ('Carrefour', 'Corn flakes', '3'),
    ('Crownfield', 'Müsli Multifrucht', '3'),
    ('Carrefour BIO', 'Corn flakes', '4'),
    ('Carrefour', 'Crunchy Chocolat noir intense', '4'),
    ('Crownfield', 'Traube-Nuss Müsli 68% Vollkorn', '3'),
    ('Carrefour', 'Flocons d''avoine complete', '1'),
    ('Carrefour BIO', 'Céréales cœur fondant', '4'),
    ('Carrefour', 'Stylesse Nature', '3'),
    ('Carrefour', 'MUESLI & Co 6 FRUITS SECS', '1'),
    ('Carrefour BIO', 'Pétales au chocolat blé complet', '4'),
    ('Carrefour', 'Stylesse Chocolat Noir', '4'),
    ('Carrefour', 'Stylesse Fruits rouges', '3'),
    ('Carrefour', 'CROCKS Goût CHOCO-NOISETTE', '4'),
    ('Carrefour', 'Crunchy', '4'),
    ('Carrefour', 'Muesly croustillant cruchy chocolat noir intense', '4'),
    ('Carrefour', 'Choco Bollz', '4'),
    ('Carrefour', 'Choco Rice', '4'),
    ('Carrefour', 'Pétales de maïs', '3')
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;
