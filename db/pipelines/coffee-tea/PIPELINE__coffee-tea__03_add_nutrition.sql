-- PIPELINE (Coffee & Tea): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Coffee & Tea'
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
    ('Herbapol', 'Herbaciany ogród - Prosto z lasu.', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Herbapol', 'Herbaciany ogród, malina z żurawiną', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Cafe d''Or', 'Cappuccino o smaku śmietankowym', 426.0, 10.0, 9.4, 0, 76.0, 50.0, 1.8, 7.1, 0.4),
    ('Mokate', 'Mokate Cappuccino z belgijską czekoladą', 447.0, 15.0, 13.0, 0.0, 68.0, 56.0, 0.0, 8.6, 0.3),
    ('PKN Orlen', 'Napój kawowy na bazie pełnego mleka i śmietanki', 67.0, 3.2, 2.0, 0, 8.3, 8.1, 0, 1.5, 0.3),
    ('Herbapol', 'Herbapol Herbaciany Ogród Briar Rose Fruit-herbal Tea', 3.0, 0.0, 0.0, 0, 3.0, 0.0, 0.0, 0.0, 0.0),
    ('Big Active', 'Herbata biała tajska cytryna, kwiat granatu', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Big-Active', 'Early Grey & płatki róży', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Big-Active', 'Zielona herbata z kawałkami opuncji', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Big Active', 'Herbata biała jaśmin', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Cafe d''or', 'Kawa rozpuszczalna gold liofilizowana robusta/arabica', 2.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Unilever', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 4.0, 0.0, 0.0, 0, 0.5, 0.5, 0, 0.0, 0.0),
    ('Remsey', 'Herbata czarna aromatyzowana Earl Grey Strong w torebkach do zaparzania', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lipton', 'Yellow Label', 4.0, 0.0, 0.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Mokate', 'Cappuccino', 441.0, 13.0, 11.0, 0, 74.0, 52.0, 0.0, 4.6, 0.4),
    ('Mokate', 'Mokate Cappuccino smak smietankowy', 432.0, 11.0, 10.0, 0, 75.0, 53.0, 0, 7.2, 0.3),
    ('Mokate', 'Cappuccino o smaku orzechowym', 437.0, 10.0, 8.7, 0, 80.0, 53.0, 0, 5.5, 0.3),
    ('Cafe d''Or', 'Cappuccino', 422.0, 9.9, 8.9, 0, 75.0, 50.0, 1.4, 7.5, 0),
    ('Mokate', 'Cappuccino z magnezem', 431.0, 9.6, 8.2, 0, 80.0, 53.0, 0, 5.0, 0.3),
    ('Mokate', 'Cappuccino o smaku rumowym', 421.0, 8.5, 7.4, 0, 80.0, 55.0, 0, 6.2, 0.3),
    ('Mokate', 'Cappuccino caffee', 450.0, 12.5, 12.5, 0, 75.0, 55.0, 0.0, 10.0, 0.3),
    ('Mokate', 'Cappuccino vanilla', 450.0, 13.0, 11.0, 0, 78.0, 50.0, 0, 4.6, 0.4),
    ('Mokate', 'Cappuccino karmelowe', 425.0, 8.5, 7.3, 0, 81.0, 59.0, 0, 6.0, 0.2),
    ('Mokate', 'Mokate Gold Latte Caramel', 413.0, 7.9, 7.2, 0, 80.0, 59.0, 0.0, 4.7, 1.3),
    ('Senso', 'Pumpkin Spice Latte Coffe', 218.0, 12.5, 6.8, 0, 8.8, 7.3, 0, 8.5, 0.3),
    ('Mokate Gold', 'Vanilla late', 59.0, 1.2, 0.9, 0, 11.0, 8.3, 0, 0.9, 0),
    ('Mokate', 'Mokate mocha double chocolate', 414.3, 7.9, 7.1, 0.7, 78.6, 57.1, 7.1, 7.1, 1.1),
    ('Cafe d''Or', 'Cappuccino o smaku orzechowym', 437.0, 10.0, 8.4, 0, 80.0, 57.0, 0, 6.0, 0.7),
    ('Lipton', 'Ice Tea Peach', 19.0, 0.0, 0, 0, 4.6, 4.4, 0, 0.0, 0.0),
    ('Lipton', 'Green Ice Tea', 10.0, 0.0, 0.0, 0, 2.4, 2.2, 0, 0.0, 0.0),
    ('Herbapol', 'Malina', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Herbapol', 'Herbatka na zimno Truskawka Rabarbar', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Sir Adalbert''s tea', 'Herbata czarna earl grey liściasta', 0.1, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Bifix', 'Herbata z suszu owocowego', 48.0, 0.5, 0.1, 0, 10.1, 6.5, 0, 0.7, 0.0),
    ('Asia Flavours', 'Matcha', 383.0, 2.5, 0.7, 0, 70.7, 12.9, 0, 18.2, 0.1),
    ('Milton', 'Herbata zielona o smaku grejpfrutowym', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Herbapol', 'Herb. aronia Herbapol 20SZT', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Big-active', 'Zielona herbata w torebkach', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Lipton', 'Lipton Green 0.5', 10.0, 0.0, 0.0, 0, 2.4, 2.2, 0.0, 0.0, 0.0),
    ('Lipton', 'Zielona herbata z nutą truskawki i maliny', 4.0, 0.5, 0.1, 0, 0.5, 0.5, 0.0, 0.5, 0.0),
    ('Unknown', 'Herbata Bio-active Li Zielona Z Owoc Malin 100G', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Nestlé', 'Nescafe', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 8.0),
    ('Carrefour', 'Intenso', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0, 0.2, 0.0),
    ('Carrefour', 'Classico', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Carrefour', 'Dolce', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Carrefour', 'Cappuccino', 440.0, 12.0, 11.0, 0, 77.0, 52.0, 0.5, 5.9, 0.3),
    ('Carrefour', 'Latte Macchiato', 451.0, 15.0, 13.0, 0, 65.0, 57.0, 0.0, 14.0, 0.5),
    ('Carrefour', 'Cappuccino Vanilata', 47.0, 0.6, 0.6, 0, 9.2, 7.0, 0.5, 1.1, 0.1),
    ('Carrefour', 'CAPPUCCINO Decaffeinato', 336.0, 0.5, 0.3, 0, 63.0, 63.0, 3.4, 18.0, 0.9),
    ('Carrefour', 'CAPPUCCINO Chocolate', 46.0, 0.6, 0.5, 0, 8.7, 7.6, 0.5, 1.3, 0.1),
    ('L''Or Barista', 'L''or Barista Double Ristretto Intensity 11', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Carrefour', 'Lungo Généreux et Fruité', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0, 0.2, 0.0),
    ('Carrefour', 'Pérou', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0.0, 0.2, 0.0),
    ('Carrefour BIO', 'AMÉRIQUE LATINE GRAINS Pur Arabica', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0.0, 0.2, 0.0),
    ('Carrefour BIO', 'Amérique Latine', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0, 0.2, 0.0),
    ('Carrefour', 'Espresso nocciolita', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0.0, 0.2, 0.0),
    ('Carrefour', 'Espresso Colombie', 1.0, 0.0, 0.0, 0, 0.3, 0.0, 0.0, 0.2, 0.0),
    ('Carrefour', 'Lungo Voluptuo', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.1, 0.0),
    ('Carrefour', 'Café Grande 100% Arabica', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.1, 0.0),
    ('Carrefour', 'Cappuccino ORIGINAL', 35.0, 0.5, 0.5, 0, 6.1, 5.6, 0, 1.5, 0.1),
    ('Carrefour', 'Caffe latte', 26.0, 0.5, 0.3, 0, 3.5, 2.4, 0.5, 1.7, 0.1),
    ('Carrefour', 'Espresso decaffeinato', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.2, 0.0),
    ('Carrefour', 'Espresso', 1.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.1, 0.0),
    ('Tian Ku Shan', 'Matcha Tea powder', 296.0, 23.0, 0.0, 0, 34.7, 0.0, 0, 34.2, 0.0),
    ('Lipton', 'Herbata czarna z naturalnym aromatem', 4.0, 0.0, 0.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Lipton', 'Pokrzywa z mango', 4.0, 0.0, 0.0, 0, 0.5, 0.5, 0, 0.5, 0.0),
    ('Lipton', 'Yellow Label granulowana', 4.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.5, 0.0),
    ('Lavazza', 'Qualita Oro', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.1, 0.0),
    ('Jacobs', 'Kawa rozpuszczalna Jacobs Krönung', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Jacobs', 'Crema', 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Vemondo', 'Kaffee Hafer', 53.0, 0.7, 0.1, 0, 11.2, 6.4, 0, 0.4, 0.1),
    ('Cafe d''or', 'Ice Coffee Macchiato', 73.0, 1.4, 0.9, 0, 11.7, 11.3, 0, 3.4, 0.2),
    ('Kopiko', 'Kopiko', 66.7, 1.2, 0, 0, 11.7, 10.0, 0, 1.7, 0.3),
    ('Nescafé', 'Frappé 3in1', 379.0, 3.0, 2.7, 0, 76.2, 73.1, 2.8, 10.2, 0.6),
    ('Starbucks', 'Caramel macchiato', 63.0, 1.6, 1.0, 0, 9.0, 8.8, 0, 2.9, 0.1),
    ('Jacobs', 'Jacobs CAPPUCCINO ORIGINAL', 385.0, 9.8, 9.7, 0, 43.0, 43.0, 3.5, 12.0, 1.2),
    ('Jacobs', 'Jacobs', 418.0, 11.0, 10.0, 0, 70.0, 54.0, 4.5, 6.5, 0.9),
    ('Arizona', 'Green tea', 19.0, 0.0, 0.0, 0, 5.0, 4.7, 0, 0.0, 0.0),
    ('Lipton', 'Earl Grey (classic) - Lipton', 1.0, 0.0, 0.0, 0, 0.2, 0.0, 0.0, 0.1, 0.0),
    ('FuzeTea', 'Fuze Tea Peach Hibiscus', 19.0, 0.0, 0.0, 0, 4.5, 4.5, 0.0, 0.0, 0.0),
    ('Unilever', 'Saga herbata czarna ekspresowa', 4.0, 0.0, 0.0, 0, 0.0, 0.0, 0, 0.5, 0.0),
    ('Lipton', 'Lipton Herbata Green Tea Citrus', 4.0, 0.5, 0.1, 0, 0.5, 0.5, 0, 0.5, 0),
    ('Lipton', 'Herbata aromatyzowana mango i czarna porzeczka', 4.0, 0.5, 0.1, 0, 0.5, 0.5, 0.0, 0.5, 0.0),
    ('Lipton', 'The tropical', 4.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.0),
    ('Unknown', 'Sir Albert''s tea', 0.0, 0.0, 0, 0, 0.0, 0, 0, 0.0, 0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Coffee & Tea' and p.is_deprecated is not true
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
