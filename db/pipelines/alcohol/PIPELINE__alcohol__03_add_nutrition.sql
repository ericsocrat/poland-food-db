-- PIPELINE (Alcohol): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Alcohol'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 24.0, 0.0, 0.0, 0, 5.8, 4.9, 0, 0.0, 0.0),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 309.0, 11.0, 6.4, 0, 13.0, 0.5, 31.0, 24.0, 0.1),
    ('Diamant', 'Cukier Biały', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 51.0, 0.5, 0.1, 0, 13.0, 11.0, 1.3, 0.5, 0.0),
    ('Harnaś', 'Harnaś jasne pełne', 43.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('VAN PUR S.A.', 'Łomża piwo jasne bezalkoholowe', 24.0, 0.0, 0.0, 0, 5.5, 3.3, 0.0, 0.5, 0.0),
    ('Karmi', 'Karmi o smaku żurawina', 42.0, 0.0, 0.0, 0, 9.8, 8.9, 0.0, 0.3, 0.0),
    ('Żywiec', 'Limonż 0%', 18.0, 0.0, 0.0, 0, 4.7, 2.9, 0, 0.0, 0.0),
    ('Polski Cukier', 'Cukier biały', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('Lomża', 'Łomża jasne', 43.0, 0.0, 0, 0, 3.6, 0, 0, 0.4, 0),
    ('Kompania Piwowarska', 'Kozel cerny', 36.0, 0.1, 0.1, 0, 0.0, 0.0, 0.0, 0.0, 0.1),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 43.0, 0.0, 0.0, 0, 3.4, 0, 0, 0.1, 0),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 43.0, 0.0, 0.0, 0, 3.0, 0.2, 0, 0.5, 0.0),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 40.0, 0.0, 0.0, 0, 3.3, 0.2, 0, 0.2, 0.0),
    ('Książęce', 'Książęce czerwony lager', 42.0, 0.0, 0, 0, 3.2, 0, 0, 0.6, 0),
    ('Lech', 'Lech Premium', 41.0, 0.1, 0.1, 0, 2.8, 0.8, 0, 0.6, 0.1),
    ('Zatecky', 'Zatecky 0%', 12.0, 0.0, 0, 0, 2.9, 0.0, 0, 0.0, 0),
    ('Kompania Piwowarska', 'Lech free', 22.0, 0.0, 0.0, 0, 5.5, 3.0, 0, 0.0, 0.0),
    ('Łomża', 'Radler 0,0%', 26.0, 0.0, 0.0, 0, 6.1, 4.8, 0, 0.5, 0.0),
    ('Łomża', 'Bière sans alcool', 32.0, 0.0, 0.0, 0, 7.5, 2.8, 0.0, 0.5, 0.0),
    ('Warka', 'Piwo Warka Radler', 26.0, 0.0, 0.0, 0, 6.4, 4.5, 0, 0.0, 0.0),
    ('Nestlé', 'Przyprawa Maggi', 20.0, 0.0, 0.0, 0, 2.2, 0.9, 0.0, 2.8, 22.8),
    ('Gryzzale', 'polutry kabanos sausages', 290.0, 18.0, 6.4, 0, 5.8, 1.7, 0, 24.0, 2.3),
    ('Carlsberg', 'Pilsner 0.0%', 15.0, 0.0, 0, 0, 3.2, 0, 0, 0.0, 0.0),
    ('Lech', 'Lech Free Lime Mint', 28.0, 0.0, 0, 0, 7.8, 5.8, 0, 0.0, 0),
    ('Amber', 'Amber IPA zero', 23.0, 0.1, 0.1, 0, 4.9, 2.3, 0, 0.3, 0),
    ('Unknown', 'LECH FREE CITRUS SOUR', 21.0, 0.0, 0.0, 0, 5.4, 4.1, 0.0, 0.0, 0.0),
    ('Shroom', 'Shroom power', 16.1, 0.0, 0.0, 0, 3.4, 0.8, 3.2, 0.0, 0.1),
    ('Christkindl', 'Christkindl Glühwein', 82.0, 0.5, 0.1, 0, 9.0, 8.5, 0.0, 0.5, 0.0),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 81.0, 1.5, 0.9, 0, 6.9, 4.8, 0.1, 10.0, 0.3),
    ('Heineken', 'Heineken Beer', 42.0, 0.0, 0.0, 0, 3.2, 0.0, 0, 0.0, 0.0),
    ('Just 0.', 'Just 0 White alcoholfree', 29.0, 0.0, 0.0, 0, 6.8, 6.3, 0, 0.0, 0.0),
    ('Just 0.', 'Just 0. Red', 22.0, 0.0, 0.0, 0, 4.9, 4.3, 0, 0.0, 0.0),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 44.1, 0.0, 0.0, 0, 3.5, 0.1, 0, 0.5, 0.0),
    ('Ikea', 'Glühwein', 77.0, 0.0, 0.0, 0, 19.0, 19.0, 0.0, 0.0, 0.0),
    ('Choya', 'Silver', 112.0, 0.0, 0.0, 0, 14.0, 14.0, 0.0, 0.0, 0.0),
    ('Carlo Rossi', 'Vin carlo rossi', 92.0, 0.0, 0, 0, 23.0, 0, 0, 0.0, 0),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 57.0, 0.0, 0.0, 0, 7.7, 7.5, 0, 0.0, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Alcohol' and p.is_deprecated is not true
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
