-- PIPELINE (ŻABKA): insert products
-- PIPELINE__zabka__01_insert_products.sql
-- 28 verified products sold at Żabka convenience stores in Poland.
-- Brands: Żabka (own-label), Szamamm (ready-meal sub-brand),
--         Tomcio Paluch (sandwich supplier exclusive to Żabka).
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── Żabka own-brand burgers ─────────────────────────────────────────────
-- EAN 2050000645372 — Meksykaner (hamburger with jalapeño, 11 additives, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Meksykaner','fried','Żabka','none'),
-- EAN 2050000554995 — Kurczaker (chicken burger, 12 additives incl. E223 metabisulfite, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Kurczaker','fried','Żabka','none'),
-- EAN 5908308910044 — Wołowiner Ser Kozi (beef + goat cheese, E250 sodium nitrite, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Wołowiner Ser Kozi','fried','Żabka','minor'),
-- EAN 5908308910791 — Burger Kibica (pulled pork BBQ + cheddar, 7 additives, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Burger Kibica','fried','Żabka','none'),

-- ── Żabka wraps & kebabs ───────────────────────────────────────────────
-- EAN 5903738866274 — Falafel Rollo (vegetarian wrap with falafel, 6 additives, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Falafel Rollo','fried','Żabka','none'),
-- EAN 5903111184766 — Kajzerka Kebab (kebab in kaiser roll, Nutri-Score D)
('PL','Żabka','Ready-to-eat','Żabka','Kajzerka Kebab','fried','Żabka','none'),

-- ── Żabka paninis ───────────────────────────────────────────────────────
-- EAN 5908308908729 — Panini z serem cheddar (cheddar panini, 10 additives, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Panini z serem cheddar','baked','Żabka','none'),
-- EAN 2040100470387 — Panini z kurczakiem (chicken panini, 10 additives, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Panini z kurczakiem','baked','Żabka','none'),

-- ── Żabka snacks ────────────────────────────────────────────────────────
-- EAN 5903548012045 — Kulki owsiane z czekoladą (oat balls with chocolate, 1 additive, NOVA 4)
('PL','Żabka','Ready-to-eat','Żabka','Kulki owsiane z czekoladą','baked','Żabka','none'),

-- ── Tomcio Paluch sandwiches (Żabka-exclusive supplier) ─────────────────
-- EAN 8586020103553 — Szynka & Jajko (ham & egg, E250 sodium nitrite, NOVA 4)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Szynka & Jajko','baked','Żabka','minor'),
-- EAN 8586020104505 — Pieczony bekon, sałata, jajko (BLT, E250 nitrite, NOVA 4)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Pieczony bekon, sałata, jajko','baked','Żabka','minor'),
-- EAN 5903111184339 — Bajgiel z salami (salami bagel, cured meat, Nutri-Score D)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Bajgiel z salami','baked','Żabka','none'),

-- ── Szamamm ready meals (Żabka's food-service brand) ────────────────────
-- EAN 5901398082379 — Naleśniki z jabłkami i cynamonem (apple cinnamon crepes, 0 additives, NOVA 4)
('PL','Szamamm','Ready-to-eat','Żabka','Naleśniki z jabłkami i cynamonem','baked','Żabka','none'),
-- EAN 04998358 — Placki ziemniaczane (potato pancakes, 0 additives, NOVA 3)
('PL','Szamamm','Ready-to-eat','Żabka','Placki ziemniaczane','fried','Żabka','none'),
-- EAN 5908308902093 — Penne z kurczakiem (chicken penne with basil & cheddar, Nutri-Score C)
('PL','Szamamm','Ready-to-eat','Żabka','Penne z kurczakiem','baked','Żabka','none'),
-- EAN 06638993 — Kotlet de Volaille (chicken cordon bleu, 0 additives, NOVA 4)
('PL','Szamamm','Ready-to-eat','Żabka','Kotlet de Volaille','fried','Żabka','none'),

-- ══════════════════════════════════════════════════════════════════════════
-- NEW PRODUCTS (batch 2 — 2026-02-08, 12 products)
-- ══════════════════════════════════════════════════════════════════════════

-- ── Żabka own-brand (new) ────────────────────────────────────────────────
-- EAN 2050000557415 — Wegger (vegan burger, Nutri-Score C est., NOVA 4 est.)
('PL','Żabka','Ready-to-eat','Żabka','Wegger','baked','Żabka','none'),
-- EAN 5908308911019 — Bao Burger (bao bun burger, very high salt 2.75g, NOVA 4 est.)
('PL','Żabka','Ready-to-eat','Żabka','Bao Burger','baked','Żabka','none'),
-- EAN 5908308911637 — Wieprzowiner (pork hot snack, Nutri-Score D est., NOVA 4 est.)
('PL','Żabka','Ready-to-eat','Żabka','Wieprzowiner','fried','Żabka','none'),

-- ── Tomcio Paluch sandwiches (new) ──────────────────────────────────────
-- EAN 8586020100064 — Kanapka Cezar (caesar sandwich, Nutri-Score C, NOVA 4 est.)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Kanapka Cezar','none','Żabka','none'),
-- EAN 8586015136382 — Kebab z kurczaka (chicken kebab bread, Nutri-Score D)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Kebab z kurczaka','baked','Żabka','none'),
-- EAN 8586015136399 — BBQ Strips (chicken strips baguette, 14 additives, NOVA 4)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','BBQ Strips','baked','Żabka','none'),
-- EAN 8586020103768 — Pasta jajeczna, por, jajko gotowane (egg paste sandwich, Nutri-Score C)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Pasta jajeczna, por, jajko gotowane','none','Żabka','none'),
-- EAN 8586020105540 — High 24g protein (protein bread sandwich, E250 nitrite, NOVA 4)
('PL','Tomcio Paluch','Ready-to-eat','Żabka','High 24g protein','none','Żabka','minor'),

-- ── Szamamm ready meals (new) ───────────────────────────────────────────
-- EAN 00719063 — Pierogi ruskie ze smażoną cebulką (fried pierogi, NOVA 3 est.)
('PL','Szamamm','Ready-to-eat','Żabka','Pierogi ruskie ze smażoną cebulką','fried','Żabka','none'),
-- EAN 5908308911309 — Gnocchi z kurczakiem (chicken gnocchi, Nutri-Score B est.)
('PL','Szamamm','Ready-to-eat','Żabka','Gnocchi z kurczakiem','baked','Żabka','none'),
-- EAN 5900757067941 — Panierowane skrzydełka z kurczaka (breaded chicken wings, fried)
('PL','Szamamm','Ready-to-eat','Żabka','Panierowane skrzydełka z kurczaka','fried','Żabka','none'),
-- EAN 10471346 — Kotlet Drobiowy (chicken cutlet, Nutri-Score B est.)
('PL','Szamamm','Ready-to-eat','Żabka','Kotlet Drobiowy','fried','Żabka','none')

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
where country='PL' and category='Żabka'
  and is_deprecated is not true
  and (brand, product_name) not in (
    ('Żabka','Meksykaner'),('Żabka','Kurczaker'),
    ('Żabka','Wołowiner Ser Kozi'),('Żabka','Burger Kibica'),
    ('Żabka','Falafel Rollo'),('Żabka','Kajzerka Kebab'),
    ('Żabka','Panini z serem cheddar'),('Żabka','Panini z kurczakiem'),
    ('Żabka','Kulki owsiane z czekoladą'),
    ('Tomcio Paluch','Szynka & Jajko'),
    ('Tomcio Paluch','Pieczony bekon, sałata, jajko'),
    ('Tomcio Paluch','Bajgiel z salami'),
    ('Szamamm','Naleśniki z jabłkami i cynamonem'),
    ('Szamamm','Placki ziemniaczane'),
    ('Szamamm','Penne z kurczakiem'),
    ('Szamamm','Kotlet de Volaille'),
    -- batch 2
    ('Żabka','Wegger'),
    ('Żabka','Bao Burger'),
    ('Żabka','Wieprzowiner'),
    ('Tomcio Paluch','Kanapka Cezar'),
    ('Tomcio Paluch','Kebab z kurczaka'),
    ('Tomcio Paluch','BBQ Strips'),
    ('Tomcio Paluch','Pasta jajeczna, por, jajko gotowane'),
    ('Tomcio Paluch','High 24g protein'),
    ('Szamamm','Pierogi ruskie ze smażoną cebulką'),
    ('Szamamm','Gnocchi z kurczakiem'),
    ('Szamamm','Panierowane skrzydełka z kurczaka'),
    ('Szamamm','Kotlet Drobiowy')
  );
