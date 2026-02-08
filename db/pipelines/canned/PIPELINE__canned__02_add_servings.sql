-- PIPELINE (CANNED GOODS): add servings
-- PIPELINE__canned__02_add_servings.sql
-- Adds per-100g servings for canned goods (EU nutrition labels are per 100g)

insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category='Canned Goods'
  and s.serving_id is null;
