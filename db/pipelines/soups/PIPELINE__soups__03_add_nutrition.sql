-- PIPELINE (Soups): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Soups'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Krakus', 'Zupa Żurek', 23.2, 0.5, 0.2, 0, 3.6, 3.3, 0, 0.7, 1.2),
    ('Auchan', 'Fasolka po bretońsku z kiełbasą i boczkiem.', 111.0, 4.7, 1.7, 0, 9.1, 1.0, 0, 6.5, 1.1),
    ('Łowicz', 'Kociołek węgierski', 56.0, 1.2, 0.3, 0, 7.1, 3.8, 0, 3.5, 1.4),
    ('Profi', 'Krupnik z mięsem wieprzowym', 35.0, 1.2, 0.5, 0, 4.6, 0.5, 0.5, 1.2, 1.0),
    ('Krakus', 'Barszcz biały koncentrat', 72.0, 3.4, 1.3, 0, 6.6, 4.2, 0, 2.5, 4.6),
    ('Profi', 'Zupa pomidorowa z mięsem wieprzowym', 41.0, 1.5, 0.5, 0, 5.2, 0.5, 0.5, 1.6, 1.2),
    ('Lewiatan', 'Fasolka po bretońsku', 66.0, 1.7, 0.7, 0, 7.8, 2.0, 0, 3.2, 1.2),
    ('Biedronka', 'Zupa kapuśniak z pomidorami', 27.0, 0.6, 0.1, 0, 3.0, 2.4, 0, 2.0, 0.6),
    ('Biedronka', 'Zupa kapuśniak', 32.0, 1.3, 0.4, 0, 2.4, 1.7, 0, 2.3, 0.7),
    ('Pudliszki', 'Fasolka po Bretońsku', 87.0, 2.9, 1.1, 0, 9.1, 3.2, 3.5, 4.3, 0.9),
    ('Pudliszki', 'Flaki wołowe w rosole', 56.0, 1.5, 0.6, 0, 1.5, 0.5, 0.5, 9.2, 1.3),
    ('Kuchnia Staropolska', 'Fasolka po bretońsku z kiełbasą', 96.0, 3.4, 1.4, 0, 10.0, 1.3, 0, 4.5, 1.0),
    ('Pudliszki', 'Flaki wołowe po zamojsku', 52.0, 1.4, 0.6, 0, 2.9, 0.9, 0.3, 6.9, 1.4),
    ('Unknown', 'Krem pomidorowo-paprykowy z ryżem', 393.0, 11.0, 7.4, 0, 58.0, 22.0, 9.1, 10.0, 2.5),
    ('Nasze Smaki', 'Żurek', 41.0, 0.0, 0.0, 0, 8.1, 0.2, 0.5, 1.3, 0.2),
    ('Pudliszki', 'Gulasz wieprzowo-wołowy', 163.0, 12.0, 0.8, 0, 4.6, 1.1, 0.3, 8.2, 0.8),
    ('Stoczek', 'Fasolka po bretońsku z dodatkiem kiełbasy', 66.0, 1.2, 0.3, 0, 9.8, 1.9, 0, 3.1, 1.2),
    ('Unknown', 'Flaczki królewskie wołowe', 52.0, 2.0, 0.9, 0, 1.7, 0.7, 0, 6.8, 1.3),
    ('Brzeziecki', 'Barszcz biały', 44.0, 0.5, 0.1, 0, 8.6, 0.6, 0, 1.0, 1.0),
    ('Brzeziecki', 'Żur Wiejski', 44.0, 0.5, 0.1, 0, 8.6, 0.6, 0, 1.0, 1.0),
    ('Rolnik', 'Żurek na zakwasie koncentrat', 52.0, 0.5, 0.1, 0, 11.0, 0.4, 0, 0.9, 0.4),
    ('Culineo', 'Flaki wołowe w rosole', 40.0, 0.8, 0.3, 0, 0.5, 0.5, 0.6, 7.9, 1.1),
    ('Pudliszki', 'Fasolka po bretońsku z kiełbasą', 115.0, 4.8, 0.1, 0, 13.0, 2.8, 2.0, 4.4, 0.9),
    ('M.E.A.L. Artea', 'Fasola po bretońsku', 107.0, 4.2, 1.2, 0, 11.0, 1.7, 0, 4.9, 1.2),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 56.0, 1.8, 0.2, 0, 6.3, 2.8, 1.1, 3.1, 0.1),
    ('Unknown', 'Żurek Aliny', 48.0, 0.2, 0.1, 0, 10.2, 0.2, 0.6, 1.1, 0.0),
    ('Ten Smak', 'Żurek staropolski', 42.0, 0.3, 0.1, 0, 10.6, 0.4, 0, 0.9, 0.0),
    ('Łowicz', 'Kociołek Orientalny', 68.0, 1.0, 0.3, 0, 10.4, 6.9, 0, 3.2, 1.5),
    ('Stoczek', 'Mięso wołowe z makaronem i boczkiem wędzonym w sosie pomidorowym', 79.0, 4.1, 1.5, 0, 6.8, 1.3, 0, 3.3, 1.2),
    ('Kuchnia Staropolska', 'Krupnik z mięsem drobiowym', 43.0, 0.5, 0.2, 0, 6.7, 0.5, 0, 2.5, 1.2),
    ('Łowicz', 'Fasolka po bretońsku z boczkiem i kiełbasą', 87.0, 2.5, 0.9, 0, 9.4, 2.9, 0, 4.5, 1.0),
    ('Farma świętokrzyska', 'Kapuśniak świętokrzyski', 43.0, 1.2, 1.0, 0, 6.5, 0.7, 1.3, 0.9, 0.3),
    ('Delikatna', 'Fasolka po bretońsku z ziemniakami', 112.0, 5.2, 0.4, 0, 13.0, 1.5, 0, 3.9, 0.2),
    ('Pamapol', 'Fasolka po bretońsku z boczkiem', 134.0, 8.1, 0, 0, 10.0, 0, 0, 3.9, 0),
    ('Rolnik', 'Fasolka po bretońsku z kiełbasą', 83.0, 3.2, 1.4, 0, 7.4, 2.0, 0, 4.1, 0.8),
    ('Carrefour Classic', 'Fasolka po bretońsku', 103.0, 4.4, 1.7, 0, 8.7, 3.2, 4.5, 5.0, 1.4),
    ('Herby', 'Fasolka Po Bretońsku z Kiełbasą', 94.0, 3.4, 0.9, 0, 8.7, 1.0, 0, 5.7, 1.2),
    ('Szubryt', 'Fasolka po bretońsku', 107.0, 4.8, 1.5, 0, 7.1, 1.5, 4.9, 6.3, 0.7),
    ('Primavika', 'Fasola a''la po bretońsku', 106.0, 0.9, 0.0, 0, 17.0, 4.1, 3.3, 6.1, 0.7),
    ('EdRED', 'Grochówka generalska', 177.0, 4.9, 2.1, 0, 9.7, 0.6, 0, 18.0, 0.9),
    ('Nestlé', 'Barszcz czerwony', 113.9, 1.1, 0.6, 0, 25.0, 19.2, 0.3, 1.1, 4.7),
    ('Jemy Jemy', 'Zupa krem z pomidorow', 41.0, 1.8, 1.1, 0, 4.9, 2.7, 0.8, 0.9, 1.2),
    ('Biedronka', 'Zupa krem z dyni', 26.0, 0.7, 0.3, 0, 3.9, 2.1, 0, 0.7, 0.7),
    ('Biedronka', 'Zupa Fasolowa z Pomidorami i Szpinakiem', 36.0, 0.5, 0.1, 0, 3.8, 2.5, 0, 2.2, 0.5),
    ('Jemy Jemy', 'Zupa krem z zielonego groszku', 56.0, 2.2, 0.2, 0, 5.7, 1.4, 2.1, 2.4, 1.0),
    ('Biedronka', 'Zupa pomidorowa', 34.0, 0.4, 0.1, 0, 5.9, 3.0, 2.0, 1.6, 0),
    ('Biedronka', 'Zupa grochowa', 73.0, 2.6, 1.1, 0, 7.0, 1.6, 0, 4.1, 0.7),
    ('Biedronka', 'Zupa koperkowa', 30.0, 1.4, 0.5, 0, 2.5, 1.8, 0, 1.3, 0.6),
    ('Urbanek', 'Cucumber soup with dill', 20.0, 0.2, 0.1, 0, 3.9, 1.0, 0, 0.5, 0.9),
    ('Słoik konesera', 'Klopsy w sosie pomidorowym', 88.0, 2.7, 1.0, 0, 8.9, 2.1, 0, 6.3, 1.4),
    ('Auchan', 'Pulpety w sosie pomidorowym', 85.0, 4.4, 1.5, 0, 5.8, 1.7, 0, 4.6, 0.9),
    ('Yabra', 'Zupa gulaszowa', 51.0, 1.3, 0.5, 0, 6.0, 0.5, 0, 3.8, 0.8),
    ('Pan Pomidor Lidl', 'Zupa marokańska', 45.0, 1.5, 0.0, 0, 5.1, 2.6, 2.4, 1.6, 0.8),
    ('Yabra', 'Fasolka po bretońsku', 91.0, 4.8, 1.8, 0, 9.0, 1.5, 0, 5.0, 1.0),
    ('Pan Pomidor', 'Zupa indyjska z soczewicą i gram masala', 90.0, 3.4, 1.3, 0, 8.5, 1.4, 3.5, 4.6, 0.6),
    ('Pan Pomidor', 'Zupa szczawiowa z ziemniakami', 21.0, 0.5, 0.1, 0, 3.2, 1.8, 1.2, 0.7, 1.0),
    ('Biedronka', 'Zupa Minestrone', 33.0, 0.4, 0.1, 0, 5.3, 2.1, 0, 1.5, 0.6),
    ('Culineo', 'Bulion warzywny', 91.0, 2.2, 0.2, 0, 15.0, 11.0, 1.4, 2.2, 16.4),
    ('Chef select', 'Zupa krem z pomidorów z bazylią', 43.0, 1.7, 0.1, 0, 5.1, 4.5, 0, 1.2, 0.8),
    ('Jemy JEMY', 'ZUPA TAJSKA Zupy Swiata', 62.0, 3.8, 1.5, 0, 5.0, 2.4, 0.9, 1.4, 0),
    ('Krakus', 'Barszcz czerwony', 34.0, 0.1, 0.1, 0, 7.1, 7.0, 0, 1.0, 1.1),
    ('Vifon', 'Bo tieu', 84.0, 4.1, 1.4, 0, 10.0, 0.0, 0, 1.6, 0.8),
    ('M.E.A.L.', 'Gulasz wieprzowy', 105.0, 6.7, 2.9, 0, 4.9, 1.0, 0, 6.2, 0),
    ('Kotwica', 'Krupnik', 88.0, 1.5, 0.4, 0, 16.3, 0.5, 0, 2.1, 3.3),
    ('Biedronka', 'Zupa jarzynowa', 29.0, 0.4, 0.1, 0, 4.7, 1.6, 0, 1.1, 0.6),
    ('Łowicz', 'Flaki po zamojsku', 47.0, 1.2, 0.5, 0, 2.2, 0.5, 0, 6.6, 1.4),
    ('Biedronka', 'Zupa krem pomidorowy', 26.0, 0.4, 0.0, 0, 4.0, 3.5, 0, 0.9, 0.7),
    ('Go vege', 'Strogonow roslinny', 53.0, 1.4, 0.1, 0, 5.3, 5.3, 2.6, 3.2, 1.2),
    ('Sorella', 'Zupa krem z dyni i mango', 35.0, 0.9, 0.8, 0, 6.0, 4.2, 0.5, 0.7, 1.2),
    ('Eat me', 'Zupa krem z pieczonej papryki i mascarpone', 52.0, 2.3, 1.1, 0, 6.7, 3.8, 0, 1.1, 0.8),
    ('Hortex', 'Zupa pomidorowa z makaronem', 138.0, 3.6, 0.1, 0, 21.3, 4.4, 1.6, 4.2, 1.4),
    ('Kucharek', 'Bulion warzywny', 5.0, 0.5, 0.2, 0, 0.5, 0.5, 0, 0.5, 1.0),
    ('Pan pomidor', 'Pomidorowa', 39.0, 0.7, 0.1, 0, 6.4, 5.0, 1.3, 1.2, 0),
    ('Chef Select', 'Żurek z białą kiełbasą i boczkiem', 43.0, 1.5, 0.5, 0, 5.1, 0.5, 0, 1.5, 1.1),
    ('Nestlé', 'Rosół drobiowy królewski', 2.5, 0.2, 0.1, 0, 0.1, 0.1, 0.0, 0.1, 0.5),
    ('Knorr', 'Rosół z kury', 6.0, 0.4, 0.3, 0, 0.3, 0.2, 0, 0.2, 0.9),
    ('Podravka', 'Vegeta Natur Rosół Wołowy', 62.5, 4.2, 2.1, 0, 4.2, 4.2, 0.0, 0.0, 9.4),
    ('Samyang', 'Buldak HOT Chicken Flavour Ramen Cheese Flavour', 397.0, 13.0, 5.0, 0, 61.0, 5.0, 2.0, 9.0, 3.0),
    ('Italiamo', 'Paradizniki suseni lidl', 138.0, 0.7, 0.2, 0.0, 20.0, 17.0, 6.0, 7.0, 6.6),
    ('Amino', 'Hühnersuppe mit Petersillie', 77.0, 3.5, 1.7, 0, 9.5, 0.5, 0, 1.4, 0.9),
    ('Chef Select', 'Zupa Inspiracja Tajska', 56.0, 3.5, 1.7, 0, 4.9, 2.0, 0, 1.6, 0.8),
    ('Knorr', 'Borowikowa z grzankami', 30.0, 1.3, 0.7, 0, 4.0, 0.5, 0.2, 0.5, 1.0),
    ('Bonduelle', 'Haricots blancs', 109.0, 3.2, 0.4, 0, 13.1, 5.8, 5.1, 4.3, 1.0),
    ('Freshona', 'Zupa kalafiorowa z koperkiem', 36.0, 0.2, 0.1, 0, 5.4, 2.3, 2.4, 1.9, 0.1),
    ('Knorr', 'Grochowa z grzankami', 38.0, 0.8, 0, 0, 5.6, 0, 0.6, 1.6, 0),
    ('Lidl', 'Lentil Soup Indian Style', 67.0, 2.6, 1.3, 0, 9.4, 3.3, 1.9, 2.6, 0.7),
    ('Knorr', 'Borscht, Instant', 300.0, 4.2, 3.3, 0, 63.3, 41.7, 4.2, 4.2, 3.5),
    ('Nestlé', 'Bulion drobiowy', 6.0, 0.3, 0.1, 0, 0.5, 0.4, 0, 0.2, 0.8),
    ('Kania', 'Hühnerbrühe', 4.0, 0.5, 0.1, 0, 0.7, 0.6, 0.0, 0.5, 1.1),
    ('Knorr', 'Danie puree', 87.0, 2.6, 0.9, 0, 12.0, 1.6, 2.0, 3.1, 0),
    ('Chef Select Lidl', 'Zupa grochowa z boczkiem i tymiankiem', 51.1, 0.9, 0.2, 0, 5.3, 1.3, 0, 3.1, 0.9),
    ('Chef Select Lidl', 'Zupa Inspiracja Wietnamska', 67.1, 4.7, 2.0, 0, 5.4, 0.2, 0, 1.4, 1.0),
    ('Knorr', 'Kremowa zupa z kurek ze szczypiorkiem', 58.0, 3.6, 2.2, 0, 5.4, 0.7, 0.5, 0.8, 0.8)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Soups' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
