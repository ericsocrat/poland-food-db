-- PIPELINE (Bread): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Bread'
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
    ('Gräfschafter', 'Eiweißreiches Weizenvollkornbrot', 267.7, 11.1, 1.7, 0, 15.7, 1.4, 6.9, 23.1, 1.1),
    ('Harry', 'Körner Balance Sandwich', 258.0, 6.0, 0.5, 0, 39.5, 3.4, 6.0, 8.7, 0.4),
    ('Golden Toast', 'Sandwich Körner-Harmonie', 299.0, 8.5, 0.8, 0, 42.7, 3.5, 5.3, 10.1, 1.1),
    ('Lieken Urkorn', 'Fitnessbrot mit 5 % Ölsaaten', 232.7, 5.3, 0.5, 0, 34.0, 4.4, 7.1, 9.1, 1.1),
    ('Harry', 'Eiweißbrot', 256.0, 7.5, 1.1, 0, 29.0, 2.5, 6.1, 15.0, 1.0),
    ('Harry', 'Harry Dinkel Krüstchen 4071800057637', 257.0, 1.5, 0.7, 0, 49.0, 2.6, 3.5, 10.0, 1.3),
    ('Aldi', 'Das Pure - Bio-Haferbrot mit 29% Ölsaaten', 296.0, 18.1, 2.5, 0, 18.3, 0.7, 8.1, 10.9, 1.0),
    ('Conditorei Coppenrath & Wiese', 'Weizenbrötchen', 271.0, 1.9, 0.4, 0, 53.0, 2.2, 0, 9.0, 1.5),
    ('Lieken', 'Roggenbäcker', 223.0, 1.1, 0.2, 0, 42.0, 2.3, 5.3, 8.6, 1.1),
    ('Goldähren', 'Französisches Steinofen-Baguette', 251.0, 1.0, 0.3, 0, 50.0, 2.8, 3.4, 8.3, 1.2),
    ('Goldähren', 'Laugen-Brioche vorgeschnitten, 6 Stück', 305.0, 6.2, 0.8, 0, 51.9, 10.7, 3.0, 8.8, 1.5),
    ('Mestemacher', 'Westfälischen Pumpernickel', 181.0, 1.0, 0.2, 0, 32.8, 6.2, 11.5, 4.6, 1.1),
    ('Goldähren', 'Toast-Brötchen Protein', 273.0, 10.8, 1.4, 0, 16.0, 4.1, 9.0, 23.5, 1.2),
    ('GutBio', 'Das Pure - Haferbrot mit 27% Ölsaaten', 283.0, 15.8, 2.3, 0, 19.9, 0.9, 8.9, 10.8, 1.0),
    ('Coppenrath & Wiese', 'Dinkelbrötchen', 308.0, 8.6, 1.1, 0, 43.0, 4.4, 0, 12.0, 1.1),
    ('Aldi', 'Bio-Landbrötchen - Kernig', 249.0, 1.9, 0.3, 0, 47.0, 2.4, 4.2, 8.8, 1.0),
    ('Sinnack', 'Brot Protein Brötchen', 275.0, 8.6, 1.0, 0, 25.0, 2.9, 6.7, 21.0, 1.0),
    ('Harry', 'Körner Balance Toastbrötchen', 223.2, 3.2, 0.6, 0, 38.0, 2.4, 4.7, 8.5, 1.0),
    ('Gut bio', 'Finnkorn Toastbrötchen', 232.0, 1.4, 0.2, 0, 43.0, 2.9, 0, 7.4, 1.2),
    ('Grafschafter', 'Pure Kornkraft Haferbrot', 286.0, 15.1, 2.2, 0, 20.1, 0.7, 11.9, 11.4, 1.0),
    ('Goldähren', 'Vollkorn-Sandwich', 239.0, 3.2, 0.3, 0, 40.7, 3.2, 6.6, 8.6, 0.0),
    ('Golden Toast', 'Vollkorn-Toast', 268.0, 5.2, 0.4, 0, 43.2, 4.4, 6.4, 8.8, 1.1),
    ('Harry', 'Harry Brot Vital + Fit', 241.0, 4.9, 0.8, 0, 35.0, 2.3, 6.9, 7.7, 1.0),
    ('Goldähren', 'Vollkorntoast', 268.0, 5.3, 0.5, 0, 43.0, 4.3, 6.5, 8.8, 1.1),
    ('Goldähren', 'Eiweiss Brot', 628.2, 12.0, 1.7, 0, 10.6, 2.0, 7.7, 23.1, 1.1),
    ('Meierbaer & Albro', 'Das Pure - Bio-Haferbrot', 296.0, 18.1, 2.5, 0, 18.3, 0.7, 8.1, 10.9, 1.0),
    ('Goldähren', 'Mehrkorn Wraps', 311.0, 7.3, 1.3, 0, 51.0, 1.4, 5.3, 7.7, 1.0),
    ('Goldähren', 'Protein-Wraps', 318.0, 8.7, 1.1, 0, 38.5, 3.0, 6.1, 18.4, 1.1),
    ('Nur Nur Natur', 'Bio-Roggenvollkornbrot', 184.0, 1.2, 0.1, 0, 34.0, 2.5, 9.0, 4.2, 0.9),
    ('DmBio', 'Das Pure Hafer - und Saatenbrot', 296.0, 18.0, 2.5, 0, 18.0, 0.7, 8.1, 11.0, 1.0),
    ('Goldähren', 'American Sandwich - Weizen', 254.7, 3.7, 0.5, 0, 44.8, 3.9, 3.6, 8.5, 1.0),
    ('Harry', 'Vollkorn Toast', 250.0, 4.0, 0.4, 0, 42.0, 3.2, 6.0, 8.5, 1.0),
    ('Brandt', 'Brandt Markenzwieback', 395.0, 0.7, 0.7, 0, 74.0, 14.0, 0.0, 11.0, 0.7),
    ('Harry', 'Unser Mildes (Weizenmischbrot)', 242.0, 2.7, 0.3, 0, 45.0, 2.9, 3.8, 7.5, 1.0),
    ('Lieken', 'Bauernmild Brot', 239.0, 2.2, 0.3, 0, 45.0, 3.1, 4.0, 7.7, 1.3),
    ('Lieken Urkorn', 'Vollkornsaftiges fein', 206.0, 1.2, 0.2, 0, 38.5, 2.8, 9.2, 5.7, 1.1),
    ('Goldähren', 'Mehrkornschnitten', 612.2, 6.1, 0.9, 0, 39.0, 2.3, 6.4, 9.7, 1.2),
    ('Mestemacher', 'Dinkel Wraps', 304.0, 8.6, 1.1, 0, 45.7, 1.0, 3.1, 9.5, 1.1),
    ('Harry', 'Toastbrot', 259.1, 6.0, 0.6, 0, 39.0, 3.5, 6.0, 8.8, 1.0),
    ('Harry', 'Vollkorn Urtyp', 194.0, 1.1, 0.2, 0, 36.0, 3.7, 9.3, 5.4, 1.0),
    ('Golden Toast', 'Vollkorn Toast', 267.0, 5.3, 0.5, 0, 43.0, 4.3, 6.5, 8.8, 1.1),
    ('Harry', 'Harry 1688 Korn an Korn', 203.6, 1.1, 0.2, 0, 39.0, 4.6, 8.3, 5.3, 1.0),
    ('Golden Toast', 'Buttertoast', 265.0, 3.8, 2.1, 0, 48.0, 4.0, 3.0, 8.2, 1.1),
    ('Brandt', 'Der Markenzwieback', 395.0, 5.2, 0.7, 0, 74.0, 14.0, 0, 11.0, 0.7),
    ('Gutes aus der Bäckerei', 'Weissbrot', 247.0, 3.0, 0.4, 0, 45.0, 4.0, 3.0, 8.5, 1.0),
    ('Harry', 'Mischbrot Anno 1688 Klassisch, Harry', 248.0, 2.8, 0.5, 0, 45.0, 3.1, 5.2, 8.1, 1.3),
    ('Goldähren', 'Dreisaatbrot - Roggenvollkornbrot', 215.0, 5.2, 0.6, 0, 29.4, 2.4, 11.8, 6.7, 0.9),
    ('Golden Toast', 'Dinkel-Harmonie Sandwich', 264.0, 3.8, 0.4, 0, 45.5, 4.0, 3.5, 10.3, 1.1),
    ('Filinchen', 'Das Knusperbrot Original', 406.0, 6.0, 4.0, 0, 75.0, 2.0, 4.0, 11.0, 0.2),
    ('Goldähren', 'Saaten-Sandwich', 298.7, 8.7, 0.9, 0, 42.7, 3.5, 5.3, 10.0, 1.0),
    ('Cucina', 'Pinsa', 263.0, 4.8, 0.9, 0, 43.9, 3.1, 3.3, 9.6, 1.8)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
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
