-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Baby'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4062300020719', '4062300362215', '4061459751420', '4062300020313', '4067796017090', '4018852014959', '4062300381971', '4062300255142', '4062300257597', '4010355217103', '4018852010494', '4058172067709', '4058172010149', '4018852013969', '4058172067785', '4004176100539', '4062300406476', '4062300350403', '4018852035855', '4062300123175', '4062300266179', '4062300265967', '4018852030577', '4067796081381', '4062300265998', '4062300166738', '4062300262652', '4062300265608', '4062300266025', '4062300261303', '4062300349445', '4062300261563', '4018852030522', '4062300015920', '4018852029366', '4062300259829', '4062300255234', '4062300257689', '4062300266209', '4062300257658', '4058172031335', '4058172260223', '4058172438257', '4062300432123', '4066447398649', '4062300297104', '4062300290136', '4062300406490', '4058172437892', '4062300269842', '4018852026655', '4058172480805', '4062300347854', '4058172042591', '4058172425738', '4058172438073', '4058172438714', '4062300376182', '4062300398894', '4062300297081', '4062300429710', '4018852035343', '4062300375260', '4062300278530', '4008976091271', '4062300269811', '4062300379503', '4062300379657', '4058172438011', '4000540002560', '4062300376205', '4062300344877', '4062300289406', '4062300208254', '4018852029083', '4061461962432', '4058172843228', '4062300355439', '4058172438110', '4058172438158', '4058172795459', '4018852024958', '4062300441170', '4056631003398', '4056631002414', '4018852035763', '4018852035374', '4062300344167', '4062300342811', '4062300240995', '4018852026150', '4018852030201', '4062300021112', '4062300362277', '4062300269897', '4058172445828', '4018852028970', '4062300322851', '4056631002513', '4062300293779')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Baby by pipeline',
    ean = null
