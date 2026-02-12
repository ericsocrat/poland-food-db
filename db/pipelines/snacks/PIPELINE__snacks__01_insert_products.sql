-- PIPELINE (Snacks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Snacks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900125008750', '5905186300003', '5901888021314', '5902180470336', '5902172001524', '5900749610988', '5900449006890', '5900259115393', '5902973790894', '5903548002411', '5900049041017', '5903548002206', '5907799960902', '5900617013064', '5900320005950', '5902176738938', '5900617015723', '5900672001563', '5907029010797', '5900617035905', '5900320001136', '5905187001237', '5900320001334', '5900320008463', '5906747309893', '5900617034809', '5900320003420', '5903548002022', '5900320003536', '5900928004676', '59096009', '5900617044341', '5905617002612', '5905868420999', '5900320011036', '5900320007794', '5903246562552', '5907554476143', '5905299001194', '8595229924432', '8584004042089', '4820162520316', '4056489814092', '5907554479731', '8595229924449', '5201360521210', '8595229923398', '5201049132560', '4770299395595', '5201360677351', '3800205871255', '4056489784050', '20720285', '8710449944439', '7622202009051', '7622300784751', '7300400115889')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Pano', 'Grocery', 'Snacks', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 'baked', 'Biedronka', 'none', '5900125008750'),
  ('PL', 'Go Active', 'Grocery', 'Snacks', 'Baton wysokobiałkowy Peanut Butter', 'not-applicable', 'Biedronka', 'none', '5905186300003'),
  ('PL', 'Go active', 'Grocery', 'Snacks', 'Baton białkowy malinowy', 'not-applicable', 'Biedronka', 'none', '5901888021314'),
  ('PL', 'Sonko', 'Grocery', 'Snacks', 'Wafle ryżowe w czekoladzie mlecznej', 'baked', null, 'none', '5902180470336'),
  ('PL', 'Kupiec', 'Grocery', 'Snacks', 'Wafle ryżowe naturalne', 'baked', null, 'none', '5902172001524'),
  ('PL', 'Bakalland', 'Grocery', 'Snacks', 'Ba! żurawina', 'not-applicable', null, 'none', '5900749610988'),
  ('PL', 'Vital Fresh', 'Grocery', 'Snacks', 'Surówka Colesław z białej kapusty', 'not-applicable', null, 'none', '5900449006890'),
  ('PL', 'Lay''s', 'Grocery', 'Snacks', 'Oven Baked Krakersy wielozbożowe', 'baked', null, 'none', '5900259115393'),
  ('PL', 'Pano', 'Grocery', 'Snacks', 'Wafle mini, zbożowe', 'baked', null, 'none', '5902973790894'),
  ('PL', 'Dobra kaloria', 'Grocery', 'Snacks', 'Mini batoniki z nerkowców à la tarta malinowa', 'not-applicable', null, 'none', '5903548002411'),
  ('PL', 'Lubella', 'Grocery', 'Snacks', 'Paluszki z solą', 'baked', null, 'none', '5900049041017'),
  ('PL', 'Dobra Kaloria', 'Grocery', 'Snacks', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', 'not-applicable', null, 'none', '5903548002206'),
  ('PL', 'Brześć', 'Grocery', 'Snacks', 'Słomka ptysiowa', 'baked', null, 'none', '5907799960902'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Sante Baton Proteinowy Go On Kakaowy', 'not-applicable', 'Lidl', 'none', '5900617013064'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Paluszki extra cienkie', 'baked', 'Żabka', 'none', '5900320005950'),
  ('PL', 'Wafle Dzik', 'Grocery', 'Snacks', 'Kukurydziane - ser', 'not-applicable', 'Lidl', 'none', '5902176738938'),
  ('PL', 'Sante A. Kowalski sp. j', 'Grocery', 'Snacks', 'Crunchy Cranberry & Raspberry - Santé', 'not-applicable', 'Kaufland', 'none', '5900617015723'),
  ('PL', 'Miami', 'Grocery', 'Snacks', 'Paleczki', 'baked', 'Biedronka', 'none', '5900672001563'),
  ('PL', 'Aksam', 'Grocery', 'Snacks', 'Beskidzkie paluszki o smaku sera i cebulki', 'baked', null, 'none', '5907029010797'),
  ('PL', 'Go On Nutrition', 'Grocery', 'Snacks', 'Protein 33% Caramel', 'not-applicable', null, 'none', '5900617035905'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Salted cracker', 'baked', null, 'none', '5900320001136'),
  ('PL', 'Lorenz', 'Grocery', 'Snacks', 'Chrupki Curly', 'not-applicable', null, 'none', '5905187001237'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Prezel', 'baked', null, 'none', '5900320001334'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Krakersy mini', 'baked', null, 'none', '5900320008463'),
  ('PL', 'San', 'Grocery', 'Snacks', 'San bieszczadzkie suchary', 'baked', null, 'none', '5906747309893'),
  ('PL', 'Sante', 'Grocery', 'Snacks', 'Vitamin coconut bar', 'not-applicable', null, 'none', '5900617034809'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Junior Safari', 'baked', null, 'none', '5900320003420'),
  ('PL', 'Dobra Kaloria', 'Grocery', 'Snacks', 'Kokos & Orzech', 'not-applicable', null, 'none', '5903548002022'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Drobne pieczywo o smaku waniliowym', 'baked', null, 'none', '5900320003536'),
  ('PL', 'TOP', 'Grocery', 'Snacks', 'Paluszki solone', 'baked', null, 'none', '5900928004676'),
  ('PL', 'Baron', 'Grocery', 'Snacks', 'Protein BarMax Caramel', 'not-applicable', null, 'none', '59096009'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Keto Bar', 'not-applicable', null, 'none', '5900617044341'),
  ('PL', 'Top', 'Grocery', 'Snacks', 'Popcorn solony', 'not-applicable', null, 'none', '5905617002612'),
  ('PL', 'Oshee', 'Grocery', 'Snacks', 'Raspberry & Almond High Protein Bar PROMO', 'not-applicable', null, 'none', '5905868420999'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Dobry chrup', 'baked', null, 'none', '5900320011036'),
  ('PL', 'Lajkonik', 'Grocery', 'Snacks', 'Precelki chrupkie', 'baked', null, 'none', '5900320007794'),
  ('PL', 'Be raw', 'Grocery', 'Snacks', 'Energy Raspberry', 'not-applicable', null, 'none', '5903246562552'),
  ('PL', 'Go active', 'Grocery', 'Snacks', 'Baton Proteinowy Smak Waniliowy 50%', 'not-applicable', null, 'none', '5907554476143'),
  ('PL', 'As Babuni', 'Grocery', 'Snacks', 'Chrup Asy Wafle Paprykowe', 'baked', null, 'none', '5905299001194'),
  ('PL', 'Go Active', 'Grocery', 'Snacks', 'Baton wysokobiałkowy z pistacjami', 'not-applicable', null, 'none', '8595229924432'),
  ('PL', 'Góralki', 'Grocery', 'Snacks', 'Góralki mleczne', 'baked', null, 'none', '8584004042089'),
  ('PL', 'Bob Snail', 'Grocery', 'Snacks', 'Jabłkowo-truskawkowe przekąski', 'not-applicable', null, 'none', '4820162520316'),
  ('PL', 'Tastino', 'Grocery', 'Snacks', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'baked', null, 'none', '4056489814092'),
  ('PL', 'Unknown', 'Grocery', 'Snacks', 'Protein vanillia raspberry', 'not-applicable', null, 'none', '5907554479731'),
  ('PL', 'Go Active', 'Grocery', 'Snacks', 'Baton wysokobiałkowy z migdałami i kokosem', 'not-applicable', null, 'none', '8595229924449'),
  ('PL', '7 Days', 'Grocery', 'Snacks', 'Croissant with Cocoa Filling', 'baked', 'Kaufland', 'palm oil', '5201360521210'),
  ('PL', 'Vitanella', 'Grocery', 'Snacks', 'Barony', 'not-applicable', 'Biedronka', 'none', '8595229923398'),
  ('PL', 'Unknown', 'Grocery', 'Snacks', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', 'not-applicable', null, 'none', '5201049132560'),
  ('PL', 'Tutti', 'Grocery', 'Snacks', 'Batonik twarogowy Tutti w polewie czekoladowej', 'not-applicable', 'Biedronka', 'none', '4770299395595'),
  ('PL', '7days', 'Grocery', 'Snacks', '7days', 'baked', null, 'palm oil', '5201360677351'),
  ('PL', 'Maretti', 'Grocery', 'Snacks', 'Bruschette Chips Pizza Flavour', 'baked', 'Penny', 'none', '3800205871255'),
  ('PL', 'Tastino', 'Grocery', 'Snacks', 'Wafle Kukurydziane', 'baked', null, 'none', '4056489784050'),
  ('PL', 'Pilos', 'Grocery', 'Snacks', 'Barretta al quark gusto Nocciola', 'not-applicable', null, 'none', '20720285'),
  ('PL', 'Aviko', 'Grocery', 'Snacks', 'Frytki karbowane Zig Zag', 'not-applicable', null, 'none', '8710449944439'),
  ('PL', '7 Days', 'Grocery', 'Snacks', 'Family', 'baked', null, 'none', '7622202009051'),
  ('PL', 'Milka', 'Grocery', 'Snacks', 'Cake & Chock', 'not-applicable', null, 'none', '7622300784751'),
  ('PL', 'Wasa', 'Grocery', 'Snacks', 'Lekkie 7 Ziaren', 'baked', null, 'none', '7300400115889')
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
  and product_name not in ('Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 'Baton wysokobiałkowy Peanut Butter', 'Baton białkowy malinowy', 'Wafle ryżowe w czekoladzie mlecznej', 'Wafle ryżowe naturalne', 'Ba! żurawina', 'Surówka Colesław z białej kapusty', 'Oven Baked Krakersy wielozbożowe', 'Wafle mini, zbożowe', 'Mini batoniki z nerkowców à la tarta malinowa', 'Paluszki z solą', 'Wysokobiałkowy Baton Krem Orzechowy Z Nutą Karmelu', 'Słomka ptysiowa', 'Sante Baton Proteinowy Go On Kakaowy', 'Paluszki extra cienkie', 'Kukurydziane - ser', 'Crunchy Cranberry & Raspberry - Santé', 'Paleczki', 'Beskidzkie paluszki o smaku sera i cebulki', 'Protein 33% Caramel', 'Salted cracker', 'Chrupki Curly', 'prezel', 'Krakersy mini', 'San bieszczadzkie suchary', 'Vitamin coconut bar', 'Junior Safari', 'Kokos & Orzech', 'Drobne pieczywo o smaku waniliowym', 'Paluszki solone', 'Protein BarMax Caramel', 'Keto Bar', 'popcorn solony', 'Raspberry & Almond High Protein Bar PROMO', 'dobry chrup', 'Precelki chrupkie', 'Energy Raspberry', 'Baton Proteinowy Smak Waniliowy 50%', 'Chrup Asy Wafle Paprykowe', 'Baton wysokobiałkowy z pistacjami', 'Góralki mleczne', 'Jabłkowo-truskawkowe przekąski', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'Protein vanillia raspberry', 'Baton wysokobiałkowy z migdałami i kokosem', 'Croissant with Cocoa Filling', 'Barony', 'Baton Vitanella z migdałami, żurawiną i orzeszkami ziemnymi', 'Batonik twarogowy Tutti w polewie czekoladowej', '7days', 'Bruschette Chips Pizza Flavour', 'Wafle Kukurydziane', 'Barretta al quark gusto Nocciola', 'Frytki karbowane Zig Zag', 'family', 'Cake & Chock', 'Lekkie 7 Ziaren');
