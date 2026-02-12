-- PIPELINE (Instant & Frozen): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Instant & Frozen'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901882313927', '5901882313941', '5907501001404', '5901384502768', '5901882110069', '5901882110151', '5901882110090', '5905118013384', '5905118013391', '5901882312623', '5901384503789', '5901882315075', '5901882110014', '8714100666838', '5901882110298', '5901384504731', '5907501001428', '5905118040816', '5901882018563', '5901882315051', '5901384506698', '5901384508043', '5901384506636', '5901384506681', '5901384506582', '5901384506650', '5901384506575', '5901384506629', '5901384501051', '4820179256871', '4820179254761', '5901384508074', '5901384505646', '5901384505653', '8801043057752', '8801043053167', '8994963002824', '4820179256581', '8801043057776', '0074603003287', '8850987150098', '8850987151279', '8850987148651', '8712423024588', '8801043028158', '4820179256895', '7613039253045', '8714100666630', '5023751000339')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Hot Beef pikantne w stylu syczuańskim', 'dried', 'Biedronka', 'none', '5901882313927'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Mie Goreng łagodne w stylu indonezyjskim', 'dried', null, 'palm oil', '5901882313941'),
  ('PL', 'Goong', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'dried', 'Aldi', 'none', '5907501001404'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Oyakata Kurczak Teriyaki', 'dried', 'Auchan', 'palm oil', '5901384502768'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Kurczak curry instant noodle soup', 'dried', 'Biedronka', 'palm oil', '5901882110069'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Chinese Chicken flavour instant noodle soup (mild)', 'dried', 'Carrefour', 'palm oil', '5901882110151'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Barbecue Chicken', 'dried', 'Auchan', 'none', '5901882110090'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal hot and sour CHINESE STYLE', 'dried', 'Biedronka', 'none', '5905118013384'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal hot and sour SICHUAN STYLE', 'dried', 'Biedronka', 'none', '5905118013391'),
  ('PL', 'TAN-VIET International S.A', 'Grocery', 'Instant & Frozen', 'Zupa z nudlami o smaku kimchi (pikantna)', 'dried', 'Carrefour', 'none', '5901882312623'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Oyakata Miso Ramen', 'dried', 'Biedronka', 'none', '5901384503789'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Korean Hot Beef', 'dried', 'Carrefour', 'none', '5901882315075'),
  ('PL', 'Tan-Viet', 'Grocery', 'Instant & Frozen', 'Kurczak Zloty', 'dried', null, 'palm oil', '5901882110014'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Nudle ser w ziołach', 'dried', 'Auchan', 'none', '8714100666838'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Kimchi', 'dried', null, 'palm oil', '5901882110298'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Pork Ramen', 'dried', null, 'palm oil', '5901384504731'),
  ('PL', 'Goong', 'Grocery', 'Instant & Frozen', 'Curry Noodles', 'dried', null, 'palm oil', '5907501001428'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal Thai Spicy Ramen', 'dried', null, 'none', '5905118040816'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Ramen Soy Souce', 'dried', null, 'none', '5901882018563'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Ramen Tonkotsu', 'dried', null, 'none', '5901882315051'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen soja', 'dried', null, 'none', '5901384506698'),
  ('PL', 'Sam Smak', 'Grocery', 'Instant & Frozen', 'Pomidorowa', 'dried', null, 'none', '5901384508043'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen Miso et Légumes', 'dried', null, 'palm oil', '5901384506636'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Ramen nouille de blé saveur poulet shio', 'dried', null, 'palm oil', '5901384506681'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Nouilles de blé poulet teriyaki', 'dried', null, 'palm oil', '5901384506582'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Nouilles de blé', 'dried', null, 'palm oil', '5901384506650'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Yakisoba soja classique', 'dried', null, 'palm oil', '5901384506575'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Yakisoba saveur Poulet pad thaï', 'dried', null, 'palm oil', '5901384506629'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen Barbecue', 'dried', null, 'none', '5901384501051'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku kurczaka', 'dried', null, 'none', '4820179256871'),
  ('PL', 'Rollton', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku gulaszu', 'dried', null, 'none', '4820179254761'),
  ('PL', 'Unknown', 'Grocery', 'Instant & Frozen', 'SamSmak o smaku serowa 4 sery', 'dried', null, 'none', '5901384508074'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Tomato soup', 'dried', null, 'none', '5901384505646'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Mushrood soup', 'dried', null, 'none', '5901384505653'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Zupka hińska', 'dried', null, 'none', null),  -- RCN 08153825, not a real EAN
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Bowl Noodles Hot & Spicy', 'dried', 'Biedronka', 'none', '8801043057752'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Super Spicy Red Shin', 'dried', 'Lidl', 'palm oil', '8801043053167'),
  ('PL', 'Indomie', 'Grocery', 'Instant & Frozen', 'Noodles Chicken Flavour', 'dried', 'Carrefour', 'palm oil', '8994963002824'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'REEVA Vegetable flavour Instant noodles', 'dried', null, 'none', '4820179256581'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Kimchi Bowl Noodles', 'dried', 'Netto', 'none', '8801043057776'),
  ('PL', 'NongshimSamyang', 'Grocery', 'Instant & Frozen', 'Ramen kimchi', 'dried', 'Carrefour', 'none', '0074603003287'),
  ('PL', 'Mama', 'Grocery', 'Instant & Frozen', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'dried', 'Carrefour', 'palm oil', '8850987150098'),
  ('PL', 'มาม่า', 'Grocery', 'Instant & Frozen', 'Mala Beef Instant Noodle', 'dried', 'Carrefour', 'none', '8850987151279'),
  ('PL', 'Mama', 'Grocery', 'Instant & Frozen', 'Mama salted egg', 'dried', 'Carrefour', 'none', '8850987148651'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Danie makaron Bolognese', 'dried', null, 'none', '8712423024588'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Shin Kimchi Noodles', 'dried', null, 'palm oil', '8801043028158'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'Zupa o smaku sera i boczku', 'dried', null, 'none', '4820179256895'),
  ('PL', 'Winiary', 'Grocery', 'Instant & Frozen', 'Saucy noodles smak sweet chili', 'dried', null, 'none', '7613039253045'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Nudle Pieczony kurczak', 'roasted', null, 'none', '8714100666630'),
  ('PL', 'Ko-Lee', 'Grocery', 'Instant & Frozen', 'Instant Noodles Tomato Flavour', 'dried', null, 'palm oil', '5023751000339')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
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
  and product_name not in ('Hot Beef pikantne w stylu syczuańskim', 'Mie Goreng łagodne w stylu indonezyjskim', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'Oyakata Kurczak Teriyaki', 'Kurczak curry instant noodle soup', 'Chinese Chicken flavour instant noodle soup (mild)', 'Barbecue Chicken', 'VeggieMeal hot and sour CHINESE STYLE', 'VeggieMeal hot and sour SICHUAN STYLE', 'Zupa z nudlami o smaku kimchi (pikantna)', 'Oyakata Miso Ramen', 'Korean Hot Beef', 'Kurczak Zloty', 'Nudle ser w ziołach', 'Kimchi', 'Pork Ramen', 'Curry Noodles', 'VeggieMeal Thai Spicy Ramen', 'Ramen Soy Souce', 'Ramen Tonkotsu', 'Ramen soja', 'Pomidorowa', 'Ramen Miso et Légumes', 'Ramen nouille de blé saveur poulet shio', 'Nouilles de blé poulet teriyaki', 'Nouilles de blé', 'Yakisoba soja classique', 'Yakisoba saveur Poulet pad thaï', 'Ramen Barbecue', 'Zupa błyskawiczna o smaku kurczaka', 'Zupa błyskawiczna o smaku gulaszu', 'SamSmak o smaku serowa 4 sery', 'Tomato soup', 'Mushrood soup', 'Zupka hińska', 'Bowl Noodles Hot & Spicy', 'Super Spicy Red Shin', 'Noodles Chicken Flavour', 'REEVA Vegetable flavour Instant noodles', 'Kimchi Bowl Noodles', 'Ramen kimchi', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'Mala Beef Instant Noodle', 'Mama salted egg', 'Danie makaron Bolognese', 'Shin Kimchi Noodles', 'Zupa o smaku sera i boczku', 'Saucy noodles smak sweet chili', 'Nudle Pieczony kurczak', 'Instant Noodles Tomato Flavour');
