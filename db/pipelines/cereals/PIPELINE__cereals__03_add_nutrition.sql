-- PIPELINE (Cereals): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Cereals'
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Sante', 'Granola chocolate / pieces of chocolate', 456.0, 16.0, 3.3, 0, 66.0, 22.0, 6.7, 8.6, 0.6),
    ('sante', 'Sante gold granola', 469.0, 18.0, 2.7, 0, 61.0, 15.0, 6.3, 9.8, 0.4),
    ('Sante', 'Granola Nut / peanuts & peanut butter', 458.0, 17.0, 2.3, 0, 61.0, 18.0, 6.5, 12.0, 0.6),
    ('Sante', 'sante fit granola strawberry and cherry', 412.0, 12.0, 1.7, 0, 77.0, 8.7, 13.0, 8.8, 0.6),
    ('GO ON', 'Protein granola', 416.0, 15.0, 3.0, 0, 44.0, 1.6, 18.0, 21.0, 0.0),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 423.0, 15.0, 6.4, 0, 67.0, 26.0, 6.6, 7.7, 0.3),
    ('GO ON', 'granola brownie & cherry', 408.0, 13.0, 2.4, 0.0, 64.0, 2.1, 18.0, 21.0, 0.0),
    ('One Day More', 'Muesli chocolat', 397.0, 8.3, 3.2, 0, 64.0, 11.3, 7.3, 12.3, 0.2),
    ('Carrefour', 'Copos de Avena / Fiocchi d''Avena', 372.0, 7.0, 1.3, 0, 59.0, 0.7, 10.0, 14.0, 0.0),
    ('Chabrior', 'Flocons d''avoine complète 500g', 369.0, 6.8, 1.2, 0, 60.0, 1.1, 10.0, 12.0, 0.1),
    ('Carrefour', 'Corn flakes', 383.0, 1.2, 0.2, 0, 85.0, 7.2, 2.5, 6.9, 0.8),
    ('Crownfield', 'Müsli Multifrucht', 346.0, 5.3, 1.8, 0, 60.8, 20.0, 9.4, 9.1, 0.1),
    ('Carrefour BIO', 'Corn flakes', 384.0, 1.1, 0.2, 0, 85.0, 2.0, 2.7, 7.4, 0.5),
    ('Carrefour', 'Crunchy Chocolat noir intense', 441.0, 15.0, 3.8, 0, 62.0, 19.0, 9.0, 10.0, 0.1),
    ('Crownfield', 'Traube-Nuss Müsli 68% Vollkorn', 375.0, 10.6, 2.7, 0, 53.6, 11.2, 10.8, 10.8, 0.1),
    ('Carrefour', 'Flocons d''avoine complete', 363.0, 6.6, 1.2, 0, 59.0, 1.1, 11.0, 12.0, 0.0),
    ('Carrefour BIO', 'Céréales cœur fondant', 419.0, 12.0, 2.7, 0, 65.0, 29.0, 7.2, 9.2, 0.4),
    ('Carrefour', 'Stylesse Nature', 379.0, 1.5, 0.2, 0, 80.0, 13.0, 5.3, 8.7, 0.8),
    ('Carrefour', 'MUESLI & Co 6 FRUITS SECS', 366.0, 6.4, 3.0, 0, 63.0, 16.0, 8.9, 9.5, 0.0),
    ('Carrefour BIO', 'Pétales au chocolat blé complet', 379.0, 3.4, 1.6, 0, 74.0, 25.0, 7.6, 9.3, 0.2),
    ('Carrefour', 'Stylesse Chocolat Noir', 397.0, 5.3, 2.6, 0, 76.0, 18.0, 5.6, 8.3, 0.7),
    ('Carrefour', 'Stylesse Fruits rouges', 371.0, 1.4, 0.3, 0, 78.0, 17.0, 7.0, 8.1, 0.8),
    ('Carrefour', 'CROCKS Goût CHOCO-NOISETTE', 456.0, 13.0, 2.0, 0, 75.0, 26.0, 6.3, 6.6, 0.6),
    ('Carrefour', 'Crunchy', 428.0, 15.0, 2.9, 0, 57.0, 5.0, 14.0, 11.0, 0.1),
    ('Carrefour', 'Muesly croustillant cruchy chocolat noir intense', 441.0, 15.0, 3.8, 0, 62.0, 19.0, 9.0, 10.0, 0.1),
    ('Carrefour', 'Choco Bollz', 380.0, 2.4, 1.0, 0, 77.0, 22.0, 7.5, 8.7, 0.4),
    ('Carrefour', 'Choco Rice', 381.0, 2.0, 1.1, 0, 81.0, 19.0, 5.3, 7.1, 0.3),
    ('Carrefour', 'Pétales de maïs', 380.0, 1.1, 0.3, 0, 83.0, 5.4, 3.4, 8.1, 1.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
