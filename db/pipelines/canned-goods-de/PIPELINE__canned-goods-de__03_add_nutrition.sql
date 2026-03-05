-- PIPELINE (Canned Goods): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Canned Goods'
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
    ('Nixe - LIDL', 'Thunfisch Filets in Sonnenblumenöl', 165.0, 9.0, 1.5, 0, 0.0, 0.0, 0.0, 21.0, 0.9),
    ('Hengstenberg', 'KNAX Gewürzgurken', 24.0, 0.5, 0.1, 0, 4.0, 3.9, 0.5, 0.8, 1.3),
    ('Aldi', 'Bio-Gewürzgurken', 30.0, 0.2, 0.1, 0, 4.9, 4.5, 1.1, 0.8, 0.9),
    ('Kuehne', 'Schlemmertöpfchen gew. Gurken', 61.0, 0.2, 0.1, 0, 12.0, 11.0, 1.3, 1.4, 2.3),
    ('Wonnemeyer', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 190.0, 13.0, 7.3, 0, 14.0, 12.0, 0, 2.9, 1.2),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 45.0, 1.8, 0.3, 0, 5.1, 1.8, 1.0, 1.6, 0.9),
    ('Kühne', 'Gewürzgurken', 30.0, 0.2, 0.1, 0, 4.9, 4.7, 1.3, 0.9, 1.6),
    ('Spreewaldhof', 'Spreelinge Gewürzgurken', 35.0, 0.1, 0.1, 0, 6.8, 6.7, 1.5, 0.5, 1.4),
    ('Erasco', 'Linseneintopf mit Würstchen', 77.0, 2.0, 0.8, 0, 9.5, 1.3, 2.7, 4.2, 1.0),
    ('Erasco', 'Erasco Kartoffelsuppe m. Würstchen', 61.0, 2.2, 0.8, 0, 8.2, 0.7, 0.5, 1.8, 0.9),
    ('Aldi', 'Sardinen in Sonnenblumenöl - Klassik', 171.0, 7.0, 4.3, 0, 0.5, 0.5, 0, 27.0, 0.6),
    ('Nestlé', 'Ravioli Gemüse', 81.0, 1.3, 0.1, 0, 13.7, 3.2, 1.3, 2.9, 0.9),
    ('Erasco', 'Westfälische Linsen Eintopf', 58.0, 0.6, 0.2, 0, 9.1, 1.3, 1.6, 3.3, 0.7),
    ('Erasco', 'Hühner Reis-Topf', 57.0, 2.0, 0.6, 0, 7.2, 0.4, 0, 2.1, 1.0),
    ('King''s Crown', 'Erbsen und Möhren sehr fein', 45.0, 0.7, 0.1, 0, 4.2, 0.9, 5.5, 2.7, 0.3),
    ('Erasco', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 75.0, 1.9, 0.7, 0, 9.4, 1.4, 1.7, 4.2, 1.0),
    ('Kühne', 'Gurken Sauer Honig Schlemmertöpfchen', 65.0, 0.2, 0.1, 0, 13.0, 12.0, 1.5, 1.4, 1.7),
    ('Nixe', 'Thunfisch', 109.0, 0.7, 0.0, 0, 0.0, 0.0, 0.0, 26.0, 0.9),
    ('Appel', 'Zarte Filets vom Hering in Tomaten-Creme', 218.0, 16.1, 2.7, 0, 5.2, 4.5, 0, 12.0, 1.0),
    ('KING''S CROWN (Aldi)', 'Tomatenmark', 126.0, 1.0, 0.2, 0, 18.5, 18.0, 6.3, 6.2, 1.0),
    ('Almare Seafood', 'Thunfisch Filets in eigenen Saft', 66.0, 0.6, 0.4, 0, 0.0, 0.0, 0, 23.0, 0.8),
    ('Aldi', 'Tomatenmark', 96.0, 0.7, 0.2, 0, 14.0, 14.0, 4.1, 4.7, 0.0),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 113.0, 0.6, 0.1, 0, 18.0, 18.0, 3.5, 5.9, 1.0),
    ('King''s Crown', 'Tomaten gehackt', 20.0, 0.5, 0.1, 0, 3.0, 3.0, 1.1, 1.1, 0.1),
    ('Oro Di Parma', 'Tomaten', 23.0, 0.5, 0.1, 0, 3.0, 3.0, 1.6, 1.1, 0.5),
    ('Hawesta', 'Heringsfilets - Tomaten-Creme', 214.0, 17.0, 2.0, 0, 3.6, 2.0, 0, 11.5, 0.5),
    ('Aldi', 'Cornichons', 29.0, 0.5, 0.1, 0, 3.8, 3.8, 0.5, 0.5, 1.1),
    ('Erasco', 'Vegetarischer linsen-eintopf', 66.0, 0.9, 0.1, 0, 10.0, 1.4, 1.9, 3.4, 1.0),
    ('DmBio', 'Tomatenmark', 105.0, 0.4, 0.1, 0, 19.0, 13.0, 3.7, 4.9, 0.1),
    ('Erasco', 'Erbsensuppe Hubertus', 88.0, 1.8, 0.6, 0, 10.0, 0.8, 3.2, 5.7, 0.7),
    ('Hawesta', 'Heringsfilets - Pfeffercreme', 215.0, 17.0, 2.0, 0, 3.6, 2.0, 0, 11.5, 0.5),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 22.0, 0.5, 0.1, 0, 1.9, 1.7, 2.5, 1.5, 1.1),
    ('Bio Organic', 'Rote Beete', 42.0, 0.1, 0.1, 0, 8.2, 8.2, 2.5, 0.9, 0.2),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 214.0, 17.1, 2.9, 0, 2.5, 1.8, 0, 11.5, 1.3),
    ('Appel', 'Zarte Filets vom Hering Tomate-Mozzarella', 194.0, 14.1, 3.2, 0, 4.1, 4.0, 0, 11.6, 1.2),
    ('Erasco', 'Erbseneintopf', 79.0, 1.3, 0.1, 0, 10.0, 0.9, 3.9, 4.7, 0.8),
    ('Aldi', 'Mais', 82.0, 1.7, 0.4, 0, 12.0, 6.4, 0, 3.0, 0.3),
    ('Hengstenberg', 'Tomaten - Passiert', 33.0, 0.5, 0.1, 0, 4.9, 4.9, 2.2, 1.4, 0.5),
    ('Sweet Valley', 'Pfirsiche halbe Frucht, leicht gezuckert', 68.0, 0.1, 0.0, 0, 15.6, 14.6, 1.0, 0.6, 0.0),
    ('Deutsche See', 'Thunfisch im Aufguss', 99.0, 0.8, 0.3, 0, 0.5, 0.5, 0, 23.0, 0.8),
    ('King''s Crown', 'Rote Beete in Kugeln', 57.0, 0.0, 0.0, 0, 11.6, 10.7, 2.0, 1.0, 0.3),
    ('Freshona', 'Sonnenmais natursüß', 77.0, 1.7, 0.3, 0, 11.5, 5.5, 2.8, 2.6, 0.3),
    ('REWE Bio', 'Tomaten in Stücken', 21.0, 0.1, 0.0, 0, 3.0, 3.0, 0, 1.3, 0.1),
    ('Erasco', 'Erasco Erbsen-Eintopf 4037300108309', 82.0, 1.9, 0.7, 0, 10.0, 0.8, 3.5, 5.1, 1.0),
    ('Aldi', 'Gehackte Tomaten', 20.0, 0.1, 0.0, 0, 3.0, 3.0, 1.1, 1.3, 0.1),
    ('K-Classic', 'Thunfisch Filets I.E.S', 101.0, 8.0, 3.0, 0, 0.0, 0.0, 0.0, 23.0, 0.8),
    ('Nestlé', 'Dosen Ravioli', 88.0, 2.2, 0.6, 0, 13.4, 1.9, 0.8, 3.3, 0.9),
    ('Edeka', 'Delikatess Gewürzgurken', 28.0, 0.1, 0.0, 0, 5.1, 5.0, 0, 0.4, 1.0),
    ('Mutti', 'Geschälte Italienische Tomaten', 22.0, 0.5, 0.1, 0, 3.6, 2.9, 0, 1.1, 0.0),
    ('Sweet Valley', 'ALDI SWEET VALLEY OBST Ananas in Scheiben ohne Zuckerzusatz', 59.0, 5.0, 1.0, 0, 13.0, 13.0, 0, 5.0, 1.0),
    ('Erasco', 'Serbische Bohnensuppe', 60.0, 1.2, 0.4, 0, 8.0, 2.4, 3.4, 2.7, 1.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Canned Goods' and p.is_deprecated is not true
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
