-- PIPELINE (Sauces): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Sauces'
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
    ('Pudliszki', 'Po Bolońsku sos do spaghetti', 53.0, 0.6, 0.1, 0, 9.2, 6.3, 2.0, 1.7, 1.2),
    ('Culineo', 'Sos meksykański', 65.0, 0.5, 0.1, 0, 12.0, 9.0, 1.8, 1.8, 1.4),
    ('Dawtona', 'Sos do spaghetti pomidorowo-śmietankowy', 57.0, 1.9, 0.6, 0, 8.6, 4.0, 0.5, 1.1, 1.3),
    ('Dawtona', 'Sos Neapolitański z papryką', 58.0, 0.5, 0.1, 0, 12.0, 7.9, 0.7, 1.0, 1.5),
    ('Dawtona', 'Sos Boloński z ziołami', 73.0, 0.5, 0.1, 0, 16.0, 10.0, 0.5, 1.0, 2.0),
    ('Dawtona', 'Sos meksykański', 70.0, 0.6, 0.1, 0, 14.0, 9.1, 1.1, 1.6, 1.8),
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 85.0, 0.5, 0.0, 0, 19.0, 16.0, 0.7, 0.7, 0.8),
    ('Polskie Przetwory', 'Sos Boloński z bazylią', 51.0, 0.5, 0.1, 0, 10.3, 6.5, 0, 1.0, 1.3),
    ('Międzychód', 'Sos Boloński z mięsem', 65.0, 2.2, 1.0, 0, 8.0, 5.5, 0, 3.8, 1.3),
    ('Roleski', 'Sos tysiąca wysp', 345.0, 33.0, 4.9, 0, 11.0, 9.3, 0, 1.2, 1.6),
    ('Heinz', 'Sos tysiąca wysp', 399.0, 36.0, 3.0, 0, 15.0, 14.0, 0, 2.2, 1.2),
    ('Heinz', 'Sos Barbecue. Sos do grilla z cebulą i papryką', 142.0, 0.2, 0.0, 0, 34.0, 30.0, 0, 0.8, 2.4),
    ('Fanex', 'Sos meksykański', 88.0, 0.5, 0.1, 0, 20.0, 18.0, 0, 1.2, 1.3),
    ('Łowicz', 'Sos Boloński', 42.0, 1.1, 0.1, 0, 6.5, 6.0, 0, 0.9, 0.0),
    ('Culineo', 'Sos boloński', 53.0, 0.8, 0.1, 0, 8.8, 7.7, 0, 1.6, 1.6),
    ('Dawtona', 'Sos do pizzy z ziołami', 32.0, 0.0, 0.0, 0, 6.3, 4.4, 1.1, 1.2, 0.6),
    ('Roleski', 'Sos pomidor + miód + limonka + nasiona chia', 107.0, 0.5, 0.1, 0, 23.0, 21.0, 0, 1.5, 2.1),
    ('Pudliszki', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', 73.0, 3.5, 0.4, 0, 9.3, 6.0, 1.3, 1.1, 0.9),
    ('Fanex', 'Sos tysiąc wysp', 301.0, 28.0, 0, 0, 10.0, 6.9, 0, 1.1, 1.2),
    ('Vital FRESH', 'Sałatka w stylu greckim', 136.0, 12.0, 3.7, 0, 3.0, 2.6, 1.0, 3.2, 0.8),
    ('Vifon', 'Sos chili tajski słodko-pikantny', 138.0, 0.0, 0.0, 0, 34.0, 31.0, 0, 0.0, 1.7),
    ('Sottile Gusto', 'Passata z czosnkiem', 32.0, 0.5, 0.1, 0, 4.6, 4.3, 0, 1.8, 0.2),
    ('Sottile Gusto', 'Passata', 30.9, 0.5, 0.1, 0, 4.3, 4.2, 0, 1.7, 0.2),
    ('Dawtona', 'Sos Pomidorowy do Makaronu', 52.0, 0.6, 0.1, 0, 10.0, 7.2, 0.5, 1.2, 1.1),
    ('Międzychód', 'Sos pomidorowy', 60.0, 0.9, 0.1, 0, 12.0, 8.5, 0, 1.3, 1.1),
    ('Dawtona', 'Sos Curry', 152.0, 0.0, 0.0, 0, 37.0, 32.0, 0.9, 0.6, 2.6),
    ('Carrefour', 'Przecier pomidorowy', 24.0, 0.5, 0, 0, 3.6, 3.5, 0.9, 1.4, 0.0),
    ('Culineo', 'SOS Spaghetti', 95.0, 1.0, 0.1, 0, 19.0, 7.3, 0, 1.8, 1.0),
    ('Develey', 'Sos 1000 wysp', 271.0, 25.0, 1.9, 0, 11.0, 9.0, 0.6, 0.7, 1.0),
    ('Madero', 'Sos jogurtowy z ziołami', 61.0, 1.1, 0.6, 0, 9.8, 9.7, 0.9, 2.7, 0),
    ('Go Vege', 'Sos z jalapeño', 278.0, 25.0, 1.8, 0, 12.0, 7.4, 0.6, 0.5, 1.5),
    ('Biedronka', 'Sos z chili', 269.0, 25.0, 1.8, 0, 10.0, 6.2, 0.6, 0.5, 1.6),
    ('Vifon', 'Sos chili pikantny', 107.0, 0.5, 0.0, 0, 25.0, 24.0, 0, 0.7, 5.5),
    ('Develey', 'Sos jalapeño', 67.0, 0.5, 0.1, 0, 13.0, 12.0, 0, 1.7, 2.0),
    ('Dawtona', 'Sos BBQ', 128.0, 0.0, 0.0, 0, 32.0, 26.0, 0.0, 0.0, 2.2),
    ('Madero', 'Sos BBQ z chipotle', 138.0, 0.5, 0.1, 0, 32.0, 29.0, 0.0, 0.0, 0.3),
    ('Łowicz', 'Sos Spaghetti', 81.0, 2.0, 0.2, 0, 14.0, 12.0, 0, 1.6, 1.1),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 59.0, 1.0, 0.1, 0, 9.0, 7.1, 0, 1.7, 1.0),
    ('Dawtona', 'Passata rustica', 34.0, 0.2, 0.1, 0, 5.5, 3.8, 2.0, 1.3, 0.3),
    ('Pudliszki', 'Przecier pomidorowy', 33.0, 0.3, 0.1, 0, 5.7, 4.0, 0.8, 1.4, 0.5),
    ('Łowicz', 'Leczo', 57.0, 1.8, 0, 0, 7.4, 7.3, 0, 1.6, 0),
    ('Roleski', 'Avocaboo!', 107.0, 0.6, 0.1, 0, 23.0, 20.0, 0, 1.3, 1.7),
    ('Sottile Gusto', 'Przecier pomidorowy', 30.0, 0.2, 0.1, 0, 5.2, 5.2, 0, 1.4, 0.0),
    ('Jamar', 'Passata - przecier pomidorowy klasyczny', 33.0, 0.5, 0.1, 0, 4.9, 4.6, 2.1, 1.4, 0.0),
    ('Roleski', 'Sos do kurczaka z czosnkiem', 79.0, 0.5, 0.1, 0, 18.0, 14.0, 0, 0.8, 2.6),
    ('Rolnik', 'Passata', 35.0, 0.3, 0.0, 0, 4.9, 4.0, 0, 1.7, 0.6),
    ('GustoBello', 'Arrabbiata Bruschetta', 190.0, 16.7, 1.8, 0, 6.4, 6.4, 2.7, 1.7, 1.6),
    ('Helcom', 'Dip in mexicana style', 52.0, 0.0, 0.0, 0, 11.0, 8.9, 1.0, 1.4, 1.0),
    ('Roleski', 'Sos pomidor + czarnuszka ostry', 80.0, 1.2, 0.1, 0, 15.0, 11.0, 0, 1.5, 2.0),
    ('Roleski', 'Sos pomidor + jagody goji', 110.0, 0.5, 0.1, 0, 25.0, 24.0, 0, 1.5, 1.4),
    ('MW Food', 'Sauce tomate', 51.0, 1.2, 0.1, 0, 7.8, 5.9, 0.0, 1.5, 1.0),
    ('Pudliszki', 'Bolonski', 70.0, 2.3, 0.6, 0, 8.0, 4.7, 1.1, 3.6, 1.3),
    ('Biedronka', 'Pesto Zielone. Sos na bazie bazyli', 401.0, 39.0, 5.3, 0, 7.6, 3.2, 2.2, 4.7, 2.0),
    ('GustoBello', 'White wine vinegar cream with pesto alla genovese', 180.0, 3.2, 0.6, 0, 37.0, 31.0, 0.6, 0.5, 0.9),
    ('Kucharek', 'Kucharek', 144.0, 0.1, 0.1, 0, 25.0, 16.0, 0, 7.9, 25.0),
    ('Roleski', 'Sos vinaigrette', 44.0, 4.5, 0.3, 0, 0.6, 0.0, 0, 0.0, 2.5),
    ('Knorr', 'Sos sałatkowy paprykowo-ziołowy', 424.0, 45.0, 6.5, 0, 4.8, 3.8, 0.7, 0.5, 2.2),
    ('Madero', 'Sos chilli pikantny', 83.0, 0.3, 0.0, 0, 17.4, 15.0, 0, 1.2, 2.0),
    ('Asia Flavours', 'Sos Sriracha mayo', 240.0, 20.2, 3.1, 0, 13.8, 11.1, 0.5, 0.8, 2.9),
    ('House of asia', 'Sos Sriracha', 152.0, 0.4, 0.1, 0, 35.0, 25.0, 0, 1.2, 5.8),
    ('Asia Flavours', 'Sos Sambal Oelek', 47.0, 0.6, 0.2, 0, 8.7, 1.7, 0, 1.7, 9.9),
    ('House of Asia', 'Sos z Czarnym Pieprzem', 93.0, 1.9, 0.0, 0, 16.0, 6.0, 0, 3.0, 7.0),
    ('Madero', 'Sos BBQ z miodem gryczanym', 126.0, 0.5, 0.1, 0, 29.0, 26.0, 0.8, 1.0, 2.4),
    ('Roleski', 'BBQ sos whisky', 174.0, 0.5, 0.1, 0, 43.0, 40.0, 0.0, 0.5, 1.5),
    ('Roleski', 'Texas sos BBQ', 189.0, 0.0, 0.0, 0, 45.0, 42.0, 0, 1.3, 1.8),
    ('Kotlin', 'Sos BBQ', 138.0, 0.5, 0.1, 0, 32.0, 31.0, 0, 1.8, 1.7),
    ('Jamar', 'Passata klasyczna', 32.0, 0.5, 0.1, 0, 5.9, 5.4, 0.9, 1.4, 0.2),
    ('Waldi Ben', 'Koncentrat pomidorowy 30%', 100.0, 1.0, 0.5, 0, 18.0, 18.0, 0, 5.2, 0.3),
    ('Winiary', 'Spaghetti sos z pomidorów', 49.6, 0.9, 0.2, 0, 7.4, 6.7, 1.4, 1.8, 1.3),
    ('Pingo Doce', 'Sos pomidorowy z bazylią', 78.0, 5.0, 0.6, 0, 5.5, 5.1, 2.5, 1.6, 0.6),
    ('Podravka', 'Przecier pomidorowy z bazylią', 32.0, 0.3, 0.1, 0, 5.8, 5.2, 0, 1.4, 0.9),
    ('HELCOM', 'Sauce a la mexicaine', 52.0, 0.0, 0.0, 0, 11.0, 8.9, 1.0, 1.4, 1.0),
    ('Dawtona', 'Sos pomidorowy ostry z papryczkami jalapeño', 60.0, 0.9, 0.1, 0, 10.0, 7.9, 1.0, 1.6, 1.1),
    ('Schedro', 'Sos Chersoński', 73.0, 0.0, 0.0, 0, 17.0, 13.0, 0, 1.0, 2.5),
    ('Unknown', 'Pesto all Genovese', 527.0, 53.0, 7.6, 0, 6.7, 2.1, 0, 4.8, 1.5),
    ('Pure Line', 'Sos jogurtowy z czosnkiem', 71.0, 1.1, 0.6, 0, 12.0, 11.0, 0, 2.9, 0),
    ('Asia Flavours', 'Sos Sriracha', 136.0, 0.0, 0.0, 0, 33.0, 26.0, 0, 1.1, 7.5),
    ('Develey', 'Sos Mayo Sriracha z chili i czosnkiem', 260.0, 20.0, 1.7, 0, 18.0, 14.0, 0, 1.0, 1.9),
    ('Heinz', 'słodki sos barbecue', 181.0, 0.2, 0.0, 0, 44.0, 39.0, 0, 0.9, 1.1),
    ('Winiary', 'Sos amerykański BBQ', 110.0, 0.5, 0.1, 0, 24.0, 23.0, 1.1, 1.9, 2.2),
    ('Roleski', 'Sos BBQ dark beer', 167.0, 0.5, 0, 0, 38.0, 35.0, 0, 0.9, 2.5),
    ('Italiamo', 'Sugo al pomodoro con basilico', 36.0, 0.1, 0.0, 0, 6.4, 5.7, 0, 1.7, 0.5),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 51.0, 2.3, 0.4, 0, 5.5, 4.7, 1.3, 1.3, 0.9),
    ('Auchan', 'Passata con basilico', 31.0, 0.1, 0, 0, 6.0, 3.9, 0.8, 1.1, 0.3),
    ('mondo italiano', 'passierte Tomaten', 29.0, 0.2, 0.0, 0, 4.6, 2.9, 0.0, 1.2, 0.0),
    ('Combino', 'Sauce tomate bio à la napolitaine', 51.0, 0.9, 0.2, 0, 8.4, 6.6, 0, 1.3, 1.6),
    ('Extra Line', 'Passata garlic', 38.0, 0.2, 0.1, 0, 6.1, 4.0, 2.1, 1.5, 0.3),
    ('Carrefour', 'Tomates basilic', 47.0, 1.2, 0.1, 0, 6.9, 5.1, 2.0, 1.2, 0.9),
    ('Baresa', 'Pesto alla Genovese', 364.0, 35.9, 1.5, 0, 4.8, 1.0, 1.0, 4.1, 0.7),
    ('Barilla', 'Pesto alla Genovese', 492.0, 47.0, 5.3, 0, 11.0, 5.0, 3.0, 4.7, 3.2),
    ('Carrefour', 'Pesto verde', 447.0, 46.0, 6.6, 0, 3.2, 1.8, 4.2, 2.6, 1.7),
    ('Go Vege', 'Pesto z tofu', 238.0, 22.2, 2.7, 0, 3.2, 1.6, 3.7, 4.5, 2.0),
    ('Deluxe', 'Pesto con rucola', 273.0, 25.0, 3.7, 0, 7.3, 2.8, 2.5, 3.4, 2.1),
    ('Heinz', 'Sauce Salade Caesar', 442.0, 44.7, 7.3, 0, 8.3, 7.7, 0, 1.5, 2.1),
    ('Sol & Mar', 'Piri-Piri', 16.0, 0.8, 0.2, 0, 0.9, 0.5, 1.6, 0.6, 5.3),
    ('Kikkoman', 'Kikkoman Sojasauce', 77.0, 0.0, 0.0, 0, 3.2, 0.6, 0.0, 10.0, 16.9),
    ('Mutti', 'Passierte Tomaten', 36.0, 0.5, 0.1, 0, 5.1, 4.5, 0, 1.6, 0.5),
    ('gustobello', 'Passata', 28.0, 0.1, 0, 0, 4.1, 3.5, 1.8, 1.4, 0.0),
    -- ── Batch 2 — sauces (new) ───────────────────────────────────────────────────────
    ('Gustobello',      'Passata',          28, 0.1, 0.02, 0, 4.1, 3.5, 1.8, 1.4, 0.01),   -- OFF
    ('Helcom',          'Sauce a la mexicaine', 52, 0, 0, 0, 11, 8.9, 1.0, 1.4, 1.0),       -- OFF
    ('Mondo Italiano',  'Passierte Tomaten', 30, 0.2, 0.05, 0, 4.5, 4.0, 0.5, 1.3, 0.10)    -- OFF
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Sauces' and p.is_deprecated is not true
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
