-- PIPELINE (Instant & Frozen): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Instant & Frozen'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Oyakata Miso Ramen', null, 'Albert Heijn,Asia Markt,Biedronka', 'none', '5901384503789'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Kurczak curry instant noodle soup', null, 'Lidl,Biedronka', 'palm oil', '5901882110069'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Oyakata Kurczak Teriyaki', null, 'Auchan', 'palm oil', '5901384502768'),
  ('PL', 'VIFON', 'Grocery', 'Instant & Frozen', 'Chinese Chicken flavour instant noodle soup (mild)', null, 'Carrefour', 'palm oil', '5901882110151'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Barbecue Chicken', null, 'Auchan,E.Lecelrc,Stokrotka', 'none', '5901882110090'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal hot and sour SICHUAN STYLE', null, 'Biedronka', 'none', '5905118013391'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Nouilles de blé poulet teriyaki', null, null, 'palm oil', '5901384506582'),
  ('PL', 'Tan-Viet', 'Grocery', 'Instant & Frozen', 'Kurczak Zloty', null, null, 'palm oil', '5901882110014'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Yakisoba soja classique', null, null, 'palm oil', '5901384506575'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Nouilles de blé', null, null, 'palm oil', '5901384506650'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen Miso et Légumes', null, null, 'palm oil', '5901384506636'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Yakisoba saveur Poulet pad thaï', null, null, 'palm oil', '5901384506629'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen soja', null, null, 'none', '5901384506698'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Ramen nouille de blé saveur poulet shio', null, null, 'palm oil', '5901384506681'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Nudle ser w ziołach', null, 'Auchan', 'none', '8714100666838'),
  ('PL', 'Goong', 'Grocery', 'Instant & Frozen', 'Curry Noodles', null, null, 'palm oil', '5907501001428'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Kimchi', null, null, 'palm oil', '5901882110298'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Pork Ramen', null, 'HIT', 'palm oil', '5901384504731'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Ramen Soy Souce', null, null, 'none', '5901882018563'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku kurczaka', null, null, 'none', '4820179256871'),
  ('PL', 'Rollton', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku gulaszu', null, null, 'none', '4820179254761'),
  ('PL', 'Indomie', 'Grocery', 'Instant & Frozen', 'Noodles Chicken Flavour', null, 'Carrefour', 'palm oil', '8994963002824'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Super Spicy Red Shin', null, 'Lidl', 'palm oil', '8801043053167'),
  ('PL', 'mama', 'Grocery', 'Instant & Frozen', 'Mama salted egg', null, 'Carrefour', 'none', '8850987148651'),
  ('PL', 'NongshimSamyang', 'Grocery', 'Instant & Frozen', 'Ramen kimchi', null, 'Paris Store,Carrefour', 'none', '0074603003287'),
  ('PL', 'MAMA', 'Grocery', 'Instant & Frozen', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', null, 'SPAR,Carrefour', 'palm oil', '8850987150098'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Bowl Noodles Hot & Spicy', null, 'Biedronka', 'none', '8801043057752'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'REEVA Vegetable flavour Instant noodles', null, 'SPAR', 'none', '4820179256581')
on conflict (country, brand, product_name) do update set
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Instant & Frozen'
  and is_deprecated is not true
  and product_name not in ('Oyakata Miso Ramen', 'Kurczak curry instant noodle soup', 'Oyakata Kurczak Teriyaki', 'Chinese Chicken flavour instant noodle soup (mild)', 'Barbecue Chicken', 'VeggieMeal hot and sour SICHUAN STYLE', 'Nouilles de blé poulet teriyaki', 'Kurczak Zloty', 'Yakisoba soja classique', 'Nouilles de blé', 'Ramen Miso et Légumes', 'Yakisoba saveur Poulet pad thaï', 'Ramen soja', 'Ramen nouille de blé saveur poulet shio', 'Nudle ser w ziołach', 'Curry Noodles', 'Kimchi', 'Pork Ramen', 'Ramen Soy Souce', 'Zupa błyskawiczna o smaku kurczaka', 'Zupa błyskawiczna o smaku gulaszu', 'Noodles Chicken Flavour', 'Super Spicy Red Shin', 'Mama salted egg', 'Ramen kimchi', 'ORIENTAL KITCHEN INSTANT NOODLES CARBONARA BACON FLAVOUR', 'Bowl Noodles Hot & Spicy', 'REEVA Vegetable flavour Instant noodles');
