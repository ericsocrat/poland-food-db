-- PIPELINE (ŻABKA): add servings
-- PIPELINE__zabka__02_add_servings.sql
-- Adds per-100g servings for Żabka products (EU label standard).

insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category='Żabka'
  and p.is_deprecated is not true
  and s.serving_id is null;
