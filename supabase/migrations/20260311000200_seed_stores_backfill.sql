-- ==========================================================================
-- Migration: 20260311000200_seed_stores_backfill.sql
-- Purpose:   Seed PL + DE stores into store_ref, backfill
--            product_store_availability from products.store_availability.
--            Part of #350 — Store Architecture.
-- Rollback:  TRUNCATE product_store_availability;
--            TRUNCATE store_ref CASCADE;
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Seed Polish stores (~21)
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO public.store_ref (country, store_name, store_slug, store_type, website_url, sort_order)
VALUES
    ('PL', 'Biedronka',          'biedronka',          'discounter',   'https://www.biedronka.pl',          1),
    ('PL', 'Lidl',               'lidl',               'discounter',   'https://www.lidl.pl',               2),
    ('PL', 'Żabka',              'zabka',              'convenience',  'https://www.zabka.pl',              3),
    ('PL', 'Kaufland',           'kaufland',           'hypermarket',  'https://www.kaufland.pl',           4),
    ('PL', 'Auchan',             'auchan',             'hypermarket',  'https://www.auchan.pl',             5),
    ('PL', 'Dino',               'dino',               'supermarket',  'https://www.marketdino.pl',         6),
    ('PL', 'Carrefour',          'carrefour',          'hypermarket',  'https://www.carrefour.pl',          7),
    ('PL', 'Netto',              'netto',              'discounter',   'https://www.netto.pl',              8),
    ('PL', 'Aldi',               'aldi',               'discounter',   'https://www.aldi.pl',               9),
    ('PL', 'Tesco',              'tesco',              'hypermarket',  'https://www.tesco.pl',             10),
    ('PL', 'Stokrotka',          'stokrotka',          'supermarket',  'https://www.stokrotka.pl',         11),
    ('PL', 'Lewiatan',           'lewiatan',           'supermarket',  NULL,                               12),
    ('PL', 'Penny',              'penny',              'discounter',   'https://www.penny.pl',             13),
    ('PL', 'Dealz',              'dealz',              'discounter',   'https://www.dealz.pl',             14),
    ('PL', 'Selgros',            'selgros',            'hypermarket',  'https://www.selgros.pl',           15),
    ('PL', 'Polska Chata',       'polska-chata',       'supermarket',  NULL,                               16),
    ('PL', 'Mila',               'mila',               'supermarket',  NULL,                               17),
    ('PL', 'Ikea',               'ikea',               'specialty',    'https://www.ikea.com/pl',          18),
    ('PL', 'Rossmann',           'rossmann',           'drugstore',    'https://www.rossmann.pl',          19),
    ('PL', 'Freshmarket',        'freshmarket',        'convenience',  NULL,                               20),
    ('PL', 'Delikatesy Centrum', 'delikatesy-centrum', 'supermarket',  'https://www.delikatesy.pl',       21)
ON CONFLICT (country, store_slug) DO UPDATE SET
    store_name  = EXCLUDED.store_name,
    store_type  = EXCLUDED.store_type,
    website_url = EXCLUDED.website_url,
    sort_order  = EXCLUDED.sort_order;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Seed German stores (~12)
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO public.store_ref (country, store_name, store_slug, store_type, website_url, sort_order)
VALUES
    ('DE', 'Aldi',     'aldi',     'discounter',   'https://www.aldi.de',       1),
    ('DE', 'Lidl',     'lidl',     'discounter',   'https://www.lidl.de',       2),
    ('DE', 'Edeka',    'edeka',    'supermarket',  'https://www.edeka.de',      3),
    ('DE', 'REWE',     'rewe',     'supermarket',  'https://www.rewe.de',       4),
    ('DE', 'Penny',    'penny',    'discounter',   'https://www.penny.de',      5),
    ('DE', 'Netto',    'netto',    'discounter',   'https://www.netto-online.de', 6),
    ('DE', 'Kaufland', 'kaufland', 'hypermarket',  'https://www.kaufland.de',   7),
    ('DE', 'dm',       'dm',       'drugstore',    'https://www.dm.de',         8),
    ('DE', 'Rossmann', 'rossmann', 'drugstore',    'https://www.rossmann.de',   9),
    ('DE', 'Real',     'real',     'hypermarket',  'https://www.real.de',      10),
    ('DE', 'Norma',    'norma',    'discounter',   'https://www.norma-online.de', 11),
    ('DE', 'Tegut',    'tegut',    'supermarket',  'https://www.tegut.com',    12)
ON CONFLICT (country, store_slug) DO UPDATE SET
    store_name  = EXCLUDED.store_name,
    store_type  = EXCLUDED.store_type,
    website_url = EXCLUDED.website_url,
    sort_order  = EXCLUDED.sort_order;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Backfill product_store_availability from products.store_availability
--    Only for non-deprecated PL products with a NON-NULL store value.
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO public.product_store_availability (product_id, store_id, verified_at, source)
SELECT
    p.product_id,
    sr.store_id,
    NOW(),
    'pipeline'
FROM public.products p
JOIN public.store_ref sr
    ON sr.country = p.country
   AND sr.store_name = p.store_availability
WHERE p.store_availability IS NOT NULL
  AND p.is_deprecated = false
ON CONFLICT (product_id, store_id) DO NOTHING;

COMMIT;
