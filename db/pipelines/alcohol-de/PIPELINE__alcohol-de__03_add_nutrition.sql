-- PIPELINE (Alcohol): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Alcohol'
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
    ('Franziskaner', 'Franziskaner Premium Weissbier Naturtrüb', 43.0, 0.0, 0.0, 0, 0.2, 0.2, 0.0, 0.8, 0.0),
    ('Hauser Weinimport', 'Glühwein rot', 90.0, 0.0, 0.0, 0, 9.3, 8.5, 0, 0.0, 0.0),
    ('Köstritzer', 'Köstritzer Schwarzbier', 42.0, 0.0, 0.0, 0, 2.5, 0.0, 0, 0.0, 0.0),
    ('Hasseröder', 'Hasseröder Premium Pils', 49.0, 0.0, 0, 0, 2.7, 0.1, 0, 0.4, 0.0),
    ('Spaten', 'Münchner Hell', 45.0, 0.5, 0.1, 0, 3.1, 0.5, 0, 0.7, 0.0),
    ('Paulaner München', 'Weißbier-Zitrone Alkoholfrei', 35.0, 0.0, 0.0, 0, 8.5, 5.6, 0, 0.0, 0.0),
    ('Mönchshof', 'Mönchshof Kellerbier', 45.0, 0.5, 0.1, 0, 3.3, 0.5, 0, 0.5, 0.0),
    ('Erdinger', 'Weißbier', 44.0, 0.1, 0, 0, 2.6, 0.5, 0.0, 0.6, 0.0),
    ('Lübzer', 'Lübzer Pils', 39.0, 0.0, 0.0, 0, 2.2, 0.0, 0.0, 0.4, 0.0),
    ('Paulaner', 'Paulaner Original Münchner Hell', 38.0, 0.0, 0.0, 0, 2.4, 0.0, 0, 0.5, 0),
    ('Paulaner', 'Münchner Hell', 38.0, 0.0, 0.0, 0, 2.2, 0.0, 0, 0.5, 0.0),
    ('Mönchshof', 'Mönchshof Original Naturtrüb''s Alkoholfrei 4082100003552 Alkoholfreies Schankbier', 23.0, 0.5, 0.1, 0, 4.7, 1.8, 0, 0.5, 0.0),
    ('Wernesgrüner', 'Wernesgrüner Pils', 41.0, 0.0, 0.0, 0, 2.9, 0.2, 0, 0.0, 0.0),
    ('Köstritzer', 'Köstritzer Edel Pils', 40.0, 0.0, 0.0, 0, 2.5, 0.0, 0.0, 0.0, 0),
    ('Neumarkter Lammsbräu', 'Neumarkter Lammsbräu Glutenfrei', 39.0, 0.5, 0.1, 0, 2.8, 0.5, 0, 0.5, 0.0),
    ('Bayreuther Brauhaus', 'Bayreuther', 39.0, 0.5, 0.0, 0, 3.1, 0.0, 0, 1.0, 0.0),
    ('Pülleken', 'Veltins', 43.0, 0.0, 0.0, 0, 3.1, 0.0, 0, 0.5, 0.0),
    ('Veltins', 'Bier - Veltins Pilsener', 40.0, 0.0, 0.0, 0, 2.9, 1.4, 0.2, 0.6, 0.0),
    ('Rotkäppchen', 'Sekt halbtrocken', 82.0, 0.0, 0, 0, 4.0, 0, 0, 0.0, 0),
    ('Berliner', 'Berliner Pilsner', 40.0, 0.5, 0.1, 0, 2.2, 0.5, 0, 0.5, 0.0),
    ('Jever', 'Jever Pilsener', 40.0, 0.0, 0.0, 0, 2.2, 0.5, 0, 0.5, 0.0),
    ('0 Original', '5,0 Original Pils', 40.0, 0.0, 0.0, 0, 2.8, 0.0, 0, 0.5, 0.0),
    ('Mönchshof', 'Natur Radler', 38.0, 0.5, 0, 0, 7.0, 5.5, 0, 0.5, 0),
    ('Störtebeker', 'Atlantik Ale', 41.0, 0.0, 0, 0, 2.5, 0, 0, 0.5, 0.0),
    ('Nordbrand Nordhausen', 'Pfefferminz', 164.2, 0.5, 0, 0, 16.9, 14.2, 0, 0.5, 0.0),
    ('Warsteiner', 'Radler alkoholfrei', 35.0, 0.0, 0.0, 0, 7.7, 5.7, 0, 0.3, 0.0),
    ('Warsteiner', 'Pilsener', 42.0, 0.0, 0.0, 0, 3.5, 0.0, 0, 0.5, 0),
    ('Mumm', 'Sekt, Jahrgang Dry, alkoholfrei', 18.0, 0.0, 0.0, 0, 3.5, 3.0, 0, 0.0, 0.0),
    ('Mönchshof', 'Natur Radler 0,0%', 27.0, 0.5, 0.1, 0, 6.4, 5.1, 0, 0.5, 0.0),
    ('Krombacher', 'Krombacher Pils', 38.0, 0.0, 0.0, 0, 2.4, 0.0, 0, 0.0, 0.0),
    ('Herzoglich Bayerisches Brauhaus Tegernsee', 'Tegernseer Hell', 43.0, 0.0, 0, 0, 2.4, 0, 0, 0.4, 0),
    ('Oettinger', 'Pils', 40.0, 0.0, 0, 0, 2.8, 0, 0, 0.5, 0),
    ('Radeberger', 'Pilsner Alkoholfrei', 17.0, 0.0, 0.0, 0, 2.9, 0.5, 0, 0.6, 0.0),
    ('Rothaus', 'Tannenzäpfle', 40.0, 0.4, 0.1, 0, 2.3, 0.4, 0, 0.5, 0.0),
    ('Gesamt', 'Hefeweissbier hell', 42.0, 0.0, 0, 0, 2.6, 0, 0, 0.0, 0),
    ('Unknown', 'Wodka Gorbatschow', 207.0, 0.0, 0, 0, 0.0, 0, 0, 0.0, 0),
    ('Doppio Passo', 'Doppio Passo Rotwein alkoholfrei', 33.0, 0.5, 0.1, 0, 6.9, 6.4, 0, 0.5, 0.0),
    ('Schloss Wachenheim', 'Light Live Red 0,0%', 23.0, 0.0, 0.0, 0, 5.7, 5.0, 0, 0.0, 0.0),
    ('Paulaner', 'Natur-Radler', 37.0, 0.0, 0, 0, 6.0, 6.0, 0, 0.0, 0),
    ('Franziskaner', 'Premium Weissbier Dunkel', 46.0, 0.1, 0.0, 0, 4.4, 1.8, 0.1, 0.6, 0.2),
    ('Mönchshof', 'Radler Blutorange', 46.0, 0.5, 0.1, 0, 7.5, 6.3, 0, 0.5, 0.0),
    ('Unknown', 'Benediktiner Hell', 42.0, 0.0, 0.0, 0, 3.1, 0.0, 0.0, 0.0, 0.0),
    ('Christkindl', 'Christkindl Glühwein', 82.0, 0.5, 0.1, 0, 9.0, 8.5, 0.0, 0.5, 0.0),
    ('Schöfferhofer', 'Weizen-Mix Grapefruit', 40.0, 0.0, 0.0, 0, 6.2, 5.1, 0, 0.5, 0.0),
    ('Krombacher', 'Weizen Alkoholfrei', 28.0, 0.0, 0.0, 0, 6.1, 2.7, 0, 0.5, 0.0),
    ('Allgäuer Brauhaus', 'Büble Bier Edelbräu', 44.0, 0.5, 0.1, 0, 2.5, 0.5, 0, 0.5, 0.0),
    ('Gösser', 'Natur Radler', 35.0, 0.0, 0.0, 0, 5.8, 4.4, 0, 0.0, 0.0),
    ('Budweiser', 'Budvar', 41.0, 0.0, 0, 0, 3.3, 0, 0, 0.3, 0),
    ('Unknown', 'Pilsner Urquell', 42.0, 0.0, 0, 0, 5.1, 0, 0, 0.5, 0),
    ('Carlsberg', 'Apple Cider', 61.0, 0.0, 0.0, 0, 10.0, 10.0, 0.0, 0.0, 0.0),
    ('Cerveceria Modelio', 'Corona Extra', 42.0, 0.0, 0.0, 0, 4.0, 0.2, 0, 0.3, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Alcohol' and p.is_deprecated is not true
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
