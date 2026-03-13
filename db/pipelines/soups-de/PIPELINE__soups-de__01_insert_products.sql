-- PIPELINE (Soups): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Soups'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061458005814', '4037300104370', '4037300108217', '4002473960351', '4002473962355', '4002473961358', '4037300103250', '4023006392210', '4009062800845', '4047247047616', '4006153697100', '4037300103328', '4023006392234', '4013300035067', '4037300108293', '4037300108491', '4006237642095', '4037300108231', '4037300103236', '4047247047609', '4037300107340', '4037300107371', '4037300104387', '4002473966353', '4037300108279', '4047247311489', '4037300103373', '4037300107135', '4023006392135', '4031829232255', '4037300103786', '4013300034985', '4037300107319', '4061458010023', '4002473807458', '4006622060046', '4006040271130', '4039057400446', '4002473814456', '4031829232200', '4037300104011', '4037300108248', '4037300104004', '4061462580376', '4008002000123', '4056489199083', '4000503243405', '4009062452006', '4061461879259', '4066447892444', '4061458009812', '4058172824470', '4037300107357', '4037300107517', '4037300107661', '4061458009867', '4006276029666', '4061458183147', '4061463579201', '4013182020472', '4061461879297', '4068134046383', '4013300034749', '4061458009829', '4013182020403', '4047247047562', '4037300108309', '4260614720411', '8710236091049', '4067796068351', '4037300108460', '8711200414352', '7613037683561', '4037300107326', '4316268046336', '4008366000296', '4037300103243', '4280000878991', '4013182028058', '4002473967350', '4037300104431', '7613036053600', '4061458009881', '4008391004214', '4013182028591', '4037300107555', '4400108012015', '4061461879273', '4008585103211', '4061462114779', '4061458010030', '7613035151697', '4037300107647', '4311501463383', '4002473859457', '4260655551241', '4015518799007', '4037300107586', '4061458009874', '4023006392142')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Soups by pipeline',
    ean = null
