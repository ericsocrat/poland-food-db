-- PIPELINE (Pasta & Rice): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Pasta & Rice'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4075600055039', '4008366009961', '4061458102711', '4067796002508', '4001163135734', '4061458151214', '4061458240031', '4075600055145', '4061458018784', '4061458068499', '4061458018340', '4000398254159', '4001163110922', '4061458151221', '4061462037887', '4005500330318', '4001163000506', '4008366017317', '4056489497714', '4008366002580', '4008401620052', '4075600113470', '4001163000599', '4067796096347', '4056489291060', '4013159604575', '4061458036672', '4061458036702', '4061458102728', '4013159604599', '4056489483489', '4061463990884', '4066447122688', '4056489133049', '4061459618587', '4056489127284', '4056489376194', '4061459270303', '4056489484202', '4061458003841', '4061458036689', '4058172516030', '4056489009191', '4056489290681', '4061461867669', '4061463689177', '4061458018777', '4001163134218', '4061458057868', '4058172388651', '4061458057851', '4058172848742', '4013159604551', '4056489305590', '4061459618600', '4061458049009', '4008366008858', '4061462648359', '4061458003834', '4063367147999', '4061458102704', '4056489291053', '4023900545385', '4067796064834', '4075600135984', '4056489707523', '4061463812124', '4009337902083', '4013423910104', '4023900545361', '4058172516016', '4018077006159', '4002966004074', '4013200880088', '4013200880019', '4023900545101', '4002359018633', '4061459301854', '4006040150510', '4022381014106', '4311501641477', '4337256672887', '4056489639220', '4104420250192', '4260122510405', '8076802085981', '8076809512268', '8076809523738', '20995744', '20995751', '8076800195019', '8076809529457', '4250241206778', '4311596410644', '4260651480019', '4337256561563', '4337256299572', '4337256675017', '8001665727471', '4337256672092')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Pasta & Rice by pipeline',
    ean = null
