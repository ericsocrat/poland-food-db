-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906730621100', '5906730621148', '5903475460131', '5903895631418', '5900344000337', '5900344016697', '5906395035717', '5900344000375', '5901576050404', '5900344901832', '5900344901825', '5904215131335', '5901576058059', '5904468000228', '5901489215273', '5904215138518', '5905784347943', '5900672012606', '5904215128328', '5904215166375', '5906730621179', '5903895632491', '5900344030129', '5900344000429', '5906730601058', '5903475440133', '5903475450132', '5906395035953', '5908235955582', '5903075000126', '5900344992175', '5906730601614', '5903496036971', '5901576051616', '5901576051876', '5900344902266', '5903496036582', '5900344301090', '5903475471106', '5904215163299', '5905784346748', '5901576044724', '5900344026597', '5902353006102', '5901596471005', '5900344403664', '5902353032729', '5903475450323', '5900344009293', '5903895039009', '5900335004733', '5903895080018', '5900344901818', '5906730601850', '5902020533115', '5901529089642', '5906730621155', '5902340971444', '5900344024876', '5900344024814', '5900344024852', '5900344038118', '5904507903473', '5902353029125', '5906259705299', '5902353029132', '5903895010237', '5901489037707', '5900344901788', '20544508', '5908257108836', '5903050791537', '5907599956204', '8412604989308', '8429583014433', '2098765853199', '5908219994774', '5903246561913', '20503031', '4063367018657', '2982142001740', '2974236004614', '20691332', '5903895020045', '20411671', '5902353003248', '5903229004994', '5905118020511', '5900344901276', '4337185254635', '5901596470404', '5901576051418', '5901596050453', '5905009021870', '5906259705312', '5906259710804', '5016599010769', '5902627496004', '5905009020194', '4056489619499', '4056489813286', '4056489813262', '4056489813279', '20933692', '20145668', '20145651', '20145675', '2887038001883', '2870430001544', '4068706109607', '2842620003362', '20419073', '28029588', '2920849001410', '2932861003068', '2824454003046', '5900344018172', '5900972010111', '5902194106443', '5901576058653', '2982148001058', '4056489025115', '4056489918530', '3560071004408', '3560070422067', '3560071013493', '3560070485529', '3560070492527', '5400101015630', '8012666006960', '2864035001580', '3560071449865', '3560071357894', '4770190041980', '4056489922766', '4056489923886', '4770190379267', '8595241515281', '4770190141406', '3222473292219', '5606677101917', '0590490091904', '0906730630386')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Seafood & Fish by pipeline',
    ean = null
