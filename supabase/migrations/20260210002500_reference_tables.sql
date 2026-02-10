-- Migration: Reference Tables
-- Date: 2026-02-10
-- Purpose: Create four typed reference tables to replace inline CHECK constraints
--          with FK-backed lookups that carry metadata (descriptions, sort order, display info).
--          Existing CHECK constraints are preserved for belt-and-suspenders validation.

BEGIN;

-- ============================================================
-- 1. country_ref — ISO 3166-1 alpha-2 country codes
-- ============================================================
CREATE TABLE IF NOT EXISTS public.country_ref (
    country_code  text PRIMARY KEY,          -- ISO 3166-1 alpha-2 (e.g. 'PL')
    country_name  text NOT NULL,             -- Full English name
    native_name   text,                      -- Name in local language
    currency_code text,                      -- ISO 4217 (e.g. 'PLN')
    is_active     boolean NOT NULL DEFAULT true,
    notes         text
);

COMMENT ON TABLE public.country_ref IS 'Reference table for ISO 3166-1 alpha-2 country codes. Currently PL only; designed for multi-country expansion.';

INSERT INTO public.country_ref (country_code, country_name, native_name, currency_code, is_active, notes) VALUES
    ('PL', 'Poland', 'Polska', 'PLN', true, 'Primary market. All 560 products.');

-- FK: products.country → country_ref.country_code
ALTER TABLE public.products
    ADD CONSTRAINT fk_products_country
    FOREIGN KEY (country) REFERENCES public.country_ref(country_code);


-- ============================================================
-- 2. category_ref — Product category master list
-- ============================================================
CREATE TABLE IF NOT EXISTS public.category_ref (
    category        text PRIMARY KEY,        -- Exact category name as used in products table
    display_name    text NOT NULL,           -- UI-friendly display name
    description     text,                    -- What this category covers
    parent_category text,                    -- For future hierarchy (nullable)
    sort_order      integer NOT NULL DEFAULT 0,
    icon_emoji      text,                    -- Optional emoji for UI
    is_active       boolean NOT NULL DEFAULT true,
    target_per_category integer NOT NULL DEFAULT 28,
    notes           text
);

COMMENT ON TABLE public.category_ref IS 'Reference table for product categories. 20 active categories, each with 28 products. Provides display metadata and hierarchy support.';

INSERT INTO public.category_ref (category, display_name, description, sort_order, icon_emoji, target_per_category) VALUES
    ('Alcohol',                    'Alcohol',                    'Beer, wine, spirits, and alcoholic beverages',          1,  '🍺', 28),
    ('Baby',                       'Baby Food',                  'Baby formula, purees, snacks, and child nutrition',     2,  '👶', 28),
    ('Bread',                      'Bread',                      'Bread loaves, rolls, and bakery products',             3,  '🍞', 28),
    ('Breakfast & Grain-Based',    'Breakfast & Grain-Based',    'Granola, muesli, porridge, pancakes, and breakfast bars', 4, '🥣', 28),
    ('Canned Goods',               'Canned Goods',               'Canned vegetables, beans, soups, and preserves',       5,  '🥫', 28),
    ('Cereals',                    'Cereals',                    'Breakfast cereals, flakes, and puffed grains',          6,  '🥣', 28),
    ('Chips',                      'Chips',                      'Potato chips, crisps, and extruded snacks',            7,  '🍟', 28),
    ('Condiments',                 'Condiments',                 'Mustard, ketchup, mayonnaise, vinegar, and pickles',   8,  '🫙', 28),
    ('Dairy',                      'Dairy',                      'Milk, yogurt, cheese, butter, and cream',              9,  '🧀', 28),
    ('Drinks',                     'Drinks',                     'Soft drinks, juices, energy drinks, and water',        10, '🥤', 28),
    ('Frozen & Prepared',          'Frozen & Prepared',          'Frozen meals, pizza, dumplings, and prepared foods',   11, '🧊', 28),
    ('Instant & Frozen',           'Instant & Frozen',           'Instant noodles, soups, frozen convenience foods',     12, '🍜', 28),
    ('Meat',                       'Meat',                       'Fresh meat, deli, sausages, and cured meats',          13, '🥩', 28),
    ('Nuts, Seeds & Legumes',      'Nuts, Seeds & Legumes',      'Nuts, seeds, dried legumes, and nut butters',          14, '🥜', 28),
    ('Plant-Based & Alternatives', 'Plant-Based & Alternatives', 'Tofu, tempeh, plant milk, meat alternatives',         15, '🌱', 28),
    ('Sauces',                     'Sauces',                     'Pasta sauces, cooking sauces, and dressings',          16, '🫗', 28),
    ('Seafood & Fish',             'Seafood & Fish',             'Fresh fish, canned fish, seafood, and fish products',  17, '🐟', 28),
    ('Snacks',                     'Snacks',                     'Crackers, pretzels, popcorn, and mixed snacks',        18, '🍿', 28),
    ('Sweets',                     'Sweets',                     'Chocolate, candy, gummies, and confectionery',         19, '🍫', 28),
    ('Żabka',                      'Żabka Convenience',          'Ready meals and snacks from Żabka convenience stores', 20, '🏪', 28);

