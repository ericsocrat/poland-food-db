-- PIPELINE (Ready Meals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Ready Meals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4075600058177', '4008366001484', '4000405002704', '4075600058634', '4008366008582', '4008366010967', '4012200046654', '4061458017367', '4008366002757', '4008366001347', '4008366017331', '4061458219655', '4075600111834', '4061462936333', '4061459119190', '4009233003686', '4001724011118', '4036577905093', '4061458042130', '4008366015535', '4008366010981', '4006237642101', '4008366013852', '4015637004945', '4075600125114', '4008366883400', '4008366003686', '4000400130570', '4037300104356', '4008366010042', '40804033', '4008366001309', '4008366003587', '4009233006847', '4008366883301', '4001724038993', '4008366015337', '4015637822952', '4000405002711', '4001724049906', '4009233003952', '4001724015420', '4008366009787', '4008366015511', '4004820124072', '4061462580406', '4001724038597', '4009233003655', '4001724011057', '4001724038900', '4056489451044', '4067796097184', '4001724011170', '40081908', '4008366009763', '4061458009966', '4061458014878', '4001724040538', '4075600112541', '4001724038931', '4061463213211', '4009233003587', '4001724027195', '4056489387688', '4045800700442', '4061461543921', '4008366000500', '4061458017213', '4001724039389', '4030800078943', '4061459977660', '4009233003921', '4056489456483', '4045800460216', '4075600057118', '4061458049382', '4009337902106', '4061458009973', '4001724039655', '4001724038443', '4061459674446', '4008366015498', '4008366017195', '4008366016273', '4260414150449', '4260414150531', '4001724039143', '4075600151328', '4005500339403', '4045800475197', '4260414150470', '4104420016408', '20026394', '4001724036739', '4061461976842', '4337256763196', '4250241204958', '20155087', '4008366003334', '7613034854896')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Ready Meals by pipeline',
    ean = null
where country = 'DE'
  and category != 'Ready Meals'
  and identity_key in ('01fe9490d3dd73237c9eab3dda2721bf', '05783f79efa2ab5fc9cc5c1793b983e3', '0b64fab655ed1894b057867d62fde23b', '0d1b06d9192076d86da971fb3c8c63d5', '0f5d745323437ee54ba0b8249ce16281', '17c94d086ecd2ebe524ba10dbe2f1eb4', '17f732ac2f68ebc1231b7e42d432285d', '1cfddd791cb1d311aebcaa08c9190f25', '1e966bb7759ff1cd72275e04ff009173', '1f3b6928d374942444fea41169f34f78', '1ff37b4df9ba58aef50e351009815490', '211798d7c121bd1a8f653702d7cf95fc', '25b246ebb84cfc8488453740c7b9d36f', '2c9460c8e6e0975214e6614740182f7f', '2c982c532db043fc1a61cf1b6c3c3069', '2dc975265f932112b7853aef5c80bea0', '3074f6fd8f2402e67c67dc423bbee9ac', '30ca5c39d582f1cb65721589f2dc6247', '3107f42bc3585e9a1f6eb38ddfc20f9f', '330b511ec067cc4027f48677dda818c1', '432c51cbd0695d049d40e92bee29b9e8', '4472b7c6f20fc9886cbd09151de19fa9', '44cdaabb9b75d3b53e45914d0e6d927a', '4a0b3af1ae279dd6f4fe953ddfe9358e', '4a6793c61057c3caccf8da896f31ddee', '4a929d412b31fb36af96bbbc7b452b50', '4ec4b5aeb405017b66aee8cae0539cc5', '4f4d58cd3558b64839421c0a33dd72e4', '4f5fba514ea4799d86269bc758fe0266', '50c18968c0e6f22af0f7b428c7c1cdeb', '55264842f7779898b7555dba5fc56427', '562cc547bf212abde8e815dd4453685b', '56dd9f525da904cf0827239c821228aa', '5920ec0b13938383151397325c35ae75', '599ae513353f5a47f00f7c74f6f21d5b', '5b5ec73311e69497ff482190a09a81e8', '5e25372a68e9f699f21c9829bf634f06', '6743446c6727b20b25b07fe62e7c037c', '683a2a8b6f08f3bf190ad60c4a059eb5', '69168e6b0d6718e3a1c9ccd46bfc799f', '69f046e5abb811aac3337e1581de66f2', '6a6de81e404dcc081824eee72e8da508', '6a78fade9f9c78f6ea044256f780df77', '6f5ce13a7987989853595f1d30c12a31', '74e2ff3f0c64c9ec8a77fa559ef7c019', '7c69ff5888fa491aa42e000d333d2291', '808b6661270dfc9b9009cc7e6ee05be6', '8469d3ff4d85550987486eca10ec2d32', '84b0babe620a9e04fa3653212d1f861d', '87f89a99b955c83e69e61684bb181bcc', '9169e55e4e60d26518af4316198273a4', '929449b33a65c6701a7f7edb4035fb93', '9403e1e3da4e667197d6e8a948351eb9', '943567f61a68b4fd2c9d998d7e1f1a5b', '97da3e857be32b2b347da2198ec9020c', '98c742feb91a733eb57bd91f6c4cb3b6', '99830a1e461234c6475e20c71cca73a6', '99ba6923d7f66ed6b3cb0eba0f64109d', '9cbf1bbc09a53924c40c84aea537d082', '9da24a4144d09eea9f72e6c1fa21a9c4', '9ee06074c3977af37575b623d7d02522', '9f441d1e371f23ca7e7622fb211d3101', 'a36ea5514fd636427fdc2c3859c79f05', 'a4f7cf0ff76591128a31c499ed9dd58e', 'a67d112038eba6f3ee08f569a9fe276d', 'a82588cbfd41336ce8a0a789444cd7ba', 'a99a71d4fbe4c5289261c7a0938122e2', 'ab6ea2473c5d2504e4b4139077773c1d', 'ab91e5cb42cadf23e82f7835a4bd1427', 'b1c0df2acb8c7176069859193f19eb8f', 'b2127b9f83d3ac32d824e35f284d64c0', 'b481ee28372ddadd38917d868e0af6f8', 'b6e2d3fa10bc9abbd2fedbd45ed201ff', 'bda420abc16ba53c1ace919f1a8d4c71', 'bfe68ca0f2b5c2c4b2669f083f2f3f78', 'c2dc9344951ee022cf274a51057693c2', 'cea677341467d20497770f96b41588ad', 'ced8687cec6ab702c1d27813705faac8', 'd41ce4dd78200025741c08f762e8e439', 'd4a197c1a24b0c94ee10f14d992263e4', 'd522ad051d0690288799ab5eb8cea3df', 'd91d6e2fcbc67c278471c5c2163c9421', 'daba2ad7ae57b37d4e90fd3a92006ad4', 'db6e22cb9dbe31b36e9070390f48ad78', 'dc0de655632d38be8b9213052ecfc31f', 'dcfe4fe70281acb200899d84091788a0', 'e14ff89af30d8e5657458e383227a6b0', 'e16087e0254f439f35be623ee535f280', 'e2fb9c9d6118db49cd941b6d2c63ba4a', 'e637046089f76a2dc3a02cb278cdc5c5', 'e68d1836a9dd24dad9ac6bae346bcae1', 'e7669f9182cec1f2a1a15ec86489d99b', 'e86c909f54aee19de9268e83e89604b0', 'e8860647d35a8d3ef41c08c724168868', 'ec3e07eb2c4ef240a3683aecd615ea2c', 'ee4f9f5fa4d3234f0de7c181dcfc20c8', 'f1d85f64a406389922a29856684409c6', 'fc0bc877e818e24d3574795bf2106503', 'ff604530e33a573e4d27f16e3c262c44', 'ffd98336feb78819c7e5e209809a4cc2')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Vegane Maultaschen mit feinem Gemüse', 'not-applicable', 'Aldi', 'none', '4075600058177'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Bratkartoffel Hähnchen Pfanne', 'not-applicable', 'Kaufland', 'none', '4008366001484'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Ready Meals', 'Fleischsalat (vegan) - Rügenwalder Mühle', 'not-applicable', null, 'none', '4000405002704'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Gemüse-Maultaschen', 'not-applicable', 'Aldi', 'none', '4075600058634'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Hühnerfrikassee', 'not-applicable', 'Lidl', 'none', '4008366008582'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Rahmgeschnetzeltes mit Hähnchen und Spätzle', 'not-applicable', null, 'none', '4008366010967'),
  ('DE', 'Kuehne', 'Grocery', 'Ready Meals', 'Schlemmertöpfchen gew. Gurken', 'not-applicable', null, 'none', '4012200046654'),
  ('DE', 'Golden Seafood', 'Grocery', 'Ready Meals', 'Fischstäbchen', 'not-applicable', 'Aldi', 'none', '4061458017367'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Spätzle Pfanne', 'not-applicable', null, 'none', '4008366002757'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Hähnchen Curry', 'not-applicable', 'Kaufland', 'none', '4008366001347'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Rotes Curry mit Hähnchen und Reis', 'not-applicable', null, 'none', '4008366017331'),
  ('DE', 'Kühlmann', 'Grocery', 'Ready Meals', 'Klarer Weißkrautsalat', 'not-applicable', 'Aldi', 'none', '4061458219655'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Freilandhähnchen-Maultaschen', 'not-applicable', 'Aldi', 'none', '4075600111834'),
  ('DE', 'Bunte Küche', 'Grocery', 'Ready Meals', 'Pasta mit Hähnchen in fruchtiger Tomatensoße', 'not-applicable', 'Aldi', 'none', '4061462936333'),
  ('DE', 'Daylicious', 'Grocery', 'Ready Meals', 'Salatcup - Hähnchen mit Senf-Dressing', 'not-applicable', 'Aldi', 'none', '4061459119190'),
  ('DE', 'Original Wagner', 'Grocery', 'Ready Meals', 'Flammkuchen Elsässer Art', 'not-applicable', null, 'none', '4009233003686'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Die Ofenfrische Vier Käse', 'not-applicable', null, 'none', '4001724011118'),
  ('DE', 'Dilek', 'Grocery', 'Ready Meals', 'Gefüllte Weinblätter mit Reis', 'not-applicable', 'Lidl', 'none', '4036577905093'),
  ('DE', 'Aldi', 'Grocery', 'Ready Meals', 'Hähnchen Mediterran', 'not-applicable', 'Aldi', 'none', '4061458042130'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Wildlachs in Kräuterrahm', 'not-applicable', null, 'none', '4008366015535'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Paprika Sahne Hähnchen mit Bandnudeln', 'not-applicable', null, 'none', '4008366010981'),
  ('DE', 'Reis-fit', 'Grocery', 'Ready Meals', 'Linsen mit Reis & Gemüse - Fach 14', 'not-applicable', null, 'none', '4006237642101'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Thai Style Hähnchen mit Bandnudeln', 'not-applicable', null, 'none', '4008366013852'),
  ('DE', 'Bauck Hof', 'Grocery', 'Ready Meals', 'Grünkern Burger', 'dried', null, 'none', '4015637004945'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Bio Gemüse Maultaschen', 'not-applicable', null, 'none', '4075600125114'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Gemüsebowl Cremiges Linsencurry mit Kürbis & Spinat', 'not-applicable', null, 'none', '4008366883400'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Hackbällchen Pfanne', 'not-applicable', null, 'none', '4008366003686'),
  ('DE', 'Pfanni', 'Grocery', 'Ready Meals', 'Kartoffelknödel halb & halb', 'dried', null, 'none', '4000400130570'),
  ('DE', 'Erasco', 'Grocery', 'Ready Meals', 'Hühner Reis-Topf', 'not-applicable', null, 'none', '4037300104356'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Reis Hähnchen Pfanne', 'not-applicable', null, 'none', '4008366010042'),
  ('DE', 'Kühne', 'Grocery', 'Ready Meals', 'Grünkohl', 'not-applicable', null, 'none', '40804033'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Bami Goreng', 'not-applicable', 'Kaufland', 'none', '4008366001309'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Butter Chicken', 'not-applicable', null, 'none', '4008366003587'),
  ('DE', 'Original Wagner', 'Grocery', 'Ready Meals', 'Pizza Die Backfrische Mozzarella', 'not-applicable', null, 'none', '4009233006847'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Nice Rice - Korean Style', 'not-applicable', null, 'none', '4008366883301'),
  ('DE', 'Dr. Oetker Ristorante', 'Grocery', 'Ready Meals', 'Ristorante PIZZA TONNO', 'not-applicable', 'Penny', 'none', '4001724038993'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Paella', 'not-applicable', 'Kaufland', 'none', '4008366015337'),
  ('DE', 'Bauch Hof', 'Grocery', 'Ready Meals', 'Falafel', 'dried', null, 'none', '4015637822952'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Ready Meals', 'Veganer Schinkenspicker Salat', 'not-applicable', null, 'none', '4000405002711'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Suprema Pizza Calabrese & ''Nduja', 'not-applicable', null, 'none', '4001724049906'),
  ('DE', 'Original Wagner', 'Grocery', 'Ready Meals', 'Steinofen-Pizza Mozzarella Vegetarisch', 'not-applicable', 'Lidl', 'none', '4009233003952'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Die Ofenfrische Margherita', 'not-applicable', null, 'none', '4001724015420'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Fisch Schlemmerfilet Mediterraner Art', 'not-applicable', null, 'none', '4008366009787'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Fettuccine Wildlachs', 'not-applicable', null, 'none', '4008366015511'),
  ('DE', 'Dahlhoff Feinkost', 'Grocery', 'Ready Meals', 'Kartoffelsalat - Tegernseer Art', 'not-applicable', 'Netto', 'none', '4004820124072'),
  ('DE', 'Bio', 'Grocery', 'Ready Meals', 'Veganer Linseneintopf', 'not-applicable', 'Aldi', 'none', '4061462580406'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Tradizionale Margherita', 'not-applicable', null, 'none', '4001724038597'),
  ('DE', 'Original Wagner', 'Grocery', 'Ready Meals', 'Steinofen-Pizza - Diavolo', 'not-applicable', 'Netto', 'none', '4009233003655'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Die Ofenfrische Speciale', 'not-applicable', 'Netto', 'none', '4001724011057'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Salame Ristorante', 'not-applicable', 'Lidl', 'none', '4001724038900'),
  ('DE', 'Vemondo', 'Grocery', 'Ready Meals', 'Vegan pizza Verdura', 'not-applicable', 'Lidl', 'none', '4056489451044'),
  ('DE', 'Dm Bio', 'Grocery', 'Ready Meals', 'Kichererbseneintopf mit Kokosmilch', 'not-applicable', null, 'none', '4067796097184'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Die Ofenfrische Salami', 'not-applicable', 'Lidl', 'none', '4001724011170'),
  ('DE', 'Hengstenberg', 'Grocery', 'Ready Meals', 'Mildes Weinsauerkraut', 'fermented', 'Lidl', 'none', '40081908'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Fisch Schlemmerfilet Brokkoli Mandel', 'not-applicable', null, 'none', '4008366009763'),
  ('DE', 'Omnimax Lebensmittel', 'Grocery', 'Ready Meals', 'Chili con Carne', 'not-applicable', 'Aldi', 'none', '4061458009966'),
  ('DE', 'Cucina Nobile', 'Grocery', 'Ready Meals', 'Tortelloni - Spinat-Ricotta', 'not-applicable', 'Aldi', 'none', '4061458014878'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'La Mia Grande Rucola', 'not-applicable', null, 'none', '4001724040538'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Vegane Maultaschen 2.0', 'not-applicable', null, 'none', '4075600112541'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Ristorante Pizza Funghi', 'not-applicable', null, 'none', '4001724038931'),
  ('DE', 'GiaPizza', 'Grocery', 'Ready Meals', 'Bio-Dinkel-Steinofenpizza - Spinat', 'not-applicable', 'Aldi', 'none', '4061463213211'),
  ('DE', 'Nestlé', 'Grocery', 'Ready Meals', 'Pizza Speciale', 'not-applicable', 'Netto', 'none', '4009233003587'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'La Mia Grande Pizza Margherita', 'not-applicable', null, 'none', '4001724027195'),
  ('DE', 'Lidl', 'Grocery', 'Ready Meals', 'Vegane Kartoffel-Schupfnudeln', 'not-applicable', 'Lidl', 'none', '4056489387688'),
  ('DE', 'Popp', 'Grocery', 'Ready Meals', 'Kartoffelsalat Gurke, Zwiebel & Ei', 'not-applicable', null, 'none', '4045800700442'),
  ('DE', 'Bon-ri', 'Grocery', 'Ready Meals', 'Express Reis Parboiled Mexikanische Art', 'not-applicable', 'Aldi', 'none', '4061461543921'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Nom Nom Noodles', 'not-applicable', null, 'none', '4008366000500'),
  ('DE', 'Condeli', 'Grocery', 'Ready Meals', 'Lasagne Bolognese', 'not-applicable', 'Aldi', 'none', '4061458017213'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Ristorante Pizza Pasta', 'not-applicable', null, 'none', '4001724039389'),
  ('DE', 'Nordsee', 'Grocery', 'Ready Meals', 'Fischfrikadellen', 'not-applicable', 'Lidl', 'none', '4030800078943'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Ready Meals', 'Samosas', 'not-applicable', 'Aldi', 'none', '4061459977660'),
  ('DE', 'Nestlé', 'Grocery', 'Ready Meals', 'Steinofen-Pizza Thunfisch', 'not-applicable', null, 'none', '4009233003921'),
  ('DE', 'Vemondo', 'Grocery', 'Ready Meals', 'Pumpkin & quinoa', 'not-applicable', 'Lidl', 'none', '4056489456483'),
  ('DE', 'Feinkost Popp', 'Grocery', 'Ready Meals', 'Krautsalat griechischer Art', 'not-applicable', null, 'none', '4045800460216'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'Rindfleisch-Maultaschen', 'not-applicable', 'Lidl', 'none', '4075600057118'),
  ('DE', 'GOOD Choice', 'Grocery', 'Ready Meals', 'Rosmarinkartoffeln // 2 kg Kart.frisch oben / 2,5 kg frisch Keller', 'not-applicable', 'Aldi', 'none', '4061458049382'),
  ('DE', 'Steinhaus', 'Grocery', 'Ready Meals', 'Steinpilz-Champignon-Totelli', 'not-applicable', null, 'none', '4009337902106'),
  ('DE', 'Omnimax Lebensmittel', 'Grocery', 'Ready Meals', 'Chili sin Carne', 'not-applicable', 'Aldi', 'none', '4061458009973'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Ristorante Pizza Margherita Pomodori', 'not-applicable', 'Netto', 'none', '4001724039655'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Tradizionale Speciale', 'not-applicable', null, 'none', '4001724038443'),
  ('DE', 'Speisezeit', 'Grocery', 'Ready Meals', 'Red Thai Curry', 'not-applicable', 'Aldi', 'none', '4061459674446'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Tagliatelle Wildlachs', 'not-applicable', null, 'none', '4008366015498'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Veganes Bami Goreng', 'not-applicable', null, 'none', '4008366017195'),
  ('DE', 'FRoSTA', 'Grocery', 'Ready Meals', 'Bandnudeln Pilz', 'not-applicable', null, 'none', '4008366016273'),
  ('DE', 'Gustavo Gusto', 'Grocery', 'Ready Meals', 'Tiefkühler Pizza groß', 'not-applicable', null, 'none', '4260414150449'),
  ('DE', 'Gustavo Gusto', 'Grocery', 'Ready Meals', 'Vier Käse für ein Halleluja - Pizza Quattro Formaggi', 'not-applicable', null, 'none', '4260414150531'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Ristorante Pizza Vegetale', 'not-applicable', null, 'none', '4001724039143'),
  ('DE', 'Bürger', 'Grocery', 'Ready Meals', 'BIO Maultaschen', 'not-applicable', null, 'none', '4075600151328'),
  ('DE', 'Maggi', 'Grocery', 'Ready Meals', 'Ravioli in Tomatensauce', 'not-applicable', null, 'none', '4005500339403'),
  ('DE', 'Feinkost Popp', 'Grocery', 'Ready Meals', 'Feiner Coleslaw-Salat', 'not-applicable', null, 'none', '4045800475197'),
  ('DE', 'Gustavo Gusto', 'Grocery', 'Ready Meals', 'Gustavo Gusto Pizza Salame 4260414150470 Steinofenpizza nach italienischer Art mit Tomatensoße, laktosefreiem, schnittfestem Mozzarella und Rindersalami, teilweise vorgebacken und tiefgekühlt', 'not-applicable', 'Netto', 'none', '4260414150470'),
  ('DE', 'Alnatura', 'Grocery', 'Ready Meals', 'Kartoffel Püree', 'not-applicable', null, 'none', '4104420016408'),
  ('DE', 'Eridanous', 'Grocery', 'Ready Meals', 'Bohnen weiß eingelegt in Tomatensoße', 'baked', 'Lidl', 'none', '20026394'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Die Ofenfrische Thunfisch', 'not-applicable', null, 'none', '4001724036739'),
  ('DE', 'Speise Zeit', 'Grocery', 'Ready Meals', 'Linseneintopf', 'not-applicable', null, 'none', '4061461976842'),
  ('DE', 'REWE to go', 'Grocery', 'Ready Meals', 'Hähnchen Salat', 'not-applicable', null, 'none', '4337256763196'),
  ('DE', 'Iglo', 'Grocery', 'Ready Meals', '8 Lachs-Stäbchen', 'not-applicable', null, 'none', '4250241204958'),
  ('DE', 'Ocean Sea', 'Grocery', 'Ready Meals', 'Fischstäbchen', 'not-applicable', 'Lidl', 'none', '20155087'),
  ('DE', 'Frosta', 'Grocery', 'Ready Meals', 'Mexican Style Chicken', 'not-applicable', null, 'none', '4008366003334'),
  ('DE', 'Original Wagner', 'Grocery', 'Ready Meals', 'Rustipani dunkles Ofenbrot geräucherter Käse', 'not-applicable', null, 'none', '7613034854896')
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
where country = 'DE' and category = 'Ready Meals'
  and is_deprecated is not true
  and product_name not in ('Vegane Maultaschen mit feinem Gemüse', 'Bratkartoffel Hähnchen Pfanne', 'Fleischsalat (vegan) - Rügenwalder Mühle', 'Gemüse-Maultaschen', 'Hühnerfrikassee', 'Rahmgeschnetzeltes mit Hähnchen und Spätzle', 'Schlemmertöpfchen gew. Gurken', 'Fischstäbchen', 'Spätzle Pfanne', 'Hähnchen Curry', 'Rotes Curry mit Hähnchen und Reis', 'Klarer Weißkrautsalat', 'Freilandhähnchen-Maultaschen', 'Pasta mit Hähnchen in fruchtiger Tomatensoße', 'Salatcup - Hähnchen mit Senf-Dressing', 'Flammkuchen Elsässer Art', 'Die Ofenfrische Vier Käse', 'Gefüllte Weinblätter mit Reis', 'Hähnchen Mediterran', 'Wildlachs in Kräuterrahm', 'Paprika Sahne Hähnchen mit Bandnudeln', 'Linsen mit Reis & Gemüse - Fach 14', 'Thai Style Hähnchen mit Bandnudeln', 'Grünkern Burger', 'Bio Gemüse Maultaschen', 'Gemüsebowl Cremiges Linsencurry mit Kürbis & Spinat', 'Hackbällchen Pfanne', 'Kartoffelknödel halb & halb', 'Hühner Reis-Topf', 'Reis Hähnchen Pfanne', 'Grünkohl', 'Bami Goreng', 'Butter Chicken', 'Pizza Die Backfrische Mozzarella', 'Nice Rice - Korean Style', 'Ristorante PIZZA TONNO', 'Paella', 'Falafel', 'Veganer Schinkenspicker Salat', 'Suprema Pizza Calabrese & ''Nduja', 'Steinofen-Pizza Mozzarella Vegetarisch', 'Die Ofenfrische Margherita', 'Fisch Schlemmerfilet Mediterraner Art', 'Fettuccine Wildlachs', 'Kartoffelsalat - Tegernseer Art', 'Veganer Linseneintopf', 'Pizza Tradizionale Margherita', 'Steinofen-Pizza - Diavolo', 'Die Ofenfrische Speciale', 'Pizza Salame Ristorante', 'Vegan pizza Verdura', 'Kichererbseneintopf mit Kokosmilch', 'Die Ofenfrische Salami', 'Mildes Weinsauerkraut', 'Fisch Schlemmerfilet Brokkoli Mandel', 'Chili con Carne', 'Tortelloni - Spinat-Ricotta', 'La Mia Grande Rucola', 'Vegane Maultaschen 2.0', 'Ristorante Pizza Funghi', 'Bio-Dinkel-Steinofenpizza - Spinat', 'Pizza Speciale', 'La Mia Grande Pizza Margherita', 'Vegane Kartoffel-Schupfnudeln', 'Kartoffelsalat Gurke, Zwiebel & Ei', 'Express Reis Parboiled Mexikanische Art', 'Nom Nom Noodles', 'Lasagne Bolognese', 'Ristorante Pizza Pasta', 'Fischfrikadellen', 'Samosas', 'Steinofen-Pizza Thunfisch', 'Pumpkin & quinoa', 'Krautsalat griechischer Art', 'Rindfleisch-Maultaschen', 'Rosmarinkartoffeln // 2 kg Kart.frisch oben / 2,5 kg frisch Keller', 'Steinpilz-Champignon-Totelli', 'Chili sin Carne', 'Ristorante Pizza Margherita Pomodori', 'Pizza Tradizionale Speciale', 'Red Thai Curry', 'Tagliatelle Wildlachs', 'Veganes Bami Goreng', 'Bandnudeln Pilz', 'Tiefkühler Pizza groß', 'Vier Käse für ein Halleluja - Pizza Quattro Formaggi', 'Ristorante Pizza Vegetale', 'BIO Maultaschen', 'Ravioli in Tomatensauce', 'Feiner Coleslaw-Salat', 'Gustavo Gusto Pizza Salame 4260414150470 Steinofenpizza nach italienischer Art mit Tomatensoße, laktosefreiem, schnittfestem Mozzarella und Rindersalami, teilweise vorgebacken und tiefgekühlt', 'Kartoffel Püree', 'Bohnen weiß eingelegt in Tomatensoße', 'Die Ofenfrische Thunfisch', 'Linseneintopf', 'Hähnchen Salat', '8 Lachs-Stäbchen', 'Fischstäbchen', 'Mexican Style Chicken', 'Rustipani dunkles Ofenbrot geräucherter Käse');
