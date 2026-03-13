-- PIPELINE (Frozen Vegetables): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Frozen Vegetables'
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
    ('Hortex', 'Warzywa na patelnię', 27.0, 0.5, 0.1, 0, 3.7, 2.5, 2.4, 1.4, 0.5),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 62.0, 1.3, 0.5, 0, 9.4, 1.3, 2.5, 1.9, 0.1),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 50.0, 0.5, 0.1, 0, 8.3, 2.5, 3.9, 1.6, 0.1),
    ('Hortex', 'Warzywa na patelnię z przyprawą włoską', 38.0, 0.5, 0.1, 0, 4.9, 3.5, 2.7, 2.2, 0.5),
    ('Mroźna Kraina', 'Szpinak w liściach, porcjowany', 27.0, 0.3, 0.1, 0, 1.1, 0.7, 3.5, 3.2, 0.1),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 57.0, 2.2, 0.3, 0, 6.8, 4.4, 1.8, 1.7, 0.6),
    ('Hortex', 'Warzywa na patelnię ze szpinakiem', 54.0, 1.1, 0.2, 0, 7.6, 2.4, 2.5, 2.0, 0.6),
    ('Mroźna Kraina', 'Brokuły różyczki', 20.0, 0.5, 0.1, 0, 1.8, 1.2, 0, 1.8, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po hiszpańsku&quot;', 53.0, 1.2, 0, 0, 7.1, 0, 3.4, 1.8, 0),
    ('Hortex', 'Warzywa Na Patelnię Z Koperkiem', 51.0, 1.1, 0.2, 0, 7.0, 2.5, 2.5, 2.0, 0.1),
    ('Mroźna Kraina', 'Fasola szparagowa cięta Mroźna Kraina', 34.0, 0.3, 0.1, 0, 4.1, 1.5, 1.9, 2.0, 0.0),
    ('Mroźna Kraina', 'Jagody leśne', 58.0, 0.4, 0.1, 0, 12.1, 9.7, 2.0, 0.4, 0.0),
    ('Mroźna Kraina', 'Borówka', 59.0, 0.2, 0.0, 0, 11.8, 10.2, 3.4, 0.8, 0.0),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 22.0, 0.4, 0.1, 0, 0.9, 0.6, 3.3, 2.0, 0.0),
    ('Asia Flavours', 'Mieszanka Chińska', 29.0, 0.2, 0.1, 0, 5.5, 3.2, 0.5, 1.2, 0.0),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 32.0, 0.5, 0.1, 0, 3.1, 2.3, 3.4, 1.9, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 34.0, 0.5, 0, 0, 4.4, 0, 0, 1.8, 0),
    ('Mroźna Kraina', 'Warzywa na patelnię po grecku', 50.0, 0.6, 0, 0, 8.6, 2.4, 2.0, 1.5, 0),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 79.0, 2.7, 0.4, 0, 8.8, 1.7, 4.2, 2.7, 0.4),
    ('Poltino', 'Danie chińskie', 105.0, 0.8, 0.2, 0, 17.2, 2.3, 1.7, 6.8, 0.6),
    ('Mroźna Kraina', 'Kalafior różyczki', 21.0, 0.2, 0.1, 0, 2.7, 2.6, 1.0, 1.7, 0.0),
    ('Mroźna kraina', 'Warzywa na patelnię po turecku', 85.0, 3.6, 0.6, 0, 10.0, 3.4, 2.3, 1.7, 0.1),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 60.0, 0.4, 0.2, 0, 9.7, 3.5, 2.5, 3.1, 0),
    ('Agram', 'Szpinak liście', 18.0, 0.5, 0.1, 0, 0.6, 0.1, 0, 2.8, 0.1),
    ('Mroźna Kraina', 'Warzywa na patelnię po azjatycku', 46.0, 2.0, 0.2, 0, 4.6, 3.9, 2.5, 1.2, 0.0),
    ('Hortex', 'Szpinak liście', 19.0, 0.5, 0.1, 0, 0.4, 0.3, 2.3, 2.3, 0.1),
    ('Unknown', 'Jagody leśne', 62.0, 0.9, 0.0, 0, 10.7, 6.7, 4.0, 0.7, 0.0),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 71.3, 0.0, 0.0, 0, 15.9, 11.2, 1.2, 1.3, 0.0),
    ('Hortex', 'Maliny mrożone', 43.0, 0.5, 0.1, 0, 5.3, 5.3, 6.7, 1.3, 0.0),
    ('Mroźna Kraina', 'Mieszanka wiosenna', 42.0, 0.6, 0.1, 0, 4.8, 2.8, 0, 2.6, 0.1),
    ('Hortex', 'Warzywa na patelnie', 57.0, 1.1, 0.2, 0, 8.6, 2.2, 2.4, 2.0, 0.4),
    ('Hortex', 'Bukiet warzyw kwiatowy', 28.0, 0.5, 0.1, 0, 3.1, 2.9, 0, 1.9, 0.1),
    ('Mroźna kraina', 'Szpinak rozdrobniony porcjowany', 14.0, 0.2, 0.0, 0, 0.5, 0.5, 0, 1.5, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 52.4, 1.3, 0.5, 0, 6.6, 2.9, 3.1, 1.9, 0.0),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po indyjsku&quot;', 47.0, 0.5, 0.1, 0, 5.7, 2.8, 4.6, 2.7, 0.3),
    ('Mroźna kraina', 'Warzywa na patelnie', 40.0, 0.4, 0, 0, 6.1, 0, 0, 1.6, 0),
    ('Mroźna Kraina', 'Groszek zielony', 80.0, 0.9, 0.3, 0, 7.8, 2.6, 7.7, 6.4, 0.0),
    ('Iglote', 'Warzywa na patelnię po włosku', 43.0, 0.5, 0.1, 0, 6.2, 1.0, 0, 2.2, 0.1),
    ('Iglotex', 'Warzywa na patelnię klasyczne', 58.0, 1.2, 0.1, 0, 8.1, 0.9, 0, 2.2, 0.0),
    ('Proste Historie', 'Mieszanka Chińska', 30.0, 0.2, 0.0, 0, 3.7, 1.1, 2.5, 2.0, 0.1),
    ('Mroźna Kraina', 'Marchew mini', 32.0, 0.2, 0.0, 0, 6.0, 3.8, 1.7, 0.7, 0.1),
    ('Mroźna Kraina', 'Brzoskwinia', 45.0, 0.0, 0.0, 0, 9.9, 8.7, 1.3, 0.6, 0.0),
    ('Harvest Best', 'Zupa jarzynowa', 33.0, 0.3, 0.1, 0, 3.7, 3.0, 0, 3.2, 0.1),
    ('Harvest Best', 'Zupa kalafiorowa', 37.0, 0.5, 0.1, 0, 5.6, 2.5, 0, 1.9, 0.1),
    ('Mroźna Kraina', 'Zupa jarzynowa', 33.0, 0.3, 0.1, 0, 4.3, 2.1, 0, 1.9, 0.1),
    ('Proste Historie', 'Chopped spinach', 19.0, 0.4, 0, 0, 0.4, 0.2, 0, 2.3, 0),
    ('Hortex', 'Mieszanka Azjatycka', 29.0, 0.5, 0.1, 0, 3.8, 3.3, 3.0, 1.4, 0.5),
    ('Mroźna Kraina', 'Marchewka z groszkiem', 63.0, 0.6, 0.1, 0, 9.0, 5.2, 3.6, 3.6, 0.1),
    ('Mroźna Kraina', 'Ananas', 63.0, 0.2, 0, 0, 14.0, 13.0, 1.0, 0.9, 0),
    ('Lidl', 'Warzywa Na Patelnię Z Ziemniakami', 56.0, 1.0, 0, 0, 7.9, 0, 0, 2.4, 0),
    ('Freshona', 'Warzywa mrożone po hiszpańsku', 69.0, 1.3, 0.2, 0, 10.9, 2.5, 2.4, 2.1, 0.4),
    ('World of Taste', '7 - Vegetables Mix', 35.0, 0.3, 0.1, 0, 4.2, 1.3, 2.2, 2.2, 0),
    ('Nordis', 'Warzywa na payelnie premium', 41.0, 0.4, 0.1, 0, 6.1, 1.2, 0, 1.9, 0.1),
    ('Kuchnia Eksperta', 'Frozen spinach', 22.0, 0.5, 0, 0, 0.6, 0.5, 2.6, 2.8, 0),
    ('Hortex', 'Stir-Fry Vegetables With Oriental Seasoning', 35.0, 0.5, 0.1, 0.0, 4.4, 3.2, 3.3, 2.1, 0.4),
    ('Hortex', 'Broccoli And Cauliflower Mix', 28.0, 0.5, 0.1, 0, 2.4, 2.2, 2.3, 2.4, 0.0),
    ('Hortex', 'Warzywa Do Zapiekania', 63.0, 1.3, 0.3, 0, 9.0, 2.9, 3.0, 2.2, 0.8),
    ('Mroźna kraina', 'Spinach', 20.0, 0.4, 0.0, 0, 0.8, 0.8, 1.9, 2.3, 0.0),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 26.0, 0.0, 0, 0, 3.4, 3.0, 2.3, 2.0, 0.0),
    ('Freshona Lidl', 'Warzywa na patelnię po włosku', 42.0, 0.5, 0.0, 0, 5.8, 3.7, 2.7, 2.2, 0.5),
    ('Freshona', 'Mix zeleniny na čínský způsob', 28.0, 0.5, 0.1, 0, 3.4, 3.0, 0, 1.5, 0.1),
    ('Harvest Best', 'Wok mix', 28.0, 0.0, 0.0, 0, 3.9, 2.2, 0, 1.8, 0.1),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', 24.0, 0.4, 0.1, 0, 1.5, 0.7, 2.3, 2.5, 0.1),
    ('Carrefour', 'Haricots Verts Très Fins', 32.0, 0.5, 0.1, 0, 3.8, 0.9, 3.9, 1.9, 0.0),
    ('Carrefour', 'CHOUX-FLEURS En fleurette', 31.0, 0.9, 0.2, 0, 2.1, 1.8, 1.6, 2.9, 0.0),
    ('Spar', 'Guisantes finos', 83.0, 0.4, 0.2, 0, 11.3, 2.8, 0, 6.0, 0),
    ('Tesco', 'Mix mražené zeleniny', 67.0, 1.5, 0.1, 0, 9.6, 6.0, 2.4, 2.5, 0.0),
    ('Freshona', 'Berry Mix with Sour Cherries', 47.0, 0.2, 0.0, 0.0, 7.1, 7.1, 0.0, 0.9, 0.0),
    ('Lidl', 'Szpinak Rozdrobniony W Porcjach', 19.0, 0.4, 0.0, 0, 0.4, 0.3, 0, 2.3, 0.1),
    ('Freshona', 'Fasolka szparagowa zielona', 42.0, 0.2, 0.1, 0, 6.8, 0.5, 2.3, 2.2, 0.0),
    ('Bonduelle', 'Špenátové listy', 32.0, 0.6, 0.1, 0, 2.0, 0.4, 2.6, 3.4, 0.1),
    ('Bonduelle', 'Thailand Mix With Rice Frozen', 60.0, 0.3, 0.0, 0, 12.0, 1.9, 1.2, 1.6, 0.0),
    ('Freshona', 'Groszek zielony', 106.0, 0.4, 0.2, 0, 16.3, 2.0, 5.8, 6.4, 0.0),
    ('Bonduelle', 'Croustis Original Brocolis 305g', 161.0, 9.1, 2.2, 0, 14.0, 1.7, 2.3, 4.7, 0.8),
    ('Unknown', '10 Légumes POUR Minestrone', 36.0, 0.5, 0.1, 0, 6.3, 2.8, 2.5, 1.6, 0.1),
    ('Freshona', 'Marchew z groszkiem', 47.0, 0.4, 0.1, 0, 6.4, 4.2, 0, 2.6, 0.1),
    ('Bonduelle restauration', 'Snap peas', 48.0, 0.3, 0.1, 0, 7.4, 4.6, 3.0, 2.3, 0.0),
    ('Douceur du Verger', 'Framboises entières', 36.0, 0.2, 0.1, 0, 6.1, 6.0, 7.0, 1.6, 0.0),
    ('Freshona', 'Mixed vegetables Californian style', 89.0, 4.6, 0.5, 0, 7.9, 4.4, 0, 2.5, 0.5)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Frozen Vegetables' and p.is_deprecated is not true
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
