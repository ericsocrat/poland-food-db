-- PIPELINE (Bread): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Bread'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4056489206026', '4071800038810', '4009249001843', '4009249002277', '4071800058269', '4071800057637', '4061461077563', '4008577006315', '4009249002550', '4061458046046', '4061459698992', '4000446001018', '4061458227650', '4061463060327', '4056489100522', '4008577006391', '4061461010911', '4068445000029', '4009249019954', '4000446011376', '4071800038612', '4009249040071', '4061458176323', '4008577006186', '4068706471902', '4009097010691', '4071800038568', '4061462968624', '4071800048611', '4000446016791', '4068706471896', '4000186010400', '4000446011420', '4000446016630', '4071800038780', '4008577006278', '4061458239240', '4066447370072', '4056489183631', '4061458022040', '4009249019923', '4071800001012', '4061458045759', '4061462084256', '4061458045797', '4061458236928', '4061459425697', '4067796162462', '4061458022033', '4071800000633', '4013752019004', '4071800000879', '4009249001171', '4006170001676', '4061458169066', '4000446015497', '4071800038803', '4071800034508', '4009249022565', '4071800000824', '4009249019916', '4013752019547', '4071800001081', '4071800052618', '4061458054263', '4009249038184', '4015427111112', '4061458045827', '4061459712001', '4061462084454', '4071800000992', '4061458045780', '4071800053462', '4071800003696', '4009249002420', '4071800000909', '4061458055901', '4071800000763', '4056489235750', '4071800058801', '4068706374456', '4056489124184', '4056489123941', '4061461901301', '4013752040541', '4071800060064', '4056489123972', '4061459301335', '4009249002437', '4071800004372', '4056489124191', '4071800034874', '4061461010935', '4056489423867', '4056489096320')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Gräfschafter', 'Grocery', 'Bread', 'Eiweißreiches Weizenvollkornbrot', 'not-applicable', 'Lidl', 'none', '4056489206026'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Körner Balance Sandwich', 'not-applicable', 'Lidl', 'none', '4071800038810'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Sandwich Körner-Harmonie', 'not-applicable', null, 'none', '4009249001843'),
  ('DE', 'Lieken Urkorn', 'Grocery', 'Bread', 'Fitnessbrot mit 5 % Ölsaaten', 'not-applicable', 'Netto', 'none', '4009249002277'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Eiweißbrot', 'not-applicable', null, 'none', '4071800058269'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Harry Dinkel Krüstchen 4071800057637', 'not-applicable', 'Kaufland', 'none', '4071800057637'),
  ('DE', 'Aldi', 'Grocery', 'Bread', 'Das Pure - Bio-Haferbrot mit 29% Ölsaaten', 'not-applicable', 'Aldi', 'none', '4061461077563'),
  ('DE', 'Conditorei Coppenrath & Wiese', 'Grocery', 'Bread', 'Weizenbrötchen', 'not-applicable', 'Lidl', 'none', '4008577006315'),
  ('DE', 'Lieken', 'Grocery', 'Bread', 'Roggenbäcker', 'not-applicable', 'Netto', 'none', '4009249002550'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Französisches Steinofen-Baguette', 'baked', 'Aldi', 'none', '4061458046046'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Laugen-Brioche vorgeschnitten, 6 Stück', 'not-applicable', 'Aldi', 'none', '4061459698992'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', 'Westfälischen Pumpernickel', 'not-applicable', null, 'none', '4000446001018'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Toast-Brötchen Protein', 'not-applicable', 'Aldi', 'none', '4061458227650'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Proteinbrötchen zum Fertigbacken', 'not-applicable', 'Aldi', 'none', '4061463060327'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Mehrkorn-Toastbrötchen', 'not-applicable', 'Lidl', 'none', '4056489100522'),
  ('DE', 'Conditorei Coppenrath & Wiese', 'Grocery', 'Bread', 'Baguette-Brötchen', 'not-applicable', null, 'none', '4008577006391'),
  ('DE', 'Cucina', 'Grocery', 'Bread', 'Grissotti - Olivenöl und Meersalz', 'not-applicable', 'Aldi', 'none', '4061461010911'),
  ('DE', 'K-Classic', 'Grocery', 'Bread', 'Toastbrötchen Mehrkorn', 'not-applicable', 'Kaufland', 'none', '4068445000029'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Körnerharmonie-Toast', 'not-applicable', 'Penny', 'none', '4009249019954'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', 'High Protein Eiweißbrot', 'not-applicable', null, 'none', '4000446011376'),
  ('DE', 'EDEKA Harry', 'Grocery', 'Bread', 'EDEKA Harry Harry XXL Burger Brötchen 4 Stück 300g 1.79€ 1kg 5.97€', 'not-applicable', 'Kaufland', 'none', '4071800038612'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Körner Toasties (2x 3 Stück, 300 g; pro 3 Stück aufgeführt)', 'not-applicable', null, 'none', '4009249040071'),
  ('DE', 'GutBio', 'Grocery', 'Bread', 'Das Pure - Haferbrot mit 27% Ölsaaten', 'not-applicable', null, 'none', '4061458176323'),
  ('DE', 'Coppenrath & Wiese', 'Grocery', 'Bread', 'Dinkelbrötchen', 'not-applicable', null, 'none', '4008577006186'),
  ('DE', 'Aldi', 'Grocery', 'Bread', 'Bio-Landbrötchen - Kernig', 'baked', null, 'none', '4068706471902'),
  ('DE', 'Sinnack', 'Grocery', 'Bread', 'Brot Protein Brötchen', 'not-applicable', null, 'none', '4009097010691'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Körner Balance Toastbrötchen', 'not-applicable', null, 'none', '4071800038568'),
  ('DE', 'Gut Bio', 'Grocery', 'Bread', 'Finnkorn Toastbrötchen', 'not-applicable', null, 'none', '4061462968624'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Dinkel Toastbrötchen 4071800048611', 'not-applicable', null, 'none', '4071800048611'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', 'Mestemacher High Protein Toastbrötchen 4000446016791 Eiweiß Toastbrötchen', 'not-applicable', null, 'none', '4000446016791'),
  ('DE', 'Bio', 'Grocery', 'Bread', 'Bio-Landbrötchen - Weizen', 'not-applicable', null, 'none', '4068706471896'),
  ('DE', 'Leimer', 'Grocery', 'Bread', 'Semmelbrösel', 'not-applicable', null, 'none', '4000186010400'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', 'Eiweißbrot mit Karotten', 'not-applicable', null, 'none', '4000446011420'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', '1 stück Wraps Tortilla', 'not-applicable', null, 'none', '4000446016630'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Körner Balance toast', 'not-applicable', null, 'none', '4071800038780'),
  ('DE', 'Bäcker', 'Grocery', 'Bread', 'Roggenbrötchen', 'not-applicable', null, 'none', '4008577006278'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Toast Brötchen Mehrkorn', 'not-applicable', null, 'none', '4061458239240'),
  ('DE', 'DmBio', 'Grocery', 'Bread', 'Eiweißbrot', 'not-applicable', null, 'none', '4066447370072'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Pure Kornkraft Haferbrot', 'not-applicable', 'Lidl', 'none', '4056489183631'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Vollkorn-Sandwich', 'not-applicable', 'Aldi', 'none', '4061458022040'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Vollkorn-Toast', 'not-applicable', 'Lidl', 'none', '4009249019923'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Harry Brot Vital + Fit', 'not-applicable', null, 'none', '4071800001012'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Vollkorntoast', 'not-applicable', 'Aldi', 'none', '4061458045759'),
  ('DE', 'Meierbaer & Albro', 'Grocery', 'Bread', 'Das Pure - Bio-Haferbrot', 'not-applicable', 'Aldi', 'none', '4061462084256'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Mehrkorn Wraps', 'not-applicable', 'Aldi', 'none', '4061458045797'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Protein-Wraps', 'not-applicable', 'Aldi', 'none', '4061458236928'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Bread', 'Bio-Roggenvollkornbrot', 'not-applicable', 'Aldi', 'none', '4061459425697'),
  ('DE', 'DmBio', 'Grocery', 'Bread', 'Das Pure Hafer - und Saatenbrot', 'not-applicable', null, 'none', '4067796162462'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'American Sandwich - Weizen', 'not-applicable', 'Aldi', 'none', '4061458022033'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Vollkorn Toast', 'not-applicable', null, 'none', '4071800000633'),
  ('DE', 'Brandt', 'Grocery', 'Bread', 'Brandt Markenzwieback', 'not-applicable', null, 'none', '4013752019004'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Unser Mildes (Weizenmischbrot)', 'not-applicable', 'Netto', 'none', '4071800000879'),
  ('DE', 'Lieken', 'Grocery', 'Bread', 'Bauernmild Brot', 'not-applicable', 'Lidl', 'none', '4009249001171'),
  ('DE', 'Lieken Urkorn', 'Grocery', 'Bread', 'Vollkornsaftiges fein', 'not-applicable', 'Netto', 'none', '4006170001676'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Mehrkornschnitten', 'not-applicable', 'Aldi', 'none', '4061458169066'),
  ('DE', 'Mestemacher', 'Grocery', 'Bread', 'Dinkel Wraps', 'not-applicable', null, 'none', '4000446015497'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Toastbrot', 'not-applicable', 'Kaufland', 'none', '4071800038803'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Vollkorn Urtyp', 'not-applicable', null, 'none', '4071800034508'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Vollkorn Toast', 'not-applicable', 'Netto', 'none', '4009249022565'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Harry 1688 Korn an Korn', 'not-applicable', null, 'none', '4071800000824'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Buttertoast', 'not-applicable', 'Lidl', 'none', '4009249019916'),
  ('DE', 'Brandt', 'Grocery', 'Bread', 'Der Markenzwieback', 'not-applicable', 'Netto', 'none', '4013752019547'),
  ('DE', 'Gutes aus der Bäckerei', 'Grocery', 'Bread', 'Weissbrot', 'not-applicable', 'Kaufland', 'none', '4071800001081'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Mischbrot Anno 1688 Klassisch, Harry', 'not-applicable', null, 'none', '4071800052618'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Dreisaatbrot - Roggenvollkornbrot', 'not-applicable', 'Aldi', 'none', '4061458054263'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Dinkel-Harmonie Sandwich', 'not-applicable', null, 'none', '4009249038184'),
  ('DE', 'Filinchen', 'Grocery', 'Bread', 'Das Knusperbrot Original', 'not-applicable', 'Netto', 'none', '4015427111112'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Saaten-Sandwich', 'not-applicable', 'Aldi', 'none', '4061458045827'),
  ('DE', 'Cucina', 'Grocery', 'Bread', 'Pinsa', 'not-applicable', 'Aldi', 'none', '4061459712001'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Bread', 'Das Pure Bio', 'not-applicable', 'Aldi', 'none', '4061462084454'),
  ('DE', 'Harry', 'Grocery', 'Bread', '1688 Mehrkorn', 'not-applicable', null, 'none', '4071800000992'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Wraps - Weizen', 'not-applicable', 'Aldi', 'none', '4061458045780'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Vital & pur', 'not-applicable', null, 'none', '4071800053462'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Vollkorn mit Sonnenblumenkernen', 'not-applicable', 'Kaufland', 'none', '4071800003696'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'Vollkorn-Harmonie Sandwich', 'not-applicable', null, 'none', '4009249002420'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Roggenvollkornbrot Sonnenkern', 'not-applicable', null, 'none', '4071800000909'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Bauernschnitten', 'baked', 'Aldi', 'none', '4061458055901'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Voll:Korn - Katen - Harry 1688', 'not-applicable', null, 'none', '4071800000763'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Bauernmildes Weizenmischbrot', 'not-applicable', 'Lidl', 'none', '4056489235750'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Eiweiss Sandwich', 'not-applicable', null, 'none', '4071800058801'),
  ('DE', 'Aldi', 'Grocery', 'Bread', 'Volles Korn dunkel - Roggenvollkornbrot', 'not-applicable', 'Aldi', 'none', '4068706374456'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'American Style Sandwich Weizen', 'not-applicable', 'Lidl', 'none', '4056489124184'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Pfundsschnitten Roggenmischbrot', 'not-applicable', 'Lidl', 'none', '4056489123941'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Das Rustikale - Dinkel', 'not-applicable', 'Aldi', 'none', '4061461901301'),
  ('DE', 'Brandt', 'Grocery', 'Bread', 'Mini-Zwieback', 'not-applicable', 'Aldi', 'none', '4013752040541'),
  ('DE', 'Kronenbrot', 'Grocery', 'Bread', 'Rustikales Dinkel', 'not-applicable', 'Netto', 'none', '4071800060064'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Balance Brot', 'not-applicable', 'Lidl', 'none', '4056489123972'),
  ('DE', 'Goldähren', 'Grocery', 'Bread', 'Dinkel-Sandwich', 'not-applicable', 'Aldi', 'none', '4061459301335'),
  ('DE', 'Golden Toast', 'Grocery', 'Bread', 'American Sandwich', 'not-applicable', 'Netto', 'none', '4009249002437'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Krustenbrot', 'not-applicable', null, 'none', '4071800004372'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'American Style Sandwich Vollkorn', 'not-applicable', 'Lidl', 'none', '4056489124191'),
  ('DE', 'Harry', 'Grocery', 'Bread', 'Weltmeister Mehrkornbrot', 'not-applicable', null, 'none', '4071800034874'),
  ('DE', 'Cucina', 'Grocery', 'Bread', 'Grissotti - Sesam', 'not-applicable', 'Aldi', 'none', '4061461010935'),
  ('DE', 'Grafschafter', 'Grocery', 'Bread', 'Laugen-Brezeln', 'not-applicable', 'Lidl', 'none', '4056489423867'),
  ('DE', 'Backländer GmbH', 'Grocery', 'Bread', 'Mehrkorn-Schnitten', 'not-applicable', 'Lidl', 'none', '4056489096320')
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
where country = 'DE' and category = 'Bread'
  and is_deprecated is not true
  and product_name not in ('Eiweißreiches Weizenvollkornbrot', 'Körner Balance Sandwich', 'Sandwich Körner-Harmonie', 'Fitnessbrot mit 5 % Ölsaaten', 'Eiweißbrot', 'Harry Dinkel Krüstchen 4071800057637', 'Das Pure - Bio-Haferbrot mit 29% Ölsaaten', 'Weizenbrötchen', 'Roggenbäcker', 'Französisches Steinofen-Baguette', 'Laugen-Brioche vorgeschnitten, 6 Stück', 'Westfälischen Pumpernickel', 'Toast-Brötchen Protein', 'Proteinbrötchen zum Fertigbacken', 'Mehrkorn-Toastbrötchen', 'Baguette-Brötchen', 'Grissotti - Olivenöl und Meersalz', 'Toastbrötchen Mehrkorn', 'Körnerharmonie-Toast', 'High Protein Eiweißbrot', 'EDEKA Harry Harry XXL Burger Brötchen 4 Stück 300g 1.79€ 1kg 5.97€', 'Körner Toasties (2x 3 Stück, 300 g; pro 3 Stück aufgeführt)', 'Das Pure - Haferbrot mit 27% Ölsaaten', 'Dinkelbrötchen', 'Bio-Landbrötchen - Kernig', 'Brot Protein Brötchen', 'Körner Balance Toastbrötchen', 'Finnkorn Toastbrötchen', 'Dinkel Toastbrötchen 4071800048611', 'Mestemacher High Protein Toastbrötchen 4000446016791 Eiweiß Toastbrötchen', 'Bio-Landbrötchen - Weizen', 'Semmelbrösel', 'Eiweißbrot mit Karotten', '1 stück Wraps Tortilla', 'Körner Balance toast', 'Roggenbrötchen', 'Toast Brötchen Mehrkorn', 'Eiweißbrot', 'Pure Kornkraft Haferbrot', 'Vollkorn-Sandwich', 'Vollkorn-Toast', 'Harry Brot Vital + Fit', 'Vollkorntoast', 'Das Pure - Bio-Haferbrot', 'Mehrkorn Wraps', 'Protein-Wraps', 'Bio-Roggenvollkornbrot', 'Das Pure Hafer - und Saatenbrot', 'American Sandwich - Weizen', 'Vollkorn Toast', 'Brandt Markenzwieback', 'Unser Mildes (Weizenmischbrot)', 'Bauernmild Brot', 'Vollkornsaftiges fein', 'Mehrkornschnitten', 'Dinkel Wraps', 'Toastbrot', 'Vollkorn Urtyp', 'Vollkorn Toast', 'Harry 1688 Korn an Korn', 'Buttertoast', 'Der Markenzwieback', 'Weissbrot', 'Mischbrot Anno 1688 Klassisch, Harry', 'Dreisaatbrot - Roggenvollkornbrot', 'Dinkel-Harmonie Sandwich', 'Das Knusperbrot Original', 'Saaten-Sandwich', 'Pinsa', 'Das Pure Bio', '1688 Mehrkorn', 'Wraps - Weizen', 'Vital & pur', 'Vollkorn mit Sonnenblumenkernen', 'Vollkorn-Harmonie Sandwich', 'Roggenvollkornbrot Sonnenkern', 'Bauernschnitten', 'Voll:Korn - Katen - Harry 1688', 'Bauernmildes Weizenmischbrot', 'Eiweiss Sandwich', 'Volles Korn dunkel - Roggenvollkornbrot', 'American Style Sandwich Weizen', 'Pfundsschnitten Roggenmischbrot', 'Das Rustikale - Dinkel', 'Mini-Zwieback', 'Rustikales Dinkel', 'Balance Brot', 'Dinkel-Sandwich', 'American Sandwich', 'Krustenbrot', 'American Style Sandwich Vollkorn', 'Weltmeister Mehrkornbrot', 'Grissotti - Sesam', 'Laugen-Brezeln', 'Mehrkorn-Schnitten');
