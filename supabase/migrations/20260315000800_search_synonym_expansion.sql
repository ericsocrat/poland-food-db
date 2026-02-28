-- Search synonym coverage expansion — Phase 2 of Issue #378
--
-- Existing state: 200 rows (50 PL↔EN + 50 DE↔EN bidirectional)
-- This migration adds ~130 new synonyms across under-covered categories:
--   • ~50 PL→EN + EN→PL for: Baby, Alcohol, Seafood, Plant-Based, Nuts/Seeds,
--     Canned, Frozen/Prepared, Sauces, Meat, Sweets
--   • ~15 DE→EN + EN→DE for: Dairy, Bread, Sweets, Chips, Drinks specifics
--
-- Rollback: DELETE FROM search_synonyms WHERE id > (SELECT MAX(id) FROM search_synonyms) - 130;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Additional PL → EN synonyms (under-covered categories)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
-- ── Baby ─────────────────────────────────────────────────────────────────────
('kaszka',       'porridge',       'pl', 'en'),
('obiadek',      'baby meal',      'pl', 'en'),
('deserek',      'baby dessert',   'pl', 'en'),
('herbatka',     'baby tea',       'pl', 'en'),
('kleik',        'baby cereal',    'pl', 'en'),

-- ── Alcohol ──────────────────────────────────────────────────────────────────
('wódka',        'vodka',          'pl', 'en'),
('cydr',         'cider',          'pl', 'en'),
('nalewka',      'liqueur',        'pl', 'en'),
('likier',       'liqueur',        'pl', 'en'),
('bezalkoholowe','non-alcoholic',  'pl', 'en'),
('piwo rzemieślnicze', 'craft beer', 'pl', 'en'),

-- ── Seafood & Fish ───────────────────────────────────────────────────────────
('łosoś',        'salmon',         'pl', 'en'),
('tuńczyk',      'tuna',           'pl', 'en'),
('dorsz',        'cod',            'pl', 'en'),
('śledź',        'herring',        'pl', 'en'),
('krewetki',     'shrimp',         'pl', 'en'),
('wędzony',      'smoked',         'pl', 'en'),
('makrela',      'mackerel',       'pl', 'en'),
('sardynki',     'sardines',       'pl', 'en'),

-- ── Plant-Based & Alternatives ───────────────────────────────────────────────
('roślinny',     'plant-based',    'pl', 'en'),
('sojowy',       'soy',            'pl', 'en'),
('owsiany',      'oat',            'pl', 'en'),
('migdałowy',    'almond',         'pl', 'en'),
('kokosowy',     'coconut',        'pl', 'en'),
('wegański',     'vegan',          'pl', 'en'),
('tofu',         'tofu',           'pl', 'en'),

-- ── Nuts, Seeds & Legumes ────────────────────────────────────────────────────
('orzechy',      'nuts',           'pl', 'en'),
('migdały',      'almonds',        'pl', 'en'),
('pistacje',     'pistachios',     'pl', 'en'),
('nasiona',      'seeds',          'pl', 'en'),
('sezam',        'sesame',         'pl', 'en'),
('fasola',       'beans',          'pl', 'en'),
('soczewica',    'lentils',        'pl', 'en'),
('groch',        'peas',           'pl', 'en'),
('ciecierzyca',  'chickpeas',      'pl', 'en'),
('orzeszki ziemne', 'peanuts',     'pl', 'en'),

-- ── Canned Goods ─────────────────────────────────────────────────────────────
('konserwa',     'canned food',    'pl', 'en'),
('puszka',       'can',            'pl', 'en'),
('groszek',      'peas',           'pl', 'en'),
('kukurydza',    'corn',           'pl', 'en'),

-- ── Frozen & Prepared ────────────────────────────────────────────────────────
('mrożonki',     'frozen food',    'pl', 'en'),
('pierogi',      'dumplings',      'pl', 'en'),
('naleśniki',    'pancakes',       'pl', 'en'),
('pizza',        'pizza',          'pl', 'en'),

