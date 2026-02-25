-- PIPELINE (Sweets): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Sweets'
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
    ('Ferrero', 'Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 576.0, 36.0, 20.8, 0, 56.8, 55.2, 0, 4.8, 0.0),
    ('Ritter Sport', 'Kakao-Klasse Die Kräftige 74%', 627.0, 50.0, 32.0, 0, 27.0, 24.0, 0, 7.0, 0.0),
    ('Kinder', 'Überraschung', 561.0, 34.9, 22.9, 0, 52.6, 52.3, 0, 8.4, 0.3),
    ('J. D. Gross', 'Edelbitter Mild 90%', 608.0, 51.9, 31.4, 0, 16.2, 7.3, 14.6, 11.0, 0.0),
    ('Moser Roth', 'Edelbitter-Schokolade 85 % Cacao', 604.0, 50.0, 31.0, 0, 20.0, 14.0, 14.0, 11.0, 0.3),
    ('Ritter Sport', 'Kakao Klasse die Starke - 81%', 609.0, 52.0, 33.0, 0, 20.0, 16.0, 0, 9.4, 0.0),
    ('Moser Roth', 'Edelbitter 90 % Cacao', 644.0, 56.8, 35.2, 0, 15.2, 8.8, 14.0, 11.2, 0.0),
    ('Lidl', 'Lidl Organic Dark Chocolate', 600.0, 40.0, 26.7, 0, 46.7, 26.7, 10.0, 10.0, 0.0),
    ('Aldi', 'Edelbitter-Schokolade 70% Cacao', 578.0, 42.0, 26.0, 0, 34.0, 28.0, 12.0, 9.5, 0.0),
    ('Ritter Sport', 'Schokolade Halbbitter', 534.0, 33.0, 19.0, 0, 50.0, 48.0, 0, 6.0, 0.0),
    ('Ritter Sport', 'Marzipan', 496.0, 27.0, 11.0, 0, 52.0, 51.0, 0, 7.0, 0.0),
    ('Aldi', 'Edelbitter- Schokolade', 583.0, 43.0, 26.0, 0, 37.0, 29.0, 10.0, 6.7, 0.0),
    ('Ritter Sport', 'Alpenmilch', 547.0, 32.0, 20.0, 0, 54.0, 53.0, 0, 8.2, 0.2),
    ('Ritter Sport', 'Ritter Sport Nugat', 552.0, 33.0, 13.0, 0, 54.0, 51.0, 0, 7.3, 0.1),
    ('Lindt', 'Lindt Dubai Style Chocolade', 563.0, 36.0, 19.0, 0, 50.0, 46.0, 0, 8.3, 0.3),
    ('Ritter Sport', 'Ritter Sport Voll-Nuss', 569.0, 38.0, 13.0, 0, 45.0, 43.0, 0, 8.9, 0.1),
    ('Schogetten', 'Schogetten originals: Edel-Zartbitter', 529.0, 31.0, 19.0, 0, 52.0, 47.0, 0, 6.8, 0.0),
    ('Choceur', 'Aldi-Gipfel', 527.0, 27.9, 16.4, 0, 63.2, 62.5, 1.8, 4.9, 0.1),
    ('Ritter Sport', 'Edel-Vollmilch', 571.0, 38.0, 23.0, 0, 48.0, 47.0, 0, 7.3, 0.2),
    ('Müller & Müller GmbH', 'Blockschokolade', 531.0, 31.0, 20.0, 0, 53.0, 50.0, 0, 6.0, 0.0),
    ('Sarotti', 'Mild 85%', 655.0, 60.0, 38.0, 0, 15.0, 11.0, 0, 7.5, 0.0),
    ('Aldi', 'Nussknacker - Vollmilchschokolade', 591.0, 40.0, 16.0, 0, 45.0, 41.0, 0, 11.0, 0.2),
    ('Aldi', 'Nussknacker - Zartbitterschokolade', 590.0, 41.0, 16.0, 0, 42.0, 36.0, 8.1, 8.9, 0.0),
    ('Back Family', 'Schoko-Chunks - Zartbitter', 528.0, 31.3, 18.5, 0, 51.5, 47.1, 7.9, 6.2, 0.0),
    ('Ritter Sport', 'Pistachio', 539.0, 32.3, 14.8, 0.0, 51.6, 51.6, 3.2, 6.5, 1.4),
    ('Lindt', 'Excellence Mild 70%', 610.0, 48.0, 29.0, 0, 33.0, 29.0, 0, 6.9, 0.1),
    ('Fairglobe', 'Bio Vollmilch-Schokolade', 564.0, 35.7, 21.5, 0, 52.7, 51.5, 0.1, 7.2, 0.2),
    ('Ritter Sport', 'Kakao-Mousse', 577.0, 39.0, 23.0, 0, 47.0, 46.0, 0, 7.4, 0.3),
    ('Ritter Sport', 'Kakao Klasse 61 die feine aus Nicaragua', 600.0, 45.0, 28.0, 0, 40.0, 37.0, 0.0, 5.6, 0.0),
    ('Ritter Sport', 'Ritter Sport Honig Salz Mandel', 548.0, 34.0, 13.0, 0, 48.0, 47.0, 0.0, 9.1, 0.3),
    ('Lindt', 'Gold Bunny', 544.0, 32.0, 19.0, 0, 56.0, 54.0, 0, 7.2, 0.3),
    ('Schogetten', 'Schogetten - Edel-Alpenvollmilchschokolade', 551.0, 33.0, 20.0, 0, 57.0, 56.0, 0, 5.5, 0.1),
    ('Ferrero', 'Kinder Osterhase - Harry Hase', 579.0, 36.2, 24.1, 0, 53.9, 53.6, 0, 8.8, 0.3),
    ('Ritter Sport', 'Joghurt', 585.0, 40.0, 23.0, 0, 48.0, 48.0, 0, 6.7, 0.2),
    ('Ritter Sport', 'Trauben Nuss', 516.0, 28.0, 14.0, 0, 58.0, 55.0, 0, 6.4, 0.1),
    ('Ritter Sport', 'Knusperkeks', 544.0, 32.0, 19.0, 0, 57.0, 50.0, 0, 6.2, 0.3),
    ('Milka', 'Schokolade Joghurt', 573.0, 37.0, 21.0, 0, 56.0, 55.0, 1.1, 4.4, 0.2),
    ('Ritter Sport', 'Rum Trauben Nuss Schokolade', 522.0, 28.0, 15.0, 0, 56.0, 54.0, 0, 6.3, 0.1),
    ('Aldi', 'Schokolade (Alpen-Sahne-)', 580.0, 41.0, 25.0, 0, 44.0, 41.0, 5.1, 8.2, 0.1),
    ('Aldi', 'Erdbeer-Joghurt', 577.0, 38.0, 23.0, 0, 52.0, 51.0, 0, 6.3, 0.2),
    ('Rapunzel', 'Nirwana Vegan', 573.0, 38.0, 16.0, 0, 52.0, 43.0, 3.9, 4.6, 0.2),
    ('Ritter Sport', 'Haselnuss', 554.0, 34.0, 17.0, 0, 53.0, 50.0, 0, 7.3, 0.2),
    ('Ritter SPORT', 'Ritter Sport Erdbeer', 572.0, 38.0, 22.0, 0, 49.0, 48.0, 0, 6.6, 0.2),
    ('Schogetten', 'Schogetten Edel-Zartbitter-Haselnuss', 565.0, 38.0, 20.0, 0, 45.0, 41.0, 0, 7.1, 0.0),
    ('Ritter Sport', 'Amicelli', 563.0, 35.0, 17.0, 0, 53.0, 50.0, 0, 6.5, 0.2),
    ('Ferrero', 'Kinder Weihnachtsmann', 577.0, 36.2, 24.1, 0, 53.9, 53.6, 0, 8.8, 0.3),
    ('Merci', 'Finest Selection Mandel Knusper Vielfalt', 571.0, 37.4, 19.0, 0, 47.2, 44.5, 0, 9.6, 0.2),
    ('Aldi', 'Rahm Mandel', 581.0, 40.0, 17.0, 0, 39.0, 39.0, 5.3, 12.0, 0.2),
    ('Ritter Sport', 'Vegan Roasted Peanut', 574.0, 40.0, 17.0, 0, 37.0, 35.0, 0.0, 14.0, 0.4),
    ('Ritter Sport', 'Nussklasse Ganze Mandel', 559.0, 37.0, 14.0, 0, 45.0, 44.0, 0, 9.8, 0.1),
    ('Ritter Sport', 'Ritter Sport Lemon', 592.0, 41.0, 24.0, 0, 49.0, 49.0, 0, 5.9, 0.2)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Sweets' and p.is_deprecated is not true
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
