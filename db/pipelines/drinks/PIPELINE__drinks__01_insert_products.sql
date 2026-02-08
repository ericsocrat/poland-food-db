-- PIPELINE (DRINKS): insert products
-- PIPELINE__drinks__01_insert_products.sql
-- 28 verified beverages from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Coca-Cola Company ───────────────────────────────────────────────────
-- EAN 5449000130389 — Coca-Cola Original (classic cola, NOVA 4)
('PL','Coca-Cola','Grocery','Drinks','Coca-Cola Original','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5449000133328 — Coca-Cola Zero (zero-sugar cola, NOVA 4)
('PL','Coca-Cola','Grocery','Drinks','Coca-Cola Zero','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5449000136350 — Cappy 100% Orange (pure juice, NOVA 1)
('PL','Cappy','Grocery','Drinks','Cappy 100% Orange','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5449000053541 — Fanta Orange (orange soda, NOVA 4)
('PL','Fanta','Grocery','Drinks','Fanta Orange','none','Biedronka;Lidl;Żabka','none'),

-- ── PepsiCo ─────────────────────────────────────────────────────────────
-- EAN 5900497312004 — Pepsi (classic cola, NOVA 4)
('PL','Pepsi','Grocery','Drinks','Pepsi','none','Biedronka;Lidl;Żabka','none'),

-- ── Tymbark (Maspex) ────────────────────────────────────────────────────
-- EAN 5900334012685 — Tymbark Sok 100% Pomarańczowy (100% OJ, NOVA 1)
('PL','Tymbark','Grocery','Drinks','Tymbark Sok 100% Pomarańczowy','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5900334005939 — Tymbark Sok 100% Jabłkowy (100% apple, NOVA 1)
('PL','Tymbark','Grocery','Drinks','Tymbark Sok 100% Jabłkowy','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5900334013378 — Tymbark Multiwitamina (multivitamin nectar, NOVA 4)
('PL','Tymbark','Grocery','Drinks','Tymbark Multiwitamina','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5900334001047 — Tymbark Cactus (low-cal flavored drink, NOVA 4)
('PL','Tymbark','Grocery','Drinks','Tymbark Cactus','none','Biedronka;Lidl;Żabka','none'),

-- ── Hortex ──────────────────────────────────────────────────────────────
-- EAN 5900500031397 — Hortex Sok Jabłkowy 100% (apple juice, NOVA 1)
('PL','Hortex','Grocery','Drinks','Hortex Sok Jabłkowy 100%','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5900500031434 — Hortex Sok Pomarańczowy 100% (orange juice, NOVA 1)
('PL','Hortex','Grocery','Drinks','Hortex Sok Pomarańczowy 100%','none','Biedronka;Lidl;Żabka','none'),

-- ── Tiger (FoodCare) ────────────────────────────────────────────────────
-- EAN 5900334008206 — Tiger Energy Drink (low-sugar energy, NOVA 4)
('PL','Tiger','Grocery','Drinks','Tiger Energy Drink','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5900334009142 — Tiger Energy Drink Classic (full-sugar energy, NOVA 4)
('PL','Tiger','Grocery','Drinks','Tiger Energy Drink Classic','none','Biedronka;Lidl;Żabka','none'),

-- ── 4Move ───────────────────────────────────────────────────────────────
-- EAN 5900552077718 — 4Move Activevitamin (vitamin water, NOVA 4)
('PL','4Move','Grocery','Drinks','4Move Activevitamin','none','Biedronka;Żabka','none'),

-- ── Dawtona ─────────────────────────────────────────────────────────────
-- EAN 5901713020307 — Dawtona Sok Pomidorowy (tomato juice, NOVA 3)
('PL','Dawtona','Grocery','Drinks','Dawtona Sok Pomidorowy','none','Biedronka;Lidl','none'),

-- ── Mlekovita ───────────────────────────────────────────────────────────
-- EAN 5900512300320 — Mlekovita Mleko 3.2% (full-fat UHT milk, NOVA 1)
('PL','Mlekovita','Grocery','Drinks','Mlekovita Mleko 3.2%','none','Biedronka;Lidl;Żabka','none'),

-- ── Red Bull ────────────────────────────────────────────────────────────
-- EAN 9002490100070 — Red Bull Energy Drink (energy drink with taurine, NOVA 4)
('PL','Red Bull','Grocery','Drinks','Red Bull Energy Drink','none','Biedronka;Lidl;Żabka','minor'),

-- ── Monster ─────────────────────────────────────────────────────────────
-- EAN 5060517883683 — Monster Energy Mango Loco (fruit energy drink with taurine, NOVA 4)
('PL','Monster','Grocery','Drinks','Monster Energy Mango Loco','none','Biedronka;Lidl;Żabka','minor'),

-- ── Sprite (Coca-Cola Company) ──────────────────────────────────────────
-- EAN 5449000004840 — Sprite (lemon-lime soda, NOVA 4)
('PL','Sprite','Grocery','Drinks','Sprite','none','Biedronka;Lidl;Żabka','none'),

-- ── 7UP (PepsiCo) ──────────────────────────────────────────────────────
-- EAN 5900497017770 — 7UP (lemon-lime soda, NOVA 4)
('PL','7UP','Grocery','Drinks','7UP','none','Biedronka;Lidl;Żabka','none'),

-- ── Lipton ──────────────────────────────────────────────────────────────
-- EAN 8722700406723 — Lipton Ice Tea Lemon (iced tea, NOVA 4)
('PL','Lipton','Grocery','Drinks','Lipton Ice Tea Lemon','none','Biedronka;Lidl;Żabka','none'),

-- ── Fuze Tea (Coca-Cola Company) ────────────────────────────────────────
-- EAN 5449000237620 — Fuze Tea Peach Hibiscus (iced tea with hibiscus, NOVA 4)
('PL','Fuze Tea','Grocery','Drinks','Fuze Tea Peach Hibiscus','none','Biedronka;Lidl;Żabka','none'),

-- ── Kubuś (Maspex) ─────────────────────────────────────────────────────
-- EAN 5900334005052 — Kubuś Play Marchew-Jabłko (carrot-apple drink, NOVA 3)
('PL','Kubuś','Grocery','Drinks','Kubuś Play Marchew-Jabłko','none','Biedronka;Lidl;Żabka','none'),

-- ── Mountain Dew (PepsiCo) ──────────────────────────────────────────────
-- EAN 4060800207272 — Mountain Dew (citrus soda with caffeine, NOVA 4)
('PL','Mountain Dew','Grocery','Drinks','Mountain Dew','none','Biedronka;Lidl;Żabka','none'),

-- ── Żywiec Zdrój ───────────────────────────────────────────────────────
-- EAN 5900134001359 — Żywiec Zdrój Smako-łyk Truskawka (strawberry flavored water, NOVA 4)
('PL','Żywiec Zdrój','Grocery','Drinks','Żywiec Zdrój Smako-łyk Truskawka','none','Biedronka;Lidl;Żabka','none'),

-- ── Łaciate (Mlekpol) ──────────────────────────────────────────────────
-- EAN 5900820000070 — Łaciate Mleko 2% (semi-skimmed UHT milk, NOVA 1)
('PL','Łaciate','Grocery','Drinks','Łaciate Mleko 2%','none','Biedronka;Lidl;Żabka','none'),

-- ── Mirinda (PepsiCo) ──────────────────────────────────────────────────
-- EAN 4060800102201 — Mirinda Orange (orange soda, NOVA 4)
('PL','Mirinda','Grocery','Drinks','Mirinda Orange','none','Biedronka;Lidl;Żabka','none'),

-- ── Costa Coffee (Coca-Cola Company) ────────────────────────────────────
-- EAN 5449000298928 — Costa Coffee Latte (ready-to-drink latte, NOVA 4)
('PL','Costa Coffee','Grocery','Drinks','Costa Coffee Latte','none','Biedronka;Żabka','none')

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
where country='PL' and category='Drinks'
  and is_deprecated is not true
  and product_name not in (
    'Coca-Cola Original','Coca-Cola Zero','Cappy 100% Orange','Fanta Orange',
    'Pepsi',
    'Tymbark Sok 100% Pomarańczowy','Tymbark Sok 100% Jabłkowy','Tymbark Multiwitamina','Tymbark Cactus',
    'Hortex Sok Jabłkowy 100%','Hortex Sok Pomarańczowy 100%',
    'Tiger Energy Drink','Tiger Energy Drink Classic',
    '4Move Activevitamin',
    'Dawtona Sok Pomidorowy',
    'Mlekovita Mleko 3.2%',
    'Red Bull Energy Drink','Monster Energy Mango Loco',
    'Sprite','7UP',
    'Lipton Ice Tea Lemon','Fuze Tea Peach Hibiscus',
    'Kubuś Play Marchew-Jabłko','Mountain Dew',
    'Żywiec Zdrój Smako-łyk Truskawka',
    'Łaciate Mleko 2%',
    'Mirinda Orange','Costa Coffee Latte'
  );
