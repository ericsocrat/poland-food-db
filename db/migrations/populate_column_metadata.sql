-- Populate the column_metadata (data dictionary) table
INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== PRODUCTS TABLE =====
('products', 'product_id',        'Product ID',         'Auto-incrementing primary key for each product.',                                'bigint',  NULL,   '1+',                   '1, 42, 1069',                    'Unique identifier for internal use only.',                        'Identity',     1),
('products', 'country',           'Country',            'ISO 3166-1 alpha-2 country code where the product is sold.',                    'text',    NULL,   'PL',                   'PL',                              'Country of sale. Currently all products are Polish market.',       'Identity',     2),
('products', 'brand',             'Brand',              'Manufacturer or brand name, normalised to official casing.',                    'text',    NULL,   NULL,                   'Alpro, Mlekovita',                'Brand name as shown on packaging.',                               'Identity',     3),
('products', 'product_name',      'Product Name',       'Full product name including brand prefix and variant.',                         'text',    NULL,   NULL,                   'Alpro Napoj Sojowy Naturalny',    'Full product name.',                                              'Identity',     4),
('products', 'category',          'Category',           'Food category assigned by the pipeline (20 categories).',                       'text',    NULL,   '20 categories',        'Dairy, Chips, Meat, Drinks',      'Food group classification.',                                      'Identity',     5),
('products', 'product_type',      'Product Type',       'Specific subtype within a category for finer classification.',                  'text',    NULL,   NULL,                   'yogurt, frozen_pizza, beer',      'Specific product subtype (e.g. yogurt within Dairy).',            'Identity',     6),
('products', 'ean',               'EAN Barcode',        'European Article Number (barcode). 590x = Polish GS1 prefix.',                  'text',    NULL,   '8-13 digits',          '5900512345678',                   'Barcode number. 590 prefix indicates Polish origin.',             'Identity',     7),
('products', 'prep_method',       'Preparation Method', 'How the product is typically prepared or consumed.',                            'text',    NULL,   NULL,                   'fried, baked, ready to eat',      'How to prepare this product.',                                     'Product Info', 8),
('products', 'store_availability','Store Availability',  'Known Polish retail chains where the product has been spotted.',               'text',    NULL,   NULL,                   'Biedronka, Lidl, Zabka',          'Which stores carry this product.',                                'Product Info', 9),
('products', 'controversies',     'Controversies',      'Known ingredient concerns. "none" if clean.',                                   'text',    NULL,   'none / palm oil',      'none, palm oil',                  'Flags controversial ingredients like palm oil.',                  'Product Info', 10),
('products', 'is_deprecated',     'Deprecated?',        'Whether this product row has been superseded or is a duplicate.',               'boolean', NULL,   'true / false',         'false',                           'Deprecated products are hidden from active views.',               'System',       11),
('products', 'deprecated_reason', 'Deprecation Reason', 'Why the product was deprecated (NULL if active).',                              'text',    NULL,   NULL,                   'Duplicate: normalised to PL',     'Reason for deprecation, if applicable.',                          'System',       12)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== SERVINGS TABLE =====
('servings', 'serving_id',         'Serving ID',      'Auto-incrementing primary key for each serving record.',     'bigint',  NULL,   '1+',      '1, 100',           'Unique serving identifier for internal use.',  'Identity',     1),
('servings', 'product_id',         'Product ID (FK)', 'Foreign key linking to the products table.',                 'bigint',  NULL,   NULL,      NULL,               'Links to the parent product.',                 'Identity',     2),
('servings', 'serving_basis',      'Serving Basis',   'What the serving measurement is based on (e.g. per 100g).', 'text',    NULL,   NULL,      'per 100g, per piece','The standard unit this serving represents.',   'Product Info', 3),
('servings', 'serving_amount_g_ml','Serving Amount',   'Weight or volume of one serving in grams or millilitres.', 'numeric', 'g/ml', '0+',      '100, 250, 30',     'Serving size in grams or ml.',                 'Product Info', 4)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== NUTRITION_FACTS TABLE =====
('nutrition_facts', 'product_id',      'Product ID (FK)',  'Foreign key linking to the products table.',              'bigint',  NULL,   NULL, NULL,              'Links to the parent product.',                          'Identity',  1),
('nutrition_facts', 'serving_id',      'Serving ID (FK)',  'Foreign key linking to the servings table.',              'bigint',  NULL,   NULL, NULL,              'Links to the serving basis for these values.',          'Identity',  2),
('nutrition_facts', 'calories',        'Calories',         'Energy content per serving.',                             'numeric', 'kcal', '0+', '45, 150, 530',    'Kilocalories per serving.',                             'Nutrition', 3),
('nutrition_facts', 'total_fat_g',     'Total Fat',        'Total fat content per serving.',                          'numeric', 'g',    '0+', '0.5, 12.3, 35.0', 'Total fat in grams per serving.',                       'Nutrition', 4),
('nutrition_facts', 'saturated_fat_g', 'Saturated Fat',    'Saturated fat content per serving.',                      'numeric', 'g',    '0+', '0.1, 5.2, 18.0',  'Saturated fat: linked to cardiovascular risk.',         'Nutrition', 5),
('nutrition_facts', 'trans_fat_g',     'Trans Fat',        'Trans fat content per serving.',                          'numeric', 'g',    '0+', '0, 0.1, 0.5',     'Trans fat: strongly linked to heart disease.',          'Nutrition', 6),
('nutrition_facts', 'carbs_g',         'Carbohydrates',    'Total carbohydrate content per serving.',                 'numeric', 'g',    '0+', '5.0, 25.0, 70.0',  'Carbohydrates in grams per serving.',                   'Nutrition', 7),
('nutrition_facts', 'sugars_g',        'Sugars',           'Total sugars (natural + added) per serving.',             'numeric', 'g',    '0+', '0.5, 10.0, 45.0',  'Sugars: includes both natural and added sugars.',       'Nutrition', 8),
('nutrition_facts', 'fibre_g',         'Fibre',            'Dietary fibre content per serving.',                      'numeric', 'g',    '0+', '0, 2.5, 8.0',      'Dietary fibre: generally beneficial, aids digestion.',  'Nutrition', 9),
('nutrition_facts', 'protein_g',       'Protein',          'Protein content per serving.',                            'numeric', 'g',    '0+', '1.0, 8.0, 25.0',   'Protein in grams per serving.',                         'Nutrition', 10),
('nutrition_facts', 'salt_g',          'Salt',             'Salt content per serving (calculated from sodium x 2.5).','numeric', 'g',    '0+', '0.01, 1.2, 3.5',   'Salt: high intake linked to hypertension.',             'Nutrition', 11)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== SCORES TABLE =====
('scores', 'product_id',                      'Product ID (FK)',               'Foreign key linking to the products table.',                                'bigint',  NULL, NULL,            NULL,                'Links to the parent product.',                                     'Identity', 1),
('scores', 'unhealthiness_score',              'Unhealthiness Score',           'Composite score 0-100 quantifying overall unhealthiness. Higher = worse.', 'numeric', NULL, '0-100',         '12, 35, 72',        'Higher means less healthy. Combines sugar, fat, salt, processing.', 'Scoring',  2),
('scores', 'nutri_score_label',                'Nutri-Score',                   'EU Nutri-Score grade (A=best, E=worst). UNKNOWN if unavailable.',          'text',    NULL, 'A-E / UNKNOWN', 'A, C, E, UNKNOWN',  'Nutri-Score: A (healthiest) to E (least healthy).',                'Scoring',  3),
('scores', 'processing_risk',                  'Processing Risk',               'Risk level based on degree of industrial processing.',                     'text',    NULL, 'Very Low-High',  'Low, Moderate, High','How processed the product is. Ultra-processed = High.',           'Scoring',  4),
('scores', 'nova_classification',              'NOVA Group',                    'NOVA food classification (1=unprocessed, 4=ultra-processed).',              'text',    NULL, '1-4',           '1, 3, 4',           'NOVA: 1=natural, 2=basic, 3=processed, 4=ultra-processed.',       'Scoring',  5),
('scores', 'high_salt_flag',                   'High Salt Flag',                'YES if salt per 100g exceeds WHO threshold (1.5g).',                       'text',    NULL, 'YES / NO',      'YES, NO',           'Flags products with salt > 1.5g per 100g.',                        'Flags',    6),
('scores', 'high_sugar_flag',                  'High Sugar Flag',               'YES if sugars per 100g exceed WHO threshold (12.5g).',                     'text',    NULL, 'YES / NO',      'YES, NO',           'Flags products with sugars > 12.5g per 100g.',                     'Flags',    7),
('scores', 'high_sat_fat_flag',                'High Saturated Fat Flag',       'YES if saturated fat per 100g exceeds threshold (5g).',                    'text',    NULL, 'YES / NO',      'YES, NO',           'Flags products with saturated fat > 5g per 100g.',                 'Flags',    8),
('scores', 'high_additive_load',               'High Additive Load',            'YES if additive count exceeds threshold (5 additives).',                   'text',    NULL, 'YES / NO',      'YES, NO',           'Flags products with many artificial additives.',                   'Flags',    9),
('scores', 'scoring_version',                  'Scoring Version',               'Version of the scoring algorithm used.',                                   'text',    NULL, NULL,            'v2.2, v3.1',        'Which scoring formula version produced these values.',             'System',   10),
('scores', 'scored_at',                        'Scored Date',                   'Date when the scores were last calculated.',                               'date',    NULL, NULL,            '2025-02-07',        'When this product was last scored.',                                'System',   11),
('scores', 'data_completeness_pct',            'Data Completeness',             'Percentage of available nutrition fields that were filled.',                'numeric', '%',  '0-100',         '75, 90, 100',       'How complete the source data was for scoring.',                    'System',   12),
('scores', 'confidence',                       'Confidence Level',              'Confidence in the score (estimated = partial data, NULL = full data).',    'text',    NULL, 'estimated/NULL','estimated',          'Whether the score is an estimate or based on full data.',          'System',   13)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== INGREDIENTS TABLE =====
('ingredients', 'product_id',      'Product ID (FK)',    'Foreign key linking to the products table.',                              'bigint',  NULL, NULL, NULL,                         'Links to the parent product.',                           'Identity',     1),
('ingredients', 'ingredients_raw',  'Ingredients Text',   'Raw ingredient list as printed on the product label.',                   'text',    NULL, NULL, 'Maka pszenna, woda, sol...', 'Ingredient list from packaging, ordered by weight.',     'Product Info', 2),
('ingredients', 'additives_count', 'Additives Count',    'Number of identified food additives (E-numbers) in the product.',        'integer', NULL, '0+', '0, 3, 12',                   'How many E-number additives were detected.',              'Product Info', 3)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.column_metadata (table_name, column_name, display_label, description, data_type, unit, value_range, example_values, tooltip_text, category_group, sort_order) VALUES
-- ===== SOURCES TABLE =====
('sources', 'source_id',   'Source ID',   'Auto-incrementing primary key for each data source.',   'bigint', NULL, '1+',  '1, 5',                          'Unique source identifier.',            'Identity',     1),
('sources', 'brand',       'Brand',       'Brand associated with this source (NULL if all brands).','text',   NULL, NULL,  'Zabka',                         'Which brand this source relates to.',   'Identity',     2),
('sources', 'source_type', 'Source Type', 'Type of data source (e.g. API, manual, retailer).',     'text',   NULL, NULL,  'OFF API, manual',               'Where the data came from.',             'Product Info', 3),
('sources', 'ref',         'Reference',   'Short reference identifier or filename.',                'text',   NULL, NULL,  'off-api-2025, zabka-menu',      'Brief reference name.',                'Product Info', 4),
('sources', 'url',         'URL',         'Full URL to the data source, if applicable.',            'text',   NULL, NULL,  'https://world.openfoodfacts.org','Link to the original data source.',    'Product Info', 5),
('sources', 'notes',       'Notes',       'Freeform notes about the source.',                       'text',   NULL, NULL,  'Scraped Feb 2025',              'Additional context about data.',        'Product Info', 6)
ON CONFLICT (table_name, column_name) DO UPDATE SET
  display_label = EXCLUDED.display_label, description = EXCLUDED.description,
  data_type = EXCLUDED.data_type, unit = EXCLUDED.unit,
  value_range = EXCLUDED.value_range, example_values = EXCLUDED.example_values,
  tooltip_text = EXCLUDED.tooltip_text, category_group = EXCLUDED.category_group,
  sort_order = EXCLUDED.sort_order;
