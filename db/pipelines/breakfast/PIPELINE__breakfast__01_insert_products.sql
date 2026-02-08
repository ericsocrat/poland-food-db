-- PIPELINE (BREAKFAST & GRAIN-BASED): insert products
-- PIPELINE__breakfast__01_insert_products.sql
-- 28 breakfast products from the Polish market (EANs removed - unverifiable).
-- Includes: granola, muesli, breakfast bars, instant oatmeal, porridge, pancake mixes, spreads.
-- Data sourced from Open Food Facts (openfoodfacts.org).
-- Last updated: 2026-02-08
-- NOTE: EAN codes removed on 2026-02-08 due to 92% checksum failure rate (25/27 invalid) and inability to verify via Open Food Facts

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ══════════════════════════════════════════════════════════════════════
-- GRANOLA (5 products) - higher-end breakfast cereals, premium positioning
-- ══════════════════════════════════════════════════════════════════════

('PL','Nestlé','Granola','Breakfast & Grain-Based','Nestlé Granola Almonds','Ready to eat','Biedronka;Lidl;Żabka','none'),

('PL','Sante','Granola','Breakfast & Grain-Based','Sante Organic Granola','Ready to eat','Biedronka;Lidl','none'),

('PL','Kupiec','Granola','Breakfast & Grain-Based','Kupiec Granola w Miodzie','Ready to eat','Biedronka;Żabka','none'),

('PL','Crownfield (Lidl)','Granola','Breakfast & Grain-Based','Crownfield Granola Nuts','Ready to eat','Lidl','none'),

('PL','Vitanella (Biedronka)','Granola','Breakfast & Grain-Based','Vitanella Granola Owoce','Ready to eat','Biedronka','none'),

-- ══════════════════════════════════════════════════════════════════════
-- MUESLI (4 products) - no added sugar variants, mixed grain base
-- ══════════════════════════════════════════════════════════════════════

('PL','Nestlé','Muesli','Breakfast & Grain-Based','Nestlé Muesli 5 Grains','Ready to eat','Biedronka;Lidl;Żabka','none'),

('PL','Sante','Muesli','Breakfast & Grain-Based','Sante Muesli Bio','Ready to eat','Biedronka;Lidl','none'),

('PL','Mix','Muesli','Breakfast & Grain-Based','Mix Muesli Classic','Ready to eat','Biedronka;Żabka','none'),

