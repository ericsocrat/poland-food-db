-- PIPELINE (Ready Meals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Ready Meals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901592127463', '5901398069936', '5901398071557', '5902666647313', '5901398069981', '5900437005133', '5900437007151', '5904215140528', '5901398085127', '5908230529894', '5900437007137', '5901398079270', '5904215139034', '5904215139850', '5901398082874', '5900331207985', '5904215146087', '5900449006913', '5900962042009', '5904194906153', '5902162134232', '5902973785494', '5904194906160', '5902973785487', '5902738900094', '5907501019904', '5900397741911', '5905162002860', '5907778534445', '5900344016543', '5902166397862', '5901398082775', '5900344028676', '5900344016550', '5907222798225', '5901398070642', '5905475050114', '5905475050121', '5907778530485', '5907778535817', '5903895635089', '5907501002036', '5900344006834', '5902666643476', '5902885000128', '5907623268297', '5905475050183', '5905475050404', '5905475050596', '5905475050237', '5905475050190', '5905475050497', '5905475050503', '5905475050541', '5905475050565', '5905475050268', '5904384073078', '5908239792060', '5900962023213', '5907751477240', '5902353034372', '5900244042673', '5907468138557', '5900972008293', '5900783010416', '5900397734944', '5900919004326', '5900783004095', '5907778531796', '5901398069974', '5900741604527', '5901398069653', '5900344504231', '5907799016876', '5901398087121', '5901398071533', '5900437205137', '5900437005256', '5900437005577', '5904194910419', '5904378244323', '5904215143680', '5901398071496', '5900783009090', '5902666645616', '5900741604879', '5901398087459', '5905279712140', '5000157072023', '5900962040180', '5900437205175', '5907751159146', '4335619094826', '5905644031272', '5902166398029', '5900741600826', '5901398085462', '5907799016869', '5900962042214', '5903895010169')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Ready Meals by pipeline',
    ean = null
where country = 'PL'
  and category != 'Ready Meals'
  and identity_key in ('0294764cae9fe7cf89961e09aa47e8fb', '049cde4c8acba11f6989dfeb43f5334b', '054fc99b33266dfb89ab4570ef69daac', '08c849249918abf989bb063208acee7e', '09e9b6b69198940259b4c76ba9f9dbd5', '0cbcf93c4eae6182c192e4924f18d6f1', '0dc7a840deb575979e739819d2dd6865', '0df76eb0990e3fa3093275f98820c773', '0e45f12893b20c48681069fa4cad4deb', '124ae3ba340aec780c3c599372409f40', '1927bade660d0ceb94ab45fd6cce287e', '19ccb88116e1cefd6fa6dd8b836ee825', '1a924948aa4086fd28a4169b24cd2391', '1b17637705872793380377d882511733', '1c09db840f98fcabf61ebf9101313783', '1e95dab9b02dde8b6fd82c48380cc61d', '20033b5787af648bea64d6b6cbbde926', '20ad0ff1097a771321f3747d8f3c86f0', '20c08b63bef63fc0c0096750071368b2', '21a90f3ca86abc382be944d7ae4b8cef', '2286a40f9e98525b6e60cff553631073', '22df998b3e627815cfab90954c9b8453', '25b4b66544750108caa9a71d51f1f87f', '267efac053a0c9183e09b7c156e58b3f', '27e5d85068d01d9aead5a489fbbfc4f2', '289961a409336728a20086b9427056fb', '2af4bda91f7b86dca8bb3526e8fbb0a2', '2b5fb9471d46385b20f47490752fabaa', '36282328ed8ef7203b50600bf8746695', '37147c44493535a3f1c35d9fc9942319', '3a9e42a6ccb4fc9d1ab0a4627eee102b', '4464b94f6e4a1f1cbb01efc76c3324ec', '448f971d24feeb7c8099875f7b82fcc5', '45b3a9913255ffba97f698212a0834e2', '46ed35bb62ac3f6d4b9c2e502d260afb', '484c17cb3ed9587b87491e3a59e5b55e', '4a09e9fd4fc01c9b23949bf8988f45f2', '4b8c2ae770b5b650732609040cd8bb55', '4bef817089e497dc5351d5fe1bfb8c02', '4f15ad074952690d86adcd926ab3f383', '4f53e08b745d9a479be929cba4033a44', '4f5ede1b6b448cf239ac955ab4ceb347', '51cdb74ffa9ace1ae905909e7490d0ef', '525c65da0828c93f610c447026175030', '558adcacbea4a885a01a157d849eda27', '5670a12420a4b5873e7547aea320bfe0', '5d36823dd9a9976bd141530735de1035', '604d33173c7f74cef49bdd8ce9eb663b', '65c3e0e5eb9ca30f18f50c5853d95abc', '66da49fb7467cb48a7998e30c64de3b4', '6789ca94a2ca2adb903a8042506086dc', '6d213378f1de28db6da95b60d2e2c3b9', '6f86ea57947109771fe7b68487e402c6', '70e3777e4be8e7919bd7c0a01be46a55', '788634f58f990d950b7c9bff66d29282', '7c0f8c37b7b220e83ff36b40e42ed57c', '7e677f8d362f4adb29abd2d7ce3fb53e', '7ee50c80e51ef545bf391c018505fc63', '81cd0310608a2fad2ce690ff2258d3eb', '8571e4183c33e83eeb4a385079307a93', '8a2d79518d8512fc7a6503be7309db91', '8c0262f6d86bb2b88ff02d43e017b1dc', '8c39a40b2fde2f753eed4ba2078fa497', '8c71a2900df7b6561905699d6152b795', '94f008ced0db6cef8775bfbcadeb847e', '95f8e78d60857601da41cacb95808498', '98ab6317bd70401c5d269a6c675d3207', '9a7c93cee3ef469b9d2974bbe0e130be', '9d130b6f5c27f40a6d0b3193288cb20c', 'a65bfc216ccebab43b565b0a1f537366', 'a6c052ceb3da1a67a3cb8aa642737035', 'accf961874ae673b85bb266e6c21ec4a', 'b185f6b81bf4fc89734b8a8e9bb1100c', 'b668c198ff4ec86789bfc336d2c489da', 'be39c408edc4b7c22aa4ca8e6032549c', 'c4e53602c86355158ca89f067ca29223', 'c6f05f360b7118b6084ea598cc3bafc8', 'c76399289585d049b1e1f6408d0bf10f', 'c9f0b895991f0322a19ab57f8f0375d3', 'cb80677d333ca0734ca7a39bc799879b', 'cb9d1f188049572e75d5a2519de7b80c', 'd193db2eb1d99439f507e319404dd32b', 'd7d02b24de7d6db6bc44619dff097262', 'd9ed65b8d6ed1293595ed79d4c5410a2', 'dd754a3ad0ca9cec471b89733d7536f3', 'dda8da553c5a735efca11637ff8ea358', 'e35a29af9e449eab93c714d83b4ef264', 'e3f81b2b7d8889715a70e833287c3f7b', 'e6ad35f672625137300ff6f8fde355dc', 'e88ea2c6e345f765ba512f8c970b78fb', 'eb11446b145c07f65f1ad6351c47857a', 'ed4fa7f4ad4135b983d1b4f05f4e9c00', 'ef587ee9505c1bb9ade642644a6ac90c', 'f1d890b0c6e26a47811cf89eff0e1f8c', 'f364771b3ae43223730776e39ab6d189', 'f4899303148b869a53302e915a5c3b6b', 'f52f1f76e9dd782723405de04105ba51', 'f53aa74ef1f4f4418c1b79358bf6fc4f', 'f7a26adec504e5fd22f28540cd202cc9', 'fbe416cc8b8e6a008fe4a4b0458fb26a')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Go Active', 'Grocery', 'Ready Meals', 'Kuskus Perłowy', 'not-applicable', 'Biedronka', 'none', '5901592127463'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Pierogi z kapustą i grzybami', 'not-applicable', 'Biedronka', 'none', '5901398069936'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Krokiety z mięsem', 'not-applicable', 'Biedronka', 'none', '5901398071557'),
  ('PL', 'Vital Fresh', 'Grocery', 'Ready Meals', 'Sałatka lunchbox', 'not-applicable', 'Biedronka', 'none', '5902666647313'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Pierogi z mięsem', 'not-applicable', 'Biedronka', 'none', '5901398069981'),
  ('PL', 'Dr. Peter', 'Grocery', 'Ready Meals', 'Pizza Guseppe z szynką i pieczarkami głęboko mrożona', 'not-applicable', 'Dino', 'none', '5900437005133'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza z salami i chorizo, głęboko mrożona', 'not-applicable', null, 'none', '5900437007151'),
  ('PL', 'Auchan', 'Grocery', 'Ready Meals', 'Pierogi z Mięsem', 'not-applicable', 'Auchan', 'none', '5904215140528'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Naleśniki z serem', 'not-applicable', 'Biedronka', 'none', '5901398085127'),
  ('PL', 'Rośl-inne', 'Grocery', 'Ready Meals', 'Rośl-inne Kabanosy Piri-Piri', 'not-applicable', 'Kaufland', 'none', '5908230529894'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza 4 sery, głęboko mrożona.', 'not-applicable', 'Tesco', 'none', '5900437007137'),
  ('PL', 'Nasze smaki', 'Grocery', 'Ready Meals', 'Kotlet drobiowy z puree i marchewką z groszkiem', 'not-applicable', 'Biedronka', 'none', '5901398079270'),
  ('PL', 'Auchan', 'Grocery', 'Ready Meals', 'Surówka Colesław', 'not-applicable', 'Auchan', 'none', '5904215139034'),
  ('PL', 'Auchan', 'Grocery', 'Ready Meals', 'Pierogi ukraińskie', 'not-applicable', 'Auchan', 'none', '5904215139850'),
  ('PL', 'U Jedrusia', 'Grocery', 'Ready Meals', 'Placki Ziemniaczane z gulaszem wieprzowym po węgiersku', 'not-applicable', 'Kaufland', 'none', '5901398082874'),
  ('PL', 'Cedrob', 'Grocery', 'Ready Meals', 'Skrzydełka z kurczaka w marynacie buffalo', 'not-applicable', 'Dino', 'none', '5900331207985'),
  ('PL', 'Auchan', 'Grocery', 'Ready Meals', 'Pasta łososiowa ze szczypiorkiem', 'not-applicable', 'Auchan', 'none', '5904215146087'),
  ('PL', 'Vital Fresh', 'Grocery', 'Ready Meals', 'Surówka Smakołyk', 'not-applicable', 'Biedronka', 'none', '5900449006913'),
  ('PL', 'Asia Flavours', 'Grocery', 'Ready Meals', 'Pierożki Gyoza z warzywami', 'not-applicable', 'Biedronka', 'none', '5900962042009'),
  ('PL', 'Go Active', 'Grocery', 'Ready Meals', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'not-applicable', 'Biedronka', 'none', '5904194906153'),
  ('PL', 'Biedronka', 'Grocery', 'Ready Meals', 'Pizza z szynką wieprzową i pieczarkami', 'not-applicable', 'Biedronka', 'none', '5902162134232'),
  ('PL', 'Smacznego!', 'Grocery', 'Ready Meals', 'Sałatka bulgur z sosem pomidorowo-paprykowym', 'not-applicable', 'Biedronka', 'none', '5902973785494'),
  ('PL', 'GO Active', 'Grocery', 'Ready Meals', 'Kuskus perłowy z suszoną śliwką, mango i hummusem', 'not-applicable', 'Biedronka', 'none', '5904194906160'),
  ('PL', 'Perla', 'Grocery', 'Ready Meals', 'Sałatka bulgur', 'not-applicable', 'Biedronka', 'none', '5902973785487'),
  ('PL', 'Dega', 'Grocery', 'Ready Meals', 'Sałatka jarzynowa', 'not-applicable', 'Dino', 'none', '5902738900094'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Mięsny przysmak', 'not-applicable', 'Biedronka', 'none', '5907501019904'),
  ('PL', 'Łowicz', 'Grocery', 'Ready Meals', 'Kaszotto z kukurydzą i fasolką', 'not-applicable', 'Lewiatan', 'none', '5900397741911'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Kapusta kiszona z marchewką', 'fermented', 'Biedronka', 'none', '5905162002860'),
  ('PL', 'Grześkowiak', 'Grocery', 'Ready Meals', 'Sałatka makaronowa z brokułami i ogórkiem', 'not-applicable', 'Lewiatan', 'none', '5907778534445'),
  ('PL', 'Lisner', 'Grocery', 'Ready Meals', 'Sałatka warzywna z jajkiem', 'not-applicable', 'Biedronka', 'none', '5900344016543'),
  ('PL', 'Fit & Easy', 'Grocery', 'Ready Meals', 'Tabbouleh z mięta i pietruszką', 'not-applicable', null, 'none', '5902166397862'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Pierogi ruskie z cebulką', 'not-applicable', null, 'none', '5901398082775'),
  ('PL', 'Lisner', 'Grocery', 'Ready Meals', 'O Mamo! Sałatka warzywna z jajkiem', 'not-applicable', null, 'none', '5900344028676'),
  ('PL', 'Salato', 'Grocery', 'Ready Meals', 'Salato sałatka jarzynowa', 'not-applicable', null, 'none', '5900344016550'),
  ('PL', 'Go Active', 'Grocery', 'Ready Meals', 'Kurczak w Sosie Curry z Ryżem i Warzywami', 'not-applicable', null, 'none', '5907222798225'),
  ('PL', 'U Jędrusia', 'Grocery', 'Ready Meals', 'Racuchy z jabłkami', 'not-applicable', null, 'none', '5901398070642'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Mango - ryż na mleczku kokosowym z mango', 'not-applicable', null, 'none', '5905475050114'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Sałatka ryżowa z tuńczykiem i warzywami', 'not-applicable', null, 'none', '5905475050121'),
  ('PL', 'Grześkowiak', 'Grocery', 'Ready Meals', 'Surówka dla wegan i wegetarian ze świeżym ogórkiem', 'not-applicable', null, 'none', '5907778530485'),
  ('PL', 'Grześkowiak', 'Grocery', 'Ready Meals', 'Surówka z porem w delikatnym sosie', 'not-applicable', null, 'none', '5907778535817'),
  ('PL', 'Marinero', 'Grocery', 'Ready Meals', 'Sałatka z tuńczykiem', 'not-applicable', null, 'none', '5903895635089'),
  ('PL', 'Pamapol', 'Grocery', 'Ready Meals', 'Pulpety w sosie pomidorowym z marchewką i pietruszką', 'not-applicable', null, 'none', '5907501002036'),
  ('PL', 'Lisner', 'Grocery', 'Ready Meals', 'O Mamo! sałatka jajeczna ze szypiorkiem', 'not-applicable', null, 'none', '5900344006834'),
  ('PL', 'Vital fresh', 'Grocery', 'Ready Meals', 'Mix sałat z roszponką', 'not-applicable', null, 'none', '5902666643476'),
  ('PL', 'Jawo', 'Grocery', 'Ready Meals', 'Pierogi z mięsem', 'not-applicable', null, 'none', '5902885000128'),
  ('PL', 'Dega', 'Grocery', 'Ready Meals', 'Sałatka z jajkiem', 'not-applicable', null, 'none', '5907623268297'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Kotleciki brokułowe w sosie pieczarkowym z komosa ryżową', 'not-applicable', null, 'none', '5905475050183'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Sałatka warzywna z cukinią, jabłkiem, jajkiem, zielonym groszkiem i porem', 'not-applicable', null, 'none', '5905475050404'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Rybka - pulpeciki rybne z miruną w sosie koperkowym z ryżem basmati i fasolką szparagową', 'not-applicable', null, 'none', '5905475050596'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Pieczeń drobiowa w sosie chrzanowy z puree ziemniaczano-selerowym i burakami', 'not-applicable', null, 'none', '5905475050237'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Gulasz drobiowy w sosie piwnym z kaszą gryczana i sałatką szwedzką', 'not-applicable', null, 'none', '5905475050190'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Kurczak - makaron z kurczakiem w śmietanowym sosie z brokuła i suszonych pomidorów', 'not-applicable', null, 'none', '5905475050497'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Gołąbki bez zawijania z mięsem drobiowym w sosie pomidorowym z puree ziemniaczanym', 'not-applicable', null, 'none', '5905475050503'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Pieczeń drobiowa w sosie pomidorowo-koperkowym z puree ziemniaczano-pieczarkowym', 'not-applicable', null, 'none', '5905475050541'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Pulpeciki drobiowe w sosie koperkowym z kaszą jęczmienną i buraczkami z jabłkiem', 'not-applicable', null, 'none', '5905475050565'),
  ('PL', 'Body Chief', 'Grocery', 'Ready Meals', 'Pulpeciki - pulpety drobiowe w sosie z kiszonych ogórków z kaszą gryczana i buraczkami', 'not-applicable', null, 'none', '5905475050268'),
  ('PL', 'Smak', 'Grocery', 'Ready Meals', 'Pierogi z pieczarkami i żółtym serem', 'not-applicable', null, 'none', '5904384073078'),
  ('PL', 'Smak', 'Grocery', 'Ready Meals', 'Golabki z ryżem i mięsiem', 'not-applicable', null, 'none', '5908239792060'),
  ('PL', 'Drosed', 'Grocery', 'Ready Meals', 'Cordon Bleu z serem i szynką', 'not-applicable', null, 'none', '5900962023213'),
  ('PL', 'Ludmiła', 'Grocery', 'Ready Meals', 'Rusztyk wieprzowy z cebulką z buraczkami zasmażanymi i puree', 'not-applicable', null, 'none', '5907751477240'),
  ('PL', 'Fish & Chill', 'Grocery', 'Ready Meals', 'Ryba w sosie po hawajsku z ryżem', 'not-applicable', null, 'none', '5902353034372'),
  ('PL', 'Unknown', 'Grocery', 'Ready Meals', 'Kajzerka z szynką konserwową i pieczonym bekonem papryka konserwowa sos tysiąca wysp sałata', 'roasted', null, 'none', '5900244042673'),
  ('PL', 'Well Done', 'Grocery', 'Ready Meals', 'Krokiety z kapustą i grzybami', 'not-applicable', null, 'none', '5907468138557'),
  ('PL', 'Frosta', 'Grocery', 'Ready Meals', 'Złote Paluszki Rybne z Fileta', 'not-applicable', null, 'none', '5900972008293'),
  ('PL', 'Pudliszki', 'Grocery', 'Ready Meals', 'Wołowina w sosie grzybowym', 'not-applicable', null, 'none', '5900783010416'),
  ('PL', 'Łowicz', 'Grocery', 'Ready Meals', 'Gołąbki w sosie pomidorowym', 'not-applicable', null, 'none', '5900397734944'),
  ('PL', 'Vatan Engros As', 'Grocery', 'Ready Meals', 'Sałatka grecka', 'not-applicable', null, 'none', '5900919004326'),
  ('PL', 'Pudliszki', 'Grocery', 'Ready Meals', 'Pulpety wieprzowo-wołowe w sosie pomidorowym', 'not-applicable', null, 'none', '5900783004095'),
  ('PL', 'Grześkowiak', 'Grocery', 'Ready Meals', 'Naleśniki z serem twarogowym', 'not-applicable', null, 'none', '5907778531796'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Pierogi ruskie', 'not-applicable', 'Biedronka', 'none', '5901398069974'),
  ('PL', 'Donatello', 'Grocery', 'Ready Meals', 'Lasagne z kurczakiem', 'not-applicable', 'Biedronka', 'none', '5900741604527'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Pierogi ze szpinakiem i serem', 'not-applicable', 'Biedronka', 'none', '5901398069653'),
  ('PL', 'Lisner', 'Grocery', 'Ready Meals', 'Vegetable salad with eggs', 'not-applicable', 'Biedronka', 'none', '5900344504231'),
  ('PL', 'Yeemy', 'Grocery', 'Ready Meals', 'Italian style wrap', 'not-applicable', 'Biedronka', 'none', '5907799016876'),
  ('PL', 'Go Active', 'Grocery', 'Ready Meals', 'Kurczak z puree marchewkowym', 'not-applicable', 'Biedronka', 'none', '5901398087121'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Pierogi z serem', 'not-applicable', 'Biedronka', 'none', '5901398071533'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Guseppe z szynką i pieczarkami', 'not-applicable', null, 'none', '5900437205137'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Guseppe Chicken Curry', 'not-applicable', 'Tesco', 'none', '5900437005256'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza Giuseppe kebab', 'not-applicable', 'Dino', 'none', '5900437005577'),
  ('PL', 'Unknown', 'Grocery', 'Ready Meals', 'Salatka kuskus', 'not-applicable', 'Żabka', 'none', '5904194910419'),
  ('PL', 'Vital Fresh', 'Grocery', 'Ready Meals', 'Mix Salad Z Sałatą Lodową', 'not-applicable', null, 'none', '5904378244323'),
  ('PL', 'Auchan', 'Grocery', 'Ready Meals', 'Pierogi z serem i szpinakiem', 'not-applicable', 'Auchan', 'none', '5904215143680'),
  ('PL', 'Swojska Chata', 'Grocery', 'Ready Meals', 'Pierogi serowo- jagodowe', 'not-applicable', 'Biedronka', 'none', '5901398071496'),
  ('PL', 'Heinz', 'Grocery', 'Ready Meals', 'Heinz beanz', 'baked', null, 'none', '5900783009090'),
  ('PL', 'Vital Fresh', 'Grocery', 'Ready Meals', 'Lunchbox z makaronem i kuraczakiem', 'not-applicable', null, 'none', '5902666645616'),
  ('PL', 'Come A Casa', 'Grocery', 'Ready Meals', 'Lasagne bolognese', 'not-applicable', null, 'none', '5900741604879'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Ready Meals', 'Filet Z Kurczaka', 'not-applicable', null, 'none', '5901398087459'),
  ('PL', 'Sushi 4you', 'Grocery', 'Ready Meals', 'Sushi Toshii', 'not-applicable', null, 'none', '5905279712140'),
  ('PL', 'Heinz', 'Grocery', 'Ready Meals', '5 rodzajów fasoli w sosie pomidorowym', 'baked', 'Lidl', 'none', '5000157072023'),
  ('PL', 'Konspol', 'Grocery', 'Ready Meals', 'Zöldséges gyoza', 'not-applicable', 'Aldi', 'none', '5900962040180'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Ready Meals', 'Pizza 4 Cheese', 'not-applicable', null, 'none', '5900437205175'),
  ('PL', 'Siła Natury', 'Grocery', 'Ready Meals', 'Kapusta kiszona z Charsznicy', 'fermented', null, 'none', '5907751159146'),
  ('PL', 'Chef Select', 'Grocery', 'Ready Meals', 'Kotlet De Volatile Z Puree Ziemniaczanym I Marchewką Z Groszkiem', 'not-applicable', 'Lidl', 'none', '4335619094826'),
  ('PL', 'Makłowicz i Synowie', 'Grocery', 'Ready Meals', 'Fettuccine w sosie pomidorowym z kurczakiem', 'not-applicable', null, 'none', '5905644031272'),
  ('PL', 'Fit&Easy', 'Grocery', 'Ready Meals', 'Lunch Box Proteinowy', 'not-applicable', null, 'none', '5902166398029'),
  ('PL', 'Donatello', 'Grocery', 'Ready Meals', 'Lasagne', 'not-applicable', null, 'none', '5900741600826'),
  ('PL', 'Asia Flavours', 'Grocery', 'Ready Meals', 'Tikka Masala', 'not-applicable', null, 'none', '5901398085462'),
  ('PL', 'Yeemy', 'Grocery', 'Ready Meals', 'Greek Style Wrap', 'not-applicable', null, 'none', '5907799016869'),
  ('PL', 'Go Asia', 'Grocery', 'Ready Meals', 'Gyoza with beef', 'not-applicable', null, 'none', '5900962042214'),
  ('PL', 'Graal', 'Grocery', 'Ready Meals', 'Szprot w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010169')
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
where country = 'PL' and category = 'Ready Meals'
  and is_deprecated is not true
  and product_name not in ('Kuskus Perłowy', 'Pierogi z kapustą i grzybami', 'Krokiety z mięsem', 'Sałatka lunchbox', 'Pierogi z mięsem', 'Pizza Guseppe z szynką i pieczarkami głęboko mrożona', 'Pizza z salami i chorizo, głęboko mrożona', 'Pierogi z Mięsem', 'Naleśniki z serem', 'Rośl-inne Kabanosy Piri-Piri', 'Pizza 4 sery, głęboko mrożona.', 'Kotlet drobiowy z puree i marchewką z groszkiem', 'Surówka Colesław', 'Pierogi ukraińskie', 'Placki Ziemniaczane z gulaszem wieprzowym po węgiersku', 'Skrzydełka z kurczaka w marynacie buffalo', 'Pasta łososiowa ze szczypiorkiem', 'Surówka Smakołyk', 'Pierożki Gyoza z warzywami', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'Pizza z szynką wieprzową i pieczarkami', 'Sałatka bulgur z sosem pomidorowo-paprykowym', 'Kuskus perłowy z suszoną śliwką, mango i hummusem', 'Sałatka bulgur', 'Sałatka jarzynowa', 'Mięsny przysmak', 'Kaszotto z kukurydzą i fasolką', 'Kapusta kiszona z marchewką', 'Sałatka makaronowa z brokułami i ogórkiem', 'Sałatka warzywna z jajkiem', 'Tabbouleh z mięta i pietruszką', 'Pierogi ruskie z cebulką', 'O Mamo! Sałatka warzywna z jajkiem', 'Salato sałatka jarzynowa', 'Kurczak w Sosie Curry z Ryżem i Warzywami', 'Racuchy z jabłkami', 'Mango - ryż na mleczku kokosowym z mango', 'Sałatka ryżowa z tuńczykiem i warzywami', 'Surówka dla wegan i wegetarian ze świeżym ogórkiem', 'Surówka z porem w delikatnym sosie', 'Sałatka z tuńczykiem', 'Pulpety w sosie pomidorowym z marchewką i pietruszką', 'O Mamo! sałatka jajeczna ze szypiorkiem', 'Mix sałat z roszponką', 'Pierogi z mięsem', 'Sałatka z jajkiem', 'Kotleciki brokułowe w sosie pieczarkowym z komosa ryżową', 'Sałatka warzywna z cukinią, jabłkiem, jajkiem, zielonym groszkiem i porem', 'Rybka - pulpeciki rybne z miruną w sosie koperkowym z ryżem basmati i fasolką szparagową', 'Pieczeń drobiowa w sosie chrzanowy z puree ziemniaczano-selerowym i burakami', 'Gulasz drobiowy w sosie piwnym z kaszą gryczana i sałatką szwedzką', 'Kurczak - makaron z kurczakiem w śmietanowym sosie z brokuła i suszonych pomidorów', 'Gołąbki bez zawijania z mięsem drobiowym w sosie pomidorowym z puree ziemniaczanym', 'Pieczeń drobiowa w sosie pomidorowo-koperkowym z puree ziemniaczano-pieczarkowym', 'Pulpeciki drobiowe w sosie koperkowym z kaszą jęczmienną i buraczkami z jabłkiem', 'Pulpeciki - pulpety drobiowe w sosie z kiszonych ogórków z kaszą gryczana i buraczkami', 'Pierogi z pieczarkami i żółtym serem', 'Golabki z ryżem i mięsiem', 'Cordon Bleu z serem i szynką', 'Rusztyk wieprzowy z cebulką z buraczkami zasmażanymi i puree', 'Ryba w sosie po hawajsku z ryżem', 'Kajzerka z szynką konserwową i pieczonym bekonem papryka konserwowa sos tysiąca wysp sałata', 'Krokiety z kapustą i grzybami', 'Złote Paluszki Rybne z Fileta', 'Wołowina w sosie grzybowym', 'Gołąbki w sosie pomidorowym', 'Sałatka grecka', 'Pulpety wieprzowo-wołowe w sosie pomidorowym', 'Naleśniki z serem twarogowym', 'Pierogi ruskie', 'Lasagne z kurczakiem', 'Pierogi ze szpinakiem i serem', 'Vegetable salad with eggs', 'Italian style wrap', 'Kurczak z puree marchewkowym', 'Pierogi z serem', 'Pizza Guseppe z szynką i pieczarkami', 'Pizza Guseppe Chicken Curry', 'Pizza Giuseppe kebab', 'Salatka kuskus', 'Mix Salad Z Sałatą Lodową', 'Pierogi z serem i szpinakiem', 'Pierogi serowo- jagodowe', 'Heinz beanz', 'Lunchbox z makaronem i kuraczakiem', 'Lasagne bolognese', 'Filet Z Kurczaka', 'Sushi Toshii', '5 rodzajów fasoli w sosie pomidorowym', 'Zöldséges gyoza', 'Pizza 4 Cheese', 'Kapusta kiszona z Charsznicy', 'Kotlet De Volatile Z Puree Ziemniaczanym I Marchewką Z Groszkiem', 'Fettuccine w sosie pomidorowym z kurczakiem', 'Lunch Box Proteinowy', 'Lasagne', 'Tikka Masala', 'Greek Style Wrap', 'Gyoza with beef', 'Szprot w sosie pomidorowym');
