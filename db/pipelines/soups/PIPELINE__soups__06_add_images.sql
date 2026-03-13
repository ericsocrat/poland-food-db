-- PIPELINE (Soups): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Soups'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Krakus', 'Zupa Żurek', 'https://images.openfoodfacts.org/images/products/590/039/773/4401/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397734401', 'front_5900397734401'),
    ('Auchan', 'Fasolka po bretońsku z kiełbasą i boczkiem.', 'https://images.openfoodfacts.org/images/products/590/421/513/5159/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215135159', 'front_5904215135159'),
    ('Łowicz', 'Kociołek węgierski', 'https://images.openfoodfacts.org/images/products/590/039/773/5200/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397735200', 'front_5900397735200'),
    ('Profi', 'Krupnik z mięsem wieprzowym', 'https://images.openfoodfacts.org/images/products/590/169/600/0860/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696000860', 'front_5901696000860'),
    ('Krakus', 'Barszcz biały koncentrat', 'https://images.openfoodfacts.org/images/products/590/039/774/2994/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397742994', 'front_5900397742994'),
    ('Profi', 'Zupa pomidorowa z mięsem wieprzowym', 'https://images.openfoodfacts.org/images/products/590/169/600/0839/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696000839', 'front_5901696000839'),
    ('Lewiatan', 'Fasolka po bretońsku', 'https://images.openfoodfacts.org/images/products/590/389/563/4822/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895634822', 'front_5903895634822'),
    ('Biedronka', 'Zupa kapuśniak z pomidorami', 'https://images.openfoodfacts.org/images/products/590/718/032/7116/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180327116', 'front_5907180327116'),
    ('Biedronka', 'Zupa kapuśniak', 'https://images.openfoodfacts.org/images/products/590/718/031/2242/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180312242', 'front_5907180312242'),
    ('Pudliszki', 'Fasolka po Bretońsku', 'https://images.openfoodfacts.org/images/products/590/078/300/4057/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004057', 'front_5900783004057'),
    ('Pudliszki', 'Flaki wołowe w rosole', 'https://images.openfoodfacts.org/images/products/590/078/300/4743/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004743', 'front_5900783004743'),
    ('Kuchnia Staropolska', 'Fasolka po bretońsku z kiełbasą', 'https://images.openfoodfacts.org/images/products/590/389/562/7176/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895627176', 'front_5903895627176'),
    ('Pudliszki', 'Flaki wołowe po zamojsku', 'https://images.openfoodfacts.org/images/products/590/078/300/4736/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004736', 'front_5900783004736'),
    ('Unknown', 'Krem pomidorowo-paprykowy z ryżem', 'https://images.openfoodfacts.org/images/products/590/612/290/1049/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906122901049', 'front_5906122901049'),
    ('Nasze Smaki', 'Żurek', 'https://images.openfoodfacts.org/images/products/590/516/200/2297/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905162002297', 'front_5905162002297'),
    ('Pudliszki', 'Gulasz wieprzowo-wołowy', 'https://images.openfoodfacts.org/images/products/590/078/300/4941/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004941', 'front_5900783004941'),
    ('Stoczek', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'https://images.openfoodfacts.org/images/products/590/100/200/2991/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901002002991', 'front_5901002002991'),
    ('Unknown', 'Flaczki królewskie wołowe', 'https://images.openfoodfacts.org/images/products/590/736/874/0294/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907368740294', 'front_5907368740294'),
    ('Brzeziecki', 'Barszcz biały', 'https://images.openfoodfacts.org/images/products/590/324/039/4067/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240394067', 'front_5903240394067'),
    ('Brzeziecki', 'Żur Wiejski', 'https://images.openfoodfacts.org/images/products/590/324/039/4036/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240394036', 'front_5903240394036'),
    ('Rolnik', 'Żurek na zakwasie koncentrat', 'https://images.openfoodfacts.org/images/products/590/091/900/2025/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900919002025', 'front_5900919002025'),
    ('Culineo', 'Flaki wołowe w rosole', 'https://images.openfoodfacts.org/images/products/590/389/563/7465/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895637465', 'front_5903895637465'),
    ('Pudliszki', 'Fasolka po bretońsku z kiełbasą', 'https://images.openfoodfacts.org/images/products/590/078/300/4897/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004897', 'front_5900783004897'),
    ('M.E.A.L. Artea', 'Fasola po bretońsku', 'https://images.openfoodfacts.org/images/products/590/222/166/2027/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902221662027', 'front_5902221662027'),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 'https://images.openfoodfacts.org/images/products/590/085/215/0005/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900852150005', 'front_5900852150005'),
    ('Unknown', 'Żurek Aliny', 'https://images.openfoodfacts.org/images/products/590/202/071/0004/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902020710004', 'front_5902020710004'),
    ('Ten Smak', 'Żurek staropolski', 'https://images.openfoodfacts.org/images/products/590/263/497/0009/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902634970009', 'front_5902634970009'),
    ('Łowicz', 'Kociołek Orientalny', 'https://images.openfoodfacts.org/images/products/590/039/773/5118/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397735118', 'front_5900397735118'),
    ('Stoczek', 'Mięso wołowe z makaronem i boczkiem wędzonym w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/100/200/6586/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901002006586', 'front_5901002006586'),
    ('Kuchnia Staropolska', 'Krupnik z mięsem drobiowym', 'https://images.openfoodfacts.org/images/products/590/389/563/1012/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895631012', 'front_5903895631012'),
    ('Łowicz', 'Fasolka po bretońsku z boczkiem i kiełbasą', 'https://images.openfoodfacts.org/images/products/590/039/773/4838/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397734838', 'front_5900397734838'),
    ('Farma świętokrzyska', 'Kapuśniak świętokrzyski', 'https://images.openfoodfacts.org/images/products/590/253/754/0132/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902537540132', 'front_5902537540132'),
    ('Delikatna', 'Fasolka po bretońsku z ziemniakami', 'https://images.openfoodfacts.org/images/products/590/372/640/7076/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903726407076', 'front_5903726407076'),
    ('Pamapol', 'Fasolka po bretońsku z boczkiem', 'https://images.openfoodfacts.org/images/products/590/750/100/2074/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501002074', 'front_5907501002074'),
    ('Rolnik', 'Fasolka po bretońsku z kiełbasą', 'https://images.openfoodfacts.org/images/products/590/091/905/2433/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900919052433', 'front_5900919052433'),
    ('Carrefour Classic', 'Fasolka po bretońsku', 'https://images.openfoodfacts.org/images/products/590/578/435/2886/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784352886', 'front_5905784352886'),
    ('Primavika', 'Fasola a''la po bretońsku', 'https://images.openfoodfacts.org/images/products/590/067/230/2691/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900672302691', 'front_5900672302691'),
    ('EdRED', 'Grochówka generalska', 'https://images.openfoodfacts.org/images/products/590/408/358/4318/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904083584318', 'front_5904083584318'),
    ('Nestlé', 'Barszcz czerwony', 'https://images.openfoodfacts.org/images/products/590/008/501/0886/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900085010886', 'front_5900085010886'),
    ('Jemy Jemy', 'Zupa krem z pomidorow', 'https://images.openfoodfacts.org/images/products/590/169/601/2474/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696012474', 'front_5901696012474'),
    ('Biedronka', 'Zupa krem z dyni', 'https://images.openfoodfacts.org/images/products/590/718/033/3353/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180333353', 'front_5907180333353'),
    ('Biedronka', 'Zupa Fasolowa z Pomidorami i Szpinakiem', 'https://images.openfoodfacts.org/images/products/590/718/033/3223/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180333223', 'front_5907180333223'),
    ('Jemy Jemy', 'Zupa krem z zielonego groszku', 'https://images.openfoodfacts.org/images/products/590/169/601/2481/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696012481', 'front_5901696012481'),
    ('Biedronka', 'Zupa pomidorowa', 'https://images.openfoodfacts.org/images/products/590/718/031/6035/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180316035', 'front_5907180316035'),
    ('Biedronka', 'Zupa grochowa', 'https://images.openfoodfacts.org/images/products/590/718/031/2211/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180312211', 'front_5907180312211'),
    ('Biedronka', 'Zupa koperkowa', 'https://images.openfoodfacts.org/images/products/590/718/032/6379/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180326379', 'front_5907180326379'),
    ('Urbanek', 'Cucumber soup with dill', 'https://images.openfoodfacts.org/images/products/590/090/700/4710/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907004710', 'front_5900907004710'),
    ('Słoik konesera', 'Klopsy w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/421/513/5166/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215135166', 'front_5904215135166'),
    ('Auchan', 'Pulpety w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/421/511/0774/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215110774', 'front_5904215110774'),
    ('Yabra', 'Zupa gulaszowa', 'https://images.openfoodfacts.org/images/products/590/136/366/2780/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901363662780', 'front_5901363662780'),
    ('Yabra', 'Fasolka po bretońsku', 'https://images.openfoodfacts.org/images/products/590/136/366/2520/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901363662520', 'front_5901363662520'),
    ('Pan Pomidor', 'Zupa indyjska z soczewicą i gram masala', 'https://images.openfoodfacts.org/images/products/590/090/700/8602/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907008602', 'front_5900907008602'),
    ('Pan Pomidor', 'Zupa szczawiowa z ziemniakami', 'https://images.openfoodfacts.org/images/products/590/090/700/5625/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907005625', 'front_5900907005625'),
    ('Biedronka', 'Zupa Minestrone', 'https://images.openfoodfacts.org/images/products/590/718/031/5908/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180315908', 'front_5907180315908'),
    ('Culineo', 'Bulion warzywny', 'https://images.openfoodfacts.org/images/products/590/184/410/1579/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901844101579', 'front_5901844101579'),
    ('Chef select', 'Zupa krem z pomidorów z bazylią', 'https://images.openfoodfacts.org/images/products/405/648/935/9418/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489359418', 'front_4056489359418'),
    ('Krakus', 'Barszcz czerwony', 'https://images.openfoodfacts.org/images/products/590/039/773/4357/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397734357', 'front_5900397734357'),
    ('Vifon', 'Bo tieu', 'https://images.openfoodfacts.org/images/products/590/188/211/0489/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882110489', 'front_5901882110489'),
    ('M.E.A.L.', 'Gulasz wieprzowy', 'https://images.openfoodfacts.org/images/products/590/222/166/2034/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902221662034', 'front_5902221662034'),
    ('Kotwica', 'Krupnik', 'https://images.openfoodfacts.org/images/products/590/014/300/7841/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900143007841', 'front_5900143007841'),
    ('Biedronka', 'Zupa jarzynowa', 'https://images.openfoodfacts.org/images/products/590/718/031/3454/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180313454', 'front_5907180313454'),
    ('Łowicz', 'Flaki po zamojsku', 'https://images.openfoodfacts.org/images/products/590/039/773/6108/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397736108', 'front_5900397736108'),
    ('Biedronka', 'Zupa krem pomidorowy', 'https://images.openfoodfacts.org/images/products/590/718/031/2266/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180312266', 'front_5907180312266'),
    ('Go vege', 'Strogonow roslinny', 'https://images.openfoodfacts.org/images/products/590/419/400/0936/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194000936', 'front_5904194000936'),
    ('Sorella', 'Zupa krem z dyni i mango', 'https://images.openfoodfacts.org/images/products/590/750/100/2364/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501002364', 'front_5907501002364'),
    ('Eat me', 'Zupa krem z pieczonej papryki i mascarpone', 'https://images.openfoodfacts.org/images/products/590/154/998/9892/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901549989892', 'front_5901549989892'),
    ('Hortex', 'Zupa pomidorowa z makaronem', 'https://images.openfoodfacts.org/images/products/590/047/701/6069/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900477016069', 'front_5900477016069'),
    ('Kucharek', 'Bulion warzywny', 'https://images.openfoodfacts.org/images/products/590/113/501/1082/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135011082', 'front_5901135011082'),
    ('Pan pomidor', 'Pomidorowa', 'https://images.openfoodfacts.org/images/products/590/090/700/5557/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907005557', 'front_5900907005557'),
    ('Chef Select', 'Żurek z białą kiełbasą i boczkiem', 'https://images.openfoodfacts.org/images/products/405/648/925/9794/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489259794', 'front_4056489259794'),
    ('Nestlé', 'Rosół drobiowy królewski', 'https://images.openfoodfacts.org/images/products/761/303/444/1539/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613034441539', 'front_7613034441539'),
    ('Knorr', 'Rosół z kury', 'https://images.openfoodfacts.org/images/products/872/018/234/4250/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720182344250', 'front_8720182344250'),
    ('Podravka', 'Vegeta Natur Rosół Wołowy', 'https://images.openfoodfacts.org/images/products/385/010/420/0014/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 3850104200014', 'front_3850104200014'),
    ('Samyang', 'Buldak HOT Chicken Flavour Ramen Cheese Flavour', 'https://images.openfoodfacts.org/images/products/880/107/311/6474/front_en.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801073116474', 'front_8801073116474'),
    ('Italiamo', 'Paradizniki suseni lidl', 'https://images.openfoodfacts.org/images/products/000/002/048/7942/front_en.163.400.jpg', 'off_api', 'front', true, 'Front — EAN 20487942', 'front_20487942'),
    ('Amino', 'Hühnersuppe mit Petersillie', 'https://images.openfoodfacts.org/images/products/871/120/033/6173/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711200336173', 'front_8711200336173'),
    ('Chef Select', 'Zupa Inspiracja Tajska', 'https://images.openfoodfacts.org/images/products/405/648/918/0227/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489180227', 'front_4056489180227'),
    ('Knorr', 'Borowikowa z grzankami', 'https://images.openfoodfacts.org/images/products/871/210/086/8054/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712100868054', 'front_8712100868054'),
    ('Freshona', 'Zupa kalafiorowa z koperkiem', 'https://images.openfoodfacts.org/images/products/000/002/086/0035/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 20860035', 'front_20860035'),
    ('Knorr', 'Grochowa z grzankami', 'https://images.openfoodfacts.org/images/products/871/210/086/7316/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712100867316', 'front_8712100867316'),
    ('Lidl', 'Lentil Soup Indian Style', 'https://images.openfoodfacts.org/images/products/405/648/918/0210/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489180210', 'front_4056489180210'),
    ('Knorr', 'Borscht, Instant', 'https://images.openfoodfacts.org/images/products/871/210/046/6342/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712100466342', 'front_8712100466342'),
    ('Nestlé', 'Bulion drobiowy', 'https://images.openfoodfacts.org/images/products/761/303/659/9009/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036599009', 'front_7613036599009'),
    ('Kania', 'Hühnerbrühe', 'https://images.openfoodfacts.org/images/products/405/648/944/1830/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489441830', 'front_4056489441830'),
    ('Knorr', 'Danie puree', 'https://images.openfoodfacts.org/images/products/871/410/069/8792/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8714100698792', 'front_8714100698792'),
    ('Chef Select Lidl', 'Zupa grochowa z boczkiem i tymiankiem', 'https://images.openfoodfacts.org/images/products/405/648/917/9375/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489179375', 'front_4056489179375'),
    ('Chef Select Lidl', 'Zupa Inspiracja Wietnamska', 'https://images.openfoodfacts.org/images/products/405/648/918/0203/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489180203', 'front_4056489180203'),
    ('Knorr', 'Kremowa zupa z kurek ze szczypiorkiem', 'https://images.openfoodfacts.org/images/products/871/811/471/2789/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8718114712789', 'front_8718114712789')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Soups' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
