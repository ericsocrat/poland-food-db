-- PIPELINE (PLANT-BASED): insert products
-- PIPELINE__plant-based__01_insert_products.sql
-- 28 plant-based and alternative products from the Polish market (EANs removed - unverifiable).
-- Data sourced from Open Food Facts (openfoodfacts.org).
-- Last updated: 2026-02-08
-- NOTE: EAN codes removed on 2026-02-08 due to 37% checksum failure rate and inability to verify via Open Food Facts

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Alpro (Soy & Oat Milk Leader) ──────────────────────────────────────
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Sojowy Naturalny','Ready to eat','Biedronka;Lidl;Carrefour;Żabka','none'),
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Owsiany Naturalny','Ready to eat','Biedronka;Lidl;Carrefour;Żabka','none'),
('PL','Alpro','Plant-Based Yogurt','Plant-Based & Alternatives','Alpro Jogurt Sojowy Naturalny','Ready to eat','Biedronka;Lidl;Carrefour','none'),
('PL','Alpro','Plant-Based Milk','Plant-Based & Alternatives','Alpro Napój Migdałowy Niesłodzony','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Garden Gourmet (Nestlé Vegan Meat Alternatives) ────────────────────
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Sensational Burger','pan-fry','Biedronka;Carrefour;Auchan','none'),
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Nuggets','oven-baked','Biedronka;Carrefour;Auchan','none'),
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Mince','pan-fry','Biedronka;Carrefour;Auchan','none'),
('PL','Garden Gourmet','Vegan Meat Alternative','Plant-Based & Alternatives','Garden Gourmet Vegan Schnitzel','pan-fry','Biedronka;Carrefour','none'),

-- ── Violife (Leading Vegan Cheese) ─────────────────────────────────────
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Original Block','Ready to eat','Carrefour;Auchan;Organic shops','none'),
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Mozzarella Style Shreds','Ready to eat','Carrefour;Auchan;Organic shops','none'),
('PL','Violife','Vegan Cheese','Plant-Based & Alternatives','Violife Cheddar Slices','Ready to eat','Carrefour;Auchan;Organic shops','none'),

-- ── Taifun (Organic Tofu Producer) ─────────────────────────────────────
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Natural','pan-fry','Organic shops;Auchan','none'),
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Smoked','Ready to eat','Organic shops;Auchan','none'),
('PL','Taifun','Tofu','Plant-Based & Alternatives','Taifun Tofu Rosso','pan-fry','Organic shops;Auchan','none'),

-- ── LikeMeat (Plant-Based Meat Range) ──────────────────────────────────
('PL','LikeMeat','Vegan Meat Alternative','Plant-Based & Alternatives','LikeMeat Like Chicken Pieces','pan-fry','Lidl;Kaufland','none'),
('PL','LikeMeat','Vegan Meat Alternative','Plant-Based & Alternatives','LikeMeat Like Kebab','pan-fry','Lidl;Kaufland','none'),

-- ── Sojasun (Soy Yogurt Specialist) ────────────────────────────────────
('PL','Sojasun','Plant-Based Yogurt','Plant-Based & Alternatives','Sojasun Jogurt Sojowy Naturalny','Ready to eat','Carrefour;Auchan','none'),
('PL','Sojasun','Plant-Based Yogurt','Plant-Based & Alternatives','Sojasun Jogurt Sojowy Waniliowy','Ready to eat','Carrefour;Auchan','none'),

-- ── Kupiec (Polish Soy Products) ───────────────────────────────────────
('PL','Kupiec','Tofu','Plant-Based & Alternatives','Kupiec Ser Tofu Naturalny','pan-fry','Biedronka;Lidl;Carrefour','none'),
('PL','Kupiec','Tofu','Plant-Based & Alternatives','Kupiec Ser Tofu Wędzony','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Beyond Meat (Premium Vegan Burgers) ────────────────────────────────
('PL','Beyond Meat','Vegan Meat Alternative','Plant-Based & Alternatives','Beyond Meat Beyond Burger','pan-fry','Carrefour;Auchan','none'),
('PL','Beyond Meat','Vegan Meat Alternative','Plant-Based & Alternatives','Beyond Meat Beyond Sausage','pan-fry','Carrefour;Auchan','none'),

-- ── Naturalnie (Polish Oat Milk) ───────────────────────────────────────
('PL','Naturalnie','Plant-Based Milk','Plant-Based & Alternatives','Naturalnie Napój Owsiany Klasyczny','Ready to eat','Biedronka;Lidl;Carrefour','none'),
('PL','Naturalnie','Plant-Based Milk','Plant-Based & Alternatives','Naturalnie Napój Kokosowy','Ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── Simply V (Vegan Cheese Alternative) ────────────────────────────────
('PL','Simply V','Vegan Cheese','Plant-Based & Alternatives','Simply V Ser Kremowy Naturalny','Ready to eat','Carrefour;Auchan','none'),

-- ── Green Legend (Plant-Based Ready Meals) ──────────────────────────────
('PL','Green Legend','Vegan Meat Alternative','Plant-Based & Alternatives','Green Legend Kotlet Sojowy','pan-fry','Lidl;Kaufland','none'),

-- ── Tempeh (Indonesian Fermented Soy) ──────────────────────────────────
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
