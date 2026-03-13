-- PIPELINE (Spices & Seasonings): scoring
-- Generated: 2026-03-13

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', 'NOT-APPLICABLE'),
    ('Donatello', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 'NOT-APPLICABLE'),
    ('Kamis', 'Przyprawa kuchni włoskiej', 'NOT-APPLICABLE'),
    ('Donatello', 'Antipasti nadziewane serkiem wiśniowe papryczki', 'NOT-APPLICABLE'),
    ('Kamis', 'Przyprawa do dań z ziemniaków', 'NOT-APPLICABLE'),
    ('Planteon', 'Pieprz ziołowy', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do kurczaka złocista skórka', 'NOT-APPLICABLE'),
    ('Kucharek', 'Przyprawa do mięs', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do mięs', 'NOT-APPLICABLE'),
    ('Promienie Słońca', 'Papryka słodka wędzona', 'NOT-APPLICABLE'),
    ('Perla', 'Pełna dobra papryczkę czerwone i pepperoni', 'NOT-APPLICABLE'),
    ('Kotanyi', 'Anyż cały', 'NOT-APPLICABLE'),
    ('Herbapol', 'Mięta', 'UNKNOWN'),
    ('Knorr', 'Przyprawa do mięs', 'E'),
    ('Kamis', 'Przyprawa do gyrosa', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do sałatek sosów i dipów', 'NOT-APPLICABLE'),
    ('Culineo', 'Cebulka zapiekana', 'E'),
    ('Sainsbury''s', 'Black Peppercorns', 'NOT-APPLICABLE'),
    ('Casa de mexico', 'Papryka zielona krojona', 'NOT-APPLICABLE'),
    ('Kamis', 'Curry', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do kurczaka', 'NOT-APPLICABLE'),
    ('Kamis', 'Seasoning for fish', 'NOT-APPLICABLE'),
    ('Kamis', 'Cynamon', 'NOT-APPLICABLE'),
    ('Prymat', 'Grill klasyczny', 'NOT-APPLICABLE'),
    ('Prymat', 'Kebab gyros', 'NOT-APPLICABLE'),
    ('Casa del sur', 'Pepperoni pepper imp', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa Kebab Gyros klasyczna', 'NOT-APPLICABLE'),
    ('Kamis', 'Przyprawa do spaghetti bolognese', 'NOT-APPLICABLE'),
    ('Planteon', 'Papryka ostra mielona 60 ASTA', 'NOT-APPLICABLE'),
    ('Prymat', 'Przyprawa do ryb', 'NOT-APPLICABLE'),
    ('Lewiatan', 'Chipsy paprykowe', 'NOT-APPLICABLE'),
    ('El Toro Rojo', 'Kapary w zalewie', 'UNKNOWN'),
    ('Lidl', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 'NOT-APPLICABLE'),
    ('Dr. Oetker', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 'NOT-APPLICABLE'),
    ('El Tequito', 'Jalapeños', 'NOT-APPLICABLE'),
    ('Lidl', 'Ground chili peppers in olive oil', 'NOT-APPLICABLE'),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'NOT-APPLICABLE'),
    ('Eridanous', 'Gyros', 'NOT-APPLICABLE'),
    ('Knorr', 'Czosnek', 'NOT-APPLICABLE'),
    ('Vilgain', 'Koření na pizzu', 'NOT-APPLICABLE'),
    ('All Seasons', 'Papryka konserwowa', 'NOT-APPLICABLE')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', '4'),
    ('Donatello', 'Antipasti - papryczki czereśniowe nadziewane serkiem', '3'),
    ('Prymat', 'Przyprawa do gulaszu i dań kuchni węgierskiej', '3'),
    ('Kamis', 'Przyprawa kuchni włoskiej', '3'),
    ('Donatello', 'Antipasti nadziewane serkiem wiśniowe papryczki', '3'),
    ('Kamis', 'Przyprawa do dań z ziemniaków', '3'),
    ('Planteon', 'Pieprz ziołowy', '1'),
    ('Prymat', 'Przyprawa do kurczaka złocista skórka', '3'),
    ('Kucharek', 'Przyprawa do mięs', '3'),
    ('Prymat', 'Przyprawa do mięs', '3'),
    ('Promienie Słońca', 'Papryka słodka wędzona', '1'),
    ('Perla', 'Pełna dobra papryczkę czerwone i pepperoni', '4'),
    ('Kotanyi', 'Anyż cały', '1'),
    ('Herbapol', 'Mięta', '4'),
    ('Knorr', 'Przyprawa do mięs', '4'),
    ('Kamis', 'Przyprawa do gyrosa', '3'),
    ('Prymat', 'Przyprawa do sałatek sosów i dipów', '4'),
    ('Culineo', 'Cebulka zapiekana', '3'),
    ('Sainsbury''s', 'Black Peppercorns', '4'),
    ('Casa de mexico', 'Papryka zielona krojona', '4'),
    ('Kamis', 'Curry', '3'),
    ('Prymat', 'Przyprawa do kurczaka', '3'),
    ('Kamis', 'Seasoning for fish', '3'),
    ('Kamis', 'Cynamon', '4'),
    ('Prymat', 'Grill klasyczny', '3'),
    ('Prymat', 'Kebab gyros', '3'),
    ('Casa del sur', 'Pepperoni pepper imp', '3'),
    ('Prymat', 'Przyprawa Kebab Gyros klasyczna', '3'),
    ('Kamis', 'Przyprawa do spaghetti bolognese', '3'),
    ('Planteon', 'Papryka ostra mielona 60 ASTA', '1'),
    ('Prymat', 'Przyprawa do ryb', '4'),
    ('Lewiatan', 'Chipsy paprykowe', '3'),
    ('El Toro Rojo', 'Kapary w zalewie', '3'),
    ('Lidl', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', '3'),
    ('Dr. Oetker', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', '4'),
    ('El Tequito', 'Jalapeños', '3'),
    ('Lidl', 'Ground chili peppers in olive oil', '3'),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', '4'),
    ('Eridanous', 'Gyros', '3'),
    ('Knorr', 'Czosnek', '4'),
    ('Vilgain', 'Koření na pizzu', '3'),
    ('All Seasons', 'Papryka konserwowa', '3')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Spices & Seasonings', 100, 'PL');