where country = 'DE'
  and category != 'Pasta & Rice'
  and identity_key in ('01416f12e9f9dba3c024ce91e67be4a2', '05abffb32c01f4997e2fbd27afa02a13', '139ac193b833879aa4d8b30624d237cd', '17568247b44f8c0625f1536fa325d17d', '18da0b464e22550a5e66653a42405cb5', '197849f780fca13f9d3df46ea59053ce', '1d07ed637d5444a81259bdc130df55d4', '1defe5d5c7bf81c43cda3ceb3c8c3ea3', '222e94485858c56e743e838e3c820108', '24e0c2ac4371c8068ed6ee0cab29ac41', '259b9ce2841d7d071aaab8bec598fec9', '27a53e69b6c5f29d3205031258bb1849', '2a19f6f81fcd14c692e23388accb2c02', '2d9b23e538ae44010ba5549e6728f557', '2fdd0678d26cf5ec493dbdae6fea958b', '31aac87d73fab488286a3b575825c72b', '322dcc3d49c631b1892966e74c1afe32', '33ee11ac7ca97e98c08dd61523711c3f', '36993546d1cfcbbb2c6ddde34f21935d', '36dc7346b026b70c79ac4cd91b4c3a97', '3a141f0af80fff95cc864bf3c1f83528', '3a457b57bee97058e6d9a44561b156d3', '3bc1e291113b9dc1ae52cd720fd17c0f', '475c23c2cd25eea2604f4ad33d37438a', '50ed1048e12f4bc14c1e4ee9b1a3107b', '55341bb3e19aa806e6ae1f38a6aeaad1', '567ec98ade76d364461f256b3c1607ea', '5c53e28e9f83ec841e4364cbec26ffdf', '5fabc8ef683a759b2059f9362a94f02b', '616182f60f3dd471f1118bb869eac4be', '63d99e421ac78bc5ce44af49ae626f86', '654333142bd33e1025ba240f9b762ab8', '66c47b83c597a04d374b483daaadcda3', '6f3251f7b8a4b3f14e98d8851d3f5ec9', '7059eb5a41775d355263d4667492353f', '7141177e305a0672aa4baa15c161d483', '746cdd3ff0fda829c705aebe43693294', '74af102cfc213708c9eac4c5d30e36fe', '74f3c59a50e3095ee1a9a4d05046734b', '772bb089926fbe1a3178e1acf0f7db88', '77410968f0173d89c390e4b8684dbe66', '803727660a8a30eb8ac2190cf3129723', '809174083bea3c1c4975190f87cff19d', '81fbe04a6b92877cd4ff67eb0751d194', '884a4bcff2c2d5741ca56584ceae39eb', '8c17996a158163caf8dfd29bd4d6b6f1', '8c34d4b7c6525f9cc368f30b442e3ca2', '8d0919d2f01f69b975d58026502e846c', '8d5beb79d01c1a630565e81e2e6ecbcc', '8dfa4d5480327e558e457bad0118b641', '9190f4c545315cc6a1004525feca9da2', '95f0cbe20cb8ca4afb255b6ef4fd9288', '9a71cc2cc4168472aa90372d5c623f83', '9bcb3387e13442276910e1c15c4f3e6d', '9f47e6337e6039467090af757134da46', 'a7aad7f2b5c7009d6895109f0a5581f2', 'a807196c953eac9a1bc3e413152c0391', 'a87e3ed52ce6d0feba1b2b891c0125ca', 'ab7fe9e1b9c6abd01901bc311f9e7e17', 'b2e5b129158982c255ac1d0679b73857', 'b3a63c0957aea08f3e606a23437d660b', 'b8795e17e3545773ade23decb63edd86', 'b925adedf91aa135fea7d4f2b92f9e64', 'be8b5439243e9c904999f178a04c8894', 'bef59ce5851c8409abb998e25632f4be', 'c0840ece86e46d69f1e588da6086fd2c', 'c0fbb008b85b22c92f728d3eb94dfeac', 'c787324fba2de2cf312fb90f22af331d', 'c80fe150cf8bdf5d087a16a81621c6a1', 'c9b511714982d1db30cd2dcae02379e1', 'ca309b30b655ab73deb392374395d8aa', 'cc9d23d35ee894f91ba3eaff574c08f3', 'cfb87f72a17b313dfb9688ea930c7cca', 'd02f087c8addfc8692f6fea8f7793f2f', 'd03160e2f0d01514a6d34e3af1fa7fd5', 'd07f81e9a9b56616f8dbab423636da44', 'd14b53467cfbae0fbbd02bf8a889c925', 'd234930c8e27ebea92fdf47e46cc6dca', 'd27096ff876fbd92ec79707941db88db', 'd2c5aae7d067f57b1833e61ca17000ad', 'd2cf31ffa56c685ff9b0475d422ac507', 'd4096619b36698c2de5974d8e88e2de6', 'd5c35cfd8f0635bb81219491759f6f4a', 'd64ca3a75a4703c3901caa4e43a1f151', 'd7839f975911758ec03c6ec7c51c2286', 'd97baaef927da11e066744b34243f9cc', 'db3699c409b1bdc41cd5b7be3638d6e8', 'ddbed357ca61210bd03932ab716c7a19', 'e0868e5da0e84810b583e69f6ee26ef4', 'e38fae199c1d3669dc15fc6ab68904ac', 'e54986c23f90d1631f1e176ec756daa5', 'ea559d8076726ff56a0861d68547f92e', 'ee8e0ae70e66e46cad3bfc15734d135a', 'f06d7dd60f707a0a1259855b837fac1a', 'f28d88d76a593def150cdbf76e1ee433', 'f3e5ae5ec7c4e388465ad6b217d9b62b', 'f41ad8e9dd298d2debfe0070fcef03c1', 'fc9770e3775254033dffb71ee983a3a8', 'fcead31d3aa51e1249e26902edb54074', 'fd679147478a8416f6f4769978dd1530')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Bürger', 'Grocery', 'Pasta & Rice', 'Maultaschen traditionell schwäbisch', 'not-applicable', 'Lidl', 'none', '4075600055039'),
  ('DE', 'FRoSTA', 'Grocery', 'Pasta & Rice', 'Tortellini Käse-Sahne (vegetarisch)', 'not-applicable', null, 'none', '4008366009961'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Bio-Penne aus grünen Erbsen', 'not-applicable', 'Aldi', 'none', '4061458102711'),
  ('DE', 'DmBio', 'Grocery', 'Pasta & Rice', 'Gemüse Tortellini', 'not-applicable', null, 'none', '4067796002508'),
  ('DE', 'Henglein', 'Grocery', 'Pasta & Rice', 'Frischer Blätterteig', 'not-applicable', null, 'none', '4001163135734'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Frische Mezzelune - Kürbis, Salbei und Mascarpone', 'not-applicable', 'Aldi', 'none', '4061458151214'),
  ('DE', 'Landfreude', 'Grocery', 'Pasta & Rice', 'Schwäbische Eierspätzle', 'not-applicable', 'Aldi', 'none', '4061458240031'),
  ('DE', 'Bürger', 'Grocery', 'Pasta & Rice', 'Maultaschen original schwäbisch', 'not-applicable', null, 'none', '4075600055145'),
  ('DE', 'Landfreude', 'Grocery', 'Pasta & Rice', 'Spätzle', 'not-applicable', 'Aldi', 'none', '4061458018784'),
  ('DE', 'Landfreude', 'Grocery', 'Pasta & Rice', 'Spätzle / Nudeln', 'not-applicable', 'Aldi', 'none', '4061458068499'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Schwäbische Maultaschen traditionelle Art', 'not-applicable', 'Aldi', 'none', '4061458018340'),
  ('DE', 'Dorfmühle', 'Grocery', 'Pasta & Rice', 'Frischeier schwäbische Spätzle', 'not-applicable', 'Netto', 'none', '4000398254159'),
  ('DE', 'Henglein', 'Grocery', 'Pasta & Rice', 'Frische Spätzle vegan', 'not-applicable', null, 'none', '4001163110922'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Frische Ravioloni - Karamellisierte Zwiebeln und Ziegenkäse', 'not-applicable', 'Aldi', 'none', '4061458151221'),
  ('DE', 'Bio', 'Grocery', 'Pasta & Rice', 'Schwäbische Maultaschen', 'not-applicable', 'Aldi', 'none', '4061462037887'),
  ('DE', 'Nestlé', 'Grocery', 'Pasta & Rice', 'Ravioli Gemüse', 'not-applicable', null, 'none', '4005500330318'),
  ('DE', 'Henglein', 'Grocery', 'Pasta & Rice', 'Spätzle', 'not-applicable', null, 'none', '4001163000506'),
  ('DE', 'Frosta', 'Grocery', 'Pasta & Rice', 'Tagliatelle Rahm Hähnchen', 'not-applicable', null, 'none', '4008366017317'),
  ('DE', 'Chef select', 'Grocery', 'Pasta & Rice', 'Spätzle-Pfanne mit Hähnchen und Gemüse', 'not-applicable', null, 'none', '4056489497714'),
  ('DE', 'Frosta', 'Grocery', 'Pasta & Rice', 'Veggie Geschnetzeltes mit Spätzle', 'not-applicable', null, 'none', '4008366002580'),
  ('DE', 'Egle', 'Grocery', 'Pasta & Rice', 'Wiener Würste', 'not-applicable', null, 'none', '4008401620052'),
  ('DE', 'Bürger', 'Grocery', 'Pasta & Rice', 'Eierspätzle', 'not-applicable', null, 'none', '4075600113470'),
  ('DE', 'Henglein', 'Grocery', 'Pasta & Rice', 'Schupfnudeln', 'not-applicable', null, 'none', '4001163000599'),
  ('DE', 'Dm', 'Grocery', 'Pasta & Rice', 'Fussili rote Linsen', 'not-applicable', null, 'none', '4067796096347'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Nudeln Dinkel Penne', 'not-applicable', 'Lidl', 'none', '4056489291060'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Fussili', 'not-applicable', 'Lidl', 'none', '4013159604575'),
  ('DE', 'Gut Bio', 'Grocery', 'Pasta & Rice', 'Bio-Penne Vollkorn', 'not-applicable', 'Aldi', 'none', '4061458036672'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Spaghettini', 'not-applicable', 'Aldi', 'none', '4061458036702'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Bio-Strozzapreti aus roten Linsen', 'not-applicable', 'Aldi', 'none', '4061458102728'),
  ('DE', 'Cometino', 'Grocery', 'Pasta & Rice', 'Nudeln Spaghetti', 'not-applicable', 'Lidl', 'none', '4013159604599'),
  ('DE', 'Vemondo', 'Grocery', 'Pasta & Rice', 'Vegan tortelloni with meat alternative filling', 'not-applicable', 'Lidl', 'none', '4056489483489'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Wok-Nudeln - Klassik Chinanudel', 'not-applicable', 'Aldi', 'none', '4061463990884'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Vollkorn Farfalle', 'not-applicable', null, 'none', '4066447122688'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Glutenfrei Fusili', 'not-applicable', 'Lidl', 'none', '4056489133049'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Pasta & Rice', 'Udon Nudeln - Japanisch', 'not-applicable', 'Aldi', 'none', '4061459618587'),
  ('DE', 'What''s Cooking?', 'Grocery', 'Pasta & Rice', 'Bami Goreng', 'not-applicable', 'Lidl', 'none', '4056489127284'),
  ('DE', 'Vitasia', 'Grocery', 'Pasta & Rice', 'Konjac Noodles', 'not-applicable', 'Lidl', 'none', '4056489376194'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Pasta & Rice', 'Spaghetti - Dinkel', 'not-applicable', 'Aldi', 'none', '4061459270303'),
  ('DE', 'Chef Select', 'Grocery', 'Pasta & Rice', 'Feine Schlupfnudeln', 'not-applicable', 'Lidl', 'none', '4056489484202'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', 'Aldi', 'none', '4061458003841'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Bio-Fusilli', 'not-applicable', 'Aldi', 'none', '4061458036689'),
  ('DE', 'DmBio', 'Grocery', 'Pasta & Rice', 'Pasta Fusilli Rote Linsen Nudeln', 'not-applicable', null, 'none', '4058172516030'),
  ('DE', 'Baresa', 'Grocery', 'Pasta & Rice', 'Tortelloni Ricotta et épinards', 'not-applicable', 'Lidl', 'none', '4056489009191'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Rote Linsen Rollini', 'not-applicable', 'Lidl', 'none', '4056489290681'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Pasta & Rice', 'Udon-Nudeln mit Erdnusssauce', 'not-applicable', 'Aldi', 'none', '4061461867669'),
  ('DE', 'Bio', 'Grocery', 'Pasta & Rice', 'Farfalle Vollkorn', 'not-applicable', 'Aldi', 'none', '4061463689177'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Schupfnudeln', 'not-applicable', 'Aldi', 'none', '4061458018777'),
  ('DE', 'Henglein', 'Grocery', 'Pasta & Rice', 'Kartoffel-Gnocchi', 'not-applicable', null, 'none', '4001163134218'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Tortelloni Spinat-Ricotta', 'not-applicable', 'Aldi', 'none', '4061458057868'),
  ('DE', 'DmBio', 'Grocery', 'Pasta & Rice', 'Dinkel Vollkorn Locken Nudeln', 'not-applicable', null, 'none', '4058172388651'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Tortelloni - Prosciutto-Mortadella', 'not-applicable', 'Aldi', 'none', '4061458057851'),
  ('DE', 'DmBio', 'Grocery', 'Pasta & Rice', 'Gnocchi', 'not-applicable', null, 'none', '4058172848742'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Penne Rigate', 'not-applicable', 'Lidl', 'none', '4013159604551'),
  ('DE', 'Chef select', 'Grocery', 'Pasta & Rice', 'Frische Tortelloni Ricotta & Spinat', 'not-applicable', 'Lidl', 'none', '4056489305590'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Pasta & Rice', 'Soba Nudeln - Japanisch', 'not-applicable', 'Aldi', 'none', '4061459618600'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Kritharaki', 'not-applicable', 'Aldi', 'none', '4061458049009'),
  ('DE', 'FRoSTA', 'Grocery', 'Pasta & Rice', 'Pappardelle Crème Spinaci', 'not-applicable', null, 'none', '4008366008858'),
  ('DE', 'Cucina', 'Grocery', 'Pasta & Rice', 'Gnocchi - Kartoffel', 'not-applicable', null, 'none', '4061462648359'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Fusilli', 'not-applicable', null, 'none', '4061458003834'),
  ('DE', 'K Bio', 'Grocery', 'Pasta & Rice', 'Bio Fusilli, Vollkorn', 'not-applicable', null, 'none', '4063367147999'),
  ('DE', 'Aldi', 'Grocery', 'Pasta & Rice', 'Bio-Fusilli aus Kichererbsen', 'not-applicable', null, 'none', '4061458102704'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Dinkel Nudeln', 'not-applicable', null, 'none', '4056489291053'),
  ('DE', 'Bamboo Garden', 'Grocery', 'Pasta & Rice', 'Glasnudeln Breit', 'not-applicable', null, 'none', '4023900545385'),
  ('DE', 'Dm Bio', 'Grocery', 'Pasta & Rice', 'Spaghetti 100% Hartweizen', 'not-applicable', null, 'none', '4067796064834'),
  ('DE', 'Bürger', 'Grocery', 'Pasta & Rice', 'Kartoffel-Gnocchi', 'not-applicable', null, 'none', '4075600135984'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Lasagne', 'not-applicable', null, 'none', '4056489707523'),
  ('DE', 'Bio+', 'Grocery', 'Pasta & Rice', 'Nudeln Dinkellocken Vollkorn Biobio', 'not-applicable', null, 'none', '4061463812124'),
  ('DE', 'Steinhaus', 'Grocery', 'Pasta & Rice', 'Tomaten - Mozzarella - Tortelli', 'not-applicable', null, 'none', '4009337902083'),
  ('DE', 'Riesa Nudeln', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', null, 'none', '4013423910104'),
  ('DE', 'Bamboo Garden', 'Grocery', 'Pasta & Rice', 'Glasnudeln', 'not-applicable', null, 'none', '4023900545361'),
  ('DE', 'DmBio', 'Grocery', 'Pasta & Rice', 'Fusilli Kichererbsen Nudeln', 'not-applicable', null, 'none', '4058172516016'),
  ('DE', 'Lorenz', 'Grocery', 'Pasta & Rice', 'Erdnusslocken', 'not-applicable', null, 'none', '4018077006159'),
  ('DE', '3 Glocken', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', null, 'none', '4002966004074'),
  ('DE', 'Lien Ying', 'Grocery', 'Pasta & Rice', 'Noodles Uncooked', 'not-applicable', null, 'none', '4013200880088'),
  ('DE', 'Lien Ying', 'Grocery', 'Pasta & Rice', 'Reis-bandnudeln', 'not-applicable', null, 'none', '4013200880019'),
  ('DE', 'Bamboo Garden', 'Grocery', 'Pasta & Rice', 'Mie-Nudeln', 'not-applicable', null, 'none', '4023900545101'),
  ('DE', 'Mirácoli', 'Grocery', 'Pasta & Rice', 'MIRÁCOLI Klassik Spaghetti 3 Portionen', 'not-applicable', null, 'none', '4002359018633'),
  ('DE', 'Landfreunde', 'Grocery', 'Pasta & Rice', 'Bandnudeln', 'not-applicable', null, 'none', '4061459301854'),
  ('DE', 'Rapunzel', 'Grocery', 'Pasta & Rice', 'Spirelli', 'not-applicable', null, 'none', '4006040150510'),
  ('DE', 'Spielberger Mühle', 'Grocery', 'Pasta & Rice', 'Wholegrain Speltpasta', 'not-applicable', null, 'none', '4022381014106'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Pasta & Rice', 'Spätzle Pfanne', 'not-applicable', null, 'none', '4311501641477'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Pasta & Rice', 'Rindfleisch Tortelloni HERZHAFT & WÜRZIG', 'not-applicable', null, 'none', '4337256672887'),
  ('DE', 'Lidl', 'Grocery', 'Pasta & Rice', 'Tagliatelle Wildlachs', 'not-applicable', null, 'none', '4056489639220'),
  ('DE', 'Alnatura', 'Grocery', 'Pasta & Rice', 'Tortellini Gemüse semi frisch', 'not-applicable', null, 'none', '4104420250192'),
  ('DE', 'Mylos', 'Grocery', 'Pasta & Rice', 'Mylos Kritharaki 4260122510405 Griechische Teigwaren aus 100% Hartweizengrieß', 'not-applicable', null, 'none', '4260122510405'),
  ('DE', 'Barilla', 'Grocery', 'Pasta & Rice', 'Fusilli 98', 'not-applicable', 'Lidl', 'none', '8076802085981'),
  ('DE', 'Barilla', 'Grocery', 'Pasta & Rice', 'Pasta Girandole 500g Barilla', 'not-applicable', 'Lidl', 'none', '8076809512268'),
  ('DE', 'Barilla', 'Grocery', 'Pasta & Rice', 'Lasagne', 'not-applicable', 'Netto', 'none', '8076809523738'),
  ('DE', 'Combino', 'Grocery', 'Pasta & Rice', 'Spaghetti blé complet Bio', 'not-applicable', 'Lidl', 'none', '20995744'),
  ('DE', 'Lidl', 'Grocery', 'Pasta & Rice', 'Bio vollkorn penne', 'not-applicable', 'Lidl', 'none', '20995751'),
  ('DE', 'Barilla', 'Grocery', 'Pasta & Rice', 'Capellini (Spagetti) Nr. 1', 'not-applicable', 'Carrefour', 'none', '8076800195019'),
  ('DE', 'Barilla', 'Grocery', 'Pasta & Rice', 'Fusilli Integrale', 'not-applicable', null, 'none', '8076809529457'),
  ('DE', 'Iglo', 'Grocery', 'Pasta & Rice', 'Tagliatelle Pilz-Pfanne', 'not-applicable', 'Lidl', 'none', '4250241206778'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Pasta & Rice', 'Spaghetti Nudeln', 'not-applicable', null, 'none', '4311596410644'),
  ('DE', 'Just Taste', 'Grocery', 'Pasta & Rice', 'Edamame Spaghetti', 'not-applicable', null, 'none', '4260651480019'),
  ('DE', 'REWE Bio', 'Grocery', 'Pasta & Rice', 'Penne Vollkorn', 'not-applicable', null, 'none', '4337256561563'),
  ('DE', 'Rewe', 'Grocery', 'Pasta & Rice', 'Gnocci', 'not-applicable', null, 'none', '4337256299572'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Pasta & Rice', 'Gnocchi', 'not-applicable', null, 'none', '4337256675017'),
  ('DE', 'Giovanni Rana', 'Grocery', 'Pasta & Rice', 'Ravioli Ricotta und Spinat', 'not-applicable', null, 'none', '8001665727471'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Pasta & Rice', 'Spinat ricotta Tortellini', 'not-applicable', null, 'none', '4337256672092')
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
where country = 'DE' and category = 'Pasta & Rice'
  and is_deprecated is not true
  and product_name not in ('Maultaschen traditionell schwäbisch', 'Tortellini Käse-Sahne (vegetarisch)', 'Bio-Penne aus grünen Erbsen', 'Gemüse Tortellini', 'Frischer Blätterteig', 'Frische Mezzelune - Kürbis, Salbei und Mascarpone', 'Schwäbische Eierspätzle', 'Maultaschen original schwäbisch', 'Spätzle', 'Spätzle / Nudeln', 'Schwäbische Maultaschen traditionelle Art', 'Frischeier schwäbische Spätzle', 'Frische Spätzle vegan', 'Frische Ravioloni - Karamellisierte Zwiebeln und Ziegenkäse', 'Schwäbische Maultaschen', 'Ravioli Gemüse', 'Spätzle', 'Tagliatelle Rahm Hähnchen', 'Spätzle-Pfanne mit Hähnchen und Gemüse', 'Veggie Geschnetzeltes mit Spätzle', 'Wiener Würste', 'Eierspätzle', 'Schupfnudeln', 'Fussili rote Linsen', 'Nudeln Dinkel Penne', 'Fussili', 'Bio-Penne Vollkorn', 'Spaghettini', 'Bio-Strozzapreti aus roten Linsen', 'Nudeln Spaghetti', 'Vegan tortelloni with meat alternative filling', 'Wok-Nudeln - Klassik Chinanudel', 'Vollkorn Farfalle', 'Glutenfrei Fusili', 'Udon Nudeln - Japanisch', 'Bami Goreng', 'Konjac Noodles', 'Spaghetti - Dinkel', 'Feine Schlupfnudeln', 'Spaghetti', 'Bio-Fusilli', 'Pasta Fusilli Rote Linsen Nudeln', 'Tortelloni Ricotta et épinards', 'Rote Linsen Rollini', 'Udon-Nudeln mit Erdnusssauce', 'Farfalle Vollkorn', 'Schupfnudeln', 'Kartoffel-Gnocchi', 'Tortelloni Spinat-Ricotta', 'Dinkel Vollkorn Locken Nudeln', 'Tortelloni - Prosciutto-Mortadella', 'Gnocchi', 'Penne Rigate', 'Frische Tortelloni Ricotta & Spinat', 'Soba Nudeln - Japanisch', 'Kritharaki', 'Pappardelle Crème Spinaci', 'Gnocchi - Kartoffel', 'Fusilli', 'Bio Fusilli, Vollkorn', 'Bio-Fusilli aus Kichererbsen', 'Dinkel Nudeln', 'Glasnudeln Breit', 'Spaghetti 100% Hartweizen', 'Kartoffel-Gnocchi', 'Lasagne', 'Nudeln Dinkellocken Vollkorn Biobio', 'Tomaten - Mozzarella - Tortelli', 'Spaghetti', 'Glasnudeln', 'Fusilli Kichererbsen Nudeln', 'Erdnusslocken', 'Spaghetti', 'Noodles Uncooked', 'Reis-bandnudeln', 'Mie-Nudeln', 'MIRÁCOLI Klassik Spaghetti 3 Portionen', 'Bandnudeln', 'Spirelli', 'Wholegrain Speltpasta', 'Spätzle Pfanne', 'Rindfleisch Tortelloni HERZHAFT & WÜRZIG', 'Tagliatelle Wildlachs', 'Tortellini Gemüse semi frisch', 'Mylos Kritharaki 4260122510405 Griechische Teigwaren aus 100% Hartweizengrieß', 'Fusilli 98', 'Pasta Girandole 500g Barilla', 'Lasagne', 'Spaghetti blé complet Bio', 'Bio vollkorn penne', 'Capellini (Spagetti) Nr. 1', 'Fusilli Integrale', 'Tagliatelle Pilz-Pfanne', 'Spaghetti Nudeln', 'Edamame Spaghetti', 'Penne Vollkorn', 'Gnocci', 'Gnocchi', 'Ravioli Ricotta und Spinat', 'Spinat ricotta Tortellini');
