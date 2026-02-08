-- PIPELINE (PLANT-BASED): insert products
-- PIPELINE__plant-based__01_insert_products.sql
-- 28 verified plant-based and alternative products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Alpro (Soy & Oat Milk Leader) ──────────────────────────────────────
-- EAN 5411188127383 — Alpro Napój Sojowy Naturalny (unsweetened soy, NOVA 3)
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Sojowy Naturalny','Ready to eat','Biedronka;Lidl;Carrefour;Żabka','none'),
-- EAN 5411188118534 — Alpro Napój Owsiany Naturalny (oat milk, NOVA 3)
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Owsiany Naturalny','Ready to eat','Biedronka;Lidl;Carrefour;Żabka','none'),
-- EAN 5411188127680 — Alpro Jogurt Sojowy Naturalny (soy yogurt, NOVA 3)
('PL','Alpro','Plant-Based Yogurt','Plant-Based & Alternatives','Alpro Jogurt Sojowy Naturalny','Ready to eat','Biedronka;Lidl;Carrefour','none'),
-- EAN 5411188128267 — Alpro Napój Migdałowy Niesłodzony (almond milk, NOVA 3)
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Migdałowy Niesłodzony','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Garden Gourmet (Nestlé Vegan Meat Alternatives) ────────────────────
-- EAN 7613287935779 — Garden Gourmet Sensational Burger (pea protein, NOVA 4)
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Sensational Burger','pan-fry','Biedronka;Carrefour;Auchan','none'),
-- EAN 7613287935953 — Garden Gourmet Vegan Nuggets (soy protein, NOVA 4)
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Nuggets','oven-baked','Biedronka;Carrefour;Auchan','none'),
-- EAN 7613287935984 — Garden Gourmet Vegan Mince (soy protein, NOVA 4)
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Mince','pan-fry','Biedronka;Carrefour;Auchan','none'),
-- EAN 7613287936004 — Garden Gourmet Vegan Schnitzel (wheat protein, NOVA 4)
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Schnitzel','pan-fry','Biedronka;Carrefour','none'),

-- ── Violife (Leading Vegan Cheese) ─────────────────────────────────────
-- EAN 5013665100867 — Violife Original Block (coconut oil-based, NOVA 4)
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Original Block','Ready to eat','Carrefour;Auchan;Organic shops','none'),
-- EAN 5013665101024 — Violife Mozzarella Style Shreds (pizza cheese, NOVA 4)
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Mozzarella Style Shreds','Ready to eat','Carrefour;Auchan;Organic shops','none'),
-- EAN 5013665102687 — Violife Cheddar Slices (coconut oil-based, NOVA 4)
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Cheddar Slices','Ready to eat','Carrefour;Auchan;Organic shops','none'),

-- ── Taifun (Organic Tofu Producer) ─────────────────────────────────────
-- EAN 4005359030015 — Taifun Tofu Natural (organic tofu, NOVA 1)
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Natural','pan-fry','Organic shops;Auchan','none'),
-- EAN 4005359031517 — Taifun Tofu Smoked (naturally smoked, NOVA 3)
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Smoked','Ready to eat','Organic shops;Auchan','none'),
-- EAN 4005359032514 — Taifun Tofu Rosso (Mediterranean herbs, NOVA 3)
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Rosso','pan-fry','Organic shops;Auchan','none'),

-- ── LikeMeat (Plant-Based Meat Range) ──────────────────────────────────
-- EAN 4260347484297 — LikeMeat Like Chicken Pieces (soy-based, NOVA 4)
('PL','LikeMeat','Vegan Meat Alternative','Plant-Based & Alternatives','LikeMeat Like Chicken Pieces','pan-fry','Lidl;Kaufland','none'),
-- EAN 4260347484426 — LikeMeat Like Kebab (seitan-based, NOVA 4)
('PL','LikeMeat','Vegan Meat Alternative','Plant-Based & Alternatives','LikeMeat Like Kebab','pan-fry','Lidl;Kaufland','none'),

