-- PIPELINE (Ready Meals): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-13

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Go Active', 'Kuskus Perłowy', 'Biedronka'),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 'Biedronka'),
    ('Swojska Chata', 'Krokiety z mięsem', 'Biedronka'),
    ('Vital Fresh', 'Sałatka lunchbox', 'Biedronka'),
    ('Nasze Smaki', 'Pierogi z mięsem', 'Biedronka'),
    ('Dr. Peter', 'Pizza Guseppe z szynką i pieczarkami głęboko mrożona', 'Dino'),
    ('Auchan', 'Pierogi z Mięsem', 'Auchan'),
    ('Nasze Smaki', 'Naleśniki z serem', 'Biedronka'),
    ('Rośl-inne', 'Rośl-inne Kabanosy Piri-Piri', 'Kaufland'),
    ('Rośl-inne', 'Rośl-inne Kabanosy Piri-Piri', 'Carrefour'),
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 'Tesco'),
    ('Nasze smaki', 'Kotlet drobiowy z puree i marchewką z groszkiem', 'Biedronka'),
    ('Auchan', 'Surówka Colesław', 'Auchan'),
    ('Auchan', 'Pierogi ukraińskie', 'Auchan'),
    ('U Jedrusia', 'Placki Ziemniaczane z gulaszem wieprzowym po węgiersku', 'Kaufland'),
    ('Cedrob', 'Skrzydełka z kurczaka w marynacie buffalo', 'Dino'),
    ('Auchan', 'Pasta łososiowa ze szczypiorkiem', 'Auchan'),
    ('Vital Fresh', 'Surówka Smakołyk', 'Biedronka'),
    ('Asia Flavours', 'Pierożki Gyoza z warzywami', 'Biedronka'),
    ('Go Active', 'Kuskus perłowy z ciecierzycą, fasolką i hummusem', 'Biedronka'),
    ('Biedronka', 'Pizza z szynką wieprzową i pieczarkami', 'Biedronka'),
    ('Smacznego!', 'Sałatka bulgur z sosem pomidorowo-paprykowym', 'Biedronka'),
    ('GO Active', 'Kuskus perłowy z suszoną śliwką, mango i hummusem', 'Biedronka'),
    ('Perla', 'Sałatka bulgur', 'Biedronka'),
    ('Dega', 'Sałatka jarzynowa', 'Dino'),
    ('Nasze Smaki', 'Mięsny przysmak', 'Biedronka'),
    ('Łowicz', 'Kaszotto z kukurydzą i fasolką', 'Lewiatan'),
    ('Swojska Chata', 'Kapusta kiszona z marchewką', 'Biedronka'),
    ('Grześkowiak', 'Sałatka makaronowa z brokułami i ogórkiem', 'Lewiatan'),
    ('Lisner', 'Sałatka warzywna z jajkiem', 'Biedronka'),
    ('Nasze Smaki', 'Pierogi ruskie', 'Biedronka'),
    ('Donatello', 'Lasagne z kurczakiem', 'Biedronka'),
    ('Swojska Chata', 'Pierogi ze szpinakiem i serem', 'Biedronka'),
    ('Lisner', 'Vegetable salad with eggs', 'Biedronka'),
    ('Yeemy', 'Italian style wrap', 'Biedronka'),
    ('Go Active', 'Kurczak z puree marchewkowym', 'Biedronka'),
    ('Swojska Chata', 'Pierogi z serem', 'Biedronka'),
    ('Dr. Oetker', 'Pizza Guseppe Chicken Curry', 'Tesco'),
    ('Dr. Oetker', 'Pizza Giuseppe kebab', 'Dino'),
    ('Unknown', 'Salatka kuskus', 'Żabka'),
    ('Auchan', 'Pierogi z serem i szpinakiem', 'Auchan'),
    ('Swojska Chata', 'Pierogi serowo- jagodowe', 'Biedronka'),
    ('Heinz', '5 rodzajów fasoli w sosie pomidorowym', 'Lidl'),
    ('Heinz', '5 rodzajów fasoli w sosie pomidorowym', 'Kaufland'),
    ('Konspol', 'Zöldséges gyoza', 'Aldi'),
    ('Chef Select', 'Kotlet De Volatile Z Puree Ziemniaczanym I Marchewką Z Groszkiem', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Ready Meals' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
