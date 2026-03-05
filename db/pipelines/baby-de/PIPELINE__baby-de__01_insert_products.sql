-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Baby'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4062300020719', '4062300362215', '4061459751420', '4062300020313', '4067796017090', '4018852014959', '4062300381971', '4062300255142', '4062300257597', '4004176100539', '4062300406476', '4062300350403', '4018852035855', '4062300123175', '4062300266179', '4062300265967', '4018852030577', '4067796081381', '4062300265998', '4062300166738', '4062300262652', '4062300265608', '4062300266025', '4062300261303', '4062300349445', '4062300432123', '4066447398649', '4062300297104', '4062300290136', '4062300406490', '4058172437892', '4062300269842', '4018852026655', '4062300376182', '4062300398894', '4062300297081', '4062300429710', '4018852035343', '4062300375260', '4062300278530', '4008976091271', '4062300269811', '4062300379503', '4062300379657', '4058172438011', '4000540002560', '4062300376205', '4062300344877', '4062300289406', '4062300208254', '4018852029083')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Reine Bio-Karotten mild-süßlich', 'not-applicable', null, 'none', '4062300020719'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Früchte Riegel Joghurt-Kirsch in Banane', 'not-applicable', null, 'none', '4062300362215'),
  ('DE', 'Mamia Bio', 'Grocery', 'Baby', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'not-applicable', 'Aldi', 'none', '4061459751420'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Allerlei', 'not-applicable', null, 'none', '4062300020313'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Kürbis pur', 'not-applicable', null, 'none', '4067796017090'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Mini-Makkaroni mit buntem Rahmgemüse', 'not-applicable', null, 'none', '4018852014959'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Reiner Butternut Kürbis', 'not-applicable', null, 'none', '4062300381971'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Menü Karotten, Kartoffeln, Wildlachs', 'not-applicable', null, 'none', '4062300255142'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Kürbis Nach Dem 4. Monat', 'not-applicable', null, 'none', '4062300257597'),
  ('DE', 'Puttkammer', 'Grocery', 'Baby', 'Schinkenröllchen in Aspik', 'not-applicable', null, 'none', '4004176100539'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Mango-Bananen-Grieß', 'not-applicable', null, 'none', '4062300406476'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Spinatgemüse in Kartoffeln', 'not-applicable', null, 'none', '4062300350403'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Abendbrei Grieß-Vanille', 'not-applicable', null, 'none', '4018852035855'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Grießbrei', 'not-applicable', null, 'none', '4062300123175'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 'not-applicable', null, 'none', '4062300266179'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Lasagne', 'not-applicable', null, 'none', '4062300265967'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Gemüse-Spätzle-Pfanne', 'not-applicable', null, 'none', '4018852030577'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 'not-applicable', null, 'none', '4067796081381'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 'not-applicable', null, 'none', '4062300265998'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 'not-applicable', null, 'none', '4062300166738'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Erdbeere in Apfel-Joghurt-Müsli', 'not-applicable', null, 'none', '4062300262652'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gartengemüse Mit Pute Und Rosmarin', 'not-applicable', null, 'none', '4062300265608'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 'not-applicable', null, 'none', '4062300266025'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 'not-applicable', null, 'none', '4062300261303'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 'not-applicable', null, 'none', '4062300349445'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hippis Pfirsich Banane Mango Joghurt', 'fermented', null, 'none', '4062300432123'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Hirse Getreidebrei', 'not-applicable', null, 'none', '4066447398649'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Pfirsich in Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4062300297104'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4062300290136'),
  ('DE', 'Unknown', 'Grocery', 'Baby', 'Apfel Bananen müesli', 'not-applicable', null, 'none', '4062300406490'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'not-applicable', null, 'none', '4058172437892'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'not-applicable', null, 'none', '4062300269842'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Anfangsmilch', 'not-applicable', 'Lidl', 'none', '4018852026655'),
  ('DE', 'Hipp Bio', 'Grocery', 'Baby', 'Himbeer Reiswaffeln', 'not-applicable', null, 'none', '4062300376182'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Bio Combiotik Pre', 'dried', null, 'none', '4062300398894'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Baby', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4062300297081'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Urkorn Dinos', 'not-applicable', null, 'none', '4062300429710'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Reis mit Karotten und Pute', 'not-applicable', null, 'none', '4018852035343'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp', 'not-applicable', null, 'none', '4062300375260'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hippis Apfel-Birne-Banane', 'not-applicable', null, 'none', '4062300278530'),
  ('DE', 'Milupa', 'Grocery', 'Baby', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 'not-applicable', null, 'none', '4008976091271'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Apfel Banane in Babykeks', 'not-applicable', null, 'none', '4062300269811'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 'not-applicable', null, 'none', '4062300379503'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp Guten Morgen', 'not-applicable', null, 'none', '4062300379657'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Babyobst', 'not-applicable', null, 'none', '4058172438011'),
  ('DE', 'Kölln', 'Grocery', 'Baby', 'Schmelzflocken 5 korn 6. Monat', 'not-applicable', null, 'none', '4000540002560'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Heidelbeer reiswaffeln', 'not-applicable', null, 'none', '4062300376205'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'BIO Getreidebrei 5-Korn', 'not-applicable', null, 'none', '4062300344877'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'not-applicable', null, 'none', '4062300289406'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp, Karotten Mit Reis Und Wildlachs', 'not-applicable', null, 'none', '4062300208254'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Pfirsich mit Maracuja in Apfel', 'not-applicable', null, 'none', '4018852029083')
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
where country = 'DE' and category = 'Baby'
  and is_deprecated is not true
  and product_name not in ('Reine Bio-Karotten mild-süßlich', 'Früchte Riegel Joghurt-Kirsch in Banane', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'Gemüse Allerlei', 'Kürbis pur', 'Mini-Makkaroni mit buntem Rahmgemüse', 'Reiner Butternut Kürbis', 'Menü Karotten, Kartoffeln, Wildlachs', 'Gemüse Kürbis Nach Dem 4. Monat', 'Schinkenröllchen in Aspik', 'Mango-Bananen-Grieß', 'Spinatgemüse in Kartoffeln', 'Abendbrei Grieß-Vanille', 'Grießbrei', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 'Gemüse Lasagne', 'Gemüse-Spätzle-Pfanne', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 'Erdbeere in Apfel-Joghurt-Müsli', 'Gartengemüse Mit Pute Und Rosmarin', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 'Hippis Pfirsich Banane Mango Joghurt', 'Hirse Getreidebrei', 'Pfirsich in Apfel (ab 5. Monat)', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'Apfel Bananen müesli', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'Anfangsmilch', 'Himbeer Reiswaffeln', 'Bio Combiotik Pre', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 'Urkorn Dinos', 'Reis mit Karotten und Pute', 'Hipp', 'Hippis Apfel-Birne-Banane', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 'Apfel Banane in Babykeks', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 'Hipp Guten Morgen', 'Babyobst', 'Schmelzflocken 5 korn 6. Monat', 'Heidelbeer reiswaffeln', 'BIO Getreidebrei 5-Korn', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'Hipp, Karotten Mit Reis Und Wildlachs', 'Pfirsich mit Maracuja in Apfel');
