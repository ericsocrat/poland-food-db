-- PIPELINE (Ready Meals): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Ready Meals'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Go Active', 'Kuskus Perłowy', 'https://images.openfoodfacts.org/images/products/590/159/212/7463/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901592127463', 'front_5901592127463'),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 'https://images.openfoodfacts.org/images/products/590/139/806/9936/front_pl.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398069936', 'front_5901398069936'),
    ('Swojska Chata', 'Krokiety z mięsem', 'https://images.openfoodfacts.org/images/products/590/139/807/1557/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398071557', 'front_5901398071557'),
    ('Vital Fresh', 'Sałatka lunchbox', 'https://images.openfoodfacts.org/images/products/590/266/664/7313/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902666647313', 'front_5902666647313'),
    ('Nasze Smaki', 'Pierogi z mięsem', 'https://images.openfoodfacts.org/images/products/590/139/806/9981/front_pl.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398069981', 'front_5901398069981'),
    ('Dr. Peter', 'Pizza Guseppe z szynką i pieczarkami głęboko mrożona', 'https://images.openfoodfacts.org/images/products/590/043/700/5133/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437005133', 'front_5900437005133'),
    ('Dr. Oetker', 'Pizza z salami i chorizo, głęboko mrożona', 'https://images.openfoodfacts.org/images/products/590/043/700/7151/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437007151', 'front_5900437007151'),
    ('Auchan', 'Pierogi z Mięsem', 'https://images.openfoodfacts.org/images/products/590/421/514/0528/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215140528', 'front_5904215140528'),
    ('Nasze Smaki', 'Naleśniki z serem', 'https://images.openfoodfacts.org/images/products/590/139/808/5127/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398085127', 'front_5901398085127'),
    ('Rośl-inne', 'Rośl-inne Kabanosy Piri-Piri', 'https://images.openfoodfacts.org/images/products/590/823/052/9894/front_pl.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908230529894', 'front_5908230529894'),
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 'https://images.openfoodfacts.org/images/products/590/043/700/7137/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437007137', 'front_5900437007137'),
    ('Nasze smaki', 'Kotlet drobiowy z puree i marchewką z groszkiem', 'https://images.openfoodfacts.org/images/products/590/139/807/9270/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398079270', 'front_5901398079270'),
    ('Auchan', 'Surówka Colesław', 'https://images.openfoodfacts.org/images/products/590/421/513/9034/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215139034', 'front_5904215139034'),
    ('U Jedrusia', 'Placki Ziemniaczane z gulaszem wieprzowym po węgiersku', 'https://images.openfoodfacts.org/images/products/590/139/808/2874/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398082874', 'front_5901398082874'),
    ('Cedrob', 'Skrzydełka z kurczaka w marynacie buffalo', 'https://images.openfoodfacts.org/images/products/590/033/120/7985/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900331207985', 'front_5900331207985'),
    ('Auchan', 'Pasta łososiowa ze szczypiorkiem', 'https://images.openfoodfacts.org/images/products/590/421/514/6087/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215146087', 'front_5904215146087'),
    ('Vital Fresh', 'Surówka Smakołyk', 'https://images.openfoodfacts.org/images/products/590/044/900/6913/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900449006913', 'front_5900449006913'),
    ('Asia Flavours', 'Pierożki Gyoza z warzywami', 'https://images.openfoodfacts.org/images/products/590/096/204/2009/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900962042009', 'front_5900962042009'),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'https://images.openfoodfacts.org/images/products/590/419/490/6153/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906153', 'front_5904194906153'),
    ('Biedronka', 'Pizza z szynką wieprzową i pieczarkami', 'https://images.openfoodfacts.org/images/products/590/216/213/4232/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902162134232', 'front_5902162134232'),
    ('Smacznego!', 'Sałatka bulgur z sosem pomidorowo-paprykowym', 'https://images.openfoodfacts.org/images/products/590/297/378/5494/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902973785494', 'front_5902973785494'),
    ('GO Active', 'Kuskus perłowy z suszoną śliwką, mango i hummusem', 'https://images.openfoodfacts.org/images/products/590/419/490/6160/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906160', 'front_5904194906160'),
    ('Perla', 'Sałatka bulgur', 'https://images.openfoodfacts.org/images/products/590/297/378/5487/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902973785487', 'front_5902973785487'),
    ('Dega', 'Sałatka jarzynowa', 'https://images.openfoodfacts.org/images/products/590/273/890/0094/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902738900094', 'front_5902738900094'),
    ('Nasze Smaki', 'Mięsny przysmak', 'https://images.openfoodfacts.org/images/products/590/750/101/9904/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501019904', 'front_5907501019904'),
    ('Łowicz', 'Kaszotto z kukurydzą i fasolką', 'https://images.openfoodfacts.org/images/products/590/039/774/1911/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397741911', 'front_5900397741911'),
    ('Swojska Chata', 'Kapusta kiszona z marchewką', 'https://images.openfoodfacts.org/images/products/590/516/200/2860/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905162002860', 'front_5905162002860'),
    ('Grześkowiak', 'Sałatka makaronowa z brokułami i ogórkiem', 'https://images.openfoodfacts.org/images/products/590/777/853/4445/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907778534445', 'front_5907778534445'),
    ('Lisner', 'Sałatka warzywna z jajkiem', 'https://images.openfoodfacts.org/images/products/590/034/401/6543/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344016543', 'front_5900344016543'),
    ('Fit & Easy', 'Tabbouleh z mięta i pietruszką', 'https://images.openfoodfacts.org/images/products/590/216/639/7862/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902166397862', 'front_5902166397862'),
    ('Nasze Smaki', 'Pierogi ruskie z cebulką', 'https://images.openfoodfacts.org/images/products/590/139/808/2775/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398082775', 'front_5901398082775'),
    ('Lisner', 'O Mamo! Sałatka warzywna z jajkiem', 'https://images.openfoodfacts.org/images/products/590/034/402/8676/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344028676', 'front_5900344028676'),
    ('Salato', 'Salato sałatka jarzynowa', 'https://images.openfoodfacts.org/images/products/590/034/401/6550/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344016550', 'front_5900344016550'),
    ('Go Active', 'Kurczak w Sosie Curry z Ryżem i Warzywami', 'https://images.openfoodfacts.org/images/products/590/722/279/8225/front_pl.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907222798225', 'front_5907222798225'),
    ('U Jędrusia', 'Racuchy z jabłkami', 'https://images.openfoodfacts.org/images/products/590/139/807/0642/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398070642', 'front_5901398070642'),
    ('Body Chief', 'Mango - ryż na mleczku kokosowym z mango', 'https://images.openfoodfacts.org/images/products/590/547/505/0114/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050114', 'front_5905475050114'),
    ('Body Chief', 'Sałatka ryżowa z tuńczykiem i warzywami', 'https://images.openfoodfacts.org/images/products/590/547/505/0121/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050121', 'front_5905475050121'),
    ('Grześkowiak', 'Surówka dla wegan i wegetarian ze świeżym ogórkiem', 'https://images.openfoodfacts.org/images/products/590/777/853/0485/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907778530485', 'front_5907778530485'),
    ('Grześkowiak', 'Surówka z porem w delikatnym sosie', 'https://images.openfoodfacts.org/images/products/590/777/853/5817/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907778535817', 'front_5907778535817'),
    ('Marinero', 'Sałatka z tuńczykiem', 'https://images.openfoodfacts.org/images/products/590/389/563/5089/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895635089', 'front_5903895635089'),
    ('Pamapol', 'Pulpety w sosie pomidorowym z marchewką i pietruszką', 'https://images.openfoodfacts.org/images/products/590/750/100/2036/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501002036', 'front_5907501002036'),
    ('Lisner', 'O Mamo! sałatka jajeczna ze szypiorkiem', 'https://images.openfoodfacts.org/images/products/590/034/400/6834/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344006834', 'front_5900344006834'),
    ('Vital fresh', 'Mix sałat z roszponką', 'https://images.openfoodfacts.org/images/products/590/266/664/3476/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902666643476', 'front_5902666643476'),
    ('Jawo', 'Pierogi z mięsem', 'https://images.openfoodfacts.org/images/products/590/288/500/0128/front_es.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902885000128', 'front_5902885000128'),
    ('Dega', 'Sałatka z jajkiem', 'https://images.openfoodfacts.org/images/products/590/762/326/8297/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907623268297', 'front_5907623268297'),
    ('Body Chief', 'Kotleciki brokułowe w sosie pieczarkowym z komosa ryżową', 'https://images.openfoodfacts.org/images/products/590/547/505/0183/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050183', 'front_5905475050183'),
    ('Body Chief', 'Sałatka warzywna z cukinią, jabłkiem, jajkiem, zielonym groszkiem i porem', 'https://images.openfoodfacts.org/images/products/590/547/505/0404/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050404', 'front_5905475050404'),
    ('Body Chief', 'Rybka - pulpeciki rybne z miruną w sosie koperkowym z ryżem basmati i fasolką szparagową', 'https://images.openfoodfacts.org/images/products/590/547/505/0596/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050596', 'front_5905475050596'),
    ('Body Chief', 'Pieczeń drobiowa w sosie chrzanowy z puree ziemniaczano-selerowym i burakami', 'https://images.openfoodfacts.org/images/products/590/547/505/0237/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050237', 'front_5905475050237'),
    ('Body Chief', 'Gulasz drobiowy w sosie piwnym z kaszą gryczana i sałatką szwedzką', 'https://images.openfoodfacts.org/images/products/590/547/505/0190/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050190', 'front_5905475050190'),
    ('Body Chief', 'Kurczak - makaron z kurczakiem w śmietanowym sosie z brokuła i suszonych pomidorów', 'https://images.openfoodfacts.org/images/products/590/547/505/0497/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050497', 'front_5905475050497'),
    ('Body Chief', 'Gołąbki bez zawijania z mięsem drobiowym w sosie pomidorowym z puree ziemniaczanym', 'https://images.openfoodfacts.org/images/products/590/547/505/0503/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050503', 'front_5905475050503'),
    ('Body Chief', 'Pieczeń drobiowa w sosie pomidorowo-koperkowym z puree ziemniaczano-pieczarkowym', 'https://images.openfoodfacts.org/images/products/590/547/505/0541/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050541', 'front_5905475050541'),
    ('Body Chief', 'Pulpeciki drobiowe w sosie koperkowym z kaszą jęczmienną i buraczkami z jabłkiem', 'https://images.openfoodfacts.org/images/products/590/547/505/0565/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050565', 'front_5905475050565'),
    ('Body Chief', 'Pulpeciki - pulpety drobiowe w sosie z kiszonych ogórków z kaszą gryczana i buraczkami', 'https://images.openfoodfacts.org/images/products/590/547/505/0268/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905475050268', 'front_5905475050268'),
    ('Smak', 'Pierogi z pieczarkami i żółtym serem', 'https://images.openfoodfacts.org/images/products/590/438/407/3078/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904384073078', 'front_5904384073078'),
    ('Smak', 'Golabki z ryżem i mięsiem', 'https://images.openfoodfacts.org/images/products/590/823/979/2060/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908239792060', 'front_5908239792060'),
    ('Drosed', 'Cordon Bleu z serem i szynką', 'https://images.openfoodfacts.org/images/products/590/096/202/3213/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900962023213', 'front_5900962023213'),
    ('Ludmiła', 'Rusztyk wieprzowy z cebulką z buraczkami zasmażanymi i puree', 'https://images.openfoodfacts.org/images/products/590/775/147/7240/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907751477240', 'front_5907751477240'),
    ('Fish & Chill', 'Ryba w sosie po hawajsku z ryżem', 'https://images.openfoodfacts.org/images/products/590/235/303/4372/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902353034372', 'front_5902353034372'),
    ('Unknown', 'Kajzerka z szynką konserwową i pieczonym bekonem papryka konserwowa sos tysiąca wysp sałata', 'https://images.openfoodfacts.org/images/products/590/024/404/2673/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244042673', 'front_5900244042673'),
    ('Well Done', 'Krokiety z kapustą i grzybami', 'https://images.openfoodfacts.org/images/products/590/746/813/8557/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907468138557', 'front_5907468138557'),
    ('Frosta', 'Złote Paluszki Rybne z Fileta', 'https://images.openfoodfacts.org/images/products/590/097/200/8293/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900972008293', 'front_5900972008293'),
    ('Pudliszki', 'Wołowina w sosie grzybowym', 'https://images.openfoodfacts.org/images/products/590/078/301/0416/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783010416', 'front_5900783010416'),
    ('Łowicz', 'Gołąbki w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/039/773/4944/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397734944', 'front_5900397734944'),
    ('Vatan Engros As', 'Sałatka grecka', 'https://images.openfoodfacts.org/images/products/590/091/900/4326/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900919004326', 'front_5900919004326'),
    ('Pudliszki', 'Pulpety wieprzowo-wołowe w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/078/300/4095/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004095', 'front_5900783004095'),
    ('Grześkowiak', 'Naleśniki z serem twarogowym', 'https://images.openfoodfacts.org/images/products/590/777/853/1796/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907778531796', 'front_5907778531796'),
    ('Nasze Smaki', 'Pierogi ruskie', 'https://images.openfoodfacts.org/images/products/590/139/806/9974/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398069974', 'front_5901398069974'),
    ('Donatello', 'Lasagne z kurczakiem', 'https://images.openfoodfacts.org/images/products/590/074/160/4527/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900741604527', 'front_5900741604527'),
    ('Swojska Chata', 'Pierogi ze szpinakiem i serem', 'https://images.openfoodfacts.org/images/products/590/139/806/9653/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398069653', 'front_5901398069653'),
    ('Lisner', 'Vegetable salad with eggs', 'https://images.openfoodfacts.org/images/products/590/034/450/4231/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344504231', 'front_5900344504231'),
    ('Yeemy', 'Italian style wrap', 'https://images.openfoodfacts.org/images/products/590/779/901/6876/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907799016876', 'front_5907799016876'),
    ('Go Active', 'Kurczak z puree marchewkowym', 'https://images.openfoodfacts.org/images/products/590/139/808/7121/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398087121', 'front_5901398087121'),
    ('Swojska Chata', 'Pierogi z serem', 'https://images.openfoodfacts.org/images/products/590/139/807/1533/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398071533', 'front_5901398071533'),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', 'https://images.openfoodfacts.org/images/products/590/043/720/5137/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437205137', 'front_5900437205137'),
    ('Dr. Oetker', 'Pizza Guseppe Chicken Curry', 'https://images.openfoodfacts.org/images/products/590/043/700/5256/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437005256', 'front_5900437005256'),
    ('Dr. Oetker', 'Pizza Giuseppe kebab', 'https://images.openfoodfacts.org/images/products/590/043/700/5577/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437005577', 'front_5900437005577'),
    ('Unknown', 'Salatka kuskus', 'https://images.openfoodfacts.org/images/products/590/419/491/0419/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194910419', 'front_5904194910419'),
    ('Vital Fresh', 'Mix Salad Z Sałatą Lodową', 'https://images.openfoodfacts.org/images/products/590/437/824/4323/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378244323', 'front_5904378244323'),
    ('Auchan', 'Pierogi z serem i szpinakiem', 'https://images.openfoodfacts.org/images/products/590/421/514/3680/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215143680', 'front_5904215143680'),
    ('Swojska Chata', 'Pierogi serowo- jagodowe', 'https://images.openfoodfacts.org/images/products/590/139/807/1496/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398071496', 'front_5901398071496'),
    ('Heinz', 'Heinz beanz', 'https://images.openfoodfacts.org/images/products/590/078/300/9090/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783009090', 'front_5900783009090'),
    ('Vital Fresh', 'Lunchbox z makaronem i kuraczakiem', 'https://images.openfoodfacts.org/images/products/590/266/664/5616/front_ru.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902666645616', 'front_5902666645616'),
    ('Come A Casa', 'Lasagne bolognese', 'https://images.openfoodfacts.org/images/products/590/074/160/4879/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900741604879', 'front_5900741604879'),
    ('Nasze Smaki', 'Filet Z Kurczaka', 'https://images.openfoodfacts.org/images/products/590/139/808/7459/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398087459', 'front_5901398087459'),
    ('Heinz', '5 rodzajów fasoli w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/500/015/707/2023/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000157072023', 'front_5000157072023'),
    ('Konspol', 'Zöldséges gyoza', 'https://images.openfoodfacts.org/images/products/590/096/204/0180/front_hu.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900962040180', 'front_5900962040180'),
    ('Dr. Oetker', 'Pizza 4 Cheese', 'https://images.openfoodfacts.org/images/products/590/043/720/5175/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437205175', 'front_5900437205175'),
    ('Siła Natury', 'Kapusta kiszona z Charsznicy', 'https://images.openfoodfacts.org/images/products/590/775/115/9146/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907751159146', 'front_5907751159146'),
    ('Chef Select', 'Kotlet De Volatile Z Puree Ziemniaczanym I Marchewką Z Groszkiem', 'https://images.openfoodfacts.org/images/products/433/561/909/4826/front_ru.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619094826', 'front_4335619094826'),
    ('Makłowicz i Synowie', 'Fettuccine w sosie pomidorowym z kurczakiem', 'https://images.openfoodfacts.org/images/products/590/564/403/1272/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905644031272', 'front_5905644031272'),
    ('Fit&Easy', 'Lunch Box Proteinowy', 'https://images.openfoodfacts.org/images/products/590/216/639/8029/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902166398029', 'front_5902166398029'),
    ('Asia Flavours', 'Tikka Masala', 'https://images.openfoodfacts.org/images/products/590/139/808/5462/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398085462', 'front_5901398085462'),
    ('Yeemy', 'Greek Style Wrap', 'https://images.openfoodfacts.org/images/products/590/779/901/6869/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907799016869', 'front_5907799016869'),
    ('Go Asia', 'Gyoza with beef', 'https://images.openfoodfacts.org/images/products/590/096/204/2214/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900962042214', 'front_5900962042214'),
    ('Graal', 'Szprot w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/501/0169/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010169', 'front_5903895010169')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Ready Meals' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
