-- PIPELINE (Seafood & Fish): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Seafood & Fish'
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
    ('Aldi', 'ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 174.0, 10.0, 1.5, 0, 0.1, 0.1, 0, 21.0, 3.2),
    ('Aldi Archiv', 'Räucherlachs Bio', 177.0, 10.0, 2.1, 0, 0.0, 0.0, 0, 21.0, 2.6),
    ('ArcticFish', 'Pures Grün Räucherlachs', 165.0, 9.0, 1.3, 0, 0.5, 0.5, 0.0, 21.0, 3.1),
    ('Lidl', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 166.0, 9.3, 1.9, 0, 0.0, 0, 0.0, 20.6, 2.6),
    ('Golden Seafood', 'Fischstäbchen', 183.0, 8.3, 1.0, 0, 14.0, 2.0, 0, 13.0, 0.7),
    ('Almare', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 157.0, 7.7, 1.7, 0, 0.0, 0.0, 0, 22.8, 2.5),
    ('Almare', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 153.0, 7.8, 1.2, 0, 0.0, 0.0, 0, 20.7, 1.6),
    ('Krone', 'Räucherlachs', 180.0, 11.0, 2.0, 0, 0.0, 0.0, 0, 21.0, 3.1),
    ('Appel', 'Bratheringe in würzigem Aufguss', 22.0, 14.0, 3.0, 0, 6.0, 5.0, 0.8, 16.0, 1.0),
    ('Aldi', 'Bio-Räucherlachs', 175.0, 11.0, 1.7, 0, 0.0, 0.0, 0, 19.0, 2.5),
    ('Almare Seafood', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 72.0, 1.0, 0.3, 0, 0.0, 0.0, 0, 15.0, 1.8),
    ('Aldi', 'Thunfischfilets in Sonnenblumenöl', 154.0, 5.7, 1.1, 0, 0.0, 0.0, 0, 25.7, 0.9),
    ('Golden Seafood', 'Riesengarnelenschwänze - Provencale', 84.0, 4.4, 0.7, 0, 0.5, 0.5, 0, 11.0, 1.2),
    ('Aldi', 'Knusper-Filets - Käse-Kräuter', 195.0, 9.0, 1.7, 0, 17.0, 0.7, 0, 11.0, 0.8),
    ('Krone Fisch', 'Lachs aus verantwortungsvoller Fischzucht', 180.0, 11.0, 2.0, 0, 0.0, 0.0, 0, 21.0, 3.1),
    ('Aldi', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 190.0, 13.0, 2.0, 0, 6.9, 4.0, 0, 11.0, 0.9),
    ('Almare', 'Stremellachs - Pfeffer', 233.0, 16.4, 2.5, 0, 0.0, 0.0, 0, 21.4, 1.4),
    ('Almare Seafood', 'Lachs', 111.0, 2.7, 0.7, 0, 0.5, 0.5, 0, 21.0, 3.3),
    ('Almare', 'Matjes Blister', 225.0, 18.0, 3.1, 0, 0.5, 0.5, 0, 16.0, 3.9),
    ('Almare', 'Stremellachs - Natur', 230.4, 19.0, 2.9, 0, 0.0, 0.0, 0.0, 21.4, 1.3),
    ('Ocean sea', 'King Prawns - White Tiger Garnelen', 72.0, 0.9, 0.3, 0, 0.0, 0.0, 0, 16.0, 1.0),
    ('Frosta', 'Backofen Fisch (Knusprig Kross)', 176.0, 7.2, 0.5, 0, 14.6, 2.0, 0, 12.8, 0.8),
    ('Nordsee', 'Fischfrikadellen', 159.0, 6.1, 0.5, 0, 18.0, 4.6, 0, 8.0, 0.3),
    ('Almare Seafood', 'Lachsforelle', 174.0, 10.0, 1.7, 0, 0.0, 0.0, 0, 21.0, 3.2),
    ('Lidl', 'Bio Stremel Lachs', 211.0, 15.0, 3.0, 0, 0.0, 0.0, 0.0, 19.0, 1.4),
    ('Almare', 'Marinierte Garnelen - Tomate-Chili', 262.0, 22.0, 1.9, 0, 1.1, 0.6, 0, 13.0, 1.8),
    ('Almare', 'Matjesfilets mit Honig-Senf-Sauce', 313.0, 28.0, 3.7, 0, 5.2, 5.2, 0, 10.0, 2.8),
    ('Lidl', 'Smoke Salmon Slices', 182.0, 11.2, 1.6, 0, 0.5, 0.5, 0, 20.2, 2.5),
    ('Deutsche See GmbH', 'Lachsfilet', 222.0, 15.7, 3.3, 0, 0.0, 0, 0, 20.2, 0.2),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 315.0, 29.0, 4.1, 0, 6.8, 6.5, 0.1, 6.9, 2.0),
    ('Select & Go', 'Sushi Box', 157.0, 4.6, 0.6, 0, 24.0, 4.8, 0, 4.7, 1.9),
    ('Almare', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 141.0, 9.0, 1.7, 0, 3.7, 1.4, 0, 11.0, 0.8),
    ('Golden Seafood', 'White-Tiger-Garnelen', 70.0, 0.9, 0.3, 0, 0.5, 0.5, 0, 16.0, 1.3),
    ('Nordsee', 'Backfisch in knuspriger Panade mit Remoulade', 292.0, 21.0, 3.4, 0, 15.9, 2.3, 0, 9.4, 1.2),
    ('Krone', 'Bio-Lachs', 185.0, 11.0, 1.9, 0, 0.0, 0.0, 0, 23.0, 3.2),
    ('Edeka', 'Räucherlachs', 177.0, 9.9, 1.4, 0, 0.0, 0.0, 0, 22.0, 2.7),
    ('Golden Seafood', 'Wildlachsfilet', 95.0, 1.7, 0.4, 0, 0.0, 0.0, 0, 20.0, 0.2),
    ('Fischerstolz', 'Frisches Lachsforellen-Filet mit Haut', 158.0, 9.3, 2.1, 0, 0.5, 0.5, 0, 18.0, 0.0),
    ('REWE Bio', 'Räucherlachs', 183.0, 11.0, 2.1, 0, 0.0, 0.0, 0.0, 21.0, 2.5),
    ('Natürlich für uns', 'Bio Räucherlachs', 165.0, 8.2, 1.9, 0, 0.1, 0.0, 0, 22.8, 2.6),
    ('Golden Seafood', 'Lachsfilet-Portion mit Haut aus Norwegen', 224.0, 15.9, 2.0, 0, 0.0, 0.0, 0.0, 20.3, 0.1),
    ('Golden Seafood', 'Lachsfilet', 233.0, 17.6, 2.5, 0, 0.0, 0, 0, 18.6, 0.0),
    ('Almare Seafood', 'Matjesfilets mit Sauce nach Sylter Art', 310.0, 29.0, 4.3, 0, 2.8, 2.8, 0, 9.5, 2.7),
    ('Krone', 'Kodiak Wildlachs', 111.0, 2.8, 0.9, 0, 0.0, 0.0, 0, 22.0, 2.7),
    ('Ja!', 'Regenbogenforelle Geräuchert', 144.0, 5.6, 1.3, 0, 0.5, 0.0, 0.0, 23.0, 2.0),
    ('Nadler', 'Alaska Seelachs Mus', 341.0, 33.0, 2.5, 0, 0.5, 0.5, 0, 12.0, 8.3),
    ('Fischerstolz', 'Bio Lachsfiletportionen', 226.0, 16.6, 3.0, 0, 0.0, 0.0, 0.0, 19.2, 0.1),
    ('Almare', 'Shrimps- Salat', 296.0, 27.0, 1.9, 0, 5.2, 4.4, 0, 8.1, 1.6),
    ('Almare Seafood', 'Lachsfilet in Cranberry-Chili-Sauce', 190.0, 12.0, 2.4, 0, 6.5, 5.0, 0, 14.0, 1.2),
    ('Sea Gold', 'Fischstäbchen', 181.0, 7.9, 1.0, 0.0, 15.0, 1.0, 0.0, 12.0, 0.0),
    ('Fischersolz', 'Norwegische Lachsfiletportionen', 239.0, 18.0, 2.9, 0, 0.0, 0.0, 0.0, 19.3, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Seafood & Fish' and p.is_deprecated is not true
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
