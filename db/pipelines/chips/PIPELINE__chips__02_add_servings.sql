-- PIPELINE (CHIPS): add servings
-- PIPELINE__chips__02_add_servings.sql
-- Adds per-100g servings for chips (since labels are per 100g in EU).

insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category='Chips'
  and s.serving_id is null;
