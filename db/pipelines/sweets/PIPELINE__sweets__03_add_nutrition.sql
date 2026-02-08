-- PIPELINE (Sweets): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Sweets'
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
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', '557.0', '36.0', '16.0', '0', '49.0', '40.0', '4.0', '7.7', '0.1'),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', '558.0', '45.0', '27.0', '0', '21.0', '16.0', '16.0', '10.0', '0.0'),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', '508.0', '33.0', '20.0', '0', '36.0', '32.0', '14.0', '9.1', '0.0'),
    ('E. Wedel', 'Mleczna klasyczna', '534.0', '31.0', '17.0', '0', '55.0', '55.0', '2.7', '6.3', '0.2'),
    ('Wawel', 'Gorzka Extra', '556.0', '44.4', '28.9', '0.0', '33.3', '8.9', '17.8', '15.6', '0.0'),
    ('Wawel', '100% Cocoa Ekstra Gorzka', '647.0', '60.0', '38.0', '0', '6.3', '1.2', '0', '13.0', '0.0'),
    ('Wawel', 'Gorzka 70%', '576.0', '43.0', '27.0', '0', '32.0', '28.0', '0', '9.8', '0.0'),
    ('Unknown', 'Czekolada gorzka Luximo', '555.0', '45.0', '30.0', '0', '18.0', '13.0', '17.0', '11.0', '0.1'),
    ('Luximo', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', '527.0', '36.0', '24.0', '0', '38.0', '32.0', '12.0', '7.7', '0.1'),
    ('fin CARRÉ', 'Extra dark 74% Cocoa', '571.0', '42.0', '26.0', '0', '32.0', '26.0', '0', '9.9', '0.0'),
    ('Lindt Excellence', 'Excellence 85% Cacao Rich Dark', '578.0', '46.0', '27.0', '0', '22.0', '15.0', '0.0', '12.5', '0.0'),
    ('Milka', 'Chocolat au lait', '539.0', '31.0', '19.0', '0', '57.0', '55.0', '2.3', '6.5', '0.3'),
    ('Toblerone', 'Milk Chocolate with Honey and Almond Nougat', '528.0', '28.0', '17.0', '0', '61.0', '60.0', '2.4', '5.6', '0.1'),
    ('Storck', 'Merci Finest Selection Assorted Chocolates', '563.0', '36.1', '19.9', '0', '49.9', '48.0', '0', '7.8', '0.2'),
    ('Fin Carré', 'Milk Chocolate', '535.0', '30.2', '18.4', '0', '57.9', '56.6', '1.9', '6.9', '0.2'),
    ('fin Carré', 'Dunkle Schokolade mit ganzen Haselnüssen', '587.0', '44.3', '17.9', '0', '34.4', '30.0', '8.0', '8.6', '0.0'),
    ('Lindt', 'Lindt Excellence Dark Orange Intense', '535.0', '32.0', '17.0', '0', '51.0', '46.0', '0', '7.0', '0.1'),
    ('Fin Carré', 'Weiße Schokolade', '539.0', '30.0', '18.5', '0', '59.7', '59.4', '0.0', '7.2', '0.4'),
    ('Milka', 'Milka chocolate Hazelnuts', '551.0', '34.1', '17.4', '0', '52.1', '50.9', '3.0', '7.2', '0.0'),
    ('Fin Carré', 'Extra Dark 85% Cocoa', '588.0', '48.1', '29.0', '0', '21.2', '12.8', '0', '10.5', '0.0'),
    ('Ritter SPORT', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', '516.1', '25.8', '11.3', '0.0', '61.3', '51.6', '6.5', '6.5', '0.0'),
    ('Milka', 'Happy Cow', '538.0', '31.0', '18.0', '0', '58.0', '57.0', '1.9', '6.1', '0.3'),
    ('Heidi', 'Dark Intense', '591.0', '48.0', '29.0', '0', '25.0', '22.0', '0', '7.8', '0.0'),
    ('Schogetten', 'Schogetten alpine milk chocolate', '560.0', '35.0', '22.0', '0', '55.0', '55.0', '0', '5.4', '0.1'),
    ('Milka', 'Milka Mmmax Oreo', '556.0', '34.0', '19.0', '0', '56.0', '48.0', '1.7', '5.0', '0.4'),
    ('Milka', 'Schokolade Joghurt', '573.0', '37.0', '21.0', '0', '56.0', '55.0', '1.1', '4.4', '0.2'),
    ('Milka', 'Strawberry', '560.0', '34.5', '19.5', '0', '55.0', '55.0', '1.0', '4.0', '0.2'),
    ('Hatherwood', 'Salted Caramel Style', '459.0', '18.0', '2.0', '0', '71.0', '12.7', '1.0', '1.9', '0.1')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
