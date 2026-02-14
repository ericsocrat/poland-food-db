-- PIPELINE (Chips): scoring
-- Generated: 2026-02-11

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Intersnack', 'Prażynki solone', 'D'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 'D'),
    ('Miami', 'Pałeczki kukurydziane', 'UNKNOWN'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', 'D'),
    ('Przysnacki', 'Prażynki bekonowe', 'E'),
    ('Przysnacki', 'Chipsy w kotle prażone', 'D'),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', 'D'),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', 'E'),
    ('Star', 'Maczugi', 'D'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 'D'),
    ('Przysnacki', 'Chrupki o smaku keczupu', 'D'),
    ('Crunchips', 'Crunchips X-CUT, Papryka', 'D'),
    ('Lorenz', 'Crunchips Sticks Ketchup', 'C'),
    ('Lorenz', 'Crunchips X-cut Chakalaka', 'D'),
    ('Top', 'Tortilla', 'C'),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', 'D'),
    ('Miami', 'Chrupki kukurydziane', 'A'),
    ('Top', 'Sticks smak ketchup', 'D'),
    ('Curly', 'Curly Mexican style', 'D'),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', 'E'),
    ('Sunny Family', 'Trips kukurydziane', 'C'),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', 'D'),
    ('Top', 'Top Sticks', 'D'),
    ('Lay''s', 'Chipsy ziemniaczane solone', 'D'),
    ('Go Vege', 'Tortilla Chips Buraczane', 'C'),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', 'D'),
    ('Lay''s', 'Karbowane Papryka', 'D'),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', 'E'),
    ('Lay''s', 'Lay''s green onion flavoured', 'D'),
    ('Lay''s', 'Fromage flavoured chips', 'C'),
    ('Lay''s', 'Lay''s Oven Baked Grilled Paprika', 'C'),
    ('Lay''s', 'Lays Papryka', 'UNKNOWN'),
    ('Top', 'Chipsy smak serek Fromage', 'D'),
    ('Zdrowidło', 'Loopeas light o smaku papryki', 'D'),
    ('Lay''s', 'Lays strong', 'D'),
    ('Lay''s', 'Lays solone', 'D'),
    ('Doritos', 'Hot Corn', 'D'),
    ('Lay''s', 'Oven Baked krakersy', 'D'),
    ('Sonko', 'Chipsy z ciecierzycy', 'D'),
    ('Crunchips', 'Potato crisps with paprika flavour', 'D'),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', 'D'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 'E'),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', 'D'),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 'D'),
    ('Cheetos', 'Cheetos Flamin Hot', 'D'),
    ('Lay''s', 'Flamin'' Hot', 'C'),
    ('Lorenz', 'Peppies Bacon Flavour', 'E'),
    ('Lorenz', 'Monster Munch Mr BIG', 'E'),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Intersnack', 'Prażynki solone', '3'),
    ('Lorenz', 'Crunchips Pieczone Żeberka', '4'),
    ('Miami', 'Pałeczki kukurydziane', '3'),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', '4'),
    ('Przysnacki', 'Prażynki bekonowe', '4'),
    ('Przysnacki', 'Chipsy w kotle prażone', '3'),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', '4'),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', '4'),
    ('Star', 'Maczugi', '4'),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', '4'),
    ('Przysnacki', 'Chrupki o smaku keczupu', '4'),
    ('Crunchips', 'Crunchips X-CUT, Papryka', '4'),
    ('Lorenz', 'Crunchips Sticks Ketchup', '4'),
    ('Lorenz', 'Crunchips X-cut Chakalaka', '4'),
    ('Top', 'Tortilla', '4'),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', '4'),
    ('Miami', 'Chrupki kukurydziane', '3'),
    ('Top', 'Sticks smak ketchup', '4'),
    ('Curly', 'Curly Mexican style', '4'),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', '4'),
    ('Sunny Family', 'Trips kukurydziane', '3'),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', '4'),
    ('Top', 'Top Sticks', '3'),
    ('Lay''s', 'Chipsy ziemniaczane solone', '3'),
    ('Go Vege', 'Tortilla Chips Buraczane', '3'),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', '4'),
    ('Lay''s', 'Karbowane Papryka', '4'),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', '4'),
    ('Lay''s', 'Lay''s green onion flavoured', '4'),
    ('Lay''s', 'Fromage flavoured chips', '4'),
    ('Lay''s', 'Lay''s Oven Baked Grilled Paprika', '4'),
    ('Lay''s', 'Lays Papryka', '4'),
    ('Top', 'Chipsy smak serek Fromage', '4'),
    ('Zdrowidło', 'Loopeas light o smaku papryki', '4'),
    ('Lay''s', 'Lays strong', '4'),
    ('Lay''s', 'Lays solone', '3'),
    ('Doritos', 'Hot Corn', '4'),
    ('Lay''s', 'Oven Baked krakersy', '4'),
    ('Sonko', 'Chipsy z ciecierzycy', '4'),
    ('Crunchips', 'Potato crisps with paprika flavour', '4'),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', '4'),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', '4'),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', '3'),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', '4'),
    ('Cheetos', 'Cheetos Flamin Hot', '4'),
    ('Lay''s', 'Flamin'' Hot', '4'),
    ('Lorenz', 'Peppies Bacon Flavour', '4'),
    ('Lorenz', 'Monster Munch Mr BIG', '4'),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Chips');
