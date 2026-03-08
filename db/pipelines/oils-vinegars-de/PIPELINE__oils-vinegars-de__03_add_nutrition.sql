-- PIPELINE (Oils & Vinegars): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Oils & Vinegars'
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
    ('Bellasan', 'Natives Olivenöl Extra', 824.0, 91.6, 13.5, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Primadonna', 'Natives Olivenöl Extra', 824.0, 91.6, 14.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('DmBio', 'Natives Olivenöl extra', 824.0, 92.0, 16.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lyttos', 'Olivenöl', 828.0, 92.0, 14.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('DmBio', 'Bratolivenöl', 824.0, 92.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Camaletti', 'Camaletti Olivenöl', 822.0, 91.3, 13.4, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Gut Bio', 'Natives Olivenöl Extra', 824.0, 92.0, 14.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Lyttos', 'Griechisches natives Olivenöl extra', 824.0, 91.6, 77.4, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Primadonna', 'Brat Olivenöl', 824.0, 91.6, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Primadonna', 'Olivenöl (nativ, extra)', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Aldi', 'Griechisches natives Olivenöl Extra', 822.0, 91.0, 12.0, 0, 0.5, 0.5, 0, 0.5, 0),
    ('Bellasan', 'Oliven Öl', 822.0, 91.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('K-Classic', 'Natives Olivenöl extra', 807.4, 91.0, 14.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lidl', 'Natives Olivenöl extra aus Griechenland', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('DmBio', 'Natives Olivenöl extra naturtrüb', 824.0, 92.0, 14.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Cucina Nobile', 'Natives Olivenöl', 824.0, 91.0, 12.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Aldi Bellasan', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 822.0, 91.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Bellasan', 'Olivenöl', 824.0, 92.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Aldi', 'Natives Olivenöl Extra', 824.0, 92.0, 13.0, 0, 0.5, 0.5, 0, 0.5, 0),
    ('Primadonna', 'Olivenöl', 824.0, 91.6, 14.3, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Rapunzel', 'Ö-Kreta Olivenöl nativ extra-10,48€/29.6.22', 819.0, 91.0, 14.7, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Ener Bio', 'Griechisches natives Olivenöl e', 824.0, 92.0, 16.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Deluxe', 'Olivenöl', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('K Favorites', 'Natives Olivenöl Extra', 824.0, 92.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Rapunzel', 'Olivenöl fruchtig', 900.0, 100.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Rapunzel', 'Olivenöl nativ extra mild', 900.0, 100.0, 21.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Rapunzel', 'Ölivenöl Finca la Torre', 900.0, 100.0, 14.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Biozentrsle', 'Olivenöl', 828.0, 92.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Deluxe', 'Öl - Olivenöl Extra G.G.A. Chania Kritis', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Dennree', 'Olivenöl nativ extra', 824.0, 92.0, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Rapunzel', 'Rapunzel Olivenöl Fruchtig, Nativ Extra, 0,5 LTR Flasche', 900.0, 100.0, 14.1, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Bertolli', 'Natives Olivenöl Originale', 821.0, 91.0, 15.0, 0, 0.0, 0, 0, 0.0, 0.0),
    ('Rewe', 'Natives Olivenöl Extra', 824.0, 91.6, 13.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Edeka Bio', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 824.0, 91.6, 14.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Alnatura', 'Olivenöl', 828.0, 92.0, 14.0, 0, 0.5, 0.5, 0.5, 0.5, 0.0),
    ('Gut & Günstig', 'Olivenöl Extra Natives', 822.0, 91.3, 13.3, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('D.O.P. Terra Di Bari Castel Del Monte', 'Italienisches natives Olivenöl extra', 822.0, 91.0, 13.0, 0, 0.0, 0, 0, 0.0, 0),
    ('Bertolli', 'Olivenöl Natives Extra Gentile SANFT', 821.0, 91.0, 15.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('BioBio', 'Natives Bio-Olivenöl Extra', 822.0, 91.3, 13.4, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('EDEKA Bio', 'Natives Olivenöl extra', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Rewe beste Wahl', 'Olivenöl ideal für warme Speisen', 822.0, 91.3, 14.1, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Ja!', 'Natives Olivenöl Extra', 824.0, 92.0, 15.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('La Espaniola', 'Natives Ölivenöl extra', 822.0, 92.0, 12.8, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Las Cuarenta', 'Spanisches Natives Olivenöl extra', 823.0, 91.4, 12.8, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Natur Gut', 'Natives Olivenöl Extra', 824.0, 91.6, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Bio', 'Bio natives Olivenöl', 824.0, 92.0, 16.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Primadonna', 'Bio natives Olivenöl extra', 824.0, 91.6, 13.2, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vegola', 'Natives Olivenöl extra', 822.0, 91.3, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Fiore', 'Natives Olivenöl Extra', 822.0, 91.3, 13.7, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('REWE Feine Welt', 'Natives Olivenöl Extra Lesvos g.g.A.', 824.0, 92.0, 13.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Edeka', 'Griechisches Natives Olivenöl Extra', 824.0, 91.6, 14.2, 0, 0.0, 0.0, 0.0, 0.0, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
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
