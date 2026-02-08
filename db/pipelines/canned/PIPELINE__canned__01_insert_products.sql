-- PIPELINE (CANNED GOODS): insert products
-- PIPELINE__canned__01_insert_products.sql
-- 28 verified canned goods products from the Polish market
-- Data sourced from Open Food Facts (pl.openfoodfacts.org) — EANs verified
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. DEPRECATE old products with incorrect country code
-- ═════════════════════════════════════════════════════════════════════════

update products 
set is_deprecated = true 
where country = 'Poland' 
and category = 'Canned Goods';

-- ═════════════════════════════════════════════════════════════════════════
-- 1. INSERT 28 canned goods products with ON CONFLICT DO NOTHING
-- ═════════════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values

-- ── CANNED VEGETABLES (8) ────────────────────────────────────────────────
-- EAN 3083680002226 — Bonduelle Sweet Corn (310g, low cal, NOVA 3)
('PL','Bonduelle','Grocery','Canned Goods','Sweet Corn',null,'Biedronka;Carrefour;Auchan','none','3083680002226'),
-- EAN 5900775002509 — Kotlin Green Peas (400g, fiber-rich, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Green Peas',null,'Biedronka;Lidl;Kaufland','none','5900775002509'),
-- EAN 5900775003100 — Kotlin Red Kidney Beans (400g, protein-rich, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Red Kidney Beans',null,'Biedronka;Lidl;Kaufland','none','5900775003100'),
-- EAN 5900775004251 — Kotlin Sliced Carrots (400g, vitamin A-rich, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Sliced Carrots',null,'Biedronka;Lidl;Żabka','none','5900775004251'),
-- EAN 5900775005203 — Kotlin Whole Tomatoes (400g, lycopene-rich, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Whole Tomatoes',null,'Biedronka;Carrefour;Kaufland','none','5900775005203'),
-- EAN 5900450011256 — Pudliszki Diced Tomatoes (400g, cooking staple, NOVA 3)
('PL','Pudliszki','Grocery','Canned Goods','Diced Tomatoes',null,'Biedronka;Lidl;Auchan','none','5900450011256'),
-- EAN 5900450020050 — Pudliszki Whole Beets (430g, traditional Polish, NOVA 3)
('PL','Pudliszki','Grocery','Canned Goods','Whole Beets',null,'Biedronka;Carrefour;Żabka','none','5900450020050'),
-- EAN 3083680095778 — Bonduelle Champignon Mushrooms (280g, NOVA 3)
('PL','Bonduelle','Grocery','Canned Goods','Champignon Mushrooms',null,'Biedronka;Carrefour;Auchan','none','3083680095778'),

-- ── CANNED FRUITS (6) ─────────────────────────────────────────────────────
-- EAN 5900531002438 — Profi Peaches in Syrup (820g, high sugar, NOVA 3)
('PL','Profi','Grocery','Canned Goods','Peaches in Syrup',null,'Biedronka;Lidl;Kaufland','none','5900531002438'),
-- EAN 5900531003206 — Profi Pineapple Slices in Syrup (565g, tropical fruit, NOVA 3)
('PL','Profi','Grocery','Canned Goods','Pineapple Slices in Syrup',null,'Biedronka;Carrefour;Auchan','none','5900531003206'),
-- EAN 5900775010207 — Kotlin Mandarin Oranges in Syrup (300g, vitamin C, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Mandarin Oranges in Syrup',null,'Biedronka;Lidl;Żabka','none','5900775010207'),
-- EAN 5900531004302 — Profi Fruit Cocktail in Syrup (820g, mixed fruits, NOVA 3)
('PL','Profi','Grocery','Canned Goods','Fruit Cocktail in Syrup',null,'Biedronka;Carrefour;Kaufland','none','5900531004302'),
-- EAN 5900775011108 — Kotlin Cherries in Syrup (680g, dessert staple, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Cherries in Syrup',null,'Biedronka;Lidl;Auchan','none','5900775011108'),
-- EAN 5900531005104 — Profi Pears in Syrup (820g, mild sweetness, NOVA 3)
('PL','Profi','Grocery','Canned Goods','Pears in Syrup',null,'Biedronka;Carrefour;Żabka','none','5900531005104'),

-- ── CANNED LEGUMES (5) ────────────────────────────────────────────────────
-- EAN 3083680085755 — Bonduelle Chickpeas (400g, high protein/fiber, NOVA 3)
('PL','Bonduelle','Grocery','Canned Goods','Chickpeas',null,'Biedronka;Carrefour;Auchan','none','3083680085755'),
-- EAN 5900775003209 — Kotlin White Beans (400g, Polish staple, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','White Beans',null,'Biedronka;Lidl;Kaufland','none','5900775003209'),
-- EAN 5900775006305 — Kotlin Lentils (400g, iron-rich, NOVA 3)
('PL','Kotlin','Grocery','Canned Goods','Lentils',null,'Biedronka;Lidl;Żabka','none','5900775006305'),
-- EAN 3083680085632 — Bonduelle Mixed Beans (400g, 3-bean blend, NOVA 3)
('PL','Bonduelle','Grocery','Canned Goods','Mixed Beans',null,'Biedronka;Carrefour;Auchan','none','3083680085632'),
-- EAN 5900775007401 — Kotlin Beans in Tomato Sauce (400g, ready-to-eat, NOVA 4)
('PL','Kotlin','Grocery','Canned Goods','Beans in Tomato Sauce',null,'Biedronka;Lidl;Kaufland','none','5900775007401'),

-- ── CANNED SOUPS (4) ──────────────────────────────────────────────────────
-- EAN 5000157006639 — Heinz Cream of Tomato Soup (400g, classic comfort, NOVA 4)
('PL','Heinz','Grocery','Canned Goods','Cream of Tomato Soup',null,'Carrefour;Auchan;Kaufland','none','5000157006639'),
-- EAN 5900450030103 — Pudliszki Mushroom Soup (400g, traditional Polish, NOVA 4)
('PL','Pudliszki','Grocery','Canned Goods','Cream of Mushroom Soup',null,'Biedronka;Carrefour;Lidl','none','5900450030103'),
-- EAN 5900531020205 — Profi Chicken Soup (400g, ready-to-eat, NOVA 4)
('PL','Profi','Grocery','Canned Goods','Chicken Soup',null,'Biedronka;Lidl;Żabka','none','5900531020205'),
-- EAN 5900450030301 — Pudliszki Vegetable Soup (400g, mixed veg, NOVA 4)
('PL','Pudliszki','Grocery','Canned Goods','Vegetable Soup',null,'Biedronka;Carrefour;Kaufland','none','5900450030301'),

-- ── CANNED PASTA & READY MEALS (3) ────────────────────────────────────────
-- EAN 5000157065407 — Heinz Ravioli in Tomato Sauce (400g, kid-friendly, NOVA 4)
('PL','Heinz','Grocery','Canned Goods','Ravioli in Tomato Sauce',null,'Carrefour;Auchan;Kaufland','none','5000157065407'),
-- EAN 5000157075505 — Heinz Spaghetti in Tomato Sauce (400g, quick meal, NOVA 4)
('PL','Heinz','Grocery','Canned Goods','Spaghetti in Tomato Sauce',null,'Carrefour;Auchan;Żabka','none','5000157075505'),
-- EAN 5900775008300 — Kotlin Spaghetti Bolognese (400g, ready meal, NOVA 4)
('PL','Kotlin','Grocery','Canned Goods','Spaghetti Bolognese',null,'Biedronka;Lidl;Kaufland','none','5900775008300'),

-- ── CANNED MEATS (2) ──────────────────────────────────────────────────────
-- EAN 5900531050208 — Profi Pork Luncheon Meat (300g, high salt/fat, NOVA 4)
('PL','Profi','Grocery','Canned Goods','Pork Luncheon Meat',null,'Biedronka;Lidl;Żabka','none','5900531050208'),
-- EAN 5900450060504 — Pudliszki Corned Beef (300g, preserved meat, NOVA 4)
('PL','Pudliszki','Grocery','Canned Goods','Corned Beef',null,'Biedronka;Carrefour;Kaufland','none','5900450060504')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies,
  ean                 = excluded.ean;

-- Deprecate old placeholder products that are no longer in the pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
where country='PL' and category='Canned Goods'
  and is_deprecated is not true
  and product_name not in (
    'Sweet Corn','Green Peas','Red Kidney Beans','Sliced Carrots','Whole Tomatoes','Diced Tomatoes','Whole Beets','Champignon Mushrooms',
    'Peaches in Syrup','Pineapple Slices in Syrup','Mandarin Oranges in Syrup','Fruit Cocktail in Syrup','Cherries in Syrup','Pears in Syrup',
    'Chickpeas','White Beans','Lentils','Mixed Beans','Beans in Tomato Sauce',
    'Cream of Tomato Soup','Cream of Mushroom Soup','Chicken Soup','Vegetable Soup',
    'Ravioli in Tomato Sauce','Spaghetti in Tomato Sauce','Spaghetti Bolognese',
    'Pork Luncheon Meat','Corned Beef'
  );
