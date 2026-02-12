-- PIPELINE (Breakfast & Grain-Based): scoring
-- Generated: 2026-02-09

-- 0. DEFAULT concern score for products without ingredient data
update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true
  and ingredient_concern_score is null;

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update products p set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      p.ingredient_concern_score
  )
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'C'),
    ('Biedronka', 'Vitanella Granola z czekoladą', 'D'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'D'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną', 'C'),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 'A'),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 'B'),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 'D'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami', 'C'),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 'C'),
    ('Łowicz', 'Dżem truskawkowy', 'D'),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń', 'C'),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', 'UNKNOWN'),
    ('Raspodia', 'Dżem wiśniowy', 'C'),
    ('Rapsodia', 'Dżem wiśniowy', 'C'),
    ('Rapsodia', 'Powidła węgierkowe', 'D'),
    ('Herbapol', 'Powidła wegierkowe', 'D'),
    ('Rapsodia', 'Dżem czarna porzeczka', 'UNKNOWN'),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', 'C'),
    ('Dawtona', 'Powidła śliwkowe', 'D'),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony', 'C'),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', 'A'),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie', 'B'),
    ('Go Active', 'Musli wyobiałkowe', 'C'),
    ('Vitanella', 'Musli 5 zbóż', 'A'),
    ('Go Bio', 'Musli z czekoladą i orzechami', 'C'),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', 'UNKNOWN'),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', 'D'),
    ('Kupiec', 'Coś na Ząb', 'A'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi', 'A'),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 'C'),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', 'A'),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', 'A'),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin', 'C'),
    ('OneDayMore', 'Musli z malinami i jeżynami', 'A'),
    ('Promienie Słońca', 'Promienie Słońca Słoneczna granola z orzechami i miodem', 'C'),
    ('Dawtona', 'Drugie śniadanie', 'A'),
    ('Pano', 'Pieczywo żytnie chrupkie', 'UNKNOWN'),
    ('Rapsodia', 'Dżem malinowy', 'UNKNOWN'),
    ('Herbapol', 'Dżem truskawkowy', 'C'),
    ('Łowicz', 'Łowicz - Dżem Wiśniowy', 'D'),
    ('Rapsodia', 'Dżem truskawkowy', 'UNKNOWN'),
    ('Łowicz', 'Dżem Malinowy', 'C'),
    ('Łowicz', 'Extra konfitura z wiśni', 'D'),
    ('Łowicz', 'Dżem 100% z owoców wiśnia', 'C'),
    ('Lidl', 'Dżem truskawkowy Rapsodia', 'UNKNOWN'),
    ('Łowicz', 'Konfitura z żółtych owoców', 'D'),
    ('Łowicz', 'Dżem brzoskwiniowy super gładki', 'C'),
    ('One day more', 'Muesli Protein', 'C'),
    ('Vitanella', 'Banana Chocolate musli', 'D'),
    ('Vitanella', 'Musli z owocami i orzechami', 'D'),
    ('Inna Bajka', 'Owsianka Mango i Jagody Goji', 'B'),
    ('Vitanella', 'Granola z czekoladą i orzechami', 'C'),
    ('Vitanella', 'Musli premium', 'D'),
    ('Bell''s', 'Owsianka owoce i orzechy', 'A'),
    ('Inna Bajka', 'Musli Marakuja i Pitaja', 'UNKNOWN'),
    ('Dobra Kaloria', 'Owsianka królewska z jabłkiem', 'UNKNOWN'),
    ('Vitanella', 'Muesli z owocami i siemieniem lnianym', 'C'),
    ('Rapsodia', 'Dżem wiśniowy o obniżonej zawartości cukru', 'C'),
    ('Rapsodia', 'Dżem brzoskwiniowy', 'UNKNOWN'),
    ('Łowicz', 'Dżem z agrestu i kiwi', 'UNKNOWN'),
    ('Mirella', 'Powidła śliwkowe', 'D'),
    ('Rolnik', 'Borówka cala', 'C'),
    ('Dawtona', 'Eperdzsem', 'C'),
    ('Sante', 'Granola chocolate / pieces of chocolate', 'D'),
    ('Biedronka', 'Granola', 'C'),
    ('Sante', 'Granola Nut / peanuts & peanut butter', 'D'),
    ('One Day More', 'Muesli chocolat', 'C'),
    ('One Day More', 'Muesli for focused ones', 'A'),
    ('Sante', 'sante fit granola strawberry and cherry', 'B'),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 'D'),
    ('Promienie słońca', 'Baton musli z owocami', 'B'),
    ('Nestlé', 'Musli tropical', 'C'),
    ('Nestlé', 'musli classic', 'C'),
    ('Promienie słońca', 'Baton musli z orzechami i miodem', 'B'),
    ('Purella', 'Purella Super Musli Proteinowe', 'C'),
    ('One Day More', 'Porridge Orange', 'A'),
    ('Bell''s', 'Crunchy', 'C'),
    ('OneDayMore', 'Musli Keto Choco', 'C'),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 'C'),
    ('Kupiec', 'Cosnazab', 'A'),
    ('Go On', 'Protein granola', 'A'),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców', 'E'),
    ('Vitanella', 'Owsianka ananas, kokos', 'D'),
    ('Kupiec', 'Cos na Zab', 'A'),
    ('Sante', 'Musli Lo z owocami', 'C'),
    ('Bell’s', 'Owsianka', 'A'),
    ('Go On', 'Protein Granola Go On', 'A'),
    ('Vivi', 'Musli owocowe: polskie owoce', 'C'),
    ('BakallanD', 'Granola klasyczna z kokosem', 'C'),
    ('One day more', 'Fruit Granola', 'A'),
    ('Bifood', 'Muesli crunchy', 'D'),
    ('Vitanella', 'Muesli z owocami i orzechami', 'UNKNOWN'),
    ('Vitanella', 'Granola z kakao i orzechami', 'A'),
    ('Purella Superfoods', 'purella superfoods granola', 'A'),
    ('One Day More', 'Granola with salty caramel and white chocolate', 'C'),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', 'A'),
    ('Lestello', 'Chickpea cakes', 'B'),
    ('Wasa', 'Wasa Pieczywo chrupkie z błonnikiem', 'A'),
    ('Chaber', 'Maca razowa', 'B'),
    ('Dr. Oetker', 'Protein Pancakes', 'UNKNOWN')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', '4'),
    ('Biedronka', 'Vitanella Granola z czekoladą', '4'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', '4'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną', '4'),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', '4'),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', '4'),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', '4'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami', '4'),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', '4'),
    ('Łowicz', 'Dżem truskawkowy', '4'),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń', '4'),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', '4'),
    ('Raspodia', 'Dżem wiśniowy', '4'),
    ('Rapsodia', 'Dżem wiśniowy', '4'),
    ('Rapsodia', 'Powidła węgierkowe', '4'),
    ('Herbapol', 'Powidła wegierkowe', '3'),
    ('Rapsodia', 'Dżem czarna porzeczka', '4'),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', '4'),
    ('Dawtona', 'Powidła śliwkowe', '4'),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony', '4'),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', '4'),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie', '1'),
    ('Go Active', 'Musli wyobiałkowe', '4'),
    ('Vitanella', 'Musli 5 zbóż', '1'),
    ('Go Bio', 'Musli z czekoladą i orzechami', '3'),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', '1'),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', '4'),
    ('Kupiec', 'Coś na Ząb', '4'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi', '3'),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', '3'),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', '4'),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', '1'),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin', '4'),
    ('OneDayMore', 'Musli z malinami i jeżynami', '3'),
    ('Promienie Słońca', 'Promienie Słońca Słoneczna granola z orzechami i miodem', '4'),
    ('Dawtona', 'Drugie śniadanie', '1'),
    ('Pano', 'Pieczywo żytnie chrupkie', '3'),
    ('Rapsodia', 'Dżem malinowy', '4'),
    ('Herbapol', 'Dżem truskawkowy', '4'),
    ('Łowicz', 'Łowicz - Dżem Wiśniowy', '4'),
    ('Rapsodia', 'Dżem truskawkowy', '4'),
    ('Łowicz', 'Dżem Malinowy', '4'),
    ('Łowicz', 'Extra konfitura z wiśni', '4'),
    ('Łowicz', 'Dżem 100% z owoców wiśnia', '4'),
    ('Lidl', 'Dżem truskawkowy Rapsodia', '4'),
    ('Łowicz', 'Konfitura z żółtych owoców', '4'),
    ('Łowicz', 'Dżem brzoskwiniowy super gładki', '4'),
    ('One day more', 'Muesli Protein', '3'),
    ('Vitanella', 'Banana Chocolate musli', '4'),
    ('Vitanella', 'Musli z owocami i orzechami', '4'),
    ('Inna Bajka', 'Owsianka Mango i Jagody Goji', '3'),
    ('Vitanella', 'Granola z czekoladą i orzechami', '4'),
    ('Vitanella', 'Musli premium', '3'),
    ('Bell''s', 'Owsianka owoce i orzechy', '1'),
    ('Inna Bajka', 'Musli Marakuja i Pitaja', '1'),
    ('Dobra Kaloria', 'Owsianka królewska z jabłkiem', '4'),
    ('Vitanella', 'Muesli z owocami i siemieniem lnianym', '3'),
    ('Rapsodia', 'Dżem wiśniowy o obniżonej zawartości cukru', '4'),
    ('Rapsodia', 'Dżem brzoskwiniowy', '4'),
    ('Łowicz', 'Dżem z agrestu i kiwi', '4'),
    ('Mirella', 'Powidła śliwkowe', '4'),
    ('Rolnik', 'Borówka cala', '4'),
    ('Dawtona', 'Eperdzsem', '4'),
    ('Sante', 'Granola chocolate / pieces of chocolate', '4'),
    ('Biedronka', 'Granola', '4'),
    ('Sante', 'Granola Nut / peanuts & peanut butter', '4'),
    ('One Day More', 'Muesli chocolat', '4'),
    ('One Day More', 'Muesli for focused ones', '4'),
    ('Sante', 'sante fit granola strawberry and cherry', '4'),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', '4'),
    ('Promienie słońca', 'Baton musli z owocami', '4'),
    ('Nestlé', 'Musli tropical', '4'),
    ('Nestlé', 'musli classic', '4'),
    ('Promienie słońca', 'Baton musli z orzechami i miodem', '4'),
    ('Purella', 'Purella Super Musli Proteinowe', '4'),
    ('One Day More', 'Porridge Orange', '4'),
    ('Bell''s', 'Crunchy', '4'),
    ('OneDayMore', 'Musli Keto Choco', '4'),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', '4'),
    ('Kupiec', 'Cosnazab', '4'),
    ('Go On', 'Protein granola', '4'),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców', '4'),
    ('Vitanella', 'Owsianka ananas, kokos', '3'),
    ('Kupiec', 'Cos na Zab', '4'),
    ('Sante', 'Musli Lo z owocami', '4'),
    ('Bell’s', 'Owsianka', '4'),
    ('Go On', 'Protein Granola Go On', '4'),
    ('Vivi', 'Musli owocowe: polskie owoce', '1'),
    ('BakallanD', 'Granola klasyczna z kokosem', '3'),
    ('One day more', 'Fruit Granola', '1'),
    ('Bifood', 'Muesli crunchy', '4'),
    ('Vitanella', 'Muesli z owocami i orzechami', '4'),
    ('Vitanella', 'Granola z kakao i orzechami', '4'),
    ('Purella Superfoods', 'purella superfoods granola', '4'),
    ('One Day More', 'Granola with salty caramel and white chocolate', '4'),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', '1'),
    ('Lestello', 'Chickpea cakes', '3'),
    ('Wasa', 'Wasa Pieczywo chrupkie z błonnikiem', '3'),
    ('Chaber', 'Maca razowa', '3'),
    ('Dr. Oetker', 'Protein Pancakes', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 4. Health-risk flags
update products p set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;
