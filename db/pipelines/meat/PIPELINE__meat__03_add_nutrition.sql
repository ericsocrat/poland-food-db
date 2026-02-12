-- PIPELINE (Meat): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Meat'
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
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 186.0, 13.0, 4.0, 0, 1.7, 0.5, 0.0, 15.5, 0.0),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 291.0, 25.0, 9.4, 0, 1.3, 1.1, 0, 15.0, 2.1),
    ('Kraina Wędlin', 'Parówki z szynki', 277.0, 24.0, 9.6, 0, 1.3, 0.6, 0, 14.0, 1.8),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 110.0, 2.3, 0.9, 0, 0.0, 0.0, 0, 22.0, 1.9),
    ('Morliny', 'Szynka konserwowa z galaretką', 114.0, 4.9, 2.0, 0, 0.5, 0.0, 0.0, 17.0, 2.0),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 107.0, 2.5, 1.2, 0, 2.2, 0.5, 0, 19.0, 2.0),
    ('Biedra', 'Polędwica Wiejska Sadecka', 155.0, 5.0, 3.4, 0, 0.5, 0.5, 0, 27.0, 0.0),
    ('Krakus', 'Parówki z piersi kurczaka', 185.0, 13.0, 3.4, 0, 1.0, 0.7, 0, 16.0, 2.2),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 241.0, 19.0, 7.6, 0, 0.5, 0.0, 0, 17.0, 2.1),
    ('Kraina Wędlin', 'Szynka Zawędzana', 102.0, 2.0, 0.7, 0, 3.0, 0.8, 0, 18.0, 2.5),
    ('Dania Express', 'Polędwiczki z kurczaka panierowane', 175.0, 7.7, 0.9, 0, 7.8, 0.3, 0.5, 18.5, 1.8),
    ('KRAINA WEDLIN', 'Polędwica drobiowa', 100.0, 2.0, 0.6, 0, 2.5, 1.0, 0.0, 18.0, 1.9),
    ('Kraina Wędlin', 'Kiełbasa Żywiecka z indyka', 160.0, 7.4, 2.2, 0, 0.3, 0.1, 0.1, 23.0, 2.8),
    ('Kraina Wędlin', 'Szynka Wędzona', 114.0, 3.0, 1.2, 0, 1.1, 0.6, 0, 20.0, 2.3),
    ('Kraina Wędlin', 'Kiełbasa Myśliwska', 309.0, 21.1, 7.1, 0, 1.1, 1.1, 0.0, 28.9, 3.1),
    ('Lisner', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 265.0, 23.0, 2.2, 0, 9.3, 5.8, 0, 4.5, 1.4),
    ('Masarnia Strzała', 'Wołowina w sosie własnym', 189.0, 14.0, 6.0, 0, 0.6, 0.3, 0.1, 15.0, 2.1),
    ('Goodvalley', 'Wędzony Schab 100% polskiego mięsa', 125.0, 4.2, 1.8, 0, 0.0, 0.0, 0.0, 22.0, 2.6),
    ('Yeemy', 'Pikantne skrzydełka panierowane z kurczaka', 249.0, 16.0, 3.7, 0, 10.0, 0.9, 1.1, 16.0, 2.1),
    ('Kraina Mięs', 'mięso mielone z łopatki wieprzowej i wołowiny', 200.0, 14.0, 5.6, 0, 0.5, 0.5, 0, 19.0, 0.1),
    ('Stoczek', 'Kiełbasa z weka', 269.0, 24.0, 9.1, 0, 1.0, 0.5, 0, 13.0, 2.4),
    ('Olewnik', 'Żywiecka kiełbasa sucha z szynki.', 187.0, 8.5, 3.4, 0, 0.6, 0.5, 0, 27.0, 2.5),
    ('Biedronka', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 167.0, 11.0, 4.1, 0, 0.5, 0.5, 0, 16.0, 1.0),
    ('Provincja', 'Pasztet z dzika z wątróbką drobiową', 191.0, 13.0, 9.7, 0, 1.6, 0.3, 0, 17.0, 2.4),
    ('Duda', 'Parówki wieprzowe Mediolanki', 280.0, 24.0, 10.0, 0, 2.9, 1.3, 0, 13.0, 2.2),
    ('Kraina Mięs', 'Tatar wołowy', 116.0, 4.0, 1.0, 0, 0.5, 0.0, 0, 19.0, 2.3),
    ('Nasze Smaki', 'Mięsiwo w sosie własnym', 149.0, 8.7, 3.1, 0, 0.5, 0.5, 0, 18.0, 1.7),
    ('Kraina Wędlin', 'Salami ostródzkie', 441.0, 39.0, 14.0, 0, 0.3, 0.0, 0.2, 22.0, 4.2),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 102.0, 2.4, 1.2, 0, 2.0, 0.5, 0.0, 18.0, 2.2),
    ('Kraina Mięs', 'Mięso Mielone Z Kurczaka Świeże', 148.0, 7.9, 2.7, 0, 0.5, 0.5, 0, 19.0, 0.2),
    ('Morliny', 'Boczek wędzony', 334.0, 31.0, 12.0, 0, 0.7, 0.0, 0, 13.0, 2.0),
    ('Sokołów', 'Salami z cebulą', 425.0, 37.0, 15.0, 0, 4.0, 1.0, 0, 19.0, 3.7),
    ('Kraina Wędlin', 'Boczek wędzony surowy', 274.0, 23.0, 9.2, 0, 0.6, 0.5, 0, 16.0, 2.1),
    ('Sokołów', 'Tatar wołowy', 121.0, 5.4, 2.2, 0, 0.5, 0.5, 0, 17.0, 2.4),
    ('Drobimex', 'Polędwica z kurcząt', 107.0, 2.5, 1.2, 0, 2.2, 0.5, 0, 19.0, 2.0),
    ('Sokołów', 'Stówki z mięsa z piersi kurczaka', 179.0, 12.0, 3.5, 0, 1.8, 0.8, 0, 16.0, 2.0),
    ('Dolina Dobra', 'Kiełbaski 100% mięsa', 234.0, 18.0, 6.6, 0, 0.7, 0.0, 0, 17.0, 2.1),
    ('Morliny', 'Mięsko ze smalczykiem', 378.0, 36.0, 14.0, 0, 1.5, 0.0, 0.0, 12.0, 1.9),
    ('Drobimex', 'Pierś pieczona z pomidorami i ziołami', 114.0, 2.0, 0.7, 0, 2.0, 2.0, 0, 22.0, 2.5),
    ('Sokołów', 'Boczek surowy wędzony', 278.0, 24.0, 2.0, 0, 0.5, 0.5, 0, 15.0, 1.3),
    ('Morliny', 'Berlinki classic', 225.0, 18.0, 6.7, 0, 2.8, 1.0, 0, 13.0, 2.5),
    ('tarczyński', 'Kabanosy wieprzowe', 507.0, 42.0, 17.0, 0.0, 5.2, 1.9, 0.0, 26.0, 0.0),
    ('Morliny', 'Berlinki Classic', 223.5, 18.0, 6.7, 0, 2.8, 1.0, 0, 13.0, 2.5),
    ('Krakus', 'Szynka eksportowa', 98.0, 1.6, 0.6, 0, 2.0, 1.9, 0, 19.0, 2.5),
    ('Drosed', 'Podlaski pasztet drobiowy', 181.0, 15.0, 3.0, 0, 4.0, 0.8, 0, 7.0, 1.4),
    ('Morliny', 'Boczek', 308.0, 28.0, 9.8, 0, 1.0, 0.0, 0, 13.0, 2.0),
    ('Berlinki', 'Z Serem', 231.0, 19.0, 7.1, 0, 2.9, 1.1, 0, 12.0, 2.5),
    ('Podlaski', 'Pasztet drobiowy', 160.0, 12.0, 2.3, 0, 5.5, 0.5, 0, 7.5, 1.4),
    ('Unknown', 'Polędwiczki z kurczaka panierowane łagodna', 184.0, 7.9, 0.8, 0, 8.8, 0.5, 2.0, 19.0, 0),
    ('Animex Foods', 'Berlinki Kurczak', 181.0, 13.0, 3.9, 0, 1.1, 0.7, 0, 15.0, 2.4)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Meat' and p.is_deprecated is not true
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
