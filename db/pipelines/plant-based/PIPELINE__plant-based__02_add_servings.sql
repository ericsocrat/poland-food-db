-- PIPELINE (PLANT-BASED): add servings
-- PIPELINE__plant-based__02_add_servings.sql
-- Adds per-100g servings for plant-based products (EU nutrition labels are per 100g/100ml).

insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category='Plant-Based & Alternatives'
  and s.serving_id is null;
