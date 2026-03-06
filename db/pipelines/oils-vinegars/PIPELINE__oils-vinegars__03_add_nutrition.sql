-- PIPELINE (Oils & Vinegars): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Oils & Vinegars'
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
    ('Carrefour', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 822.0, 91.4, 12.8, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Biedronka', 'Wyborny olej słonecznikowy', 828.0, 92.0, 10.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Wielkopolski', 'Wielkopolski olej słonecznikowy rafinowany', 900.0, 100.0, 11.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('OEL Polska', 'Wielkopolski olej rzepakowy tłoczony tylko raz, rafinowany.', 900.0, 100.0, 7.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('House of Asia', 'Ocet ryżowy', 42.0, 0.0, 0.0, 0, 6.0, 1.0, 0, 0.0, 0.0),
    ('ZT Kruszwica', 'Bartek olej słonecznikowy', 900.0, 100.0, 11.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 900.0, 100.0, 7.5, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia', 900.0, 100.0, 7.5, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Oliwa kaszubska', 'Olej rzepakowy tłoczony na zimno', 900.0, 100.0, 7.2, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vifon', 'Ocet ryżowy', 144.0, 0.0, 0.0, 0, 36.0, 33.0, 0.0, 0.0, 4.0),
    ('Asia Kitchen', 'Ocet ryżowy', 15.0, 0.0, 0.0, 0, 0.3, 0.2, 0, 0.2, 0.2),
    ('Mi''Ra', 'Olej z ryżu', 819.0, 91.0, 21.8, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Slonecznikowy', 'Olej wyborny', 900.0, 100.0, 11.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Komagra', 'Polski olej rzepakowy', 818.0, 91.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Wyborny Olej', 'Wyborny olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0, 0, 0.0, 0),
    ('Kujawski', 'Olej rzepakowy pomidor czosnek bazylia', 888.0, 98.0, 6.9, 0, 1.1, 0.9, 0, 0.3, 0.1),
    ('Wyborny', 'Olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Unknown', 'Olej wyborny rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Auchan', 'Rafinowany olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vitanella', 'Olej kokosowy, bezzapachowy', 900.0, 100.0, 91.0, 0, 0.5, 0.5, 0.0, 0.5, 0.0),
    ('House of Asia', 'Olej z prażonego sezamu', 894.0, 99.0, 17.0, 0, 0.0, 0, 0, 0.0, 0),
    ('Bunge', 'Optima Cardio', 540.0, 60.0, 17.0, 0, 0.0, 0.0, 0.0, 0.0, 0.5),
    ('Intenson', 'Olej kokosowy rafinowany', 833.0, 93.0, 84.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Look Food', 'Olej lniany ekologiczny', 900.0, 100.0, 12.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lewiatan', 'Olej kokosowy', 900.0, 100.0, 91.0, 0, 0.5, 0.5, 0.0, 0.5, 0.0),
    ('Coosur', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 882.0, 91.4, 12.8, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lidl Primadonna', 'Bio Hiszpańska oliwa z oliwek.', 822.0, 91.3, 13.8, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Bielmar', 'Sonnenblumen Öl', 828.0, 92.0, 6.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Oleo', 'Olej rzepakowy', 90.0, 10.0, 0.8, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Semco', 'Olej rzepakowy', 819.0, 91.0, 7.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Culineo', 'Ocet spirytusowy 10%', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('GustoBello', 'Krem z octem balsamicznym', 191.0, 0.5, 0.0, 0, 45.0, 40.0, 0.5, 0.5, 0.1),
    ('Pegaz', 'Ocet spirytusowy 10%', 0.0, 0.0, 0.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Kujawski', 'Olej 3 ziarna', 900.0, 100.0, 7.6, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Kujawski', 'Kujawski czosnek bazylia', 888.0, 98.3, 7.4, 0, 0.6, 0.0, 0, 0.2, 0.0),
    ('Biedronka', 'Olej z awokado z pierwszego tłoczenia', 822.0, 91.4, 15.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Oliver', 'Olej', 900.0, 100.0, 8.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('EkoWital', 'Ekologiczny Olej Kokosowy', 900.0, 99.9, 90.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Felix', 'Orzeszki z pieca', 598.0, 48.0, 7.6, 0, 12.0, 5.4, 8.4, 25.0, 1.5),
    ('LenVitol', 'Olej lniany', 837.0, 93.0, 9.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Olejowy Raj', 'Olej kokosowy', 900.0, 100.0, 91.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Unknown', 'Wyborny Delio', 828.0, 92.0, 7.3, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Oleofarm', 'Olej z pestek dyni', 824.0, 92.0, 16.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Semco', 'Oil', 828.0, 92.0, 8.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Premium Gold Master', 'Olej kokosowy', 900.0, 100.0, 91.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Olejarnia Świecie', 'Naturalny olej konopny', 900.0, 99.9, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Radix-Bis', 'Olej kokosowy rafinowany', 900.0, 100.0, 92.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Go Bio', 'Olej Kokosowy', 900.0, 100.0, 94.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vita Natura', 'Olej kokosowy Bio', 862.0, 100.0, 86.5, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Unknown', 'Olej kokosowy bezzapachowy rafinowany', 900.0, 100.0, 90.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Nestlé', 'Przyprawa Maggi', 20.0, 0.0, 0.0, 0, 2.2, 0.9, 0.0, 2.8, 22.8),
    ('Iorgos', 'Olive Oil', 824.0, 91.6, 12.8, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('PPHU &quot;OLMAJ&quot; Sławomir Majewski', 'Olej rzepakowy zwyczajny', 899.0, 100.0, 6.9, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Lyrakis Family', 'Oliwa z oliwek z pierwszego tłoczenia', 828.0, 92.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Suriny', 'Olej z ryżu 100%', 823.0, 91.0, 22.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Pudliszki', 'Pudliszki', 99.0, 0.5, 0, 0, 17.0, 0, 0, 5.3, 0),
    ('Primadonna', 'Extra Virgin Olive Oil', 830.0, 92.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Primadonna', 'Olivenöl (nativ, extra)', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Casa de Azeite', 'Oliwa z oliwek', 821.0, 91.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 822.0, 91.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Casa de Azeite', 'Casa de Azeite', 821.0, 91.0, 13.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Auchan', 'Auchan huile d''olive extra vierge verre 0.75l pack b', 822.0, 91.0, 13.0, 0, 0.5, 0.5, 0.5, 0.5, 0.0),
    ('Vita D''or', 'Sonnenblumenöl', 828.0, 92.0, 10.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vita D´or', 'Sonnenblumenöl', 828.0, 92.0, 10.0, 0, 0.0, 0, 0, 0.0, 0),
    ('Carrefour', 'Huile De Tournesol', 828.0, 92.0, 10.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vita d''Or', 'Rapsöl', 83.0, 9.2, 0.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vita D''or', 'Olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Kaufland', 'Rapsöl', 828.0, 92.0, 0, 0, 0.0, 0, 0, 0.0, 0),
    ('SimplCarrefour', 'Huile de Colza', 828.0, 92.0, 6.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Złote Łany', 'Olej rzepakowy', 828.0, 92.0, 6.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Vitasia', 'Vinagre de arroz', 15.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Lidl', 'Olej kokosowy', 900.0, 100.0, 92.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Carrefour', 'Huile pour friture', 828.0, 92.0, 9.3, 0, 0.0, 0.0, 0.0, 0.0, 2.0),
    ('Monini', 'Oliwa z oliwek', 828.0, 92.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Gallo', 'Olive Oil', 819.0, 91.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Oils & Vinegars' and p.is_deprecated is not true
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