('PL','Crownfield (Lidl)','Muesli','Breakfast & Grain-Based','Crownfield Musli Bio','Ready to eat','Lidl','none'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST BARS (5 products) - portable, fortified, convenience
-- ══════════════════════════════════════════════════════════════════════

('PL','Vitanella (Biedronka)','Breakfast Bar','Breakfast & Grain-Based','Biedronka Fitness Cereal Bar','Ready to eat','Biedronka','none'),

('PL','Nestlé','Breakfast Bar','Breakfast & Grain-Based','Nestlé AERO Breakfast Bar','Ready to eat','Biedronka;Lidl;Żabka','none'),

('PL','Müller','Breakfast Bar','Breakfast & Grain-Based','Müller Granola Bar','Ready to eat','Biedronka;Żabka','none'),

('PL','Vitanella (Biedronka)','Breakfast Bar','Breakfast & Grain-Based','Vitanella Granola Bar','Ready to eat','Biedronka','none'),

('PL','Carrefour','Breakfast Bar','Breakfast & Grain-Based','Carrefour Energy Bar','Ready to eat','Carrefour','none'),

-- ══════════════════════════════════════════════════════════════════════
-- INSTANT OATMEAL (3 products) - quick breakfast, individual packets
-- ══════════════════════════════════════════════════════════════════════

('PL','Kupiec','Instant Oatmeal','Breakfast & Grain-Based','Kupiec Instant Oatmeal','Boil 2-3 min','Biedronka;Żabka','none'),

('PL','Melvit','Instant Oatmeal','Breakfast & Grain-Based','Melvit Instant Owsianka','Boil 1-2 min','Biedronka;Lidl','none'),

('PL','Vitanella (Biedronka)','Instant Oatmeal','Breakfast & Grain-Based','Biedronka Quick Oats','Boil 2 min','Biedronka','none'),

-- ══════════════════════════════════════════════════════════════════════
-- PORRIDGE / INSTANT PORRIDGE (3 products) - creamy, flavored variants
-- ══════════════════════════════════════════════════════════════════════

('PL','Quick Oats','Porridge','Breakfast & Grain-Based','Quick Oats Instant Porridge','Mix + heat 1 min','Biedronka;Żabka','none'),

('PL','Kupiec','Porridge','Breakfast & Grain-Based','Kupiec Instant Porridge Chocolate','Mix + heat 1 min','Biedronka;Żabka','none'),

('PL','Sante','Porridge','Breakfast & Grain-Based','Sante Instant Porridge','Mix + heat 1 min','Biedronka;Lidl','none'),

-- ══════════════════════════════════════════════════════════════════════
-- PANCAKE / CREPE MIXES (2 products) - weekend breakfast staple
-- ══════════════════════════════════════════════════════════════════════

('PL','Dr. Oetker','Pancake Mix','Breakfast & Grain-Based','Dr. Oetker Pancake Mix','Mix + fry 3-4 min','Biedronka;Lidl;Carrefour','none'),

('PL','Pan Maslak','Pancake Mix','Breakfast & Grain-Based','Pan Maslak Nalesniki Mix','Mix + fry 3-4 min','Żabka;Biedronka','none'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST SPREADS - HONEY (2 products) - natural, unprocessed
-- ══════════════════════════════════════════════════════════════════════

('PL','Centrum','Breakfast Spread','Breakfast & Grain-Based','Centrum Honey','Ready to eat','Biedronka;Żabka;Lidl','none'),

('PL','Polish Beekeepers','Breakfast Spread','Breakfast & Grain-Based','Polish Beekeepers Acacia Honey','Ready to eat','Biedronka;Żabka;Carrefour','none'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST SPREADS - JAM (3 products) - traditional fruit preserves
-- ══════════════════════════════════════════════════════════════════════

('PL','Vitanella (Biedronka)','Breakfast Spread','Breakfast & Grain-Based','Biedronka Jam Raspberry','Ready to eat','Biedronka','none'),

('PL','Nestlé','Breakfast Spread','Breakfast & Grain-Based','Nestlé Konfiturama Mixed Berry','Ready to eat','Biedronka;Lidl;Żabka','none'),

-- ══════════════════════════════════════════════════════════════════════
-- CHOCOLATE SPREADS (3 products) - Nutella-style, high palatability
-- ══════════════════════════════════════════════════════════════════════

('PL','Ferrero','Breakfast Spread','Breakfast & Grain-Based','Nutella','Ready to eat','Biedronka;Lidl;Żabka;Carrefour','none'),

('PL','Vitanella (Biedronka)','Breakfast Spread','Breakfast & Grain-Based','Biedronka Chocolate Spread','Ready to eat','Biedronka','none')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies;

-- ══════════════════════════════════════════════════════════════════════
-- DEPRECATION BLOCK: Mark old 'Poland' entries as deprecated
-- ══════════════════════════════════════════════════════════════════════

update products
set is_deprecated = true,
    deprecated_reason = 'Removed: migrated to PL country code (old Poland entries)'
where country='Poland' and category='Breakfast & Grain-Based'
  and is_deprecated is not true
  and product_name not in (
    'Nestlé Granola Almonds','Sante Organic Granola','Kupiec Granola w Miodzie',
    'Crownfield Granola Nuts','Vitanella Granola Owoce',
    'Nestlé Muesli 5 Grains','Sante Muesli Bio','Mix Muesli Classic','Crownfield Musli Bio',
    'Biedronka Fitness Cereal Bar','Nestlé AERO Breakfast Bar','Müller Granola Bar',
    'Vitanella Granola Bar','Carrefour Energy Bar',
    'Kupiec Instant Oatmeal','Melvit Instant Owsianka','Biedronka Quick Oats',
    'Quick Oats Instant Porridge','Kupiec Instant Porridge Chocolate','Sante Instant Porridge',
    'Dr. Oetker Pancake Mix','Pan Maslak Nalesniki Mix',
    'Centrum Honey','Polish Beekeepers Acacia Honey',
    'Biedronka Jam Raspberry','Nestlé Konfiturama Mixed Berry',
    'Nutella','Biedronka Chocolate Spread'
  );

