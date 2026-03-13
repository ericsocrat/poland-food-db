-- PIPELINE (Soups): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Soups'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900397734401', '5904215135159', '5900397735200', '5901696000860', '5900397742994', '5901696000839', '5903895634822', '5907180327116', '5907180312242', '5900783004057', '5900783004743', '5903895627176', '5900783004736', '5906122901049', '5905162002297', '5900783004941', '5901002002991', '5907368740294', '5903240394067', '5903240394036', '5900919002025', '5903895637465', '5900783004897', '5902221662027', '5900852150005', '5902020710004', '5902634970009', '5900397735118', '5901002006586', '5903895631012', '5900397734838', '5902537540132', '5903726407076', '5907501002074', '5900919052433', '5905784352886', '5902356000268', '5906190371492', '5900672302691', '5904083584318', '5900085010886', '5901696012474', '5907180333353', '5907180333223', '5901696012481', '5907180316035', '5907180312211', '5907180326379', '5900907004710', '5904215135166', '5904215110774', '5901363662780', '5900907006356', '5901363662520', '5900907008602', '5900907005625', '5907180315908', '5901844101579', '4056489359418', '5901696012221', '5900397734357', '5901882110489', '5902221662034', '5900143007841', '5907180313454', '5900397736108', '5907180312266', '5904194000936', '5907501002364', '5901549989892', '5900477016069', '5901135011082', '5900907005557', '4056489259794', '7613034441539', '8720182344250', '3850104200014', '8801073116474', '20487942', '8711200336173', '4056489180227', '8712100868054', '3083680077675', '20860035', '8712100867316', '4056489180210', '8712100466342', '7613036599009', '4056489441830', '8714100698792', '4056489179375', '4056489180203', '8718114712789')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Soups by pipeline',
    ean = null
