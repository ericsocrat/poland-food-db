-- PIPELINE (Drinks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Drinks'
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
    ('My Vay', 'Bio-Haferdrink ungesüßt', 42.0, 1.4, 0.2, 0, 5.8, 0.0, 0.0, 0.8, 0.1),
    ('Rio d''Oro', 'Apfel-Direktsaft Naturtrüb', 46.0, 0.5, 0.1, 0, 11.0, 10.0, 0, 0.5, 0.0),
    ('Club Mate', 'Club-Mate Original', 20.0, 0.0, 0.0, 0, 5.0, 5.0, 0.0, 0.0, 0.0),
    ('Paulaner', 'Paulaner Spezi', 37.0, 0.0, 0.0, 0, 9.2, 9.2, 0, 0.0, 0.0),
    ('Lidl', 'Milch Mandel ohne Zucker', 15.0, 1.1, 0.1, 0, 0.5, 0.1, 0.0, 0.5, 0.2),
    ('Vemondo', 'Barista Oat Drink', 58.0, 3.2, 0.3, 0, 5.7, 1.6, 1.0, 0.9, 0.1),
    ('Gerolsteiner', 'Gerolsteiner Medium 1,5 Liter', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Aldi', 'Bio-Haferdrink Natur', 40.0, 0.8, 0.1, 0, 7.3, 4.2, 0.5, 0.7, 0.1),
    ('Lidl', 'No Milk Hafer 3,5% Fett', 53.0, 3.5, 0.3, 0, 4.1, 1.2, 1.1, 0.8, 0.1),
    ('Gut & Günstig', 'Mineralwasser', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Asia Green Garden', 'Kokosnussmilch Klassik', 207.0, 21.0, 18.6, 0, 2.2, 2.1, 0, 1.8, 0),
    ('Vemondo', 'No Milk Hafer 1,8% Fett', 38.0, 1.8, 0.2, 0, 4.1, 1.2, 1.1, 0.8, 0.1),
    ('Berief', 'BiO HAFER NATUR', 40.0, 1.4, 0.2, 0, 6.0, 5.2, 0, 0.6, 0.1),
    ('Paulaner', 'Spezi Zero', 1.0, 0.0, 0.0, 0, 0.5, 0.5, 0.0, 0.0, 0.0),
    ('Vemondo', 'Bio Hafer', 37.0, 1.2, 0.2, 0, 5.6, 3.3, 1.0, 0.4, 0.1),
    ('Berief', 'Bio Hafer ohne Zucker', 42.0, 1.8, 0.3, 0, 5.6, 0.0, 0, 0.8, 0.1),
    ('DmBio', 'Sojadrink natur', 38.0, 1.9, 0.5, 0, 1.8, 0.7, 0.2, 3.2, 0.0),
    ('Bensdorp', 'Bensdorp Kakao', 366.0, 21.0, 13.0, 0, 8.9, 0.6, 0.0, 20.0, 0.1),
    ('Choco', 'Kakao Choco', 389.0, 3.0, 1.3, 0, 83.0, 80.0, 0.0, 3.9, 0.3),
    ('Vemondo', 'High Protein Sojadrink', 50.0, 2.2, 0.3, 0, 2.5, 2.4, 0.0, 5.0, 0.2),
    ('Drinks & More GmbH & Co. KG', 'Knabe Malz', 38.0, 0.0, 0, 0, 8.9, 7.1, 0, 0.0, 0.0),
    ('Rio d''Oro', 'Trauben-Direktsaft', 67.0, 0.0, 0.0, 0, 16.0, 16.0, 0, 0.0, 0.0),
    ('Alpro', 'Geröstete Mandel Ohne Zucker', 15.0, 1.1, 0.1, 0, 0.0, 0.0, 0.3, 0.5, 0.1),
    ('Vemondo', 'Bio Hafer ohne Zucker', 33.0, 1.5, 0.2, 0, 3.7, 0.0, 1.0, 0.6, 0.1),
    ('Pepsi', 'Pepsi Zero Zucker', 0.5, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Jever', 'Jever fun 4008948194016 Pilsener alkoholfrei', 15.0, 0.0, 0.0, 0, 0.5, 0.1, 0, 0.1, 0.0),
    ('Valensia', 'Orange ohne Fruchtfleisch', 43.0, 0.2, 0.0, 0, 9.0, 9.0, 0.2, 0.7, 0.0),
    ('DmBio', 'Oat Drink - Sugarfree', 42.0, 1.8, 0.3, 0, 5.6, 0.0, 1.1, 0.8, 0.1),
    ('Red Bull', 'Kokos Blaubeere (Weiß)', 45.0, 0.0, 0, 0, 11.0, 11.0, 0, 0.0, 0.1),
    ('Vemondo', 'High protein soy with chocolate taste', 64.0, 1.7, 0.3, 0, 7.2, 4.8, 0, 5.0, 0.2),
    ('Naturalis', 'Getränke - Mineralwasser - Classic', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vly', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 37.0, 2.5, 0.3, 0, 0.2, 0.0, 2.1, 2.5, 0.1),
    ('Teekanne', 'Teebeutel Italienische Limone', 2.0, 0.0, 0.0, 0, 0.4, 0.0, 0, 0.0, 0.0),
    ('Hohes C', 'Saft Plus Eisen', 42.0, 0.0, 0.0, 0, 9.8, 9.1, 0, 0.0, 0.0),
    ('Pepsi', 'Pepsi', 18.0, 0.0, 0.0, 0, 4.6, 4.6, 0.0, 0.0, 0.0),
    ('Quellbrunn', 'Mineralwasser Naturell', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Granini', 'Multivitaminsaft', 45.0, 0.0, 0.0, 0, 10.0, 9.8, 0, 0.0, 0.0),
    ('Schwip schwap', 'Schwip Schwap Zero', 1.5, 0.0, 0, 0, 0.3, 0.3, 0, 0.0, 0.0),
    ('Quellbrunn', 'Naturell Mierbachquelle ohne Kohlensäure', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Müller', 'Müllermilch - Bananen-Geschmack', 67.0, 1.4, 0.9, 0, 10.5, 10.0, 0, 3.2, 0.1),
    ('Volvic', 'Wasser Volvic naturelle', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Coca-Cola', 'Coca-Cola Original', 42.0, 0.0, 0.0, 0, 10.6, 10.6, 0, 0.0, 0.0),
    ('Oatly', 'Haferdrink Barista', 61.0, 3.0, 0.3, 0, 7.1, 3.4, 0.8, 1.1, 0.1),
    ('Coca-Cola', 'Coca-Cola 1 Liter', 42.0, 0.0, 0.0, 0, 10.6, 10.6, 0.0, 0.0, 0.0),
    ('Red Bull', 'Red Bull Energydrink Classic', 46.0, 0.0, 0.0, 0, 11.0, 11.0, 0.0, 0.0, 0.1),
    ('Monster Energy', 'Monster Energy Ultra', 2.0, 0.0, 0.0, 0, 0.9, 0.0, 0.0, 0.0, 0.2),
    ('Coca-Cola', 'Coca-Cola Zero', 0.2, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Alpro', 'Alpro Not Milk', 59.0, 3.5, 0.4, 0, 5.7, 0.0, 1.0, 0.7, 0.1),
    ('Saskia', 'Mineralwasser still 6 x 1,5 L', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Cola', 'Coca-Cola Zero', 0.2, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Coca-Cola', 'Cola Zero', 0.2, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Drinks' and p.is_deprecated is not true
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