where country = 'DE'
  and category != 'Soups'
  and identity_key in ('037a81eeb7413cea16261deb56534bb1', '07de0e3424b8697a45bdfbc2e2aa9344', '0c9a082003ea710a09e1bf9eb9fb346c', '0c9d1d9e562b979985ab2c56065d93b7', '0d8ac0a107f187a28d635d17d6f45e00', '0e21ae7aaaf0c8d242c2ff3226165d21', '0e31681e7da078803236f4631c44632d', '11e65dfad2ce62204578643866b4d782', '1aef9fc75d05793c32f2adedaddacc5a', '1be91c67abf1d606261885402d7087c3', '1e60ff8da5d896da3f06e7e8d776ea05', '208e035dfbf5235b8c79d992142aa818', '20d32060fdde806514300457ebd73aa6', '21366dddf996b425280d408d110c9780', '252ae228e4b398a13d67102dda1b10ca', '2702575203e3102d3cedbae125c2246c', '28e8d619c047015cfb9f79ab75398f73', '2d2f62aeabae8e8a48eeef2bbbf9f141', '2d7394f5612518e7c4630d277111f2f3', '2fb512bd2068db013a5a7fcf6964cccc', '3070ba918a2a42f08c8e3dab996ab518', '3241ceda9529bb0044debc671b2670c5', '3424c994484cfcffe1527b9e077906b3', '386a0f555c2ccc5da2131f76fd8ed0bf', '39dba6c36214e2bbc006529c3e493abc', '39df54e83878f45eed5d324198598e97', '3b3a543cb859bba3532887b90def9d58', '3bf4d95bad1aba7ebfb9f11476d9808e', '3f7d2e09f6e68699b33401a2f7e9458a', '442386b1334857fa81cebae91a941329', '44bbb5ebd9c8f1d4ddf3ce607f3e937b', '44cdaabb9b75d3b53e45914d0e6d927a', '4803113446c48bdab783f53ecbce991a', '48bc49bc36035b317aa50ca49db3cbdf', '4d4f6403914b8390c90dff6d5d5efc14', '4f55aa8be4f110a56c3c936e05133ad2', '5427871e0439b5c202712ca204412b8b', '54b8aef65d25fddd102686f93b433fb9', '54f75a65c8e56e8fae74a043e0cc12a2', '5bdd05f69062afb1b9728b3ef68efd28', '5bf766f71d00eb6773e357362477eaeb', '5fb9fbac02d6ca061ba405ecc26a51fc', '631c007b3ca05c91e4c2a40dcbf36184', '65c546ae05d85ab625146293ad98438a', '67c5675b0b39e355b163ce2e34b724da', '67d992f53d0a4f0221fcd5ee42d55ef7', '68539918ce9defe1333572b9493c25b9', '6858b3401929814986a09a0bc67cbd4c', '697acf233cd64d95dedb1d48be1b923b', '6a3b42b6cfc55a6bca0ee99156c51382', '6a9e43e1c6e7d85b9ee6eca85dccde38', '6baca37c8ca7c9c065164578d3b0da9e', '6e9424657d3f31bb9fec4a77e5d803d5', '6f5c526c88340996ccf9705b50c4f47d', '739952f2d71932560948610c68e53ef1', '7aadee95db871bd85fc4666d7f780e21', '7adef0270056872a68263aa1314915cd', '7bd01bf57239146c681fbc07153d8cc7', '8148883ac4e051d33b167a6ff4f86f8f', '824f670f289fcefa89244e3c1b93110a', '870d61069814e35d46ef0d80633bb403', '8af4ebd8b09c7ce58f83ee238cf6f82b', '8c6dad0292431d66a023e8875398e057', '8f0f7042c66fb5d735781468eb2708a0', '90915a2ee86556a7620bc70133003060', '9676d6cd13f69c4fab5b1c1c042985fb', '9b19102a5ecb78e22fdcda00eca112ae', '9b350627f9427e479259087155be97aa', '9c5ddfd18091d242c7a353e04ca39e13', '9ec191924e66d740f820deb9ae429fce', '9ee966b5495683b1d3e2f49ab973dcc6', 'a1d7348efa479a177ad25667c0138a38', 'a6fbb6e269a9573fb04c2e97a93d9f12', 'a83911ab597e9ac214f46737e9c8804a', 'abeefb5c79a4e6533ccc792add7e829c', 'acc28438eda01c2a740c3ade4c2797b9', 'ae0acc5af04d184de48a9bb4c4137867', 'b60598301595f2c6034c93917392f266', 'b748eb8479ed7792e8ce0256b50ff61a', 'b85c875533dd6bc4d73a44729e4f187a', 'b8b1d55c2294fc8433d39a666aa2dd33', 'b8d3c58f426cadda57023ec04a420b18', 'be61b4c8d2d08b68849e8f78b1c47513', 'c003e6413f4d6bb9df15a22d43dc1c03', 'cb8b595c69d0708f3af6e7de53af9549', 'd288c8339b45ad2b550241069b31220e', 'd78126a6a3673fe0543be69f1f68aed5', 'd91b5a9d0182243c8e4a049b395dea76', 'd94974d803c9284de5c70d73bdd773cb', 'da0a1851aa820495cad371151c6083b5', 'e3ee49adcc7c03829f805f67ebf19460', 'e451f5b7a577a8b43b78d8f36b0f8adf', 'e82822295df41f8e27d9d8afe628b99f', 'e82ec8c3cbeda1d1d5ab5af152df5ba4', 'ec2320eb4f2c253d8a3885984756c0fb', 'edb9905eccfbfc7d283cbf516c707f61', 'f02f988fe93f701831c73b48e339c8d4', 'f05c1073c0e0ad23f4e14d2425c45b42', 'f0e5a3361e62a63333df4d2717b5b8e4', 'f90c1e742e7ef07d7ab02a5269f37742')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Bio-Gemüsebrühe', 'dried', 'Aldi', 'none', '4061458005814'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Hühner Nudel Topf/ Erasco', 'not-applicable', 'Lidl', 'none', '4037300104370'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Grüne-Bohnen-Eintopf', 'not-applicable', 'Lidl', 'none', '4037300108217'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Hühner- Nudel-Topf/ So. Bas.', 'not-applicable', 'Netto', 'none', '4002473960351'),
  ('DE', '10% Kartoffeln', 'Grocery', 'Soups', 'Grüne Bohnen Eintopf Rind', 'not-applicable', 'Lidl', 'none', '4002473962355'),
  ('DE', 'Bassermann', 'Grocery', 'Soups', 'Eintopf Frühlingstopf m. Klößen', 'not-applicable', 'Kaufland', 'none', '4002473961358'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Grüne Bohnen Kartoffeltopf', 'not-applicable', null, 'none', '4037300103250'),
  ('DE', 'Natur Werk', 'Grocery', 'Soups', 'Kichererbsensuppe (mit Kokoscreme & Kreuzkümmel)', 'not-applicable', 'Netto', 'none', '4023006392210'),
  ('DE', 'Lacroix', 'Grocery', 'Soups', 'Gemüsefond', 'not-applicable', null, 'none', '4009062800845'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Soups', 'Feurige Thaisuppe mit Hühnerfleisch', 'not-applicable', 'Aldi', 'none', '4047247047616'),
  ('DE', 'Zimmermann', 'Grocery', 'Soups', 'Leberknödelsuppe', 'not-applicable', null, 'none', '4006153697100'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Hühner Reis-Topf', 'not-applicable', null, 'none', '4037300103328'),
  ('DE', 'Natur Werk', 'Grocery', 'Soups', 'Süßkartoffelsuppe mit Ingwer und Curry', 'not-applicable', null, 'none', '4023006392234'),
  ('DE', 'Heisse Tasse', 'Grocery', 'Soups', 'Knoblauch Französischer Art mit Croûtons', 'dried', null, 'none', '4013300035067'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Linseneintopf mit Würstchen', 'not-applicable', null, 'none', '4037300108293'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Erasco Kartoffelsuppe m. Würstchen', 'not-applicable', null, 'none', '4037300108491'),
  ('DE', 'Reis-fit', 'Grocery', 'Soups', 'Kichererbsen mit Quinoa & Gemüse', 'not-applicable', null, 'none', '4006237642095'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Westfälische Linsen Eintopf', 'not-applicable', null, 'none', '4037300108231'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'not-applicable', null, 'none', '4037300103236'),
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Pekingsuppe mit Hühnerfleisch', 'not-applicable', null, 'none', '4047247047609'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Lübecker Hochzeitssuppe', 'not-applicable', null, 'none', '4037300107340'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Hühner-Nudelsuppe', 'not-applicable', null, 'none', '4037300107371'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Dose Reistopf mit Fleischklößchen', 'not-applicable', null, 'none', '4037300104387'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Erbsen-Eintopf mit Würstchen', 'not-applicable', null, 'none', '4002473966353'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Dosen Frischgemüsetopf mit Fleischklößchen', 'not-applicable', null, 'none', '4037300108279'),
  ('DE', 'Speisezeit', 'Grocery', 'Soups', 'Hühnernudeltopf', 'not-applicable', null, 'none', '4047247311489'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Hühner Nudel-Topf', 'not-applicable', null, 'none', '4037300103373'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Kürbis Cremesuppe', 'not-applicable', null, 'none', '4037300107135'),
  ('DE', 'Natur Werk', 'Grocery', 'Soups', 'Möhrensuppe mit Ingwer und Kokosmilch', 'not-applicable', null, 'none', '4023006392135'),
  ('DE', 'Ökoland', 'Grocery', 'Soups', 'Linsensuppe mit Würstchenscheiben', 'not-applicable', null, 'none', '4031829232255'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Westfälischer Linsen-Eintopf mit Essig', 'not-applicable', null, 'none', '4037300103786'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Heiße Tasse Champignon-Creme', 'dried', null, 'none', '4013300034985'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Leberknödelsuppe', 'not-applicable', null, 'none', '4037300107319'),
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Fleisch-Bällcheneintopf mit Tomaten & Nudeln', 'not-applicable', null, 'none', '4061458010023'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Rinder Kraftbrühe', 'not-applicable', null, 'none', '4002473807458'),
  ('DE', 'Geti wilba', 'Grocery', 'Soups', 'Hühner Suppe', 'not-applicable', null, 'none', '4006622060046'),
  ('DE', 'Rapunzel', 'Grocery', 'Soups', 'Gemüsebrühe', 'dried', null, 'none', '4006040271130'),
  ('DE', 'BioGourmet', 'Grocery', 'Soups', 'BioGourmet Gemüsebrühe rein pflanzlich', 'not-applicable', null, 'none', '4039057400446'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Zwiebelsuppe französische Art', 'not-applicable', null, 'none', '4002473814456'),
  ('DE', 'Ökoland', 'Grocery', 'Soups', 'Linsensuppe mit Würstchen', 'not-applicable', null, 'none', '4031829232200'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Vegetarischer Linseneintopf', 'not-applicable', 'Lidl', 'none', '4037300104011'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Erbsensuppe Hubertus', 'not-applicable', 'Lidl', 'none', '4037300108248'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Vegetarischer Erbsen-Eintopf', 'not-applicable', null, 'none', '4037300104004'),
  ('DE', 'Bio', 'Grocery', 'Soups', 'Veganer Erbseneintopf', 'not-applicable', 'Aldi', 'none', '4061462580376'),
  ('DE', 'Indonesia', 'Grocery', 'Soups', 'Bihun Suppe', 'not-applicable', null, 'none', '4008002000123'),
  ('DE', 'Kania', 'Grocery', 'Soups', 'Tomaten Suppe - toskanische Art', 'dried', 'Lidl', 'none', '4056489199083'),
  ('DE', 'Meica', 'Grocery', 'Soups', 'Volle Kelle', 'not-applicable', null, 'none', '4000503243405'),
  ('DE', 'Lacroix', 'Grocery', 'Soups', 'Gulaschsuppe', 'not-applicable', null, 'none', '4009062452006'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Soups', 'Bio-Kartoffelsuppe', 'not-applicable', 'Aldi', 'none', '4061461879259'),
  ('DE', 'Dm Bio', 'Grocery', 'Soups', 'Dm Bio Linseneintopf', 'not-applicable', null, 'none', '4066447892444'),
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Gulasch-Suppe', 'not-applicable', 'Aldi', 'none', '4061458009812'),
  ('DE', 'DmBio', 'Grocery', 'Soups', 'Tocană de mazăre ECO', 'not-applicable', null, 'none', '4058172824470'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Kartoffel-Cremesuppe', 'not-applicable', null, 'none', '4037300107357'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Ungarische Gulaschsuppe', 'not-applicable', null, 'none', '4037300107517'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Pfifferling Rahmsuppe', 'not-applicable', null, 'none', '4037300107661'),
  ('DE', 'Buss Fertiggerichte', 'Grocery', 'Soups', 'Thai Suppe', 'not-applicable', 'Aldi', 'none', '4061458009867'),
  ('DE', 'Dreistern', 'Grocery', 'Soups', 'Gulaschsuppe', 'not-applicable', 'Netto', 'none', '4006276029666'),
  ('DE', 'Speisezeit', 'Grocery', 'Soups', 'Bihun-Suppe', 'not-applicable', 'Aldi', 'none', '4061458183147'),
  ('DE', 'Le Gusto', 'Grocery', 'Soups', 'Waldpilzsuppe', 'not-applicable', 'Aldi', 'none', '4061463579201'),
  ('DE', 'Naba Feinkost', 'Grocery', 'Soups', 'Rote Beete Cremesuppe mit Birne', 'not-applicable', null, 'none', '4013182020472'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Soups', 'Bio-Brokkolisuppe', 'not-applicable', 'Aldi', 'none', '4061461879297'),
  ('DE', 'Ener BIO', 'Grocery', 'Soups', 'Čočková polévka', 'not-applicable', 'Rossmann', 'none', '4068134046383'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Heisse Tasse - Tomaten-Creme', 'dried', null, 'none', '4013300034749'),
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Tomaten-Rahmsuppe', 'not-applicable', 'Aldi', 'none', '4061458009829'),
  ('DE', 'Nabio', 'Grocery', 'Soups', 'Erbsensuppe mit Basilikum', 'not-applicable', null, 'none', '4013182020403'),
  ('DE', 'Buss', 'Grocery', 'Soups', 'Ochsenschwanz-Suppe', 'not-applicable', 'Aldi', 'none', '4047247047562'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Erasco Erbsen-Eintopf 4037300108309', 'not-applicable', null, 'none', '4037300108309'),
  ('DE', 'Little Lunch', 'Grocery', 'Soups', 'Kürbissuppe von Little Lunch', 'not-applicable', null, 'none', '4260614720411'),
  ('DE', 'Larco', 'Grocery', 'Soups', 'Hühnerbrühe konzentriert mit Fleisch', 'not-applicable', 'Netto', 'none', '8710236091049'),
  ('DE', 'DmBio', 'Grocery', 'Soups', 'Linseneintopf', 'not-applicable', null, 'none', '4067796068351'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Serbische Bohnensuppe', 'not-applicable', null, 'none', '4037300108460'),
  ('DE', 'Knorr', 'Grocery', 'Soups', 'Bratensoße', 'dried', 'Lidl', 'none', '8711200414352'),
  ('DE', 'Maggi', 'Grocery', 'Soups', '5 Minuten Terrine - Hühner-Nudeltopf', 'dried', 'Penny', 'none', '7613037683561'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Tomatencreme suppe', 'not-applicable', null, 'none', '4037300107326'),
  ('DE', 'Netto', 'Grocery', 'Soups', 'Hühner Nudeltopf', 'not-applicable', 'Netto', 'none', '4316268046336'),
  ('DE', 'Frosta', 'Grocery', 'Soups', 'Yummy Tummy Soup', 'not-applicable', null, 'none', '4008366000296'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Erbsen-Eintopf', 'not-applicable', null, 'none', '4037300103243'),
  ('DE', 'Little Lunch', 'Grocery', 'Soups', 'Little Lunch Bio Little Marokko 4280000878991 Bio-Eintopf mit Gemüse und Gewürzen marokkanischer Art', 'not-applicable', 'Rossmann', 'none', '4280000878991'),
  ('DE', 'Reichenhof', 'Grocery', 'Soups', 'Vegetarischer Linseneintopf', 'not-applicable', null, 'none', '4013182028058'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Eintopf Linseneintopf', 'not-applicable', null, 'none', '4002473967350'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Graupen-Topf', 'not-applicable', null, 'none', '4037300104431'),
  ('DE', 'Maggi', 'Grocery', 'Soups', 'Tütensuppe', 'dried', 'Kaufland', 'none', '7613036053600'),
  ('DE', 'La Finesse', 'Grocery', 'Soups', 'Minestrone', 'not-applicable', null, 'none', '4061458009881'),
  ('DE', 'Seitenbacher', 'Grocery', 'Soups', 'Klare Suppe', 'not-applicable', null, 'none', '4008391004214'),
  ('DE', 'Reichenhof', 'Grocery', 'Soups', 'Vegetarische Gulaschsuppe', 'not-applicable', null, 'none', '4013182028591'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Ochsenschwanzsuppe', 'not-applicable', null, 'none', '4037300107555'),
  ('DE', 'Metzger Meyer', 'Grocery', 'Soups', 'Erbseneintopf', 'not-applicable', null, 'none', '4400108012015'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Soups', 'BioKarottenIngwerSuppe', 'not-applicable', null, 'none', '4061461879273'),
  ('DE', 'SonnenBassermann', 'Grocery', 'Soups', 'Gulaschsuppe', 'not-applicable', null, 'none', '4008585103211'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Soups', 'Asia Fond', 'not-applicable', null, 'none', '4061462114779'),
  ('DE', 'Aldi', 'Grocery', 'Soups', 'Konserve Erbseneintopf', 'not-applicable', null, 'none', '4061458010030'),
  ('DE', 'Maggi', 'Grocery', 'Soups', 'Grießklößchen Suppe', 'dried', null, 'none', '7613035151697'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Spargel Cremesuppe', 'not-applicable', null, 'none', '4037300107647'),
  ('DE', 'Edeka', 'Grocery', 'Soups', 'Hühner Nudeltopf', 'not-applicable', null, 'none', '4311501463383'),
  ('DE', 'Sonnen Bassermann', 'Grocery', 'Soups', 'Tomatencremesuppe', 'not-applicable', null, 'none', '4002473859457'),
  ('DE', 'Followfood', 'Grocery', 'Soups', 'Gemüsesuppe mit Kichererbsen', 'not-applicable', null, 'none', '4260655551241'),
  ('DE', 'EWU', 'Grocery', 'Soups', 'Soljanka', 'not-applicable', null, 'none', '4015518799007'),
  ('DE', 'Erasco', 'Grocery', 'Soups', 'Feurige Thai-Suppe', 'not-applicable', null, 'none', '4037300107586'),
  ('DE', 'Speisezeit', 'Grocery', 'Soups', 'Festtagssuppe', 'not-applicable', null, 'none', '4061458009874'),
  ('DE', 'Natur-Werk', 'Grocery', 'Soups', 'Rote Linsensuppe', 'not-applicable', null, 'none', '4023006392142')
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
where country = 'DE' and category = 'Soups'
  and is_deprecated is not true
  and product_name not in ('Bio-Gemüsebrühe', 'Hühner Nudel Topf/ Erasco', 'Grüne-Bohnen-Eintopf', 'Hühner- Nudel-Topf/ So. Bas.', 'Grüne Bohnen Eintopf Rind', 'Eintopf Frühlingstopf m. Klößen', 'Grüne Bohnen Kartoffeltopf', 'Kichererbsensuppe (mit Kokoscreme & Kreuzkümmel)', 'Gemüsefond', 'Feurige Thaisuppe mit Hühnerfleisch', 'Leberknödelsuppe', 'Hühner Reis-Topf', 'Süßkartoffelsuppe mit Ingwer und Curry', 'Knoblauch Französischer Art mit Croûtons', 'Linseneintopf mit Würstchen', 'Erasco Kartoffelsuppe m. Würstchen', 'Kichererbsen mit Quinoa & Gemüse', 'Westfälische Linsen Eintopf', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'Pekingsuppe mit Hühnerfleisch', 'Lübecker Hochzeitssuppe', 'Hühner-Nudelsuppe', 'Dose Reistopf mit Fleischklößchen', 'Erbsen-Eintopf mit Würstchen', 'Dosen Frischgemüsetopf mit Fleischklößchen', 'Hühnernudeltopf', 'Hühner Nudel-Topf', 'Kürbis Cremesuppe', 'Möhrensuppe mit Ingwer und Kokosmilch', 'Linsensuppe mit Würstchenscheiben', 'Westfälischer Linsen-Eintopf mit Essig', 'Heiße Tasse Champignon-Creme', 'Leberknödelsuppe', 'Fleisch-Bällcheneintopf mit Tomaten & Nudeln', 'Rinder Kraftbrühe', 'Hühner Suppe', 'Gemüsebrühe', 'BioGourmet Gemüsebrühe rein pflanzlich', 'Zwiebelsuppe französische Art', 'Linsensuppe mit Würstchen', 'Vegetarischer Linseneintopf', 'Erbsensuppe Hubertus', 'Vegetarischer Erbsen-Eintopf', 'Veganer Erbseneintopf', 'Bihun Suppe', 'Tomaten Suppe - toskanische Art', 'Volle Kelle', 'Gulaschsuppe', 'Bio-Kartoffelsuppe', 'Dm Bio Linseneintopf', 'Gulasch-Suppe', 'Tocană de mazăre ECO', 'Kartoffel-Cremesuppe', 'Ungarische Gulaschsuppe', 'Pfifferling Rahmsuppe', 'Thai Suppe', 'Gulaschsuppe', 'Bihun-Suppe', 'Waldpilzsuppe', 'Rote Beete Cremesuppe mit Birne', 'Bio-Brokkolisuppe', 'Čočková polévka', 'Heisse Tasse - Tomaten-Creme', 'Tomaten-Rahmsuppe', 'Erbsensuppe mit Basilikum', 'Ochsenschwanz-Suppe', 'Erasco Erbsen-Eintopf 4037300108309', 'Kürbissuppe von Little Lunch', 'Hühnerbrühe konzentriert mit Fleisch', 'Linseneintopf', 'Serbische Bohnensuppe', 'Bratensoße', '5 Minuten Terrine - Hühner-Nudeltopf', 'Tomatencreme suppe', 'Hühner Nudeltopf', 'Yummy Tummy Soup', 'Erbsen-Eintopf', 'Little Lunch Bio Little Marokko 4280000878991 Bio-Eintopf mit Gemüse und Gewürzen marokkanischer Art', 'Vegetarischer Linseneintopf', 'Eintopf Linseneintopf', 'Graupen-Topf', 'Tütensuppe', 'Minestrone', 'Klare Suppe', 'Vegetarische Gulaschsuppe', 'Ochsenschwanzsuppe', 'Erbseneintopf', 'BioKarottenIngwerSuppe', 'Gulaschsuppe', 'Asia Fond', 'Konserve Erbseneintopf', 'Grießklößchen Suppe', 'Spargel Cremesuppe', 'Hühner Nudeltopf', 'Tomatencremesuppe', 'Gemüsesuppe mit Kichererbsen', 'Soljanka', 'Feurige Thai-Suppe', 'Festtagssuppe', 'Rote Linsensuppe');