where country = 'PL'
  and category != 'Seafood & Fish'
  and identity_key in ('00f1335bce764820dfc34bdb7baadb85', '07517e946460ecd571fa9c179127b685', '0c31becd897bc5975880b54c7e3695f7', '0dc4f8d08cc88b483f5cbe75e45cd038', '0f7ab2cc91a861d0bcf18f4e694b1a3c', '10009200aa0543e749eaa423de25853b', '10e76c79f277a9cc993001934ea11016', '13d5241827ae346c56c24220be8dafbc', '16da352c4987686c54ca9d1de4d317d6', '17d67410278438f6e8e3e61cf58fecdb', '189a3a9357f455631d29769c9fa53350', '1b161f493618cf0d33d2a95cfb4ddb5f', '1bcdf6cb41a05aef047dc05f5e1afa62', '20eb2a9b0d6b4165a0389f19e8013b7a', '2273cafdc54454f4d5885aefc44c4c4f', '2574e30a3dc26f77c2b8a627995cc4f3', '2948df6a6c16072742b717873b0b46ea', '2aeaed158f407e727ccae802b30d347b', '2c0e88f88341dca0c29edbb05f666504', '2e3f493c76af62b57987bb768104038a', '2f42c645aaa7d4537b24d0b134f1f8c7', '3197a62463c090865349b46589aad0b7', '32a4afaab625efb1de3b3bac4ab061d6', '33c8fbe3ff596e3e97fd3c6c6dcfd347', '3664693dae3f3c7dbf020592975acd7f', '3d2730ee5151d00bd6043ad7493bd92d', '3e2c392fbf351732dc0b88deaa644068', '3f80d302e8a5061fb59db97a1cc5cfee', '4042d6df780956ebef6b21d0e0240fd0', '410049b1d8adb9da83dc256873aeb683', '4276b7da8529235c878ead8917adcdb4', '45652a1ffe28c8fc6721db1befdc4ad2', '48846d95348d4d15f6ad54ffa48183ce', '490ce93da0ef30c83573920d9fc8bb85', '493bec4843f009d9b566a7d318a63135', '493c24f70f5fb5783db03c35794e8961', '4ef08ad11ef875e5db3b62997de73803', '4fcb7d02d163e04214f93e5dab000960', '4feca80b242363e9d5cf66b3aa8dc97f', '5246495721bb4ace6166c65cfded8d67', '52b39952d1e1ee0ba1379018de6a0084', '596eaefb601e5e91e421c198b27e5b12', '59afabed35c61b61dde34930f2f1b0cc', '5ab5fe27e2229a7dbb894f66af6892e2', '5bbcd4ffa35482492483d13644312fb1', '5edac454db02024fac6d844d429f0b55', '5ef17fe7a0134a9ebb8dc134c639e902', '61d9c1edaa04d11a0c6aa9f09ac155d0', '63628c4e9cd37072fce35e8af35b2730', '664751f4943d8c7769173f522686f0a9', '67984efd4a64090b6dd46a3dad9fb515', '685462ec2487346af59a3f57bb0acc3e', '6c01dc24f430275c4e696c74a58589dd', '700702056827be2207e133d24290f287', '713b3801450af261ab84ae5caa5a7cec', '7215a0b998e854bafb70a65d6a423432', '75af9dd3d58706b2bd817b43b66cb59d', '775fa8645c2136554bedfe257ccf93b5', '777b34e99575dfb0303cd97bd337dcc1', '78ce403e87e9c8dc8834723b48476f16', '78f27f9d19bd33be904d2738446339bf', '7d60016b871f1d122e35f69e8e817803', '7e7b817131555ada6a3f7e0b9aab36d2', '802b3baebf3aa213a26719c4f0fcdd2e', '8038413b9c440c90aac73f84188bc62c', '8338565baa7318ca42a368b29aee3ebc', '841f6ca53d9675005d80ef41793a4e38', '8446a6f50cc80be1dfe765f5db216153', '867c8bbb55f14b1162d49386be170990', '88681ae3dcb4749bee62f16ef8e55c7a', '88b521225cb3da182c2daabd774f15e4', '8c45ea62d26e11e80ed65a3b90c04ae9', '8e7106baceb4c87e818f87ac6ac57e73', '90431645f14741545ba6969f74b0d388', '90e19212462f6465d6eea033a93d2613', '9100d6687d0597650cbcd0c1abf466e3', '92703cbb9f702954ab456c8ce00764f7', '941b107a1f3995a74388ef0c61ac5f22', '973ab01166eab770ca7bd03367726ad8', '9926d9e86c69abfd9024b8aaa5168c38', '9afe00b76396c5a7d5f7a3e4be32f226', '9e30861edf93c0a172ffb673744ace5a', '9e3edd79afac6a10d26c344a24a9e2db', 'a2ca32e4a6451bd84f45a28382d7821c', 'a4716c7dff779cead44142f3e63e1a5e', 'a4f44dc597c71a6d695b8fe2ce176213', 'a65d4bc9baf24f63dd4e9917b74bd141', 'a6eda8711c24846d97ec894e64db14a6', 'ab2f05e47cb1b74f27f8a35e62c84af0', 'ab4bfeac5c3da12b1f19ff6c6546c333', 'ad49009b84d61392b72ed5d5d1cb5372', 'ae3da71bdb5c1612f8413718e0fcb58a', 'aec98b6fce31f3d369b1ce49103c03f4', 'b25a2602647a54c5504a96886395c8a7', 'b295401a26cbe153d8b5d3835aeaf2d1', 'b2c02e9da5f0a835ef3b4e86984ec737', 'b7ee7ffdf9024b262b340bbbd42e9f19', 'b84cfb438ca048ef8a1a7a6475ff5893', 'b86b33de7bb27f78a211f32ce8bbacf4', 'baff9964c1d4d010833fc9effe1d999e', 'bbd49c0ec702be2fe4e73cf3e0ce1384', 'bc11bac0179d3defce4462680f0b1bb3', 'c19d5d37d35d6094da5b306b4b7710e9', 'c36d262e3ba8217ede884984aa636bd9', 'c58dba95295ff4873b0909aca5a8ab0b', 'c7c61d83be423c1a8abad77eff7460e5', 'cb4ebb8639fc57ea0f506dbc9740814e', 'cd3a53bf034686925eb2e2dfaed6eba8', 'd0f7aabb108e9467fc14f96986baf54c', 'd104874d0a830d452574975dbab8962e', 'd1f58c22e20331285a4f1ac3111239b9', 'd76427ead9b4bb7cb1144cc4edf0ad2c', 'dbf75731354d9bf3abcaee349675d589', 'dc8548b2664758199521baa24b6e5a0d', 'de90300cf73488173c365769f407b928', 'df4aa82509a5ad481858b7d06490e344', 'e0efc6e7dcc0a057b8bc7949d9458240', 'e1b1e5e0773c486ae845e028f5824fdf', 'e3b57735a163a49feda4ddf8174ae933', 'e643a821f318025711aafc79e53b2bee', 'e70f3368882769292924ef5db0c0bd14', 'e749c97c2ebee9761034401c37922416', 'e9249292ad46df756b8bf92cd9eb2003', 'ef258fa67ab3624a21a9e63cdc3563aa', 'ef3524726a8b6f88793a634f18fdb00d', 'f17744a9c99ad9ee3f57bb60a0711ac3', 'f2a3b09822db3a3abfcc7ed604a7926f', 'f4e963985615315baef8e917c76b14b8', 'f52496aa80d9670f1cbedf75af5b242b', 'f5844db865de8ac8ca04bc2dfbb24316', 'f5d5e3ed1054ebc4e94aba9a135fab3b', 'f63c58ff0b5949f861d559c04cfe4657', 'f89b51db84f5437a2d6942c9ba1f2125', 'f8a22e47d1b9fb11b5281bb7b43d8375', 'f8c7c4c795a54309f7b01b2bb26269c1', 'f8d1ecb8116980ce3b2745a572051e97', 'f919e092eb357f90ad618cedb6507190', 'f95f274348f98f4c5f01071959ebd44f', 'faf69a5096c6d633d56ed92a004e39ce', 'fb3b43bb1c7ee182e920c9d374d4c402', 'fb78261091cfd642ac0827961bb4bb1c', 'fda1f9d1b374159db1db6ed8112593a6', 'ffa7f173838bcc919dc4faaae25e0dd0')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na zimno', 'smoked', 'Biedronka', 'none', '5906730621100'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki marynowany plastry', 'marinated', 'Biedronka', 'none', '5906730621148'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'smoked', 'Biedronka', 'none', '5903475460131'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '5903895631418'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'not-applicable', 'Biedronka', 'none', '5900344000337'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w oleju a''la Matjas', 'not-applicable', 'Tesco', 'none', '5900344016697'),
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Szprot wędzony na gorąco', 'smoked', 'Auchan', 'none', '5906395035717'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki Śledzik w sosie śmietankowym', 'not-applicable', 'Biedronka', 'none', '5900344000375'),
  ('PL', 'Fischer King', 'Grocery', 'Seafood & Fish', 'Stek z łososia', 'not-applicable', 'Netto', 'none', '5901576050404'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'not-applicable', 'Biedronka', 'none', '5900344901832'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami', 'not-applicable', 'Biedronka', 'none', '5900344901825'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Łosoś Pacyficzny Dziki', 'smoked', 'Auchan', 'none', '5904215131335'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'smoked', 'Biedronka', 'none', '5901576058059'),
  ('PL', 'Komersmag', 'Grocery', 'Seafood & Fish', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'fried', 'Auchan', 'none', '5904468000228'),
  ('PL', 'Kong Oskar', 'Grocery', 'Seafood & Fish', 'Tuńczyk w kawałkach w oleju roślinnym', 'not-applicable', 'Auchan', 'none', '5901489215273'),
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'smoked', 'Auchan', 'none', '5904215138518'),
  ('PL', 'Northlantica', 'Grocery', 'Seafood & Fish', 'Śledź filet (wędzony z przyprawami)', 'smoked', 'Carrefour', 'none', '5905784347943'),
  ('PL', 'Dega', 'Grocery', 'Seafood & Fish', 'Ryba śledź po grecku', 'not-applicable', 'Lewiatan', 'none', '5900672012606'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Płaty śledziowe marynowane', 'not-applicable', 'Auchan', 'none', '5904215128328'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Łosoś Atlantycki', 'not-applicable', 'Auchan', 'none', '5904215166375'),
  ('PL', 'Mariners', 'Grocery', 'Seafood & Fish', 'Dziki Łosoś Sockeye', 'not-applicable', 'Biedronka', 'none', '5906730621179'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk Mexicans z warzywami', 'not-applicable', null, 'none', '5903895632491'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz w sosie grzybowym kurki', 'not-applicable', null, 'none', '5900344030129'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe z cebulką', 'not-applicable', null, 'none', '5900344000429'),
  ('PL', 'Suempol Pan Łosoś', 'Grocery', 'Seafood & Fish', 'Łosoś Wędzony Plastrowany', 'smoked', null, 'none', '5906730601058'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś łagodny', 'smoked', null, 'none', '5903475440133'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'smoked', null, 'none', '5903475450132'),
  ('PL', 'Pescadero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga', 'not-applicable', null, 'none', '5906395035953'),
  ('PL', 'Orka', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', null, 'none', '5908235955582'),
  ('PL', 'Homar', 'Grocery', 'Seafood & Fish', 'Filet śledziowy a''la matjas', 'not-applicable', null, 'none', '5903075000126'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'not-applicable', null, 'none', '5900344992175'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'smoked', null, 'none', '5906730601614'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Śledź filety z suszonymi pomidorami', 'not-applicable', null, 'none', '5903496036971'),
  ('PL', 'Fisher King', 'Grocery', 'Seafood & Fish', 'Pstrąg łososiowy wędzony w plastrach', 'smoked', null, 'none', '5901576051616'),
  ('PL', 'Śledzie od serca', 'Grocery', 'Seafood & Fish', 'Śledzie po żydowsku', 'not-applicable', null, 'none', '5901576051876'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz Pikantny', 'not-applicable', null, 'none', '5900344902266'),
  ('PL', 'Mirko', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe z papryką chilli', 'not-applicable', null, 'none', '5903496036582'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', 'not-applicable', null, 'none', '5900344301090'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś plastry, wędzony na zimno', 'smoked', null, 'none', '5903475471106'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno plastry', 'smoked', null, 'none', '5904215163299'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki marynowany', 'smoked', null, 'none', '5905784346748'),
  ('PL', 'Contimax', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe marynowane z cebulą', 'not-applicable', null, 'none', '5901576044724'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'not-applicable', null, 'none', '5900344026597'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Filety z makreli smażone w zalewie octowej', 'fried', null, 'none', '5902353006102'),
  ('PL', 'Baltica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', null, 'none', '5901596471005'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz w sosie śmietankowym', 'not-applicable', null, 'none', '5900344403664'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe w oleju', 'not-applicable', null, 'none', '5902353032729'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś plastry wędzony na zimno', 'smoked', null, 'none', '5903475450323'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marinated Herring in mushroom sauce', 'marinated', 'Auchan', 'none', '5900344009293'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895039009'),
  ('PL', 'SuperFish', 'Grocery', 'Seafood & Fish', 'Smoked Salmon', 'smoked', 'Kaufland', 'none', '5900335004733'),
  ('PL', 'MegaRyba', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5903895080018'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring single portion with onion', 'not-applicable', 'Biedronka', 'none', '5900344901818'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Gniazda z łososia', 'not-applicable', null, 'none', '5906730601850'),
  ('PL', 'Koryb', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', null, 'none', '5902020533115'),
  ('PL', 'Port netto', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno', 'smoked', null, 'none', '5901529089642'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco', 'smoked', null, 'none', '5906730621155'),
  ('PL', 'Vital Food', 'Grocery', 'Seafood & Fish', 'Chlorella', 'dried', 'Auchan', 'none', '5902340971444'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe wiejskie - pikantne pomidory', 'not-applicable', null, 'none', '5900344024876'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe wiejskie - klasyczna cebulka', 'not-applicable', null, 'none', '5900344024814'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe wiejskie - zioła ogrodowe', 'not-applicable', null, 'none', '5900344024852'),
  ('PL', 'Marinus', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie śmietanowym', 'not-applicable', null, 'none', '5900344038118'),
  ('PL', 'Jantar LTD', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco', 'smoked', null, 'none', '5904507903473'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Śledzik po myśliwsku', 'not-applicable', null, 'none', '5902353029125'),
  ('PL', 'Mowi', 'Grocery', 'Seafood & Fish', 'Łosoś', 'smoked', null, 'none', '5906259705299'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Śledziki na okrągło salsa', 'not-applicable', null, 'none', '5902353029132'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010237'),
  ('PL', 'King Oscar', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', null, 'none', '5901489037707'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring Snack', 'not-applicable', null, 'none', '5900344901788'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Śledzie Wiejskie', 'not-applicable', 'Lidl', 'none', '20544508'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Paluszki z fileta z dorsza', 'not-applicable', null, 'none', '5908257108836'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Sushi Nori', 'dried', null, 'none', '5903050791537'),
  ('PL', 'House Od Asia', 'Grocery', 'Seafood & Fish', 'Nori', 'not-applicable', null, 'none', '5907599956204'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Tuńczyk jednolity w sosie własnym', 'not-applicable', 'Biedronka', 'none', '8412604989308'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '8429583014433'),
  ('PL', 'Well done', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', 'Stokrotka', 'none', '2098765853199'),
  ('PL', 'House of Asia', 'Grocery', 'Seafood & Fish', 'Wakame', 'dried', null, 'none', '5908219994774'),
  ('PL', 'Purella', 'Grocery', 'Seafood & Fish', 'Chlorella detoks', 'dried', null, 'none', '5903246561913'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', 'not-applicable', 'Biedronka', 'none', '20503031'),
  ('PL', 'K-Classic', 'Grocery', 'Seafood & Fish', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'smoked', 'Kaufland', 'none', '4063367018657'),
  ('PL', 'Biedronka', 'Grocery', 'Seafood & Fish', 'Filet z makreli wędzony z posypką', 'smoked', 'Biedronka', 'none', '2982142001740'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Świeży pstrąg tęczowy łososiowy filet', 'not-applicable', 'Biedronka', 'none', '2974236004614'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Opiekane filety śledziowe w zalewie octowej', 'not-applicable', 'Lidl', 'none', '20691332'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Thon', 'not-applicable', null, 'none', '5903895020045'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie śmietanowym', 'not-applicable', 'Lidl', 'none', '20411671'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Ryba po grecku', 'not-applicable', null, 'none', '5902353003248'),
  ('PL', 'Targroch', 'Grocery', 'Seafood & Fish', 'Agar-Agar proszek', 'not-applicable', null, 'none', '5903229004994'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Dried wakame', 'dried', null, 'none', '5905118020511'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring rolls with onion in rapeseed oil', 'not-applicable', null, 'none', '5900344901276'),
  ('PL', 'K classic', 'Grocery', 'Seafood & Fish', 'Filety Śledziowe w sosie koperkowym', 'not-applicable', 'Kaufland', 'none', '4337185254635'),
  ('PL', 'Baltica', 'Grocery', 'Seafood & Fish', 'Filety z makreli w oleju', 'not-applicable', null, 'none', '5901596470404'),
  ('PL', 'CONNOISSEUR seafood collection', 'Grocery', 'Seafood & Fish', 'Filetti di salmone al naturale', 'not-applicable', null, 'none', '5901576051418'),
  ('PL', 'BMC', 'Grocery', 'Seafood & Fish', 'Szprot popularny w sosie pomidorowym', 'not-applicable', null, 'none', '5901596050453'),
  ('PL', 'Ocean Catch', 'Grocery', 'Seafood & Fish', 'Fish fingers', 'not-applicable', null, 'none', '5905009021870'),
  ('PL', 'Mowi', 'Grocery', 'Seafood & Fish', 'Saumon Atlantique - 6 Tranches', 'smoked', null, 'none', '5906259705312'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Salmone Norvegese Affumicato', 'smoked', null, 'none', '5906259710804'),
  ('PL', 'Princes', 'Grocery', 'Seafood & Fish', 'Tuńczyk Jednolity', 'not-applicable', 'Kaufland', 'none', '5016599010769'),
  ('PL', 'Grand frais', 'Grocery', 'Seafood & Fish', 'Saumon', 'not-applicable', null, 'none', '5902627496004'),
  ('PL', 'FRoSTA', 'Grocery', 'Seafood & Fish', 'Salmon steaks', 'not-applicable', null, 'none', '5905009020194'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Łosoś plastry', 'smoked', null, 'none', '4056489619499'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki Śledziowe Po Kaszubsku', 'not-applicable', null, 'none', '4056489813286'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe po giżycku', 'not-applicable', null, 'none', '4056489813262'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe w oleju', 'not-applicable', null, 'none', '4056489813279'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe wiejskie', 'not-applicable', null, 'none', '20933692'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z żurawiną i brzoskwinią', 'not-applicable', null, 'none', '20145668'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z kolorowym piperzem', 'not-applicable', null, 'none', '20145651'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z suszonymi pomidorami', 'not-applicable', null, 'none', '20145675'),
  ('PL', 'Fjord', 'Grocery', 'Seafood & Fish', 'Łosoś Pieczony', 'roasted', null, 'none', '2887038001883'),
  ('PL', 'SuperFish', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki pieczony', 'roasted', null, 'none', '2870430001544'),
  ('PL', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Filety Z Tuńczyka W Oleju Słonecznikowym', 'not-applicable', null, 'none', '4068706109607'),
  ('PL', 'Blue bay', 'Grocery', 'Seafood & Fish', 'Łosoś Norweski', 'not-applicable', null, 'none', '2842620003362'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie koperkowym', 'not-applicable', null, 'none', '20419073'),
  ('PL', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Filet z tuńczyka w sosie własnym', 'not-applicable', null, 'none', '28029588'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga tęczowego wędzonego na gorąco', 'smoked', null, 'none', '2920849001410'),
  ('PL', 'Biedronka', 'Grocery', 'Seafood & Fish', 'Łosos pacyficzny filet ze skórą', 'not-applicable', null, 'none', '2932861003068'),
  ('PL', 'Targ rybny Lidla', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki filet ze skórą', 'not-applicable', 'Lidl', 'none', '2824454003046'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring', 'not-applicable', null, 'none', '5900344018172'),
  ('PL', 'Frosta', 'Grocery', 'Seafood & Fish', 'Salmon Fillets', 'not-applicable', null, 'none', '5900972010111'),
  ('PL', 'Myfood', 'Grocery', 'Seafood & Fish', 'Krewetki koktajlowe gotowane obrane glazurowane', 'not-applicable', null, 'none', '5902194106443'),
  ('PL', 'Kaufland classik', 'Grocery', 'Seafood & Fish', 'Makrelenfilets geräuchert Pfeffer', 'not-applicable', null, 'none', '5901576058653'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Makrela wędzona', 'smoked', null, 'none', '2982148001058'),
  ('PL', 'Ocean sea', 'Grocery', 'Seafood & Fish', 'Paluszki surimi', 'not-applicable', 'Lidl', 'none', '4056489025115'),
  ('PL', 'Vitasia', 'Grocery', 'Seafood & Fish', 'Wakame seaweed dried sprinkles', 'dried', 'Lidl', 'none', '4056489918530'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', '16 Grosses croquettes de poisson', 'fried', 'Carrefour', 'none', '3560071004408'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Queues de crevettes CRUES', 'not-applicable', 'Carrefour', 'none', '3560070422067'),
  ('PL', 'Simplo', 'Grocery', 'Seafood & Fish', 'Crevettes sauvages décortiquées cuites', 'not-applicable', 'Carrefour', 'none', '3560071013493'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Filets DE MERLU BLANC', 'not-applicable', 'Carrefour', 'none', '3560070485529'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Bâtonnets de Poissons PANÉS', 'not-applicable', 'Carrefour', 'none', '3560070492527'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Filets de CABILLAUD', 'not-applicable', 'Carrefour', 'none', '5400101015630'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Tonno a pinne gialle al naturale', 'not-applicable', 'Carrefour', 'none', '8012666006960'),
  ('PL', 'Fjørd fiskursson', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony brzuszki', 'smoked', null, 'none', '2864035001580'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Thon albacore Au naturel', 'not-applicable', 'Carrefour', 'none', '3560071449865'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Filets de sardines', 'not-applicable', 'Carrefour', 'none', '3560071357894'),
  ('PL', 'Vici', 'Grocery', 'Seafood & Fish', 'Classic surimi sticks', 'not-applicable', null, 'none', '4770190041980'),
  ('PL', 'Ocean Sea', 'Grocery', 'Seafood & Fish', 'Steki Rybne W Panierce', 'not-applicable', null, 'none', '4056489922766'),
  ('PL', 'Ocean Sea', 'Grocery', 'Seafood & Fish', 'Paluszki Rybne z Mintaja', 'not-applicable', null, 'none', '4056489923886'),
  ('PL', 'Vičiunai', 'Grocery', 'Seafood & Fish', 'Surimi nūj.Viči Snow crab 250g', 'not-applicable', null, 'none', '4770190379267'),
  ('PL', 'Gaston', 'Grocery', 'Seafood & Fish', 'Tuňák steak v pikantním oleji', 'not-applicable', null, 'none', '8595241515281'),
  ('PL', 'Viči', 'Grocery', 'Seafood & Fish', 'Surimi sticks', 'not-applicable', null, 'none', '4770190141406'),
  ('PL', 'Casino', 'Grocery', 'Seafood & Fish', 'Noix de Saint Jacques avec corail', 'not-applicable', null, 'none', '3222473292219'),
  ('PL', 'Minerva', 'Grocery', 'Seafood & Fish', 'Minerva', 'not-applicable', null, 'none', '5606677101917'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Thon.', 'not-applicable', 'Auchan', 'none', '0590490091904'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Salmon hotdogs', 'not-applicable', null, 'none', '0906730630386')
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
where country = 'PL' and category = 'Seafood & Fish'
  and is_deprecated is not true
  and product_name not in ('Łosoś wędzony na zimno', 'Łosoś atlantycki marynowany plastry', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'Tuńczyk kawałki w sosie własnym', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'Filety śledziowe w oleju a''la Matjas', 'Szprot wędzony na gorąco', 'Szybki Śledzik w sosie śmietankowym', 'Stek z łososia', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'Śledzik na raz z suszonymi pomidorami', 'Łosoś Pacyficzny Dziki', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'Tuńczyk w kawałkach w oleju roślinnym', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'Śledź filet (wędzony z przyprawami)', 'Ryba śledź po grecku', 'Płaty śledziowe marynowane', 'Łosoś Atlantycki', 'Dziki Łosoś Sockeye', 'Tuńczyk Mexicans z warzywami', 'Śledzik na raz w sosie grzybowym kurki', 'Wiejskie filety śledziowe z cebulką', 'Łosoś Wędzony Plastrowany', 'Łosoś łagodny', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'Filety z pstrąga', 'Filety śledziowe w sosie pomidorowym', 'Filet śledziowy a''la matjas', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'Śledź filety z suszonymi pomidorami', 'Pstrąg łososiowy wędzony w plastrach', 'Śledzie po żydowsku', 'Śledzik na raz Pikantny', 'Koreczki śledziowe z papryką chilli', 'Filety śledziowe a''la Matjas', 'Łosoś plastry, wędzony na zimno', 'Łosoś atlantycki wędzony na zimno plastry', 'Łosoś atlantycki marynowany', 'Wiejskie filety śledziowe marynowane z cebulą', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'Filety z makreli smażone w zalewie octowej', 'Filety śledziowe w sosie pomidorowym', 'Śledzik na raz w sosie śmietankowym', 'Koreczki śledziowe w oleju', 'Łosoś plastry wędzony na zimno', 'Marinated Herring in mushroom sauce', 'Filety z makreli w sosie pomidorowym', 'Smoked Salmon', 'Szprot w sosie pomidorowym', 'Herring single portion with onion', 'Gniazda z łososia', 'Łosoś atlantycki', 'Łosoś atlantycki wędzony na zimno', 'Łosoś wędzony na gorąco', 'Chlorella', 'Filety śledziowe wiejskie - pikantne pomidory', 'Filety śledziowe wiejskie - klasyczna cebulka', 'Filety śledziowe wiejskie - zioła ogrodowe', 'Filety śledziowe w sosie śmietanowym', 'Łosoś wędzony na gorąco', 'Śledzik po myśliwsku', 'Łosoś', 'Śledziki na okrągło salsa', 'Filety z makreli w sosie pomidorowym', 'Filety z makreli w sosie pomidorowym', 'Herring Snack', 'Śledzie Wiejskie', 'Paluszki z fileta z dorsza', 'Sushi Nori', 'Nori', 'Tuńczyk jednolity w sosie własnym', 'Tuńczyk kawałki w sosie własnym', 'Łosoś atlantycki', 'Wakame', 'Chlorella detoks', 'Filety śledziowe a''la Matjas', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'Filet z makreli wędzony z posypką', 'Świeży pstrąg tęczowy łososiowy filet', 'Opiekane filety śledziowe w zalewie octowej', 'Thon', 'Filety śledziowe w sosie śmietanowym', 'Ryba po grecku', 'Agar-Agar proszek', 'Dried wakame', 'Herring rolls with onion in rapeseed oil', 'Filety Śledziowe w sosie koperkowym', 'Filety z makreli w oleju', 'Filetti di salmone al naturale', 'Szprot popularny w sosie pomidorowym', 'Fish fingers', 'Saumon Atlantique - 6 Tranches', 'Salmone Norvegese Affumicato', 'Tuńczyk Jednolity', 'Saumon', 'Salmon steaks', 'Łosoś plastry', 'Koreczki Śledziowe Po Kaszubsku', 'Koreczki śledziowe po giżycku', 'Koreczki śledziowe w oleju', 'Filety śledziowe wiejskie', 'Krajanka śledziowa z żurawiną i brzoskwinią', 'Krajanka śledziowa z kolorowym piperzem', 'Krajanka śledziowa z suszonymi pomidorami', 'Łosoś Pieczony', 'Łosoś atlantycki pieczony', 'Filety Z Tuńczyka W Oleju Słonecznikowym', 'Łosoś Norweski', 'Filety śledziowe w sosie koperkowym', 'Filet z tuńczyka w sosie własnym', 'Filety z pstrąga tęczowego wędzonego na gorąco', 'Łosos pacyficzny filet ze skórą', 'Łosoś atlantycki filet ze skórą', 'Herring', 'Salmon Fillets', 'Krewetki koktajlowe gotowane obrane glazurowane', 'Makrelenfilets geräuchert Pfeffer', 'Makrela wędzona', 'Paluszki surimi', 'Wakame seaweed dried sprinkles', '16 Grosses croquettes de poisson', 'Queues de crevettes CRUES', 'Crevettes sauvages décortiquées cuites', 'Filets DE MERLU BLANC', 'Bâtonnets de Poissons PANÉS', 'Filets de CABILLAUD', 'Tonno a pinne gialle al naturale', 'Łosoś wędzony brzuszki', 'Thon albacore Au naturel', 'Filets de sardines', 'Classic surimi sticks', 'Steki Rybne W Panierce', 'Paluszki Rybne z Mintaja', 'Surimi nūj.Viči Snow crab 250g', 'Tuňák steak v pikantním oleji', 'Surimi sticks', 'Noix de Saint Jacques avec corail', 'Minerva', 'Thon.', 'Salmon hotdogs');
