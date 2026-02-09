-- PIPELINE (Breakfast & Grain-Based): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
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
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 364.0, 7.3, 4.1, 0, 60.2, 10.3, 9.9, 9.4, 0.1),
    ('Biedronka', 'Vitanella Granola z czekoladą', 468.0, 18.4, 5.5, 0, 63.6, 23.2, 5.6, 9.2, 0.3),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 437.0, 14.0, 3.4, 0, 64.2, 23.1, 9.0, 9.0, 0.4),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 371.0, 6.3, 3.2, 0, 64.7, 18.7, 9.1, 9.4, 0.6),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 457.0, 17.7, 4.4, 0, 59.6, 21.1, 9.4, 10.0, 0.4),
    ('Sante', 'Masło orzechowe', 616.0, 50.0, 8.8, 0, 14.0, 9.0, 6.9, 24.0, 0.7),
    ('Łowicz', 'Dżem truskawkowy', 142.0, 0.5, 0.1, 0, 35.0, 35.0, 0, 0.5, 0.0),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 387.0, 11.2, 1.7, 0, 52.7, 8.3, 10.4, 13.7, 0.1),
    ('Laciaty', 'Serek puszysty naturalny Łaciaty', 249.0, 23.0, 16.0, 0, 4.8, 3.7, 0, 5.8, 0.3),
    ('One day more', 'Muesli Protein', 410.0, 13.9, 2.1, 0, 42.9, 13.2, 7.7, 24.2, 0.4),
    ('Vitanella', 'Musli premium', 398.0, 12.6, 6.1, 0, 59.4, 24.7, 7.7, 8.0, 0.0),
    ('Vitanella', 'Banana Chocolate musli', 430.0, 13.0, 4.0, 0, 67.0, 25.0, 7.0, 7.8, 0.2),
    ('GO ON', 'Peanut Butter Smooth', 603.0, 48.0, 6.4, 0, 12.0, 6.7, 7.6, 27.0, 0.0),
    ('Mazurskie Miody', 'Polish Honey multiflower', 319.2, 0.0, 0.0, 0, 79.5, 73.4, 0, 0.3, 0.0),
    ('Piątnica', 'Low Fat Cottage Cheese', 81.0, 3.0, 2.0, 0, 2.4, 2.0, 0, 11.0, 0.7),
    ('Mlekovita', 'Oselka', 750.0, 82.0, 54.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 387.0, 8.4, 2.9, 0, 61.4, 11.2, 9.6, 0.0, 0.0),
    ('Biedronka', 'Granola', 478.0, 21.1, 2.5, 0, 58.7, 14.3, 6.7, 9.9, 0.5)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Breakfast & Grain-Based' and p.is_deprecated is not true
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