-- ── Sauces & Condiments ──────────────────────────────────────────────────────
('ketchup',      'ketchup',        'pl', 'en'),
('sos',          'sauce',          'pl', 'en'),
('sos sojowy',   'soy sauce',      'pl', 'en'),
('przyprawa',    'seasoning',      'pl', 'en'),

-- ── Meat ─────────────────────────────────────────────────────────────────────
('wołowina',     'beef',           'pl', 'en'),
('wieprzowina',  'pork',           'pl', 'en'),
('indyk',        'turkey',         'pl', 'en'),
('kabanosy',     'kabanos',        'pl', 'en'),
('parówki',      'hot dogs',       'pl', 'en'),
('boczek',       'bacon',          'pl', 'en'),

-- ── Sweets ───────────────────────────────────────────────────────────────────
('cukierki',     'candy',          'pl', 'en'),
('wafle',        'wafers',         'pl', 'en'),
('galaretka',    'jelly',          'pl', 'en'),
('żelki',        'gummy bears',    'pl', 'en'),
('batonik',      'candy bar',      'pl', 'en'),
('herbatniki',   'biscuits',       'pl', 'en')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Reverse EN → PL for new terms
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
('porridge',      'kaszka',        'en', 'pl'),
('baby meal',     'obiadek',       'en', 'pl'),
('baby dessert',  'deserek',       'en', 'pl'),
('baby tea',      'herbatka',      'en', 'pl'),
('baby cereal',   'kleik',         'en', 'pl'),
('vodka',         'wódka',         'en', 'pl'),
('cider',         'cydr',          'en', 'pl'),
('liqueur',       'nalewka',       'en', 'pl'),
('non-alcoholic', 'bezalkoholowe', 'en', 'pl'),
('craft beer',    'piwo rzemieślnicze', 'en', 'pl'),
('salmon',        'łosoś',         'en', 'pl'),
('tuna',          'tuńczyk',       'en', 'pl'),
('cod',           'dorsz',         'en', 'pl'),
('herring',       'śledź',         'en', 'pl'),
('shrimp',        'krewetki',      'en', 'pl'),
('smoked',        'wędzony',       'en', 'pl'),
('mackerel',      'makrela',       'en', 'pl'),
('sardines',      'sardynki',      'en', 'pl'),
('plant-based',   'roślinny',      'en', 'pl'),
('soy',           'sojowy',        'en', 'pl'),
('oat',           'owsiany',       'en', 'pl'),
('almond',        'migdałowy',     'en', 'pl'),
('coconut',       'kokosowy',      'en', 'pl'),
('vegan',         'wegański',      'en', 'pl'),
('tofu',          'tofu',          'en', 'pl'),
('nuts',          'orzechy',       'en', 'pl'),
('almonds',       'migdały',       'en', 'pl'),
('pistachios',    'pistacje',      'en', 'pl'),
('seeds',         'nasiona',       'en', 'pl'),
('sesame',        'sezam',         'en', 'pl'),
('beans',         'fasola',        'en', 'pl'),
('lentils',       'soczewica',     'en', 'pl'),
('peas',          'groch',         'en', 'pl'),
('chickpeas',     'ciecierzyca',   'en', 'pl'),
('peanuts',       'orzeszki ziemne', 'en', 'pl'),
('canned food',   'konserwa',      'en', 'pl'),
('corn',          'kukurydza',     'en', 'pl'),
('frozen food',   'mrożonki',      'en', 'pl'),
('dumplings',     'pierogi',       'en', 'pl'),
('pancakes',      'naleśniki',     'en', 'pl'),
('ketchup',       'ketchup',       'en', 'pl'),
('sauce',         'sos',           'en', 'pl'),
('soy sauce',     'sos sojowy',    'en', 'pl'),
('seasoning',     'przyprawa',     'en', 'pl'),
('beef',          'wołowina',      'en', 'pl'),
('pork',          'wieprzowina',   'en', 'pl'),
('turkey',        'indyk',         'en', 'pl'),
('kabanos',       'kabanosy',      'en', 'pl'),
('hot dogs',      'parówki',       'en', 'pl'),
('bacon',         'boczek',        'en', 'pl'),
('candy',         'cukierki',      'en', 'pl'),
('wafers',        'wafle',         'en', 'pl'),
('jelly',         'galaretka',     'en', 'pl'),
('gummy bears',   'żelki',         'en', 'pl'),
('candy bar',     'batonik',       'en', 'pl'),
('biscuits',      'herbatniki',    'en', 'pl')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Additional DE → EN synonyms (category-specific terms)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
-- ── Dairy (DE) ───────────────────────────────────────────────────────────────
('quark',        'quark',          'de', 'en'),
('schmand',      'sour cream',     'de', 'en'),
('frischkäse',   'cream cheese',   'de', 'en'),
('kefir',        'kefir',          'de', 'en'),
('skyr',         'skyr',           'de', 'en'),
('buttermilch',  'buttermilk',     'de', 'en'),

