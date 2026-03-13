-- PIPELINE (Desserts & Ice Cream): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Desserts & Ice Cream'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4002671157751', '4061458047692', '4023600013511', '4061458280334', '4061458047708', '4061458229838', '4061458014793', '4061458278928', '4061458244299', '4002334113018', '4002334113025', '4056489124313', '40466071', '40255774', '40466033', '4036300002648', '4023600014235', '4061463958310', '4067517001315', '4056489012788', '4016241030603', '4003490323600', '4002971243703', '4016241030917', '4056489216162', '4061458028820', '4061458028813', '4002971243802', '4056489014003', '4002334113032', '4056489118190', '4008452011007', '4061458244404', '4061459015072', '40255729', '4023600013474', '4056489018483', '4056489013082', '4056489118206', '4002971247503', '4056489150497', '4056489472261', '4061458028806', '4003490032076', '4002971283808', '4002971253108', '4061458014151', '4056489118213', '4056489109570', '4014500036830', '4047247031080', '4061462714443', '4000980357411', '4023600013498', '4002971840704', '4056489128212', '40193502', '4002971253207', '4002971453201', '4002971010206', '4009700074720', '4002971011906', '4061463915016', '4002971243901', '4056489412175', '4061458040839', '4009700035783', '4003490323617', '4061458014175', '4056489014119', '4061463915030', '4014500059570', '4028900004351', '40255651', '4056489258346', '4023600015539', '4067517001629', '4067517001759', '4032549039834', '4008452011960', '4046700006184', '4061458014823', '4002334110802', '4002971011401', '4056489850373', '4002971455205', '4063367247743', '4068706393075', '4056489216155', '4056489025207', '4014500059617', '4002971010404', '4003490323709', '4002971013801', '4056489014102', '4061463480910', '4056489128151', '4028900004641', '4061458020251', '4008452035539')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Desserts & Ice Cream by pipeline',
    ean = null
