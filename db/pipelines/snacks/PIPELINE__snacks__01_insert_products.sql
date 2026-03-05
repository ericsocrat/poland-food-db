-- PIPELINE (Snacks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Snacks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5905617000854', '5900259115393', '5902180470336', '5902172001524', '5904569550394', '5900049041017', '5902973790894', '5900749610988', '5900449006890', '5900320003260', '5906747308582', '5903548013110', '5900617013064', '5900320011036', '5900320001136', '5900617035905', '5900320008463', '5900749610926', '5900617047304', '5900320001334', '5905187001237', '5907029001658', '5905186302410', '5905186302106', '5904358563994', '5900320003420', '5905187001213', '5907029010797', '5900320003536', '5900928004676', '5903246562552', '5904607004810', '5906747309893', '4056489814092', '8595229924432', '5900320008470', '5906747308490', '5900617047281', '8584004042089', '5900749115049', '5201360521210', '4056489827498', '4018077632006', '4014500513485', '8595229926573', '3800205871255', '5201360677351', '4056489784050', '8690526026220', '3258561400242', '8719979201470')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Top', 'Grocery', 'Snacks', 'Popcorn o smaku maślanym', 'not-applicable', 'Biedronka', 'none', '5905617000854'),
  ('PL', 'Lay''s', 'Grocery', 'Snacks', 'Oven Baked Krakersy wielozbożowe', 'baked', null, 'none', '5900259115393'),
  ('PL', 'Sonko', 'Grocery', 'Snacks', 'Wafle ryżowe w czekoladzie mlecznej', 'not-applicable', null, 'none', '5902180470336'),
  ('PL', 'Kupiec', 'Grocery', 'Snacks', 'Wafle ryżowe naturalne', 'not-applicable', null, 'none', '5902172001524'),
  ('PL', 'Zdrowidło', 'Grocery', 'Snacks', 'Chipsy Loopea''s O Smaku Śmietanki Z Cebulką', 'not-applicable', null, 'none', '5904569550394'),
  ('PL', 'Lubella', 'Grocery', 'Snacks', 'Paluszki z solą', 'not-applicable', null, 'none', '5900049041017'),
  ('PL', 'Pano', 'Grocery', 'Snacks', 'Wafle mini, zbożowe', 'not-applicable', null, 'none', '5902973790894'),
  ('PL', 'Bakalland', 'Grocery', 'Snacks', 'Ba! żurawina', 'not-applicable', null, 'none', '5900749610988'),
  ('PL', 'Vital Fresh', 'Grocery', 'Snacks', 'Surówka Colesław z białej kapusty', 'not-applicable', null, 'none', '5900449006890'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Paluszki o smaku waniliowym.', 'not-applicable', 'Biedronka', 'none', '5900320003260'),
  ('PL', 'Delicje', 'Grocery', 'Snacks', 'Szampariskie pomaranczowe', 'not-applicable', 'Carrefour', 'none', '5906747308582'),
  ('PL', 'Vitanella', 'Grocery', 'Snacks', 'Superballs Kokos i kakao', 'not-applicable', 'Biedronka', 'none', '5903548013110'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Sante Baton Proteinowy Go On Kakaowy', 'not-applicable', 'Lidl', 'none', '5900617013064'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Dobry chrup', 'not-applicable', null, 'none', '5900320011036'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Salted cracker', 'not-applicable', null, 'none', '5900320001136'),
  ('PL', 'Go On Nutrition', 'Grocery', 'Snacks', 'Protein 33% Caramel', 'not-applicable', null, 'none', '5900617035905'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Krakersy mini', 'not-applicable', null, 'none', '5900320008463'),
  ('PL', 'Bakalland', 'Grocery', 'Snacks', 'Barre chocolat ba', 'not-applicable', null, 'none', '5900749610926'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Go On Energy', 'not-applicable', null, 'none', '5900617047304'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Prezel', 'not-applicable', null, 'none', '5900320001334'),
  ('PL', 'Lorenz', 'Grocery', 'Snacks', 'Chrupki Curly', 'not-applicable', null, 'none', '5905187001237'),
  ('PL', 'Beskidzkie', 'Grocery', 'Snacks', 'Beskidzkie paluchy z sezamem', 'not-applicable', null, 'none', '5907029001658'),
  ('PL', 'Purella superfoods', 'Grocery', 'Snacks', 'Purella ciasteczko', 'not-applicable', null, 'none', '5905186302410'),
  ('PL', 'Unknown', 'Grocery', 'Snacks', 'Vitanella raw', 'raw', 'Biedronka', 'none', '5905186302106'),
  ('PL', 'Meltié Chocolatier', 'Grocery', 'Snacks', 'Dark Chocolate 64% Cocoa', 'not-applicable', null, 'none', '5904358563994'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Junior Safari', 'not-applicable', null, 'none', '5900320003420'),
  ('PL', 'Lorenz', 'Grocery', 'Snacks', 'Monster munch', 'not-applicable', null, 'none', '5905187001213'),
  ('PL', 'Aksam', 'Grocery', 'Snacks', 'Beskidzkie paluszki o smaku sera i cebulki', 'not-applicable', null, 'none', '5907029010797'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Drobne pieczywo o smaku waniliowym', 'not-applicable', null, 'none', '5900320003536'),
  ('PL', 'TOP', 'Grocery', 'Snacks', 'Paluszki solone', 'not-applicable', null, 'none', '5900928004676'),
  ('PL', 'Be raw', 'Grocery', 'Snacks', 'Energy Raspberry', 'not-applicable', null, 'none', '5903246562552'),
  ('PL', 'Top', 'Grocery', 'Snacks', 'Paluszki i precelki solone', 'not-applicable', null, 'none', '5904607004810'),
  ('PL', 'San', 'Grocery', 'Snacks', 'San bieszczadzkie suchary', 'not-applicable', null, 'none', '5906747309893'),
  ('PL', 'Tastino', 'Grocery', 'Snacks', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'not-applicable', null, 'none', '4056489814092'),
  ('PL', 'Go Active', 'Grocery', 'Snacks', 'Baton wysokobiałkowy z pistacjami', 'not-applicable', null, 'none', '8595229924432'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Krakersy mini ser i cebula', 'not-applicable', null, 'none', '5900320008470'),
  ('PL', 'Delicje', 'Grocery', 'Snacks', 'Delicje malinowe', 'not-applicable', null, 'none', '5906747308490'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Vitamin Coconut & Milk Chocolate', 'not-applicable', null, 'none', '5900617047281'),
  ('PL', 'Góralki', 'Grocery', 'Snacks', 'Góralki mleczne', 'not-applicable', null, 'none', '8584004042089'),
  ('PL', 'Unknown', 'Grocery', 'Snacks', 'Popcorn solony', 'not-applicable', null, 'palm oil', '5900749115049'),
  ('PL', '7 Days', 'Grocery', 'Snacks', 'Croissant with Cocoa Filling', 'not-applicable', 'Kaufland', 'palm oil', '5201360521210'),
  ('PL', 'Snack Day', 'Grocery', 'Snacks', 'Popcorn', 'not-applicable', 'Lidl', 'none', '4056489827498'),
  ('PL', 'Lorenz', 'Grocery', 'Snacks', 'Monster Munch Crispy Potato-Snack Original', 'not-applicable', 'Biedronka', 'palm oil', '4018077632006'),
  ('PL', 'Zott', 'Grocery', 'Snacks', 'Monte Snack', 'not-applicable', 'Biedronka', 'none', '4014500513485'),
  ('PL', 'Emco', 'Grocery', 'Snacks', 'Vitanella Bars', 'not-applicable', 'Biedronka', 'none', '8595229926573'),
  ('PL', 'Maretti', 'Grocery', 'Snacks', 'Bruschette Chips Pizza Flavour', 'not-applicable', 'Penny', 'none', '3800205871255'),
  ('PL', '7days', 'Grocery', 'Snacks', '7days', 'not-applicable', null, 'palm oil', '5201360677351'),
  ('PL', 'Tastino', 'Grocery', 'Snacks', 'Wafle Kukurydziane', 'not-applicable', null, 'none', '4056489784050'),
  ('PL', 'Eti', 'Grocery', 'Snacks', 'Dare with MILK CHOCOLATE', 'not-applicable', null, 'none', '8690526026220'),
  ('PL', 'Belle France', 'Grocery', 'Snacks', 'Brioche Tressée', 'not-applicable', null, 'none', '3258561400242'),
  ('PL', 'Happy Creations', 'Grocery', 'Snacks', 'Cracker Mix Classic', 'not-applicable', null, 'none', '8719979201470')
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
where country = 'PL' and category = 'Snacks'
  and is_deprecated is not true
  and product_name not in ('Popcorn o smaku maślanym', 'Oven Baked Krakersy wielozbożowe', 'Wafle ryżowe w czekoladzie mlecznej', 'Wafle ryżowe naturalne', 'Chipsy Loopea''s O Smaku Śmietanki Z Cebulką', 'Paluszki z solą', 'Wafle mini, zbożowe', 'Ba! żurawina', 'Surówka Colesław z białej kapusty', 'Paluszki o smaku waniliowym.', 'Szampariskie pomaranczowe', 'Superballs Kokos i kakao', 'Sante Baton Proteinowy Go On Kakaowy', 'Dobry chrup', 'Salted cracker', 'Protein 33% Caramel', 'Krakersy mini', 'Barre chocolat ba', 'Go On Energy', 'Prezel', 'Chrupki Curly', 'Beskidzkie paluchy z sezamem', 'Purella ciasteczko', 'Vitanella raw', 'Dark Chocolate 64% Cocoa', 'Junior Safari', 'Monster munch', 'Beskidzkie paluszki o smaku sera i cebulki', 'Drobne pieczywo o smaku waniliowym', 'Paluszki solone', 'Energy Raspberry', 'Paluszki i precelki solone', 'San bieszczadzkie suchary', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'Baton wysokobiałkowy z pistacjami', 'Krakersy mini ser i cebula', 'Delicje malinowe', 'Vitamin Coconut & Milk Chocolate', 'Góralki mleczne', 'Popcorn solony', 'Croissant with Cocoa Filling', 'Popcorn', 'Monster Munch Crispy Potato-Snack Original', 'Monte Snack', 'Vitanella Bars', 'Bruschette Chips Pizza Flavour', '7days', 'Wafle Kukurydziane', 'Dare with MILK CHOCOLATE', 'Brioche Tressée', 'Cracker Mix Classic');
