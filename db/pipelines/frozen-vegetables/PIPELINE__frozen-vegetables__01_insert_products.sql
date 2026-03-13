-- PIPELINE (Frozen Vegetables): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Frozen Vegetables'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900477000846', '5901581232413', '5901581232352', '5900477000853', '5901028916586', '5900972010647', '5900477014027', '5901581210176', '5901028913554', '5900477003632', '5903154549829', '5902966009002', '5901028917507', '5901028908055', '5901028918948', '5901028916616', '5903154542622', '5903154542615', '5901028917972', '5907431389788', '5901028917422', '5901028913325', '5901028913479', '5902966000337', '5901028913349', '5900477003267', '5901028915541', '5901028917378', '5900477013747', '5901028915558', '5900477000839', '5900477000754', '5907431389795', '5901028913103', '5901028913592', '5901028913387', '5901028917415', '5902162345614', '5902162345416', '5902162347618', '5901028918634', '5901028917521', '5901529083206', '5901529083244', '5903154548730', '5902162001008', '5900477017158', '5901581211173', '5901028915442', '4056489881032', '20860028', '5902162000988', '5900488002419', '5903161000146', '5900477000525', '5900477018131', '5900477019572', '5907431380549', '4056489359593', '20860011', '20113384', '5712873003389', '3083680836371', '3560070444373', '3560070552498', '8480013200291', '5051007112000', '20130596', '4056489880516', '4056489784845', '3083681060041', '3083681144109', '4056489784838', '3083681147834', '3560070444366', '20982959', '3083680014601', '3564700457320', '4056489447832')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Frozen Vegetables by pipeline',
    ean = null
