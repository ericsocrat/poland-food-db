-- PIPELINE (Breakfast & Grain-Based): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
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
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 364.0, 7.3, 4.1, 0, 60.2, 10.3, 9.9, 9.4, 0.1),
    ('Biedronka', 'Vitanella Granola z czekoladą', 468.0, 18.4, 5.5, 0, 63.6, 23.2, 5.6, 9.2, 0.3),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 457.0, 17.7, 4.4, 0, 59.6, 21.1, 9.4, 10.0, 0.4),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 437.0, 14.0, 3.4, 0, 64.2, 23.1, 9.0, 9.0, 0.4),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 369.0, 6.1, 1.0, 0, 61.8, 13.1, 11.0, 11.2, 0.6),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 337.0, 4.0, 1.5, 0, 61.7, 17.8, 9.5, 8.7, 0.1),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 434.0, 12.0, 4.6, 0, 68.0, 21.0, 4.9, 11.0, 0.2),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 371.0, 6.3, 3.2, 0, 64.7, 18.7, 9.1, 9.4, 0.6),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 445.0, 21.0, 6.2, 0, 41.0, 5.7, 10.0, 18.0, 0.1),
    ('Łowicz', 'Dżem truskawkowy', 142.0, 0.5, 0.1, 0, 35.0, 35.0, 0, 0.5, 0.0),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń.', 148.0, 0.5, 0.1, 0, 34.0, 31.0, 0, 0.8, 0.1),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', 141.0, 0.5, 0, 0, 33.0, 30.0, 0, 0.5, 0.0),
    ('Raspodia', 'Dżem wiśniowy', 149.0, 0.5, 0.1, 0, 34.0, 32.0, 0, 0.8, 0.0),
    ('Rapsodia', 'Dżem wiśniowy', 150.0, 0.5, 0.1, 0, 33.0, 31.0, 0, 0.9, 0.1),
    ('Rapsodia', 'Powidła węgierkowe', 214.0, 0.2, 0.1, 0, 50.0, 46.0, 0, 1.1, 0.0),
    ('Herbapol', 'Powidła wegierkowe', 207.0, 0.0, 0.0, 0, 48.0, 46.0, 0, 1.1, 0.0),
    ('Rapsodia', 'Dżem czarna porzeczka', 138.0, 0.5, 0.1, 0, 27.0, 25.0, 0.0, 1.3, 0),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', 142.0, 0.0, 0.0, 0, 35.0, 35.0, 0.9, 0.0, 0.0),
    ('Dawtona', 'Powidła śliwkowe', 227.0, 0.6, 0.0, 0, 54.0, 54.0, 2.7, 1.4, 0.0),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony.', 141.0, 0.5, 0.1, 0, 34.0, 34.0, 0, 0.5, 0.0),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', 367.0, 5.3, 0.9, 0, 62.0, 18.0, 9.1, 13.0, 0.2),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie.', 355.0, 5.4, 1.5, 0, 71.2, 5.0, 8.2, 7.5, 1.0),
    ('Go Active', 'Musli wyobiałkowe', 446.0, 18.0, 7.1, 0, 37.0, 8.7, 7.9, 30.0, 0.0),
    ('Vitanella', 'Musli 5 zbóż', 350.0, 3.8, 0.7, 0, 62.1, 17.0, 11.3, 11.1, 0.1),
    ('Go Bio', 'Musli z czekoladą i orzechami', 409.0, 13.5, 3.0, 0, 56.1, 17.3, 9.9, 10.7, 0.1),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', 357.0, 10.4, 1.3, 0, 50.5, 17.7, 0, 10.6, 0),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', 466.0, 20.0, 8.0, 0, 58.0, 14.6, 8.0, 8.8, 0.3),
    ('Kupiec', 'Coś na Ząb', 148.8, 2.2, 0.4, 0, 24.8, 6.2, 3.0, 5.6, 0.2),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 387.0, 11.2, 1.7, 0, 52.7, 8.3, 10.4, 13.7, 0.1),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 400.0, 8.7, 3.1, 0, 65.2, 10.4, 5.8, 11.7, 0.2),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', 365.0, 5.4, 1.0, 0, 63.0, 19.0, 9.4, 11.0, 0.2),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', 374.0, 8.8, 1.1, 0, 57.3, 15.8, 9.5, 11.6, 0.0),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin.', 378.0, 7.0, 2.1, 0, 61.7, 19.3, 8.3, 12.9, 0.1),
    ('OneDayMore', 'Musli z malinami i jeżynami', 350.0, 2.2, 0.4, 0, 68.0, 8.4, 10.7, 9.1, 0.0),
    ('Promienie Słońca', 'Promienie Słońca Słoneczna granola z orzechami i miodem', 478.0, 20.0, 1.6, 0, 63.0, 18.0, 6.2, 8.5, 0.1),
    ('Dawtona', 'Drugie śniadanie', 47.0, 0.0, 0.0, 0, 10.0, 9.0, 2.4, 0.6, 0.1),
    ('Pano', 'Pieczywo żytnie chrupkie', 361.0, 0.7, 0, 0, 75.0, 0, 0, 8.3, 0),
    ('Rapsodia', 'Dżem malinowy', 139.0, 0.5, 0, 0, 33.0, 0, 0, 0.5, 0),
    ('Herbapol', 'Dżem truskawkowy', 152.0, 0.5, 0.1, 0, 36.0, 35.0, 0, 0.5, 0.1),
    ('Łowicz', 'Łowicz - Dżem Wiśniowy', 144.0, 0.5, 0.1, 0, 35.0, 35.0, 0, 0.5, 0.0),
    ('Rapsodia', 'Dżem truskawkowy', 140.0, 0.1, 0.0, 0, 33.0, 32.0, 0, 0.6, 0),
    ('Łowicz', 'Dżem Malinowy', 139.0, 0.5, 0.1, 0, 33.0, 33.0, 0, 0.5, 0.0),
    ('Łowicz', 'Extra konfitura z wiśni', 165.0, 0.5, 0.1, 0, 40.0, 40.0, 0, 0.5, 0.0),
    ('Łowicz', 'Dżem 100% z owoców wiśnia', 145.0, 0.5, 0.1, 0, 34.0, 34.0, 0, 0.8, 0.0),
    ('Lidl', 'Dżem truskawkowy Rapsodia', 144.0, 0.0, 0, 0, 35.0, 34.0, 0, 0.0, 0),
    ('Łowicz', 'Konfitura z żółtych owoców', 166.0, 0.5, 0.1, 0, 40.0, 40.0, 0, 0.5, 0.0),
    ('Łowicz', 'Dżem brzoskwiniowy super gładki', 155.0, 0.5, 0.1, 0, 36.0, 36.0, 0, 1.3, 0.0),
    ('One day more', 'Muesli Protein', 410.0, 13.9, 2.1, 0, 42.9, 13.2, 7.7, 24.2, 0.4),
    ('Vitanella', 'Banana Chocolate musli', 430.0, 13.0, 4.0, 0, 67.0, 25.0, 7.0, 7.8, 0.2),
    ('Vitanella', 'Musli z owocami i orzechami', 398.0, 12.6, 6.1, 0, 59.4, 24.7, 7.7, 8.0, 0.1),
    ('Inna Bajka', 'Owsianka Mango i Jagody Goji', 369.0, 6.6, 1.0, 0, 72.0, 20.0, 8.0, 9.4, 0.2),
    ('Vitanella', 'Granola z czekoladą i orzechami', 473.0, 19.8, 3.0, 0, 62.3, 23.6, 5.6, 8.6, 0.2),
    ('Vitanella', 'Musli premium', 398.0, 12.6, 6.1, 0, 59.4, 24.7, 7.7, 8.0, 0.0),
    ('Bell''s', 'Owsianka owoce i orzechy', 371.0, 8.3, 1.4, 0, 58.0, 15.7, 9.5, 11.3, 0.0),
    ('Inna Bajka', 'Musli Marakuja i Pitaja', 475.0, 14.9, 5.7, 0, 66.6, 7.2, 10.3, 13.4, 0),
    ('Dobra Kaloria', 'Owsianka królewska z jabłkiem', 364.0, 6.7, 1.4, 0, 59.0, 5.8, 11.0, 12.0, 0),
    ('Vitanella', 'Muesli z owocami i siemieniem lnianym', 370.0, 8.7, 2.6, 0, 59.0, 24.7, 9.6, 9.0, 0.0),
    ('Rapsodia', 'Dżem wiśniowy o obniżonej zawartości cukru', 146.0, 0.5, 0.1, 0, 34.0, 34.0, 0, 0.5, 0.1),
    ('Rapsodia', 'Dżem brzoskwiniowy', 146.0, 0.1, 0.1, 0, 35.0, 35.0, 0, 0.6, 0),
    ('Łowicz', 'Dżem z agrestu i kiwi', 143.0, 0.5, 0.1, 0, 35.0, 35.0, 5.0, 0.5, 0),
    ('Mirella', 'Powidła śliwkowe', 228.0, 0.5, 0.0, 0, 54.0, 43.0, 0, 1.0, 0.0),
    ('Rolnik', 'Borówka cala', 120.0, 0.0, 0, 0, 29.0, 24.0, 0, 0.0, 0.0),
    ('Dawtona', 'Eperdzsem', 138.0, 0.0, 0.0, 0, 34.0, 34.0, 0.8, 0.0, 0.0),
    ('Sante', 'Granola chocolate / pieces of chocolate', 456.0, 16.0, 3.3, 0, 66.0, 22.0, 6.7, 8.6, 0.6),
    ('Biedronka', 'Granola', 478.0, 21.1, 2.5, 0, 58.7, 14.3, 6.7, 9.9, 0.5),
    ('Sante', 'Granola Nut / peanuts & peanut butter', 458.0, 17.0, 2.3, 0, 61.0, 18.0, 6.5, 12.0, 0.6),
    ('One Day More', 'Muesli chocolat', 397.0, 8.3, 3.2, 0, 64.0, 11.3, 7.3, 12.3, 0.2),
    ('One Day More', 'Muesli for focused ones', 424.0, 17.1, 2.8, 0, 47.8, 10.9, 9.4, 14.9, 0.0),
    ('Sante', 'sante fit granola strawberry and cherry', 412.0, 12.0, 1.7, 0, 77.0, 8.7, 13.0, 8.8, 0.6),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 423.0, 15.0, 6.4, 0, 67.0, 26.0, 6.6, 7.7, 0.3),
    ('Promienie słońca', 'Baton musli z owocami', 434.0, 16.0, 1.7, 0, 60.0, 16.0, 8.8, 8.1, 0.0),
    ('Nestlé', 'Musli tropical', 379.0, 7.0, 3.4, 0, 64.9, 19.6, 9.1, 9.5, 0.5),
    ('Nestlé', 'musli classic', 378.0, 6.7, 0.9, 0, 62.2, 14.9, 10.5, 11.9, 0.6),
    ('Promienie słońca', 'Baton musli z orzechami i miodem', 450.0, 19.0, 2.0, 0, 57.0, 14.0, 8.2, 8.7, 0.0),
    ('Purella', 'Purella Super Musli Proteinowe', 414.0, 16.0, 3.7, 0, 37.0, 17.0, 11.0, 25.0, 0.3),
    ('One Day More', 'Porridge Orange', 368.0, 7.2, 2.4, 0, 56.2, 7.2, 13.6, 12.5, 0.0),
    ('Bell''s', 'Crunchy', 437.0, 14.0, 3.4, 0, 64.2, 23.1, 9.0, 9.0, 0.4),
    ('OneDayMore', 'Musli Keto Choco', 598.0, 48.5, 6.8, 0, 11.0, 5.6, 10.1, 25.5, 0.1),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 387.0, 8.4, 2.9, 0, 61.4, 11.2, 9.6, 0.0, 0.0),
    ('Kupiec', 'Cosnazab', 370.0, 5.2, 0.9, 0, 64.0, 21.0, 7.8, 13.0, 0.0),
    ('Go on', 'Protein granola', 391.0, 12.0, 1.6, 0, 42.0, 2.7, 21.0, 21.0, 0.4),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców.', 431.0, 14.4, 7.6, 0, 64.5, 31.8, 7.0, 7.4, 0.5),
    ('Vitanella', 'Owsianka ananas, kokos', 415.0, 16.0, 8.8, 0, 51.2, 16.6, 11.7, 10.8, 0.0),
    ('Kupiec', 'Cos na Zab', 371.0, 5.7, 1.0, 0, 63.0, 17.0, 6.3, 13.0, 0.2),
    ('Sante', 'Musli Lo z owocami', 347.0, 4.2, 0.8, 0, 62.0, 21.0, 12.0, 8.6, 0.2),
    ('Bell’s', 'Owsianka', 377.0, 6.5, 1.9, 0, 62.3, 18.9, 8.3, 13.7, 0.1),
    ('Go On', 'Protein Granola Go On', 416.0, 15.0, 2.9, 0, 44.0, 1.6, 18.0, 21.0, 0.4),
    ('Vivi', 'Musli owocowe: polskie owoce', 332.0, 2.7, 0.7, 0, 75.3, 6.3, 8.2, 5.6, 1.2),
    ('BakallanD', 'Granola klasyczna z kokosem', 421.0, 16.0, 6.7, 0, 56.0, 17.0, 8.4, 8.9, 0.1),
    ('One day more', 'Fruit Granola', 395.0, 8.4, 1.3, 0, 62.9, 15.4, 10.3, 11.3, 0.1),
    ('Bifood', 'Muesli crunchy', 429.0, 14.0, 5.6, 0, 63.0, 23.0, 4.9, 10.0, 0.0),
    ('Vitanella', 'Muesli z owocami i orzechami', 398.0, 12.6, 6.1, 0, 59.4, 24.7, 7.7, 8.0, 0),
    ('Vitanella', 'Granola z kakao i orzechami', 430.0, 10.1, 2.2, 0, 43.3, 5.9, 20.7, 10.9, 0.4),
    ('Purella Superfoods', 'purella superfoods granola', 425.0, 16.0, 2.5, 0, 44.0, 2.9, 8.1, 22.0, 0.0),
    ('One Day More', 'Granola with salty caramel and white chocolate', 396.0, 8.5, 2.4, 0, 65.1, 14.6, 9.4, 9.5, 0.8),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', 344.0, 1.5, 0.3, 0, 65.0, 2.0, 17.0, 9.0, 0.9),
    ('Lestello', 'Chickpea cakes', 380.0, 3.2, 0.6, 0, 73.0, 1.9, 6.0, 12.0, 0.9),
    ('Wasa', 'Wasa Pieczywo chrupkie z błonnikiem', 333.0, 5.0, 1.0, 0, 46.0, 2.0, 26.0, 13.0, 1.1),
    ('Chaber', 'Maca razowa', 3690.1, 1.4, 0.1, 0, 7.8, 0.5, 3.8, 9.4, 0.5),
    ('Dr. Oetker', 'Protein Pancakes', 231.0, 8.1, 1.8, 0, 27.0, 2.7, 0, 12.0, 0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Breakfast & Grain-Based' and p.is_deprecated is not true
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
