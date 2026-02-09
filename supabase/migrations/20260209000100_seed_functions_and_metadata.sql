-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: Seed functions, sources, and column metadata
-- Consolidates previously ad-hoc scripts into a reproducible migration.
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- 1. assign_confidence() function
-- ───────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.assign_confidence(
    p_data_completeness_pct NUMERIC,
    p_source_type TEXT
) RETURNS TEXT AS $$
BEGIN
    IF p_data_completeness_pct IS NULL THEN
        RETURN 'low';
    END IF;
    IF p_data_completeness_pct < 70 THEN
        RETURN 'low';
    END IF;
    IF p_data_completeness_pct >= 90 THEN
        IF p_source_type = 'openfoodfacts' THEN
            RETURN 'estimated';
        ELSE
            RETURN 'estimated';
        END IF;
    END IF;
    RETURN 'estimated';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION public.assign_confidence IS
'Auto-assigns confidence level based on data completeness percentage and source type.
Returns: verified | estimated | low';

-- ───────────────────────────────────────────────────────────────────────────
-- 2. Sources sequence + seed data (20 categories)
-- ───────────────────────────────────────────────────────────────────────────

CREATE SEQUENCE IF NOT EXISTS public.sources_source_id_seq
  START 1 INCREMENT 1 MINVALUE 1 NO MAXVALUE CACHE 1;

INSERT INTO sources (source_id, brand, source_type, ref, url, notes) VALUES
  (nextval('sources_source_id_seq'), 'Multi-brand (Chips)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=crisps&countries_tags_en=poland',
   'Chip & crisp products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Drinks)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=beverages&countries_tags_en=poland',
   'Beverages from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Cereals)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=breakfast-cereals&countries_tags_en=poland',
   'Breakfast cereals from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Dairy)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=dairies&countries_tags_en=poland',
   'Dairy products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Sweets)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=sweet-snacks&countries_tags_en=poland',
   'Sweets & chocolate from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Meat)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=meats&countries_tags_en=poland',
   'Meat & deli products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Sauces)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=sauces&countries_tags_en=poland',
   'Sauces from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Bread)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=breads&countries_tags_en=poland',
   'Bread products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Instant & Frozen)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=instant-noodles&countries_tags_en=poland',
   'Instant noodles & soups from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Baby)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=baby-foods&countries_tags_en=poland',
   'Baby food & formula from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Alcohol)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=beers&countries_tags_en=poland',
   'Alcohol & beer products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Żabka)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=meals&countries_tags_en=poland',
   'Żabka convenience store products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Breakfast & Grain-Based)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=breakfasts&countries_tags_en=poland',
   'Breakfast & grain-based products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Canned Goods)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=canned-foods&countries_tags_en=poland',
   'Canned goods from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Condiments)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=condiments&countries_tags_en=poland',
   'Condiments from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Frozen & Prepared)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=frozen-foods&countries_tags_en=poland',
   'Frozen & prepared foods from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Nuts, Seeds & Legumes)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=nuts&countries_tags_en=poland',
   'Nuts, seeds & legumes from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Plant-Based & Alternatives)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=plant-based-foods-and-beverages&countries_tags_en=poland',
   'Plant-based & alternative products from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Seafood & Fish)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=seafood&countries_tags_en=poland',
   'Seafood & fish from Open Food Facts Polish market.'),
  (nextval('sources_source_id_seq'), 'Multi-brand (Snacks)',
   'openfoodfacts', 'Open Food Facts — v2 API, 2026-02-09',
   'https://world.openfoodfacts.org/api/v2/search?categories_tags_en=snacks&countries_tags_en=poland',
   'Snacks from Open Food Facts Polish market.')
ON CONFLICT DO NOTHING;

