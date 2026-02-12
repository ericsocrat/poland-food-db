-- PIPELINE (Canned Goods): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Canned Goods'
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
    ('Nasza Spiżarnia', 'Kukurydza słodka', 77.0, 1.8, 0.4, 0, 11.0, 5.2, 2.8, 2.9, 0.5),
    ('Dawtona', 'Kukurydza słodka', 126.0, 1.2, 0.2, 0, 24.0, 2.2, 3.9, 2.9, 0.7),
    ('Auchan', 'Kukurydza super słodka', 89.0, 2.4, 0.5, 0, 12.0, 4.9, 3.8, 2.9, 0.4),
    ('Marineo', 'Filety śledziowe w sosie pomidorowym', 154.0, 10.0, 2.1, 0, 5.9, 5.4, 0, 10.0, 1.1),
    ('Marinero', 'Płaty śledziowe smażone w zalewie octowej', 214.0, 13.0, 1.3, 0, 9.6, 6.1, 0, 15.0, 2.4),
    ('Nasza spiżarnia', 'Ogórki konserwowe', 30.0, 0.5, 0.1, 0, 6.3, 4.4, 0.5, 0.7, 0.9),
    ('Helcom', 'Tuńczyk kawałki w sosie własnym', 94.0, 0.6, 0.5, 0, 0.0, 0.0, 0, 22.0, 1.5),
    ('Provitus', 'Ogórki konserwowe hot chili', 42.0, 0.0, 0.0, 0, 9.6, 7.6, 0.5, 0.6, 1.1),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 176.0, 10.0, 1.5, 0, 3.6, 2.0, 0, 18.0, 0.6),
    ('Graal', 'Tuńczyk kawałki w oleju roślinnym', 141.0, 5.9, 0.9, 0, 0.0, 0.0, 0, 22.0, 1.3),
    ('King Oscar', 'Filety z makreli w sosie pomidorowym z papryką', 227.0, 17.0, 3.5, 0, 6.1, 4.8, 0, 12.0, 1.2),
    ('Krakus', 'Ćwikła z chrzanem', 52.0, 0.5, 0.0, 0, 9.1, 8.2, 0, 1.7, 0.6),
    ('Graal', 'Sałatka z makrelą pikantna', 134.0, 7.4, 1.6, 0, 7.1, 6.6, 0, 8.4, 1.4),
    ('Mega ryba', 'Śledź w sosie pomidorowym', 134.0, 7.9, 2.2, 0, 5.6, 1.9, 0, 10.0, 1.1),
    ('Łosoś Ustka', 'Śledź w sosie pomidorowym', 130.0, 6.4, 1.6, 0, 5.1, 4.5, 0, 13.0, 0.9),
    ('EvraFish', 'Śledzie w sosie pomidorowym', 97.0, 3.3, 0.6, 0, 4.7, 4.5, 0, 12.0, 1.1),
    ('Graal', 'Tuńczyk kawałki w bulionie warzywnym', 85.0, 0.6, 0.0, 0, 0.0, 0.0, 0, 20.0, 0.8),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym', 18.0, 0.2, 0.1, 0, 2.9, 2.9, 0.8, 0.7, 0.0),
    ('Lisner', 'Tuńczyk w sosie własnym', 99.0, 0.5, 0.1, 0, 0.0, 0.0, 0, 23.5, 1.1),
    ('Nasza Spiżarnia', 'Pomidory całe', 20.0, 0.5, 0.0, 0, 3.1, 3.1, 1.1, 1.1, 0.6),
    ('Pudliszki', 'Fasolka po Bretońsku', 87.0, 2.9, 1.1, 0, 9.1, 3.2, 3.5, 4.3, 0.9),
    ('Amerigo', 'Śledź w sosie pomidorowym', 192.0, 7.6, 1.9, 0, 17.0, 3.9, 0, 13.0, 1.2),
    ('Asia Flavours', 'Jackfruit kawałki', 21.0, 0.6, 0.2, 0, 0.5, 0.5, 6.0, 0.8, 0.4),
    ('Krakus', 'Ogórki Korniszony', 58.0, 0.5, 0, 0, 13.0, 0, 0, 0.5, 0),
    ('Lisner', 'Tuńczyk kawałki w oleju roślinnym', 180.0, 9.5, 1.6, 0, 0.0, 0.0, 0.0, 23.5, 1.0),
    ('Provitus', 'Ogórki konserwowe kozackie', 65.0, 0.5, 0.0, 0, 14.0, 13.0, 0.5, 0.8, 0),
    ('Łowicz', 'Pomidory krojone bez skórki', 20.0, 0.5, 0.0, 0, 3.0, 3.0, 0, 1.2, 0.0),
    ('Ole!', 'Cebulka marynowana złota', 47.0, 0.3, 0.1, 0, 9.4, 9.4, 1.8, 0.8, 1.3),
    ('Unknown', 'Brzoskwinie połówki w lekkim syropie', 59.0, 0.5, 0.0, 0, 14.0, 14.0, 0, 0.5, 0.0),
    ('Nasza Spiżarnia', 'Mieszanka warzywna z kukuyrdzą', 34.0, 0.5, 0.1, 0, 4.6, 3.9, 2.7, 1.5, 1.2),
    ('Jamar', 'Mieszanka warzywna meksykańska', 43.0, 0.5, 0.1, 0, 7.2, 4.4, 2.0, 1.7, 0.7),
    ('Go Vege', 'Strogonow roślinny z pieczarkami', 58.0, 2.1, 0.2, 0, 5.1, 5.0, 2.4, 3.3, 0.9),
    ('Rolnik', 'Cebulka perłowa Premium', 34.0, 0.5, 0.1, 0, 6.3, 6.1, 0, 0.5, 0.2),
    ('Neptun', 'Tuńczyk W Wodzie', 114.0, 0.9, 0, 0, 0.0, 0, 0, 27.0, 0),
    ('EvraFish', 'Makrela po meksykańsku', 178.0, 13.0, 2.4, 0, 6.3, 6.3, 0, 8.6, 1.2),
    ('Auchan', 'Tuńczyk w kawałkach w sosie własnym', 116.0, 0.9, 0.2, 0, 0.0, 0.0, 0, 27.0, 1.0),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 75.0, 1.2, 0.5, 0, 0.0, 0.0, 0.0, 23.0, 1.2),
    ('Stoczek', 'Fasolka po bretońsku z dodatkiem kiełbasy', 66.0, 1.2, 0.3, 0, 9.8, 1.9, 0, 3.1, 1.2),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 64.4, 0.0, 0.0, 0, 15.1, 14.6, 1.1, 0.3, 0.1),
    ('Dega', 'Fish spread with rice', 150.0, 9.4, 1.2, 0, 11.0, 3.8, 0, 4.8, 1.3),
    ('Nasza Spiżarnia', 'Pomidory Krojone', 19.0, 0.0, 0.0, 0, 3.2, 3.1, 1.1, 1.1, 0.4),
    ('Dawtona', 'Kukurydza gold', 77.0, 1.8, 0.4, 0, 11.0, 5.2, 2.8, 2.9, 0.4),
    ('Unknown', 'Buraczki zasmażane z cebulą', 67.0, 1.3, 0.1, 0, 11.0, 10.0, 1.6, 1.5, 0.9),
    ('Łosoś ustka', 'Paprykarz szczeciński', 181.0, 12.0, 1.6, 0, 12.0, 3.1, 0, 5.7, 1.4),
    ('Mega ryba', 'Filety z makreli w sosie pomidorowym', 91.0, 2.2, 0.3, 0, 5.8, 5.4, 0, 12.0, 0.9),
    ('Nasza Spiżarnia', 'Korniszony z chili', 17.0, 0.5, 0.1, 0, 1.5, 0.5, 2.0, 1.3, 1.5),
    ('Graal', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami', 270.0, 22.0, 5.0, 0, 6.0, 5.4, 0, 12.0, 0.8),
    ('Łosoś Ustka', 'Tinned Tomato Mackerel', 182.0, 12.7, 7.3, 0.0, 5.5, 5.5, 0.0, 12.7, 0.2),
    ('Graal', 'Makrela w sosie pomidorowym', 183.0, 13.0, 2.8, 0, 6.3, 5.3, 0, 10.0, 1.3),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 183.0, 11.8, 2.3, 0, 6.7, 6.6, 0, 11.8, 0.8)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Canned Goods' and p.is_deprecated is not true
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
