-- PIPELINE (Pasta & Rice): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Pasta & Rice'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900049006375', '5901398077115', '5900049005521', '5900354036906', '5900049001714', '5900252000603', '5908217001436', '5904215115540', '5900049823026', '5903077000834', '5900049823033', '5904358551793', '5900354038474', '5900354039822', '5900049003022', '5900049823040', '5906940003703', '5900143010346', '5901752700406', '5901841000097', '5906750251592', '5901885567198', '5904215155652', '5905392000049', '5908217001177', '5901882188815', '5904072400537', '5901367001172', '5901367001240', '5906720572580', '5900049011829', '5900354037934', '5902898827101', '5900049812730', '5902898827095', '5904215149415', '5900354036920', '5906940001945', '5906940001969', '5900252000610', '5904215123729', '5901619992388', '5900354038221', '5900252000467', '5904215110064', '5904215133896', '5906940003000', '5906940003062', '5900049011300', '5902020572022', '5900049001523', '5907544131892', '5900049816585', '5900049001516', '5903077000292', '5901619933602', '5900049823125', '5900049818923', '5903890433130', '5900049816561', '5903077004931', '5900049003107', '5904741001508', '5900049003329', '5901752702820', '5906940007039', '5900049003497', '20234010', '5901367000311', '5905530500158', '5901801581079', '5904960066517', '5901619990674', '5901619973677', '5901619939192', '5905118002807', '5905784356129', '5905644030169', '5908235060743', '5900049823064', '5905299000623', '3560071015152', '5903077000841', '9062300130833', '5900049011546', '5903890433079', '5908259954028', '8001665725941', '4056489881445', '5905118052468', '8076800105056', '8076802085738', '20639792', '20351939', '4056489185550', '20981129', '20143084', '3856020223083', '5201193204021', '20063757')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Pasta & Rice by pipeline',
    ean = null
