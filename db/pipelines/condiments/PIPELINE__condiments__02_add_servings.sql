-- PIPELINE (Condiments): add servings
insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category='Condiments'
  and p.is_deprecated is not true
  and s.serving_id is null;
