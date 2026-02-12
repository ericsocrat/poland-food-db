-- PIPELINE (Frozen & Prepared): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Frozen & Prepared'
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
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 265.0, 9.5, 4.9, 0, 33.5, 3.7, 0, 10.2, 1.3),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 146.0, 3.8, 0.4, 0, 23.0, 1.8, 2.5, 3.9, 1.2),
    ('Koral', 'Lody śmietankowe - kostka śnieżna', 196.0, 9.0, 7.6, 0, 25.0, 19.0, 0, 3.7, 0.2),
    ('Dobra kaloria', 'Roślinna kaszanka', 244.0, 16.0, 7.0, 0, 16.0, 0.3, 6.2, 6.3, 1.0),
    ('Grycan', 'Lody śmietankowe', 262.0, 15.5, 9.8, 0, 25.8, 22.9, 0.3, 4.6, 0.2),
    ('Hortex', 'Warzywa na patelnię', 27.0, 0.5, 0.1, 0, 3.7, 2.5, 2.4, 1.4, 0.5),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 62.0, 1.3, 0.5, 0, 9.4, 1.3, 2.5, 1.9, 0.1),
    ('Dr.Oetker', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 238.0, 7.3, 3.5, 0, 33.0, 3.7, 0, 9.6, 1.2),
    ('Dr.Oetker', 'Pizza z szynką i sosem pesto, głęboko mrożona.', 229.0, 7.2, 3.3, 0, 31.4, 3.6, 1.8, 8.9, 1.0),
    ('Biedronka', 'Rożek z czekoladą', 328.0, 18.0, 13.0, 0, 37.0, 26.0, 2.6, 4.6, 0.1),
    ('Mroźna Kraina', 'Jagody leśne', 58.0, 0.4, 0.1, 0, 12.1, 9.7, 2.0, 0.4, 0.0),
    ('MaxTop Sławków', 'Pizza głęboko mrożona z szynką i pieczarkami.', 240.0, 8.0, 2.5, 0, 34.0, 2.7, 0, 8.0, 1.5),
    ('Hortex', 'Makaron na patelnię penne z sosem serowym', 66.0, 0.7, 0.3, 0, 10.8, 2.6, 0, 3.1, 0.5),
    ('Fish Time', 'Ryba z piekarnika z sosem brokułowym', 115.0, 5.0, 2.3, 0, 5.3, 2.0, 0, 11.8, 0.7),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 50.0, 0.5, 0.1, 0, 8.3, 2.5, 3.9, 1.6, 0.1),
    ('Marletto', 'Lody o smaku śmietankowym', 195.0, 10.0, 9.0, 0, 23.0, 21.0, 0, 3.1, 0.1),
    ('Iglotex', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony.', 195.0, 5.3, 1.4, 0, 28.0, 3.2, 0, 7.6, 0.9),
    ('Bracia Koral', 'Lody śmietankowe z ciasteczkami', 271.0, 15.0, 9.7, 0, 30.0, 22.0, 0, 3.9, 0.2),
    ('Feliciana', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 238.0, 7.3, 3.5, 0, 33.0, 3.7, 0, 9.6, 1.2),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 57.0, 2.2, 0.3, 0, 6.8, 4.4, 1.8, 1.7, 0.6),
    ('Dr. Oetker', 'Pizza z salami i chorizo, głęboko mrożona', 266.0, 9.8, 4.6, 0, 34.0, 3.9, 0, 9.7, 1.6),
    ('Gotszlik', 'Rożek Dolce Giacomo', 389.0, 7.1, 4.7, 0, 73.0, 29.0, 6.9, 6.9, 0.4),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 32.0, 0.5, 0.1, 0, 3.1, 2.3, 3.4, 1.9, 0.0),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 22.0, 0.4, 0.1, 0, 0.9, 0.6, 3.3, 2.0, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 34.0, 0.5, 0, 0, 4.4, 0, 0, 1.8, 0),
    ('Mroźna Kraina', 'Kalafior różyczki', 21.0, 0.2, 0.1, 0, 2.7, 2.6, 1.0, 1.7, 0.0),
    ('Mroźna kraina', 'Warzywa na patelnię letnie', 79.0, 5.4, 0.6, 0, 4.3, 4.3, 2.7, 2.0, 0.6),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 71.3, 0.0, 0.0, 0, 15.9, 11.2, 1.2, 1.3, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 60.0, 0.4, 0.2, 0, 9.7, 3.5, 2.5, 3.1, 0),
    ('Asia Flavours', 'Mieszanka chińska', 29.0, 0.2, 0.1, 0, 5.5, 3.2, 0.5, 1.2, 0.0),
    ('NewIce', 'Plombie Śnieżynka', 212.0, 11.3, 0, 0, 23.3, 0, 0, 4.2, 0),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 79.0, 2.7, 0.4, 0, 8.8, 1.7, 4.2, 2.7, 0.4),
    ('ABRAMCZYK', 'KAPITAŃSKIE PALUSZKI RYBNE', 188.0, 9.6, 0.8, 0, 13.0, 1.8, 0.7, 12.0, 0.8),
    ('Hortex', 'Maliny mrożone', 43.0, 0.5, 0.1, 0, 5.3, 5.3, 6.7, 1.3, 0.0),
    ('Bracia Koral', 'Lody Jak Dawniej Śmietankowe', 249.0, 15.0, 11.0, 0, 25.0, 22.0, 0, 3.6, 0.2),
    ('Frosta', 'Złote Paluszki Rybne z Fileta', 185.0, 8.6, 0.8, 0, 14.0, 0.9, 0, 13.0, 0.9),
    ('Bracia Koral', 'Lody czekoladowe z wiśniami', 220.0, 11.0, 7.8, 0, 27.0, 25.0, 0, 3.3, 0.1),
    ('Iglotex', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie.', 213.0, 8.3, 2.4, 0, 24.0, 2.7, 0, 9.3, 1.2),
    ('Diuna', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', 175.0, 8.2, 6.4, 0, 22.4, 20.9, 0, 2.7, 0.1),
    ('Unknown', 'Jagody leśne', 62.0, 0.9, 0.0, 0, 10.7, 6.7, 4.0, 0.7, 0.0),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', 221.0, 8.8, 4.5, 0, 26.7, 3.3, 0, 8.1, 1.1),
    ('Kilargo', 'Marletto Almond', 345.0, 22.0, 14.0, 0, 31.0, 29.0, 1.8, 4.8, 0.1),
    ('Zielona Budka', 'Lody Truskawkowe', 114.0, 5.5, 5.0, 0, 15.0, 12.0, 0, 0.9, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 52.4, 1.3, 0.5, 0, 6.6, 2.9, 3.1, 1.9, 0.0),
    ('Unknown', 'Lody proteinowe śmietankowe go active', 120.0, 2.7, 1.9, 0, 14.0, 9.9, 5.4, 7.3, 0.5),
    ('Grycan', 'Lody truskawkowe', 231.0, 12.1, 7.7, 0, 26.3, 23.2, 0.7, 3.6, 0.1),
    ('Kilargo', 'Marletto Salted Caramel Lava', 342.0, 21.0, 13.0, 0, 34.0, 31.0, 0.8, 4.4, 0.4),
    ('Hortex', 'Warzywa na patelnie', 57.0, 1.1, 0.2, 0, 8.6, 2.2, 2.4, 2.0, 0.4),
    ('Koral', 'Lody Kukułka', 219.0, 11.0, 0, 0, 26.0, 0, 0, 4.1, 0),
    ('Mroźna kraina', 'Warzywa na patelnie', 40.0, 0.4, 0, 0, 6.1, 0, 0, 1.6, 0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Frozen & Prepared' and p.is_deprecated is not true
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