-- FK: products.category → category_ref.category
ALTER TABLE public.products
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (category) REFERENCES public.category_ref(category);


-- ============================================================
-- 3. nutri_score_ref — Nutri-Score label definitions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.nutri_score_ref (
    label           text PRIMARY KEY,        -- A, B, C, D, E, UNKNOWN, NOT-APPLICABLE
    display_name    text NOT NULL,           -- Full display label
    description     text NOT NULL,           -- What this grade means
    color_hex       text,                    -- Brand color for UI
    sort_order      integer NOT NULL,        -- A=1 (best) → E=5 (worst)
    score_range_min integer,                 -- Nutri-Score point range start (nullable for UNKNOWN)
    score_range_max integer                  -- Nutri-Score point range end
);

COMMENT ON TABLE public.nutri_score_ref IS 'Reference table for Nutri-Score labels (A–E + UNKNOWN/NOT-APPLICABLE). Provides display metadata and grade definitions per EU regulation.';

INSERT INTO public.nutri_score_ref (label, display_name, description, color_hex, sort_order, score_range_min, score_range_max) VALUES
    ('A',              'Nutri-Score A', 'Highest nutritional quality',                '#038141', 1, -15, -1),
    ('B',              'Nutri-Score B', 'Good nutritional quality',                   '#85BB2F', 2,   0,  2),
    ('C',              'Nutri-Score C', 'Average nutritional quality',                '#FECB02', 3,   3, 10),
    ('D',              'Nutri-Score D', 'Below average nutritional quality',          '#EE8100', 4,  11, 18),
    ('E',              'Nutri-Score E', 'Lowest nutritional quality',                 '#E63E11', 5,  19, 40),
    ('UNKNOWN',        'Unknown',       'Nutri-Score could not be computed',          '#999999', 6, NULL, NULL),
    ('NOT-APPLICABLE', 'N/A',           'Product exempt from Nutri-Score (e.g. alcohol)', '#CCCCCC', 7, NULL, NULL);

-- FK: scores.nutri_score_label → nutri_score_ref.label
ALTER TABLE public.scores
    ADD CONSTRAINT fk_scores_nutri_score
    FOREIGN KEY (nutri_score_label) REFERENCES public.nutri_score_ref(label);


-- ============================================================
-- 4. concern_tier_ref — EFSA ingredient concern tiers
-- ============================================================
CREATE TABLE IF NOT EXISTS public.concern_tier_ref (
    tier            integer PRIMARY KEY,     -- 0, 1, 2, 3
    tier_name       text NOT NULL,           -- Human-readable tier name
    description     text NOT NULL,           -- What this tier means
    score_impact    text NOT NULL,           -- How it affects the unhealthiness score
    example_ingredients text,                -- Representative examples
    efsa_guidance   text                     -- EFSA reference or guidance note
);

COMMENT ON TABLE public.concern_tier_ref IS 'Reference table for EFSA ingredient concern tiers (0–3). Documents scoring impact and provides examples for each tier.';

INSERT INTO public.concern_tier_ref (tier, tier_name, description, score_impact, example_ingredients, efsa_guidance) VALUES
    (0, 'No concern',   'Generally recognized as safe; no adverse EFSA findings',
     'No penalty (0 points)', 'Water, salt, sugar, flour, olive oil, milk, eggs',
     'EFSA panel: no safety concerns at typical dietary levels'),
    (1, 'Low concern',  'Minor flags in literature; safe at normal intake levels',
     'Minimal penalty (+0.5 per ingredient)', 'Lecithins (E322), citric acid (E330), pectin (E440), ascorbic acid (E300)',
     'EFSA re-evaluation: acceptable daily intake established, no reduction needed'),
    (2, 'Moderate concern', 'EFSA has identified potential risks at high intake; ADI established',
     'Moderate penalty (+1.5 per ingredient)', 'Carrageenan (E407), sodium nitrite (E250), potassium sorbate (E202), BHA (E320)',
     'EFSA re-evaluation: ADI set; concerns at levels exceeding ADI in vulnerable populations'),
    (3, 'High concern', 'EFSA has flagged for re-evaluation or reduced ADI; avoid where possible',
     'High penalty (+3.0 per ingredient)', 'Titanium dioxide (E171), azodicarbonamide, partially hydrogenated oils',
     'EFSA 2021: E171 no longer considered safe as food additive; banned in EU from 2022');

-- FK: ingredient_ref.concern_tier → concern_tier_ref.tier
ALTER TABLE public.ingredient_ref
    ADD CONSTRAINT fk_ingredient_concern_tier
    FOREIGN KEY (concern_tier) REFERENCES public.concern_tier_ref(tier);


-- ============================================================
-- 5. Update v_master to join reference tables for display metadata
-- ============================================================
-- Note: v_master already exposes the raw values (category, nutri_score_label, etc.)
-- which now serve as FK columns. Reference table metadata is available via
-- simple JOINs when needed. We do NOT add all ref columns to v_master to avoid
-- bloating the view — consumers can join as needed:
--   SELECT m.*, cr.description AS category_description, cr.icon_emoji
--   FROM v_master m
--   JOIN category_ref cr ON cr.category = m.category;

COMMIT;