-- ───────────────────────────────────────────────────────────────────────────
-- 3. Column metadata (data dictionary)
-- ───────────────────────────────────────────────────────────────────────────

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- PRODUCTS
('products', 'product_id',        'Product ID',         'Auto-incrementing primary key.',                                              'bigint',  NULL,   '1+',            '1, 42, 1069',                 'Unique identifier.',                                              'Identity',     1),
('products', 'country',           'Country',            'ISO 3166-1 alpha-2 country code.',                                            'text',    NULL,   'PL',            'PL',                          'Country of sale.',                                                'Identity',     2),
('products', 'brand',             'Brand',              'Manufacturer or brand name.',                                                 'text',    NULL,   NULL,            'Alpro, Mlekovita',            'Brand name as shown on packaging.',                               'Identity',     3),
('products', 'product_name',      'Product Name',       'Full product name including variant.',                                        'text',    NULL,   NULL,            'Alpro Napoj Sojowy Naturalny','Full product name.',                                              'Identity',     4),
('products', 'category',          'Category',           'Food category (20 categories).',                                              'text',    NULL,   '20 categories', 'Dairy, Chips, Meat, Drinks',  'Food group classification.',                                      'Identity',     5),
('products', 'product_type',      'Product Type',       'Subtype within category.',                                                    'text',    NULL,   NULL,            'yogurt, beer',                'Specific product subtype.',                                       'Identity',     6),
('products', 'ean',               'EAN Barcode',        'European Article Number (barcode).',                                           'text',    NULL,   '8-13 digits',   '5900512345678',               'Barcode number.',                                                 'Identity',     7),
('products', 'prep_method',       'Preparation Method', 'How the product is typically prepared.',                                       'text',    NULL,   NULL,            'fried, baked, ready to eat',  'How to prepare this product.',                                    'Product Info', 8),
('products', 'store_availability','Store Availability',  'Polish retail chains where spotted.',                                         'text',    NULL,   NULL,            'Biedronka, Lidl, Żabka',     'Which stores carry this product.',                                'Product Info', 9),
('products', 'controversies',     'Controversies',      'Known ingredient concerns.',                                                  'text',    NULL,   'none / palm oil','none, palm oil',             'Flags controversial ingredients.',                                'Product Info', 10),
('products', 'is_deprecated',     'Deprecated?',        'Whether this product row has been superseded.',                                'boolean', NULL,   'true / false',  'false',                       'Deprecated products are hidden from views.',                      'System',       11),
('products', 'deprecated_reason', 'Deprecation Reason', 'Why the product was deprecated.',                                             'text',    NULL,   NULL,            'Duplicate',                   'Reason for deprecation.',                                         'System',       12)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- SERVINGS
('servings', 'serving_id',         'Serving ID',      'Auto-incrementing primary key.',                      'bigint',  NULL,   '1+',  '1, 100',           'Unique serving identifier.',  'Identity',     1),
('servings', 'product_id',         'Product ID (FK)', 'Foreign key to products table.',                      'bigint',  NULL,   NULL,  NULL,               'Links to parent product.',    'Identity',     2),
('servings', 'serving_basis',      'Serving Basis',   'What the measurement is based on.',                   'text',    NULL,   NULL,  'per 100g, per piece','Standard unit.',             'Product Info', 3),
('servings', 'serving_amount_g_ml','Serving Amount',   'Weight or volume in grams or ml.',                   'numeric', 'g/ml', '0+',  '100, 250, 30',     'Serving size in g or ml.',    'Product Info', 4)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- NUTRITION_FACTS
('nutrition_facts', 'product_id',      'Product ID (FK)', 'Foreign key to products table.',  'bigint',  NULL,   NULL, NULL,              'Links to parent product.',                          'Identity',  1),
('nutrition_facts', 'serving_id',      'Serving ID (FK)', 'Foreign key to servings table.',  'bigint',  NULL,   NULL, NULL,              'Links to serving basis.',                           'Identity',  2),
('nutrition_facts', 'calories',        'Calories',        'Energy per serving.',              'numeric', 'kcal', '0+', '45, 150, 530',    'Kilocalories per serving.',                         'Nutrition', 3),
('nutrition_facts', 'total_fat_g',     'Total Fat',       'Total fat per serving.',           'numeric', 'g',    '0+', '0.5, 12.3, 35.0', 'Total fat in grams.',                               'Nutrition', 4),
('nutrition_facts', 'saturated_fat_g', 'Saturated Fat',   'Saturated fat per serving.',       'numeric', 'g',    '0+', '0.1, 5.2, 18.0',  'Saturated fat: cardiovascular risk factor.',        'Nutrition', 5),
('nutrition_facts', 'trans_fat_g',     'Trans Fat',       'Trans fat per serving.',           'numeric', 'g',    '0+', '0, 0.1, 0.5',     'Trans fat: linked to heart disease.',               'Nutrition', 6),
('nutrition_facts', 'carbs_g',         'Carbohydrates',   'Total carbs per serving.',         'numeric', 'g',    '0+', '5.0, 25.0, 70.0',  'Carbohydrates in grams.',                           'Nutrition', 7),
('nutrition_facts', 'sugars_g',        'Sugars',          'Total sugars per serving.',        'numeric', 'g',    '0+', '0.5, 10.0, 45.0',  'Includes natural and added sugars.',                'Nutrition', 8),
('nutrition_facts', 'fibre_g',         'Fibre',           'Dietary fibre per serving.',       'numeric', 'g',    '0+', '0, 2.5, 8.0',      'Dietary fibre: aids digestion.',                    'Nutrition', 9),
('nutrition_facts', 'protein_g',       'Protein',         'Protein per serving.',             'numeric', 'g',    '0+', '1.0, 8.0, 25.0',   'Protein in grams.',                                'Nutrition', 10),
('nutrition_facts', 'salt_g',          'Salt',            'Salt per serving.',                'numeric', 'g',    '0+', '0.01, 1.2, 3.5',   'High intake linked to hypertension.',               'Nutrition', 11)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- SCORES
('scores', 'product_id',            'Product ID (FK)',          'Foreign key to products table.',                      'bigint',  NULL, NULL,            NULL,                'Links to parent product.',                                     'Identity', 1),
('scores', 'unhealthiness_score',   'Unhealthiness Score',     'Composite score 0-100. Higher = worse.',              'numeric', NULL, '0-100',         '12, 35, 72',        'Higher means less healthy.',                                   'Scoring',  2),
('scores', 'nutri_score_label',     'Nutri-Score',             'EU Nutri-Score grade (A=best, E=worst).',             'text',    NULL, 'A-E / UNKNOWN', 'A, C, E, UNKNOWN',  'A (healthiest) to E (least healthy).',                         'Scoring',  3),
('scores', 'processing_risk',       'Processing Risk',         'Risk level based on industrial processing.',          'text',    NULL, 'Very Low-High',  'Low, Moderate, High','How processed the product is.',                               'Scoring',  4),
('scores', 'nova_classification',   'NOVA Group',              'NOVA food classification (1-4).',                     'text',    NULL, '1-4',           '1, 3, 4',           '1=natural, 2=basic, 3=processed, 4=ultra-processed.',         'Scoring',  5),
('scores', 'high_salt_flag',        'High Salt Flag',          'YES if salt > 1.5g per 100g.',                        'text',    NULL, 'YES / NO',      'YES, NO',           'Flags high-salt products.',                                    'Flags',    6),
('scores', 'high_sugar_flag',       'High Sugar Flag',         'YES if sugars > 12.5g per 100g.',                     'text',    NULL, 'YES / NO',      'YES, NO',           'Flags high-sugar products.',                                   'Flags',    7),
('scores', 'high_sat_fat_flag',     'High Saturated Fat Flag', 'YES if saturated fat > 5g per 100g.',                 'text',    NULL, 'YES / NO',      'YES, NO',           'Flags high saturated fat products.',                           'Flags',    8),
('scores', 'high_additive_load',    'High Additive Load',      'YES if additives > 5.',                               'text',    NULL, 'YES / NO',      'YES, NO',           'Flags products with many additives.',                          'Flags',    9),
('scores', 'scoring_version',       'Scoring Version',         'Version of the scoring algorithm.',                   'text',    NULL, NULL,            'v3.1',              'Which scoring formula version produced these values.',         'System',   10),
('scores', 'scored_at',             'Scored Date',             'Date when scores were last calculated.',               'date',    NULL, NULL,            '2026-02-09',        'When this product was last scored.',                           'System',   11),
('scores', 'data_completeness_pct', 'Data Completeness',       'Percentage of filled nutrition fields.',               'numeric', '%',  '0-100',         '75, 90, 100',       'How complete the source data was.',                            'System',   12),
('scores', 'confidence',            'Confidence Level',        'Confidence in the score.',                             'text',    NULL, 'estimated/low', 'estimated',          'Whether the score is an estimate or fully verified.',          'System',   13)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- INGREDIENTS
('ingredients', 'product_id',      'Product ID (FK)',  'Foreign key to products table.',     'bigint',  NULL, NULL, NULL,                         'Links to parent product.',                        'Identity',     1),
('ingredients', 'ingredients_raw',  'Ingredients Text', 'Raw ingredient list from label.',    'text',    NULL, NULL, 'Mąka pszenna, woda, sól...','Ingredient list, ordered by weight.',              'Product Info', 2),
('ingredients', 'additives_count', 'Additives Count',  'Number of E-number additives.',      'integer', NULL, '0+', '0, 3, 12',                   'How many E-number additives detected.',            'Product Info', 3)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- SOURCES
('sources', 'source_id',   'Source ID',   'Auto-incrementing primary key.',       'bigint', NULL, '1+',  '1, 5',                          'Unique source identifier.',            'Identity',     1),
('sources', 'brand',       'Brand',       'Brand associated with this source.',   'text',   NULL, NULL,  'Multi-brand (Chips)',            'Which brand this source relates to.',   'Identity',     2),
('sources', 'source_type', 'Source Type', 'Type of data source.',                 'text',   NULL, NULL,  'openfoodfacts',                  'Where the data came from.',            'Product Info', 3),
('sources', 'ref',         'Reference',   'Short reference identifier.',          'text',   NULL, NULL,  'Open Food Facts — v2 API',       'Brief reference name.',                'Product Info', 4),
('sources', 'url',         'URL',         'Full URL to the data source.',         'text',   NULL, NULL,  'https://world.openfoodfacts.org','Link to the original data source.',    'Product Info', 5),
('sources', 'notes',       'Notes',       'Freeform notes about the source.',     'text',   NULL, NULL,  'Polish market entries',          'Additional context about data.',        'Product Info', 6)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;
