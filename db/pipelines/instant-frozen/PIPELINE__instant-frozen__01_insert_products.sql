-- PIPELINE (Instant & Frozen): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Instant & Frozen'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901882313927', '5901384502751', '5907501001404', '5901882313941', '5905118013384', '5905118013391', '5901882315075', '5901882110298', '5907501001428', '5905118040816', '5901882018563', '5901882315051', '5901384508043', '5901384506636', '5901384506681', '5901384506582', '5901384506650', '5901384506629', '5901384501051', '4820179256871', '4820179254761', '5901384508074', '5901384505646', '5901384505653', '08153825', '8801043057752', '8801043057776', '8801043053167', '8994963002824', '4820179256581', '0074603003287', '8850987150098', '8850987151279', '8850987148651', '4820179256895', '8714100666630', '5023751000339', '8719979203672', '8801043028158', '5023751000322', '8721317713040', '8712423019461', '8720182001641')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Instant & Frozen by pipeline',
    ean = null
where country = 'PL'
  and category != 'Instant & Frozen'
  and identity_key in ('0412140e1c45b21a13fd045ea4edfea0', '12a49e2a5677eaba8377cb1e5fa8c266', '1535c2658202cd70a7225247e28430eb', '16d04e2852df606f751847355772fb36', '22d4717b8443d26bac48c0bd1142163b', '31221715d8357892d4ebcaf08cc4f403', '385d63c37034bbfca2d3aeeb5d3ec434', '39d2720ac4ccc27640440b1a14dd54ef', '43d2b4f82baa67c8242bde4b956003e3', '4af6d4494af59722fe8e08624568bd87', '4ba87083de0c4ecefe6fe0e1c018346c', '4ea8ea88891af9ae43312dcee6f7d0bf', '5118905c9f039b9ee1e348dfc69e5fc4', '5153af4d39c2db6755acbfe6e5274279', '563d217b69aaab4f76f25523c05a5393', '5a8b6f43984fabe6acfa84634315958f', '6020511fabafb0ff7381e598f5963f39', '61639b0aee46df0b50a15ce506ee01a6', '695b67b7e2d2c506c54c89e2277e65b4', '69a729b2d1b5e29307264dec198e9e0d', '6fb0b16e8b914085d993212987e112ad', '82ea60d9fbebad620e7fc084d26f9c0c', '8bd4605a1ae7963382e5f9c49c48aaf7', '8c43072e8ccd222c15cbe9b4fac6f73e', '8ea6e2f73873d99694112c67219dce8f', '93d44cb49b0575d66ec592c81849067c', '96a69ac5f586ad31bd54ad5ba9d8781c', '9d7edb25e1a4576dcdbd2a430f0d9c32', 'a57d6b5d6b93791b56070ae7bb5d103d', 'a918e132e6a041abd284901ac9fe2870', 'ad9b6bc19acd86ba5e72be3dd5d194fe', 'b5d5f6c0492e8b32a1969706165211d6', 'c49cbd524968168ec90394835ddc292d', 'c706305cb79dc2199c83d4171ed7a383', 'c7827d77a9493636ed6b1429c07be0ac', 'd528f9ef9cd451a73a9ca509c27e3d1c', 'd941b56474a25b8134bbb28937372c26', 'dbd37d168a68d5efedf9bec0a218c847', 'e49b92f26367c26804eb36f9a433e307', 'e973f8fc21d3b01671255ad6152ddd22', 'f06afcc05a3b56f36e04f5897eac8d7c', 'f954dc95b76918bf1e87f108dbfafabe', 'fd6a45da09bf9c05c3944a1da009c080')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Hot Beef pikantne w stylu syczuańskim', 'dried', 'Biedronka', 'none', '5901882313927'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Oyakata w stylu japoński klasyczny', 'dried', null, 'palm oil', '5901384502751'),
  ('PL', 'Goong', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'dried', 'Aldi', 'none', '5907501001404'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Mie Goreng łagodne w stylu indonezyjskim', 'dried', null, 'palm oil', '5901882313941'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal hot and sour CHINESE STYLE', 'dried', 'Biedronka', 'none', '5905118013384'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal hot and sour SICHUAN STYLE', 'dried', 'Biedronka', 'none', '5905118013391'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Korean Hot Beef', 'dried', 'Carrefour', 'none', '5901882315075'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Kimchi', 'dried', null, 'palm oil', '5901882110298'),
  ('PL', 'Goong', 'Grocery', 'Instant & Frozen', 'Curry Noodles', 'dried', null, 'palm oil', '5907501001428'),
  ('PL', 'Asia Style', 'Grocery', 'Instant & Frozen', 'VeggieMeal Thai Spicy Ramen', 'dried', null, 'none', '5905118040816'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Ramen Soy Souce', 'dried', null, 'none', '5901882018563'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Ramen Tonkotsu', 'dried', null, 'none', '5901882315051'),
  ('PL', 'Sam Smak', 'Grocery', 'Instant & Frozen', 'Pomidorowa', 'dried', null, 'none', '5901384508043'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen Miso et Légumes', 'dried', null, 'palm oil', '5901384506636'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Ramen nouille de blé saveur poulet shio', 'dried', null, 'palm oil', '5901384506681'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Nouilles de blé poulet teriyaki', 'dried', null, 'palm oil', '5901384506582'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Nouilles de blé', 'dried', null, 'palm oil', '5901384506650'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Yakisoba saveur Poulet pad thaï', 'dried', null, 'palm oil', '5901384506629'),
  ('PL', 'Oyakata', 'Grocery', 'Instant & Frozen', 'Ramen Barbecue', 'dried', null, 'none', '5901384501051'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku kurczaka', 'dried', null, 'none', '4820179256871'),
  ('PL', 'Rollton', 'Grocery', 'Instant & Frozen', 'Zupa błyskawiczna o smaku gulaszu', 'dried', null, 'none', '4820179254761'),
  ('PL', 'Unknown', 'Grocery', 'Instant & Frozen', 'SamSmak o smaku serowa 4 sery', 'dried', null, 'none', '5901384508074'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Tomato soup', 'dried', null, 'none', '5901384505646'),
  ('PL', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Mushrood soup', 'dried', null, 'none', '5901384505653'),
  ('PL', 'Vifon', 'Grocery', 'Instant & Frozen', 'Zupka hińska', 'dried', null, 'none', '08153825'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Bowl Noodles Hot & Spicy', 'dried', 'Biedronka', 'none', '8801043057752'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Kimchi Bowl Noodles', 'dried', 'Netto', 'none', '8801043057776'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Super Spicy Red Shin', 'dried', 'Lidl', 'palm oil', '8801043053167'),
  ('PL', 'Indomie', 'Grocery', 'Instant & Frozen', 'Noodles Chicken Flavour', 'dried', 'Carrefour', 'palm oil', '8994963002824'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'REEVA Vegetable flavour Instant noodles', 'dried', null, 'none', '4820179256581'),
  ('PL', 'NongshimSamyang', 'Grocery', 'Instant & Frozen', 'Ramen kimchi', 'dried', 'Carrefour', 'none', '0074603003287'),
  ('PL', 'Mama', 'Grocery', 'Instant & Frozen', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'dried', 'Carrefour', 'palm oil', '8850987150098'),
  ('PL', 'มาม่า', 'Grocery', 'Instant & Frozen', 'Mala Beef Instant Noodle', 'dried', 'Carrefour', 'none', '8850987151279'),
  ('PL', 'Mama', 'Grocery', 'Instant & Frozen', 'Mama salted egg', 'dried', 'Carrefour', 'none', '8850987148651'),
  ('PL', 'Reeva', 'Grocery', 'Instant & Frozen', 'Zupa o smaku sera i boczku', 'dried', null, 'none', '4820179256895'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Nudle Pieczony kurczak', 'roasted', null, 'none', '8714100666630'),
  ('PL', 'Ko-Lee', 'Grocery', 'Instant & Frozen', 'Instant Noodles Tomato Flavour', 'dried', null, 'palm oil', '5023751000339'),
  ('PL', 'Unknown', 'Grocery', 'Instant & Frozen', 'Chicken flavour', 'dried', null, 'none', '8719979203672'),
  ('PL', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Shin Kimchi Noodles', 'dried', null, 'palm oil', '8801043028158'),
  ('PL', 'Ko-Lee', 'Grocery', 'Instant & Frozen', 'Instant noodles curry flavour', 'dried', null, 'palm oil', '5023751000322'),
  ('PL', 'Namdong', 'Grocery', 'Instant & Frozen', 'Beef Jjigae k-noodles', 'dried', null, 'none', '8721317713040'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Makaron ser z bekonem', 'dried', null, 'none', '8712423019461'),
  ('PL', 'Knorr', 'Grocery', 'Instant & Frozen', 'Makaron 4 sery', 'dried', null, 'none', '8720182001641')
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
  and product_name not in ('Hot Beef pikantne w stylu syczuańskim', 'Oyakata w stylu japoński klasyczny', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'Mie Goreng łagodne w stylu indonezyjskim', 'VeggieMeal hot and sour CHINESE STYLE', 'VeggieMeal hot and sour SICHUAN STYLE', 'Korean Hot Beef', 'Kimchi', 'Curry Noodles', 'VeggieMeal Thai Spicy Ramen', 'Ramen Soy Souce', 'Ramen Tonkotsu', 'Pomidorowa', 'Ramen Miso et Légumes', 'Ramen nouille de blé saveur poulet shio', 'Nouilles de blé poulet teriyaki', 'Nouilles de blé', 'Yakisoba saveur Poulet pad thaï', 'Ramen Barbecue', 'Zupa błyskawiczna o smaku kurczaka', 'Zupa błyskawiczna o smaku gulaszu', 'SamSmak o smaku serowa 4 sery', 'Tomato soup', 'Mushrood soup', 'Zupka hińska', 'Bowl Noodles Hot & Spicy', 'Kimchi Bowl Noodles', 'Super Spicy Red Shin', 'Noodles Chicken Flavour', 'REEVA Vegetable flavour Instant noodles', 'Ramen kimchi', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'Mala Beef Instant Noodle', 'Mama salted egg', 'Zupa o smaku sera i boczku', 'Nudle Pieczony kurczak', 'Instant Noodles Tomato Flavour', 'Chicken flavour', 'Shin Kimchi Noodles', 'Instant noodles curry flavour', 'Beef Jjigae k-noodles', 'Makaron ser z bekonem', 'Makaron 4 sery');
