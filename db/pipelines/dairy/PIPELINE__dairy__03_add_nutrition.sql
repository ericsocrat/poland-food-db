-- PIPELINE (Dairy): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Dairy'
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
    ('Piątnica', 'Twój Smak Serek śmietankowy', 243.0, 23.0, 15.0, 0, 3.0, 3.0, 0.0, 6.0, 0.7),
    ('Mlekpol', 'Łaciate 3,2%', 60.0, 3.2, 2.0, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Piątnica', 'Twaróg wiejski półtłusty', 115.0, 4.0, 2.4, 0, 3.8, 3.8, 0, 16.0, 0.1),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 66.0, 0.0, 0, 0, 3.8, 3.8, 0, 12.0, 0.1),
    ('Mleczna Dolina', 'Mleko Świeże 2,0%', 50.0, 2.0, 1.2, 0, 4.8, 4.8, 0, 3.3, 0.1),
    ('Biedronka', 'Kefir naturalny 1,5 % tłuszczu', 44.0, 1.5, 1.1, 0, 4.5, 3.4, 0, 3.2, 0.1),
    ('Piątnica', 'Skyr z mango i marakują', 78.0, 0.0, 0.0, 0, 10.0, 10.0, 0, 9.6, 0.1),
    ('Wieluń', 'Twarożek "Mój ulubiony"', 273.0, 26.0, 18.0, 0, 3.7, 3.7, 0, 6.0, 0.2),
    ('Piątnica', 'Śmietana 18%', 191.0, 18.0, 11.0, 0, 4.8, 3.6, 0.0, 2.5, 0.1),
    ('Sierpc', 'Ser królewski', 352.0, 27.0, 18.0, 0, 1.2, 0.0, 0, 26.0, 1.4),
    ('Piątnica', 'Mleko wieskie świeże 2%', 50.0, 2.0, 1.3, 0, 4.8, 4.8, 0, 3.2, 0.1),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 50.0, 2.0, 1.3, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Almette', 'Serek Almette z ziołami', 238.0, 22.0, 15.0, 0, 3.1, 3.0, 0, 7.0, 0.6),
    ('Mlekpol', 'Świeże mleko', 60.0, 3.2, 2.0, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Delikate', 'Twarożek grani klasyczny', 115.0, 7.0, 4.5, 0, 2.0, 2.0, 0.0, 11.0, 0.7),
    ('Zott', 'Primo śmietanka 30%', 293.0, 30.0, 20.1, 0, 3.4, 3.4, 0, 2.3, 0.1),
    ('Gostyńskie', 'Mleko zagęszczone słodzone', 322.0, 8.0, 4.8, 0, 55.0, 55.0, 0, 7.3, 0.3),
    ('Piątnica', 'Twarożek Domowy grani naturalny', 115.0, 7.0, 4.6, 0, 2.0, 2.0, 0, 11.0, 0.7),
    ('SM Gostyń', 'Kajmak masa krówkowa gostyńska', 291.0, 7.2, 4.3, 0, 50.0, 50.0, 0, 6.6, 0.2),
    ('Piątnica', 'Koktail Białkowy malina & granat', 87.5, 1.2, 0.7, 0, 9.0, 9.0, 0, 10.2, 0.0),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', 147.0, 5.8, 3.8, 0, 20.3, 13.4, 0, 2.9, 0.1),
    ('Hochland', 'Ser żółty w plastrach Gouda', 352.0, 28.0, 20.0, 0, 0.0, 0.0, 0, 25.0, 1.5),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 60.0, 3.2, 2.1, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 82.0, 0.0, 0.0, 0, 11.0, 11.0, 0, 9.6, 0.1),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 80.0, 1.5, 1.5, 0, 10.0, 10.0, 0, 6.5, 0.1),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 78.0, 1.5, 1.1, 0, 9.5, 9.0, 0, 6.5, 0.1),
    ('Piątnica', 'Skyr Wanilia', 78.0, 1.5, 1.1, 0, 9.5, 9.0, 0, 6.5, 0.1),
    ('Robico', 'Kefir Robcio', 43.0, 1.5, 1.0, 0, 4.2, 4.2, 0, 3.1, 0.0),
    ('Piątnica', 'Skyr Naturalny', 42.7, 0.0, 0.0, 0, 4.1, 4.1, 0, 12.0, 0.1),
    ('Piątnica', 'Soured cream 18%', 192.0, 18.0, 12.0, 0, 4.8, 4.5, 0, 2.7, 0.1),
    ('Zott', 'Jogurt naturalny', 67.0, 3.1, 2.1, 0, 4.0, 4.0, 0, 4.8, 0.2),
    ('Mlekpol', 'Mleko UHT 2%', 50.0, 2.0, 1.2, 0, 4.8, 4.8, 0, 3.3, 0.1),
    ('Almette', 'Puszysty Serek Jogurtowy', 260.0, 24.0, 16.0, 0, 4.0, 4.0, 0, 7.1, 0.5),
    ('Spółdzielnia Mleczarska Ryki', 'Ser Rycki Edam kl.I', 360.0, 28.0, 19.0, 0, 2.0, 0, 0, 27.0, 1.1),
    ('Mleczna Dolina', 'Mleko 1,5% bez laktozy', 44.0, 1.5, 1.0, 0, 4.7, 4.7, 0, 3.0, 0.1),
    ('Mlekovita', 'Mleko UHT 3,2%', 60.0, 3.2, 2.1, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Piątnica', 'Icelandic type yoghurt natural', 64.0, 0.0, 0.0, 0, 4.1, 4.1, 0, 12.0, 0.2),
    ('Favita', 'Favita', 230.0, 18.0, 11.0, 0, 4.0, 4.0, 0, 10.0, 3.0),
    ('Almette', 'Almette z chrzanem', 250.0, 23.0, 16.0, 0, 4.0, 3.4, 0.0, 6.8, 1.0),
    ('Mlekovita', 'Mleko 2%', 50.0, 2.0, 1.3, 0, 4.7, 4.7, 0.0, 3.2, 0.1),
    ('Mleczna Dolina', 'Mleko 1,5%', 44.0, 1.5, 1.0, 0, 4.7, 4.7, 0, 3.0, 0.1),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 130.0, 6.3, 4.3, 0, 12.0, 6.3, 0, 6.3, 0.1),
    ('Mlekovita', 'Jogurt Grecki naturalny', 124.0, 10.0, 6.5, 0, 5.0, 5.0, 0.0, 3.6, 0.1),
    ('Delikate', 'Delikate Serek Smetankowy', 243.0, 23.0, 15.0, 0, 3.0, 3.0, 0.0, 6.0, 0.7),
    ('Mleczna Dolina', 'Śmietana', 188.0, 18.0, 12.3, 0, 3.1, 3.1, 0, 2.6, 0.1),
    ('OSM Łowicz', 'Mleko UHT 3,2', 60.0, 3.2, 1.9, 0, 4.7, 4.7, 0, 3.0, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Dairy' and p.is_deprecated is not true
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
