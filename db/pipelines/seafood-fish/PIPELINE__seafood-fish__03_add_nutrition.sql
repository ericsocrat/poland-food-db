-- PIPELINE (Seafood & Fish): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Seafood & Fish'
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
    ('Jantar', 'Szprot wędzony na gorąco', '229.0', '17.0', '4.7', '0', '0.2', '0.2', '0', '19.0', '2.0'),
    ('Dega', 'Ryba śledź po grecku', '126.0', '7.3', '1.0', '0', '9.4', '6.5', '0', '5.1', '0.9'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', '212.0', '15.0', '1.2', '0', '9.3', '4.3', '0', '8.9', '0.8'),
    ('Fisher King', 'Pstrąg łososiowy wędzony w plastrach', '198.0', '13.0', '2.5', '0', '0.0', '0.0', '0', '20.0', '3.2'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', '195.0', '12.7', '2.8', '0', '10.0', '9.2', '0.6', '9.9', '2.4'),
    ('Lisner', 'Pastella - pasta z łososia', '518.0', '52.4', '4.2', '0', '6.6', '6.4', '0', '4.5', '1.9'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', '196.0', '15.0', '3.4', '0', '5.3', '4.8', '0', '10.0', '0.9'),
    ('Lisner', 'Marinated Herring in mushroom sauce', '322.0', '30.0', '4.5', '0', '6.4', '5.5', '0', '6.5', '0.0'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', '127.0', '6.8', '1.7', '0', '5.5', '5.5', '0', '11.0', '1.2'),
    ('Lisner', 'Herring single portion with onion', '274.0', '25.0', '2.3', '0', '3.9', '3.4', '0', '8.2', '2.6'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', '170.0', '12.0', '2.7', '0', '5.6', '3.8', '0.0', '10.0', '1.0'),
    ('nautica', 'Śledzie Wiejskie', '188.0', '13.1', '2.9', '0', '7.6', '5.8', '0.8', '9.4', '2.9'),
    ('Lisner', 'Herring Snack', '294.0', '27.0', '3.0', '0', '3.8', '3.6', '0', '8.7', '2.6'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', '157.0', '8.6', '1.3', '0', '0.5', '0.5', '0', '20.0', '2.0'),
    ('Carrefour Discount', 'Bâtonnets saveur crabe', '131.0', '5.4', '0.4', '0', '14.0', '2.7', '0', '6.2', '1.7'),
    ('ocean sea', 'Paluszki surimi', '136.0', '4.9', '0.4', '0', '15.3', '3.3', '0', '8.3', '2.0'),
    ('Carrefour', 'Queues de crevettes CRUES', '81.0', '0.8', '0.3', '0', '0.8', '0.0', '0.0', '18.0', '0.9'),
    ('Carrefour', 'Crevettes sauvages décortiquées cuites', '48.0', '0.7', '0.2', '0', '0.5', '0.5', '0.5', '9.9', '1.3'),
    ('Vici', 'Classic surimi sticks', '112.0', '3.2', '0.3', '0', '13.2', '2.9', '0', '8.2', '1.3'),
    ('Rio Mare', 'Insalatissime Sicily Edition', '208.0', '13.0', '1.6', '0', '12.0', '1.4', '0', '9.5', '1.1')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
