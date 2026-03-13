-- PIPELINE (Coffee & Tea): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Coffee & Tea'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4005500086062', '4009041101017', '4061458002875', '4008167037002', '4046234767414', '4000508059087', '4005500005827', '4006581020686', '4052700068398', '4046234815948', '4021155043809', '4047247382144', '4061458002899', '4002971605501', '4058172487255', '4058172487316', '4006581092607', '4052700073453', '4337256382304', '4008167152729', '4005500274995', '4008167103905', '4056489893882', '42413660', '4388840018321', '4023600016482', '4311501697733', '4311501482223', '4063367480638', '4047046006098', '4002720000496', '4056489884057', '4024297440154', '4008167102113', '4056489576792', '4008452043947', '7613032569556', '4316268595322', '4052700085715', '4047247382113', '4047046005008', '4052700072159', '4002720001219', '4061445226840', '7613036303910', '8445290603708', '4316268668958', '4104420224810', '8711000509388', '8711000433270', '8711000371237', '5011546460437', '4061458003018', '42413677', '20084035', '8003753900438', '8711000506325', '20149499', '42413684', '4316268595407', '20441463', '4316268595360', '4311501482162', '8000070009745', '7610900237654', '4337256003896', '4311501797471', '4311501387894', '7610900239139', '4311501697856', '4311501119365', '20036850', '4311501664698', '7613031514793', '4316268595421', '8711000390757', '7610900251759', '20705817', '4337185298066', '8711000506448', '7613036310116', '7610900138906', '8711000496312', '7613036900072', '7610900205165', '8711000504895', '7613036914321', '20715212', '8711000891735', '7613037788884', '8711000496343', '8003753900520', '8003753915050', '7613037491173', '8711000849941', '7610900138890', '8711000504802', '7613035690660', '8711000525159', '7613036960298')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Coffee & Tea by pipeline',
    ean = null
