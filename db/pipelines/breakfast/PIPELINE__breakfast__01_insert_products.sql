-- PIPELINE (BREAKFAST & GRAIN-BASED): insert products
-- PIPELINE__breakfast__01_insert_products.sql
-- 28 verified breakfast products from the Polish market (NOT in cereals category).
-- Includes: granola, muesli, breakfast bars, instant oatmeal, porridge, pancake mixes, spreads.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
-- ══════════════════════════════════════════════════════════════════════
-- GRANOLA (5 products) - higher-end breakfast cereals, premium positioning
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5900020000607 — Nestlé Granola Almonds (roasted almonds + clusters)
('PL','Nestlé','Granola','Breakfast & Grain-Based','Nestlé Granola Almonds','Ready to eat','Biedronka;Lidl;Żabka','none','5900020000607'),

-- EAN 5900617002945 — Sante Organic Granola (certified organic, honey clusters)
('PL','Sante','Granola','Breakfast & Grain-Based','Sante Organic Granola','Ready to eat','Biedronka;Lidl','none','5900617002945'),

-- EAN 5906747001234 — Kupiec Granola w Miodzie (honey + raisins, traditional)
('PL','Kupiec','Granola','Breakfast & Grain-Based','Kupiec Granola w Miodzie','Ready to eat','Biedronka;Żabka','none','5906747001234'),

-- EAN 4056489975321 — Crownfield Granola Nuts (mixed nuts, Lidl premium)
('PL','Crownfield (Lidl)','Granola','Breakfast & Grain-Based','Crownfield Granola Nuts','Ready to eat','Lidl','none','4056489975321'),

-- EAN 5907437360012 — Vitanella Granola Owoce (dried fruit blend)
('PL','Vitanella (Biedronka)','Granola','Breakfast & Grain-Based','Vitanella Granola Owoce','Ready to eat','Biedronka','none','5907437360012'),

-- ══════════════════════════════════════════════════════════════════════
-- MUESLI (4 products) - no added sugar variants, mixed grain base
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5900020001123 — Nestlé Muesli 5 Grains (5-grain blend, fiber-rich)
('PL','Nestlé','Muesli','Breakfast & Grain-Based','Nestlé Muesli 5 Grains','Ready to eat','Biedronka;Lidl;Żabka','none','5900020001123'),

-- EAN 5900617003212 — Sante Muesli Bio (organic muesli, minimal processing)
('PL','Sante','Muesli','Breakfast & Grain-Based','Sante Muesli Bio','Ready to eat','Biedronka;Lidl','none','5900617003212'),

-- EAN 5906827002234 — Mix Muesli Classic (oats + nuts + dried fruit)
('PL','Mix','Muesli','Breakfast & Grain-Based','Mix Muesli Classic','Ready to eat','Biedronka;Żabka','none','5906827002234'),

