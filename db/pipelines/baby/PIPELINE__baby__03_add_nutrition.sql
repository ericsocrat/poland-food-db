-- PIPELINE (Baby): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Baby'
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
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 309.0, 11.0, 6.4, 0, 13.0, 0.5, 31.0, 24.0, 0.1),
    ('Diamant', 'Cukier Biały', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 51.0, 0.5, 0.1, 0, 13.0, 11.0, 1.3, 0.5, 0.0),
    ('OwoLovo', 'OwoLowo Jabłkowo', 50.0, 0.0, 0.0, 0, 12.0, 10.0, 0.5, 0.5, 0.0),
    ('Mlekovita', 'Bezwodny tłuszcz mleczny, Masło klarowane', 898.0, 99.8, 65.0, 0, 0.1, 0.1, 0.0, 0.1, 0.0),
    ('Vital Fresh', 'Surówka Smakołyk', 91.0, 5.3, 0.4, 0, 8.2, 6.1, 2.2, 1.6, 0.7),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 56.0, 1.8, 0.2, 0, 6.3, 2.8, 1.1, 3.1, 0.1),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 428.0, 12.0, 2.7, 0, 61.0, 31.0, 5.9, 16.0, 0.3),
    ('Polski Cukier', 'Cukier biały', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('Piątnica', 'Twaróg wiejski tłusty', 147.0, 8.0, 4.8, 0, 3.7, 3.7, 0, 15.0, 0.1),
    ('Vital Fresh', 'Mus 100% owoców jabłko gruszka', 54.0, 0.0, 0.0, 0, 13.0, 12.0, 0.5, 0.5, 0.0),
    ('kubuś', 'kubuś malina', 39.0, 0.5, 0.1, 0, 8.0, 7.6, 1.4, 0.5, 0.1),
    ('owolovo', 'mus jabłkowo-malinowo', 46.0, 0.0, 0.0, 0, 9.8, 9.0, 1.5, 0.4, 0.0),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 88.0, 1.2, 0.7, 0, 9.0, 9.0, 0, 10.2, 0.1),
    ('Nestlé', 'Barszcz czerwony', 114.0, 1.1, 0.6, 0, 25.0, 19.2, 0.3, 1.1, 4.7),
    ('Swojska Chata', 'Pierogi ruskie', 164.0, 4.1, 0.7, 0, 25.0, 1.4, 2.3, 5.7, 1.0),
    ('Kraina Wędlin', 'POLĘDWICA SOPOCKA', 97.1, 2.6, 1.1, 0, 1.4, 1.4, 0, 17.4, 2.2),
    ('Kapitan navi', 'Śledzie po kołobrzesku', 402.0, 41.0, 3.7, 0, 0.7, 0.7, 0, 7.5, 2.7),
    ('Magnetic', 'QuickCao', 370.0, 2.1, 1.3, 0, 80.0, 78.0, 6.3, 4.5, 0.1),
    ('Królewski', 'Cukier 1 kg', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('Nestlé', 'Przyprawa Maggi', 20.0, 0.0, 0.0, 0, 2.2, 0.9, 0.0, 2.8, 22.8),
    ('Gryzzale', 'polutry kabanos sausages', 290.0, 18.0, 6.4, 0, 5.8, 1.7, 0, 24.0, 2.3),
    ('Dania Express Biedronka', 'Lasagne Bolognese', 172.0, 8.8, 3.6, 0, 15.0, 1.5, 1.5, 7.5, 1.0),
    ('Owolovo', 'Owolovo ananasowo', 46.0, 0.0, 0.0, 0, 10.0, 9.5, 1.7, 0.5, 0.0),
    ('Tarczyński', 'Kabanosy Z Kurczaka Protein', 309.0, 14.0, 4.2, 0, 4.9, 1.6, 0.0, 40.0, 3.4),
    ('OWOLOVO', 'BRZOSKWINIOWO', 49.0, 0.2, 0.1, 0, 14.0, 12.0, 1.3, 0.4, 0.0),
    ('Leibniz', 'Minis classic', 449.0, 12.0, 7.8, 0, 76.0, 23.0, 2.2, 8.1, 0.6),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 80.0, 3.1, 0.6, 0, 10.1, 3.0, 0, 0.1, 0.0),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 51.1, 0.1, 0.0, 0, 11.6, 6.9, 1.1, 0.3, 0.0),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', 75.0, 3.0, 0.7, 0, 8.2, 3.1, 0, 3.2, 0.1),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 70.0, 2.4, 0.7, 0, 9.0, 2.3, 1.5, 2.4, 0.2),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 42.0, 0.2, 0, 0, 8.7, 8.3, 2.0, 0.4, 0),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 78.0, 3.0, 1.4, 0, 10.7, 4.8, 0.4, 1.9, 0.1),
    ('Pudliszki', 'Pudliszki', 99.0, 0.5, 0, 0, 17.0, 0, 0, 5.3, 0),
    ('Kamis', 'Kamis Musztarda Kremska 185G.', 96.0, 4.2, 1.6, 0, 7.8, 7.6, 0, 4.5, 2.1),
    ('tarczyński', 'gryzzale', 381.0, 29.0, 12.0, 0, 3.9, 1.1, 0, 26.0, 2.2),
    ('Dolina Dobra', '5908226815710', 321.0, 29.0, 11.0, 0, 3.5, 1.8, 0, 13.0, 2.2),
    ('Hyperfood', 'Eatyx Wanilla', 68.0, 3.8, 0.3, 0, 3.6, 0.5, 1.2, 4.2, 0.2),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 81.0, 1.5, 0.9, 0, 6.9, 4.8, 0.1, 10.0, 0.3),
    ('Vitanella', 'Ciastka Czekolada & Zboża', 419.0, 12.0, 3.6, 0, 64.0, 28.0, 9.3, 9.1, 0.6),
    ('Vitanella', 'Baton select orzeszki ziemne, migdały, sól morska', 557.0, 40.2, 5.8, 0, 33.1, 25.5, 6.4, 12.6, 0.6),
    ('Maribel', 'Ahorn sirup', 349.0, 0.0, 0.0, 0, 87.2, 81.5, 0, 0.0, 0.0),
    ('Nestlé', 'Nestle Sinlac', 431.0, 11.5, 0.9, 0, 64.6, 4.5, 3.8, 15.3, 0.1),
    ('Hipp', 'Dynia z indykiem', 59.0, 2.5, 0.4, 0, 5.7, 2.9, 0, 2.9, 0.1),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 63.0, 0.5, 0.1, 0, 13.0, 12.0, 0, 0.6, 0.0),
    ('Go active', 'Pudding proteinowy', 76.0, 1.3, 0.8, 0, 6.0, 4.4, 0.1, 10.0, 0.3),
    ('Nestlé', 'Bulion drobiowy', 6.0, 0.3, 0.1, 0, 0.5, 0.4, 0, 0.2, 0.8),
    ('GO Active', 'pudding czekolada', 81.0, 1.5, 1.0, 0, 6.4, 5.2, 0.9, 10.0, 0.0),
    ('Tastino', 'Papryka Barbecue', 412.0, 8.5, 0.8, 0, 75.0, 3.3, 2.9, 7.4, 1.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Baby' and p.is_deprecated is not true
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
