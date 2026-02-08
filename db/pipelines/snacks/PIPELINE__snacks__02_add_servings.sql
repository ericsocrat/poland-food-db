-- PIPELINE (SNACKS): add servings
-- PIPELINE__snacks__02_add_servings.sql
-- All nutrition is declared per 100 g (standard EU labeling).
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT servings (idempotent: skip if already exists)
-- ═══════════════════════════════════════════════════════════════════

insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and sv.serving_id is null;