where country = 'PL'
  and category != 'Pasta & Rice'
  and identity_key in ('044bffe2b3c1f8e837949fe54e0e51fa', '04825ebacce210f941f795f26ef2ca54', '080b7e7e35eb819c4f86ce488a3b8120', '091dbc95d5c7df3a65822498d31268a8', '0d5b60f491b6bb754cb23407a6c7913e', '0e88b20f79e0da65187ea09b0a48cf41', '138dd5fdc7dbdf88fe7ce4725de69d53', '17c174236bb69d07e44b67abaea98a96', '1921e691fe587f9f2da7843ec2f96287', '1a70c5a6feb59fecdc62dd5dd862d07c', '233de99663893ee61a20c872184c5a4a', '2386920dd6fdba57a207ed545580042c', '3728e51eda4c1493912ba513a2a8e37b', '3af7467e0aa155b316fce30f1dff0518', '3c870b0eea0a4b58aa15c30ffc4510c4', '3fc6f63a85853c0934bb43d755e916df', '42c0981cbdb06e2f72054aea75a16aa8', '43158984d530cb6df76dc7711539adf8', '4727c818b779a00ef79a850382265a8d', '49426a1bb8a85908c4810c74fea80011', '5180ecdbceeba6efc963c5b6745984fe', '54abfd66898aa44131473b670a58a6dd', '5752f09f3e1583cc59662c90ba82e454', '582b33774aa92bd6ce2004697ce308a3', '5a39004d37dd47d5a690962187ed97cb', '5d69a196ad7f40ab17c947b70b1450d8', '5f4f15d0e5cf6458eec369747ed1ecb3', '5f602846dc6c66f82ec9d407fe7b6e49', '617ebc6939d3000f0f2cf518c45334a8', '631ca65b8c20ab06179e702ae3ac492f', '6387a2f55048660b9bf37eec6934d786', '64624da569c73cdffd84ee1725956344', '65f59a50293a25f90129aae68bc29fbd', '6710dbe0b740de9740f0d0b95038ede6', '675bf1c73855e8e6ede8def1cdadb5cb', '6954eb659f21af880c094b20254acf9a', '6958249cde452e1193f9472d2c9336d2', '69f230ed7020c3efd6d874dadedccc7a', '70e2c47245cd755e32a83e9cd113e272', '77bb6ee1a219f6478f4d17afaecea62f', '7939814e0763fee886a38ee86b229ec7', '79902f571ee4bab53f953598244d3ae7', '7cae10f2e9559f59802544caa6285f1e', '7f6591083a1d7bbcb76f7c07e5d3b924', '80eb29ad07ff131f6e10ec2021638320', '8d0f16a52eb33566d49a10ff209d80f5', '91e34d31dd5652d855e062a331070589', '9290d0fc2b2387f26f783d4d24f13211', '9412f406097d6db90cad6ed7f686f5a0', '9540b1c612e50abead9b9cfa42f0d0b8', '95c3fc5fe24b055df5a2bc4ff1ba68ac', '96f74b68a5b0690146e3e16bbb09827d', '99c2002b74ca46c0f5dcae7b92ae3448', '9c20ec5e352bf0cf674e5fbc69224674', 'a18989139614dc9f3dbbdd79777a6935', 'a39ccdd3aa10f707401b62f5fe5c0b5c', 'a57cf5bdc96b40a498476ab9f6abad3d', 'ad4d9ecd683d2fa76c80e5302ea4be51', 'ae166ba98a7b055f255a6d6dc86f849d', 'ae5d16d1de7c1f70e40665c516ea2a88', 'b53be32d51d490690f01eaa6151a8517', 'b883311888eddbc3d79b926f9b21c56e', 'b8ca52345d516db3f05610c4f34a59ca', 'b8d563ea2f91fbb1460d6cfb003e0fbf', 'b92bc64e3eb088b769778d90256211cd', 'b9b4d82a62be81af81a787d074060a02', 'b9ebf81a05998b7fdbe926e4f915b211', 'ba811d4ff56c86ea6ed1969d19431943', 'bc3f45b9e833c9c0e4b326031a5a29ad', 'be5e13f299d9f84457d1fee15d9e1b42', 'be8b52c0ccc3dff7611188d082512934', 'bf6969daf0f70fc8fcfaa64dbf28bfc5', 'c0dc5c6b09ddb459b345e4baa0cb84a8', 'c2a8990609a3e329f0216bf41624b749', 'c9d4c466a810b00b301c22101c01e200', 'cbd118859cd6d84555bb822f8fd64402', 'd1c27c718cb09a1304308e4dbc0a7186', 'd2c1dc1fc9375053f401bc849eb8cca5', 'd5a10f44ce2d4b739af8982d9d476b78', 'dbd0794af0ebd1d69a70a62298e081d4', 'dee387e790699e0624300dffb1993b78', 'e1db924715aa8f325a02f8700d2b40e0', 'e1ecbba13dfabc493d247ed15a7e3af7', 'e64f3a0779f2882f99785ceb99c9b559', 'e7f2c98700d9c0eb93bcd466cea159d3', 'ebfc5d17bcf256fbda00ce5baab5ea0e', 'ed7fb8504fd7b71c8710e1a28ffbe375', 'edb580b25851f603b36b9c155dfd236c', 'ee4828ef0f933f17ff79df4465a4d09d', 'f0e23ecfa2a9a15799c4531ad7f4ebd6', 'f3dc98a2083821f593398df3ee64e225', 'f43a3aa3a7613386b802cae2ebdf8831', 'f49d69d547d2e67da7e780a3b6562464', 'f5267cdc32c976682968669ac3b85aab', 'f8886d44bdb9b3831c6e1d2995a046a4', 'fa04c9301abae7d269991c59246324c3', 'fb279d1c1b5e4892318befce0a2a2861', 'fc0c87e705bf1ee0c1a1c28dd5a65fe1', 'fc32e1fa6d4c46477743ae8ac5cfc69e', 'ff91f00bb41ae58527d838a276d756c5')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Makaron Lubella Pióra nr 17', 'not-applicable', 'Dino', 'none', '5900049006375'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Pasta & Rice', 'Kluski śląskie', 'not-applicable', 'Biedronka', 'none', '5901398077115'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makaron pełnoziarnisty świderki', 'not-applicable', 'Biedronka', 'none', '5900049005521'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makaron Świderki', 'not-applicable', 'Biedronka', 'none', '5900354036906'),
  ('PL', 'Dobrusia', 'Grocery', 'Pasta & Rice', 'Makaron świderki', 'not-applicable', 'Biedronka', 'none', '5900049001714'),
  ('PL', 'Goliard', 'Grocery', 'Pasta & Rice', 'Makaron szlachecki jajeczny. Wstażki - Gniazda', 'not-applicable', 'Biedronka', 'none', '5900252000603'),
  ('PL', 'Maxpol', 'Grocery', 'Pasta & Rice', 'Penne rurka skośna', 'not-applicable', 'Dino', 'none', '5908217001436'),
  ('PL', 'Auchan', 'Grocery', 'Pasta & Rice', 'Makaron świderki', 'not-applicable', 'Auchan', 'none', '5904215115540'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Świderki', 'not-applicable', null, 'none', '5900049823026'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makarom pełnoziarnisty pióra', 'not-applicable', null, 'none', '5903077000834'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Nitki Cięte - filini', 'not-applicable', null, 'none', '5900049823033'),
  ('PL', 'House Of Asia', 'Grocery', 'Pasta & Rice', 'Makaron ryżowy', 'not-applicable', null, 'none', '5904358551793'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Spaghetti Pełnoziarnisty', 'not-applicable', null, 'none', '5900354038474'),
  ('PL', 'Novelle', 'Grocery', 'Pasta & Rice', 'Diabetic makaron świderki', 'not-applicable', 'Aldi', 'none', '5900354039822'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Makaron Lubella świderki nr 19', 'not-applicable', null, 'none', '5900049003022'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Łazanki', 'not-applicable', null, 'none', '5900049823040'),
  ('PL', 'Makarony premium', 'Grocery', 'Pasta & Rice', 'Makaron pełnoziarnisty', 'dried', null, 'none', '5906940003703'),
  ('PL', 'Taverna fell ancora', 'Grocery', 'Pasta & Rice', 'Ravioli z ricottą i suszonymi pomidorami', 'not-applicable', null, 'none', '5900143010346'),
  ('PL', 'Unknown', 'Grocery', 'Pasta & Rice', 'Makaron ryżowy', 'not-applicable', null, 'none', '5901752700406'),
  ('PL', 'Czaniecki', 'Grocery', 'Pasta & Rice', 'Makaron 5-jajeczny w kształcie ryżu', 'not-applicable', null, 'none', '5901841000097'),
  ('PL', 'Vitaliana', 'Grocery', 'Pasta & Rice', 'Ekologiczny makaron pełnoziarnisty świderki', 'dried', null, 'none', '5906750251592'),
  ('PL', 'Food House', 'Grocery', 'Pasta & Rice', 'Wegańskie spaghetti z sosem bolognese', 'not-applicable', null, 'none', '5901885567198'),
  ('PL', 'Auchan', 'Grocery', 'Pasta & Rice', 'Makaron pełnoziarnisty świdry z pszenicy durum', 'not-applicable', null, 'none', '5904215155652'),
  ('PL', 'Torebka plastikowa', 'Grocery', 'Pasta & Rice', 'NUDLE ser w ziołach', 'not-applicable', null, 'none', '5905392000049'),
  ('PL', 'MaxPol', 'Grocery', 'Pasta & Rice', 'Makaron rosołowy', 'not-applicable', null, 'none', '5908217001177'),
  ('PL', 'TaoTao', 'Grocery', 'Pasta & Rice', 'Makaron ryżowy wstążki', 'not-applicable', null, 'none', '5901882188815'),
  ('PL', 'Makarony Babuni', 'Grocery', 'Pasta & Rice', 'Makaron fusilli-świderek z kurkumą', 'not-applicable', null, 'none', '5904072400537'),
  ('PL', 'Sulma', 'Grocery', 'Pasta & Rice', 'Makaron Nadarzyński', 'not-applicable', null, 'none', '5901367001172'),
  ('PL', 'Sulma', 'Grocery', 'Pasta & Rice', 'Makaron Nadarzyński rurka', 'not-applicable', null, 'none', '5901367001240'),
  ('PL', 'Bezgluten', 'Grocery', 'Pasta & Rice', 'Makaron z mąka gryczaną - Penne', 'not-applicable', null, 'none', '5906720572580'),
  ('PL', 'Malma', 'Grocery', 'Pasta & Rice', 'Makaron Malma pióra nr. 14', 'not-applicable', null, 'none', '5900049011829'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makaron Cavatappi', 'not-applicable', 'Biedronka', 'none', '5900354037934'),
  ('PL', 'House of Asia', 'Grocery', 'Pasta & Rice', 'Makaron udon pszenny', 'not-applicable', 'Lidl', 'none', '5902898827101'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makaron pełnoziarnisty gotowany', 'not-applicable', null, 'none', '5900049812730'),
  ('PL', 'De Care', 'Grocery', 'Pasta & Rice', 'Ramen Noodles', 'not-applicable', 'Kaufland', 'none', '5902898827095'),
  ('PL', 'Auchan', 'Grocery', 'Pasta & Rice', 'Kluski leniwe', 'not-applicable', 'Auchan', 'none', '5904215149415'),
  ('PL', 'Makarony Polskie', 'Grocery', 'Pasta & Rice', 'Pastani Penne', 'not-applicable', 'Biedronka', 'none', '5900354036920'),
  ('PL', 'Novelle', 'Grocery', 'Pasta & Rice', 'Makaron z soczewicy czerwonej', 'not-applicable', 'Kaufland', 'none', '5906940001945'),
  ('PL', 'Novelle', 'Grocery', 'Pasta & Rice', 'Makaron z zielonego groszku', 'not-applicable', 'Kaufland', 'none', '5906940001969'),
  ('PL', 'Makaron szlachecki', 'Grocery', 'Pasta & Rice', 'Makaron wstęgi', 'not-applicable', null, 'none', '5900252000610'),
  ('PL', 'Auchan', 'Grocery', 'Pasta & Rice', 'Makaron spaghetti', 'not-applicable', 'Auchan', 'none', '5904215123729'),
  ('PL', 'Asia Style', 'Grocery', 'Pasta & Rice', 'Spaghetti Konjac', 'not-applicable', 'Biedronka', 'none', '5901619992388'),
  ('PL', 'Sorenti', 'Grocery', 'Pasta & Rice', 'Makaron spaghetti nr 79', 'not-applicable', 'Dino', 'none', '5900354038221'),
  ('PL', 'Jeronimo Martons', 'Grocery', 'Pasta & Rice', 'Makaron szlachecki', 'not-applicable', 'Biedronka', 'none', '5900252000467'),
  ('PL', 'Makarony Polskie SA', 'Grocery', 'Pasta & Rice', 'Makaron falbanki', 'not-applicable', 'Auchan', 'none', '5904215110064'),
  ('PL', 'Auchan', 'Grocery', 'Pasta & Rice', 'Makaron jajeczny krajanka', 'not-applicable', 'Auchan', 'none', '5904215133896'),
  ('PL', 'Makarony Polskie', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', 'Kaufland', 'none', '5906940003000'),
  ('PL', 'Makarony Polskie', 'Grocery', 'Pasta & Rice', 'Swiderki spirals noodle pasta', 'not-applicable', 'Kaufland', 'none', '5906940003062'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Wholegrain pasta spaghetti', 'not-applicable', null, 'none', '5900049011300'),
  ('PL', 'Czarniecki', 'Grocery', 'Pasta & Rice', 'Nitka walcowana. 5-jajeczny makaron', 'not-applicable', null, 'none', '5902020572022'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Makaron Lasagne', 'not-applicable', null, 'none', '5900049001523'),
  ('PL', 'GustoBello', 'Grocery', 'Pasta & Rice', 'Makaron z semoliny z pszenicy durum z dodatkiem sepii', 'not-applicable', null, 'none', '5907544131892'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Jajeczna 5 jaj nitki', 'not-applicable', null, 'none', '5900049816585'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Kokardki Farfalle', 'not-applicable', null, 'none', '5900049001516'),
  ('PL', 'Pastani', 'Grocery', 'Pasta & Rice', 'Makaron muszelki', 'not-applicable', null, 'none', '5903077000292'),
  ('PL', 'Asia Flavours', 'Grocery', 'Pasta & Rice', 'Massa de arroz integral', 'not-applicable', null, 'none', '5901619933602'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Kolanka ozdobne', 'not-applicable', null, 'none', '5900049823125'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', null, 'none', '5900049818923'),
  ('PL', 'Donatello', 'Grocery', 'Pasta & Rice', 'Spaghetti bolognese', 'not-applicable', null, 'none', '5903890433130'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', '5-jajeczny makaron', 'not-applicable', null, 'none', '5900049816561'),
  ('PL', 'Makarony Polskie', 'Grocery', 'Pasta & Rice', 'Makaron szlachecki', 'not-applicable', null, 'none', '5903077004931'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Makaron spaghetti', 'not-applicable', null, 'none', '5900049003107'),
  ('PL', 'Makarony kopcza', 'Grocery', 'Pasta & Rice', 'Makaron ze szpinakiem', 'not-applicable', null, 'none', '5904741001508'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Makaron muszelki nr 26', 'not-applicable', null, 'none', '5900049003329'),
  ('PL', 'House Of Asia', 'Grocery', 'Pasta & Rice', 'Makaron pszenny Mie', 'not-applicable', null, 'none', '5901752702820'),
  ('PL', 'Makarony Polskie', 'Grocery', 'Pasta & Rice', 'Makaron Staropolski', 'not-applicable', null, 'none', '5906940007039'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Gniazda nitki', 'not-applicable', null, 'none', '5900049003497'),
  ('PL', 'Tiradell', 'Grocery', 'Pasta & Rice', 'Makaron świderki', 'not-applicable', 'Lidl', 'none', '20234010'),
  ('PL', 'Sulma', 'Grocery', 'Pasta & Rice', 'Smaki z ogrodu', 'not-applicable', null, 'none', '5901367000311'),
  ('PL', 'Mlexer', 'Grocery', 'Pasta & Rice', 'Makaron rurki', 'not-applicable', null, 'none', '5905530500158'),
  ('PL', 'Asia Flavours', 'Grocery', 'Pasta & Rice', 'Makaron vermicelli', 'dried', null, 'none', '5901801581079'),
  ('PL', 'Firma Produkcyjno-Handlowa &quot;GZ Kowalczyk&quot;', 'Grocery', 'Pasta & Rice', 'Makaron Szlachecki 5-jajeczny. Krajanka', 'not-applicable', null, 'none', '5904960066517'),
  ('PL', 'Asia style', 'Grocery', 'Pasta & Rice', 'Makaron soba', 'not-applicable', null, 'none', '5901619990674'),
  ('PL', 'Unknown', 'Grocery', 'Pasta & Rice', 'Makaron Ramen', 'not-applicable', null, 'none', '5901619973677'),
  ('PL', 'Asia Style', 'Grocery', 'Pasta & Rice', 'Makaron Chow Mein', 'not-applicable', null, 'none', '5901619939192'),
  ('PL', 'Asia Style', 'Grocery', 'Pasta & Rice', 'Makaron wonton', 'not-applicable', null, 'none', '5905118002807'),
  ('PL', 'Carrefour', 'Grocery', 'Pasta & Rice', 'Fusilli - whole wheat pasta', 'not-applicable', null, 'none', '5905784356129'),
  ('PL', 'Makłowicz i synowie', 'Grocery', 'Pasta & Rice', 'Makaron z semoliny z pszenicy durum', 'not-applicable', null, 'none', '5905644030169'),
  ('PL', 'Unifood Smaki Świata', 'Grocery', 'Pasta & Rice', 'Makaron pad thai', 'not-applicable', null, 'none', '5908235060743'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Spaghetti express', 'not-applicable', null, 'none', '5900049823064'),
  ('PL', 'As-Babuni', 'Grocery', 'Pasta & Rice', 'Makaron Lasagne', 'not-applicable', null, 'none', '5905299000623'),
  ('PL', 'Carrefour', 'Grocery', 'Pasta & Rice', 'Espirales cocción rápida', 'not-applicable', 'Carrefour', 'none', '3560071015152'),
  ('PL', 'Unknown', 'Grocery', 'Pasta & Rice', 'Pastani Makaron', 'not-applicable', null, 'none', '5903077000841'),
  ('PL', 'Hipp', 'Grocery', 'Pasta & Rice', 'Spaghetti z pomidorami i mozzarellą', 'not-applicable', null, 'none', '9062300130833'),
  ('PL', 'Lubella', 'Grocery', 'Pasta & Rice', 'Wholegrain Pasta', 'not-applicable', null, 'none', '5900049011546'),
  ('PL', 'Virtu', 'Grocery', 'Pasta & Rice', 'Makaron Penne Z Kurczakiem', 'not-applicable', null, 'none', '5903890433079'),
  ('PL', 'NiroBio', 'Grocery', 'Pasta & Rice', 'Bio Makaron Orkiszowy spirelli', 'not-applicable', null, 'none', '5908259954028'),
  ('PL', 'Rana', 'Grocery', 'Pasta & Rice', 'Tortellini z ricottą i szpinakiem', 'not-applicable', null, 'none', '8001665725941'),
  ('PL', 'Vitasia', 'Grocery', 'Pasta & Rice', 'Linguine z matchą', 'not-applicable', null, 'none', '4056489881445'),
  ('PL', 'Asia style', 'Grocery', 'Pasta & Rice', 'Makaron vermicelli', 'not-applicable', null, 'none', '5905118052468'),
  ('PL', 'Barilla', 'Grocery', 'Pasta & Rice', 'Pâtes spaghetti n°5 1kg', 'not-applicable', 'Carrefour', 'none', '8076800105056'),
  ('PL', 'Barilla', 'Grocery', 'Pasta & Rice', 'Penne Rigate N°73', 'not-applicable', 'Auchan', 'none', '8076802085738'),
  ('PL', 'Tiradell', 'Grocery', 'Pasta & Rice', 'Makaron 5-jajeczny, krajanka', 'not-applicable', 'Lidl', 'none', '20639792'),
  ('PL', 'Chef select', 'Grocery', 'Pasta & Rice', 'Tortellini viande', 'not-applicable', 'Lidl', 'none', '20351939'),
  ('PL', 'Combino', 'Grocery', 'Pasta & Rice', 'Makaron Wstążka Przepiórcza', 'not-applicable', null, 'none', '4056489185550'),
  ('PL', 'Tiradell', 'Grocery', 'Pasta & Rice', 'Makaron gryczany rurki', 'not-applicable', 'Lidl', 'none', '20981129'),
  ('PL', 'Combino', 'Grocery', 'Pasta & Rice', 'Sardinen in Sonnenblumenöl mit Chili', 'not-applicable', 'Lidl', 'none', '20143084'),
  ('PL', 'Podravka', 'Grocery', 'Pasta & Rice', 'Makaron z pszenicy twardej durum', 'not-applicable', 'Auchan', 'none', '3856020223083'),
  ('PL', 'Melissa', 'Grocery', 'Pasta & Rice', 'Pasta Kids', 'not-applicable', 'Biedronka', 'none', '5201193204021'),
  ('PL', 'Combino', 'Grocery', 'Pasta & Rice', 'Spaghetti', 'not-applicable', 'Lidl', 'none', '20063757')
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
where country = 'PL' and category = 'Pasta & Rice'
  and is_deprecated is not true
  and product_name not in ('Makaron Lubella Pióra nr 17', 'Kluski śląskie', 'Makaron pełnoziarnisty świderki', 'Makaron Świderki', 'Makaron świderki', 'Makaron szlachecki jajeczny. Wstażki - Gniazda', 'Penne rurka skośna', 'Makaron świderki', 'Świderki', 'Makarom pełnoziarnisty pióra', 'Nitki Cięte - filini', 'Makaron ryżowy', 'Spaghetti Pełnoziarnisty', 'Diabetic makaron świderki', 'Makaron Lubella świderki nr 19', 'Łazanki', 'Makaron pełnoziarnisty', 'Ravioli z ricottą i suszonymi pomidorami', 'Makaron ryżowy', 'Makaron 5-jajeczny w kształcie ryżu', 'Ekologiczny makaron pełnoziarnisty świderki', 'Wegańskie spaghetti z sosem bolognese', 'Makaron pełnoziarnisty świdry z pszenicy durum', 'NUDLE ser w ziołach', 'Makaron rosołowy', 'Makaron ryżowy wstążki', 'Makaron fusilli-świderek z kurkumą', 'Makaron Nadarzyński', 'Makaron Nadarzyński rurka', 'Makaron z mąka gryczaną - Penne', 'Makaron Malma pióra nr. 14', 'Makaron Cavatappi', 'Makaron udon pszenny', 'Makaron pełnoziarnisty gotowany', 'Ramen Noodles', 'Kluski leniwe', 'Pastani Penne', 'Makaron z soczewicy czerwonej', 'Makaron z zielonego groszku', 'Makaron wstęgi', 'Makaron spaghetti', 'Spaghetti Konjac', 'Makaron spaghetti nr 79', 'Makaron szlachecki', 'Makaron falbanki', 'Makaron jajeczny krajanka', 'Spaghetti', 'Swiderki spirals noodle pasta', 'Wholegrain pasta spaghetti', 'Nitka walcowana. 5-jajeczny makaron', 'Makaron Lasagne', 'Makaron z semoliny z pszenicy durum z dodatkiem sepii', 'Jajeczna 5 jaj nitki', 'Kokardki Farfalle', 'Makaron muszelki', 'Massa de arroz integral', 'Kolanka ozdobne', 'Spaghetti', 'Spaghetti bolognese', '5-jajeczny makaron', 'Makaron szlachecki', 'Makaron spaghetti', 'Makaron ze szpinakiem', 'Makaron muszelki nr 26', 'Makaron pszenny Mie', 'Makaron Staropolski', 'Gniazda nitki', 'Makaron świderki', 'Smaki z ogrodu', 'Makaron rurki', 'Makaron vermicelli', 'Makaron Szlachecki 5-jajeczny. Krajanka', 'Makaron soba', 'Makaron Ramen', 'Makaron Chow Mein', 'Makaron wonton', 'Fusilli - whole wheat pasta', 'Makaron z semoliny z pszenicy durum', 'Makaron pad thai', 'Spaghetti express', 'Makaron Lasagne', 'Espirales cocción rápida', 'Pastani Makaron', 'Spaghetti z pomidorami i mozzarellą', 'Wholegrain Pasta', 'Makaron Penne Z Kurczakiem', 'Bio Makaron Orkiszowy spirelli', 'Tortellini z ricottą i szpinakiem', 'Linguine z matchą', 'Makaron vermicelli', 'Pâtes spaghetti n°5 1kg', 'Penne Rigate N°73', 'Makaron 5-jajeczny, krajanka', 'Tortellini viande', 'Makaron Wstążka Przepiórcza', 'Makaron gryczany rurki', 'Sardinen in Sonnenblumenöl mit Chili', 'Makaron z pszenicy twardej durum', 'Pasta Kids', 'Spaghetti');
