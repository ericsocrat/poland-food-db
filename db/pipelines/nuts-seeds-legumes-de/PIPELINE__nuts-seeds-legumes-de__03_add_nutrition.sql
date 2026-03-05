-- PIPELINE (Nuts, Seeds & Legumes): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Nuts, Seeds & Legumes'
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
    ('Ültje', 'Erdnüsse geröstet & gesalzen', 619.0, 51.0, 7.8, 0, 11.0, 5.2, 8.2, 24.0, 1.0),
    ('Ültje', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 626.0, 52.0, 7.9, 0, 11.0, 5.3, 8.3, 25.0, 0.1),
    ('Ültje', 'Erdnüsse', 620.0, 50.0, 7.7, 0, 11.0, 5.3, 8.3, 24.3, 1.0),
    ('Ültje', 'EXTRA ROAST Erdnüsse gesalzen', 600.0, 48.0, 7.5, 0, 14.0, 5.2, 7.9, 24.0, 1.4),
    ('Farmer', 'Cashewkerne - geröstet & gesalzen', 631.0, 51.0, 11.0, 0, 21.0, 7.0, 5.8, 20.0, 0.7),
    ('Maryland', 'Snack Nüsse pur', 608.0, 48.0, 7.2, 0, 13.0, 4.2, 0, 27.0, 0.0),
    ('K-Classic', 'Erdnüsse geröstet & gesalzen', 618.0, 51.0, 7.5, 0, 11.0, 6.7, 5.3, 26.0, 0.8),
    ('Ültje', 'Ofen Erdnüsse gesalzen', 598.0, 48.0, 7.6, 0, 12.0, 5.5, 9.0, 25.0, 1.3),
    ('Alesto', 'Erdnusskerne geröstet', 626.0, 51.8, 7.9, 0, 11.1, 5.3, 0, 24.7, 0.0),
    ('Aldi', 'Pistazien - geröstet & gesalzen', 605.0, 49.2, 6.3, 0, 10.3, 5.6, 7.6, 26.5, 1.8),
    ('Maryland', 'Nuss-Kern-Mischung geröstet & gesalzen', 602.0, 48.0, 7.1, 0, 12.0, 4.1, 0, 26.0, 1.0),
    ('Alesto', 'XXL Erdnüsse', 619.0, 51.2, 7.8, 0, 11.0, 5.2, 0, 24.4, 1.0),
    ('Eurofood', 'Macadamia geröstet & gesalzen', 760.0, 77.0, 13.0, 0, 4.8, 4.6, 0, 8.3, 1.0),
    ('Aldi', 'Erdnüsse in der Schale, geröstet', 617.0, 51.0, 10.0, 0, 10.0, 5.9, 0, 24.0, 0),
    ('Seeberger', 'Cashew Kerne Nüsse', 606.0, 48.0, 9.3, 0, 23.0, 6.2, 0, 19.0, 0.0),
    ('August Töpfer', 'Nuss-Mix, geröstet & gesalzen', 614.0, 51.0, 7.6, 0, 10.0, 3.8, 9.0, 25.0, 1.0),
    ('Maryland', 'Studentenfutter Berry mit Cranberries & Walnüssen', 513.0, 32.0, 4.3, 0, 37.0, 30.0, 0, 16.0, 0.0),
    ('Farmer', 'Cashewkerne - pikant gewürzt', 606.0, 48.0, 10.0, 0, 20.0, 5.0, 0, 21.0, 1.9),
    ('XOX', 'Erdnüsse geröstet ohne Salz', 624.0, 52.0, 7.8, 0, 5.3, 4.0, 0, 29.0, 0.0),
    ('Farmer', 'Pistazien - geröstet & ungesalzen', 613.3, 50.3, 6.7, 0, 11.3, 6.3, 10.0, 23.3, 0.0),
    ('K-Classic', 'Erdnüsse geröstet', 629.0, 52.0, 7.9, 0, 11.0, 5.3, 8.3, 25.0, 0.0),
    ('Maryland', 'Snack Nüsse Honig & Salz', 567.0, 41.0, 5.7, 0, 25.0, 21.0, 6.1, 22.0, 1.0),
    ('Ültje', 'Erdnüsse pikant gewürzt', 590.0, 46.0, 6.0, 0, 16.0, 5.5, 7.3, 25.0, 1.6),
    ('Farmer', 'Erdnusskerne - geröstet und gesalzen', 645.0, 53.0, 9.2, 0, 9.0, 4.2, 7.9, 29.0, 1.0),
    ('Trader Joe''s', 'Erdnüsse geröstet und gesalzen', 618.0, 51.0, 7.5, 0, 11.0, 6.7, 0, 26.0, 0.8),
    ('Ültje', 'Kessel Nüsse Paprika', 498.0, 28.0, 3.7, 0, 46.0, 7.4, 4.3, 13.0, 1.7),
    ('Farmer', 'Erdnüsse', 618.0, 51.0, 7.5, 0, 11.0, 6.7, 0, 26.0, 0.8),
    ('Ültje', 'Erdnüsse, geröstet & gesalzen', 619.0, 51.0, 7.8, 0, 11.0, 5.2, 12.0, 24.0, 1.0),
    ('K Classic', 'Erdnüsse pikant', 596.0, 47.0, 7.5, 0, 14.0, 5.8, 8.4, 25.0, 1.7),
    ('Alesto', 'Spanische Mandeln blanchiert und geröstet', 666.0, 58.6, 5.2, 0, 3.6, 3.6, 11.5, 25.3, 0.1),
    ('Ültje', 'Erdnüsse ungesalzen', 626.0, 52.0, 7.9, 0, 11.0, 5.3, 0, 25.0, 0.1),
    ('Ültje', 'Mandeln & Erdnüsse Honig und Salz', 538.0, 34.0, 4.1, 0, 37.0, 34.0, 6.7, 17.0, 0.8),
    ('Lorenz', 'NicNacs', 543.0, 35.0, 6.9, 0, 37.0, 7.1, 5.8, 17.0, 2.0),
    ('Farmer Naturals', 'Walnusskerne naturbelassen', 733.0, 70.6, 6.5, 0, 6.1, 2.7, 4.6, 16.1, 0.0),
    ('Seeberger', 'Nusskernmischung', 644.0, 57.0, 6.3, 0.0, 11.0, 4.6, 5.7, 20.0, 0.0),
    ('Fazer naturals', 'Feinste Nuss-Variation, naturbelassen', 649.0, 58.0, 5.9, 0, 10.1, 4.9, 8.2, 17.5, 0.0),
    ('Alesto', 'Mix Proteína Frutos Secos Y Soja', 586.0, 45.9, 6.7, 0, 6.8, 3.8, 11.3, 30.8, 1.0),
    ('Farmer Naturals', 'Cashewkerne naturbelassen', 603.0, 47.1, 9.3, 0, 22.2, 6.2, 3.1, 21.0, 0.0),
    ('Farmer Naturals', 'Premium-Nussmix - Fein mit Pekannusskernen', 631.0, 54.0, 5.6, 0, 9.6, 3.9, 9.0, 21.0, 0.0),
    ('Alesto Selection', 'Pecan Nuts natural', 725.0, 71.4, 6.8, 0, 4.2, 4.1, 10.0, 11.2, 0.0),
    ('Trader Joe''s', 'Walnusskerne naturbelassen', 708.0, 68.0, 6.7, 0, 5.4, 2.4, 4.6, 17.0, 0.0),
    ('Farmer Naturals', 'Simply Roasted - Cashewkerne', 606.0, 48.0, 11.0, 0, 25.0, 13.0, 3.5, 16.0, 0.0),
    ('Trader Joe''s', 'Cashewkerne, naturbelassen', 603.0, 47.1, 9.3, 0, 22.2, 6.2, 3.1, 21.0, 0.0),
    ('Farmer', 'Trail-Mix Kerne', 622.0, 52.0, 7.9, 0, 11.0, 4.4, 7.9, 25.0, 0.0),
    ('DmBio', 'Mandeln ganze Kerne', 624.0, 54.0, 4.0, 0, 5.4, 3.7, 14.0, 22.0, 0.0),
    ('Farmer Naturals', 'Simply Roasted - Nussmischung', 653.0, 58.0, 6.9, 0, 14.0, 8.4, 0, 15.0, 0.0),
    ('Trader joes', 'Pistachio mix', 608.0, 48.6, 7.0, 0, 16.8, 6.2, 7.7, 21.3, 0.8),
    ('Seeberger', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 717.0, 69.0, 6.4, 0, 6.0, 2.6, 4.5, 16.0, 0.0),
    ('Alesto', 'Cashew Nuts XXL', 600.0, 47.6, 9.0, 0, 19.8, 6.5, 5.2, 20.5, 0.0),
    ('Alesto', 'Mandeln Honig & Salz', 545.0, 35.8, 3.0, 0, 35.7, 32.6, 5.5, 17.2, 2.0),
    ('Alesto', 'Noisettes grillées', 722.0, 70.5, 6.8, 0, 3.5, 3.5, 8.2, 14.3, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Nuts, Seeds & Legumes' and p.is_deprecated is not true
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
