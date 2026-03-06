-- PIPELINE (Spreads & Dips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-06

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Spreads & Dips'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900012010828', '5905784351414', '5904378643287', '5904215149460', '5900820021832', '5907222673294', '5904194906641', '5904194906658', '5904194906665', '5904194906672', '5900617039514', '5907517805522', '5907517808240', '5907517801968', '5900344002324', '5903240793884', '5907517805478', '5900617035714', '5901473001868', '5907623268136', '5900617030078', '5904194901271', '5904194900854', '5900617030115', '5902166728161', '5904569550615', '5902425050286', '5902425050293', '5905784305363', '5901752704602', '5907517805447', '5904194902025', '5902241243930', '5903240793433', '5905398585755', '5900562250439', '5901696011644', '5900562266935', '5901891744026', '5900085011180', '5904194906696', '4335619127524', '4056489851400', '5902367409982', '5907517801951', '5900344002201', '5900672300932', '5903240793044', '1532302005449', '5901135010177', '5900783009960', '4056489306344', '20901882', '4056489459545', '4056489459514', '4063367201882', '4063367201837', '8719172050608', '8436008520950', '4063367201967', '4056489339052', '4056489550587', '5202277000515', '4056489306351', '4056489962991', '4056489306368', '20901929', '8436008521414', '4056489459538', '4316734032351', '8590421044872', '5712873674534', '5744001102299', '8588004348585', '4056489508274')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Spreads & Dips by pipeline',
    ean = null