where country = 'PL'
  and category != 'Frozen Vegetables'
  and identity_key in ('0121e5296c65c36059cdbdcb1861c335', '02be48f55396bddde9f7d6029b40dd4d', '039c4b676af0f997e3d714026d50d8f7', '0c76cf5e437799658828a70b34945d79', '0df73e0a8cdc3d07e64e7467e9093127', '11648ad41ad0461bed396cde2dcc75c0', '144b62ccd58017762e4fd647b27bb4ac', '1955dc9bb92d4021b37772b1f02c7fdc', '19c189939c151b135c4b773f2fae16ed', '208fe29c09133d842cce51ddf4aeb79f', '21f10e83a9ad409e0ef3a596282650d6', '22e76d665a50fdb263d4b7da43cb1113', '252169d61056fd853c3cb32bcbac9b64', '26743675aa20b3a5246ca30c65a0dc52', '27617b8989f8c1cc7135731879934671', '27c78a74eb3405b43c270d729ed1fd50', '2e8bdb35123d7c29594f06e078e55e03', '33c89f6564ae9b2b03e67335faedff31', '349896b1f96eafcb85d62dad06242310', '36a419350eb275e91f4a4c2380fc080d', '37a52a7c5ee8b3305f5ca0caccb7aac2', '3ea69051364da4e8833a543dea735257', '452009ec4559a2e10c6bf8e94ece3770', '46f09fe4bc3c40d5871b192a4e8da778', '4871f27df7071200520b6e19bbbddf95', '48e0cfde4a6b29223147355cf5c2dd42', '4957633126a632bd37e3c2f1be64a14d', '4a8ea84ad1a10c823a65d476e6c694aa', '4e57b473346168bea2cf96aff4b21801', '4e98480a6b56871ce36af466509c8288', '4fd3e6cf41f34c5a56cbc28ab286c319', '51b7508e7d7cf8b133a19a8f8a6c62a9', '5376775ff62d5105bf558d73f4eeff47', '58e07e5ccc0876131faae3adcc024718', '5992376645a60561dc57b0123b517284', '64fc63077e978669a7b34e3f3bd3a023', '6625c3394efb3c0a24ab9f8340e0b361', '67e949560c63bb1a9eea349b8f369ae5', '73ed214d089d4796012b3a299017f34d', '75a7781dc307345b058ca2a55290cd46', '7e314e34866a5a98e40b69d8f82f87f6', '884998e7c80d830f9bde7587c6252cbf', '89f899a488743af0c64daa473b3fc0e3', '8b8da7ad5d9e3802ea41b77f9bb89926', '8cd644ec3bd1c9b84541878859f0d97a', '926dfaf54c0e13d7c340ad1617955d01', '92e0761cc0851c630e309194a3c1798f', '966e2a0fba546d6b6b7384f5337022dd', '96cafe0c0ee57da518c92893b1f75e92', '9cb35877b02a25a70f126d5cdb1a5212', '9f6817b45b0569cfe5ef5754441ff303', 'a0fbd80cbbc558a136bbb543929d2fe6', 'a1daef04e88975004663491768b52edd', 'a66b41c561d365698dfc36f62ac97300', 'a6d8b49b756f93ff722d8d018b30e06d', 'ac4e8943df2ac05c231f709101b4d290', 'ada9b14c2bd3b4ab682f22202897ef7b', 'b425c37108d012aac00b1e8d12226817', 'b4926445ffa6eeaf808dc6f78ad22a9e', 'b5cfef683f0c4a2ee541daeb124f9019', 'b6a6b8150079ce80f91ed451daa446c6', 'b6f5627a51d0881749443af4ec487554', 'ba162ff23280cf1b40446bcaea0be0b2', 'bc44ea0aaf7c02f9be7903342edd2b30', 'be8e3ab32d125f3dce549d59e7360986', 'ca6d503d17817ad97209f500dc9c90bb', 'cfda3a5855c9c98b735fef17e995e998', 'd1846f09477a770ae9034f36948cc00a', 'd48d2ce53a28cc194b9d09c09733d5e4', 'd6fc55d7dd107c216be83171e208f349', 'd6fce6f6254c49cac26e137c0546fb26', 'd969c4f6525b5cf8ca0beef422251ae8', 'e91785940360fb5cfca5fcc22de082ac', 'ecdd9d481442ea3d7661f70ae03a689e', 'ef668adf168625bf2575dab9ad67bf49', 'f31278031c8d83afa3f477fe6b3fca5a', 'f53c78ab47a6ba43aae976f46f195749', 'f94e24f23d398cf009b0220f2e43dbe8', 'f9e49e6b2f9f60f4eaf231cfd6178fa4')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię', 'not-applicable', 'Kaufland', 'none', '5900477000846'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię z ziemniakami', 'not-applicable', 'Biedronka', 'none', '5901581232413'),
  ('PL', 'Morźna Kraina', 'Grocery', 'Frozen Vegetables', 'Włoszczyzna w słupkach', 'not-applicable', 'Biedronka', 'none', '5901581232352'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię z przyprawą włoską', 'fried', 'Kaufland', 'none', '5900477000853'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Szpinak w liściach, porcjowany', 'not-applicable', 'Biedronka', 'none', '5901028916586'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię letnie', 'not-applicable', 'Biedronka', 'none', '5900972010647'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię ze szpinakiem', 'not-applicable', 'Auchan', 'none', '5900477014027'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Brokuły różyczki', 'not-applicable', 'Biedronka', 'none', '5901581210176'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnie &quot;po hiszpańsku&quot;', 'not-applicable', 'Biedronka', 'none', '5901028913554'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa Na Patelnię Z Koperkiem', 'not-applicable', 'Żabka', 'none', '5900477003632'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Fasola szparagowa cięta Mroźna Kraina', 'not-applicable', 'Biedronka', 'none', '5903154549829'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Jagody leśne', 'not-applicable', 'Biedronka', 'none', '5902966009002'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Borówka', 'not-applicable', 'Biedronka', 'none', '5901028917507'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Trio warzywne z mini marchewką', 'not-applicable', null, 'none', '5901028908055'),
  ('PL', 'Asia Flavours', 'Grocery', 'Frozen Vegetables', 'Mieszanka Chińska', 'not-applicable', null, 'none', '5901028918948'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Fasolka szparagowa żółta i zielona, cała', 'not-applicable', null, 'none', '5901028916616'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po włosku', 'fried', null, 'none', '5903154542622'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po grecku', 'not-applicable', null, 'none', '5903154542615'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po europejsku', 'not-applicable', null, 'none', '5901028917972'),
  ('PL', 'Poltino', 'Grocery', 'Frozen Vegetables', 'Danie chińskie', 'not-applicable', null, 'none', '5907431389788'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Kalafior różyczki', 'not-applicable', null, 'none', '5901028917422'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po turecku', 'not-applicable', null, 'none', '5901028913325'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po meksykańsku', 'not-applicable', null, 'none', '5901028913479'),
  ('PL', 'Agram', 'Grocery', 'Frozen Vegetables', 'Szpinak liście', 'not-applicable', null, 'none', '5902966000337'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po azjatycku', 'fried', null, 'none', '5901028913349'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Szpinak liście', 'not-applicable', null, 'none', '5900477003267'),
  ('PL', 'Unknown', 'Grocery', 'Frozen Vegetables', 'Jagody leśne', 'not-applicable', null, 'none', '5901028915541'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Polskie wiśnie bez pestek', 'not-applicable', null, 'none', '5901028917378'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Maliny mrożone', 'not-applicable', null, 'none', '5900477013747'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Mieszanka wiosenna', 'not-applicable', 'Biedronka', 'none', '5901028915558'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnie', 'not-applicable', 'Auchan', 'none', '5900477000839'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Bukiet warzyw kwiatowy', 'not-applicable', 'Auchan', 'none', '5900477000754'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen Vegetables', 'Szpinak rozdrobniony porcjowany', 'not-applicable', 'Biedronka', 'none', '5907431389795'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnie z ziemniakami', 'not-applicable', 'Biedronka', 'none', '5901028913103'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnie &quot;po indyjsku&quot;', 'not-applicable', 'Biedronka', 'none', '5901028913592'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnie', 'not-applicable', 'Biedronka', 'none', '5901028913387'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Groszek zielony', 'not-applicable', 'Biedronka', 'none', '5901028917415'),
  ('PL', 'Iglote', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po włosku', 'not-applicable', null, 'none', '5902162345614'),
  ('PL', 'Iglotex', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię klasyczne', 'not-applicable', null, 'none', '5902162345416'),
  ('PL', 'Proste Historie', 'Grocery', 'Frozen Vegetables', 'Mieszanka Chińska', 'not-applicable', null, 'none', '5902162347618'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Marchew mini', 'not-applicable', 'Biedronka', 'none', '5901028918634'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Brzoskwinia', 'not-applicable', 'Biedronka', 'none', '5901028917521'),
  ('PL', 'Harvest Best', 'Grocery', 'Frozen Vegetables', 'Zupa jarzynowa', 'not-applicable', null, 'none', '5901529083206'),
  ('PL', 'Harvest Best', 'Grocery', 'Frozen Vegetables', 'Zupa kalafiorowa', 'not-applicable', null, 'none', '5901529083244'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Zupa jarzynowa', 'not-applicable', null, 'none', '5903154548730'),
  ('PL', 'Proste Historie', 'Grocery', 'Frozen Vegetables', 'Chopped spinach', 'not-applicable', null, 'none', '5902162001008'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Mieszanka Azjatycka', 'not-applicable', null, 'none', '5900477017158'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Marchewka z groszkiem', 'not-applicable', null, 'none', '5901581211173'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen Vegetables', 'Ananas', 'not-applicable', null, 'none', '5901028915442'),
  ('PL', 'Lidl', 'Grocery', 'Frozen Vegetables', 'Warzywa Na Patelnię Z Ziemniakami', 'not-applicable', null, 'none', '4056489881032'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Warzywa mrożone po hiszpańsku', 'not-applicable', null, 'none', '20860028'),
  ('PL', 'World of Taste', 'Grocery', 'Frozen Vegetables', '7 - Vegetables Mix', 'not-applicable', null, 'none', '5902162000988'),
  ('PL', 'Nordis', 'Grocery', 'Frozen Vegetables', 'Warzywa na payelnie premium', 'not-applicable', null, 'none', '5900488002419'),
  ('PL', 'Kuchnia Eksperta', 'Grocery', 'Frozen Vegetables', 'Frozen spinach', 'not-applicable', null, 'none', '5903161000146'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Stir-Fry Vegetables With Oriental Seasoning', 'not-applicable', null, 'none', '5900477000525'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Broccoli And Cauliflower Mix', 'not-applicable', null, 'none', '5900477018131'),
  ('PL', 'Hortex', 'Grocery', 'Frozen Vegetables', 'Warzywa Do Zapiekania', 'not-applicable', null, 'none', '5900477019572'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen Vegetables', 'Spinach', 'not-applicable', null, 'none', '5907431380549'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'not-applicable', 'Lidl', 'none', '4056489359593'),
  ('PL', 'Freshona Lidl', 'Grocery', 'Frozen Vegetables', 'Warzywa na patelnię po włosku', 'not-applicable', null, 'none', '20860011'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Mix zeleniny na čínský způsob', 'not-applicable', 'Lidl', 'none', '20113384'),
  ('PL', 'Harvest Best', 'Grocery', 'Frozen Vegetables', 'Wok mix', 'not-applicable', 'Netto', 'none', '5712873003389'),
  ('PL', 'Bonduelle', 'Grocery', 'Frozen Vegetables', 'Epinards Feuilles Préservées 750g', 'not-applicable', 'Carrefour', 'none', '3083680836371'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen Vegetables', 'Haricots Verts Très Fins', 'not-applicable', 'Carrefour', 'none', '3560070444373'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen Vegetables', 'CHOUX-FLEURS En fleurette', 'not-applicable', 'Carrefour', 'none', '3560070552498'),
  ('PL', 'Spar', 'Grocery', 'Frozen Vegetables', 'Guisantes finos', 'not-applicable', null, 'none', '8480013200291'),
  ('PL', 'Tesco', 'Grocery', 'Frozen Vegetables', 'Mix mražené zeleniny', 'not-applicable', 'Tesco', 'none', '5051007112000'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Berry Mix with Sour Cherries', 'not-applicable', 'Lidl', 'none', '20130596'),
  ('PL', 'Lidl', 'Grocery', 'Frozen Vegetables', 'Szpinak Rozdrobniony W Porcjach', 'not-applicable', null, 'none', '4056489880516'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Fasolka szparagowa zielona', 'not-applicable', null, 'none', '4056489784845'),
  ('PL', 'Bonduelle', 'Grocery', 'Frozen Vegetables', 'Špenátové listy', 'not-applicable', null, 'none', '3083681060041'),
  ('PL', 'Bonduelle', 'Grocery', 'Frozen Vegetables', 'Thailand Mix With Rice Frozen', 'not-applicable', null, 'none', '3083681144109'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Groszek zielony', 'not-applicable', null, 'none', '4056489784838'),
  ('PL', 'Bonduelle', 'Grocery', 'Frozen Vegetables', 'Croustis Original Brocolis 305g', 'not-applicable', null, 'none', '3083681147834'),
  ('PL', 'Unknown', 'Grocery', 'Frozen Vegetables', '10 Légumes POUR Minestrone', 'not-applicable', null, 'none', '3560070444366'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Marchew z groszkiem', 'not-applicable', null, 'none', '20982959'),
  ('PL', 'Bonduelle restauration', 'Grocery', 'Frozen Vegetables', 'Snap peas', 'not-applicable', null, 'none', '3083680014601'),
  ('PL', 'Douceur du Verger', 'Grocery', 'Frozen Vegetables', 'Framboises entières', 'not-applicable', null, 'none', '3564700457320'),
  ('PL', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Mixed vegetables Californian style', 'not-applicable', null, 'none', '4056489447832')
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
where country = 'PL' and category = 'Frozen Vegetables'
  and is_deprecated is not true
  and product_name not in ('Warzywa na patelnię', 'Warzywa na patelnię z ziemniakami', 'Włoszczyzna w słupkach', 'Warzywa na patelnię z przyprawą włoską', 'Szpinak w liściach, porcjowany', 'Warzywa na patelnię letnie', 'Warzywa na patelnię ze szpinakiem', 'Brokuły różyczki', 'Warzywa na patelnie &quot;po hiszpańsku&quot;', 'Warzywa Na Patelnię Z Koperkiem', 'Fasola szparagowa cięta Mroźna Kraina', 'Jagody leśne', 'Borówka', 'Trio warzywne z mini marchewką', 'Mieszanka Chińska', 'Fasolka szparagowa żółta i zielona, cała', 'Warzywa na patelnię po włosku', 'Warzywa na patelnię po grecku', 'Warzywa na patelnię po europejsku', 'Danie chińskie', 'Kalafior różyczki', 'Warzywa na patelnię po turecku', 'Warzywa na patelnię po meksykańsku', 'Szpinak liście', 'Warzywa na patelnię po azjatycku', 'Szpinak liście', 'Jagody leśne', 'Polskie wiśnie bez pestek', 'Maliny mrożone', 'Mieszanka wiosenna', 'Warzywa na patelnie', 'Bukiet warzyw kwiatowy', 'Szpinak rozdrobniony porcjowany', 'Warzywa na patelnie z ziemniakami', 'Warzywa na patelnie &quot;po indyjsku&quot;', 'Warzywa na patelnie', 'Groszek zielony', 'Warzywa na patelnię po włosku', 'Warzywa na patelnię klasyczne', 'Mieszanka Chińska', 'Marchew mini', 'Brzoskwinia', 'Zupa jarzynowa', 'Zupa kalafiorowa', 'Zupa jarzynowa', 'Chopped spinach', 'Mieszanka Azjatycka', 'Marchewka z groszkiem', 'Ananas', 'Warzywa Na Patelnię Z Ziemniakami', 'Warzywa mrożone po hiszpańsku', '7 - Vegetables Mix', 'Warzywa na payelnie premium', 'Frozen spinach', 'Stir-Fry Vegetables With Oriental Seasoning', 'Broccoli And Cauliflower Mix', 'Warzywa Do Zapiekania', 'Spinach', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'Warzywa na patelnię po włosku', 'Mix zeleniny na čínský způsob', 'Wok mix', 'Epinards Feuilles Préservées 750g', 'Haricots Verts Très Fins', 'CHOUX-FLEURS En fleurette', 'Guisantes finos', 'Mix mražené zeleniny', 'Berry Mix with Sour Cherries', 'Szpinak Rozdrobniony W Porcjach', 'Fasolka szparagowa zielona', 'Špenátové listy', 'Thailand Mix With Rice Frozen', 'Groszek zielony', 'Croustis Original Brocolis 305g', '10 Légumes POUR Minestrone', 'Marchew z groszkiem', 'Snap peas', 'Framboises entières', 'Mixed vegetables Californian style');
