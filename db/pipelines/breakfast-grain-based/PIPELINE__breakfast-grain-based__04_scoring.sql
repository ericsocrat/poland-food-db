-- PIPELINE (Breakfast & Grain-Based): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 2),
    ('Biedronka', 'Vitanella Granola z czekoladą', 2),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 3),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 3),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 1),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 1),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 2),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 2),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 0),
    ('Łowicz', 'Dżem truskawkowy', 3),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń.', 1),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', 2),
    ('Raspodia', 'Dżem wiśniowy', 1),
    ('Rapsodia', 'Dżem wiśniowy', 1),
    ('Rapsodia', 'Powidła węgierkowe', 0),
    ('Herbapol', 'Powidła wegierkowe', 0),
    ('Rapsodia', 'Dżem czarna porzeczka', 1),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', 4),
    ('Dawtona', 'Powidła śliwkowe', 0),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony.', 5),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', 0),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie.', 0),
    ('Go Active', 'Musli wyobiałkowe', 1),
    ('Vitanella', 'Musli 5 zbóż', 0),
    ('Go Bio', 'Musli z czekoladą i orzechami', 0),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', 0),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', 2),
    ('Kupiec', 'Coś na Ząb', 0),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 0),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 0),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', 0),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', 0),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin.', 1),
    ('OneDayMore', 'Musli z malinami i jeżynami', 0),
    ('Promienie Słońca', 'Promienie Słońca Słoneczna granola z orzechami i miodem', 0),
    ('Dawtona', 'Drugie śniadanie', 0),
    ('Pano', 'Pieczywo żytnie chrupkie', 0),
    ('Rapsodia', 'Dżem malinowy', 0),
    ('Herbapol', 'Dżem truskawkowy', 2),
    ('Łowicz', 'Łowicz - Dżem Wiśniowy', 3),
    ('Rapsodia', 'Dżem truskawkowy', 5),
    ('Łowicz', 'Dżem Malinowy', 3),
    ('Łowicz', 'Extra konfitura z wiśni', 4),
    ('Łowicz', 'Dżem 100% z owoców wiśnia', 1),
    ('Lidl', 'Dżem truskawkowy Rapsodia', 0),
    ('Łowicz', 'Konfitura z żółtych owoców', 4),
    ('Łowicz', 'Dżem brzoskwiniowy super gładki', 1),
    ('One day more', 'Muesli Protein', 0),
    ('Vitanella', 'Banana Chocolate musli', 0),
    ('Vitanella', 'Musli z owocami i orzechami', 1),
    ('Inna Bajka', 'Owsianka Mango i Jagody Goji', 0),
    ('Vitanella', 'Granola z czekoladą i orzechami', 0),
    ('Vitanella', 'Musli premium', 1),
    ('Bell''s', 'Owsianka owoce i orzechy', 0),
    ('Inna Bajka', 'Musli Marakuja i Pitaja', 0),
    ('Dobra Kaloria', 'Owsianka królewska z jabłkiem', 0),
    ('Vitanella', 'Muesli z owocami i siemieniem lnianym', 1),
    ('Rapsodia', 'Dżem wiśniowy o obniżonej zawartości cukru', 0),
    ('Rapsodia', 'Dżem brzoskwiniowy', 0),
    ('Łowicz', 'Dżem z agrestu i kiwi', 0),
    ('Mirella', 'Powidła śliwkowe', 0),
    ('Rolnik', 'Borówka cala', 0),
    ('Dawtona', 'Eperdzsem', 2),
    ('Sante', 'Granola chocolate / pieces of chocolate', 2),
    ('Biedronka', 'Granola', 2),
    ('Sante', 'Granola Nut / peanuts & peanut butter', 2),
    ('One Day More', 'Muesli chocolat', 1),
    ('One Day More', 'Muesli for focused ones', 1),
    ('Sante', 'sante fit granola strawberry and cherry', 1),
    ('Santé', 'Sante Crunchy Crispy Muesli Banana With Chocolate 350G', 1),
    ('Promienie słońca', 'Baton musli z owocami', 0),
    ('Nestlé', 'Musli tropical', 3),
    ('Nestlé', 'musli classic', 0),
    ('Promienie słońca', 'Baton musli z orzechami i miodem', 0),
    ('Purella', 'Purella Super Musli Proteinowe', 2),
    ('One Day More', 'Porridge Orange', 2),
    ('Bell''s', 'Crunchy', 0),
    ('OneDayMore', 'Musli Keto Choco', 2),
    ('ONE DAY MORE', 'Meusli Fruits et Chocolat Blanc', 0),
    ('Kupiec', 'Cosnazab', 0),
    ('Go on', 'Protein granola', 4),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców.', 3),
    ('Vitanella', 'Owsianka ananas, kokos', 0),
    ('Kupiec', 'Cos na Zab', 0),
    ('Sante', 'Musli Lo z owocami', 0),
    ('Bell’s', 'Owsianka', 1),
    ('Go On', 'Protein Granola Go On', 4),
    ('Vivi', 'Musli owocowe: polskie owoce', 0),
    ('BakallanD', 'Granola klasyczna z kokosem', 0),
    ('One day more', 'Fruit Granola', 0),
    ('Bifood', 'Muesli crunchy', 0),
    ('Vitanella', 'Muesli z owocami i orzechami', 2),
    ('Vitanella', 'Granola z kakao i orzechami', 1),
    ('Purella Superfoods', 'purella superfoods granola', 2),
    ('One Day More', 'Granola with salty caramel and white chocolate', 1),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', 0),
    ('Lestello', 'Chickpea cakes', 0),
    ('Wasa', 'Wasa Pieczywo chrupkie z błonnikiem', 0),
    ('Chaber', 'Maca razowa', 0),
    ('Dr. Oetker', 'Protein Pancakes', 0)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'C'),
    ('Biedronka', 'Vitanella Granola z czekoladą', 'D'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'D'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', 'C'),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', 'A'),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', 'B'),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', 'D'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 'C'),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', 'C'),
    ('Łowicz', 'Dżem truskawkowy', 'D'),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń.', 'C'),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', 'UNKNOWN'),
    ('Raspodia', 'Dżem wiśniowy', 'C'),
    ('Rapsodia', 'Dżem wiśniowy', 'C'),
    ('Rapsodia', 'Powidła węgierkowe', 'D'),
    ('Herbapol', 'Powidła wegierkowe', 'D'),
    ('Rapsodia', 'Dżem czarna porzeczka', 'UNKNOWN'),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', 'C'),
    ('Dawtona', 'Powidła śliwkowe', 'D'),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony.', 'C'),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', 'A'),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie.', 'B'),
    ('Go Active', 'Musli wyobiałkowe', 'C'),
    ('Vitanella', 'Musli 5 zbóż', 'A'),
    ('Go Bio', 'Musli z czekoladą i orzechami', 'C'),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', 'UNKNOWN'),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', 'D'),
    ('Kupiec', 'Coś na Ząb', 'A'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 'A'),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', 'C'),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', 'A'),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', 'A'),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin.', 'C'),
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
    ('Go on', 'Protein granola', 'A'),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców.', 'E'),
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA + processing risk
update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Unknown'
  end
