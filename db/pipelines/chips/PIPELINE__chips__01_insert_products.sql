-- PIPELINE (CHIPS): insert products
-- PIPELINE__chips__01_insert_products.sql
-- 16 verified products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-07

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Lay's / PepsiCo ─────────────────────────────────────────────────────
-- EAN 5900259127600 — Lay's Solone (classic salted, NOVA 3)
('PL','Lay''s','Grocery','Chips','Lay''s Solone','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259093103 — Lay's Fromage (cheese flavour, NOVA 4)
('PL','Lay''s','Grocery','Chips','Lay''s Fromage','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259133366 — Lay's Oven Baked Grilled Paprika (baked, not fried)
('PL','Lay''s','Grocery','Chips','Lay''s Oven Baked Grilled Paprika','baked','Biedronka;Lidl;Żabka','none'),

-- ── Pringles / Kellogg's ────────────────────────────────────────────────
-- EAN 5053990101573 — Pringles Original (reconstituted potato, NOVA 4)
('PL','Pringles','Grocery','Chips','Pringles Original','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5053990161669 — Pringles Paprika (7 additives incl. MSG, NOVA 4)
('PL','Pringles','Grocery','Chips','Pringles Paprika','fried','Biedronka;Lidl;Żabka','none'),

-- ── Crunchips / Lorenz Bahlsen ──────────────────────────────────────────
-- EAN 5905187114685 — Crunchips X-Cut Papryka (classic PL staple)
('PL','Crunchips','Grocery','Chips','Crunchips X-Cut Papryka','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5905187114760 — Crunchips Pieczone Żeberka (BBQ ribs flavour)
('PL','Crunchips','Grocery','Chips','Crunchips Pieczone Żeberka','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5905187114845 — Crunchips Chakalaka (African spice blend)
('PL','Crunchips','Grocery','Chips','Crunchips Chakalaka','fried','Biedronka;Lidl;Żabka','none'),

-- ── Doritos / PepsiCo (corn tortilla chips) ─────────────────────────────
-- EAN 5900259094728 — Doritos Hot Corn (corn-based, NOVA 4)
('PL','Doritos','Grocery','Chips','Doritos Hot Corn','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259106667 — Doritos BBQ (corn-based, NOVA 4)
('PL','Doritos','Grocery','Chips','Doritos BBQ','fried','Biedronka;Lidl;Żabka','none'),

-- ── Cheetos / PepsiCo (corn-based puffs) ────────────────────────────────
-- EAN 5900259135360 — Cheetos Flamin Hot (corn 71%, NOVA 4)
('PL','Cheetos','Grocery','Chips','Cheetos Flamin Hot','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259068002 — Cheetos Cheese (EXTREME salt 3.2 g, Nutri-Score E)
('PL','Cheetos','Grocery','Chips','Cheetos Cheese','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259107350 — Cheetos Hamburger (NOVA 4)
('PL','Cheetos','Grocery','Chips','Cheetos Hamburger','fried','Biedronka;Lidl;Żabka','none'),

-- ── Top Chips / Biedronka private label ─────────────────────────────────
-- EAN 5900073021269 — Top Chips Fromage (potato chips, NOVA 4)
('PL','Top Chips (Biedronka)','Grocery','Chips','Top Chips Fromage','fried','Biedronka','none'),
-- EAN 5900073400576 — Top Chips Faliste (PALM OIL — 16 g sat fat!, Nutri-Score E)
('PL','Top Chips (Biedronka)','Grocery','Chips','Top Chips Faliste','fried','Biedronka','minor'),

-- ── Snack Day / Lidl private label ──────────────────────────────────────
-- EAN 4056489486459 — Snack Day Chipsy Solone (3 ingredients, NOVA 3)
('PL','Snack Day (Lidl)','Grocery','Chips','Snack Day Chipsy Solone','fried','Lidl','none')

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
where country='PL' and category='Chips'
  and is_deprecated is not true
  and product_name not in (
    'Lay''s Solone','Lay''s Fromage','Lay''s Oven Baked Grilled Paprika',
    'Pringles Original','Pringles Paprika',
    'Crunchips X-Cut Papryka','Crunchips Pieczone Żeberka','Crunchips Chakalaka',
    'Doritos Hot Corn','Doritos BBQ',
    'Cheetos Flamin Hot','Cheetos Cheese','Cheetos Hamburger',
    'Top Chips Fromage','Top Chips Faliste',
    'Snack Day Chipsy Solone'
  );