where country = 'PL'
  and category != 'Spreads & Dips'
  and identity_key in ('052ce80dfdd46a0afece9452845ba71d', '05996c149496e85c3f07a321abf02857', '07357211fa90adb6a44255d73f27de14', '096dfcd1cd2a588be7fd03451734db5d', '0b4894261a2b404469ba3607be247d5c', '0f43eb942e8a69a8c3a73a90270985b7', '134d3b37ab2fe1024fca1671f6436957', '15ed4ddf7928224eb7f4569f1c5dc32f', '179bb1853fac0902d65c5736080350e7', '1d37bdba2eac62dc5135bb45462322c0', '1f97e8bc486f2338efaff400ec1e082b', '244377171b7cf208b993cb931e45b97c', '263c4f8293500a443090938b34a2f307', '27d3c79081edef2a1e51c6c3ddb29621', '2adbc92b7288cbd44b59ef785f6edc76', '2b06dd4d4892df01dbdc7b599e04c951', '2b2ef15fb02bb8511965472273d76c52', '2db4e7364260cb93f305067651bed1de', '2f0557781f3e56a742709b2e2ae93703', '309981e864b7dad2d97226490b5c3278', '321edf0bee4598006fbca1ebd733c60e', '32e75021e650960edb1a3135e5cfaf11', '35cc7f925b2c6e2116aef06a82eef8e5', '3e99f6b7ddbbb9079b22959291f018f1', '488561b5e612f2cbc15665fc6e88ba43', '4cf1162265a5550003d72141da5bda5c', '4e3f6daebd036da53ba8dc87206cd8ff', '4f5ef301467cb90cc889868079863540', '569a24e3926e732f5a0a4bbc78f59f89', '575eb018d622bd8983ee2b8ea2b424a8', '57f89c2d81ab98dcfd69b815d7b5b28c', '5b9e0f738e4ad07d9665b856764302ef', '5bf4db54706babd7c689e7bb4121b360', '5dcc274146aa79c50f600e7c4d72196a', '60932cd6f946dc5e42fc2f2c8fd13567', '61e4aabe64d7b3a081dc4fd9ea5ef13f', '6253ea933aa9c1610ee4e02de6676a94', '63fb552162b71edf6f0bf6c8855779f6', '663d69e1e1f357653db21b8d290c9e17', '708dca168bb3ce4cb57ee54664790495', '71e435b4989f9a81364983f5c54d346f', '75636d1d5ba58b5476c7a0d3dad588ba', '760f75bca29e704cdb7f286eb5b871fa', '7831ac74f3bccb3e19dd38d8b976c504', '800616210fd783ba4dfaf60be9f5c59d', '8714a69977506dc5566c93701802a49f', '87dad6355c563eb170f79743f53392e2', '899dcfb8f168543ee0a608a73a377491', '8ab0b141a4160101499ea49716131ca6', '92227b34923fb8ff3b8ede3ee4d36e5e', '92531c73d68a6ecdf8cbb641baf5a39e', '933376eb8d23e7e034b595652e23f3fc', '941222a1fd43b3a52be79a3f82254ffc', '98355968466a096792df47a30906c2bb', '997eb71ba14994bc5b16c78d02dd691e', 'aea8034a3e2d5524b2ed3cf3bfc638fa', 'afb4277d464f05edf0bb2290ec4858cc', 'b51ab4347151e41ffd712c7c4cf35b87', 'b6933d00ca20182f9804a39de02e0c85', 'b760cab63cf8f9758b3f9a7c32a7e8b4', 'bb72c0bb4bdeb3d9a65b3495b8dc943e', 'bd227126dcf7792f1cb772d4592760ef', 'c2795fa7bdfe95ada50a157facf2e218', 'c4849dc26bb6dfd5557ecc6fb6b9da37', 'c57096c8d10af9ac4d35a1f6bccb032d', 'cddac6e64fce0abbb600a95c891239ce', 'd1a253256c51bec1b1e8c8f5cfcab936', 'df53eb3ae106ce840f14cad21948ac70', 'df9ee634462c566d2a5e4fd2242c6cbf', 'e079a23e5c5cf669560d0584b922713b', 'e7f77d467260ba539cc2d7b4ebef9a31', 'ebda197b1de70ac9daaade026a84c1f1', 'f1a02f7059b4705dd5cbd486aa28ecf2', 'f40606b2c0c192271ec15186d4804d0e', 'f8271369be32ad98177f60c0e11dad52')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Wawrzyniec', 'Grocery', 'Spreads & Dips', 'Hummus z pestkami dyni i słonecznika', 'not-applicable', 'Rossmann', 'none', '5900012010828'),
  ('PL', 'Sensation', 'Grocery', 'Spreads & Dips', 'Ajvar łagodny', 'not-applicable', 'Carrefour', 'none', '5905784351414'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Spreads & Dips', 'Ajvar łagodny', 'not-applicable', null, 'none', '5904378643287'),
  ('PL', 'Auchan', 'Grocery', 'Spreads & Dips', 'Hummus z solą morską', 'not-applicable', 'Auchan', 'none', '5904215149460'),
  ('PL', 'Mlekpol', 'Grocery', 'Spreads & Dips', 'Dip śmietankowy z czosnkiem i ziołami', 'fermented', null, 'none', '5900820021832'),
  ('PL', 'Niewieścin', 'Grocery', 'Spreads & Dips', 'Pasztetowa Podwędzana', 'not-applicable', null, 'none', '5907222673294'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus klasyczny', 'not-applicable', 'Biedronka', 'none', '5904194906641'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus paprykowy', 'not-applicable', 'Biedronka', 'none', '5904194906658'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus pomidorowy', 'not-applicable', 'Biedronka', 'none', '5904194906665'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus z ciecierzycy z burakiem', 'not-applicable', 'Biedronka', 'none', '5904194906672'),
  ('PL', 'I&lt;3vege', 'Grocery', 'Spreads & Dips', 'Hummus z papryką na ostro', 'not-applicable', null, 'none', '5900617039514'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus', 'not-applicable', 'Biedronka', 'none', '5907517805522'),
  ('PL', 'Go Vege', 'Grocery', 'Spreads & Dips', 'Hummus z burakiem', 'not-applicable', 'Biedronka', 'none', '5907517808240'),
  ('PL', 'Vital Fresh', 'Grocery', 'Spreads & Dips', 'Hummus pomidorowy', 'not-applicable', 'Biedronka', 'none', '5907517801968'),
  ('PL', 'Lisner', 'Grocery', 'Spreads & Dips', 'Hummus z wędzonym pstrągiem', 'smoked', null, 'none', '5900344002324'),
  ('PL', 'Lavica Food', 'Grocery', 'Spreads & Dips', 'Hummus dynia & imbir', 'not-applicable', 'Kaufland', 'none', '5903240793884'),
  ('PL', 'SmaczneGo!', 'Grocery', 'Spreads & Dips', 'Hummus klasyczny z preclami', 'not-applicable', null, 'none', '5907517805478'),
  ('PL', 'I-love-vege', 'Grocery', 'Spreads & Dips', 'Hummus z suszonymi pomidorami', 'not-applicable', null, 'none', '5900617035714'),
  ('PL', 'Well Well', 'Grocery', 'Spreads & Dips', 'Hummus klasyczny', 'not-applicable', null, 'none', '5901473001868'),
  ('PL', 'Dega', 'Grocery', 'Spreads & Dips', 'Hummus', 'not-applicable', null, 'none', '5907623268136'),
  ('PL', 'Lovege', 'Grocery', 'Spreads & Dips', 'Hummus Klasyczny', 'not-applicable', null, 'none', '5900617030078'),
  ('PL', 'Perla', 'Grocery', 'Spreads & Dips', 'Pomidor hummus', 'not-applicable', 'Aldi', 'none', '5904194901271'),
  ('PL', 'Perla', 'Grocery', 'Spreads & Dips', 'Hummus Trio', 'not-applicable', null, 'none', '5904194900854'),
  ('PL', 'I love vege', 'Grocery', 'Spreads & Dips', 'Sante Hummus With Dried Tomatoes 180 G', 'dried', null, 'none', '5900617030115'),
  ('PL', 'Helcom', 'Grocery', 'Spreads & Dips', 'Dip in mexicana style', 'not-applicable', null, 'none', '5902166728161'),
  ('PL', 'Zdrowidło', 'Grocery', 'Spreads & Dips', 'Hummus kremowy z ciecierzycy klasyczny', 'not-applicable', null, 'none', '5904569550615'),
  ('PL', 'NaturAvena', 'Grocery', 'Spreads & Dips', 'Ekologiczny hummus oliwkowy', 'not-applicable', null, 'none', '5902425050286'),
  ('PL', 'NaturAvena', 'Grocery', 'Spreads & Dips', 'Ekologiczny hummus paprykowy', 'not-applicable', null, 'none', '5902425050293'),
  ('PL', 'Sensation', 'Grocery', 'Spreads & Dips', 'Vegetal Hummus - paprykowy', 'not-applicable', null, 'none', '5905784305363'),
  ('PL', 'Casa Del Sur', 'Grocery', 'Spreads & Dips', 'Salsa dip cheese', 'fermented', null, 'none', '5901752704602'),
  ('PL', 'Perla', 'Grocery', 'Spreads & Dips', 'SmaczneGo! - hummus klasyczny z preclami', 'not-applicable', null, 'none', '5907517805447'),
  ('PL', 'Perla', 'Grocery', 'Spreads & Dips', 'Hummus', 'not-applicable', null, 'none', '5904194902025'),
  ('PL', 'Metro chef', 'Grocery', 'Spreads & Dips', 'Hummus tradycyjny', 'not-applicable', null, 'none', '5902241243930'),
  ('PL', 'Lavica food', 'Grocery', 'Spreads & Dips', 'Hummus klasyczny', 'not-applicable', null, 'none', '5903240793433'),
  ('PL', 'Lavica food', 'Grocery', 'Spreads & Dips', 'Hummus proteinowy klasyczny', 'not-applicable', null, 'none', '5905398585755'),
  ('PL', 'Sokołów', 'Grocery', 'Spreads & Dips', 'Pasztet basi', 'not-applicable', null, 'none', '5900562250439'),
  ('PL', 'Profi', 'Grocery', 'Spreads & Dips', 'Pasztet Dworski Z Dzikiem', 'not-applicable', null, 'none', '5901696011644'),
  ('PL', 'Sokołów', 'Grocery', 'Spreads & Dips', 'Pasztet dzidunia', 'not-applicable', null, 'none', '5900562266935'),
  ('PL', 'Gzella', 'Grocery', 'Spreads & Dips', 'Pasztet z borowikami', 'not-applicable', null, 'none', '5901891744026'),
  ('PL', 'Nestlé', 'Grocery', 'Spreads & Dips', 'Przyprawa Maggi', 'not-applicable', null, 'none', '5900085011180'),
  ('PL', 'Unknown', 'Grocery', 'Spreads & Dips', 'Hummus z ciecierzycy spicy salsa go vege', 'not-applicable', null, 'none', '5904194906696'),
  ('PL', 'Vemondo', 'Grocery', 'Spreads & Dips', 'Hummus z pastą sezamowa i pesto bazyliowym', 'not-applicable', null, 'none', '4335619127524'),
  ('PL', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Guacamole Z Kawałkami Awokado', 'not-applicable', null, 'none', '4056489851400'),
  ('PL', 'Unknown', 'Grocery', 'Spreads & Dips', 'Ekologiczny Hummus Naturalny', 'not-applicable', null, 'none', '5902367409982'),
  ('PL', 'Vital Fresh Biedronka', 'Grocery', 'Spreads & Dips', 'Hummus paprykowy', 'not-applicable', null, 'none', '5907517801951'),
  ('PL', 'Lisner', 'Grocery', 'Spreads & Dips', 'Hummus clasic', 'not-applicable', null, 'none', '5900344002201'),
  ('PL', 'Primavika', 'Grocery', 'Spreads & Dips', 'Humus naturalny', 'not-applicable', null, 'none', '5900672300932'),
  ('PL', 'Lavica Food', 'Grocery', 'Spreads & Dips', 'Hummus z suszonymi pomidorami', 'not-applicable', null, 'none', '5903240793044'),
  ('PL', 'Sobkowiak', 'Grocery', 'Spreads & Dips', 'Pasztet pieczony z żurawiną', 'roasted', null, 'none', '1532302005449'),
  ('PL', 'Tzatziki', 'Grocery', 'Spreads & Dips', 'Taziki', 'not-applicable', null, 'none', '5901135010177'),
  ('PL', 'Pudliszki', 'Grocery', 'Spreads & Dips', 'Pudliszki', 'not-applicable', null, 'none', '5900783009960'),
  ('PL', 'Vemondo', 'Grocery', 'Spreads & Dips', 'Hummus klasyczny', 'not-applicable', 'Lidl', 'none', '4056489306344'),
  ('PL', 'Chef select', 'Grocery', 'Spreads & Dips', 'Hummus classic', 'not-applicable', 'Lidl', 'none', '20901882'),
  ('PL', 'Deluxe', 'Grocery', 'Spreads & Dips', 'Hummus und Guacamole', 'not-applicable', 'Lidl', 'none', '4056489459545'),
  ('PL', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Hummus bruschetta', 'not-applicable', 'Lidl', 'none', '4056489459514'),
  ('PL', 'K-take it veggie', 'Grocery', 'Spreads & Dips', 'K-take it veggie Hummus Tomato', 'not-applicable', 'Kaufland', 'none', '4063367201882'),
  ('PL', 'K-take it veggie', 'Grocery', 'Spreads & Dips', 'K-take it veggie Hummus Red Pepper 200g', 'not-applicable', 'Kaufland', 'none', '4063367201837'),
  ('PL', 'Taverna-Bio', 'Grocery', 'Spreads & Dips', 'Classic Hummus', 'not-applicable', 'Auchan', 'none', '8719172050608'),
  ('PL', 'Vital', 'Grocery', 'Spreads & Dips', 'Guacamole', 'not-applicable', 'Biedronka', 'none', '8436008520950'),
  ('PL', 'K-take it veggie', 'Grocery', 'Spreads & Dips', 'K-take it veggie Hummus Classic', 'not-applicable', 'Kaufland', 'none', '4063367201967'),
  ('PL', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Hummus z sosem pomidorowym', 'not-applicable', 'Lidl', 'none', '4056489339052'),
  ('PL', 'Vitasia', 'Grocery', 'Spreads & Dips', 'Hummus sweet chili', 'not-applicable', 'Lidl', 'none', '4056489550587'),
  ('PL', 'Athos', 'Grocery', 'Spreads & Dips', 'Tzatziki', 'not-applicable', 'Kaufland', 'none', '5202277000515'),
  ('PL', 'Chef select', 'Grocery', 'Spreads & Dips', 'Bio Hummus paprykowy', 'not-applicable', null, 'none', '4056489306351'),
  ('PL', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Guacamole mild', 'not-applicable', null, 'none', '4056489962991'),
  ('PL', 'Chef select', 'Grocery', 'Spreads & Dips', 'Bio Hummus pomidorowy', 'not-applicable', null, 'none', '4056489306368'),
  ('PL', 'Vemondo', 'Grocery', 'Spreads & Dips', 'Hummus Paprykowy', 'not-applicable', null, 'none', '20901929'),
  ('PL', 'Vital Fresh', 'Grocery', 'Spreads & Dips', 'Guacamole', 'not-applicable', null, 'none', '8436008521414'),
  ('PL', 'Lidl', 'Grocery', 'Spreads & Dips', 'Hummus mit falafel & mango mousse', 'not-applicable', null, 'none', '4056489459538'),
  ('PL', 'Doyal', 'Grocery', 'Spreads & Dips', 'Humus', 'not-applicable', null, 'none', '4316734032351'),
  ('PL', 'Nature''s Promise', 'Grocery', 'Spreads & Dips', 'Hummus klasik', 'not-applicable', null, 'none', '8590421044872'),
  ('PL', 'La campagna', 'Grocery', 'Spreads & Dips', 'Hummus', 'not-applicable', null, 'none', '5712873674534'),
  ('PL', 'Meyers', 'Grocery', 'Spreads & Dips', 'Hummus', 'not-applicable', null, 'none', '5744001102299'),
  ('PL', 'Taverna', 'Grocery', 'Spreads & Dips', 'Hummus coriander & lemon', 'not-applicable', null, 'none', '8588004348585'),
  ('PL', 'Pikok', 'Grocery', 'Spreads & Dips', 'Pasztet z indyka', 'not-applicable', null, 'none', '4056489508274')
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
where country = 'PL' and category = 'Spreads & Dips'
  and is_deprecated is not true
  and product_name not in ('Hummus z pestkami dyni i słonecznika', 'Ajvar łagodny', 'Ajvar łagodny', 'Hummus z solą morską', 'Dip śmietankowy z czosnkiem i ziołami', 'Pasztetowa Podwędzana', 'Hummus klasyczny', 'Hummus paprykowy', 'Hummus pomidorowy', 'Hummus z ciecierzycy z burakiem', 'Hummus z papryką na ostro', 'Hummus', 'Hummus z burakiem', 'Hummus pomidorowy', 'Hummus z wędzonym pstrągiem', 'Hummus dynia & imbir', 'Hummus klasyczny z preclami', 'Hummus z suszonymi pomidorami', 'Hummus klasyczny', 'Hummus', 'Hummus Klasyczny', 'Pomidor hummus', 'Hummus Trio', 'Sante Hummus With Dried Tomatoes 180 G', 'Dip in mexicana style', 'Hummus kremowy z ciecierzycy klasyczny', 'Ekologiczny hummus oliwkowy', 'Ekologiczny hummus paprykowy', 'Vegetal Hummus - paprykowy', 'Salsa dip cheese', 'SmaczneGo! - hummus klasyczny z preclami', 'Hummus', 'Hummus tradycyjny', 'Hummus klasyczny', 'Hummus proteinowy klasyczny', 'Pasztet basi', 'Pasztet Dworski Z Dzikiem', 'Pasztet dzidunia', 'Pasztet z borowikami', 'Przyprawa Maggi', 'Hummus z ciecierzycy spicy salsa go vege', 'Hummus z pastą sezamowa i pesto bazyliowym', 'Guacamole Z Kawałkami Awokado', 'Ekologiczny Hummus Naturalny', 'Hummus paprykowy', 'Hummus clasic', 'Humus naturalny', 'Hummus z suszonymi pomidorami', 'Pasztet pieczony z żurawiną', 'Taziki', 'Pudliszki', 'Hummus klasyczny', 'Hummus classic', 'Hummus und Guacamole', 'Hummus bruschetta', 'K-take it veggie Hummus Tomato', 'K-take it veggie Hummus Red Pepper 200g', 'Classic Hummus', 'Guacamole', 'K-take it veggie Hummus Classic', 'Hummus z sosem pomidorowym', 'Hummus sweet chili', 'Tzatziki', 'Bio Hummus paprykowy', 'Guacamole mild', 'Bio Hummus pomidorowy', 'Hummus Paprykowy', 'Guacamole', 'Hummus mit falafel & mango mousse', 'Humus', 'Hummus klasik', 'Hummus', 'Hummus', 'Hummus coriander & lemon', 'Pasztet z indyka');
