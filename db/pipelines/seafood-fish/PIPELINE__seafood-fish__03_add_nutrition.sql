-- PIPELINE (Seafood & Fish): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Seafood & Fish'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 197.0, 13.0, 0, 0, 0.0, 0.0, 0, 20.0, 3.1),
    ('Marinero', 'Łosoś wędzony na zimno', 191.0, 12.0, 1.8, 0, 0.2, 0.2, 0.0, 20.0, 3.0),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 68.0, 0.5, 0.0, 0, 0.0, 0.0, 0, 17.0, 0.5),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 331.0, 31.3, 3.4, 0, 5.7, 4.7, 0, 6.6, 2.5),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 195.0, 11.0, 2.0, 0, 0.0, 0.0, 0, 24.0, 1.7),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 212.0, 17.0, 3.4, 0, 4.1, 0.2, 0, 10.0, 0.8),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 304.0, 27.8, 2.8, 0, 4.7, 4.0, 0, 8.5, 3.0),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 175.0, 12.7, 2.4, 0, 0.1, 0.0, 0, 15.0, 6.3),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', 212.0, 15.0, 1.2, 0, 9.3, 4.3, 0, 8.9, 0.8),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 195.0, 12.7, 2.8, 0, 10.0, 9.2, 0.6, 9.9, 2.4),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', 309.0, 28.0, 4.2, 0, 6.4, 5.6, 0, 7.8, 1.9),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', 262.0, 23.0, 2.8, 0, 5.3, 4.5, 1.2, 8.7, 1.7),
    ('Śledzie od serca', 'Śledzie po żydowsku', 325.0, 31.0, 3.0, 0, 2.8, 2.3, 0, 7.7, 1.6),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 170.0, 10.0, 1.4, 0, 0.5, 0.5, 0, 20.0, 3.0),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', 195.0, 11.0, 2.0, 0, 0.0, 0.0, 0, 24.0, 1.7),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 297.0, 28.0, 3.0, 0, 4.5, 3.5, 0, 6.6, 3.2),
    ('Pescadero', 'Filety z pstrąga', 137.0, 5.8, 0.9, 0, 0.2, 0.2, 0, 21.1, 2.0),
    ('Contimax', 'Wiejskie filety śledziowe marynowane z cebulą', 199.0, 16.0, 1.8, 0, 5.1, 4.5, 0, 8.7, 2.5),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', 200.0, 13.0, 1.5, 0, 0.8, 0.6, 0, 20.0, 3.0),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 189.0, 9.8, 1.7, 0, 0.0, 0, 0, 25.0, 0),
    ('Marinero', 'Łosoś łagodny', 195.0, 11.0, 2.0, 0, 0.0, 0.0, 0, 24.0, 1.7),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 196.0, 15.0, 3.4, 0, 5.3, 4.8, 0, 10.0, 0.9),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 127.0, 6.8, 1.7, 0, 5.5, 5.5, 0, 11.0, 1.2),
    ('Lisner', 'Marinated Herring in mushroom sauce', 322.0, 30.0, 4.5, 0, 6.4, 5.5, 0, 6.5, 0.0),
    ('Suempol', 'Gniazda z łososia', 217.0, 14.0, 3.3, 0, 0.1, 0, 0, 24.0, 2.0),
    ('Koryb', 'Łosoś atlantycki', 199.0, 12.0, 1.4, 0, 0.0, 0, 0, 22.0, 0.0),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', 179.0, 11.0, 1.7, 0, 0.5, 0.5, 0, 20.0, 2.9),
    ('Unknown', 'Łosoś wędzony na gorąco', 212.0, 12.0, 3.0, 0, 0.2, 0.2, 0.0, 23.0, 1.8),
    ('Lisner', 'Herring single portion with onion', 274.0, 25.0, 2.3, 0, 3.9, 3.4, 0, 8.2, 2.6),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 170.0, 12.0, 2.7, 0, 5.6, 3.8, 0.0, 10.0, 1.0),
    ('Lisner', 'Herring Snack', 294.0, 27.0, 3.0, 0, 3.8, 3.6, 0, 8.7, 2.6),
    ('nautica', 'Śledzie Wiejskie', 188.0, 13.1, 2.9, 0, 7.6, 5.8, 0.8, 9.4, 2.9),
    ('Well done', 'Łosoś atlantycki', 179.0, 11.0, 2.1, 0, 0.0, 0.0, 0, 20.0, 3.3),
    ('Graal', 'Szprot w sosie pomidorowym', 109.0, 4.3, 1.6, 0, 5.6, 4.1, 0, 12.0, 1.4),
    ('Marinero', 'Filety śledziowe a''la Matjas', 127.0, 10.2, 2.8, 0, 0.6, 0.6, 0, 8.5, 7.5)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Seafood & Fish' and p.is_deprecated is not true
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
