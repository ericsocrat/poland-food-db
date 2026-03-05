-- PIPELINE (Baby): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Baby'
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
    ('Hipp', 'Reine Bio-Karotten mild-süßlich', 30.0, 0.1, 0.0, 0, 5.0, 4.3, 0, 0.7, 0.1),
    ('Hipp', 'Früchte Riegel Joghurt-Kirsch in Banane', 348.0, 6.1, 0.7, 0, 64.8, 39.3, 0, 6.3, 0.1),
    ('Mamia Bio', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 56.0, 0.5, 0.1, 0, 11.0, 9.8, 0, 0.5, 0.0),
    ('Hipp', 'Gemüse Allerlei', 40.0, 1.3, 0.1, 0, 4.7, 2.2, 0, 1.2, 0.1),
    ('DmBio', 'Kürbis pur', 27.0, 0.5, 0.1, 0, 4.4, 3.7, 2.1, 1.0, 0),
    ('Bebivita', 'Mini-Makkaroni mit buntem Rahmgemüse', 70.0, 2.3, 0.9, 0, 9.7, 1.7, 0.8, 2.1, 0.5),
    ('Hipp', 'Reiner Butternut Kürbis', 33.0, 0.3, 0.1, 0, 6.0, 4.2, 0, 1.0, 0.1),
    ('Hipp', 'Menü Karotten, Kartoffeln, Wildlachs', 70.0, 2.6, 0.3, 0, 8.4, 1.4, 0, 2.5, 0.5),
    ('Hipp', 'Gemüse Kürbis Nach Dem 4. Monat', 171.0, 0.2, 0.0, 0, 8.1, 3.1, 0, 1.2, 0.1),
    ('Puttkammer', 'Schinkenröllchen in Aspik', 151.0, 8.6, 1.7, 0, 6.2, 6.0, 0, 22.4, 1.5),
    ('Hipp', 'Mango-Bananen-Grieß', 65.0, 0.2, 0.0, 0, 14.8, 10.5, 0, 1.1, 0),
    ('Hipp', 'Spinatgemüse in Kartoffeln', 60.0, 2.1, 0.6, 0, 7.7, 2.3, 0, 2.0, 0.1),
    ('Bebivita', 'Abendbrei Grieß-Vanille', 55.0, 1.5, 1.0, 0, 7.8, 2.5, 0.3, 2.4, 0.0),
    ('Hipp', 'Grießbrei', 76.0, 3.3, 1.5, 0, 8.6, 2.8, 0, 2.8, 0.1),
    ('Hipp', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 75.0, 2.9, 0.9, 0, 8.4, 2.1, 0, 3.2, 0.1),
    ('Hipp', 'Gemüse Lasagne', 71.0, 2.8, 0.7, 0, 8.6, 2.4, 0, 2.4, 0.1),
    ('Bebivita', 'Gemüse-Spätzle-Pfanne', 65.0, 2.4, 0.8, 0, 7.5, 1.7, 1.2, 2.7, 0.3),
    ('DmBio', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 61.0, 1.9, 0.5, 0, 7.9, 1.2, 1.3, 2.5, 0.0),
    ('Hipp', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 65.0, 2.6, 0.6, 0, 7.5, 1.4, 0, 2.3, 0.1),
    ('Hipp', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 72.0, 2.5, 0.4, 0, 9.2, 1.3, 0, 3.1, 0.3),
    ('Hipp', 'Erdbeere in Apfel-Joghurt-Müsli', 59.0, 1.4, 0.8, 0, 9.5, 4.8, 0, 0.0, 0.0),
    ('Hipp', 'Gartengemüse Mit Pute Und Rosmarin', 70.0, 2.7, 0.5, 0, 8.1, 1.5, 0, 2.5, 0.2),
    ('Hipp', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 78.0, 3.2, 0.6, 0, 9.6, 0.9, 0, 2.7, 0.1),
    ('Hipp', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 73.0, 2.9, 0.7, 0, 8.8, 1.3, 0, 2.4, 0.3),
    ('Hipp', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 66.0, 2.0, 1.1, 0, 9.0, 3.8, 0, 2.8, 0.1),
    ('Hipp', 'Hippis Pfirsich Banane Mango Joghurt', 70.0, 0.7, 0.3, 0, 14.0, 9.9, 0, 1.4, 0.1),
    ('DmBio', 'Hirse Getreidebrei', 391.0, 3.8, 0.6, 0, 77.1, 0.6, 3.3, 10.4, 0.0),
    ('Hipp', 'Pfirsich in Apfel (ab 5. Monat)', 46.0, 0.1, 0.0, 0, 10.8, 10.2, 0, 0.4, 0.1),
    ('Hipp', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 224.0, 0.2, 0.0, 0, 11.1, 9.6, 0, 0.4, 0),
    ('Unknown', 'Apfel Bananen müesli', 65.0, 0.6, 0.2, 0, 13.0, 9.0, 0, 1.2, 0.1),
    ('DmBio', 'Apfel mit Banane & Hirse (ab 6. Monat)', 66.0, 0.5, 0.2, 0, 13.4, 9.9, 1.7, 0.8, 0.0),
    ('Hipp', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 53.0, 0.3, 0.0, 0, 11.6, 7.9, 0, 0.9, 0.1),
    ('Bebivita', 'Anfangsmilch', 67.0, 3.6, 1.5, 0, 7.3, 6.1, 0, 1.4, 0),
    ('Hipp Bio', 'Himbeer Reiswaffeln', 386.0, 0.8, 0.1, 0, 88.6, 8.3, 0.8, 7.4, 0.0),
    ('Hipp', 'Bio Combiotik Pre', 66.0, 3.6, 1.5, 0, 7.0, 7.0, 0.3, 1.3, 0.1),
    ('Dr. Oetker', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 55.0, 0.1, 0.0, 0, 12.1, 11.1, 0, 0.5, 0.1),
    ('Hipp', 'Urkorn Dinos', 362.0, 1.6, 0.3, 0, 75.0, 6.9, 5.8, 11.9, 0),
    ('Bebivita', 'Reis mit Karotten und Pute', 58.0, 2.2, 0.4, 0, 6.7, 1.8, 1.3, 2.3, 0.1),
    ('Hipp', 'Hipp', 70.0, 2.4, 0.4, 0, 8.7, 1.5, 0, 2.7, 0.3),
    ('Hipp', 'Hippis Apfel-Birne-Banane', 60.0, 0.2, 0.0, 0, 12.9, 11.3, 0, 0.0, 0.1),
    ('Milupa', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 51.0, 2.2, 0.3, 0, 5.3, 5.0, 0.8, 1.9, 0.1),
    ('Hipp', 'Apfel Banane in Babykeks', 74.0, 0.7, 0.4, 0, 15.1, 10.9, 0, 1.0, 0.0),
    ('Hipp', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 56.0, 0.4, 0.2, 0, 10.9, 6.3, 0, 1.8, 0),
    ('Hipp', 'Hipp Guten Morgen', 59.0, 1.4, 0.8, 0, 9.8, 4.7, 0, 1.7, 0.1),
    ('DmBio', 'Babyobst', 62.0, 0.3, 0.0, 0, 12.4, 10.2, 0, 0.5, 0),
    ('Kölln', 'Schmelzflocken 5 korn 6. Monat', 353.0, 4.4, 0.9, 0, 63.0, 2.1, 11.0, 11.0, 0.0),
    ('Hipp', 'Heidelbeer reiswaffeln', 393.0, 0.8, 0.1, 0, 88.1, 8.5, 1.4, 7.6, 0.0),
    ('Hipp', 'BIO Getreidebrei 5-Korn', 381.0, 3.9, 0.6, 0, 69.7, 1.8, 0, 12.1, 0),
    ('Hipp', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 74.0, 0.7, 0.4, 0, 15.1, 10.9, 0, 1.0, 0.1),
    ('Hipp', 'Hipp, Karotten Mit Reis Und Wildlachs', 65.0, 2.5, 0.3, 0, 6.8, 2.7, 0, 3.0, 0.1),
    ('Bebivita', 'Pfirsich mit Maracuja in Apfel', 49.0, 0.1, 0.0, 0, 10.7, 10.1, 1.7, 0.4, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Baby' and p.is_deprecated is not true
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
