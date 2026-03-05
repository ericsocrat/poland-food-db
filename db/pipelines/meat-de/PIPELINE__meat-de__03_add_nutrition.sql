-- PIPELINE (Meat): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Meat'
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
    ('Herta', 'Hähnchenbrust', 104.0, 1.8, 0.6, 0, 1.0, 1.0, 0, 21.0, 2.1),
    ('Frosta', 'Hähnchen Paella', 125.0, 4.7, 1.3, 0, 14.0, 2.2, 1.3, 6.1, 1.0),
    ('Gut Drei Eichen', 'Herzhafte Edelsalami, geräuchert', 379.0, 32.0, 13.0, 0, 0.5, 0.5, 0, 22.0, 3.6),
    ('Güldenhof', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 83.3, 3.4, 0.4, 0, 2.1, 1.3, 0, 21.4, 1.3),
    ('Allfein Feinkost', 'Hähnchen-Knusper-Dinos', 217.0, 11.3, 1.1, 0, 14.6, 1.0, 1.1, 13.6, 1.4),
    ('Güldenhof', 'Mini-Wiener - Geflügel', 249.0, 21.0, 6.7, 0, 1.0, 0.8, 0, 14.0, 2.2),
    ('Güldenhof', 'Geflügel-Paprikalyoner', 234.0, 20.0, 8.0, 0, 1.5, 1.4, 0, 12.0, 2.2),
    ('Adler Schwarzwald', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 243.0, 15.0, 6.4, 0, 1.0, 1.0, 0, 26.0, 5.5),
    ('Bio', 'Bio-Salami - geräuchert mit grünem Pfeffer', 331.0, 27.0, 11.0, 0, 1.0, 1.0, 0, 21.0, 3.7),
    ('Güldenhof', 'Geflügel-Mortadella', 228.0, 20.0, 8.0, 0, 0.0, 0.0, 0, 12.0, 2.0),
    ('Böklunder', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 231.0, 19.0, 5.7, 0, 1.0, 1.0, 0, 14.0, 2.0),
    ('Dulano', 'Geflügel Wiener', 223.0, 18.0, 5.8, 0, 1.2, 1.0, 0, 14.0, 1.7),
    ('Familie Wein', 'Schwarzwälder Schinken', 243.0, 15.0, 6.4, 0, 1.0, 0.5, 0, 26.0, 5.5),
    ('Zimmermann', 'Weißwurst', 273.0, 25.0, 10.0, 0, 1.0, 0.5, 0, 11.0, 1.6),
    ('Rügenwalder Mühle', 'Mühlen Frikadellen 100% Geflügel', 196.0, 13.0, 4.0, 0, 5.7, 2.1, 0, 14.0, 2.0),
    ('Gut Drei Eichen', 'Katenschinken-Würfel', 219.0, 14.0, 5.2, 0, 1.0, 1.0, 0, 22.0, 5.0),
    ('Bernard Matthews Oldenburg', 'Hähnchen Filetstreifen', 137.4, 4.0, 0.6, 0, 2.0, 0.8, 0, 23.0, 2.5),
    ('Gut Drei Eichen', 'Münchner Weißwurst', 280.0, 23.0, 9.7, 0, 6.8, 6.5, 0, 11.0, 1.8),
    ('Gutfried', 'Geflügelwurst', 231.8, 20.0, 6.0, 0, 0.5, 0.5, 0, 13.0, 2.2),
    ('Ferdi Fuchs', 'Wurst Ferdi Fuchs Mini Würstschen', 268.0, 24.0, 10.0, 0, 1.0, 0.8, 0, 12.0, 1.7),
    ('Reinert', 'Bärchenwurst', 192.0, 15.0, 6.0, 0, 1.0, 0.5, 0.3, 13.0, 2.3),
    ('Meine Metzgerei', 'Puten-Hackfleisch Frisch; gewürzt; zum Braten Aus der Frischetruhe Dauertiefpreis 2.49€ 400g Packung 1kg 6.23€', 159.0, 9.8, 3.3, 0, 0.7, 0.0, 0, 17.0, 0.0),
    ('Gutfried', 'Hähnchenbrust', 92.0, 1.5, 0.5, 0, 0.5, 0.5, 0, 19.0, 2.2),
    ('Meica', 'Geflügelwürstchen', 148.0, 10.0, 3.0, 0, 0.5, 0.0, 0, 14.0, 1.9),
    ('Dulano', 'Delikatess Hähnchenbrust', 105.0, 2.0, 0.8, 0, 1.5, 1.0, 0, 20.0, 1.6),
    ('Reinert', 'Bärchen SchlaWiener', 275.0, 24.0, 9.6, 0, 1.0, 0.5, 0, 13.5, 2.0),
    ('Sprehe Feinkost', 'Hähnchen-Brustfiletstreifen', 118.0, 2.2, 1.1, 0, 0.7, 0.0, 0.0, 23.9, 1.1),
    ('Reinert', 'Bärchen-Wurst', 192.0, 15.0, 6.0, 0, 1.0, 0.5, 0.3, 13.0, 2.3),
    ('Gutfried', 'Gutfried - Hähnchen-Salami', 287.0, 21.0, 10.5, 0, 1.0, 0.5, 0, 23.0, 3.7),
    ('Meica', 'Meica Geflügel-Wiener 4000503148601 Geflügel-Wiener im Saitling', 157.0, 11.0, 3.0, 0, 0.5, 0.5, 0, 14.0, 1.9),
    ('Dulano', 'Wurst - Geflügel-Leberwurst', 224.0, 17.0, 5.4, 0, 2.0, 1.5, 0, 15.7, 1.7),
    ('Aldi Meine Metzgerei', 'Hähnchenbrust', 110.0, 2.0, 0.6, 0, 0.5, 0.5, 0, 23.0, 0.1),
    ('Herta', 'FARMERSCHINKEN mit Honig verfeinert und über Buchenholz geräuchert, gegart', 107.0, 2.5, 0.9, 0, 1.0, 1.0, 0, 20.0, 2.3),
    ('Gutfried', 'Hähnchenbrust Kirschpaprika', 94.0, 2.0, 0.6, 0, 1.0, 1.0, 0, 18.0, 2.2),
    ('Kupfer', 'Original Nürnberger Rostbratwürste', 351.0, 32.0, 12.0, 0, 1.0, 1.0, 0, 14.0, 2.0),
    ('Kamar', 'Geflügelbratwurst', 221.0, 18.0, 5.2, 0, 1.8, 0.5, 0, 13.0, 5.2),
    ('Meica', 'Zutat: Würstchen - Wiener Art', 248.0, 22.0, 8.8, 0, 0.5, 0.5, 0, 12.0, 1.8),
    ('Gutfried', 'Hähnchenbrust, gepökelt und gebraten', 96.0, 2.0, 0.6, 0, 1.5, 1.0, 0, 18.0, 2.2),
    ('Herta', 'Schinken', 101.0, 1.9, 0.8, 0, 1.0, 1.0, 0, 20.0, 2.3),
    ('Gut Drei Eichen', 'Schinken-Lyoner', 270.0, 24.0, 9.2, 0, 0.5, 0.5, 0, 13.0, 1.7),
    ('Herta', 'Schinken gegart ofengegrillt', 102.0, 2.0, 0.9, 0, 1.0, 1.0, 0, 20.0, 2.5),
    ('Nestlé', 'Saftschinken', 107.0, 2.5, 0.9, 0, 1.0, 1.0, 0.5, 20.0, 2.3),
    ('Ponnath Die Meistermetzger', 'Delikatess Prosciutto Cotto', 108.0, 2.5, 1.6, 0, 1.0, 0.8, 0, 20.0, 3.1),
    ('Bio', 'Bio-Salami - luftgetrocknet', 336.0, 27.5, 11.5, 0, 1.0, 0.5, 0, 21.0, 3.8),
    ('Abraham', 'Jamón Serrano Schinken', 232.0, 12.0, 4.5, 0, 1.0, 1.0, 0, 30.0, 4.9),
    ('Zimbo', 'Schinken Zwiebelmettwurst fettreduziert', 157.0, 9.0, 3.6, 0, 1.0, 1.0, 0, 18.0, 2.5),
    ('K-Classic', 'Kochhinterschinken', 101.0, 2.0, 1.3, 0, 1.0, 0.9, 0, 19.7, 1.9),
    ('Herta', 'Schinken Belem Pfeffer', 102.0, 2.0, 0.8, 0, 1.0, 1.0, 0, 20.0, 2.6),
    ('Steinhaus', 'Bergische Salami', 336.0, 28.0, 11.0, 0, 1.0, 0.5, 0, 20.0, 2.6),
    ('Meica', 'Curryking fix & fertig', 215.0, 15.0, 5.5, 0, 12.0, 12.0, 0, 8.0, 1.6),
    ('Reinert', 'Schinken Nuggets', 140.0, 3.0, 1.2, 0, 1.0, 0.5, 0, 27.0, 4.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Meat' and p.is_deprecated is not true
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
