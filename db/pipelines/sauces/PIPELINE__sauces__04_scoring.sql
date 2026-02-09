-- PIPELINE (Sauces): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Pudliszki', 'Po Bolońsku sos do spaghetti', 1),
    ('Culineo', 'Sos meksykański', 1),
    ('Dawtona', 'Sos do spaghetti pomidorowo-śmietankowy.', 0),
    ('Dawtona', 'Sos Neapolitański z papryką', 0),
    ('Dawtona', 'Sos Boloński z ziołami', 1),
    ('Dawtona', 'Sos meksykański', 0),
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 1),
    ('Polskie Przetwory', 'Sos Boloński z bazylią', 2),
    ('Międzychód', 'Sos Boloński z mięsem', 0),
    ('Roleski', 'Sos tysiąca wysp', 3),
    ('Heinz', 'Sos tysiąca wysp', 3),
    ('Heinz', 'Sos Barbecue. Sos do grilla z cebulą i papryką', 2),
    ('Fanex', 'Sos meksykański', 5),
    ('Łowicz', 'Sos Boloński', 0),
    ('Culineo', 'Sos boloński', 1),
    ('Dawtona', 'Sos do pizzy z ziołami', 0),
    ('Roleski', 'Sos pomidor + miód + limonka + nasiona chia', 0),
    ('Pudliszki', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', 0),
    ('Fanex', 'Sos tysiąc wysp', 0),
    ('Vital FRESH', 'Sałatka w stylu greckim', 0),
    ('Vifon', 'Sos chili tajski słodko-pikantny', 3),
    ('Sottile Gusto', 'Passata z czosnkiem', 1),
    ('Sottile Gusto', 'Passata', 1),
    ('Dawtona', 'Sos Pomidorowy do Makaronu', 1),
    ('Międzychód', 'Sos pomidorowy', 0),
    ('Dawtona', 'Sos Curry', 2),
    ('Carrefour', 'Przecier pomidorowy', 0),
    ('Culineo', 'SOS Spaghetti', 2),
    ('Develey', 'Sos 1000 wysp', 2),
    ('Madero', 'Sos jogurtowy z ziołami', 0),
    ('Go Vege', 'Sos z jalapeño', 1),
    ('Biedronka', 'Sos z chili', 1),
    ('Vifon', 'Sos chili pikantny', 4),
    ('Develey', 'Sos jalapeño', 2),
    ('Dawtona', 'Sos BBQ', 0),
    ('Madero', 'Sos BBQ z chipotle', 2),
    ('ŁOWICZ', 'Sos Spaghetti', 2),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 1),
    ('Łowicz', 'Sos Spaghetti', 2),
    ('Dawtona', 'Passata rustica', 0),
    ('Pudliszki', 'Przecier pomidorowy', 1),
    ('Łowicz', 'Leczo', 0),
    ('Roleski', 'Avocaboo!', 1),
    ('Sottile Gusto', 'Przecier pomidorowy', 0),
    ('Jamar', 'Passata - przecier pomidorowy klasyczny', 0),
    ('Roleski', 'Sos do kurczaka z czosnkiem', 1),
    ('Rolnik', 'Passata', 1),
    ('GustoBello', 'Arrabbiata Bruschetta', 1),
    ('Helcom', 'Dip in mexicana style', 1),
    ('Roleski', 'Sos pomidor + czarnuszka ostry', 1),
    ('Roleski', 'Sos pomidor + jagody goji', 0),
    ('MW Food', 'Sauce tomate', 0),
    ('Pudliszki', 'Bolonski', 0),
    ('Biedronka', 'Pesto Zielone. Sos na bazie bazyli.', 2),
    ('GustoBello', 'White wine vinegar cream with pesto alla genovese', 1),
    ('Kucharek', 'Kucharek', 2),
    ('Develey', 'Sos 1000 Wysp', 1),
    ('Roleski', 'Sos vinaigrette', 4),
    ('Knorr', 'Sos sałatkowy paprykowo-ziołowy', 2),
    ('Madero', 'Sos chilli pikantny', 0),
    ('Asia Flavours', 'Sos Sriracha mayo', 3),
    ('House of asia', 'Sos Sriracha', 4),
    ('Asia Flavours', 'Sos Sambal Oelek', 2),
    ('House of Asia', 'Sos z Czarnym Pieprzem', 3),
    ('Madero', 'Sos BBQ z miodem gryczanym', 0),
    ('Roleski', 'BBQ sos whisky', 0),
    ('Roleski', 'Texas sos BBQ', 1),
    ('Kotlin', 'Sos BBQ', 0),
    ('Jamar', 'Passata klasyczna', 0),
    ('Waldi Ben', 'Koncentrat pomidorowy 30%', 0),
    ('Winiary', 'Spaghetti sos z pomidorów', 0),
    ('Pingo Doce', 'Sos pomidorowy z bazylią', 3),
    ('Podravka', 'Przecier pomidorowy z bazylią', 0),
    ('HELCOM', 'Sauce a la mexicaine', 0),
    ('Dawtona', 'Sos pomidorowy ostry z papryczkami jalapeño', 0),
    ('Schedro', 'Sos Chersoński', 3),
    ('Unknown', 'Pesto all Genovese', 0),
    ('Pure Line', 'Sos jogurtowy z czosnkiem', 0),
    ('Asia Flavours', 'Sos Sriracha', 0),
    ('Develey', 'Sos Mayo Sriracha z chili i czosnkiem', 0),
    ('Heinz', 'słodki sos barbecue', 1),
    ('Winiary', 'Sos amerykański BBQ', 0),
    ('Roleski', 'Sos BBQ dark beer', 0),
    ('Italiamo', 'Sugo al pomodoro con basilico', 0),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 0),
    ('Auchan', 'Passata con basilico', 0),
    ('mondo italiano', 'passierte Tomaten', 0),
    ('Combino', 'Sauce tomate bio à la napolitaine', 0),
    ('Extra Line', 'Passata garlic', 0),
    ('Carrefour', 'Tomates basilic', 2),
    ('Baresa', 'Pesto alla Genovese', 1),
    ('Barilla', 'Pesto alla Genovese', 1),
    ('Carrefour', 'Pesto verde', 3),
    ('Go Vege', 'Pesto z tofu', 3),
    ('Deluxe', 'Pesto con rucola', 3),
    ('Heinz', 'Sauce Salade Caesar', 5),
    ('Sol & Mar', 'Piri-Piri', 7),
    ('Kikkoman', 'Kikkoman Sojasauce', 0),
    ('Mutti', 'Passierte Tomaten', 0),
    ('gustobello', 'Passata', 0)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Pudliszki', 'Po Bolońsku sos do spaghetti', 'B'),
    ('Culineo', 'Sos meksykański', 'C'),
    ('Dawtona', 'Sos do spaghetti pomidorowo-śmietankowy.', 'C'),
    ('Dawtona', 'Sos Neapolitański z papryką', 'C'),
    ('Dawtona', 'Sos Boloński z ziołami', 'C'),
    ('Dawtona', 'Sos meksykański', 'C'),
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', 'C'),
    ('Polskie Przetwory', 'Sos Boloński z bazylią', 'C'),
    ('Międzychód', 'Sos Boloński z mięsem', 'C'),
    ('Roleski', 'Sos tysiąca wysp', 'D'),
    ('Heinz', 'Sos tysiąca wysp', 'D'),
    ('Heinz', 'Sos Barbecue. Sos do grilla z cebulą i papryką', 'E'),
    ('Fanex', 'Sos meksykański', 'C'),
    ('Łowicz', 'Sos Boloński', 'A'),
    ('Culineo', 'Sos boloński', 'C'),
    ('Dawtona', 'Sos do pizzy z ziołami', 'C'),
    ('Roleski', 'Sos pomidor + miód + limonka + nasiona chia', 'D'),
    ('Pudliszki', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', 'A'),
    ('Fanex', 'Sos tysiąc wysp', 'UNKNOWN'),
    ('Vital FRESH', 'Sałatka w stylu greckim', 'C'),
    ('Vifon', 'Sos chili tajski słodko-pikantny', 'D'),
    ('Sottile Gusto', 'Passata z czosnkiem', 'B'),
    ('Sottile Gusto', 'Passata', 'A'),
    ('Dawtona', 'Sos Pomidorowy do Makaronu', 'C'),
    ('Międzychód', 'Sos pomidorowy', 'C'),
    ('Dawtona', 'Sos Curry', 'E'),
    ('Carrefour', 'Przecier pomidorowy', 'UNKNOWN'),
    ('Culineo', 'SOS Spaghetti', 'C'),
    ('Develey', 'Sos 1000 wysp', 'C'),
    ('Madero', 'Sos jogurtowy z ziołami', 'UNKNOWN'),
    ('Go Vege', 'Sos z jalapeño', 'D'),
    ('Biedronka', 'Sos z chili', 'D'),
    ('Vifon', 'Sos chili pikantny', 'E'),
    ('Develey', 'Sos jalapeño', 'C'),
    ('Dawtona', 'Sos BBQ', 'D'),
    ('Madero', 'Sos BBQ z chipotle', 'C'),
    ('ŁOWICZ', 'Sos Spaghetti', 'C'),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', 'B'),
    ('Łowicz', 'Sos Spaghetti', 'C'),
    ('Dawtona', 'Passata rustica', 'A'),
    ('Pudliszki', 'Przecier pomidorowy', 'A'),
    ('Łowicz', 'Leczo', 'UNKNOWN'),
    ('Roleski', 'Avocaboo!', 'D'),
    ('Sottile Gusto', 'Przecier pomidorowy', 'A'),
    ('Jamar', 'Passata - przecier pomidorowy klasyczny', 'B'),
    ('Roleski', 'Sos do kurczaka z czosnkiem', 'D'),
    ('Rolnik', 'Passata', 'A'),
    ('GustoBello', 'Arrabbiata Bruschetta', 'C'),
    ('Helcom', 'Dip in mexicana style', 'C'),
    ('Roleski', 'Sos pomidor + czarnuszka ostry', 'D'),
    ('Roleski', 'Sos pomidor + jagody goji', 'D'),
    ('MW Food', 'Sauce tomate', 'A'),
    ('Pudliszki', 'Bolonski', 'C'),
    ('Biedronka', 'Pesto Zielone. Sos na bazie bazyli.', 'D'),
    ('GustoBello', 'White wine vinegar cream with pesto alla genovese', 'D'),
    ('Kucharek', 'Kucharek', 'E'),
    ('Develey', 'Sos 1000 Wysp', 'D'),
    ('Roleski', 'Sos vinaigrette', 'D'),
    ('Knorr', 'Sos sałatkowy paprykowo-ziołowy', 'E'),
    ('Madero', 'Sos chilli pikantny', 'D'),
    ('Asia Flavours', 'Sos Sriracha mayo', 'E'),
    ('House of asia', 'Sos Sriracha', 'E'),
    ('Asia Flavours', 'Sos Sambal Oelek', 'E'),
    ('House of Asia', 'Sos z Czarnym Pieprzem', 'E'),
    ('Madero', 'Sos BBQ z miodem gryczanym', 'E'),
    ('Roleski', 'BBQ sos whisky', 'E'),
    ('Roleski', 'Texas sos BBQ', 'E'),
    ('Kotlin', 'Sos BBQ', 'D'),
    ('Jamar', 'Passata klasyczna', 'B'),
    ('Waldi Ben', 'Koncentrat pomidorowy 30%', 'C'),
    ('Winiary', 'Spaghetti sos z pomidorów', 'B'),
    ('Pingo Doce', 'Sos pomidorowy z bazylią', 'A'),
    ('Podravka', 'Przecier pomidorowy z bazylią', 'A'),
    ('HELCOM', 'Sauce a la mexicaine', 'C'),
    ('Dawtona', 'Sos pomidorowy ostry z papryczkami jalapeño', 'C'),
    ('Schedro', 'Sos Chersoński', 'D'),
    ('Unknown', 'Pesto all Genovese', 'E'),
    ('Pure Line', 'Sos jogurtowy z czosnkiem', 'UNKNOWN'),
    ('Asia Flavours', 'Sos Sriracha', 'E'),
    ('Develey', 'Sos Mayo Sriracha z chili i czosnkiem', 'D'),
    ('Heinz', 'słodki sos barbecue', 'D'),
    ('Winiary', 'Sos amerykański BBQ', 'D'),
    ('Roleski', 'Sos BBQ dark beer', 'UNKNOWN'),
    ('Italiamo', 'Sugo al pomodoro con basilico', 'A'),
    ('Mutti', 'Sauce Tomate aux légumes grillés', 'A'),
    ('Auchan', 'Passata con basilico', 'UNKNOWN'),
    ('mondo italiano', 'passierte Tomaten', 'A'),
    ('Combino', 'Sauce tomate bio à la napolitaine', 'C'),
    ('Extra Line', 'Passata garlic', 'A'),
    ('Carrefour', 'Tomates basilic', 'A'),
    ('Baresa', 'Pesto alla Genovese', 'C'),
    ('Barilla', 'Pesto alla Genovese', 'E'),
    ('Carrefour', 'Pesto verde', 'D'),
    ('Go Vege', 'Pesto z tofu', 'D'),
    ('Deluxe', 'Pesto con rucola', 'D'),
    ('Heinz', 'Sauce Salade Caesar', 'E'),
    ('Sol & Mar', 'Piri-Piri', 'NOT-APPLICABLE'),
    ('Kikkoman', 'Kikkoman Sojasauce', 'E'),
    ('Mutti', 'Passierte Tomaten', 'A'),
    ('gustobello', 'Passata', 'UNKNOWN')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA + processing risk
update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Unknown'
  end
from (
  values
    ('Pudliszki', 'Po Bolońsku sos do spaghetti', '3'),
    ('Culineo', 'Sos meksykański', '4'),
    ('Dawtona', 'Sos do spaghetti pomidorowo-śmietankowy.', '4'),
    ('Dawtona', 'Sos Neapolitański z papryką', '4'),
    ('Dawtona', 'Sos Boloński z ziołami', '4'),
    ('Dawtona', 'Sos meksykański', '4'),
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', '4'),
    ('Polskie Przetwory', 'Sos Boloński z bazylią', '4'),
    ('Międzychód', 'Sos Boloński z mięsem', '4'),
    ('Roleski', 'Sos tysiąca wysp', '4'),
    ('Heinz', 'Sos tysiąca wysp', '4'),
    ('Heinz', 'Sos Barbecue. Sos do grilla z cebulą i papryką', '4'),
    ('Fanex', 'Sos meksykański', '4'),
    ('Łowicz', 'Sos Boloński', '4'),
    ('Culineo', 'Sos boloński', '3'),
    ('Dawtona', 'Sos do pizzy z ziołami', '4'),
    ('Roleski', 'Sos pomidor + miód + limonka + nasiona chia', '4'),
    ('Pudliszki', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', '4'),
    ('Fanex', 'Sos tysiąc wysp', '4'),
    ('Vital FRESH', 'Sałatka w stylu greckim', '4'),
    ('Vifon', 'Sos chili tajski słodko-pikantny', '4'),
    ('Sottile Gusto', 'Passata z czosnkiem', '3'),
    ('Sottile Gusto', 'Passata', '3'),
    ('Dawtona', 'Sos Pomidorowy do Makaronu', '4'),
    ('Międzychód', 'Sos pomidorowy', '4'),
    ('Dawtona', 'Sos Curry', '4'),
    ('Carrefour', 'Przecier pomidorowy', '4'),
    ('Culineo', 'SOS Spaghetti', '4'),
    ('Develey', 'Sos 1000 wysp', '4'),
    ('Madero', 'Sos jogurtowy z ziołami', '4'),
    ('Go Vege', 'Sos z jalapeño', '4'),
    ('Biedronka', 'Sos z chili', '4'),
    ('Vifon', 'Sos chili pikantny', '4'),
    ('Develey', 'Sos jalapeño', '4'),
    ('Dawtona', 'Sos BBQ', '4'),
    ('Madero', 'Sos BBQ z chipotle', '4'),
    ('ŁOWICZ', 'Sos Spaghetti', '4'),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', '3'),
    ('Łowicz', 'Sos Spaghetti', '4'),
    ('Dawtona', 'Passata rustica', '3'),
    ('Pudliszki', 'Przecier pomidorowy', '3'),
    ('Łowicz', 'Leczo', '3'),
    ('Roleski', 'Avocaboo!', '4'),
    ('Sottile Gusto', 'Przecier pomidorowy', '1'),
    ('Jamar', 'Passata - przecier pomidorowy klasyczny', '4'),
    ('Roleski', 'Sos do kurczaka z czosnkiem', '4'),
    ('Rolnik', 'Passata', '3'),
    ('GustoBello', 'Arrabbiata Bruschetta', '3'),
    ('Helcom', 'Dip in mexicana style', '4'),
    ('Roleski', 'Sos pomidor + czarnuszka ostry', '4'),
    ('Roleski', 'Sos pomidor + jagody goji', '3'),
    ('MW Food', 'Sauce tomate', '4'),
    ('Pudliszki', 'Bolonski', '3'),
    ('Biedronka', 'Pesto Zielone. Sos na bazie bazyli.', '4'),
    ('GustoBello', 'White wine vinegar cream with pesto alla genovese', '4'),
    ('Kucharek', 'Kucharek', '4'),
    ('Develey', 'Sos 1000 Wysp', '4'),
    ('Roleski', 'Sos vinaigrette', '4'),
    ('Knorr', 'Sos sałatkowy paprykowo-ziołowy', '4'),
    ('Madero', 'Sos chilli pikantny', '4'),
    ('Asia Flavours', 'Sos Sriracha mayo', '4'),
    ('House of asia', 'Sos Sriracha', '4'),
    ('Asia Flavours', 'Sos Sambal Oelek', '3'),
    ('House of Asia', 'Sos z Czarnym Pieprzem', '4'),
    ('Madero', 'Sos BBQ z miodem gryczanym', '4'),
    ('Roleski', 'BBQ sos whisky', '4'),
    ('Roleski', 'Texas sos BBQ', '4'),
    ('Kotlin', 'Sos BBQ', '4'),
    ('Jamar', 'Passata klasyczna', '4'),
    ('Waldi Ben', 'Koncentrat pomidorowy 30%', '4'),
    ('Winiary', 'Spaghetti sos z pomidorów', '3'),
    ('Pingo Doce', 'Sos pomidorowy z bazylią', '4'),
    ('Podravka', 'Przecier pomidorowy z bazylią', '3'),
    ('HELCOM', 'Sauce a la mexicaine', '4'),
    ('Dawtona', 'Sos pomidorowy ostry z papryczkami jalapeño', '4'),
    ('Schedro', 'Sos Chersoński', '4'),
    ('Unknown', 'Pesto all Genovese', '4'),
    ('Pure Line', 'Sos jogurtowy z czosnkiem', '4'),
    ('Asia Flavours', 'Sos Sriracha', '4'),
    ('Develey', 'Sos Mayo Sriracha z chili i czosnkiem', '4'),
    ('Heinz', 'słodki sos barbecue', '4'),
    ('Winiary', 'Sos amerykański BBQ', '4'),
    ('Roleski', 'Sos BBQ dark beer', '4'),
    ('Italiamo', 'Sugo al pomodoro con basilico', '3'),
    ('Mutti', 'Sauce Tomate aux légumes grillés', '4'),
    ('Auchan', 'Passata con basilico', '4'),
    ('mondo italiano', 'passierte Tomaten', '4'),
    ('Combino', 'Sauce tomate bio à la napolitaine', '3'),
    ('Extra Line', 'Passata garlic', '3'),
    ('Carrefour', 'Tomates basilic', '4'),
    ('Baresa', 'Pesto alla Genovese', '4'),
    ('Barilla', 'Pesto alla Genovese', '4'),
    ('Carrefour', 'Pesto verde', '4'),
    ('Go Vege', 'Pesto z tofu', '4'),
    ('Deluxe', 'Pesto con rucola', '3'),
    ('Heinz', 'Sauce Salade Caesar', '4'),
    ('Sol & Mar', 'Piri-Piri', '4'),
    ('Kikkoman', 'Kikkoman Sojasauce', '3'),
    ('Mutti', 'Passierte Tomaten', '3'),
    ('gustobello', 'Passata', '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;
