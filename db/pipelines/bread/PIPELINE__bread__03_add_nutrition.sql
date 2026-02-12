-- PIPELINE (Bread): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Bread'
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
    ('Gursz', 'Chleb Pszenno-Żytni', 245.0, 1.3, 0.3, 0, 49.3, 1.7, 2.8, 7.6, 1.3),
    ('Lajkonik', 'Paluszki słone', 379.0, 4.0, 0.4, 0, 72.0, 2.7, 3.4, 12.0, 3.0),
    ('Dan Cake', 'Bułeczki mleczne z czekoladą', 367.0, 13.0, 3.2, 0, 52.0, 19.0, 0, 9.3, 0.8),
    ('Pano', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', 302.0, 9.2, 1.4, 0, 40.0, 3.0, 6.9, 10.0, 1.3),
    ('Pano', 'Hot dog pszenno-żytni', 282.0, 2.8, 0.4, 0, 55.0, 5.6, 2.3, 8.5, 1.0),
    ('Mestemacher', 'Chleb wielozbożowy żytni pełnoziarnisty', 200.0, 2.8, 0.4, 0, 33.0, 4.9, 8.8, 5.8, 1.3),
    ('Auchan', 'Bułki do Hamburgerów', 346.0, 11.0, 1.6, 0, 53.0, 7.3, 0, 8.4, 1.0),
    ('Auchan', 'Tost pełnoziarnisty', 239.0, 2.5, 0.4, 0, 43.0, 2.8, 0, 8.2, 1.2),
    ('Vital', 'Bułki śniadaniowe', 260.0, 1.4, 0.4, 0, 51.0, 1.1, 3.2, 9.7, 1.4),
    ('Pano', 'Bułka tarta', 361.0, 1.1, 0.4, 0, 71.0, 3.4, 5.7, 14.0, 0.9),
    ('Piekarnia Gwóźdź', 'Chleb z mąką krojony - pieczywo mieszane', 231.0, 1.2, 0.3, 0, 46.5, 2.6, 0, 7.3, 1.3),
    ('Pano', 'Bułka do hot doga', 371.0, 12.0, 3.8, 0, 55.0, 6.7, 2.7, 9.2, 0.9),
    ('Auchan', 'Tortilla Pszenno-Żytnia', 260.0, 4.5, 1.8, 0, 41.0, 6.3, 0, 8.4, 1.4),
    ('Pano', 'Tost pełnoziarnisty', 240.0, 2.0, 0.4, 0, 43.0, 2.2, 5.6, 10.0, 1.1),
    ('Pano', 'Tost  maślany', 267.0, 3.2, 1.7, 0, 50.0, 2.9, 0, 8.6, 1.2),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 434.0, 20.0, 3.0, 0, 58.0, 9.0, 13.0, 12.0, 2.7),
    ('Pano', 'Chleb żytni', 198.0, 1.4, 0.2, 0, 36.0, 3.0, 9.3, 5.6, 1.1),
    ('Dan Cake', 'Mleczne bułeczki', 352.0, 12.0, 1.7, 0, 50.0, 13.0, 3.0, 9.6, 0.7),
    ('Sonko', 'Lekkie żytnie', 363.0, 1.6, 0.4, 0, 74.5, 0.7, 8.8, 8.2, 1.1),
    ('Lantmannen Unibake', 'Bułki pszenne do hot dogów.', 280.0, 3.3, 0.4, 0, 54.0, 8.2, 1.8, 7.5, 1.0),
    ('Aksam', 'Beskidzkie paluszki z solą', 390.0, 5.5, 0.6, 0, 73.0, 2.2, 2.1, 11.0, 3.7),
    ('Wypieczone ze smakiem', 'Chleb żytni z ziarnami', 248.0, 5.9, 0.6, 0, 37.0, 2.1, 5.4, 8.4, 1.7),
    ('Pano', 'Bułeczki śniadaniowe', 350.0, 12.0, 1.8, 0, 50.0, 15.0, 1.8, 9.5, 0.7),
    ('Spółdzielnia piekarsko ciastkarska w Warszawie', 'Chleb wieloziarnisty złoty łan', 274.0, 5.7, 0.6, 0, 43.0, 2.5, 5.1, 9.9, 1.0),
    ('PANO', 'Chleb wieloziarnisty Złoty Łan', 277.0, 4.6, 0.6, 0, 46.0, 23.0, 6.2, 9.8, 13.0),
    ('Z Piekarni Regionalnej', 'Chleb zytni ze słonecznikiem', 253.0, 3.5, 0.5, 0, 47.0, 3.8, 5.0, 6.1, 1.1),
    ('Pano', 'Bułki do hamburgerów z sezamem', 277.0, 4.3, 0.6, 0, 48.0, 5.4, 0, 10.0, 1.2),
    ('Sonko', 'Lekkie ze słonecznikiem', 369.0, 1.5, 0.2, 0, 78.1, 0, 3.5, 8.9, 1.0),
    ('Mastemacher', 'Chleb żytni', 202.0, 1.3, 0.2, 0, 36.8, 4.4, 0, 5.8, 1.3),
    ('Sendal', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', 214.0, 1.7, 0.2, 0, 47.0, 0.6, 3.8, 5.5, 1.0),
    ('Carrefour', 'Chleb tostowy maślany', 265.0, 3.0, 1.7, 0, 50.0, 2.9, 2.0, 8.6, 1.2),
    ('Oskroba', 'Chleb żytni razowy', 219.0, 1.8, 0.3, 0, 44.0, 1.6, 0, 4.8, 1.4),
    ('VITAL', 'Bułki z ziarnami', 322.0, 9.8, 1.2, 0, 44.0, 1.3, 5.0, 12.0, 1.2),
    ('DAN CAKE', 'Bułki śniadaniowe', 260.0, 1.4, 0.4, 0, 51.0, 1.1, 3.2, 9.7, 1.4),
    ('Sendal', 'Chleb na maślance', 215.0, 1.7, 0.3, 0, 47.0, 1.3, 4.0, 6.0, 1.2),
    ('Lajkonik', 'Bajgle z ziołami prowansalskimi', 437.0, 15.0, 1.5, 0, 61.0, 4.9, 4.8, 12.0, 2.7),
    ('Dan cake', 'Tost pełnoziarnisty', 247.0, 3.0, 0.3, 0, 43.0, 4.8, 4.9, 9.5, 1.1),
    ('Piekarnia Wilkowo', 'Chleb pszenno-żytni', 226.0, 1.0, 0.1, 0, 47.0, 2.8, 3.8, 9.0, 1.4),
    ('Dan Cake', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku.', 248.0, 1.0, 0.3, 0, 50.0, 2.5, 2.5, 8.5, 1.5),
    ('Sendal', 'Chleb żytni bez drożdzy', 209.0, 1.0, 0.0, 0, 47.4, 0.3, 3.9, 3.6, 0.4),
    ('Piekarnia Oskrobia', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony.', 256.0, 2.1, 0.4, 0, 47.0, 2.1, 5.3, 9.5, 1.4),
    ('Mika', 'Chleb żytni razowy', 196.0, 1.5, 0.4, 0, 37.0, 1.7, 6.8, 5.5, 2.3),
    ('Putka', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', 238.0, 1.7, 0.3, 0, 44.0, 1.4, 5.6, 8.4, 1.3),
    ('Pano', 'Tortilla', 300.0, 6.7, 1.3, 0, 49.0, 4.4, 4.7, 8.8, 1.1),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 218.0, 5.2, 0.7, 0, 31.7, 3.3, 12.0, 5.3, 1.2),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 376.0, 0.9, 0.2, 0, 83.0, 1.1, 3.5, 7.8, 0.9),
    ('Bite IT', 'LAWASZ pszenny chleb', 285.0, 3.7, 0.5, 0, 53.3, 1.5, 1.4, 8.7, 1.2),
    ('Gwóźdź', 'Chleb wieloziarnisty', 272.0, 4.1, 0.6, 0, 46.0, 2.1, 5.4, 9.8, 1.4),
    ('Oskroba', 'Tost maślany', 259.0, 3.0, 1.7, 0, 50.0, 2.9, 0, 8.6, 1.2),
    ('Z dobrej piekarni', 'Chleb baltonowski', 239.0, 1.3, 0.3, 0, 47.0, 1.7, 3.2, 8.2, 1.4),
    ('Carrefour', 'Tortilla pszenna', 324.0, 7.2, 1.8, 0, 54.4, 1.8, 1.8, 9.5, 1.1),
    ('Z Dobrej Piekarni', 'Chleb wieloziarnisty', 285.0, 7.0, 0.8, 0, 43.0, 3.0, 3.7, 10.0, 1.3),
    ('Shulstad', 'Classic Pszenny Hot Dog', 254.0, 1.4, 0.2, 0, 48.0, 2.5, 4.4, 9.9, 1.2),
    ('Oskroba', 'Chleb żytni pełnoziarnisty pasteryzowany', 199.0, 1.4, 0.2, 0, 37.0, 5.1, 0, 5.3, 1.5),
    ('Dakri', 'Pinsa', 255.0, 4.3, 0.7, 0, 46.0, 0.6, 0.2, 8.0, 1.0),
    ('Żabka', 'Kajzerka kebab', 306.0, 16.0, 1.9, 0, 29.0, 4.1, 1.6, 9.8, 1.6),
    ('Asprod', 'Chleb jakubowy żytni razowy', 234.0, 6.5, 0.7, 0, 31.0, 2.7, 10.0, 7.4, 0.9),
    ('Biedronka piekarnia gwóźdź', 'Chleb żytni', 262.0, 5.7, 0.7, 0, 43.0, 1.5, 0, 7.6, 1.7),
    ('Piekarnia &quot;Pod Rogalem&quot;', 'Chleb Baltonowski krojony', 322.0, 1.0, 0.0, 0, 68.0, 0.8, 0, 7.2, 1.2),
    ('Piekarnia Jesse', 'Chleb wieloziarnisty ciemny', 305.0, 5.1, 0.6, 0, 53.0, 1.9, 6.1, 8.8, 1.9)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Bread' and p.is_deprecated is not true
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
