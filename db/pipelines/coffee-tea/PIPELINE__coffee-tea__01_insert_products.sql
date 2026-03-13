-- PIPELINE (Coffee & Tea): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Coffee & Tea'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900956000688', '5900956003634', '5900649079229', '5902891280224', '5906041030233', '5900956000640', '5905548351179', '5907658333458', '5905548350134', '5900956700113', '5901583413926', '5900300550159', '5900396015723', '5900300550203', '5902891280217', '5902891280200', '5902891280194', '5900649079236', '5902891280231', '5902891280279', '5902891280248', '5900649050327', '5900649062740', '5900649077997', '5904448000088', '5900649078659', '5900649078017', '5900649057494', '5900497043243', '5900497043182', '5900956000633', '5900956006505', '4792331001226', '5901483081003', '5903050791582', '5900888013312', '5900956000671', '5905548350370', '5900497043267', '8720608009718', '5905548350288', '7613031918881', '3560071230494', '3245414249950', '3560070713110', '3560070755370', '3560070826063', '3560071013714', '3560071013721', '3560071013745', '8711000422069', '3560071234027', '3560071230517', '3560071244057', '3560071230500', '3560071432218', '3560071432270', '3560071432096', '3560071452278', '3560071479398', '3560071504564', '3560071432034', '3560071448561', '6922163616734', '8714100088944', '8717163856741', '8718114822853', '8000070020580', '8711000521045', '8711000521106', '4056489591528', '0080552571807', '8996001600221', '7613038887333', '4100290024987', '8711000680131', '8711000454428', '0613008761615', '5410033851336', '5449000236623', '8714100807354', '8712566388141', '8720608013661', '8722700140535', '4798810009646')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Coffee & Tea by pipeline',
    ean = null