from (
  values
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', '4'),
    ('Biedronka', 'Vitanella Granola z czekoladą', '4'),
    ('vitanella', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', '4'),
    ('Vitanella', 'Musli prażone z suszoną, słodzoną żurawiną.', '4'),
    ('Biedronka', 'Mieszanka płatków zbożowych z rodzynkami i orzechami laskowymi', '4'),
    ('Vitanella', 'Mieszanka płatków zbożowych z suszonymi owocami oraz kawałkami prażonych orzeszków laskowych', '4'),
    ('Bakalland', 'Musli chrupkie klasyczne z dodatkiem wiórków kokosowych', '4'),
    ('Vitanella', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', '4'),
    ('Melvit', 'CRISPY PIECZYWO CHRUPKIE z serem i cebulką', '4'),
    ('Łowicz', 'Dżem truskawkowy', '4'),
    ('Rapsodia', 'Produkt owocowy z brzoskwiń.', '4'),
    ('Herbapol', 'Dżem z Czarnych Porzeczek', '4'),
    ('Raspodia', 'Dżem wiśniowy', '4'),
    ('Rapsodia', 'Dżem wiśniowy', '4'),
    ('Rapsodia', 'Powidła węgierkowe', '4'),
    ('Herbapol', 'Powidła wegierkowe', '3'),
    ('Rapsodia', 'Dżem czarna porzeczka', '4'),
    ('Dawtona', 'Dżem Brzoskwiniowy niskosłodzony', '4'),
    ('Dawtona', 'Powidła śliwkowe', '4'),
    ('Łowicz', 'Dżem z truskawek i limonki niskosłodzony.', '4'),
    ('Kupiec', 'Coś na ząb owsianka z jabłkiem i bananem', '4'),
    ('Vivi Polska', 'Musli owocowe pożywne śniadanie.', '1'),
    ('Go Active', 'Musli wyobiałkowe', '4'),
    ('Vitanella', 'Musli 5 zbóż', '1'),
    ('Go Bio', 'Musli z czekoladą i orzechami', '3'),
    ('Biedronka', 'Vitanella Owsianka - śliwka, migdał, żurawina', '1'),
    ('Fitella', 'Musli chrupkie bananowe z kawałkami czekolady', '4'),
    ('Kupiec', 'Coś na Ząb', '4'),
    ('One Day More', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', '3'),
    ('OneDayMore', 'Musli z truskawkami, czerwonymi porzeczkami i czekoladą mleczna', '3'),
    ('Kupiec', 'Owsianka z jabłkiem i cynamonem', '4'),
    ('Brüggen', 'Płatki owsiane z suszonymi owocami i orzechami', '1'),
    ('Brüggen', 'Płatki owsiane z mlekiem w proszku odtłuszczonym, kawałkami białej czekolady i liofilizowanych malin.', '4'),
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
    ('Go on', 'Protein granola', '4'),
    ('Tesco', 'Musli prażone z kawałkami suszonych i kandyzowanych owoców.', '4'),
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
  and p.is_deprecated is not true;