where country = 'DE'
  and category != 'Coffee & Tea'
  and identity_key in ('00fb97a27762b96d2d23ddb772efeda3', '046b4de5d101c3a0ea9a77447f2084da', '0557a4a7c4ae01ab391fa874da1dac45', '05a0f33b4cecb606868b2bd3c9d38ec0', '08364a00f6d632c2cd24ef3270e405e9', '15d51965d1983a0ccfb027c46fbf560c', '1a12abd04f72950e75186a56cb3f64c6', '1b6452fb4dd688d7bde80652f4c22917', '22ccac3636a5f9f54bfe52993671bcd6', '25501d1b2771a3a72ecc82a90f7de2e9', '2ad88653e9cd085ee2c9a2fc5ed9f5f0', '2cf97c75770c540a5d47737077f9771c', '2dd8176cf182e470dcc6b882a40d8033', '303443b246faa8c1e23594bc2e587e48', '30df9a4c127c91a562f045d54733985a', '323c306b6bdcbd991562921c6554dace', '34ef60d7d1eda7a98b6d6ddbdae029de', '352de6c697d1c7e62be9ddffab2b9818', '361f8f8da7c9ebb70bdf82782f01f4e3', '3834864846a4a24beb6575b1e21b0f5a', '3c36de592c7ae1d18e312f4021937316', '3f714f5a2d8a8ed31242e18b590fd335', '4134b81354d7a136267afe63e30fc98d', '4c1e51718fa6fffde8df1582eaa9bd68', '4d0c5171dafa03ae91f9fb1982f667bf', '4dd4c7235919faefc62cef1a30708eea', '4eaa20054eb2a89975a902a88a775437', '4f2d21bdab72a7ab1c04378153200f60', '507984073050b627bf2262939cac326b', '57eb3f541d60f0110cac4625fc9c5dd2', '580977655a3569130ba428bcdebe81e7', '587a1209b9eec3a09fc8f8f2ed49c58c', '5cf47752745590124e2a7812696b4815', '5e53db46f280dc5c9e3d457c0391f324', '5eb032cd98d9bb9eaaec87ccaea06074', '64f97673a6116545308122db651a7c93', '6937c7a24666fe958b8c60f550e83fcd', '695981c5199818502f26ca39f225910c', '6d0ba039263fdffe6ae7095bd528c480', '6e2033b3c1c18330940557ee04881659', '6ff26a8bdf92da6d70ad5744bddfffc1', '70ebe01af0b395570bfe6508e776669a', '71f19d0fd099f1c1db46d5baaab1d6a0', '7265d80d2f4179567a8f9c81921dccbe', '72e9ab4db96a2343261dd545cb6602da', '790bfd6218d2a3a9424077d192fc6c50', '7c69f3bac26479848ddaf0b6ae73236c', '81420b43f36bc0d9aac35a8e53a7cbad', '81deb0acdf8eeaf6ecdd46748e0b447e', '8cabebb5f4b007c6beb78e5008b0c4e8', '8e148941f88ab5c9315890c07cd74b44', '912a09bb083dda6b52ebbd4bf0d8b294', '925c93acd597aee06c321e1d25a1a869', '92abbbba3d77e91f41540647e1edf388', '93077ff36dc0f8cd989ba43e64d34cd8', '94a7f3c83c90536064342425ff663ed2', 'a3e0a9a1e765b8fba3eba4245c8eae41', 'aa35c3ad981535f1a7f8dea55b2ed703', 'ac7418541a16afba26aa77ab755f5bb2', 'adca3b96075d7d37674c0cb72baf652e', 'b05b726bb464daf6d5e7d1a051f30847', 'b2695d6efe82cf1dbed314f163230f85', 'b86e37b90c1eca7b68ce55fbf686b8c6', 'bac96ca012919cce06eedadcc5a9d92f', 'bed0749d8487c5b67b33fc0ea4180ae8', 'c218fb5b9b08f92a07dd9acd1b0e3e21', 'c2f72ff313ac8eecbcf6c097cf17009a', 'c61764020974d16e4c7ad95205026218', 'c62caacd1849c0c3beb1e8c176bc757d', 'c6f0ada17f25bceca94d1ce0fa90a963', 'c71ffd72f0bf91e26dea138c193fb0d2', 'c90c14d9fab4ac2149235629bb0fee79', 'c9fc75e4b5e5dd9dd242b0beb9fc9573', 'cc18c9121b97ed56a3aa9c3e3dfd2f29', 'cd32873fc7b2f93ea27d6d286b598b75', 'cfea0736e5d020f1491238f36183b87a', 'd0f9caafec4b2218fbed4597a7f42fff', 'd2c5f99119b42e0a7559458c8c1a89b7', 'd46d3ffa7900562e0f375ff6379e2556', 'db953ad50c4b5842b36aad1f89a5889e', 'dcc141a6f7e752b2c217a415bd5cf654', 'e27ba1e6f469b23ce88e888f7cf4f8ac', 'e2e242f8f5cd66fdf586ad0f8e3b02f8', 'e384d2116d3d967d09b87e0ad0d42864', 'e3f2a1c9482f9a375c36211e268c9bde', 'e434c82bf587c9f2f5beb67c6e550ceb', 'e48b23056cdd2b7efd8e785f115b79bd', 'e590a40eed1dd135d33c115ee1f9c3f6', 'e6868abe6e8e4efaade9836c89b53438', 'ecda25286ee84346e3e9c912de4050d5', 'eda41f0258b276712826cdb263ef7dbe', 'ef8bad2d01bcf4ea01f5a737e387a83b', 'f5cc42e806ad297f68cedc164a7962fc', 'f79d497c19969b32f2af2a5705c2aaab', 'f9ad6dffa7bf8e18ff615d03ce7b8698', 'f9e8861701069e434171c838ebd96942', 'fb70b771febce2f1bb1233622d1e91c5', 'fb756ef7fa454007257e107987382540', 'fb83edb7488601dcaaa870c7350bf05c', 'fbe530da6828efcfe9b60bd566f99036')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Caro Landkaffee extra kräftig', 'not-applicable', null, 'none', '4005500086062'),
  ('DE', 'Grana', 'Grocery', 'Coffee & Tea', 'Feiner Landkaffee Aus Vollem Korn Geröstet, Kaffee', 'not-applicable', 'Kaufland', 'none', '4009041101017'),
  ('DE', 'Amaroy', 'Grocery', 'Coffee & Tea', 'Entkoffeiniert Premium Löslicher Kaffee', 'not-applicable', 'Aldi', 'none', '4061458002875'),
  ('DE', 'Dallmayr', 'Grocery', 'Coffee & Tea', 'Kaffee - GOLD - löslicher Kaffee', 'not-applicable', null, 'none', '4008167037002'),
  ('DE', 'Tchibo', 'Grocery', 'Coffee & Tea', 'Feine Milde Natur-mild lösl. Kaffee', 'not-applicable', null, 'none', '4046234767414'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Krönung Classic ganze Bohnen', 'not-applicable', null, 'none', '4000508059087'),
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Nescafé Classic', 'not-applicable', 'Lidl', 'none', '4005500005827'),
  ('DE', 'Lemonaid Beverages GmbH', 'Grocery', 'Coffee & Tea', 'Café Intención eclógico', 'not-applicable', null, 'none', '4006581020686'),
  ('DE', 'Krüger', 'Grocery', 'Coffee & Tea', 'Cappuccino Schoko', 'not-applicable', null, 'none', '4052700068398'),
  ('DE', 'Tchibo', 'Grocery', 'Coffee & Tea', 'Barista Caffè Crema Bohnen', 'not-applicable', null, 'none', '4046234815948'),
  ('DE', 'Hearts', 'Grocery', 'Coffee & Tea', 'Cappuccino mit feiner Kakaonote', 'not-applicable', 'Lidl', 'none', '4021155043809'),
  ('DE', 'Aldi', 'Grocery', 'Coffee & Tea', 'Cappuccino Schoko', 'not-applicable', 'Aldi', 'none', '4047247382144'),
  ('DE', 'Aldi', 'Grocery', 'Coffee & Tea', 'Family cappuccino', 'not-applicable', 'Aldi', 'none', '4061458002899'),
  ('DE', 'Ehrmann', 'Grocery', 'Coffee & Tea', 'Protein Caffe Latte', 'not-applicable', 'Lidl', 'none', '4002971605501'),
  ('DE', 'DmBio', 'Grocery', 'Coffee & Tea', 'Kaffee Klassik Gemahlen', 'not-applicable', null, 'none', '4058172487255'),
  ('DE', 'DmBio', 'Grocery', 'Coffee & Tea', 'Espresso gemahlen', 'not-applicable', null, 'none', '4058172487316'),
  ('DE', 'J.J. Darboven GmbH & Co KG', 'Grocery', 'Coffee & Tea', 'Café intención ecológico', 'not-applicable', 'Kaufland', 'none', '4006581092607'),
  ('DE', 'Krüger', 'Grocery', 'Coffee & Tea', 'Cappuccino Stracciatella', 'not-applicable', null, 'none', '4052700073453'),
  ('DE', 'Ja!', 'Grocery', 'Coffee & Tea', 'Typ Cappuccino - weniger süß im Geschmack', 'not-applicable', null, 'none', '4337256382304'),
  ('DE', 'Dallmayr', 'Grocery', 'Coffee & Tea', 'Crema d''Oro Kaffee', 'not-applicable', null, 'none', '4008167152729'),
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Eiskaffee', 'not-applicable', null, 'none', '4005500274995'),
  ('DE', 'Dallmayr', 'Grocery', 'Coffee & Tea', 'Dallmayr Kaffee Prodomo Naturmild', 'not-applicable', null, 'none', '4008167103905'),
  ('DE', 'Milbona', 'Grocery', 'Coffee & Tea', 'Latte macchiato lactose free', 'not-applicable', null, 'none', '4056489893882'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Latte Macchiato weniger süß', 'not-applicable', 'Netto', 'none', '42413660'),
  ('DE', 'Rewe', 'Grocery', 'Coffee & Tea', 'Extra löslicher Kaffee', 'not-applicable', null, 'none', '4388840018321'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Coffee & Tea', 'High Protein Coffee Drink - Latte Macchiato Style', 'not-applicable', null, 'none', '4023600016482'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Coffee & Tea', 'Latte Macchiato - weniger süß', 'not-applicable', null, 'none', '4311501697733'),
  ('DE', 'Edeka', 'Grocery', 'Coffee & Tea', 'Getränkepulver Typ Cappuccino (weniger süß)', 'not-applicable', null, 'none', '4311501482223'),
  ('DE', 'K Classic to go', 'Grocery', 'Coffee & Tea', 'Latte Espresso', 'not-applicable', null, 'none', '4063367480638'),
  ('DE', 'Senseo', 'Grocery', 'Coffee & Tea', 'Senseo Kaffeepads Caffè Pads', 'not-applicable', null, 'none', '4047046006098'),
  ('DE', 'Melitta', 'Grocery', 'Coffee & Tea', 'Kaffee Harmonie entkoffeiniert', 'not-applicable', null, 'none', '4002720000496'),
  ('DE', 'Lidl Milbona', 'Grocery', 'Coffee & Tea', 'Latte Macchiato', 'not-applicable', null, 'none', '4056489884057'),
  ('DE', 'Naturata', 'Grocery', 'Coffee & Tea', 'Getreidekaffee Instant', 'not-applicable', null, 'none', '4024297440154'),
  ('DE', 'Dallmayr', 'Grocery', 'Coffee & Tea', 'Kaffee', 'not-applicable', null, 'none', '4008167102113'),
  ('DE', 'Bellarom', 'Grocery', 'Coffee & Tea', 'Kaffeebohnen', 'not-applicable', null, 'none', '4056489576792'),
  ('DE', 'Weihenstephan', 'Grocery', 'Coffee & Tea', 'Rahmjoghurt Eiskaffee', 'fermented', null, 'none', '4008452043947'),
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Nescafé Cappuccino - weniger süß', 'not-applicable', null, 'none', '7613032569556'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Löslicher Kaffee, kräftig', 'not-applicable', 'Netto', 'none', '4316268595322'),
  ('DE', 'Krüger', 'Grocery', 'Coffee & Tea', 'Cappuccino Fein & Cremig', 'not-applicable', null, 'none', '4052700085715'),
  ('DE', 'Moreno', 'Grocery', 'Coffee & Tea', 'Cappuccino Classico', 'not-applicable', null, 'none', '4047247382113'),
  ('DE', 'Coffee Pads', 'Grocery', 'Coffee & Tea', 'Senseo Pads Cappuccino Choco', 'not-applicable', null, 'none', '4047046005008'),
  ('DE', 'Krüger', 'Grocery', 'Coffee & Tea', 'Latte Macchiato', 'not-applicable', null, 'none', '4052700072159'),
  ('DE', 'Melitta', 'Grocery', 'Coffee & Tea', 'Barista Classic Crema', 'not-applicable', null, 'none', '4002720001219'),
  ('DE', 'Eduscho', 'Grocery', 'Coffee & Tea', 'Café Crema (Kaffee)', 'not-applicable', null, 'none', '4061445226840'),
  ('DE', 'Nescafé', 'Grocery', 'Coffee & Tea', 'Löslicher Kaffee entkof.- Fach 21', 'not-applicable', null, 'none', '7613036303910'),
  ('DE', 'Nescafé', 'Grocery', 'Coffee & Tea', 'Typ Cappuccino Weniger Süss', 'not-applicable', null, 'none', '8445290603708'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Typ Cappuccino weniger süß', 'not-applicable', null, 'none', '4316268668958'),
  ('DE', 'Alnatura', 'Grocery', 'Coffee & Tea', 'Kaffee löslich', 'not-applicable', null, 'none', '4104420224810'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Krönung', 'not-applicable', null, 'none', '8711000509388'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Kaffee - Löslich', 'not-applicable', null, 'none', '8711000433270'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Jacobs Kaffee-kapseln Lungo 6 Classico 20 Stück', 'not-applicable', null, 'none', '8711000371237'),
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Nescafé Cappuccino Weniger Süß', 'not-applicable', null, 'none', '5011546460437'),
  ('DE', 'Unknown', 'Grocery', 'Coffee & Tea', 'Kaffee Classico Cappucino', 'not-applicable', null, 'none', '4061458003018'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Latte Espresso', 'not-applicable', 'Netto', 'none', '42413677'),
  ('DE', 'Bellarom', 'Grocery', 'Coffee & Tea', 'Family Cappuccino Chocolate', 'dried', 'Lidl', 'none', '20084035'),
  ('DE', 'Illy', 'Grocery', 'Coffee & Tea', 'Illy Classico 100% Arabica, 250g', 'not-applicable', 'Kaufland', 'none', '8003753900438'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Classic 3in1', 'not-applicable', 'Lidl', 'none', '8711000506325'),
  ('DE', 'Fairglobe', 'Grocery', 'Coffee & Tea', 'Café bio fairglobe', 'not-applicable', 'Lidl', 'none', '20149499'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Latte Cappuccino', 'not-applicable', 'Netto', 'none', '42413684'),
  ('DE', 'Cafèt', 'Grocery', 'Coffee & Tea', 'Typ Cappuccino Classico', 'not-applicable', 'Netto', 'none', '4316268595407'),
  ('DE', 'Bellarom', 'Grocery', 'Coffee & Tea', 'Cappuccino Caramel', 'not-applicable', 'Lidl', 'none', '20441463'),
  ('DE', 'Cafet', 'Grocery', 'Coffee & Tea', 'Family Cappucino Schoko', 'not-applicable', 'Netto', 'none', '4316268595360'),
  ('DE', 'Edeka', 'Grocery', 'Coffee & Tea', 'Cappuccino', 'not-applicable', null, 'none', '4311501482162'),
  ('DE', 'Lavazza', 'Grocery', 'Coffee & Tea', 'Café Bio-Organic', 'not-applicable', null, 'none', '8000070009745'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Caffè Latte', 'not-applicable', 'Netto', 'none', '7610900237654'),
  ('DE', 'Ja!', 'Grocery', 'Coffee & Tea', 'Cappuccino Family mit feiner Kakaonote', 'not-applicable', null, 'none', '4337256003896'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Coffee & Tea', 'Latte espresso', 'not-applicable', null, 'none', '4311501797471'),
  ('DE', 'Edeka Bio', 'Grocery', 'Coffee & Tea', 'Edeka Bio Espresso', 'not-applicable', null, 'none', '4311501387894'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Caffè Latte High Protein', 'not-applicable', 'Aldi', 'none', '7610900239139'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Coffee & Tea', 'Cold Latte Espresso', 'not-applicable', null, 'none', '4311501697856'),
  ('DE', 'Edeka Bio', 'Grocery', 'Coffee & Tea', 'Caffe Crema Kaffeepads', 'not-applicable', null, 'none', '4311501119365'),
  ('DE', 'Milbona', 'Grocery', 'Coffee & Tea', 'Cappucino', 'not-applicable', 'Lidl', 'none', '20036850'),
  ('DE', 'Edeka', 'Grocery', 'Coffee & Tea', 'Family Cappuccino Schoko', 'not-applicable', null, 'none', '4311501664698'),
  ('DE', 'Nescafe', 'Grocery', 'Coffee & Tea', 'Nescafé Classic Mild Instantkaffee', 'not-applicable', 'Kaufland', 'none', '7613031514793'),
  ('DE', 'Cafet', 'Grocery', 'Coffee & Tea', 'Typ Cappuccino Vanille', 'not-applicable', 'Netto', 'none', '4316268595421'),
  ('DE', 'Tassimo', 'Grocery', 'Coffee & Tea', 'Tassimo Morning Café Strong XL', 'not-applicable', null, 'none', '8711000390757'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Caffè Latte Double Zero Macchiato', 'not-applicable', 'Netto', 'none', '7610900251759'),
  ('DE', 'Penny', 'Grocery', 'Coffee & Tea', 'Caffé Latte Espresso', 'not-applicable', 'Penny', 'none', '20705817'),
  ('DE', 'K to go', 'Grocery', 'Coffee & Tea', 'Latte Macchiato', 'not-applicable', 'Kaufland', 'none', '4337185298066'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Kaffeesticks Espresso', 'not-applicable', null, 'none', '8711000506448'),
  ('DE', 'Nescafé', 'Grocery', 'Coffee & Tea', 'Nescafé Gold - Original', 'not-applicable', null, 'none', '7613036310116'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Caffè Latte Cappuccino', 'not-applicable', null, 'none', '7610900138906'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Classic 3:1', 'not-applicable', null, 'none', '8711000496312'),
  ('DE', 'Nescafe', 'Grocery', 'Coffee & Tea', 'Nescafé 3 en 1 classique', 'not-applicable', 'Carrefour', 'none', '7613036900072'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Emmi Caffè Latte Balance', 'not-applicable', null, 'none', '7610900205165'),
  ('DE', 'Tassimo', 'Grocery', 'Coffee & Tea', 'Jacobs Latte Macchiato Classico', 'not-applicable', null, 'none', '8711000504895'),
  ('DE', 'Nestlé', 'Grocery', 'Coffee & Tea', 'Nescafé Gold Bio', 'not-applicable', null, 'none', '7613036914321'),
  ('DE', 'Penny Ready', 'Grocery', 'Coffee & Tea', 'Café Latte Espresso', 'not-applicable', null, 'none', '20715212'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Kaffee Espresso Kaffee', 'not-applicable', null, 'none', '8711000891735'),
  ('DE', 'Nescafé', 'Grocery', 'Coffee & Tea', 'Dolce Gusto Latte Macchiato Caramel', 'not-applicable', null, 'none', '7613037788884'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', '3 in 1 Coffee With Caramel', 'not-applicable', null, 'none', '8711000496343'),
  ('DE', 'Jacobs Douwe Egberts Norge As', 'Grocery', 'Coffee & Tea', 'Caffè in grani classico', 'not-applicable', 'Carrefour', 'none', '8003753900520'),
  ('DE', 'Illy', 'Grocery', 'Coffee & Tea', 'Tostato classico caffè macinato ideale per moka', 'not-applicable', null, 'none', '8003753915050'),
  ('DE', 'Dolce Gusto', 'Grocery', 'Coffee & Tea', 'Latte Macchiato', 'not-applicable', null, 'none', '7613037491173'),
  ('DE', 'Senseo', 'Grocery', 'Coffee & Tea', 'Kaffeepads Classic, XXL', 'not-applicable', null, 'none', '8711000849941'),
  ('DE', 'Emmi', 'Grocery', 'Coffee & Tea', 'Caffè Latte Expresso', 'not-applicable', null, 'none', '7610900138890'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Tassimo Jacobs Latte Macchiato Caramel', 'not-applicable', null, 'none', '8711000504802'),
  ('DE', 'Nescafé Dolce Gusto', 'Grocery', 'Coffee & Tea', 'Nescafe Dolce Gusto Chococino 16cap', 'not-applicable', null, 'none', '7613035690660'),
  ('DE', 'Jacobs', 'Grocery', 'Coffee & Tea', 'Cappuccino von Jacobs', 'not-applicable', null, 'none', '8711000525159'),
  ('DE', 'Nescafe', 'Grocery', 'Coffee & Tea', '2 in 1', 'not-applicable', null, 'none', '7613036960298')
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
where country = 'DE' and category = 'Coffee & Tea'
  and is_deprecated is not true
  and product_name not in ('Caro Landkaffee extra kräftig', 'Feiner Landkaffee Aus Vollem Korn Geröstet, Kaffee', 'Entkoffeiniert Premium Löslicher Kaffee', 'Kaffee - GOLD - löslicher Kaffee', 'Feine Milde Natur-mild lösl. Kaffee', 'Krönung Classic ganze Bohnen', 'Nescafé Classic', 'Café Intención eclógico', 'Cappuccino Schoko', 'Barista Caffè Crema Bohnen', 'Cappuccino mit feiner Kakaonote', 'Cappuccino Schoko', 'Family cappuccino', 'Protein Caffe Latte', 'Kaffee Klassik Gemahlen', 'Espresso gemahlen', 'Café intención ecológico', 'Cappuccino Stracciatella', 'Typ Cappuccino - weniger süß im Geschmack', 'Crema d''Oro Kaffee', 'Eiskaffee', 'Dallmayr Kaffee Prodomo Naturmild', 'Latte macchiato lactose free', 'Latte Macchiato weniger süß', 'Extra löslicher Kaffee', 'High Protein Coffee Drink - Latte Macchiato Style', 'Latte Macchiato - weniger süß', 'Getränkepulver Typ Cappuccino (weniger süß)', 'Latte Espresso', 'Senseo Kaffeepads Caffè Pads', 'Kaffee Harmonie entkoffeiniert', 'Latte Macchiato', 'Getreidekaffee Instant', 'Kaffee', 'Kaffeebohnen', 'Rahmjoghurt Eiskaffee', 'Nescafé Cappuccino - weniger süß', 'Löslicher Kaffee, kräftig', 'Cappuccino Fein & Cremig', 'Cappuccino Classico', 'Senseo Pads Cappuccino Choco', 'Latte Macchiato', 'Barista Classic Crema', 'Café Crema (Kaffee)', 'Löslicher Kaffee entkof.- Fach 21', 'Typ Cappuccino Weniger Süss', 'Typ Cappuccino weniger süß', 'Kaffee löslich', 'Krönung', 'Kaffee - Löslich', 'Jacobs Kaffee-kapseln Lungo 6 Classico 20 Stück', 'Nescafé Cappuccino Weniger Süß', 'Kaffee Classico Cappucino', 'Latte Espresso', 'Family Cappuccino Chocolate', 'Illy Classico 100% Arabica, 250g', 'Classic 3in1', 'Café bio fairglobe', 'Latte Cappuccino', 'Typ Cappuccino Classico', 'Cappuccino Caramel', 'Family Cappucino Schoko', 'Cappuccino', 'Café Bio-Organic', 'Caffè Latte', 'Cappuccino Family mit feiner Kakaonote', 'Latte espresso', 'Edeka Bio Espresso', 'Caffè Latte High Protein', 'Cold Latte Espresso', 'Caffe Crema Kaffeepads', 'Cappucino', 'Family Cappuccino Schoko', 'Nescafé Classic Mild Instantkaffee', 'Typ Cappuccino Vanille', 'Tassimo Morning Café Strong XL', 'Caffè Latte Double Zero Macchiato', 'Caffé Latte Espresso', 'Latte Macchiato', 'Kaffeesticks Espresso', 'Nescafé Gold - Original', 'Caffè Latte Cappuccino', 'Classic 3:1', 'Nescafé 3 en 1 classique', 'Emmi Caffè Latte Balance', 'Jacobs Latte Macchiato Classico', 'Nescafé Gold Bio', 'Café Latte Espresso', 'Kaffee Espresso Kaffee', 'Dolce Gusto Latte Macchiato Caramel', '3 in 1 Coffee With Caramel', 'Caffè in grani classico', 'Tostato classico caffè macinato ideale per moka', 'Latte Macchiato', 'Kaffeepads Classic, XXL', 'Caffè Latte Expresso', 'Tassimo Jacobs Latte Macchiato Caramel', 'Nescafe Dolce Gusto Chococino 16cap', 'Cappuccino von Jacobs', '2 in 1');