where country = 'PL'
  and category != 'Coffee & Tea'
  and identity_key in ('012304f39fa92c6e3757babf43720262', '04af17bd332eac1aaba159daecda27e4', '086ce438ecb8d1aee9fa2cce47786a14', '09d53ea462d504a10e34ed72897ac0ec', '0a2118bc5455138bb9fd19b0b2cebdf4', '0e6792b85aca53d68378e49045a00113', '0ec2312397458e7ff0de4a2aa3da26d0', '10e8178e92f10e8af128029e67451400', '1230c9e8b564224e74ee3f2261de9645', '12674a81c414a140582f0a6f08949985', '1835c74e873abe225a3d575918ee018d', '1c28148082527be1a470643a3e1625df', '216d4299072e5ffc806647b2a469a691', '24cc006b9f33c141d23139cbb08c4c06', '2717e8b56285d96e2de65b336200d674', '28a38d0148eab43c40744fc8e9d4c406', '29d8c0f019adbd5fbfbf437c43d2f2ed', '2c50e0618af2c8de3321d989cfbd9556', '32375b75f04ab6bb510f18195d0c9bbe', '3392cb1a98e52a396a4fabc55c2b53f7', '39e671d5861c363985f2206bc5d9b504', '3da8ba194c59e2ed6fc52d855c89da98', '41d7c1eb28b9f9d19b2c4c8aa2ca4e6b', '41f6d7ecf6c746055f5561c7aee69977', '42c214304a3f740e49aa6bb4f43e9ca2', '4418b20559c1125ea52d2783f5046b9c', '46e23ce65cf2ba7a373dcfddf5d30e09', '46e96e24ad4988c25688f5f2ad04f3a1', '483887d6d890937ce5f8f5f6be13a602', '4b4341d7fddd4f51b0e4cf9d3131f122', '4bebbc4731e2fc267999eef30cd8cc72', '4f77da8a66be4a968b2f2f00ac7db3d2', '4fcd07d956ab270f3f72eb19328839a2', '5099cf2258014c05e1a4d890a62cf6d5', '52241b15143f3908a65a7fa47c567c24', '588cd9e75de7f1d8690a4babd7c119ad', '5b384dfa558e67b98da098aa865ccdfa', '5c4a2e4f1dca20c24eb8603f302b61f9', '5c7b713d94d6a03619955943090ec66d', '5f5067c7efde21938ce4baeaf00e3338', '616266a052c11069f3c69ef27ee1b514', '6239fefffc2f012c7f99768e740a0e6b', '713b4ce88cd1a54b6e1d6820cbad6e63', '7632cf4bab11894438174e2ed62536d6', '792b7ebef1a90d4a37ed312c61301981', '7a5914c7322d66332a11e6e3520f3aae', '81232d012abfe44d5a376cf94c4c45a3', '841988af12e09e6a0296eaa3d4244e42', '843eb8f5515f3c9aed0ac197867dc7b4', '84d2122f322e4a35542b1eb1bd1825ab', '8a4a29784853bc356cd8d2e58b4c84f2', '8a6e056f2ee8a946deefde06caed6321', '8cf05115705a41168fd2a3ecc2ffdb7a', '8e31d4e0bf7e20485014357e832cd142', '927fd48fa6b22697192423706d848f0a', '9931ffa68a5c33d205a9c673ab8add6f', '9b5c7c697ab4fb3132adf9486e77b7e2', '9ef28399867c7cb27b8fa00623fc9e06', 'ae0660d5575dbde9ee3843662554ba35', 'b26f293d016db0487609bc9d85ca63ea', 'b67deea2b107e55f10e1ac0f3cb0b6fc', 'b736eb76f645bff0f7ab92a110f470fa', 'b79fd27b458e6506c6ee8fd917d8b62f', 'b850cf54a9c326b4d5c187205abe1350', 'b9d911347b24e52f1972689f0893bdb3', 'bcee9b6b720a6fd39eb3a9ec2c0c4a80', 'be7a59c561b68aacc49617d15b412d99', 'c3ed0f9e65fe32300c7e0229cdc69f81', 'cd1af9dbad7b64b2ac64dfa3a1560e92', 'd109bca4ce010bc260667fd5b19674c0', 'd29d05dcc848d1bfe283ca6fd7abd045', 'd5022cfc2d8c2e37eaa8c0c456155107', 'd64b894e05affc5c09c36f5cc0de5ee6', 'd7afd02f802d7005459312680e898eff', 'df67f7157ec4ec05dda01438fb9d564b', 'dfbcc8849ac4f46c76efe298a20fc159', 'e1957696f49239ada213c00c8772773e', 'e19a702ff9887af3f9d72e93720fd18f', 'e322db6524cf7c9a40c8bfcc09ba26a3', 'e331189b9980baba3571ed6beaecad90', 'e799aaf714d5e55c93dece59d2f3221b', 'f2650795f3d22f879816a9beed1d1920', 'f4729ca4fd326ea6ae6fd601e6b1649c', 'fb3b484b3d94404668757bdb72bdd0ac', 'fd566bf9358f74f6aa6d1f7e4f4625fd')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Herbaciany ogród - Prosto z lasu.', 'not-applicable', 'Dino', 'none', '5900956000688'),
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Herbaciany ogród, malina z żurawiną', 'not-applicable', 'Biedronka', 'none', '5900956003634'),
  ('PL', 'Cafe d''Or', 'Grocery', 'Coffee & Tea', 'Cappuccino o smaku śmietankowym', 'not-applicable', null, 'none', '5900649079229'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Mokate Cappuccino z belgijską czekoladą', 'not-applicable', null, 'none', '5902891280224'),
  ('PL', 'PKN Orlen', 'Grocery', 'Coffee & Tea', 'Napój kawowy na bazie pełnego mleka i śmietanki', 'not-applicable', null, 'none', '5906041030233'),
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Herbapol Herbaciany Ogród Briar Rose Fruit-herbal Tea', 'not-applicable', null, 'none', '5900956000640'),
  ('PL', 'Big Active', 'Grocery', 'Coffee & Tea', 'Herbata biała tajska cytryna, kwiat granatu', 'not-applicable', null, 'none', '5905548351179'),
  ('PL', 'Big-Active', 'Grocery', 'Coffee & Tea', 'Early Grey & płatki róży', 'not-applicable', null, 'none', '5907658333458'),
  ('PL', 'Big-Active', 'Grocery', 'Coffee & Tea', 'Zielona herbata z kawałkami opuncji', 'not-applicable', null, 'none', '5905548350134'),
  ('PL', 'Big Active', 'Grocery', 'Coffee & Tea', 'Herbata biała jaśmin', 'not-applicable', null, 'none', '5900956700113'),
  ('PL', 'Cafe d''or', 'Grocery', 'Coffee & Tea', 'Kawa rozpuszczalna gold liofilizowana robusta/arabica', 'not-applicable', 'Biedronka', 'none', '5901583413926'),
  ('PL', 'Unilever', 'Grocery', 'Coffee & Tea', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'not-applicable', 'Biedronka', 'none', '5900300550159'),
  ('PL', 'Remsey', 'Grocery', 'Coffee & Tea', 'Herbata czarna aromatyzowana Earl Grey Strong w torebkach do zaparzania', 'not-applicable', 'Biedronka', 'none', '5900396015723'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Yellow Label', 'not-applicable', 'Biedronka', 'none', '5900300550203'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino', 'not-applicable', null, 'none', '5902891280217'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Mokate Cappuccino smak smietankowy', 'not-applicable', null, 'none', '5902891280200'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino o smaku orzechowym', 'not-applicable', null, 'none', '5902891280194'),
  ('PL', 'Cafe d''Or', 'Grocery', 'Coffee & Tea', 'Cappuccino', 'not-applicable', null, 'none', '5900649079236'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino z magnezem', 'not-applicable', null, 'none', '5902891280231'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino o smaku rumowym', 'dried', null, 'none', '5902891280279'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino caffee', 'not-applicable', null, 'none', '5902891280248'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino vanilla', 'not-applicable', null, 'none', '5900649050327'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Cappuccino karmelowe', 'not-applicable', null, 'none', '5900649062740'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Mokate Gold Latte Caramel', 'not-applicable', null, 'none', '5900649077997'),
  ('PL', 'Senso', 'Grocery', 'Coffee & Tea', 'Pumpkin Spice Latte Coffe', 'not-applicable', null, 'none', '5904448000088'),
  ('PL', 'Mokate Gold', 'Grocery', 'Coffee & Tea', 'Vanilla late', 'not-applicable', null, 'none', '5900649078659'),
  ('PL', 'Mokate', 'Grocery', 'Coffee & Tea', 'Mokate mocha double chocolate', 'not-applicable', null, 'none', '5900649078017'),
  ('PL', 'Cafe d''Or', 'Grocery', 'Coffee & Tea', 'Cappuccino o smaku orzechowym', 'not-applicable', null, 'none', '5900649057494'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Ice Tea Peach', 'not-applicable', null, 'none', '5900497043243'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Green Ice Tea', 'not-applicable', null, 'none', '5900497043182'),
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Malina', 'not-applicable', null, 'none', '5900956000633'),
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Herbatka na zimno Truskawka Rabarbar', 'not-applicable', null, 'none', '5900956006505'),
  ('PL', 'Sir Adalbert''s tea', 'Grocery', 'Coffee & Tea', 'Herbata czarna earl grey liściasta', 'not-applicable', 'Kaufland', 'none', '4792331001226'),
  ('PL', 'Bifix', 'Grocery', 'Coffee & Tea', 'Herbata z suszu owocowego', 'not-applicable', null, 'none', '5901483081003'),
  ('PL', 'Asia Flavours', 'Grocery', 'Coffee & Tea', 'Matcha', 'not-applicable', null, 'none', '5903050791582'),
  ('PL', 'Milton', 'Grocery', 'Coffee & Tea', 'Herbata zielona o smaku grejpfrutowym', 'not-applicable', null, 'none', '5900888013312'),
  ('PL', 'Herbapol', 'Grocery', 'Coffee & Tea', 'Herb. aronia Herbapol 20SZT', 'not-applicable', null, 'none', '5900956000671'),
  ('PL', 'Big-active', 'Grocery', 'Coffee & Tea', 'Zielona herbata w torebkach', 'not-applicable', null, 'none', '5905548350370'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Lipton Green 0.5', 'not-applicable', null, 'none', '5900497043267'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Zielona herbata z nutą truskawki i maliny', 'not-applicable', null, 'none', '8720608009718'),
  ('PL', 'Unknown', 'Grocery', 'Coffee & Tea', 'Herbata Bio-active Li Zielona Z Owoc Malin 100G', 'not-applicable', null, 'none', '5905548350288'),
  ('PL', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Nescafe', 'not-applicable', 'Carrefour', 'none', '7613031918881'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Intenso', 'not-applicable', 'Carrefour', 'none', '3560071230494'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Classico', 'not-applicable', 'Carrefour', 'none', '3245414249950'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Dolce', 'not-applicable', 'Carrefour', 'none', '3560070713110'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Cappuccino', 'not-applicable', 'Carrefour', 'none', '3560070755370'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Latte Macchiato', 'not-applicable', 'Carrefour', 'none', '3560070826063'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Cappuccino Vanilata', 'not-applicable', 'Carrefour', 'none', '3560071013714'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'CAPPUCCINO Decaffeinato', 'not-applicable', 'Carrefour', 'none', '3560071013721'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'CAPPUCCINO Chocolate', 'not-applicable', 'Carrefour', 'none', '3560071013745'),
  ('PL', 'L''Or Barista', 'Grocery', 'Coffee & Tea', 'L''or Barista Double Ristretto Intensity 11', 'not-applicable', 'Carrefour', 'none', '8711000422069'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Lungo Généreux et Fruité', 'not-applicable', 'Carrefour', 'none', '3560071234027'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Pérou', 'not-applicable', 'Carrefour', 'none', '3560071230517'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Coffee & Tea', 'AMÉRIQUE LATINE GRAINS Pur Arabica', 'not-applicable', 'Carrefour', 'none', '3560071244057'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Coffee & Tea', 'Amérique Latine', 'not-applicable', 'Carrefour', 'none', '3560071230500'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Espresso nocciolita', 'not-applicable', 'Carrefour', 'none', '3560071432218'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Espresso Colombie', 'not-applicable', 'Carrefour', 'none', '3560071432270'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Lungo Voluptuo', 'not-applicable', 'Carrefour', 'none', '3560071432096'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Café Grande 100% Arabica', 'not-applicable', 'Carrefour', 'none', '3560071452278'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Cappuccino ORIGINAL', 'not-applicable', 'Carrefour', 'none', '3560071479398'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Caffe latte', 'not-applicable', 'Carrefour', 'none', '3560071504564'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Espresso decaffeinato', 'not-applicable', 'Carrefour', 'none', '3560071432034'),
  ('PL', 'Carrefour', 'Grocery', 'Coffee & Tea', 'Espresso', 'not-applicable', 'Carrefour', 'none', '3560071448561'),
  ('PL', 'Tian Ku Shan', 'Grocery', 'Coffee & Tea', 'Matcha Tea powder', 'not-applicable', 'Netto', 'none', '6922163616734'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Herbata czarna z naturalnym aromatem', 'not-applicable', 'Biedronka', 'none', '8714100088944'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Pokrzywa z mango', 'not-applicable', 'Auchan', 'none', '8717163856741'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Yellow Label granulowana', 'not-applicable', 'Biedronka', 'none', '8718114822853'),
  ('PL', 'Lavazza', 'Grocery', 'Coffee & Tea', 'Qualita Oro', 'not-applicable', null, 'none', '8000070020580'),
  ('PL', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Kawa rozpuszczalna Jacobs Krönung', 'not-applicable', null, 'none', '8711000521045'),
  ('PL', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Crema', 'not-applicable', null, 'none', '8711000521106'),
  ('PL', 'Vemondo', 'Grocery', 'Coffee & Tea', 'Kaffee Hafer', 'not-applicable', null, 'none', '4056489591528'),
  ('PL', 'Cafe d''or', 'Grocery', 'Coffee & Tea', 'Ice Coffee Macchiato', 'not-applicable', null, 'none', '0080552571807'),
  ('PL', 'Kopiko', 'Grocery', 'Coffee & Tea', 'Kopiko', 'not-applicable', null, 'none', '8996001600221'),
  ('PL', 'Nescafé', 'Grocery', 'Coffee & Tea', 'Frappé 3in1', 'not-applicable', null, 'none', '7613038887333'),
  ('PL', 'Starbucks', 'Grocery', 'Coffee & Tea', 'Caramel macchiato', 'not-applicable', null, 'none', '4100290024987'),
  ('PL', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Jacobs CAPPUCCINO ORIGINAL', 'not-applicable', null, 'none', '8711000680131'),
  ('PL', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Jacobs', 'not-applicable', null, 'none', '8711000454428'),
  ('PL', 'Arizona', 'Grocery', 'Coffee & Tea', 'Green tea', 'not-applicable', null, 'none', '0613008761615'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Earl Grey (classic) - Lipton', 'not-applicable', null, 'none', '5410033851336'),
  ('PL', 'FuzeTea', 'Grocery', 'Coffee & Tea', 'Fuze Tea Peach Hibiscus', 'not-applicable', null, 'none', '5449000236623'),
  ('PL', 'Unilever', 'Grocery', 'Coffee & Tea', 'Saga herbata czarna ekspresowa', 'not-applicable', null, 'none', '8714100807354'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Lipton Herbata Green Tea Citrus', 'not-applicable', null, 'none', '8712566388141'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'Herbata aromatyzowana mango i czarna porzeczka', 'not-applicable', null, 'none', '8720608013661'),
  ('PL', 'Lipton', 'Grocery', 'Coffee & Tea', 'The tropical', 'not-applicable', null, 'none', '8722700140535'),
  ('PL', 'Unknown', 'Grocery', 'Coffee & Tea', 'Sir Albert''s tea', 'not-applicable', null, 'none', '4798810009646')
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
where country = 'PL' and category = 'Coffee & Tea'
  and is_deprecated is not true
  and product_name not in ('Herbaciany ogród - Prosto z lasu.', 'Herbaciany ogród, malina z żurawiną', 'Cappuccino o smaku śmietankowym', 'Mokate Cappuccino z belgijską czekoladą', 'Napój kawowy na bazie pełnego mleka i śmietanki', 'Herbapol Herbaciany Ogród Briar Rose Fruit-herbal Tea', 'Herbata biała tajska cytryna, kwiat granatu', 'Early Grey & płatki róży', 'Zielona herbata z kawałkami opuncji', 'Herbata biała jaśmin', 'Kawa rozpuszczalna gold liofilizowana robusta/arabica', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'Herbata czarna aromatyzowana Earl Grey Strong w torebkach do zaparzania', 'Yellow Label', 'Cappuccino', 'Mokate Cappuccino smak smietankowy', 'Cappuccino o smaku orzechowym', 'Cappuccino', 'Cappuccino z magnezem', 'Cappuccino o smaku rumowym', 'Cappuccino caffee', 'Cappuccino vanilla', 'Cappuccino karmelowe', 'Mokate Gold Latte Caramel', 'Pumpkin Spice Latte Coffe', 'Vanilla late', 'Mokate mocha double chocolate', 'Cappuccino o smaku orzechowym', 'Ice Tea Peach', 'Green Ice Tea', 'Malina', 'Herbatka na zimno Truskawka Rabarbar', 'Herbata czarna earl grey liściasta', 'Herbata z suszu owocowego', 'Matcha', 'Herbata zielona o smaku grejpfrutowym', 'Herb. aronia Herbapol 20SZT', 'Zielona herbata w torebkach', 'Lipton Green 0.5', 'Zielona herbata z nutą truskawki i maliny', 'Herbata Bio-active Li Zielona Z Owoc Malin 100G', 'Nescafe', 'Intenso', 'Classico', 'Dolce', 'Cappuccino', 'Latte Macchiato', 'Cappuccino Vanilata', 'CAPPUCCINO Decaffeinato', 'CAPPUCCINO Chocolate', 'L''or Barista Double Ristretto Intensity 11', 'Lungo Généreux et Fruité', 'Pérou', 'AMÉRIQUE LATINE GRAINS Pur Arabica', 'Amérique Latine', 'Espresso nocciolita', 'Espresso Colombie', 'Lungo Voluptuo', 'Café Grande 100% Arabica', 'Cappuccino ORIGINAL', 'Caffe latte', 'Espresso decaffeinato', 'Espresso', 'Matcha Tea powder', 'Herbata czarna z naturalnym aromatem', 'Pokrzywa z mango', 'Yellow Label granulowana', 'Qualita Oro', 'Kawa rozpuszczalna Jacobs Krönung', 'Crema', 'Kaffee Hafer', 'Ice Coffee Macchiato', 'Kopiko', 'Frappé 3in1', 'Caramel macchiato', 'Jacobs CAPPUCCINO ORIGINAL', 'Jacobs', 'Green tea', 'Earl Grey (classic) - Lipton', 'Fuze Tea Peach Hibiscus', 'Saga herbata czarna ekspresowa', 'Lipton Herbata Green Tea Citrus', 'Herbata aromatyzowana mango i czarna porzeczka', 'The tropical', 'Sir Albert''s tea');