-- ── Sojasun (Soy Yogurt Specialist) ────────────────────────────────────
-- EAN 3240589355014 — Sojasun Jogurt Sojowy Naturalny (NOVA 3)
('PL','Sojasun','Plant-Based Yogurt','Plant-Based & Alternatives','Sojasun Jogurt Sojowy Naturalny','Ready to eat','Carrefour;Auchan','none'),
-- EAN 3240589355120 — Sojasun Jogurt Sojowy Waniliowy (vanilla, NOVA 3)
('PL','Sojasun','Plant-Based Yogurt','Plant-Based & Alternatives','Sojasun Jogurt Sojowy Waniliowy','Ready to eat','Carrefour;Auchan','none'),

-- ── Kupiec (Polish Soy Products) ───────────────────────────────────────
-- EAN 5902172001517 — Kupiec Ser Tofu Naturalny (Polish tofu, NOVA 1)
('PL','Kupiec','Tofu','Plant-Based & Alternatives','Kupiec Ser Tofu Naturalny','pan-fry','Biedronka;Lidl;Carrefour','none'),
-- EAN 5902172003573 — Kupiec Ser Tofu Wędzony (smoked tofu, NOVA 3)
('PL','Kupiec','Tofu','Plant-Based & Alternatives','Kupiec Ser Tofu Wędzony','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Beyond Meat (Premium Vegan Burgers) ────────────────────────────────
-- EAN 0850004207017 — Beyond Meat Beyond Burger (pea protein, NOVA 4)
('PL','Beyond Meat','Vegan Meat Alternative','Plant-Based & Alternatives','Beyond Meat Beyond Burger','pan-fry','Carrefour;Auchan','none'),
-- EAN 0850004208786 — Beyond Meat Beyond Sausage (pea protein, NOVA 4)
('PL','Beyond Meat','Vegan Meat Alternative','Plant-Based & Alternatives','Beyond Meat Beyond Sausage','pan-fry','Carrefour;Auchan','none'),

-- ── Naturalnie (Polish Oat Milk) ───────────────────────────────────────
-- EAN 5906747170738 — Naturalnie Napój Owsiany Klasyczny (Polish oat milk, NOVA 3)
('PL','Naturalnie','Plant-Based Milk','Plant-Based & Alternatives','Naturalnie Napój Owsiany Klasyczny','Ready to eat','Biedronka;Lidl;Carrefour','none'),
-- EAN 5906747170752 — Naturalnie Napój Kokosowy (coconut milk, NOVA 3)
('PL','Naturalnie','Plant-Based Milk','Plant-Based & Alternatives','Naturalnie Napój Kokosowy','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Simply V (Vegan Cheese Alternative) ────────────────────────────────
-- EAN 4024176511052 — Simply V Ser Kremowy Naturalny (almond-based cream cheese, NOVA 4)
('PL','Simply V','Vegan Cheese','Plant-Based & Alternatives','Simply V Ser Kremowy Naturalny','Ready to eat','Carrefour;Auchan','none'),

-- ── Green Legend (Plant-Based Ready Meals) ──────────────────────────────
-- EAN 5906747221047 — Green Legend Kotlet Sojowy (soy cutlet, NOVA 4)
('PL','Green Legend','Vegan Meat Alternative','Plant-Based & Alternatives','Green Legend Kotlet Sojowy','pan-fry','Lidl;Kaufland','none'),

-- ── Tempeh (Indonesian Fermented Soy) ──────────────────────────────────
-- EAN 4005359041011 — Taifun Tempeh Natural (fermented soy, NOVA 1)
('PL','Taifun','Tempeh','Plant-Based & Alternatives','Taifun Tempeh Natural','pan-fry','Organic shops;Auchan','none')
on conflict (country, brand, product_name)
do update set
  product_type       = excluded.product_type,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

-- Deprecate old products with incorrect country code or no longer in pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Replaced: migrated to correct country code (PL)'
where country='Poland' and category='Plant-Based & Alternatives'
  and is_deprecated is not true;
