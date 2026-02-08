-- PIPELINE (Cereals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Cereals'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sante', 'Grocery', 'Cereals', 'Granola chocolate / pieces of chocolate', null, 'Green,Yerevan City', 'none', '5900617002983'),
  ('PL', 'sante', 'Grocery', 'Cereals', 'Sante gold granola', null, 'sultan center', 'none', '5900617037152'),
  ('PL', 'Sante', 'Grocery', 'Cereals', 'Granola Nut / peanuts & peanut butter', null, null, 'none', '5900617002976'),
  ('PL', 'Sante', 'Grocery', 'Cereals', 'sante fit granola strawberry and cherry', null, null, 'none', '5900617037213'),
  ('PL', 'GO ON', 'Grocery', 'Cereals', 'Protein granola', null, null, 'none', '5900617039262'),
  ('PL', 'Santé', 'Grocery', 'Cereals', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', null, null, 'none', '5900617002617'),
  ('PL', 'GO ON', 'Grocery', 'Cereals', 'granola brownie & cherry', null, null, 'none', '5900617043481'),
  ('PL', 'One Day More', 'Grocery', 'Cereals', 'Muesli chocolat', null, null, 'none', '5902884461890'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Copos de Avena / Fiocchi d''Avena', null, 'Carrefour,Carrefour Market,carrefour.fr', 'none', '3560070614202'),
  ('PL', 'Chabrior', 'Grocery', 'Cereals', 'Flocons d''avoine complète 500g', null, 'Intermarché, INTERMARCHE FRANCE', 'none', '3250391896554'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Corn flakes', null, 'carrefour,carrefour.fr', 'none', '3560071016074'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Müsli Multifrucht', null, 'Lidl', 'none', '20003234'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Cereals', 'Corn flakes', null, 'Carrefour,carrefour.fr', 'none', '3560071267582'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Crunchy Chocolat noir intense', null, 'Carrefour,carrefour.fr', 'none', '3560071013035'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Traube-Nuss Müsli 68% Vollkorn', null, 'Lidl', 'none', '20353889'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Flocons d''avoine complete', null, 'carrefour', 'none', '3560071478643'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Cereals', 'Céréales cœur fondant', null, 'Carrefour,carrefour.fr', 'none', '3560070800209'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Stylesse Nature', null, 'Carrefour,carrefour.fr', 'none', '3560071013196'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'MUESLI & Co 6 FRUITS SECS', null, 'Carrefour Market,Carrefour,carrefour.fr', 'none', '3270190111108'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Cereals', 'Pétales au chocolat blé complet', null, 'Carrefour,Carrefour Market,carrefour.fr', 'none', '3560071267032'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Stylesse Chocolat Noir', null, 'Carrefour Market,Carrefour,carrefour.fr', 'none', '3560071013127'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Stylesse Fruits rouges', null, 'Carrefour,carrefour.fr', 'none', '3560071013110'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'CROCKS Goût CHOCO-NOISETTE', null, 'Carrefour Market,Carrefour,carrefour.fr', 'none', '3560070737710'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Crunchy', null, 'Carrefour,carrefour.fr', 'none', '3560070581870'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Muesly croustillant cruchy chocolat noir intense', null, 'carrefour, carrefour.fr', 'none', '3560071013042'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Choco Bollz', null, 'Carrefour,carrefour.fr', 'none', '3560071090821'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Choco Rice', null, 'Carrefour, carrefour.fr', 'none', '3560070800292'),
  ('PL', 'Carrefour', 'Grocery', 'Cereals', 'Pétales de maïs', null, 'Carrefour,carrefour.fr', 'none', '3560071168674')
on conflict (country, brand, product_name) do update set
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Cereals'
  and is_deprecated is not true
  and product_name not in ('Granola chocolate / pieces of chocolate', 'Sante gold granola', 'Granola Nut / peanuts & peanut butter', 'sante fit granola strawberry and cherry', 'Protein granola', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 'granola brownie & cherry', 'Muesli chocolat', 'Copos de Avena / Fiocchi d''Avena', 'Flocons d''avoine complète 500g', 'Corn flakes', 'Müsli Multifrucht', 'Corn flakes', 'Crunchy Chocolat noir intense', 'Traube-Nuss Müsli 68% Vollkorn', 'Flocons d''avoine complete', 'Céréales cœur fondant', 'Stylesse Nature', 'MUESLI & Co 6 FRUITS SECS', 'Pétales au chocolat blé complet', 'Stylesse Chocolat Noir', 'Stylesse Fruits rouges', 'CROCKS Goût CHOCO-NOISETTE', 'Crunchy', 'Muesly croustillant cruchy chocolat noir intense', 'Choco Bollz', 'Choco Rice', 'Pétales de maïs');