where country = 'DE'
  and category != 'Baby'
  and identity_key in ('0381125858f0e041b9693b81b54b5980', '07495268d81f2ce5f0fa915a05f6a179', '077ae9af449b093fdc9c28b466be914f', '07ca75575010bee84337df5492b13440', '0b642e273d68f93594bc16eadcf2ac3f', '119a7b05b0155dee2a4e0a82f55ed055', '1266598ab153a462fa3d4000210b7ded', '139902565c0f5b200e1f3780552c2d16', '17695a52b7294d73a6c2deffef2663d8', '1a12f3ebd63a8c61c470639229ef53a3', '1ae3e3662c46d44b4a5c82de503a2355', '1d1e498c230db7086bc028151ba7c62f', '1e7a3239a772ae47b0c3c147376a4343', '219af5a9ab82c3cfb86a17759fc4df24', '230fe70287d41abc5215076c6bdfcf2a', '2456602d8eceb0366a08219ca9283590', '2658ece7af4fb4993c3d9c5e5680dfc9', '26c216590182927e9a31c5aa3b73e002', '27e399635da74c603356819d464dfde2', '28acfd25bf2a7fb04c8f52a34df978c6', '2906d4ae5bbdc86635738f6fa3ce98b4', '2aafe8dd7f6493afa450356638356555', '2c16514c797d3485b5f6e3afcea66940', '2d71c48deeac2b8d8fb7678d54e8defd', '2fc80c23f9b79feb5114e2b776e228ad', '31b0fcfb95bf7bc03c78a63cf0838ada', '34ad41bf6187e4306283175a61297a56', '361104f011ea0014dd46685c8bc0cb2d', '38fe89f4ecffe2d677fcc148166f03f1', '3fe503cc7c5ffad270769e6abbf99f6d', '44758d57d42e4e54994c5abfba3eb55e', '44ed76bb296d4fdd90312d2d7e2dadf0', '4704f53a1a9ee67da3f0b088e171159b', '48609914e3d33bba2e401bb253be7b3e', '4b62b28b569cbd1a8e3b3049a3052a5c', '4ef53bbf21284f8968e8c6ca30e87204', '4f03cd24e25e2a3d19613a8ebf10ccd3', '524a19d6027ea25d92fdd9f07c149315', '5300e0cd7f680fe3153bb77dce44a840', '56679a26ea79a168747e88a61e5cf77a', '56f9e0db418230255cdc113b9f7e1987', '5a68fc89874586edf0392ad8b498cc4e', '5f44df91fa70b1b47826db04b25fad35', '60f4ac391ce9226cf3a7e29805b38975', '664623a25bdcead79b9317e16002f24b', '6775ff1343bddd3526092280ed382827', '68f41cd4282837e5437ddb7e6f22370c', '6af2d22077f7b79ca854dead854aef26', '6e615c17006816b3d10ae6ca4fe59da2', '7254690abe8a9a57a676e9caa6061b55', '745cf0e38acb979aa843c9824e30a81f', '74ef5c7565726b64304c41fc6c8697c0', '778e090fcf7987016e98ab498a513ad2', '79701c4c45e22c8fa58d4535cc3639bc', '7a3e5309ef0006719bb852506ff0b275', '7ff3b5264cc9ddb93f002cd40c5ab6dc', '8b82b672399ca82c118aec539a8bc5cb', '8e6b0700b2369477bb50d66de1b80afc', '92145a62a221539c465aff3143dc5846', '92755925c9f229c14f13815c3543ba0a', '96a785077eb751c389a64fa4d6e67221', '98022fd58ce6cd17693ae4b9f6254040', '9977a72ac15755c656d9a45dbf5da066', '9d6d6bb76cd0a9812325bdde11cb5b7d', '9efd329b133d5013b71ea9ea5447ea4d', 'a3a962f982c1d1dc8a0acbae0ba0467a', 'a4759aa1515fd57b3099f32a5a5dd9b2', 'a70a9d0b97d340beaa5515b8a3c9a445', 'a725d70b8a469beeac727890769e9785', 'a7d2ec06531c6b8f1c7f518b2c5bc8a3', 'a85ad862d9eaba6c30f4a708707cfa8b', 'aaea7d8f34ddf530aa6321f3dfb50d16', 'b3fdf90dd2b68a35e5389a497ee7bf85', 'b421c13f17d4e42b96bfcd48b63d2a41', 'b88b8c586e6e18d882ff8326190990f0', 'bae9da708ef0b083f8bf154559ee2727', 'bc52bb62ca2aa2c91a906bed66b202ab', 'bcfc6722f4e17a199e8f2498d0e625b6', 'c4cba4db96c3cd600aa8d0bee739b00e', 'c5083924692107450cfdde5a16981f3c', 'c561bb84ef0cc566085581661865b336', 'c995a4658733d7a65bde1cdec31084f0', 'ca061adc79e2eb961a7bd62984a313ae', 'cad67e1a41661209b402722d75adddca', 'cc2fa72f3f2f96e174cfa19c88bbe8f8', 'ce515c1b137de415391963dd3c3ef997', 'd425729ad7a9ebb8c5767e9e73d8f6ae', 'dbcd6a4f56f42c7d5e2fa6d72f578b5c', 'dcdc778b0b26c4c27dc2624e9394eaf8', 'ddf37711d5959034ee181ae0573db621', 'e1790f994895966df2d7853e7dbc78b7', 'e21cad0824db2555e15b67c712e6d8e2', 'eb15fc687377a25d8677b5ca7e8b1225', 'f576e6620a69be26b6771bf841e7ec18', 'f8cbde4f1470ea1428dd06e0cc4f67a0', 'fb723f8312472264321fa08e1c67f30f', 'fc4eca0def2ecf4cf9a2e6607b5df5bd', 'fdce40a6fe509f6d1d5f0626d295ec45', 'ffdef53564c8f4f15a43159db3766bda', 'ffe360315cb65167bbb0f889b440a9ef')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Reine Bio-Karotten mild-süßlich', 'not-applicable', null, 'none', '4062300020719'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Früchte Riegel Joghurt-Kirsch in Banane', 'not-applicable', null, 'none', '4062300362215'),
  ('DE', 'Mamia Bio', 'Grocery', 'Baby', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'not-applicable', 'Aldi', 'none', '4061459751420'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Allerlei', 'not-applicable', null, 'none', '4062300020313'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Kürbis pur', 'not-applicable', null, 'none', '4067796017090'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Mini-Makkaroni mit buntem Rahmgemüse', 'not-applicable', null, 'none', '4018852014959'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Reiner Butternut Kürbis', 'not-applicable', null, 'none', '4062300381971'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Menü Karotten, Kartoffeln, Wildlachs', 'not-applicable', null, 'none', '4062300255142'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Kürbis Nach Dem 4. Monat', 'not-applicable', null, 'none', '4062300257597'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'DM Bio Grieß Getreidebrei', 'not-applicable', null, 'none', '4010355217103'),
  ('DE', 'Bebevita', 'Grocery', 'Baby', 'Sternchennudeln in Tomaten-Kürbis-Sauce', 'not-applicable', null, 'none', '4018852010494'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Couscous Gemüsepfanne', 'not-applicable', null, 'none', '4058172067709'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Karotten mit Süßkartoffeln und Rind', 'not-applicable', null, 'none', '4058172010149'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Rahmkartoffeln mit Karotten und Hühnchen', 'not-applicable', null, 'none', '4018852013969'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Gemüse mit Süßkartoffeln und Huhn', 'not-applicable', null, 'none', '4058172067785'),
  ('DE', 'Puttkammer', 'Grocery', 'Baby', 'Schinkenröllchen in Aspik', 'not-applicable', null, 'none', '4004176100539'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Mango-Bananen-Grieß', 'not-applicable', null, 'none', '4062300406476'),
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
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Mini Pasta mit Alaska Seelachsfilet & Butter Gemüse (ab 6. Monat)', 'not-applicable', null, 'none', '4062300261563'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Gemüse-Reis mit Rind', 'not-applicable', null, 'none', '4018852030522'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Frühkarotten mit Kartoffeln & Wildlachs', 'not-applicable', null, 'none', '4062300015920'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Bebivita Abendbrei Grieß-Vanille', 'not-applicable', null, 'none', '4018852029366'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Gemüse Eintopf', 'not-applicable', null, 'none', '4062300259829'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Menü Nudel-ABC mit Bolognese Sauce', 'not-applicable', null, 'none', '4062300255234'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Buttergemüse mit Süßkartoffeln', 'not-applicable', null, 'none', '4062300257689'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Buntes Gemüse mit Süsskartoffeln und Bio-Hühnchen', 'not-applicable', null, 'none', '4062300266209'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp Mediterranes Gemüse Mit Auberginen', 'not-applicable', null, 'none', '4062300257658'),
  ('DE', 'Dm', 'Grocery', 'Baby', 'Buttergemüse mit Vollkornpasta', 'not-applicable', null, 'none', '4058172031335'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Bircher Müsli (ab 8. Monat)', 'not-applicable', null, 'none', '4058172260223'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Kürbispüree', 'not-applicable', null, 'none', '4058172438257'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hippis Pfirsich Banane Mango Joghurt', 'fermented', null, 'none', '4062300432123'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Hirse Getreidebrei', 'not-applicable', null, 'none', '4066447398649'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Pfirsich in Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4062300297104'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4062300290136'),
  ('DE', 'Unknown', 'Grocery', 'Baby', 'Apfel Bananen müesli', 'not-applicable', null, 'none', '4062300406490'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'not-applicable', null, 'none', '4058172437892'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'not-applicable', null, 'none', '4062300269842'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Anfangsmilch', 'not-applicable', 'Lidl', 'none', '4018852026655'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Dinkelnudeln mit Rahmspinat & Lachs', 'not-applicable', null, 'none', '4058172480805'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Erdbeere mit Himbeere in Apfel', 'not-applicable', null, 'none', '4062300347854'),
  ('DE', 'Babylove', 'Grocery', 'Baby', 'Aprikose in Apfel', 'not-applicable', null, 'none', '4058172042591'),
  ('DE', 'Babylove', 'Grocery', 'Baby', 'Quetschie Banane & Ananas in Apfel mit Kokosmilch', 'not-applicable', null, 'none', '4058172425738'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Apfel mit Heidelbeere (ab 5. Monat)', 'not-applicable', null, 'none', '4058172438073'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Hähnchenfleisch', 'not-applicable', null, 'none', '4058172438714'),
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
  ('DE', 'HiPP', 'Grocery', 'Baby', 'BIO Getreidebrei 5-Korn', 'not-applicable', null, 'none', '4062300344877'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'not-applicable', null, 'none', '4062300289406'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Hipp, Karotten Mit Reis Und Wildlachs', 'not-applicable', null, 'none', '4062300208254'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Pfirsich mit Maracuja in Apfel', 'not-applicable', null, 'none', '4018852029083'),
  ('DE', 'King''s crown', 'Grocery', 'Baby', 'Jalapeño-mix', 'not-applicable', null, 'none', '4061461962432'),
  ('DE', 'Babylove', 'Grocery', 'Baby', 'Erdbeere Heidelbeere in Apfel', 'not-applicable', null, 'none', '4058172843228'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Folgemilch', 'not-applicable', null, 'none', '4062300355439'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Apfel mit Banane (ab 5. Monat)', 'not-applicable', null, 'none', '4058172438110'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Mango in Apfel (ab 5. Monat)', 'not-applicable', null, 'none', '4058172438158'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Dinkelnudeln mit Rahmspinat und Lachs', 'not-applicable', null, 'none', '4058172795459'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Pflaume-Cassis in Birne-Banane', 'not-applicable', null, 'none', '4018852024958'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Pflaume in Birne (ab 5. Monat)', 'not-applicable', null, 'none', '4062300441170'),
  ('DE', 'Aptamil', 'Grocery', 'Baby', 'Aptamil Pronutra Anfangsmilch Pre 2x90ml trinkfertig', 'not-applicable', null, 'none', '4056631003398'),
  ('DE', 'Aptamil', 'Grocery', 'Baby', 'Aptamil Pronutra Anfangsmilch Pre 4x200ml trinkfertig', 'not-applicable', null, 'none', '4056631002414'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Bandnudeln mit Spinat', 'not-applicable', null, 'none', '4018852035763'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Spaghetti Bolognese', 'not-applicable', null, 'none', '4018852035374'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Grignoteur asterix', 'not-applicable', null, 'none', '4062300344167'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Hippies', 'not-applicable', null, 'none', '4062300342811'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Spaghetti mit Tomate & Mozzarella (ab 8. Monat)', 'not-applicable', null, 'none', '4062300240995'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Milchbrei Keks', 'not-applicable', null, 'none', '4018852026150'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Biscuit au lait sans sucre ajouté', 'not-applicable', null, 'none', '4018852030201'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Karotten mit Kartoffeln', 'not-applicable', null, 'none', '4062300021112'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Drachenriegel', 'not-applicable', null, 'none', '4062300362277'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Pflaume-Birne mit Vollkorn', 'not-applicable', null, 'none', '4062300269897'),
  ('DE', 'DmBio', 'Grocery', 'Baby', 'Himbeer Reiswaffeln', 'not-applicable', null, 'none', '4058172445828'),
  ('DE', 'Bebivita', 'Grocery', 'Baby', 'Mango in Apfel', 'not-applicable', null, 'none', '4018852028970'),
  ('DE', 'Hipp', 'Grocery', 'Baby', 'Erdbeerschlitz', 'not-applicable', null, 'none', '4062300322851'),
  ('DE', 'Milupa', 'Grocery', 'Baby', 'Milupa milupino kindermilch 200ml', 'not-applicable', null, 'none', '4056631002513'),
  ('DE', 'HiPP', 'Grocery', 'Baby', 'Mango-Banane in Apfel', 'not-applicable', null, 'none', '4062300293779')
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
  and product_name not in ('Reine Bio-Karotten mild-süßlich', 'Früchte Riegel Joghurt-Kirsch in Banane', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'Gemüse Allerlei', 'Kürbis pur', 'Mini-Makkaroni mit buntem Rahmgemüse', 'Reiner Butternut Kürbis', 'Menü Karotten, Kartoffeln, Wildlachs', 'Gemüse Kürbis Nach Dem 4. Monat', 'DM Bio Grieß Getreidebrei', 'Sternchennudeln in Tomaten-Kürbis-Sauce', 'Couscous Gemüsepfanne', 'Karotten mit Süßkartoffeln und Rind', 'Rahmkartoffeln mit Karotten und Hühnchen', 'Gemüse mit Süßkartoffeln und Huhn', 'Schinkenröllchen in Aspik', 'Mango-Bananen-Grieß', 'Spinatgemüse in Kartoffeln', 'Abendbrei Grieß-Vanille', 'Grießbrei', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 'Gemüse Lasagne', 'Gemüse-Spätzle-Pfanne', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 'Erdbeere in Apfel-Joghurt-Müsli', 'Gartengemüse Mit Pute Und Rosmarin', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 'Mini Pasta mit Alaska Seelachsfilet & Butter Gemüse (ab 6. Monat)', 'Gemüse-Reis mit Rind', 'Frühkarotten mit Kartoffeln & Wildlachs', 'Bebivita Abendbrei Grieß-Vanille', 'Gemüse Eintopf', 'Menü Nudel-ABC mit Bolognese Sauce', 'Buttergemüse mit Süßkartoffeln', 'Buntes Gemüse mit Süsskartoffeln und Bio-Hühnchen', 'Hipp Mediterranes Gemüse Mit Auberginen', 'Buttergemüse mit Vollkornpasta', 'Bircher Müsli (ab 8. Monat)', 'Kürbispüree', 'Hippis Pfirsich Banane Mango Joghurt', 'Hirse Getreidebrei', 'Pfirsich in Apfel (ab 5. Monat)', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'Apfel Bananen müesli', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'Anfangsmilch', 'Dinkelnudeln mit Rahmspinat & Lachs', 'Erdbeere mit Himbeere in Apfel', 'Aprikose in Apfel', 'Quetschie Banane & Ananas in Apfel mit Kokosmilch', 'Apfel mit Heidelbeere (ab 5. Monat)', 'Hähnchenfleisch', 'Himbeer Reiswaffeln', 'Bio Combiotik Pre', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 'Urkorn Dinos', 'Reis mit Karotten und Pute', 'Hipp', 'Hippis Apfel-Birne-Banane', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 'Apfel Banane in Babykeks', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 'Hipp Guten Morgen', 'Babyobst', 'Schmelzflocken 5 korn 6. Monat', 'Heidelbeer reiswaffeln', 'BIO Getreidebrei 5-Korn', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'Hipp, Karotten Mit Reis Und Wildlachs', 'Pfirsich mit Maracuja in Apfel', 'Jalapeño-mix', 'Erdbeere Heidelbeere in Apfel', 'Folgemilch', 'Apfel mit Banane (ab 5. Monat)', 'Mango in Apfel (ab 5. Monat)', 'Dinkelnudeln mit Rahmspinat und Lachs', 'Pflaume-Cassis in Birne-Banane', 'Pflaume in Birne (ab 5. Monat)', 'Aptamil Pronutra Anfangsmilch Pre 2x90ml trinkfertig', 'Aptamil Pronutra Anfangsmilch Pre 4x200ml trinkfertig', 'Bandnudeln mit Spinat', 'Spaghetti Bolognese', 'Grignoteur asterix', 'Hippies', 'Spaghetti mit Tomate & Mozzarella (ab 8. Monat)', 'Milchbrei Keks', 'Biscuit au lait sans sucre ajouté', 'Karotten mit Kartoffeln', 'Drachenriegel', 'Pflaume-Birne mit Vollkorn', 'Himbeer Reiswaffeln', 'Mango in Apfel', 'Erdbeerschlitz', 'Milupa milupino kindermilch 200ml', 'Mango-Banane in Apfel');
