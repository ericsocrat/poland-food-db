-- PIPELINE (Spices & Seasonings): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Spices & Seasonings'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4010442421154', '4056489143215', '4005500027843', '4002674041910', '4000345096351', '4002674044072', '4002674123418', '4056489822103', '4002239385008', '4061458090636', '4061458090629', '4002239639705', '4005500027898', '4009286150894', '4056489676171', '4012346172804', '4002674245516', '4002674041637', '4056489032243', '4008088050500', '4007552310881', '4002674046151', '4002674043952', '4061459728460', '4061458018968', '4014472002529', '4000521026110', '40122915', '4260401174465', '4056489113737', '4047247590853', '4058172227707', '4311501738221', '4049164124913', '4009286121542', '4002674044119', '4002239854504', '4260446098276', '4061464973671', '4007552310843', '4022500137617', '4056489886358', '4056489908500', '4010321307685', '40804378', '4260347896827', '40352602', '20840013', '4022500138935', '4056489222859', '4061458197687', '4056489497110', '4337256263344', '4058172925122', '4260401174496', '9004145006492', '4335619161931', '4260401173895', '7613287353870', '4250589702123', '9004145003774', '0078895160468', '4337256669825', '20226572', '4311501611180', '9300641003103', '42436195', '4335619114142', '4311501435779', '20892319', '4260431673730', '4337256562638', '20840037', '4260133141353', '4260431672467', '4335619114159', '4260431671026', '4260159455519', '5000112682205', '4104420219144', '4260401175004', '8690804028519', '4250589701775', '4260401175301', '4250589701812', '4260757830596', '4260133141131', '20437817', '8717163935187', '4250589701799', '4260431673297', '3850104047046', '4250589702246', '4260133141889', '7311310313678', '8690804025310', '4260347890290', '3850104216466')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Spices & Seasonings by pipeline',
    ean = null
