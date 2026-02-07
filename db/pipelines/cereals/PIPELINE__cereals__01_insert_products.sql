-- PIPELINE (CEREALS): insert products
-- PIPELINE__cereals__01_insert_products.sql
-- 16 verified products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-07

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Nestlé ──────────────────────────────────────────────────────────────
-- EAN 5900020019592 — Nestlé Corn Flakes (fortified, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Corn Flakes','baked','Biedronka;Lidl;Żabka','none'),
-- EAN 5900020000590 — Chocapic (chocolate cereal, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Chocapic','baked','Biedronka;Lidl;Żabka','none'),
-- EAN 5900020002730 — Cini Minis (cinnamon squares, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Cini Minis','baked','Biedronka;Lidl;Żabka','none'),
-- EAN 5900020035929 — Cheerios Owsiany (oat-based rings, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Cheerios Owsiany','baked','Biedronka;Lidl;Żabka','none'),
-- EAN 5900020021625 — Lion Caramel & Chocolate (dessert cereal, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Lion Caramel & Chocolate','baked','Biedronka;Lidl;Żabka','none'),
-- EAN 5900020038593 — Ciniminis Churros (churros-shaped, NOVA 4)
('PL','Nestlé','Grocery','Cereals','Nestlé Ciniminis Churros','baked','Biedronka;Lidl;Żabka','none'),

-- ── Nesquik / Nestlé ────────────────────────────────────────────────────
-- EAN 5900020013491 — Nesquik Mix (cocoa + vanilla, NOVA 4)
('PL','Nesquik','Grocery','Cereals','Nesquik Mix','baked','Biedronka;Lidl;Żabka','none'),

-- ── Sante ───────────────────────────────────────────────────────────────
-- EAN 5900617037152 — Sante Gold Granola (premium crunchy granola, NOVA 4)
('PL','Sante','Grocery','Cereals','Sante Gold Granola','baked','Biedronka;Lidl','none'),
-- EAN 5900617037213 — Sante Fit Granola Truskawka & Wiśnia (lower sugar, NOVA 4)
('PL','Sante','Grocery','Cereals','Sante Fit Granola Truskawka & Wiśnia','baked','Biedronka;Lidl','none'),

-- ── Vitanella / Biedronka private label ─────────────────────────────────
-- EAN 5907437365489 — Miami Hopki (cocoa cereal balls, NOVA 4)
('PL','Vitanella (Biedronka)','Grocery','Cereals','Vitanella Miami Hopki','baked','Biedronka','none'),
-- EAN 5907437366059 — Choki (chocolate wheat shells, NOVA 4)
('PL','Vitanella (Biedronka)','Grocery','Cereals','Vitanella Choki','baked','Biedronka','none'),
-- EAN 5907437367919 — Orito Kakaowe (filled cocoa pillows, NOVA 4)
('PL','Vitanella (Biedronka)','Grocery','Cereals','Vitanella Orito Kakaowe','baked','Biedronka','minor'),

-- ── Crownfield / Lidl private label ─────────────────────────────────────
-- EAN 20061449 — Goldini (honey loops, NOVA 4)
('PL','Crownfield (Lidl)','Grocery','Cereals','Crownfield Goldini','baked','Lidl','none'),
-- EAN 4056489978701 — Choco Muszelki (chocolate shells, NOVA 4)
('PL','Crownfield (Lidl)','Grocery','Cereals','Crownfield Choco Muszelki','baked','Lidl','none'),

-- ── Melvit ──────────────────────────────────────────────────────────────
-- EAN 5906827003802 — Płatki Owsiane Górskie (whole oat flakes, NOVA 1)
('PL','Melvit','Grocery','Cereals','Melvit Płatki Owsiane Górskie','air-popped','Biedronka;Lidl','none'),

-- ── Lubella ─────────────────────────────────────────────────────────────
-- EAN 5900049011645 — Corn Flakes Pełne Ziarno (whole grain, NOVA 4)
('PL','Lubella','Grocery','Cereals','Lubella Corn Flakes Pełne Ziarno','baked','Biedronka;Lidl;Żabka','none')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies;

-- Deprecate old placeholder products that are no longer in the pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
where country='PL' and category='Cereals'
  and is_deprecated is not true
  and product_name not in (
    'Nestlé Corn Flakes','Nestlé Chocapic','Nestlé Cini Minis',
    'Nestlé Cheerios Owsiany','Nestlé Lion Caramel & Chocolate','Nestlé Ciniminis Churros',
    'Nesquik Mix',
    'Sante Gold Granola','Sante Fit Granola Truskawka & Wiśnia',
    'Vitanella Miami Hopki','Vitanella Choki','Vitanella Orito Kakaowe',
    'Crownfield Goldini','Crownfield Choco Muszelki',
    'Melvit Płatki Owsiane Górskie',
    'Lubella Corn Flakes Pełne Ziarno'
  );
