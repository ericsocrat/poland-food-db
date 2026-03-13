-- PIPELINE (Alcohol): scoring
-- Generated: 2026-03-12

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'NOT-APPLICABLE'),
    ('Harnaś', 'Harnaś jasne pełne', 'NOT-APPLICABLE'),
    ('Van Pur S.A.', 'Łomża piwo jasne bezalkoholowe', 'NOT-APPLICABLE'),
    ('Karmi', 'Karmi o smaku żurawina', 'NOT-APPLICABLE'),
    ('Żywiec', 'Limonż 0%', 'NOT-APPLICABLE'),
    ('Lomża', 'Łomża jasne', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Kozel cerny', 'NOT-APPLICABLE'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'NOT-APPLICABLE'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'NOT-APPLICABLE'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'NOT-APPLICABLE'),
    ('Książęce', 'Książęce czerwony lager', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Premium', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Lech free', 'NOT-APPLICABLE'),
    ('Zatecky', 'Zatecky 0%', 'NOT-APPLICABLE'),
    ('Łomża', 'Radler 0,0%', 'NOT-APPLICABLE'),
    ('Łomża', 'Bière sans alcool', 'NOT-APPLICABLE'),
    ('Warka', 'Piwo Warka Radler', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Free Lime Mint', 'NOT-APPLICABLE'),
    ('Carlsberg', 'Pilsner 0.0%', 'NOT-APPLICABLE'),
    ('Amber', 'Amber IPA zero', 'NOT-APPLICABLE'),
    ('Unknown', 'Lech Free Citrus Sour', 'NOT-APPLICABLE'),
    ('Shroom', 'Shroom power', 'NOT-APPLICABLE'),
    ('Heineken', 'Heineken Beer', 'NOT-APPLICABLE'),
    ('Choya', 'Silver', 'NOT-APPLICABLE'),
    ('Ikea', 'Glühwein', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0 White alcoholfree', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0. Red', 'NOT-APPLICABLE'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'NOT-APPLICABLE'),
    ('Carlo Rossi', 'Vin carlo rossi', 'NOT-APPLICABLE'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 'NOT-APPLICABLE')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', '4'),
    ('Harnaś', 'Harnaś jasne pełne', '3'),
    ('Van Pur S.A.', 'Łomża piwo jasne bezalkoholowe', '4'),
    ('Karmi', 'Karmi o smaku żurawina', '4'),
    ('Żywiec', 'Limonż 0%', '4'),
    ('Lomża', 'Łomża jasne', '4'),
    ('Kompania Piwowarska', 'Kozel cerny', '3'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', '4'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', '4'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', '3'),
    ('Książęce', 'Książęce czerwony lager', '4'),
    ('Lech', 'Lech Premium', '3'),
    ('Kompania Piwowarska', 'Lech free', '4'),
    ('Zatecky', 'Zatecky 0%', '4'),
    ('Łomża', 'Radler 0,0%', '4'),
    ('Łomża', 'Bière sans alcool', '4'),
    ('Warka', 'Piwo Warka Radler', '4'),
    ('Lech', 'Lech Free Lime Mint', '4'),
    ('Carlsberg', 'Pilsner 0.0%', '4'),
    ('Amber', 'Amber IPA zero', '4'),
    ('Unknown', 'Lech Free Citrus Sour', '3'),
    ('Shroom', 'Shroom power', '4'),
    ('Heineken', 'Heineken Beer', '3'),
    ('Choya', 'Silver', '3'),
    ('Ikea', 'Glühwein', '4'),
    ('Just 0.', 'Just 0 White alcoholfree', '4'),
    ('Just 0.', 'Just 0. Red', '3'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', '3'),
    ('Carlo Rossi', 'Vin carlo rossi', '4'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Alcohol', 100, 'PL');
