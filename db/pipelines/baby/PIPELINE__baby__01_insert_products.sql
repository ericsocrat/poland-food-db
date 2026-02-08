-- PIPELINE (BABY): insert products
-- PIPELINE__baby__01_insert_products.sql
-- 26 verified products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Categories: baby_cereal (6), baby_puree_fruit (7), baby_puree_dinner (7),
--             baby_snack (1), toddler_pouch (5)
-- NOTE: Baby formula has 0 products on OFF with complete per-100g data for Poland.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values

-- ═══════════════════════════════════════════════════════════════════════════
-- BABY CEREAL (6 products)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── BoboVita (Nutricia / Danone) ────────────────────────────────────────
-- EAN 5900852999383 — Kaszka Zbożowa Jabłko Śliwka (from 5 months, NOVA 4)
('PL','BoboVita','baby_cereal','Baby','BoboVita Kaszka Zbożowa Jabłko Śliwka','none','Biedronka;Rossmann','none'),
-- EAN 5900852041129 — Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa (from 8 months, NOVA 3)
('PL','BoboVita','baby_cereal','Baby','BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa','none','Biedronka;Rossmann','none'),
-- EAN 5900852038112 — Kaszka Mleczna Ryżowa 3 Owoce (from 6 months)
('PL','BoboVita','baby_cereal','Baby','BoboVita Kaszka Mleczna Ryżowa 3 Owoce','none','Biedronka;Rossmann','none'),

-- ── HiPP ────────────────────────────────────────────────────────────────
-- EAN 4062300279773 — Kaszka mleczna z biszkoptami i jabłkami (from 6 months, NOVA 4)
('PL','HiPP','baby_cereal','Baby','HiPP Kaszka mleczna z biszkoptami i jabłkami','none','Rossmann;Apteka','none'),

-- ── Nestlé ──────────────────────────────────────────────────────────────
-- EAN 7613287666819 — Sinlac (hypoallergenic cereal, NOVA 4)
('PL','Nestlé','baby_cereal','Baby','Nestlé Sinlac','none','Apteka;Rossmann','none'),

-- ── Gerber (Nestlé) ────────────────────────────────────────────────────
-- EAN 7613287173997 — Pełnia Zbóż Owsianka 5 Zbóż (oatmeal, from 6 months)
('PL','Gerber','baby_cereal','Baby','Gerber Pełnia Zbóż Owsianka 5 Zbóż','none','Biedronka;Rossmann','none'),

-- ═══════════════════════════════════════════════════════════════════════════
-- BABY PUREE — FRUIT (7 products)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── BoboVita ────────────────────────────────────────────────────────────
-- EAN 5900852068812 — Delikatne jabłka z bananem (from 4 months)
('PL','BoboVita','baby_puree_fruit','Baby','BoboVita Delikatne jabłka z bananem','none','Biedronka;Rossmann','none'),

-- ── Gerber (Nestlé) ────────────────────────────────────────────────────
-- EAN 7613033629303 — owoce jabłka z truskawkami i jagodami (NOVA 3)
('PL','Gerber','baby_puree_fruit','Baby','Gerber owoce jabłka z truskawkami i jagodami','none','Biedronka;Rossmann','none'),

-- ── GutBio (Aldi) ──────────────────────────────────────────────────────
-- EAN 22009326 — Puré de Frutas Manzana y Plátano (apple & banana puree)
('PL','GutBio','baby_puree_fruit','Baby','GutBio Puré de Frutas Manzana y Plátano','none','Aldi','none'),

-- ── Tymbark ─────────────────────────────────────────────────────────────
-- EAN 5900334003935 — Mus gruszka jabłko (pear & apple mousse, NOVA 1)
('PL','Tymbark','baby_puree_fruit','Baby','Tymbark Mus gruszka jabłko','none','Biedronka;Lidl','none'),

-- ── dada baby food ──────────────────────────────────────────────────────
-- EAN 8436550903003 — bio mus kokos (organic coconut mousse)
('PL','dada baby food','baby_puree_fruit','Baby','dada baby food bio mus kokos','none','Biedronka','none'),

-- ── Bobo Frut (Gerber / Nestlé) ────────────────────────────────────────
-- EAN 8445290594334 — Jabłko marchew (apple & carrot, NOVA 1)
('PL','Bobo Frut','baby_puree_fruit','Baby','Bobo Frut Jabłko marchew','none','Biedronka;Rossmann','none'),

