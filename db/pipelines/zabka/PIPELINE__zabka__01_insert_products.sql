-- PIPELINE (ŻABKA): insert products
-- PIPELINE__zabka__01_insert_products.sql
-- 28 verified products sold at Żabka convenience stores in Poland.
-- Brands: Żabka (own-label), Szamamm (ready-meal sub-brand),
--         Tomcio Paluch (sandwich supplier exclusive to Żabka).
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Note: After pipeline load, migration 20260311000300 reclassifies these
-- products to 'Frozen & Prepared' and links them to the Żabka store.
-- Last updated: 2026-02-28

-- 0a. Release EANs across ALL categories to prevent unique constraint conflicts
UPDATE products SET ean = NULL
WHERE ean IN ('2050000645372','2050000554995','5908308910043','5908308910791','5903738866274','5903111184766','5908308908729','2040100470387','5903548012045','8586020103553','8586020104505','5903111184339','5901398082379','04998358','5908308902093','06638993','2050000557415','5908308911019','5908308911637','8586020100064','8586015136382','8586015136399','8586020103768','8586020105540','00719063','5908308911309','5900757067941')
  AND ean IS NOT NULL;

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
-- ── Żabka own-brand burgers ─────────────────────────────────────────────
('PL','Żabka','Ready-to-eat','Żabka','Meksykaner','fried','Żabka','none','2050000645372'),
('PL','Żabka','Ready-to-eat','Żabka','Kurczaker','fried','Żabka','none','2050000554995'),
('PL','Żabka','Ready-to-eat','Żabka','Wołowiner Ser Kozi','fried','Żabka','minor','5908308910043'),
('PL','Żabka','Ready-to-eat','Żabka','Burger Kibica','fried','Żabka','none','5908308910791'),

-- ── Żabka wraps & kebabs ───────────────────────────────────────────────
('PL','Żabka','Ready-to-eat','Żabka','Falafel Rollo','fried','Żabka','none','5903738866274'),
('PL','Żabka','Ready-to-eat','Żabka','Kajzerka Kebab','fried','Żabka','none','5903111184766'),

-- ── Żabka paninis ───────────────────────────────────────────────────────
('PL','Żabka','Ready-to-eat','Żabka','Panini z serem cheddar','baked','Żabka','none','5908308908729'),
('PL','Żabka','Ready-to-eat','Żabka','Panini z kurczakiem','baked','Żabka','none','2040100470387'),

-- ── Żabka snacks ────────────────────────────────────────────────────────
('PL','Żabka','Ready-to-eat','Żabka','Kulki owsiane z czekoladą','baked','Żabka','none','5903548012045'),

-- ── Tomcio Paluch sandwiches (Żabka-exclusive supplier) ─────────────────
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Szynka & Jajko','baked','Żabka','minor','8586020103553'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Pieczony bekon, sałata, jajko','baked','Żabka','minor','8586020104505'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Bajgiel z salami','baked','Żabka','none','5903111184339'),

-- ── Szamamm ready meals (Żabka's food-service brand) ────────────────────
('PL','Szamamm','Ready-to-eat','Żabka','Naleśniki z jabłkami i cynamonem','baked','Żabka','none','5901398082379'),
('PL','Szamamm','Ready-to-eat','Żabka','Placki ziemniaczane','fried','Żabka','none','04998358'),
('PL','Szamamm','Ready-to-eat','Żabka','Penne z kurczakiem','baked','Żabka','none','5908308902093'),
('PL','Szamamm','Ready-to-eat','Żabka','Kotlet de Volaille','fried','Żabka','none','06638993'),

-- ══════════════════════════════════════════════════════════════════════════
-- BATCH 2 (2026-02-08, 12 products)
-- ══════════════════════════════════════════════════════════════════════════

-- ── Żabka own-brand (new) ────────────────────────────────────────────────
('PL','Żabka','Ready-to-eat','Żabka','Wegger','baked','Żabka','none','2050000557415'),
('PL','Żabka','Ready-to-eat','Żabka','Bao Burger','baked','Żabka','none','5908308911019'),
('PL','Żabka','Ready-to-eat','Żabka','Wieprzowiner','fried','Żabka','none','5908308911637'),

-- ── Tomcio Paluch sandwiches (new) ──────────────────────────────────────
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Kanapka Cezar','none','Żabka','none','8586020100064'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Kebab z kurczaka','baked','Żabka','none','8586015136382'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','BBQ Strips','baked','Żabka','none','8586015136399'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','Pasta jajeczna, por, jajko gotowane','none','Żabka','none','8586020103768'),
('PL','Tomcio Paluch','Ready-to-eat','Żabka','High 24g protein','none','Żabka','minor','8586020105540'),

-- ── Szamamm ready meals (new) ───────────────────────────────────────────
('PL','Szamamm','Ready-to-eat','Żabka','Pierogi ruskie ze smażoną cebulką','fried','Żabka','none','00719063'),
('PL','Szamamm','Ready-to-eat','Żabka','Gnocchi z kurczakiem','baked','Żabka','none','5908308911309'),
('PL','Szamamm','Ready-to-eat','Żabka','Panierowane skrzydełka z kurczaka','fried','Żabka','none','5900757067941'),
-- Kotlet Drobiowy — OFF code 10471346 fails EAN-8 checksum, no valid EAN
('PL','Szamamm','Ready-to-eat','Żabka','Kotlet Drobiowy','fried','Żabka','none',NULL)

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
