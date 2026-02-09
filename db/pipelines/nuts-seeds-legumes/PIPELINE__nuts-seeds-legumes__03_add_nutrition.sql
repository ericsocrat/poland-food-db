-- PIPELINE (Nuts, Seeds & Legumes): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
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
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 641.0, 57.0, 5.9, 0, 5.7, 4.9, 13.0, 20.0, 0.0),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 609.0, 49.0, 7.8, 0, 12.0, 5.6, 8.6, 26.0, 0.0),
    ('bakador', 'migdały', 596.0, 49.0, 3.9, 0, 8.0, 4.6, 12.0, 24.0, 0.0),
    ('Felix', 'Orzeszki ziemne smażone i solone', 615.0, 51.0, 7.8, 0, 11.0, 5.3, 8.2, 25.0, 1.2),
    ('Felix', 'Felix orzeszki ziemne', 615.0, 51.0, 7.8, 0, 11.0, 5.3, 8.2, 25.0, 1.2),
    ('BakaD''Or', 'Mieszanka egzotyczna', 454.0, 24.0, 12.0, 0, 49.0, 49.0, 7.4, 6.7, 0.1),
    ('felix', 'Orzeszki ziemne lekko solone', 615.0, 51.0, 7.7, 0, 11.0, 5.3, 8.2, 25.0, 0.7),
    ('Alesto', 'Alesto pörkölt egészmogyoró', 722.0, 70.5, 6.8, 0, 3.5, 3.5, 8.2, 14.3, 0.0),
    ('Felix', 'Orzeszki ziemne solone', 609.0, 50.0, 7.7, 0, 11.0, 5.2, 8.2, 24.0, 1.2),
    ('Bakador', 'Orzechy pekan', 730.0, 73.0, 6.5, 0, 3.5, 3.3, 10.0, 9.8, 0),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 610.0, 49.2, 7.8, 0, 11.6, 5.6, 0, 25.8, 0.0),
    ('Bakador', 'Mieszanka Orzechowa', 637.0, 57.0, 6.4, 0, 5.4, 5.3, 12.0, 19.0, 0.0),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 614.0, 50.0, 7.8, 0, 12.0, 5.5, 8.3, 24.0, 0.7),
    ('Felix', 'Peanuts join BBQ-Honey Style', 614.0, 50.0, 7.8, 0, 12.0, 6.4, 8.2, 24.0, 0.8),
    ('Bakador', 'Orzechy Nerkowca', 587.0, 45.0, 8.3, 0, 24.0, 6.1, 5.1, 20.0, 0.0),
    ('Lidl', 'Mieszanka Orzechów', 644.0, 56.1, 6.3, 0, 10.6, 4.7, 0, 19.5, 0),
    ('Alesto', 'Almonds natural', 621.0, 53.3, 4.3, 0, 4.8, 4.8, 12.1, 24.5, 0.0),
    ('Alesto', 'Cashewkerne', 600.0, 47.6, 9.0, 0, 19.8, 6.5, 5.2, 20.5, 0.0),
    ('Alesto', 'Nussmix', 647.0, 58.0, 6.3, 0, 15.0, 4.3, 8.7, 20.3, 0.0),
    ('Alesto Selection', 'Walnusskerne naturbelassen', 713.0, 69.0, 6.7, 0, 3.7, 3.0, 6.7, 15.7, 0.0),
    ('Alesto', 'Noisettes grillées', 723.0, 70.3, 6.7, 0, 3.7, 3.7, 8.3, 14.3, 0.0),
    ('Alesto Selection', 'Pecan Nuts natural', 725.0, 71.4, 6.8, 0, 4.2, 4.1, 10.0, 11.5, 0.0),
    ('Carrefour', 'Cacahuètes grillées sans sel ajouté.', 622.0, 51.0, 6.1, 0, 9.7, 5.0, 8.6, 27.0, 0.0),
    ('CARREFOUR CLASSIC''', 'CACAHUÈTES GRILLEES SALEES', 615.0, 50.0, 6.0, 0, 9.6, 5.0, 8.5, 26.0, 0.8),
    ('Alesto', 'Protein Mix mit Nüssen & Sojabohnen', 586.0, 45.9, 6.7, 0, 6.8, 3.8, 11.3, 30.8, 1.0),
    ('Carrefour', 'Pistaches grillees', 611.0, 49.0, 6.1, 0, 13.0, 7.0, 9.8, 24.0, 0.0),
    ('Carrefour', 'Cacahuètes', 615.0, 50.0, 6.0, 0, 9.6, 5.0, 8.5, 26.0, 0.8),
    ('Carrefour', 'Pistaches grillées salées', 604.0, 49.0, 6.0, 0, 13.0, 7.2, 9.1, 24.0, 0.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