-- ── OWOLOVO ─────────────────────────────────────────────────────────────
-- EAN 5901958612404 — Siła & Moc Mus Jabłkowo-Buraczany (apple & beetroot, NOVA 1)
('PL','OWOLOVO','baby_puree_fruit','Baby','OWOLOVO Siła & Moc Mus Jabłkowo-Buraczany','none','Biedronka;Lidl','none'),

-- ═══════════════════════════════════════════════════════════════════════════
-- BABY PUREE — DINNER (7 products)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Gerber (Nestlé) ────────────────────────────────────────────────────
-- EAN 7613033512353 — Krem jarzynowy ze schabem (vegetable soup with pork, NOVA 3)
('PL','Gerber','baby_puree_dinner','Baby','Gerber Krem jarzynowy ze schabem','none','Biedronka;Rossmann','none'),
-- EAN 7613035507142 — Leczo z mozzarellą i kluseczkami (lecho with mozzarella, NOVA 3)
('PL','Gerber','baby_puree_dinner','Baby','Gerber Leczo z mozzarellą i kluseczkami','none','Biedronka;Rossmann','none'),
-- EAN 8445291546967 — Warzywa z delikatnym indykiem w pomidorach (turkey & vegetables)
('PL','Gerber','baby_puree_dinner','Baby','Gerber Warzywa z delikatnym indykiem w pomidorach','none','Biedronka;Rossmann','none'),
-- EAN 8445291546851 — Bukiet warzyw z łososiem w sosie pomidorowym (salmon & vegetables)
('PL','Gerber','baby_puree_dinner','Baby','Gerber Bukiet warzyw z łososiem w sosie pomidorowym','none','Biedronka;Rossmann','none'),

-- ── BoboVita ────────────────────────────────────────────────────────────
-- EAN 5900852150005 — Pomidorowa z kurczakiem i ryżem (tomato soup with chicken, NOVA 3)
('PL','BoboVita','baby_puree_dinner','Baby','BoboVita Pomidorowa z kurczakiem i ryżem','none','Biedronka;Rossmann','none'),

-- ── HiPP ────────────────────────────────────────────────────────────────
-- EAN 9062300109365 — Dynia z indykiem (pumpkin with turkey, NOVA 1)
('PL','HiPP','baby_puree_dinner','Baby','HiPP Dynia z indykiem','none','Rossmann;Apteka','none'),
-- EAN 9062300130833 — Spaghetti z pomidorami i mozzarellą (spaghetti with tomato, NOVA 3)
('PL','HiPP','baby_puree_dinner','Baby','HiPP Spaghetti z pomidorami i mozzarellą','none','Rossmann;Apteka','none'),

-- ═══════════════════════════════════════════════════════════════════════════
-- BABY SNACK (1 product)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Gerber organic ──────────────────────────────────────────────────────
-- EAN 8000300435351 — Krakersy z pomidorem po 12 miesiącu (organic tomato crackers, NOVA 3)
('PL','Gerber','baby_snack','Baby','Gerber organic Krakersy z pomidorem po 12 miesiącu','baked','Biedronka;Rossmann','none'),

-- ═══════════════════════════════════════════════════════════════════════════
-- TODDLER POUCH (5 products)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── OWOLOVO ─────────────────────────────────────────────────────────────
-- EAN 5901958612381 — MORELOWO (apricot mousse pouch, NOVA 1)
('PL','OWOLOVO','toddler_pouch','Baby','OWOLOVO MORELOWO','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5901958612367 — Truskawkowo Mus jabłkowo-truskawkowy (strawberry, NOVA 1)
('PL','OWOLOVO','toddler_pouch','Baby','OWOLOVO Truskawkowo Mus jabłkowo-truskawkowy','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5901958614408 — Ananasowo (pineapple mousse, NOVA 1)
('PL','OWOLOVO','toddler_pouch','Baby','OWOLOVO Ananasowo','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5901958612640 — Mus jabłkowo-wiśniowy (apple & cherry, NOVA 1)
('PL','OWOLOVO','toddler_pouch','Baby','OWOLOVO Mus jabłkowo-wiśniowy','none','Biedronka;Lidl;Żabka','none'),
-- EAN 5901958614996 — Smoothie tropikalne Jabłko Morela Pomarańcza (tropical smoothie, NOVA 1)
('PL','OWOLOVO','toddler_pouch','Baby','OWOLOVO Smoothie tropikalne Jabłko Morela Pomarańcza','none','Biedronka;Lidl;Żabka','none')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies;
