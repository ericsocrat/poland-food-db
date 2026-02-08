-- POPULATE sources table
-- Create source entries for each category, documenting the data sources used.
-- All categories currently use Open Food Facts (openfoodfacts.org) as their primary source.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Create sequence for source_id (if not exists)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE SEQUENCE IF NOT EXISTS public.sources_source_id_seq
  START 1
  INCREMENT 1
  MINVALUE 1
  NO MAXVALUE
  CACHE 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Populate sources table
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO sources (source_id, brand, source_type, ref, url, notes)
VALUES
  (nextval('sources_source_id_seq'), 'Multi-brand (Chips)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=chips&countries_tags=en:poland&json=1',
   'All 28 chips products (Lay''s, Pringles, Crunchips, Doritos, Cheetos, Top Chips, Snack Day, etc.) verified via Open Food Facts Polish market entries. EANs matched to Polish SKUs.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Drinks)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=drinks&countries_tags=en:poland&json=1',
   'All 28 drinks products (Coca-Cola, Pepsi, Tymbark, Kubuś, water, etc.) verified via Open Food Facts Polish market entries. EANs matched to Polish SKUs. Some fiber values estimated from category averages.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Cereals)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=cereals&countries_tags=en:poland&json=1',
   'All 28 cereals products (Nestlé, Kupiec, Lubella, Crownfield, etc.) verified via Open Food Facts Polish market entries. EANs matched. Some nutrition values estimated where OFF was incomplete.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Dairy)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=dairy&countries_tags=en:poland&json=1',
   '15 dairy products (Danone, Łaciate, Mlekovita, Bakoma, Zott, Hochland, Piątnica) verified via Open Food Facts Polish market. EANs matched. Per 100g nutrition extracted.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Sweets)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=chocolate&countries_tags=en:poland&json=1',
   '28 sweets & chocolate products (Milka, Kinder, Snickers, Wawel, Haribo, Prince Polo, etc.) verified via Open Food Facts Polish market. EANs matched to product variants.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Meat)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=wędliny&countries_tags=en:poland&json=1',
   '26 meat & deli products (wędliny, kielbasa: Sokołów, Morliny, Tarczyński, etc.) verified via Open Food Facts Polish market. EANs matched. Per 100g nutrition.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Sauces)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=sauce&countries_tags=en:poland&json=1',
   '27 sauces & condiments (Heinz, Pudliszki, Łowicz, Develey, etc.) verified via Open Food Facts Polish market. EANs matched. Note: OFF entry for Pudliszki hot sauce had salt value error (corrected from 0.02→1.8g in OFF).'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Bread)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=bread&countries_tags=en:poland&json=1',
   '26 bread products (Chleb żytni, pszeniczny, etc.: Klara, Wasa, Mestemacher, etc.) verified via Open Food Facts Polish market. EANs matched. Per 100g nutrition.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Instant & Frozen)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=instant&countries_tags=en:poland&json=1',
   '26 instant noodles, soups, frozen meals (Knorr, Vifon, Dr. Oetker, FRoSTA, etc.) verified via Open Food Facts Polish market. EANs matched. Values: instant noodles per 100g prepared; frozen products per 100g as packaged.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Baby)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=baby&countries_tags=en:poland&json=1',
   '26 baby food & formula products (Nestlé, HiPP, Gerber, BoboVita, GutBio, Tymbark, etc.) verified via Open Food Facts Polish market. EANs matched. Per 100g nutrition for food; formula nutrition per serving + reconstitution info.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Alcohol)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=beer&countries_tags=en:poland&json=1',
   '26 alcohol & beer products (Tyskie, Żubr, Lech, Okocim, Warka, Carlsberg, etc.) verified via Open Food Facts Polish market. EANs matched. Nutrition per 100ml basis. Alcohol %ABV extracted.'),

  (nextval('sources_source_id_seq'), 'Multi-brand (Żabka)',
   'openfoodfacts', 'Open Food Facts — EAN-verified, 2026-02-08',
   'https://world.openfoodfacts.org/cgi/search.pl?search_terms=żabka&countries_tags=en:poland&json=1',
   '28 Żabka convenience store products (sandwiches, snacks, ready-to-eat: Żabka, Szamamm, Tomcio Paluch brands) verified via Open Food Facts Polish market. EANs matched. Some fiber & micronutrient values estimated.')

ON CONFLICT DO NOTHING;