where country = 'PL'
  and category != 'Soups'
  and identity_key in ('0ba13ec29c9baa03bff5ad857e23ac94', '0bb233bb687d9595abf7e2daf706b03e', '0d235014701fff8f3117a2a02b08ca5c', '0d81bc4acdc0d3421b37fbc8e134e397', '125f032d11b16d7e4923a43d76f3dc98', '1656258e60a2e4e5033cef1f2160096f', '1ef6281e1368028b78bba685dc824799', '1ff8dd5130104da8353be5806bb6b9e4', '20d3144006c8e95cf7d22cb57531dfdb', '218813931292d6141afd44e42075407d', '22ebd9477007e22fcd97b2dc0dbf3de4', '238fe9c9a7e1c6e56b8984b01e646255', '23d75bb8894721181fd12d5731aa8ba6', '243d5c518f8150173005ee6242d72f2a', '28a3d22f54766224566e2a7913a76615', '2b1aa1c13a213ef7d8b7070cd6d1a655', '2e0d6fc38cd39369365bc24d95ed9614', '30000c7fb72bddd1b891630389d0f6b1', '3409780f8eec8cd71ba954f06409af65', '3738c9c705ea5fc6737adefdee2ac5ed', '3c1407206aa2dd843d57d8d120678b30', '3dd3b9144a071afc7c8913287adb04af', '3edd163fbb525529efdc4535bb21a3f0', '3f8dea79aa097954276e3f3d90516995', '42ba28ac28fbf3fcf8ed6b7d3b7d93e9', '492fd6e217db3f8be485af35ce01e4e9', '52cd8a0b2f79138bdd88225ada186552', '564a4ed6667b5b7fec2de8bb82d443c5', '56caf9dbb24fed1c7d82f67d5aac87ff', '578d93b9223261534e1a483a53b37a05', '5b507b3271c603b99cc35fc7a69473c3', '5c0a76e736c0b96a7173c69c873ba196', '5d4a2d54f304817df95194e07c03d9bd', '624ac24d058e2e93308e0a1323737da3', '63797f9dcb83b81215a0f6edcb82a5d0', '65a00b9f880e3a563a9ef9b7e13be571', '687a79c57f2360218dacb619e5e3ba8d', '6ae6bcff991be7cdfd4b03f9f9a8371a', '6d14438ae6e326eb6345a81a34b576d0', '6d2e6790097aa56a0cb4518eabb8269f', '6e006038b38491b70328f0f613fd83e6', '6fbba6c0661c5253beaa956979ba9c41', '702c65d8d22f4dfe69772838d3396e0e', '7110aff7b5ef1191b2a2aee421bcace7', '74f978777220c69d96353d94fa093589', '798817c38a0d028947eacf5c139b3858', '7aa6605eb09f9bb17fc8593b61b0e110', '8012aa2c6eefb7d262c72f9d2a029756', '8259926c75c89ccd551593497c4b32a9', '8373600051721adad89703693ee51d09', '840f3123538349d33037403e9a37e164', '86de78b4a90c73454ff2f6926b9b72ca', '86ffe56f42e92247c2eb95f610af456a', '8b34490327eb204ebf49e9b37e51ea3b', '925bc4a785c5d47a9fa2c357323c59aa', '93af28d1fee37ddb0a6ae8afa150b31d', '9649292046f38871384d9469bab7eb2b', '9cadf5f9e4c1ab5d4d8d24418035b5aa', '9ed72d0a9d9e1fad459799c31bc32297', 'a0a59d4f148407069f9e80430768026d', 'a1572b14122f57b85f2c81823cecf28c', 'a4624bff45d40d61ce42918dfbf94234', 'a6308701898af87e380ae9d47670b0d2', 'a8364570a63be62b6b330ae1f1719470', 'ac82efca57a45ae6da853afc6e021d58', 'acdd67ba0e6330bb8e7714929c901927', 'aef69c32575f6ea559a46c5827d3d29c', 'af747ff4a17b73066e7dd3add0d095e4', 'b2f32a6cc4afc0f1cf9386e6ad77947e', 'b3999ce6de78f182778a21572b0fd686', 'b502b5613e0a1eba728db100c0100002', 'b7186d3a919f19e78a42cd5ad52f9fda', 'b79fba85eb6b258c9662a5752b398cb7', 'babe0d91d8f825b1fecd48dc84c3b7e1', 'bb42f73e2289fb3717d3498d6019b095', 'bd7d66a4207f342d8e6b5e96e5ac3ec7', 'c1cb73e35a8d701cabe3d29acbe46308', 'c4311fc172cc4eac512cfe479798f74a', 'cc2bf9adb14e0c338572c9fcc7b4e2f1', 'cfb977da3100cf73e7124b6878b6e700', 'cfc792e780d53e39421f6cd79e7a4e63', 'd85e2f406c5cee2885c29e4efbeaafd5', 'd8a1a61ba84b879495eb421b44b77770', 'dc43f6fd1827056f63c1c25765b6306d', 'dd3edb4a8c4b0d7aff0b1f683a082499', 'df2fc60a6bd33d0081895eb5b8b5c8b7', 'e531b457d02d90621c4aec5fe92fd59a', 'e56868bdb388ddc8e3185621cd307f67', 'eec3b2836266e0d10e3b452da33ea13d', 'efbbd001692c9719f5825f10522b71be', 'f222d464f7c803dd44f63f42b0c491a3', 'f2e2818c5bbe8449defcf528b8aebcc1', 'fbd81ec1a66837f84dd45cf9174c8a1e')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Krakus', 'Grocery', 'Soups', 'Zupa Żurek', 'fermented', 'Auchan', 'none', '5900397734401'),
  ('PL', 'Auchan', 'Grocery', 'Soups', 'Fasolka po bretońsku z kiełbasą i boczkiem.', 'not-applicable', 'Auchan', 'none', '5904215135159'),
  ('PL', 'Łowicz', 'Grocery', 'Soups', 'Kociołek węgierski', 'not-applicable', 'Biedronka', 'none', '5900397735200'),
  ('PL', 'Profi', 'Grocery', 'Soups', 'Krupnik z mięsem wieprzowym', 'not-applicable', 'Auchan', 'none', '5901696000860'),
  ('PL', 'Krakus', 'Grocery', 'Soups', 'Barszcz biały koncentrat', 'not-applicable', 'Biedronka', 'none', '5900397742994'),
  ('PL', 'Profi', 'Grocery', 'Soups', 'Zupa pomidorowa z mięsem wieprzowym', 'not-applicable', 'Auchan', 'none', '5901696000839'),
  ('PL', 'Lewiatan', 'Grocery', 'Soups', 'Fasolka po bretońsku', 'not-applicable', 'Lewiatan', 'none', '5903895634822'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa kapuśniak z pomidorami', 'not-applicable', 'Biedronka', 'none', '5907180327116'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa kapuśniak', 'not-applicable', 'Biedronka', 'none', '5907180312242'),
  ('PL', 'Pudliszki', 'Grocery', 'Soups', 'Fasolka po Bretońsku', 'not-applicable', null, 'none', '5900783004057'),
  ('PL', 'Pudliszki', 'Grocery', 'Soups', 'Flaki wołowe w rosole', 'not-applicable', null, 'none', '5900783004743'),
  ('PL', 'Kuchnia Staropolska', 'Grocery', 'Soups', 'Fasolka po bretońsku z kiełbasą', 'not-applicable', null, 'none', '5903895627176'),
  ('PL', 'Pudliszki', 'Grocery', 'Soups', 'Flaki wołowe po zamojsku', 'not-applicable', null, 'none', '5900783004736'),
  ('PL', 'Unknown', 'Grocery', 'Soups', 'Krem pomidorowo-paprykowy z ryżem', 'dried', null, 'none', '5906122901049'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Soups', 'Żurek', 'fermented', null, 'none', '5905162002297'),
  ('PL', 'Pudliszki', 'Grocery', 'Soups', 'Gulasz wieprzowo-wołowy', 'not-applicable', null, 'none', '5900783004941'),
  ('PL', 'Stoczek', 'Grocery', 'Soups', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'not-applicable', null, 'none', '5901002002991'),
  ('PL', 'Unknown', 'Grocery', 'Soups', 'Flaczki królewskie wołowe', 'not-applicable', null, 'none', '5907368740294'),
  ('PL', 'Brzeziecki', 'Grocery', 'Soups', 'Barszcz biały', 'not-applicable', null, 'none', '5903240394067'),
  ('PL', 'Brzeziecki', 'Grocery', 'Soups', 'Żur Wiejski', 'fermented', null, 'none', '5903240394036'),
  ('PL', 'Rolnik', 'Grocery', 'Soups', 'Żurek na zakwasie koncentrat', 'fermented', null, 'none', '5900919002025'),
  ('PL', 'Culineo', 'Grocery', 'Soups', 'Flaki wołowe w rosole', 'not-applicable', null, 'none', '5903895637465'),
  ('PL', 'Pudliszki', 'Grocery', 'Soups', 'Fasolka po bretońsku z kiełbasą', 'not-applicable', null, 'none', '5900783004897'),
  ('PL', 'M.E.A.L. Artea', 'Grocery', 'Soups', 'Fasola po bretońsku', 'not-applicable', null, 'none', '5902221662027'),
  ('PL', 'Bobovita', 'Grocery', 'Soups', 'Pomidorowa z kurczakiem i ryżem', 'not-applicable', null, 'none', '5900852150005'),
  ('PL', 'Unknown', 'Grocery', 'Soups', 'Żurek Aliny', 'not-applicable', null, 'none', '5902020710004'),
  ('PL', 'Ten Smak', 'Grocery', 'Soups', 'Żurek staropolski', 'not-applicable', null, 'none', '5902634970009'),
  ('PL', 'Łowicz', 'Grocery', 'Soups', 'Kociołek Orientalny', 'not-applicable', null, 'none', '5900397735118'),
  ('PL', 'Stoczek', 'Grocery', 'Soups', 'Mięso wołowe z makaronem i boczkiem wędzonym w sosie pomidorowym', 'smoked', null, 'none', '5901002006586'),
  ('PL', 'Kuchnia Staropolska', 'Grocery', 'Soups', 'Krupnik z mięsem drobiowym', 'not-applicable', null, 'none', '5903895631012'),
  ('PL', 'Łowicz', 'Grocery', 'Soups', 'Fasolka po bretońsku z boczkiem i kiełbasą', 'not-applicable', null, 'none', '5900397734838'),
  ('PL', 'Farma świętokrzyska', 'Grocery', 'Soups', 'Kapuśniak świętokrzyski', 'not-applicable', null, 'none', '5902537540132'),
  ('PL', 'Delikatna', 'Grocery', 'Soups', 'Fasolka po bretońsku z ziemniakami', 'not-applicable', null, 'none', '5903726407076'),
  ('PL', 'Pamapol', 'Grocery', 'Soups', 'Fasolka po bretońsku z boczkiem', 'not-applicable', null, 'none', '5907501002074'),
  ('PL', 'Rolnik', 'Grocery', 'Soups', 'Fasolka po bretońsku z kiełbasą', 'not-applicable', null, 'none', '5900919052433'),
  ('PL', 'Carrefour Classic', 'Grocery', 'Soups', 'Fasolka po bretońsku', 'not-applicable', null, 'none', '5905784352886'),
  ('PL', 'Herby', 'Grocery', 'Soups', 'Fasolka Po Bretońsku z Kiełbasą', 'not-applicable', null, 'none', '5902356000268'),
  ('PL', 'Szubryt', 'Grocery', 'Soups', 'Fasolka po bretońsku', 'not-applicable', null, 'none', '5906190371492'),
  ('PL', 'Primavika', 'Grocery', 'Soups', 'Fasola a''la po bretońsku', 'not-applicable', null, 'none', '5900672302691'),
  ('PL', 'EdRED', 'Grocery', 'Soups', 'Grochówka generalska', 'not-applicable', null, 'none', '5904083584318'),
  ('PL', 'Nestlé', 'Grocery', 'Soups', 'Barszcz czerwony', 'not-applicable', 'Carrefour', 'none', '5900085010886'),
  ('PL', 'Jemy Jemy', 'Grocery', 'Soups', 'Zupa krem z pomidorow', 'not-applicable', 'Lidl', 'none', '5901696012474'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa krem z dyni', 'not-applicable', 'Biedronka', 'none', '5907180333353'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa Fasolowa z Pomidorami i Szpinakiem', 'not-applicable', 'Biedronka', 'none', '5907180333223'),
  ('PL', 'Jemy Jemy', 'Grocery', 'Soups', 'Zupa krem z zielonego groszku', 'not-applicable', 'Lidl', 'none', '5901696012481'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa pomidorowa', 'not-applicable', 'Biedronka', 'none', '5907180316035'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa grochowa', 'not-applicable', 'Biedronka', 'none', '5907180312211'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa koperkowa', 'not-applicable', 'Biedronka', 'none', '5907180326379'),
  ('PL', 'Urbanek', 'Grocery', 'Soups', 'Cucumber soup with dill', 'not-applicable', 'Auchan', 'none', '5900907004710'),
  ('PL', 'Słoik konesera', 'Grocery', 'Soups', 'Klopsy w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5904215135166'),
  ('PL', 'Auchan', 'Grocery', 'Soups', 'Pulpety w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5904215110774'),
  ('PL', 'Yabra', 'Grocery', 'Soups', 'Zupa gulaszowa', 'not-applicable', 'Auchan', 'none', '5901363662780'),
  ('PL', 'Pan Pomidor Lidl', 'Grocery', 'Soups', 'Zupa marokańska', 'not-applicable', null, 'none', '5900907006356'),
  ('PL', 'Yabra', 'Grocery', 'Soups', 'Fasolka po bretońsku', 'not-applicable', null, 'none', '5901363662520'),
  ('PL', 'Pan Pomidor', 'Grocery', 'Soups', 'Zupa indyjska z soczewicą i gram masala', 'not-applicable', null, 'none', '5900907008602'),
  ('PL', 'Pan Pomidor', 'Grocery', 'Soups', 'Zupa szczawiowa z ziemniakami', 'not-applicable', 'Kaufland', 'none', '5900907005625'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa Minestrone', 'not-applicable', 'Biedronka', 'none', '5907180315908'),
  ('PL', 'Culineo', 'Grocery', 'Soups', 'Bulion warzywny', 'not-applicable', 'Biedronka', 'none', '5901844101579'),
  ('PL', 'Chef select', 'Grocery', 'Soups', 'Zupa krem z pomidorów z bazylią', 'not-applicable', 'Lidl', 'none', '4056489359418'),
  ('PL', 'Jemy JEMY', 'Grocery', 'Soups', 'ZUPA TAJSKA Zupy Swiata', 'not-applicable', null, 'none', '5901696012221'),
  ('PL', 'Krakus', 'Grocery', 'Soups', 'Barszcz czerwony', 'not-applicable', null, 'none', '5900397734357'),
  ('PL', 'Vifon', 'Grocery', 'Soups', 'Bo tieu', 'dried', null, 'none', '5901882110489'),
  ('PL', 'M.E.A.L.', 'Grocery', 'Soups', 'Gulasz wieprzowy', 'not-applicable', null, 'none', '5902221662034'),
  ('PL', 'Kotwica', 'Grocery', 'Soups', 'Krupnik', 'not-applicable', null, 'none', '5900143007841'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa jarzynowa', 'not-applicable', null, 'none', '5907180313454'),
  ('PL', 'Łowicz', 'Grocery', 'Soups', 'Flaki po zamojsku', 'not-applicable', null, 'none', '5900397736108'),
  ('PL', 'Biedronka', 'Grocery', 'Soups', 'Zupa krem pomidorowy', 'not-applicable', null, 'none', '5907180312266'),
  ('PL', 'Go vege', 'Grocery', 'Soups', 'Strogonow roslinny', 'not-applicable', null, 'none', '5904194000936'),
  ('PL', 'Sorella', 'Grocery', 'Soups', 'Zupa krem z dyni i mango', 'not-applicable', null, 'none', '5907501002364'),
  ('PL', 'Eat me', 'Grocery', 'Soups', 'Zupa krem z pieczonej papryki i mascarpone', 'roasted', null, 'none', '5901549989892'),
  ('PL', 'Hortex', 'Grocery', 'Soups', 'Zupa pomidorowa z makaronem', 'not-applicable', null, 'none', '5900477016069'),
  ('PL', 'Kucharek', 'Grocery', 'Soups', 'Bulion warzywny', 'dried', null, 'none', '5901135011082'),
  ('PL', 'Pan pomidor', 'Grocery', 'Soups', 'Pomidorowa', 'not-applicable', null, 'none', '5900907005557'),
  ('PL', 'Chef Select', 'Grocery', 'Soups', 'Żurek z białą kiełbasą i boczkiem', 'fermented', 'Lidl', 'none', '4056489259794'),
  ('PL', 'Nestlé', 'Grocery', 'Soups', 'Rosół drobiowy królewski', 'dried', null, 'none', '7613034441539'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Rosół z kury', 'not-applicable', null, 'none', '8720182344250'),
  ('PL', 'Podravka', 'Grocery', 'Soups', 'Vegeta Natur Rosół Wołowy', 'dried', null, 'none', '3850104200014'),
  ('PL', 'Samyang', 'Grocery', 'Soups', 'Buldak HOT Chicken Flavour Ramen Cheese Flavour', 'not-applicable', 'Biedronka', 'palm oil', '8801073116474'),
  ('PL', 'Italiamo', 'Grocery', 'Soups', 'Paradizniki suseni lidl', 'dried', 'Lidl', 'none', '20487942'),
  ('PL', 'Amino', 'Grocery', 'Soups', 'Hühnersuppe mit Petersillie', 'dried', null, 'none', '8711200336173'),
  ('PL', 'Chef Select', 'Grocery', 'Soups', 'Zupa Inspiracja Tajska', 'not-applicable', null, 'none', '4056489180227'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Borowikowa z grzankami', 'dried', null, 'none', '8712100868054'),
  ('PL', 'Bonduelle', 'Grocery', 'Soups', 'Haricots blancs', 'not-applicable', null, 'none', '3083680077675'),
  ('PL', 'Freshona', 'Grocery', 'Soups', 'Zupa kalafiorowa z koperkiem', 'not-applicable', null, 'none', '20860035'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Grochowa z grzankami', 'dried', null, 'none', '8712100867316'),
  ('PL', 'Lidl', 'Grocery', 'Soups', 'Lentil Soup Indian Style', 'not-applicable', null, 'none', '4056489180210'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Borscht, Instant', 'not-applicable', null, 'none', '8712100466342'),
  ('PL', 'Nestlé', 'Grocery', 'Soups', 'Bulion drobiowy', 'not-applicable', null, 'none', '7613036599009'),
  ('PL', 'Kania', 'Grocery', 'Soups', 'Hühnerbrühe', 'not-applicable', null, 'none', '4056489441830'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Danie puree', 'not-applicable', null, 'none', '8714100698792'),
  ('PL', 'Chef Select Lidl', 'Grocery', 'Soups', 'Zupa grochowa z boczkiem i tymiankiem', 'not-applicable', null, 'none', '4056489179375'),
  ('PL', 'Chef Select Lidl', 'Grocery', 'Soups', 'Zupa Inspiracja Wietnamska', 'not-applicable', null, 'none', '4056489180203'),
  ('PL', 'Knorr', 'Grocery', 'Soups', 'Kremowa zupa z kurek ze szczypiorkiem', 'dried', null, 'none', '8718114712789')
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
where country = 'PL' and category = 'Soups'
  and is_deprecated is not true
  and product_name not in ('Zupa Żurek', 'Fasolka po bretońsku z kiełbasą i boczkiem.', 'Kociołek węgierski', 'Krupnik z mięsem wieprzowym', 'Barszcz biały koncentrat', 'Zupa pomidorowa z mięsem wieprzowym', 'Fasolka po bretońsku', 'Zupa kapuśniak z pomidorami', 'Zupa kapuśniak', 'Fasolka po Bretońsku', 'Flaki wołowe w rosole', 'Fasolka po bretońsku z kiełbasą', 'Flaki wołowe po zamojsku', 'Krem pomidorowo-paprykowy z ryżem', 'Żurek', 'Gulasz wieprzowo-wołowy', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'Flaczki królewskie wołowe', 'Barszcz biały', 'Żur Wiejski', 'Żurek na zakwasie koncentrat', 'Flaki wołowe w rosole', 'Fasolka po bretońsku z kiełbasą', 'Fasola po bretońsku', 'Pomidorowa z kurczakiem i ryżem', 'Żurek Aliny', 'Żurek staropolski', 'Kociołek Orientalny', 'Mięso wołowe z makaronem i boczkiem wędzonym w sosie pomidorowym', 'Krupnik z mięsem drobiowym', 'Fasolka po bretońsku z boczkiem i kiełbasą', 'Kapuśniak świętokrzyski', 'Fasolka po bretońsku z ziemniakami', 'Fasolka po bretońsku z boczkiem', 'Fasolka po bretońsku z kiełbasą', 'Fasolka po bretońsku', 'Fasolka Po Bretońsku z Kiełbasą', 'Fasolka po bretońsku', 'Fasola a''la po bretońsku', 'Grochówka generalska', 'Barszcz czerwony', 'Zupa krem z pomidorow', 'Zupa krem z dyni', 'Zupa Fasolowa z Pomidorami i Szpinakiem', 'Zupa krem z zielonego groszku', 'Zupa pomidorowa', 'Zupa grochowa', 'Zupa koperkowa', 'Cucumber soup with dill', 'Klopsy w sosie pomidorowym', 'Pulpety w sosie pomidorowym', 'Zupa gulaszowa', 'Zupa marokańska', 'Fasolka po bretońsku', 'Zupa indyjska z soczewicą i gram masala', 'Zupa szczawiowa z ziemniakami', 'Zupa Minestrone', 'Bulion warzywny', 'Zupa krem z pomidorów z bazylią', 'ZUPA TAJSKA Zupy Swiata', 'Barszcz czerwony', 'Bo tieu', 'Gulasz wieprzowy', 'Krupnik', 'Zupa jarzynowa', 'Flaki po zamojsku', 'Zupa krem pomidorowy', 'Strogonow roslinny', 'Zupa krem z dyni i mango', 'Zupa krem z pieczonej papryki i mascarpone', 'Zupa pomidorowa z makaronem', 'Bulion warzywny', 'Pomidorowa', 'Żurek z białą kiełbasą i boczkiem', 'Rosół drobiowy królewski', 'Rosół z kury', 'Vegeta Natur Rosół Wołowy', 'Buldak HOT Chicken Flavour Ramen Cheese Flavour', 'Paradizniki suseni lidl', 'Hühnersuppe mit Petersillie', 'Zupa Inspiracja Tajska', 'Borowikowa z grzankami', 'Haricots blancs', 'Zupa kalafiorowa z koperkiem', 'Grochowa z grzankami', 'Lentil Soup Indian Style', 'Borscht, Instant', 'Bulion drobiowy', 'Hühnerbrühe', 'Danie puree', 'Zupa grochowa z boczkiem i tymiankiem', 'Zupa Inspiracja Wietnamska', 'Kremowa zupa z kurek ze szczypiorkiem');