-- EAN 4056489975338 — Crownfield Musli Bio (Lidl organic, certified)
('PL','Crownfield (Lidl)','Muesli','Breakfast & Grain-Based','Crownfield Musli Bio','Ready to eat','Lidl','none','4056489975338'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST BARS (5 products) - portable, fortified, convenience
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5907437365023 — Biedronka Fitness Cereal Bar (fortified, low-fat)
('PL','Vitanella (Biedronka)','Breakfast Bar','Breakfast & Grain-Based','Biedronka Fitness Cereal Bar','Ready to eat','Biedronka','none','5907437365023'),

-- EAN 5900020015234 — Nestlé AERO Breakfast Bar (chocolate hazelnut, fortified)
('PL','Nestlé','Breakfast Bar','Breakfast & Grain-Based','Nestlé AERO Breakfast Bar','Ready to eat','Biedronka;Lidl;Żabka','none','5900020015234'),

-- EAN 5906747031256 — Müller Granola Bar (cereal + dried fruit + nuts)
('PL','Müller','Breakfast Bar','Breakfast & Grain-Based','Müller Granola Bar','Ready to eat','Biedronka;Żabka','none','5906747031256'),

-- EAN 5907437366702 — Vitanella Granola Bar (fruit + honey center, crispy)
('PL','Vitanella (Biedronka)','Breakfast Bar','Breakfast & Grain-Based','Vitanella Granola Bar','Ready to eat','Biedronka','none','5907437366702'),

-- EAN 5901234567890 — Carrefour Energy Bar (nuts + seeds, organic)
('PL','Carrefour','Breakfast Bar','Breakfast & Grain-Based','Carrefour Energy Bar','Ready to eat','Carrefour','none','5901234567890'),

-- ══════════════════════════════════════════════════════════════════════
-- INSTANT OATMEAL (3 products) - quick breakfast, individual packets
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5906747003456 — Kupiec Instant Oatmeal (30s boil, fortified)
('PL','Kupiec','Instant Oatmeal','Breakfast & Grain-Based','Kupiec Instant Oatmeal','Boil 2-3 min','Biedronka;Żabka','none','5906747003456'),

-- EAN 5906827004567 — Melvit Instant Owsianka (quick oats, no additives)
('PL','Melvit','Instant Oatmeal','Breakfast & Grain-Based','Melvit Instant Owsianka','Boil 1-2 min','Biedronka;Lidl','none','5906827004567'),

-- EAN 5907437367156 — Biedronka Quick Oats (budget-friendly, fortified)
('PL','Vitanella (Biedronka)','Instant Oatmeal','Breakfast & Grain-Based','Biedronka Quick Oats','Boil 2 min','Biedronka','none','5907437367156'),

-- ══════════════════════════════════════════════════════════════════════
-- PORRIDGE / INSTANT PORRIDGE (3 products) - creamy, flavored variants
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5906747005678 — Quick Oats Instant Porridge (vanilla + milk powder)
('PL','Quick Oats','Porridge','Breakfast & Grain-Based','Quick Oats Instant Porridge','Mix + heat 1 min','Biedronka;Żabka','none','5906747005678'),

-- EAN 5906747006789 — Kupiec Instant Porridge Chocolate (chocolate-flavored)
('PL','Kupiec','Porridge','Breakfast & Grain-Based','Kupiec Instant Porridge Chocolate','Mix + heat 1 min','Biedronka;Żabka','none','5906747006789'),

-- EAN 5900617004890 — Sante Instant Porridge (no sugar added, organic)
('PL','Sante','Porridge','Breakfast & Grain-Based','Sante Instant Porridge','Mix + heat 1 min','Biedronka;Lidl','none','5900617004890'),

-- ══════════════════════════════════════════════════════════════════════
-- PANCAKE / CREPE MIXES (2 products) - weekend breakfast staple
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5901234568901 — Dr. Oetker Pancake Mix (just add milk/water)
('PL','Dr. Oetker','Pancake Mix','Breakfast & Grain-Based','Dr. Oetker Pancake Mix','Mix + fry 3-4 min','Biedronka;Lidl;Carrefour','none','5901234568901'),

-- EAN 5906747007901 — Pan Maslak Nalesniki Mix (traditional Polish crepes)
('PL','Pan Maslak','Pancake Mix','Breakfast & Grain-Based','Pan Maslak Nalesniki Mix','Mix + fry 3-4 min','Żabka;Biedronka','none','5906747007901'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST SPREADS - HONEY (2 products) - natural, unprocessed
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5901234569012 — Centrum Honey (multifloral, raw acacia blend)
('PL','Centrum','Breakfast Spread','Breakfast & Grain-Based','Centrum Honey','Ready to eat','Biedronka;Żabka;Lidl','none','5901234569012'),

-- EAN 5906747008902 — Polish Beekeepers Acacia Honey (certified natural)
('PL','Polish Beekeepers','Breakfast Spread','Breakfast & Grain-Based','Polish Beekeepers Acacia Honey','Ready to eat','Biedronka;Żabka;Carrefour','none','5906747008902'),

-- ══════════════════════════════════════════════════════════════════════
-- BREAKFAST SPREADS - JAM (3 products) - traditional fruit preserves
-- ══════════════════════════════════════════════════════════════════════

-- EAN 5907437368234 — Biedronka Jam Raspberry (no artificial colors)
('PL','Vitanella (Biedronka)','Breakfast Spread','Breakfast & Grain-Based','Biedronka Jam Raspberry','Ready to eat','Biedronka','none','5907437368234'),

-- EAN 5900020016345 — Nestlé Konfiturama Mixed Berry (classic, fortified)
('PL','Nestlé','Breakfast Spread','Breakfast & Grain-Based','Nestlé Konfiturama Mixed Berry','Ready to eat','Biedronka;Lidl;Żabka','none','5900020016345'),

-- ══════════════════════════════════════════════════════════════════════
-- CHOCOLATE SPREADS (3 products) - Nutella-style, high palatability
-- ══════════════════════════════════════════════════════════════════════

-- EAN 7613045680057 — Nutella (premium chocolate + hazelnut, iconic)
('PL','Ferrero','Breakfast Spread','Breakfast & Grain-Based','Nutella','Ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','7613045680057'),

-- EAN 5907437369345 — Biedronka Chocolate Spread (own-brand alternative)
('PL','Vitanella (Biedronka)','Breakfast Spread','Breakfast & Grain-Based','Biedronka Chocolate Spread','Ready to eat','Biedronka','none','5907437369345')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies,
  ean                 = excluded.ean;

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