where country = 'DE'
  and category != 'Desserts & Ice Cream'
  and identity_key in ('02f9d85cc5b9b80c73201d1a02fae403', '03b9279def8c0ceefc0a3c1d554cf7fc', '03db6da3cae212feccce5ed32ebcd4f7', '0476e66263096d76c8a28dcf41ebad42', '101645bfe5d161dae99973cc6a863e34', '13873b7b3b752b255702bc6a1e17424f', '144b972a0ce77802269e0bd6d3fa688b', '14b3c01c38fa4cb2a1c53a071f7b86da', '159b4c395ed3e3808cfd418f105a5a73', '18cf6a3ca588273e929cc1f3cace9060', '18e2a5395a6718725ecd2a2b40ca6a45', '1b62af34cc76eadb8caf2a6471267e2b', '1b917ed69a06ef6d132a3ec4cbd086b4', '1cc975423ba53e2b3357ff467153aeed', '23417d607821600538da3087ded524c3', '27aa53c601f6d073ec05f040c574711f', '27fac2ea167cb66b404e4b59e2b32da4', '294a5bc0067a603be418bb37d9dae198', '2a3bc274e69b6d4924ea09edccc8c586', '2c26603f046839358ad36f7de83c800a', '2c52bb92f539b57755d6c716c7e664fc', '2d366ed5c63751714ce1567d7ac55eae', '2e68aac1633065ac5f98b8fd706a7422', '2ea81cebc13e1da1c45d44d05889352b', '2f515e322703bb84f28ec44f5d2ed374', '3037ae105ce09139d9998edd34a6f3b7', '33b0bd783eef0c8227b7278877c1937e', '3733e10ceed14b54d743a4fbe4a4b5b9', '386bbf3b5d1899b63bcd7e67f2581f34', '3aaefac104193a77e06d801541c30f8d', '3dd1a08d8d0ebebff69144b6437313b6', '4358455388fba2e665c9d71ae00f424e', '48b5238af3fd39346f066f64630ba14c', '4c420bdb4ff3d7095c6e09db36a5de2c', '524a14fbc9582b2b89b673d80483efe6', '59f2b4e53d7af103628b370cb4d6b76f', '5d8b5b40740a52cfc02f02a7ebb6ec01', '5eeec184d26f515c597094de843c6c5d', '5fd0bacb3ae36b746042525232f6a713', '61b9f38e7206b19408f85ed5daaf4e6b', '62352b7961717b37018f037524001b07', '627f389920e17fb0ba8f8107bd58f7ad', '6429e4d573e9b85d99e11ba9ea2ab99d', '64ec77a6cdf6041482e82e77cb6d57f1', '68d66e614eb54a396ded27df94db0c3e', '69187cb447a1677a4f0e53528561c7b8', '6e5639c75dbae6e2b3408a19e576528d', '6ebdc464d0df2584a8d6018d3d4e0ed7', '6f768239475acd09ccc32f86358ee2c2', '77be3a2f4cec816866ce3d4d4a19cba3', '7a557cb9c75a3e2f4fe2d6e9f17877e9', '7eff20454fe864a5475661c1a04340fd', '817b91aeb5a6effa1c3df2be26ebad42', '8274e61609bead65b6a7f5ba12ac3ba3', '8659f4154410882f5db6eac2f6a67215', '86f57fba8be371e26b94593780adbbb3', '88df7b4d860f6dfefc1bc0882856b7cf', '88fd4e81177e78c506bb5d0dd67b801e', '8b378bc5783ca921f236b28c8b2a76ff', '8ce33e7e88d000c089ba04834a6f7600', '8d98840fbb51cdfff1c499bbca73fa5f', '8f1c61fd07b0f58cc3be464905c5d482', '9062360f11507ba87f909877fe9261ff', '9262668d27d602a24608808129ca2896', '9494aac24f977e45b397d153afca83ec', '9677e69b9d5cc62da859f994b6124e06', '974ebc59c501547790ef61ec86980434', '9dbc93046822758ab2b7f29120372274', 'a4d68c5627eed65afbf6e002346c7495', 'a545dc56acb6961bc28746d21f14ac28', 'a72de8c0763e827166b141ccb5fd91e9', 'a88ec32ebce908b946e040050c74d086', 'a8e12335b906c84a96504b8867914ee6', 'ac76e2c5bf15e14652b179ba12149908', 'acd693e99b7bbe4525a190ed1837614e', 'b55df3bb0789bac78ea512633f71a3b6', 'b78c551467b2fa8001f7d33164d9f93f', 'b8ecf0433603cda04416a505c40d107a', 'bfdf99cfc46f8465e67f944fbb9a7efc', 'c022fb5cba3d945d19dc49a3e1fb1bd0', 'c0a7d60e20c09ba0e61c07e284b7f8d7', 'c3a3ab78ace6bb5f4c5b7b335b2f3f83', 'c711efdd3aa5647faeebc48597561cde', 'cd0b33359ba07d94c9f1fe6e776d098d', 'ce466c68d166a9e8ab3b8c8ff7176cf2', 'd04e584bd1dddcd2d148434135e1fc74', 'd52c3af47c492e421bf3fcb69c685b2f', 'd5ff41c9b146c133f556279544d0e30e', 'd6d7303be99efe40997dad1151de2eef', 'd86b695b1f67b00d760afcbb5ca2f6fb', 'd9d8ad444a845ed025cba69d5b705303', 'dbfa3065260911ce03cd1158286a7bed', 'e2b295a1a085757d16b4304723e234bb', 'eab5becf1a4f6f889f8817a5efa99946', 'ec1b72bf52c32903c813875a96089e57', 'ed4ef405e0e6a1c737c2c2c3b86cc624', 'f10e4172b55ed2f25a43b763c4a24c7f', 'f5696e210dd9549cc0babfc1bfb5a7de', 'f67407ad5280a8918d7004f123ce1ee6', 'f693d7a176eff9f447613cd0d96baaec')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Gervais', 'Grocery', 'Desserts & Ice Cream', 'Hüttenkäse Original', 'fermented', null, 'none', '4002671157751'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Körniger Frischkäse, Halbfettstufe', 'fermented', 'Aldi', 'none', '4061458047692'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Desserts & Ice Cream', 'High Protein Pudding Grieß', 'not-applicable', 'Lidl', 'none', '4023600013511'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Grießpudding High-Protein - Zimt', 'not-applicable', 'Aldi', 'none', '4061458280334'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Körniger Frischkäse mit fettarmem Joghurt - leicht', 'fermented', 'Aldi', 'none', '4061458047708'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'fermented', 'Aldi', 'none', '4061458229838'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Kräuterquark', 'fermented', 'Aldi', 'none', '4061458014793'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Grießpudding High-Protein - Pur/Classic', 'not-applicable', 'Aldi', 'none', '4061458278928'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Joghurt nach türkischer Art, 3,5 % Fett', 'fermented', 'Aldi', 'none', '4061458244299'),
  ('DE', 'Der Grosse Bauer', 'Grocery', 'Desserts & Ice Cream', 'Der große Bauer Himbeere Joghurt mild', 'fermented', 'Netto', 'none', '4002334113018'),
  ('DE', 'Bauer', 'Grocery', 'Desserts & Ice Cream', 'Der große Bauer Heidelbeer-Cassis', 'fermented', null, 'none', '4002334113025'),
  ('DE', 'Lidl', 'Grocery', 'Desserts & Ice Cream', 'Kräuterquark', 'fermented', 'Lidl', 'none', '4056489124313'),
  ('DE', 'Milram', 'Grocery', 'Desserts & Ice Cream', 'Frühlings Quark 7 Kräuter', 'fermented', 'Kaufland', 'none', '40466071'),
  ('DE', 'Müller', 'Grocery', 'Desserts & Ice Cream', 'Müller Joghurt mit der Ecke - Schoko-Flakes', 'fermented', null, 'none', '40255774'),
  ('DE', 'Milram', 'Grocery', 'Desserts & Ice Cream', 'Frühlingsquark Family-Pack', 'fermented', 'Aldi', 'none', '40466033'),
  ('DE', 'Milram', 'Grocery', 'Desserts & Ice Cream', 'Körniger Frischkäse', 'fermented', 'Auchan', 'none', '4036300002648'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Desserts & Ice Cream', 'Götterspeise Waldmeister-Geschmack', 'not-applicable', null, 'none', '4023600014235'),
  ('DE', 'Aldi', 'Grocery', 'Desserts & Ice Cream', 'Mandeljoghurt Natur ungesüßt', 'fermented', null, 'none', '4061463958310'),
  ('DE', 'Landliebe', 'Grocery', 'Desserts & Ice Cream', 'Grießpudding Zimt', 'not-applicable', null, 'none', '4067517001315'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Skyr', 'fermented', 'Lidl', 'none', '4056489012788'),
  ('DE', 'Arla', 'Grocery', 'Desserts & Ice Cream', 'Skyr Natur', 'fermented', 'Kaufland', 'none', '4016241030603'),
  ('DE', 'Elinas', 'Grocery', 'Desserts & Ice Cream', 'Joghurt Griechischer Art', 'fermented', null, 'none', '4003490323600'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High Protein Chocolate Pudding', 'not-applicable', 'Netto', 'none', '4002971243703'),
  ('DE', 'Arla', 'Grocery', 'Desserts & Ice Cream', 'Skyr Bourbon Vanille', 'fermented', null, 'none', '4016241030917'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'High Protein Chocolate Flavour Pudding', 'not-applicable', 'Lidl', 'none', '4056489216162'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mild 3,5 % Fett', 'fermented', 'Aldi', 'none', '4061458028820'),
  ('DE', 'Aldi', 'Grocery', 'Desserts & Ice Cream', 'A/Joghurt mild 3,5% Fett', 'fermented', 'Aldi', 'none', '4061458028813'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Pudding - Vanilla', 'not-applicable', 'Netto', 'none', '4002971243802'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Bio Fettarmer Joghurt mild', 'fermented', null, 'none', '4056489014003'),
  ('DE', 'Bauer', 'Grocery', 'Desserts & Ice Cream', 'Kirsche', 'fermented', null, 'none', '4002334113032'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Skyr Vanilla', 'fermented', 'Lidl', 'none', '4056489118190'),
  ('DE', 'Weihenstephan', 'Grocery', 'Desserts & Ice Cream', 'Joghurt Natur 3,5 % Fett', 'fermented', 'Kaufland', 'none', '4008452011007'),
  ('DE', 'Lyttos', 'Grocery', 'Desserts & Ice Cream', 'Griechischer Joghurt', 'fermented', 'Aldi', 'none', '4061458244404'),
  ('DE', 'Lyttos', 'Grocery', 'Desserts & Ice Cream', 'ALDI LYTTOS YOGRI nach griechischer Art 1kg 2.19€', 'fermented', 'Aldi', 'none', '4061459015072'),
  ('DE', 'Müller', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mit der Ecke - Schoko Balls', 'fermented', null, 'none', '40255729'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Desserts & Ice Cream', 'High Protein Pudding Schoko', 'not-applicable', null, 'none', '4023600013474'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Bio Organic Cremiger Joghurt Mild (3,8% Fett)', 'fermented', 'Lidl', 'none', '4056489018483'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Bio Speisequark Magerstufe', 'fermented', 'Lidl', 'none', '4056489013082'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Skyr Erdbeere', 'fermented', 'Lidl', 'none', '4056489118206'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Chocolate & Topping with Protein', 'fermented', 'Lidl', 'none', '4002971247503'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Joghurt 1,5%', 'fermented', 'Lidl', 'none', '4056489150497'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Haselnuss Pudding', 'not-applicable', 'Lidl', 'none', '4056489472261'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mild 3,5% / 0x 500 gr / 3x 150 gr (Gebinde= 4x je 150 gr)', 'fermented', 'Aldi', 'none', '4061458028806'),
  ('DE', 'Elinas', 'Grocery', 'Desserts & Ice Cream', 'Joghurt, Natur', 'fermented', 'Kaufland', 'none', '4003490032076'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High Protein Chocolate Mousse', 'not-applicable', 'Kaufland', 'none', '4002971283808'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Grand Dessert - Vanille', 'not-applicable', null, 'none', '4002971253108'),
  ('DE', 'Aldi', 'Grocery', 'Desserts & Ice Cream', 'Speisequark Magerstufe', 'fermented', 'Aldi', 'none', '4061458014151'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Skyr Blueberry', 'fermented', 'Lidl', 'none', '4056489118213'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Kefir', 'fermented', 'Lidl', 'none', '4056489109570'),
  ('DE', 'Zott', 'Grocery', 'Desserts & Ice Cream', 'Monte MAXI', 'fermented', null, 'none', '4014500036830'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Pudding - Schoko', 'not-applicable', 'Aldi', 'none', '4047247031080'),
  ('DE', 'My Vay', 'Grocery', 'Desserts & Ice Cream', 'Sojaghurt', 'fermented', 'Aldi', 'none', '4061462714443'),
  ('DE', 'Molkerei Gropper', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Pudding - Schoko', 'not-applicable', 'Netto', 'none', '4000980357411'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Desserts & Ice Cream', 'High Protein Pudding Bourbon-Vanille', 'not-applicable', null, 'none', '4023600013498'),
  ('DE', 'Almighurt', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mild, Stracciatella', 'fermented', null, 'none', '4002971840704'),
  ('DE', 'DMK', 'Grocery', 'Desserts & Ice Cream', 'Speisequark Magerstufe', 'fermented', 'Lidl', 'none', '4056489128212'),
  ('DE', 'Exquisa', 'Grocery', 'Desserts & Ice Cream', 'Quark queso natural', 'fermented', null, 'none', '40193502'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Grand Dessert - Double Choc', 'not-applicable', 'Aldi', 'none', '4002971253207'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High Protein Heidelbeere Joghurt-Erzeugnis', 'fermented', null, 'none', '4002971453201'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Almighurt - Kirsche', 'fermented', 'Kaufland', 'none', '4002971010206'),
  ('DE', 'Actimel', 'Grocery', 'Desserts & Ice Cream', 'Danone Actimel® CLASSIC 8X100G', 'fermented', 'Kaufland', 'none', '4009700074720'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Almighurt - Ananas', 'fermented', null, 'none', '4002971011906'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Mousse Vanillegeschmack', 'fermented', 'Aldi', 'none', '4061463915016'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Pudding - Caramel Style', 'fermented', 'Netto', 'none', '4002971243901'),
  ('DE', 'Vemondo', 'Grocery', 'Desserts & Ice Cream', 'Coconut Classic', 'fermented', 'Lidl', 'none', '4056489412175'),
  ('DE', 'Lyttos', 'Grocery', 'Desserts & Ice Cream', 'Yogri - Joghurterzeugnis nach griechischer Art', 'fermented', 'Aldi', 'none', '4061458040839'),
  ('DE', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Fruchtzwerge', 'fermented', 'Lidl', 'none', '4009700035783'),
  ('DE', 'Elinas', 'Grocery', 'Desserts & Ice Cream', 'Joghurt nach griechischer Art - Honig', 'fermented', 'Kaufland', 'none', '4003490323617'),
  ('DE', 'Aldi', 'Grocery', 'Desserts & Ice Cream', 'Speisequark 20% - Bio', 'fermented', 'Aldi', 'none', '4061458014175'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Bio fruchtjoghurt', 'fermented', 'Lidl', 'none', '4056489014119'),
  ('DE', 'Milchfrisch', 'Grocery', 'Desserts & Ice Cream', 'High-Protein-Mousse - Schokolade', 'not-applicable', 'Aldi', 'none', '4061463915030'),
  ('DE', 'Zott', 'Grocery', 'Desserts & Ice Cream', 'Sahne-Joghurt mild Amarena-Kirsche', 'fermented', 'Lidl', 'none', '4014500059570'),
  ('DE', 'Weideglück', 'Grocery', 'Desserts & Ice Cream', 'Bio Joghurt Mild', 'fermented', 'Kaufland', 'none', '4028900004351'),
  ('DE', 'Müller', 'Grocery', 'Desserts & Ice Cream', 'Milchreis Schoko', 'not-applicable', 'Lidl', 'none', '40255651'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'High Protein Joghurterzeugnis - Heidelbeere', 'fermented', 'Lidl', 'none', '4056489258346'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Desserts & Ice Cream', 'Paula Pudding Vanille', 'not-applicable', 'Lidl', 'none', '4023600015539'),
  ('DE', 'Landliebe', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mild 3,8%', 'fermented', null, 'none', '4067517001629'),
  ('DE', 'Landliebe', 'Grocery', 'Desserts & Ice Cream', 'Schokolade Sahne Pudding', 'not-applicable', null, 'none', '4067517001759'),
  ('DE', 'Dogan', 'Grocery', 'Desserts & Ice Cream', 'Ayran', 'fermented', 'Kaufland', 'none', '4032549039834'),
  ('DE', 'Weihenstephan', 'Grocery', 'Desserts & Ice Cream', 'Joghurt mild 0,1% Fett', 'fermented', null, 'none', '4008452011960'),
  ('DE', 'Schwarzwaldmilch', 'Grocery', 'Desserts & Ice Cream', 'BIO Joghurt', 'fermented', 'Kaufland', 'none', '4046700006184'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Sour Creme - cremig mild', 'fermented', 'Aldi', 'none', '4061458014823'),
  ('DE', 'Seraphos', 'Grocery', 'Desserts & Ice Cream', 'Joghurt Mild nach Griechischer ART', 'fermented', null, 'none', '4002334110802'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Almighurt - Pfirsich-Maracuja', 'fermented', 'Netto', 'none', '4002971011401'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Joghurt griechischer Art Natur', 'fermented', 'Lidl', 'none', '4056489850373'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'High Protein Mango', 'fermented', null, 'none', '4002971455205'),
  ('DE', 'Kaufland', 'Grocery', 'Desserts & Ice Cream', 'Veganer cocogurt', 'fermented', 'Kaufland', 'none', '4063367247743'),
  ('DE', 'Aldi', 'Grocery', 'Desserts & Ice Cream', 'Apfelmus', 'not-applicable', 'Aldi', 'none', '4068706393075'),
  ('DE', 'Lidl', 'Grocery', 'Desserts & Ice Cream', 'High protein vanilla pudding', 'not-applicable', 'Lidl', 'none', '4056489216155'),
  ('DE', 'Gut & günstig', 'Grocery', 'Desserts & Ice Cream', 'Joghurt Griechischer Art (pur)', 'fermented', 'Lidl', 'none', '4056489025207'),
  ('DE', 'Zott', 'Grocery', 'Desserts & Ice Cream', 'Zott Sahne Joghurt mild Erdbeere 4014500059617 Sahnejoghurt mild mit Erdbeeren. 10% Fett im Milchantei', 'fermented', 'Lidl', 'none', '4014500059617'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Almighurt - Himbeere', 'fermented', 'Netto', 'none', '4002971010404'),
  ('DE', 'Elinas', 'Grocery', 'Desserts & Ice Cream', 'Joghurt nach griechischer Art Kirsche', 'fermented', null, 'none', '4003490323709'),
  ('DE', 'Ehrmann', 'Grocery', 'Desserts & Ice Cream', 'Almighurt - Zitrone', 'fermented', 'Lidl', 'none', '4002971013801'),
  ('DE', 'Milbona', 'Grocery', 'Desserts & Ice Cream', 'Joghurt Mild Vanille', 'fermented', 'Lidl', 'none', '4056489014102'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Joghurt 3,5 %', 'fermented', 'Aldi', 'none', '4061463480910'),
  ('DE', 'DMK', 'Grocery', 'Desserts & Ice Cream', 'Speisequark', 'fermented', 'Lidl', 'none', '4056489128151'),
  ('DE', 'Weideglück', 'Grocery', 'Desserts & Ice Cream', 'Joghurt 3,5% Fett', 'fermented', null, 'none', '4028900004641'),
  ('DE', 'Milsani', 'Grocery', 'Desserts & Ice Cream', 'Joghurt laktosefrei', 'fermented', 'Aldi', 'none', '4061458020251'),
  ('DE', 'Weihenstephan', 'Grocery', 'Desserts & Ice Cream', 'Rahmjoghurt Stracciatella', 'fermented', 'Kaufland', 'none', '4008452035539')
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
where country = 'DE' and category = 'Desserts & Ice Cream'
  and is_deprecated is not true
  and product_name not in ('Hüttenkäse Original', 'Körniger Frischkäse, Halbfettstufe', 'High Protein Pudding Grieß', 'Grießpudding High-Protein - Zimt', 'Körniger Frischkäse mit fettarmem Joghurt - leicht', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'Kräuterquark', 'Grießpudding High-Protein - Pur/Classic', 'Joghurt nach türkischer Art, 3,5 % Fett', 'Der große Bauer Himbeere Joghurt mild', 'Der große Bauer Heidelbeer-Cassis', 'Kräuterquark', 'Frühlings Quark 7 Kräuter', 'Müller Joghurt mit der Ecke - Schoko-Flakes', 'Frühlingsquark Family-Pack', 'Körniger Frischkäse', 'Götterspeise Waldmeister-Geschmack', 'Mandeljoghurt Natur ungesüßt', 'Grießpudding Zimt', 'Skyr', 'Skyr Natur', 'Joghurt Griechischer Art', 'High Protein Chocolate Pudding', 'Skyr Bourbon Vanille', 'High Protein Chocolate Flavour Pudding', 'Joghurt mild 3,5 % Fett', 'A/Joghurt mild 3,5% Fett', 'High-Protein-Pudding - Vanilla', 'Bio Fettarmer Joghurt mild', 'Kirsche', 'Skyr Vanilla', 'Joghurt Natur 3,5 % Fett', 'Griechischer Joghurt', 'ALDI LYTTOS YOGRI nach griechischer Art 1kg 2.19€', 'Joghurt mit der Ecke - Schoko Balls', 'High Protein Pudding Schoko', 'Bio Organic Cremiger Joghurt Mild (3,8% Fett)', 'Bio Speisequark Magerstufe', 'Skyr Erdbeere', 'Chocolate & Topping with Protein', 'Joghurt 1,5%', 'Haselnuss Pudding', 'Joghurt mild 3,5% / 0x 500 gr / 3x 150 gr (Gebinde= 4x je 150 gr)', 'Joghurt, Natur', 'High Protein Chocolate Mousse', 'Grand Dessert - Vanille', 'Speisequark Magerstufe', 'Skyr Blueberry', 'Kefir', 'Monte MAXI', 'High-Protein-Pudding - Schoko', 'Sojaghurt', 'High-Protein-Pudding - Schoko', 'High Protein Pudding Bourbon-Vanille', 'Joghurt mild, Stracciatella', 'Speisequark Magerstufe', 'Quark queso natural', 'Grand Dessert - Double Choc', 'High Protein Heidelbeere Joghurt-Erzeugnis', 'Almighurt - Kirsche', 'Danone Actimel® CLASSIC 8X100G', 'Almighurt - Ananas', 'High-Protein-Mousse Vanillegeschmack', 'High-Protein-Pudding - Caramel Style', 'Coconut Classic', 'Yogri - Joghurterzeugnis nach griechischer Art', 'Fruchtzwerge', 'Joghurt nach griechischer Art - Honig', 'Speisequark 20% - Bio', 'Bio fruchtjoghurt', 'High-Protein-Mousse - Schokolade', 'Sahne-Joghurt mild Amarena-Kirsche', 'Bio Joghurt Mild', 'Milchreis Schoko', 'High Protein Joghurterzeugnis - Heidelbeere', 'Paula Pudding Vanille', 'Joghurt mild 3,8%', 'Schokolade Sahne Pudding', 'Ayran', 'Joghurt mild 0,1% Fett', 'BIO Joghurt', 'Sour Creme - cremig mild', 'Joghurt Mild nach Griechischer ART', 'Almighurt - Pfirsich-Maracuja', 'Joghurt griechischer Art Natur', 'High Protein Mango', 'Veganer cocogurt', 'Apfelmus', 'High protein vanilla pudding', 'Joghurt Griechischer Art (pur)', 'Zott Sahne Joghurt mild Erdbeere 4014500059617 Sahnejoghurt mild mit Erdbeeren. 10% Fett im Milchantei', 'Almighurt - Himbeere', 'Joghurt nach griechischer Art Kirsche', 'Almighurt - Zitrone', 'Joghurt Mild Vanille', 'Joghurt 3,5 %', 'Speisequark', 'Joghurt 3,5% Fett', 'Joghurt laktosefrei', 'Rahmjoghurt Stracciatella');
