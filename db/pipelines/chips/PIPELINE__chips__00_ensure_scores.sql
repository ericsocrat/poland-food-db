-- PIPELINE__chips__00_ensure_scores.sql
-- Ensure every chips product has a row in scores (and ingredients if needed).

-- 1) Scores rows
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country='PL' and p.category='Chips'
  and sc.product_id is null;

-- 2) Ingredients rows (optional but useful later)
insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country='PL' and p.category='Chips'
  and i.product_id is null;
