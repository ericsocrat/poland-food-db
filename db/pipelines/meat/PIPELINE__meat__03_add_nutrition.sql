-- PIPELINE (Meat): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Meat'
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
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 186.0, 13.0, 4.0, 0, 1.7, 0.5, 0.0, 15.5, 0.0),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 291.0, 25.0, 9.4, 0, 1.3, 1.1, 0, 15.0, 2.1),
    ('Kraina Wędlin', 'Parówki z szynki', 277.0, 24.0, 9.6, 0, 1.3, 0.6, 0, 14.0, 1.8),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 110.0, 2.3, 0.9, 0, 0.0, 0.0, 0, 22.0, 1.9),
    ('Morliny', 'Szynka konserwowa z galaretką', 114.0, 4.9, 2.0, 0, 0.5, 0.0, 0.0, 17.0, 2.0),
    ('Stoczek', 'Kiełbasa z weka', 269.0, 24.0, 9.1, 0, 1.0, 0.5, 0, 13.0, 2.4),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 107.0, 2.5, 1.2, 0, 2.2, 0.5, 0, 19.0, 2.0),
    ('Biedra', 'Polędwica Wiejska Sadecka', 155.0, 5.0, 3.4, 0, 0.5, 0.5, 0, 27.0, 0.0),
    ('Krakus', 'Parówki z piersi kurczaka', 185.0, 13.0, 3.4, 0, 1.0, 0.7, 0, 16.0, 2.2),
    ('Strzała', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', 226.0, 18.0, 6.0, 0, 2.5, 1.0, 1.0, 13.0, 1.7),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 241.0, 19.0, 7.6, 0, 0.5, 0.0, 0, 17.0, 2.1),
    ('Duda', 'Parówki wieprzowe Mediolanki', 280.0, 24.0, 10.0, 0, 2.9, 1.3, 0, 13.0, 2.2),
    ('Kraina Wędlin', 'Szynka Zawędzana', 102.0, 2.0, 0.7, 0, 3.0, 0.8, 0, 18.0, 2.5),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 102.0, 2.4, 1.2, 0, 2.0, 0.5, 0.0, 18.0, 2.2),
    ('Szubryt', 'Kiełbasa z czosnkiem', 237.0, 20.0, 6.7, 0, 0.6, 0.5, 0, 14.0, 1.6),
    ('Morliny', 'Berlinki Classic', 223.5, 18.0, 6.7, 0, 2.8, 1.0, 0, 13.0, 2.5),
    ('tarczyński', 'Kabanosy wieprzowe', 507.0, 42.0, 17.0, 0.0, 5.2, 1.9, 0.0, 26.0, 0.0),
    ('Morliny', 'Berlinki classic', 225.0, 18.0, 6.7, 0, 2.8, 1.0, 0, 13.0, 2.5),
    ('Animex Foods', 'Berlinki Kurczak', 181.0, 13.0, 3.9, 0, 1.1, 0.7, 0, 15.0, 2.4),
    ('Podlaski', 'Pasztet drobiowy', 160.0, 12.0, 2.3, 0, 5.5, 0.5, 0, 7.5, 1.4),
    ('Krakus', 'Szynka eksportowa', 98.0, 1.6, 0.6, 0, 2.0, 1.9, 0, 19.0, 2.5),
    ('Drosed', 'Podlaski pasztet drobiowy', 181.0, 15.0, 3.0, 0, 4.0, 0.8, 0, 7.0, 1.4),
    ('Profi', 'Chicken Pâté', 187.0, 14.0, 4.8, 0, 6.3, 0.7, 0, 8.6, 1.4),
    ('Berlinki', 'Z Serem', 256.0, 21.0, 7.5, 0, 2.8, 0.8, 0, 14.0, 2.9),
    ('Morliny', 'Boczek', 308.0, 28.0, 9.8, 0, 1.0, 0.0, 0, 13.0, 2.0),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', 208.0, 17.0, 5.4, 0, 5.2, 0.6, 0, 8.2, 1.3),
    ('Tarczynski', 'Krakauer Wurst (polnische Brühwurst)', '209.0', '13.0', '5.1', '0', '1.0', '1.0', '0', '22.0', '2.2'),
    ('Profi', 'Pasztet z pomidorami', 187.0, 14.0, 4.5, 0, 6.7, 1.4, 0, 8.4, 1.4)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';