-- ── Bread (DE) ───────────────────────────────────────────────────────────────
('vollkorn',     'whole grain',    'de', 'en'),
('roggen',       'rye',            'de', 'en'),
('weizen',       'wheat',          'de', 'en'),
('pumpernickel', 'pumpernickel',   'de', 'en'),
('sauerteig',    'sourdough',      'de', 'en'),
('dinkel',       'spelt',          'de', 'en'),

-- ── Sweets (DE) ──────────────────────────────────────────────────────────────
('bonbon',       'candy',          'de', 'en'),
('gummibärchen', 'gummy bears',    'de', 'en'),
('marzipan',     'marzipan',       'de', 'en'),
('praline',      'praline',        'de', 'en'),
('waffel',       'wafer',          'de', 'en'),
('kuchen',       'cake',           'de', 'en'),
('torte',        'cake',           'de', 'en'),

-- ── Chips (DE) ───────────────────────────────────────────────────────────────
('kartoffelchips','potato chips',  'de', 'en'),
('riffeln',      'ridged',         'de', 'en'),
('gemüsechips',  'vegetable chips','de', 'en'),

-- ── Drinks (DE) ──────────────────────────────────────────────────────────────
('limonade',     'lemonade',       'de', 'en'),
('eistee',       'iced tea',       'de', 'en'),
('schorle',      'spritzer',       'de', 'en'),
('mineralwasser','mineral water',  'de', 'en'),
('sprudel',      'sparkling water','de', 'en')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Reverse EN → DE for new terms
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
('quark',         'quark',          'en', 'de'),
('cream cheese',  'frischkäse',     'en', 'de'),
('kefir',         'kefir',          'en', 'de'),
('skyr',          'skyr',           'en', 'de'),
('buttermilk',    'buttermilch',    'en', 'de'),
('whole grain',   'vollkorn',       'en', 'de'),
('rye',           'roggen',         'en', 'de'),
('wheat',         'weizen',         'en', 'de'),
('pumpernickel',  'pumpernickel',   'en', 'de'),
('sourdough',     'sauerteig',      'en', 'de'),
('spelt',         'dinkel',         'en', 'de'),
('candy',         'bonbon',         'en', 'de'),
('gummy bears',   'gummibärchen',   'en', 'de'),
('marzipan',      'marzipan',       'en', 'de'),
('praline',       'praline',        'en', 'de'),
('wafer',         'waffel',         'en', 'de'),
('cake',          'kuchen',         'en', 'de'),
('potato chips',  'kartoffelchips', 'en', 'de'),
('ridged',        'riffeln',        'en', 'de'),
('vegetable chips','gemüsechips',   'en', 'de'),
('lemonade',      'limonade',       'en', 'de'),
('iced tea',      'eistee',         'en', 'de'),
('spritzer',      'schorle',        'en', 'de'),
('mineral water', 'mineralwasser',  'en', 'de'),
('sparkling water','sprudel',       'en', 'de')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;
