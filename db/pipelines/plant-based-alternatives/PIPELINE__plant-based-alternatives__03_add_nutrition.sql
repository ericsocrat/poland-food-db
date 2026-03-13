-- PIPELINE (Plant-Based & Alternatives): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
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
    ('Pano', 'Wafle Ryżowe Wieloziarnisty', 400.0, 5.6, 0.9, 0, 74.0, 0.6, 4.7, 11.0, 0.3),
    ('Pri', 'Ziemniaczki Już Gotowe z papryką', 88.0, 1.9, 0.2, 0, 16.2, 1.9, 1.7, 2.4, 0.6),
    ('Go Vege', 'Parówki sojowe klasyczne', 182.0, 10.0, 0.9, 0, 4.9, 1.0, 0.7, 18.0, 1.9),
    ('Nasza Spiżarnia', 'Nasza Spiżarnia Korniszony z chilli', 17.0, 0.5, 0.1, 0, 1.5, 0.5, 2.0, 1.3, 1.3),
    ('Basia', 'Mąka Tortowa Extra typ 405 Basia', 341.0, 1.0, 0.3, 0, 71.7, 2.4, 0, 10.0, 0.0),
    ('Dobra-kaloria', 'Baton owocowy chrupiący orzech', 386.0, 12.0, 1.4, 0, 58.0, 42.0, 7.1, 8.3, 0.1),
    ('Tarczyński', 'Rośl-inne Kabanosy 3 Ziarna', 415.0, 29.0, 7.2, 0, 17.0, 8.6, 6.9, 21.0, 2.5),
    ('Złote Pola', 'Mąka tortowa pszenna. Typ 450', 340.0, 1.2, 0.5, 0, 70.0, 2.2, 0, 11.0, 0.0),
    ('Sante', 'Otręby owsiane', 425.0, 7.0, 1.3, 0, 66.0, 1.5, 15.0, 17.0, 0.0),
    ('Sonko', 'Kasza jęczmienna perłowa', 341.0, 1.5, 0.3, 0, 68.2, 1.1, 8.9, 9.3, 0.0),
    ('Pano', 'Wafle Kukurydziane sól morska', 388.0, 3.0, 0.5, 0, 78.0, 0.8, 6.7, 9.1, 0.7),
    ('Polskie Mlyny', 'Mąka pszenna Szymanowska 480', 350.0, 1.5, 0.4, 0, 71.0, 2.2, 2.2, 12.0, 0.0),
    ('Kupiec', 'Kasza manna błyskawiczna', 348.0, 1.3, 0.2, 0, 74.0, 0.1, 2.5, 8.7, 0.0),
    ('GustoBello', 'Mąka do pizzy neapolitańskiej typ 00', 343.0, 1.2, 0.3, 0, 70.0, 0.5, 2.0, 12.0, 0),
    ('PZZ Kraków', 'Mąka pszenna tortowa', 346.0, 0.9, 0.3, 0, 72.5, 0.6, 0, 11.3, 0.0),
    ('Uniflora', 'Kiełki rzodkiewki', 58.0, 1.2, 0.1, 0, 5.3, 1.7, 3.7, 4.7, 0.0),
    ('Szczepanki', 'Mąka pszenna wrocławska typ 500', 347.0, 1.2, 0.3, 0, 74.0, 0.2, 0, 10.0, 0),
    ('Unknown', 'Kasza gryczana prażona', 109.0, 0.8, 0.2, 0, 20.0, 0, 2.6, 4.2, 0),
    ('Pani', 'Wafle Prowansalskie', 391.0, 4.4, 0.7, 0, 73.0, 0.7, 8.6, 10.4, 0.6),
    ('Culineo', 'Koncentrat Pomidorowy 30%', 116.0, 0.0, 0.0, 0, 21.0, 15.0, 4.4, 3.9, 0.1),
    ('Madero', 'Chrzan tarty', 157.0, 9.8, 0.7, 0, 12.0, 9.5, 4.4, 2.7, 1.4),
    ('Dawtona', 'Sűrített paradicsom', 106.0, 0.5, 0.1, 0, 19.0, 16.0, 3.9, 4.3, 0.1),
    ('Melvit', 'Natural Mix', 343.0, 0.8, 0.3, 0, 72.0, 6.0, 6.0, 9.0, 0.1),
    ('Culineo', 'Koncentrat pomidorowy', 97.0, 0.0, 0.0, 0, 17.0, 16.0, 3.6, 3.8, 0.2),
    ('Wojan team', 'Wojanek', 20.0, 0.0, 0.0, 0, 5.0, 4.7, 0.0, 0.0, 0.0),
    ('Pudliszki', 'Koncentrat pomidorowy', 105.0, 0.5, 0.1, 0, 19.0, 15.0, 3.6, 4.7, 0.1),
    ('Nasza Spiżarnia', 'Fasola czerwona', 101.0, 0.5, 0, 0, 14.0, 0, 0, 7.3, 0),
    ('Dawtona', 'Koncentrat pomidorowy', 101.0, 0.0, 0.0, 0, 19.0, 16.0, 3.9, 4.3, 0.1),
    ('Culineo', 'Pasta z czosnkiem', 30.0, 0.5, 0.1, 0, 5.0, 4.0, 1.4, 1.4, 0.3),
    ('Biedronka', 'Borówka amerykańska odmiany Brightwell', 57.0, 0.3, 0.0, 0, 15.0, 15.0, 2.5, 1.0, 0.0),
    ('GustoBello', 'Gnocchi Di Patate', 168.0, 0.2, 0.1, 0, 36.0, 0.2, 0.9, 4.4, 0.8),
    ('Plony natury', 'Kasza manna', 339.0, 1.0, 0.5, 0, 71.0, 0.5, 0, 10.0, 0.1),
    ('Culineo', 'Passata klasyczna', 30.0, 0.2, 0.1, 0, 4.9, 4.1, 1.5, 1.4, 0.3),
    ('Anecoop', 'Włoszczyzna', 352.0, 0.9, 0.1, 0, 74.2, 0.9, 3.0, 10.3, 0.0),
    ('Vemondo', 'Tofu wędzone', 142.0, 7.8, 1.4, 0, 3.0, 0.5, 0.7, 14.7, 1.5),
    ('El Toro Rojo', 'Oliwki zielone nadziewane pastą paprykową', 124.0, 13.0, 3.0, 0, 0.0, 0.0, 2.1, 0.7, 3.5),
    ('Plony Natury', 'Kasza Gryczana Biała', 351.0, 3.3, 0, 0, 65.0, 1.1, 0, 13.0, 0.0),
    ('Janex', 'Kasza Gryczana', 350.0, 3.0, 0.6, 0.0, 63.0, 1.0, 6.0, 14.0, 0.0),
    ('Go Vege', 'Tofu Naturalne', 138.3, 8.0, 1.0, 0, 1.5, 0.5, 2.0, 14.0, 0.2),
    ('Go VEGE', 'Tofu sweet chili', 138.0, 8.0, 1.0, 0, 2.4, 2.0, 2.0, 13.0, 1.5),
    ('Lidl', 'Avocados', 190.0, 19.5, 4.1, 0, 1.9, 0.5, 3.4, 1.9, 0.1),
    ('Kania', 'Crispy Fried Onions', 442.9, 44.0, 21.0, 0, 40.0, 9.0, 5.0, 6.0, 1.2),
    ('Vemondo', 'Tofu plain', 127.0, 7.5, 1.0, 0, 2.3, 0.5, 1.0, 12.0, 1.1),
    ('Vemondo', 'Tofu naturalne', 125.0, 7.5, 1.0, 0, 2.3, 0.5, 0.1, 12.0, 0.2),
    ('K-take it veggie', 'Tofu natur eco', 137.0, 8.0, 1.4, 0, 0.7, 0.5, 1.0, 15.0, 0.0),
    ('GustoBello', 'Polpa di pomodoro', 30.0, 0.3, 0.1, 0, 5.2, 4.9, 1.2, 1.1, 0.3),
    ('Garden Gourmet', 'Veggie Balls', 227.0, 14.4, 1.0, 0, 5.2, 3.3, 5.9, 16.2, 1.0),
    ('Vemondo', 'Tofu', 120.0, 6.9, 1.1, 0, 2.6, 0.4, 2.2, 13.6, 0.0),
    ('Tastino', 'Wafle Kukurydziane', 390.0, 4.4, 0.7, 0, 73.0, 0.7, 8.6, 10.4, 0.6),
    ('Crownfield', 'Owsianka Truskawkowa', 387.7, 8.0, 1.1, 0, 65.0, 18.0, 6.5, 9.5, 0.6),
    ('Bakello', 'Ciasto francuskie', 378.0, 23.0, 14.0, 0, 33.0, 2.0, 0, 4.9, 0.6),
    ('Violife', 'Cheddar flavour slices', 285.0, 23.0, 21.0, 0, 20.0, 0.0, 0, 0.0, 2.3),
    ('Golden Sun Lidl', 'Kasza manna', 352.0, 1.3, 0.2, 0, 74.2, 0.1, 2.5, 9.5, 0.0),
    ('Nasza Spiżarnia', 'Ananas Plastry', 70.0, 0.0, 0, 0, 16.0, 0, 0, 0.4, 0),
    ('Unknown', 'Awokado hass', 223.0, 20.3, 0, 0, 8.3, 0, 0, 1.8, 0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Plant-Based & Alternatives' and p.is_deprecated is not true
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
