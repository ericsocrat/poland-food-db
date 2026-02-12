-- PIPELINE (Nuts, Seeds & Legumes): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
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
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 641.0, 57.0, 5.9, 0, 5.7, 4.9, 13.0, 20.0, 0.0),
    ('Bakador', 'Pistacje niesolone prażone', 618.0, 50.0, 6.4, 0, 11.0, 11.0, 11.0, 25.0, 0.0),
    ('Top', 'Orzechy ziemne prażone nieslone', 632.0, 53.0, 6.9, 0, 5.0, 4.2, 9.3, 30.0, 0.0),
    ('Bakallino', 'Migdały', 604.0, 52.0, 4.7, 0, 7.6, 4.9, 13.0, 20.0, 0.0),
    ('Makar Bakalie', 'Migdały', 604.0, 52.0, 4.7, 0, 7.6, 4.9, 0, 20.0, 0.0),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', 586.0, 47.0, 6.3, 0, 13.0, 5.1, 13.0, 21.0, 1.5),
    ('Bakador', 'BakaDOr. Orzechy włoskie', 689.0, 64.0, 5.6, 0, 7.5, 2.7, 7.1, 0.0, 0.0),
    ('Spar', 'Orzeszki ziemne prażone', 615.0, 50.0, 7.7, 0, 13.0, 4.9, 8.4, 24.0, 0.0),
    ('Baka D''or', 'Orzechy włoskie', 666.0, 60.0, 6.6, 0, 12.0, 9.9, 6.5, 16.0, 0.0),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 609.0, 49.0, 7.8, 0, 12.0, 5.6, 8.6, 26.0, 0.0),
    ('Felix', 'Orzeszki ziemne smażone i solone', 615.0, 51.0, 7.8, 0, 11.0, 5.3, 8.2, 25.0, 1.2),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 518.0, 30.0, 4.1, 0, 44.0, 9.2, 0, 14.0, 2.5),
    ('Bakador', 'Orzechy włoskie', 689.0, 64.0, 5.6, 0, 7.5, 2.7, 7.1, 17.0, 0.0),
    ('Felix', 'Orzeszki długo prażone extra chrupkie', 601.0, 48.0, 7.5, 0, 13.0, 5.3, 8.1, 24.0, 1.6),
    ('Bakalland', 'Orzechy makadamia łuskane', 753.0, 76.0, 12.0, 0, 5.6, 4.6, 8.6, 7.9, 0.0),
    ('Bakallino', 'Migdały łuskane', 604.0, 52.0, 4.7, 0, 7.6, 4.9, 13.0, 20.0, 0.0),
    ('Unknown', 'Orzechy nerkowca połówki', 582.0, 43.9, 7.8, 0, 26.9, 5.9, 3.3, 18.2, 0.0),
    ('Kresto', 'Mix orzechów', 611.0, 52.0, 7.1, 0, 8.4, 4.3, 11.0, 23.0, 0.0),
    ('Felix', 'Carmelove z wiórkami kokosowymi', 532.0, 33.0, 5.9, 0, 41.0, 35.0, 5.6, 16.0, 0.0),
    ('Felix', 'Orzeszki ziemne prażone', 609.0, 49.0, 7.8, 0, 12.0, 5.6, 8.6, 26.0, 0.0),
    ('Aga Holtex', 'Migdały', 604.0, 52.0, 4.7, 0, 7.6, 4.9, 13.0, 20.0, 0.0),
    ('BakaD''Or', 'Migdały łuskane kalifornijskie', 596.0, 49.0, 3.9, 0, 8.0, 4.6, 12.0, 24.0, 0),
    ('Felix', 'Orzeszki z pieca z solą', 598.0, 48.0, 7.6, 0, 12.0, 5.4, 8.4, 25.0, 1.5),
    ('Ecobi', 'Orzechy włoskie łuskane', 654.0, 65.2, 6.1, 0, 17.7, 2.6, 6.7, 15.2, 0.0),
    ('Green Essence', 'Migdały naturalne całe', 621.0, 52.0, 4.7, 0, 7.6, 4.9, 12.9, 24.1, 0.0),
    ('brat.pl', 'Orzechy brazylijskie połówki', 726.0, 67.1, 16.3, 0, 11.7, 2.3, 7.5, 14.3, 1.0),
    ('Carrefour Extra', 'Migdały łuskane', 606.0, 52.0, 4.7, 0, 7.6, 4.9, 14.0, 20.0, 0.1),
    ('Felix', 'Felix orzeszki ziemne', 615.0, 51.0, 7.8, 0, 11.0, 5.3, 8.2, 25.0, 1.2),
    ('BakaD''Or', 'Mieszanka egzotyczna', 454.0, 24.0, 12.0, 0, 49.0, 49.0, 7.4, 6.7, 0.1),
    ('Felix', 'Orzeszki ziemne lekko solone', 615.0, 51.0, 7.7, 0, 11.0, 5.3, 8.2, 25.0, 0.7),
    ('BakaD''Or', 'Orzechy Nerkowca', 587.0, 45.0, 8.3, 0, 24.0, 6.1, 5.1, 20.0, 0.0),
    ('Bakador', 'Orzechy pekan', 721.0, 72.0, 6.2, 0, 4.3, 4.0, 9.6, 9.2, 0.0),
    ('Top', 'Orzeszki Top smak papryka', 524.0, 31.0, 4.0, 0, 43.0, 9.0, 4.7, 15.0, 2.5),
    ('Bakador', 'Mieszanka orzechowa', 632.0, 55.0, 6.5, 0, 11.0, 4.2, 8.8, 19.0, 0.0),
    ('Top Biedronka', 'Orzeszki ziemne prażone', 609.0, 49.0, 7.8, 0, 12.0, 5.6, 8.6, 26.0, 0.0),
    ('Bakador', 'Orzechy brazylijskie', 693.0, 67.0, 16.0, 0, 4.2, 2.3, 7.5, 14.0, 0.0),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', 518.0, 30.0, 4.0, 0, 44.0, 8.8, 0, 14.0, 2.7),
    ('Bakador', 'Orzechy nerkowca', 571.0, 45.0, 8.5, 0, 23.0, 8.5, 3.2, 17.0, 0.0),
    ('Unknown', 'Migdały łuskane', 604.0, 52.0, 4.7, 0, 7.6, 4.9, 13.0, 20.0, 0.1),
    ('Helio S.A.', 'Mieszanka Studencka', 476.0, 30.0, 3.7, 0, 32.0, 29.0, 7.3, 15.0, 0.1),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', 520.0, 30.0, 4.1, 0, 45.0, 8.4, 0, 15.0, 1.9),
    ('Makar', 'Orzechy Brazylijskie', 684.0, 66.0, 15.0, 0, 4.8, 2.3, 0, 14.0, 0.0),
    ('Spar', 'Mieszanka Studencka', 385.0, 26.0, 3.6, 0, 24.0, 19.0, 5.2, 11.0, 0.0),
    ('Felix', 'Orzeszki ziemne solone', 609.0, 50.0, 7.7, 0, 11.0, 5.2, 8.2, 24.0, 1.2),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 610.0, 49.2, 7.8, 0, 11.6, 5.6, 0, 25.8, 0.0),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 614.0, 50.0, 7.8, 0, 12.0, 5.5, 8.3, 24.0, 0.7)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
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
