-- PIPELINE (CHIPS): insert products
-- PIPELINE__chips__01_insert_products.sql
-- 28 verified products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

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
('PL','Snack Day (Lidl)','Grocery','Chips','Snack Day Chipsy Solone','fried','Lidl','none'),

-- ── Pringles (additional) ───────────────────────────────────────────────
-- EAN 5053990101597 — Pringles Sour Cream & Onion (NOVA 4, 8 additives)
('PL','Pringles','Grocery','Chips','Pringles Sour Cream & Onion','fried','Biedronka;Lidl;Żabka','minor'),

-- ── Lay's (additional) ─────────────────────────────────────────────────
-- EAN 5900259071194 — Lay's Zielona Cebulka (Green Onion, NOVA 4)
('PL','Lay''s','Grocery','Chips','Lay''s Zielona Cebulka','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259097538 — Lay's Pikantna Papryka (NOVA 4)
('PL','Lay''s','Grocery','Chips','Lay''s Pikantna Papryka','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259133281 — Lay's Max Karbowane Papryka (NOVA 4)
('PL','Lay''s','Grocery','Chips','Lay''s Max Karbowane Papryka','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5900259097392 — Lay's Maxx Ser z Cebulką (NOVA 4)
('PL','Lay''s','Grocery','Chips','Lay''s Maxx Ser z Cebulką','fried','Biedronka;Lidl;Żabka','none'),

-- ── Crunchips (additional) ──────────────────────────────────────────────
-- EAN 5905187114692 — Crunchips X-Cut Solony (3 ingredients, NOVA 3)
('PL','Crunchips','Grocery','Chips','Crunchips X-Cut Solony','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5905187114753 — Crunchips Zielona Cebulka (NOVA 4)
('PL','Crunchips','Grocery','Chips','Crunchips Zielona Cebulka','fried','Biedronka;Lidl;Żabka','none'),

-- ── Wiejskie Ziemniaczki / Lorenz ───────────────────────────────────────
-- EAN 5905187108981 — Wiejskie Ziemniaczki Masło z Solą (kettle-style, NOVA 4)
('PL','Wiejskie Ziemniaczki','Grocery','Chips','Wiejskie Ziemniaczki Masło z Solą','fried','Biedronka;Lidl;Żabka','none'),
-- EAN 5905187109025 — Wiejskie Ziemniaczki Cebulka (NOVA 4, sunflower oil)
('PL','Wiejskie Ziemniaczki','Grocery','Chips','Wiejskie Ziemniaczki Cebulka','fried','Biedronka;Lidl;Żabka','none'),

-- ── Star / PepsiCo (corn puff) ──────────────────────────────────────────
-- EAN 5900259087898 — Star Maczugi ketchup (corn puffs, NOVA 4)
('PL','Star','Grocery','Chips','Star Maczugi','fried','Biedronka;Lidl;Żabka','none'),

-- ── Cheetos (additional) ────────────────────────────────────────────────
-- EAN 5900259115614 — Cheetos Pizzerini (NOVA 4, 5 additives)
('PL','Cheetos','Grocery','Chips','Cheetos Pizzerini','fried','Biedronka;Lidl;Żabka','none'),

-- ── Snack Day / Lidl (additional) ───────────────────────────────────────
-- EAN 4056489405115 — Snack Day Mega Karbowane Słodkie Chilli (NOVA 4)
('PL','Snack Day (Lidl)','Grocery','Chips','Snack Day Mega Karbowane Słodkie Chilli','fried','Lidl','none')

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
    'Lay''s Zielona Cebulka','Lay''s Pikantna Papryka',
    'Lay''s Max Karbowane Papryka','Lay''s Maxx Ser z Cebulką',
    'Pringles Original','Pringles Paprika','Pringles Sour Cream & Onion',
    'Crunchips X-Cut Papryka','Crunchips Pieczone Żeberka','Crunchips Chakalaka',
    'Crunchips X-Cut Solony','Crunchips Zielona Cebulka',
    'Doritos Hot Corn','Doritos BBQ',
    'Cheetos Flamin Hot','Cheetos Cheese','Cheetos Hamburger','Cheetos Pizzerini',
    'Top Chips Fromage','Top Chips Faliste',
    'Snack Day Chipsy Solone','Snack Day Mega Karbowane Słodkie Chilli',
    'Wiejskie Ziemniaczki Masło z Solą','Wiejskie Ziemniaczki Cebulka',
    'Star Maczugi'
  );