where country = 'DE'
  and category != 'Spices & Seasonings'
  and identity_key in ('0b49bd071437d5a60d9a196575a5c727', '0ef2377c8a148e9dfcc644610c49cb2c', '0f25c3fc1264179f22cb2ac76cdf50eb', '100501e3a4a4709859522c2f85d323bb', '10f9436dd434459226d7062c8d1ce17e', '16daeb6def9046efd8896ba4c437f6bb', '1a83ee4815426617fbad1a347af358d9', '1f9016745185e0be9ba70ea7c1aaa6c8', '256657dfe2430ed4e88638461e403031', '28cac44d5a90093c27f443791a1682b1', '2990a65a704926a29eadfbba4bd349e8', '2ad8e7509af35318395c5aae9822d082', '2c59f14d2afba30eb5c101d657cdfff2', '30462d9805cdcbf10476c5026468ef1e', '30e54b0d3aa807003dfdf8ea57229944', '316f96e6c25d64e7b36bb72c77882372', '37d92f5e86ee40b2043707b44d64383c', '3921b85e3da60ada4bb0cd6765eb2b4c', '39ccafcdd8275296dcd5fd3648c5f079', '3ebaf459b6626e20607b45728ce536cd', '3ec51c23161672e1050711f2a6b39057', '40076dc095bf9dc5df9905c16e335337', '422ac8f3ab120c095f63366628643cfb', '45519ae9c258cc72f16b071bd96e0ed8', '482a10335d7b7c1e5feb322531a43c35', '4e6bf656b9d0258ca3ee06d71c2b4c32', '4f5226060624d9be725db5923a21c504', '502d890e803c8659509734d07b05bb69', '538a67093bab8ba11da296b01b1847c9', '55ac4a6fe761eac8ddce520277068496', '56b7871ee69b0300aa4bd8d67b0b38e8', '56ba15b34eb7de9c91c3c3a4b7f62735', '56ff8a0fa4a8fc547958964ad3a40519', '57bd9f861e1cd55d24736660e0395506', '580ae3c53a30999b20e9e1f64b838423', '5af918389a17610e87a94367bb3aa8b8', '5dd5f7a7c189238c868e194162812416', '5ff0b77b09d5eb52020895101a9168fc', '6124a4d14874298c09a4529072322360', '66d9bb9357943079be78141905b13b20', '6e4d0bf55b58cbf3d012fa1cb3a7e68d', '6f8d63038315e1b4c2abde11ce83146d', '7cfa2bc672cf7c6a33de61edd2cb5d20', '7e62e95fabfb440db63517be3dfab3fa', '8119894a7a36cbab8a042a08dd4af28e', '811ee8dc1aca5c76bf23c871a77d38f3', '826f89fd8dae4b9be70de4fbcd6af887', '848f971210c9b41e07fc9489428a82c4', '8ba2d944470ac70f62b5b65f5736e10a', '8bbff91f08f2e6ced4fb6e92b0f9b2a8', '8d6e5ed776afd9a9447bf255c353a20d', '9626c5693aa5ba5128bbf0b7f4325ae9', '9865f883337c8eac1dcf6351d9a9b4ea', '9a4f9c99da1f91b8cc83bb05e779ba50', '9dda5ea47314b6355ca03e25dd653fe0', '9fa65f99575a614fe3f2c83a29c3f032', 'a48bd0e3029448aa939d3446b5907ae6', 'a5814979c51602d110e7b3572321aa94', 'a9344d9299fb1b109b57714dc8adce41', 'aca7ab653f7d01d0633ca34ac9ef7281', 'ad3a6d834df4efcf0f5c07572f6c9701', 'ae8fd021033b626dbf939bda050c663c', 'b025955e1daac1f964bb1c36fa0463d2', 'b50226dbb8ac68de61264f3a4607d2ef', 'b55a32d0b12c8b80daf0dddc9278d23e', 'b56dff5a53952cde2aa9ac453252f8d2', 'bcb04899ffeb81a3008bf6d50dc42eec', 'c2aaecf059a9a1da469eac211e218b8f', 'c4fc127a1b0293093d737f22707e45ee', 'c74dde44dbb277df6ae50e2665c76f2c', 'cb3a6159af36ba0b7383b63fdd215a2a', 'ce09e181de19fa89e4f53e97afd79f5d', 'd43ffb430556e96c3d92478a10936e9c', 'd6f96b3e92369d95abebe1197b8ad6e1', 'df5cf5f496bf86725036008408f21ffb', 'e1bd4f3820558f6e3eadb76206ec0dcc', 'e2f4f26371b374e1f5142eed365871b2', 'e37af71b4d28574ca6d4be82d277cfc4', 'e62cb4b993f20b7680e67e37aab7b80e', 'e7396fce58a9aaa154cb2248c2eb626b', 'e8e18c27a9eda2970265492f32da569c', 'e977a625e16cc41df71a2f1054543eba', 'e9b9d4bff27fb4631250cf8883439280', 'ea640f52632587ee5f636d2d07678ce3', 'eb121192cd85a0806e3fef374db0132e', 'ec8b52e222484486940227e2335d7e3d', 'ed44f9dcca0d5527e85dfba547f77c9a', 'f0cf8b4aff6d69a87d04a4cf6bde52fa', 'f10238a96bb2fbb1c4706bc7ec2ed3e8', 'f1115b4c04376d9122783109f299fcb1', 'f394b23bebbb70b36153cbfa92b067e8', 'f52dfb48c9bcbb0752bea0c67c7a1916', 'f575ecfc1755e6842fd3ecf32e2e1f4e', 'f7108f603b67f1124d59d1db9c71a609', 'f88e3b3b3113634617703eee0ec6295f', 'f8a65c54ef1c03eefc731d09b77c5ad0', 'f9197aeff1c5aac3468c3534e1b33249', 'fad92b6bc849f59553d1107767babc3f')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Farmer''s Snack', 'Grocery', 'Spices & Seasonings', 'Südsee-Ingwer', 'not-applicable', null, 'none', '4010442421154'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Würzlinge Kräuter Italienische Art', 'dried', 'Lidl', 'none', '4056489143215'),
  ('DE', 'Nestlé', 'Grocery', 'Spices & Seasonings', 'Würzmischung Nr. 1, Gebratenes Fleisch', 'not-applicable', null, 'none', '4005500027843'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Kreuzkümmel (Cumin)', 'not-applicable', null, 'none', '4002674041910'),
  ('DE', 'Hügli Nahrungsmittel GmbH', 'Grocery', 'Spices & Seasonings', 'Gewürzmischung Ofen-Gemüse (Bio)', 'not-applicable', null, 'none', '4000345096351'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Paprika edelsüß', 'not-applicable', null, 'none', '4002674044072'),
  ('DE', 'Fuchs-Gruppe', 'Grocery', 'Spices & Seasonings', 'Lebkuchengewürz', 'not-applicable', null, 'none', '4002674123418'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Spice your Slice- würzmischung', 'not-applicable', null, 'none', '4056489822103'),
  ('DE', 'Dittmann', 'Grocery', 'Spices & Seasonings', 'Pfeffer, Eingelegter Grüner Pfeffer', 'not-applicable', null, 'none', '4002239385008'),
  ('DE', 'Le Gusto', 'Grocery', 'Spices & Seasonings', 'Pfeffermühle mit Keramikmahlwerk - Pariser Pfeffer', 'not-applicable', null, 'none', '4061458090636'),
  ('DE', 'Le Gusto', 'Grocery', 'Spices & Seasonings', 'Pfeffermühle mit Keramikmahlwerk - Steakpfeffer', 'not-applicable', null, 'none', '4061458090629'),
  ('DE', 'Feinkost Dittmann', 'Grocery', 'Spices & Seasonings', 'Grüne Jalapeño Pfefferonen', 'not-applicable', null, 'none', '4002239639705'),
  ('DE', 'Gewürze', 'Grocery', 'Spices & Seasonings', 'Gewürzmischung 4', 'not-applicable', null, 'none', '4005500027898'),
  ('DE', 'Block House', 'Grocery', 'Spices & Seasonings', 'Zauber Gewürz', 'not-applicable', null, 'none', '4009286150894'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Pommes Würzsalz', 'not-applicable', null, 'none', '4056489676171'),
  ('DE', 'Lebensbaum', 'Grocery', 'Spices & Seasonings', 'Gewürzmischung Thai-Curry', 'not-applicable', null, 'none', '4012346172804'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Steak Gewürzsalz', 'not-applicable', null, 'none', '4002674245516'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'China Gewürz', 'not-applicable', null, 'none', '4002674041637'),
  ('DE', 'Grillmeister', 'Grocery', 'Spices & Seasonings', 'Gewürzmischung BBQ Steakpfeffer', 'not-applicable', null, 'none', '4056489032243'),
  ('DE', 'Kluth', 'Grocery', 'Spices & Seasonings', 'Ingwerstücke', 'not-applicable', null, 'none', '4008088050500'),
  ('DE', 'Fuego', 'Grocery', 'Spices & Seasonings', 'EDEKA GEWÜRZE Fuchs-Gruppe Fuego Fajita Seasoning Mix Verbesserte Rezeptur Vegan ohne Geschmacksverstärker und ohne PalmölB. 1.79€ 0.03 kg Beutel. 59.67€ 1kg', 'not-applicable', null, 'none', '4007552310881'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Zimt gemahlen', 'not-applicable', null, 'none', '4002674046151'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Oregano', 'dried', 'Netto', 'none', '4002674043952'),
  ('DE', 'Aldi', 'Grocery', 'Spices & Seasonings', 'Vanilleextrakt-Zubereitung Bio-Bourbon', 'not-applicable', 'Aldi', 'none', '4061459728460'),
  ('DE', 'Le Gusto', 'Grocery', 'Spices & Seasonings', 'Curry Pulver', 'not-applicable', 'Lidl', 'none', '4061458018968'),
  ('DE', 'Bionade', 'Grocery', 'Spices & Seasonings', 'Ingwer-Orange', 'not-applicable', null, 'none', '4014472002529'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Spices & Seasonings', 'Zitronenschale', 'not-applicable', null, 'none', '4000521026110'),
  ('DE', 'Kühne', 'Grocery', 'Spices & Seasonings', 'Jalapeños', 'not-applicable', null, 'none', '40122915'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Hähnchen Allrounder', 'not-applicable', null, 'none', '4260401174465'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Bio Curry', 'not-applicable', null, 'none', '4056489113737'),
  ('DE', 'Rio d''oro', 'Grocery', 'Spices & Seasonings', 'Bio ingwer', 'not-applicable', null, 'none', '4047247590853'),
  ('DE', 'DmBio', 'Grocery', 'Spices & Seasonings', 'Ingwersaft', 'not-applicable', null, 'none', '4058172227707'),
  ('DE', 'Gut&günstig', 'Grocery', 'Spices & Seasonings', 'Grüne Peperoni', 'not-applicable', null, 'none', '4311501738221'),
  ('DE', 'BioWagner', 'Grocery', 'Spices & Seasonings', 'Zimt gemahlen', 'not-applicable', null, 'none', '4049164124913'),
  ('DE', 'Block House', 'Grocery', 'Spices & Seasonings', 'Steak Pfeffer', 'not-applicable', null, 'none', '4009286121542'),
  ('DE', 'Ostmann', 'Grocery', 'Spices & Seasonings', 'Paprika Rosenscharf', 'not-applicable', null, 'none', '4002674044119'),
  ('DE', 'Feinkost Dittmann', 'Grocery', 'Spices & Seasonings', 'Pfefferonen', 'not-applicable', null, 'none', '4002239854504'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Gemüse Allrounder', 'not-applicable', null, 'none', '4260446098276'),
  ('DE', 'Aldi', 'Grocery', 'Spices & Seasonings', 'Hi! Spice - Stullengenie', 'not-applicable', null, 'none', '4061464973671'),
  ('DE', 'Fuego', 'Grocery', 'Spices & Seasonings', 'Fuego Taco Seasoning Mix', 'not-applicable', null, 'none', '4007552310843'),
  ('DE', 'Unknown', 'Grocery', 'Spices & Seasonings', 'Vanille Extract', 'not-applicable', null, 'none', '4022500137617'),
  ('DE', 'Belbake', 'Grocery', 'Spices & Seasonings', 'Bourbon-Vanillepaste', 'not-applicable', null, 'none', '4056489886358'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Mélanges épices sandwich', 'not-applicable', null, 'none', '4056489908500'),
  ('DE', 'Kclassic', 'Grocery', 'Spices & Seasonings', 'Sushi Ingwer', 'not-applicable', null, 'none', '4010321307685'),
  ('DE', 'Kühne', 'Grocery', 'Spices & Seasonings', 'Peperoni mild', 'not-applicable', null, 'none', '40804378'),
  ('DE', 'Ankerkraut', 'Grocery', 'Spices & Seasonings', 'Rührei Mix Gewürz', 'not-applicable', null, 'none', '4260347896827'),
  ('DE', 'Ruf', 'Grocery', 'Spices & Seasonings', 'Gourmet Vanille-Extrakt', 'not-applicable', null, 'none', '40352602'),
  ('DE', '1001 delights', 'Grocery', 'Spices & Seasonings', 'Gewürz, Ras el Hanout', 'not-applicable', 'Lidl', 'none', '20840013'),
  ('DE', 'Pickerd', 'Grocery', 'Spices & Seasonings', 'Zimt Paste', 'not-applicable', null, 'none', '4022500138935'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Knoblauch granuliert', 'dried', null, 'none', '4056489222859'),
  ('DE', 'Aldi', 'Grocery', 'Spices & Seasonings', 'Bio-Kurkumapulver', 'not-applicable', null, 'none', '4061458197687'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Fix fur salatsauce', 'not-applicable', null, 'none', '4056489497110'),
  ('DE', 'Rewe Beste Wahl', 'Grocery', 'Spices & Seasonings', 'Paprika geräuchert', 'not-applicable', null, 'none', '4337256263344'),
  ('DE', 'DmBio', 'Grocery', 'Spices & Seasonings', 'Bourbon Vanille', 'not-applicable', null, 'none', '4058172925122'),
  ('DE', 'Just spices', 'Grocery', 'Spices & Seasonings', 'Bratkartoffel Gewürz', 'not-applicable', null, 'none', '4260401174496'),
  ('DE', 'Sonnentor', 'Grocery', 'Spices & Seasonings', 'Das Beste für Reste', 'not-applicable', null, 'none', '9004145006492'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Kreuzkümmel', 'not-applicable', null, 'none', '4335619161931'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Kräuter Quark Gewürz', 'not-applicable', null, 'none', '4260401173895'),
  ('DE', 'Maggi', 'Grocery', 'Spices & Seasonings', 'Fix Jäger-Sahne Schnitzel', 'dried', null, 'none', '7613287353870'),
  ('DE', 'Gefro', 'Grocery', 'Spices & Seasonings', 'Gewürz-Pfeffer', 'not-applicable', null, 'none', '4250589702123'),
  ('DE', 'Sonnentor', 'Grocery', 'Spices & Seasonings', 'Sonnentor Gewürzblüten', 'not-applicable', null, 'none', '9004145003774'),
  ('DE', 'Lee Kum Kee', 'Grocery', 'Spices & Seasonings', 'Premium-Pilz-Würzpulver', 'not-applicable', null, 'none', '0078895160468'),
  ('DE', 'Rewe', 'Grocery', 'Spices & Seasonings', 'Jalapenos', 'not-applicable', null, 'none', '4337256669825'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Persillade provençale', 'not-applicable', 'Lidl', 'none', '20226572'),
  ('DE', 'Edeka', 'Grocery', 'Spices & Seasonings', 'Pfefferonen griechisch', 'not-applicable', null, 'none', '4311501611180'),
  ('DE', 'Taylor & Colledge', 'Grocery', 'Spices & Seasonings', 'Bourbon Bio-Vanille extrakt', 'not-applicable', null, 'none', '9300641003103'),
  ('DE', 'Backfee', 'Grocery', 'Spices & Seasonings', 'Vanillepaste', 'not-applicable', 'Netto', 'none', '42436195'),
  ('DE', 'Vitasia', 'Grocery', 'Spices & Seasonings', 'Ingwer eingelegt', 'not-applicable', 'Lidl', 'none', '4335619114142'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Spices & Seasonings', 'Pfeffer schwarz', 'not-applicable', null, 'none', '4311501435779'),
  ('DE', 'Kania', 'Grocery', 'Spices & Seasonings', 'Oignons', 'not-applicable', 'Lidl', 'none', '20892319'),
  ('DE', 'Unknown', 'Grocery', 'Spices & Seasonings', 'Bolognese Gewürz', 'not-applicable', null, 'none', '4260431673730'),
  ('DE', 'Rewe Bio', 'Grocery', 'Spices & Seasonings', 'Zitronenschale gerieben', 'not-applicable', null, 'none', '4337256562638'),
  ('DE', '1001 delights', 'Grocery', 'Spices & Seasonings', 'Gewürz, Couscous', 'not-applicable', null, 'none', '20840037'),
  ('DE', 'Beltane Naturkost GmbH', 'Grocery', 'Spices & Seasonings', 'Biofix Gebratene Nudeln (Bami Goreng)', 'not-applicable', null, 'none', '4260133141353'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Stullen Spice', 'not-applicable', null, 'none', '4260431672467'),
  ('DE', 'Vitasia Lidl', 'Grocery', 'Spices & Seasonings', 'Sushi Ingwer', 'not-applicable', 'Lidl', 'none', '4335619114159'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Avocado Toppimg', 'not-applicable', null, 'none', '4260431671026'),
  ('DE', 'Lebepur', 'Grocery', 'Spices & Seasonings', 'Kurkuma Shot', 'not-applicable', null, 'none', '4260159455519'),
  ('DE', 'The Coca-Cola Company', 'Grocery', 'Spices & Seasonings', 'Cola Vanille', 'not-applicable', null, 'none', '5000112682205'),
  ('DE', 'Alnatura', 'Grocery', 'Spices & Seasonings', 'Gelbe Linse Kurkuma Aufstrich', 'not-applicable', null, 'none', '4104420219144'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Italian allrounder', 'not-applicable', null, 'none', '4260401175004'),
  ('DE', 'Suntat', 'Grocery', 'Spices & Seasonings', 'Jalapeno Scharf', 'not-applicable', null, 'none', '8690804028519'),
  ('DE', 'Gefro', 'Grocery', 'Spices & Seasonings', 'Bella italia', 'not-applicable', null, 'none', '4250589701775'),
  ('DE', 'Ducros', 'Grocery', 'Spices & Seasonings', 'Curry Madras', 'not-applicable', null, 'none', '4260401175301'),
  ('DE', 'Gefro', 'Grocery', 'Spices & Seasonings', 'Mexiko Chili', 'not-applicable', null, 'none', '4250589701812'),
  ('DE', 'Bissfest', 'Grocery', 'Spices & Seasonings', 'Pasta Konfetti', 'not-applicable', null, 'none', '4260757830596'),
  ('DE', 'Beltane', 'Grocery', 'Spices & Seasonings', 'Biofix Spaghetti Bolognese', 'not-applicable', null, 'none', '4260133141131'),
  ('DE', 'Batts', 'Grocery', 'Spices & Seasonings', 'Chilimauste', 'not-applicable', null, 'none', '20437817'),
  ('DE', 'Knorr', 'Grocery', 'Spices & Seasonings', 'Broccoli Gratin', 'not-applicable', null, 'none', '8717163935187'),
  ('DE', 'Gefro', 'Grocery', 'Spices & Seasonings', 'Gefro Curry Indisch Bio', 'not-applicable', null, 'none', '4250589701799'),
  ('DE', 'Just Spices', 'Grocery', 'Spices & Seasonings', 'Kartoffel Allrounder', 'not-applicable', null, 'none', '4260431673297'),
  ('DE', 'Vegeta', 'Grocery', 'Spices & Seasonings', 'Vegeta', 'dried', null, 'none', '3850104047046'),
  ('DE', 'Gefro', 'Grocery', 'Spices & Seasonings', 'Gefro Bella Italia', 'not-applicable', null, 'none', '4250589702246'),
  ('DE', 'Beltane', 'Grocery', 'Spices & Seasonings', 'Biofix', 'not-applicable', null, 'none', '4260133141889'),
  ('DE', 'Santa maria', 'Grocery', 'Spices & Seasonings', 'Fajita', 'not-applicable', null, 'none', '7311310313678'),
  ('DE', 'Suntat', 'Grocery', 'Spices & Seasonings', 'Scharfe Chiliflocken', 'not-applicable', null, 'none', '8690804025310'),
  ('DE', 'Ankerkraut', 'Grocery', 'Spices & Seasonings', 'Chili con Carne Mild Ankerkraut', 'not-applicable', null, 'none', '4260347890290'),
  ('DE', 'Podravka', 'Grocery', 'Spices & Seasonings', 'Vegeta', 'not-applicable', null, 'none', '3850104216466')
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
where country = 'DE' and category = 'Spices & Seasonings'
  and is_deprecated is not true
  and product_name not in ('Südsee-Ingwer', 'Würzlinge Kräuter Italienische Art', 'Würzmischung Nr. 1, Gebratenes Fleisch', 'Kreuzkümmel (Cumin)', 'Gewürzmischung Ofen-Gemüse (Bio)', 'Paprika edelsüß', 'Lebkuchengewürz', 'Spice your Slice- würzmischung', 'Pfeffer, Eingelegter Grüner Pfeffer', 'Pfeffermühle mit Keramikmahlwerk - Pariser Pfeffer', 'Pfeffermühle mit Keramikmahlwerk - Steakpfeffer', 'Grüne Jalapeño Pfefferonen', 'Gewürzmischung 4', 'Zauber Gewürz', 'Pommes Würzsalz', 'Gewürzmischung Thai-Curry', 'Steak Gewürzsalz', 'China Gewürz', 'Gewürzmischung BBQ Steakpfeffer', 'Ingwerstücke', 'EDEKA GEWÜRZE Fuchs-Gruppe Fuego Fajita Seasoning Mix Verbesserte Rezeptur Vegan ohne Geschmacksverstärker und ohne PalmölB. 1.79€ 0.03 kg Beutel. 59.67€ 1kg', 'Zimt gemahlen', 'Oregano', 'Vanilleextrakt-Zubereitung Bio-Bourbon', 'Curry Pulver', 'Ingwer-Orange', 'Zitronenschale', 'Jalapeños', 'Hähnchen Allrounder', 'Bio Curry', 'Bio ingwer', 'Ingwersaft', 'Grüne Peperoni', 'Zimt gemahlen', 'Steak Pfeffer', 'Paprika Rosenscharf', 'Pfefferonen', 'Gemüse Allrounder', 'Hi! Spice - Stullengenie', 'Fuego Taco Seasoning Mix', 'Vanille Extract', 'Bourbon-Vanillepaste', 'Mélanges épices sandwich', 'Sushi Ingwer', 'Peperoni mild', 'Rührei Mix Gewürz', 'Gourmet Vanille-Extrakt', 'Gewürz, Ras el Hanout', 'Zimt Paste', 'Knoblauch granuliert', 'Bio-Kurkumapulver', 'Fix fur salatsauce', 'Paprika geräuchert', 'Bourbon Vanille', 'Bratkartoffel Gewürz', 'Das Beste für Reste', 'Kreuzkümmel', 'Kräuter Quark Gewürz', 'Fix Jäger-Sahne Schnitzel', 'Gewürz-Pfeffer', 'Sonnentor Gewürzblüten', 'Premium-Pilz-Würzpulver', 'Jalapenos', 'Persillade provençale', 'Pfefferonen griechisch', 'Bourbon Bio-Vanille extrakt', 'Vanillepaste', 'Ingwer eingelegt', 'Pfeffer schwarz', 'Oignons', 'Bolognese Gewürz', 'Zitronenschale gerieben', 'Gewürz, Couscous', 'Biofix Gebratene Nudeln (Bami Goreng)', 'Stullen Spice', 'Sushi Ingwer', 'Avocado Toppimg', 'Kurkuma Shot', 'Cola Vanille', 'Gelbe Linse Kurkuma Aufstrich', 'Italian allrounder', 'Jalapeno Scharf', 'Bella italia', 'Curry Madras', 'Mexiko Chili', 'Pasta Konfetti', 'Biofix Spaghetti Bolognese', 'Chilimauste', 'Broccoli Gratin', 'Gefro Curry Indisch Bio', 'Kartoffel Allrounder', 'Vegeta', 'Gefro Bella Italia', 'Biofix', 'Fajita', 'Scharfe Chiliflocken', 'Chili con Carne Mild Ankerkraut', 'Vegeta');
