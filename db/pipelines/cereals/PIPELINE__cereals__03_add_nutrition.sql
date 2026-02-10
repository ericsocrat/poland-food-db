-- PIPELINE (Cereals): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Cereals'
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
    ('Vitanella', 'Płatki Owsiane Górskie', 363.0, 5.7, 1.2, 0, 60.0, 1.8, 10.0, 13.0, 0.0),
    ('GO ACTIVE', 'GO ACTIVE  granola wysokobiałkowa', 454.0, 18.0, 3.9, 0, 37.0, 17.0, 12.0, 30.0, 0.2),
    ('Melvit', 'Płatki owsiane górskie', 374.0, 6.7, 1.3, 0, 61.0, 1.6, 9.0, 13.0, 0.0),
    ('Tymbark', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', 88.0, 0.5, 0.1, 0, 18.0, 12.0, 2.7, 1.4, 0.0),
    ('Mlyny Stoislaw', 'Płatki owsiane', 377.0, 7.4, 2.0, 0, 57.0, 1.3, 11.0, 15.0, 0.0),
    ('Kupiec', 'Ciasteczka zbożowe', 459.0, 18.5, 2.0, 0, 59.1, 14.0, 9.4, 9.3, 0.6),
    ('Melvit', 'Płatki owsiane Górskie XXL', 374.0, 6.7, 1.3, 0, 61.0, 1.6, 9.0, 13.0, 0.0),
    ('Cenos', 'Płatki owsiane błyskawiczne', 362.0, 6.0, 1.2, 0, 56.0, 2.5, 12.1, 15.0, 0.0),
    ('Vitanella', 'Miami Hopki', 356.0, 2.1, 0.7, 0, 73.7, 24.0, 7.3, 9.2, 0.4),
    ('Unknown', 'Choco kulki', 377.0, 4.5, 1.2, 0, 71.0, 25.0, 8.4, 9.0, 9.0),
    ('Nestlé', 'Cini Minis Scorțișoară', 410.0, 9.3, 1.1, 0, 72.6, 24.9, 6.5, 5.8, 0.9),
    ('Kupiec', 'Płatki owsiane błyskawiczne', 418.0, 7.6, 1.4, 0, 69.0, 1.3, 0, 14.0, 0),
    ('Unknown', 'Sante granola czekolada z truskawką', 452.0, 15.0, 2.8, 0, 67.0, 21.0, 6.7, 9.0, 0.6),  -- OFF has 28.0 sat_fat (decimal error); corrected to 2.8
    ('Vitanella', 'Crunchy Klasyczne', 444.0, 14.0, 2.9, 0, 67.0, 21.0, 6.4, 9.3, 0.3),
    ('Nestlé', 'Corn flakes', 382.0, 1.4, 0.5, 0, 82.9, 8.8, 4.2, 7.4, 1.3),
    ('Lidl', 'Crownfield Płatki owsiane górskie', 354.0, 6.3, 1.6, 0, 55.9, 1.2, 11.6, 12.5, 0),
    ('Lubella', 'Chocko Muszelki', 380.0, 3.7, 1.2, 0, 75.0, 25.0, 6.2, 8.5, 0.4),
    ('Nestlé', 'Nestle Chocapic', 389.0, 4.8, 1.3, 0, 73.6, 22.4, 7.7, 8.9, 0.2),
    ('GO ON', 'Protein granola', 416.0, 15.0, 3.0, 0, 44.0, 1.6, 18.0, 21.0, 0.0),
    ('Nestlé', 'Corn Flakes', 382.0, 1.4, 0.5, 0, 82.6, 8.8, 4.2, 7.4, 1.3),
    ('Nestlé', 'Nestle Corn Flakes', 382.0, 1.4, 0.5, 0, 82.9, 8.8, 4.2, 7.4, 1.3),
    ('sante', 'Sante gold granola', 469.0, 18.0, 2.7, 0, 61.0, 15.0, 6.3, 9.8, 0.4),
    ('Nestlé', 'Nestke Gold flakes', 400.0, 4.6, 1.0, 0, 80.3, 29.7, 0, 7.6, 1.3),
    ('Vitanella', 'Choki', 375.0, 3.1, 1.2, 0, 74.5, 25.2, 6.8, 8.9, 0.3),
    ('Nestlé', 'Fitness', 368.0, 1.5, 0.6, 0.0, 74.7, 8.3, 8.5, 9.8, 0.6),
    ('Lubella', 'Owsianka z bananami, kakao', 80.0, 1.9, 1.0, 0, 13.0, 7.4, 0, 2.0, 0.0),
    ('Nestlé', 'Cheerios Owsiany', 381.0, 6.3, 1.3, 0, 65.7, 9.0, 10.3, 10.4, 0.7),
    ('GO ON', 'granola brownie & cherry', 408.0, 13.0, 2.4, 0.0, 64.0, 2.1, 18.0, 21.0, 0.0),
    ('Vitanella', 'Vitanella owsianka mango-truskawka', 367.0, 7.7, 1.2, 0, 57.0, 20.8, 12.2, 11.3, 0.0),
    ('Lubella', 'choco piegotaki', 380.0, 2.2, 0.9, 0, 80.0, 27.0, 4.0, 8.0, 0.9),
    ('lubella', 'chrupersy', 382.0, 1.6, 0.8, 0, 84.0, 22.0, 0, 5.6, 0.8),
    ('One Day More', 'Porridge chocolate', 386.0, 8.6, 3.1, 0, 58.8, 12.6, 10.9, 12.5, 0.0),
    ('Nestlé', 'Lion caramel and chocolate', 402.0, 6.3, 1.1, 0, 74.2, 25.0, 6.6, 8.5, 0.5),
    ('Nestlé', 'Cheerios owsiany', 381.0, 6.6, 1.3, 0, 65.7, 9.0, 10.3, 10.4, 0.7),
    ('Nesquik', 'Nesquik Alphabet', 369.0, 2.1, 0.7, 0, 72.8, 14.9, 9.8, 9.7, 0.4),
    ('Vitanella', 'Orito kakaowe', 442.0, 17.5, 7.7, 0, 61.6, 26.5, 3.5, 7.7, 0.5),
    ('One day more', 'Porridge', 396.0, 8.7, 2.6, 0, 62.5, 9.6, 6.6, 12.8, 0.2),
    ('Nesquik', 'Nesquik Mix', 384.0, 4.1, 1.4, 0, 74.3, 22.0, 8.2, 8.4, 0.2),
    ('Vitanella', 'Corn Flakes', 386.0, 1.9, 0.6, 0, 82.5, 6.3, 2.3, 8.5, 1.6),
    ('Nestlé', 'Corn flakes choco', 393.0, 3.7, 1.0, 0, 81.7, 27.3, 0, 6.1, 1.3),
    ('Ba!', 'Ba granola czekoladowa', 416.0, 13.0, 3.2, 0, 63.0, 23.0, 5.8, 8.8, 0.3),
    ('Lidl', 'Płatki owsiane górskie', 359.0, 7.0, 0.9, 0, 54.1, 1.1, 11.8, 14.1, 0.0),
    ('Lidl', 'Owsianka Żurawina', 371.0, 5.6, 1.0, 0, 65.3, 18.8, 8.8, 10.5, 0.0),
    ('Crownfield', 'Płatki owsiane błyskawiczne', 372.0, 6.8, 1.2, 0, 59.6, 2.0, 0, 12.8, 0.0),
    ('Crownfield', 'Space Cookies', 375.0, 3.0, 1.2, 0, 75.0, 25.0, 7.5, 8.3, 0.5),
    ('Crownfield', 'Goldini', 409.0, 5.1, 0.9, 0, 81.2, 23.2, 2.3, 8.5, 1.3),
    ('Crownfield', 'Porridge', 389.0, 8.0, 1.0, 0, 64.0, 17.0, 8.4, 11.0, 0.5),
    ('Lidl', 'Owsiankaowoce i orzechy', 369.0, 8.2, 1.4, 0, 57.1, 12.3, 9.5, 11.9, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Cereals' and p.is_deprecated is not true
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
