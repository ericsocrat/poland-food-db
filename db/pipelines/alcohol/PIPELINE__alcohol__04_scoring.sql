-- PIPELINE (Alcohol): scoring
-- Generated: 2026-02-09

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'NOT-APPLICABLE'),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'UNKNOWN'),
    ('Diamant', 'Cukier Biały', 'E'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'A'),
    ('Harnaś', 'Harnaś jasne pełne', 'NOT-APPLICABLE'),
    ('VAN PUR S.A', 'Łomża piwo jasne bezalkoholowe', 'NOT-APPLICABLE'),
    ('Karmi', 'Karmi o smaku żurawina', 'NOT-APPLICABLE'),
    ('Żywiec', 'Limonż 0%', 'NOT-APPLICABLE'),
    ('Polski Cukier', 'Cukier biały', 'E'),
    ('Łomża', 'Łomża jasne', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Kozel cerny', 'NOT-APPLICABLE'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'NOT-APPLICABLE'),
    ('Tyskie', 'Bier "Tyskie Gronie"', 'NOT-APPLICABLE'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'NOT-APPLICABLE'),
    ('Książęce', 'Książęce czerwony lager', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Premium', 'NOT-APPLICABLE'),
    ('Zatecky', 'Zatecky 0%', 'NOT-APPLICABLE'),
    ('Kompania Piwowarska', 'Lech free', 'NOT-APPLICABLE'),
    ('Łomża', 'Radler 0,0%', 'NOT-APPLICABLE'),
    ('Łomża', 'Bière sans alcool', 'NOT-APPLICABLE'),
    ('Warka', 'Piwo Warka Radler', 'NOT-APPLICABLE'),
    ('Nestlé', 'Przyprawa Maggi', 'E'),
    ('Gryzzale', 'polutry kabanos sausages', 'UNKNOWN'),
    ('Carlsberg', 'Pilsner 0.0%', 'NOT-APPLICABLE'),
    ('Lech', 'Lech Free Lime Mint', 'NOT-APPLICABLE'),
    ('Amber', 'Amber IPA zero', 'NOT-APPLICABLE'),
    ('Unknown', 'LECH FREE CITRUS SOUR', 'NOT-APPLICABLE'),
    ('Shroom', 'Shroom power', 'NOT-APPLICABLE'),
    ('Christkindl', 'Christkindl Glühwein', 'NOT-APPLICABLE'),
    ('Go Active', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'A'),
    ('Heineken', 'Heineken Beer', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0 White alcoholfree', 'NOT-APPLICABLE'),
    ('Just 0.', 'Just 0. Red', 'NOT-APPLICABLE'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'NOT-APPLICABLE'),
    ('Ikea', 'Glühwein', 'NOT-APPLICABLE'),
    ('Choya', 'Silver', 'NOT-APPLICABLE'),
    ('Carlo Rossi', 'Vin carlo rossi', 'NOT-APPLICABLE'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 'NOT-APPLICABLE'),
    -- batch 2 (non-alcoholic)
    ('Just 0',                         'Just 0. Red',                                      'B'),
    ('Just 0',                         'Just 0 White alcoholfree',                          'B'),
    ('Seth & Riley''S Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'C'),  -- est. sugars
    ('Van Pur S.A',                    'Łomża piwo jasne bezalkoholowe',                     'B'),
    ('Owolovo',                        'Truskawkowo Mus jabłkowo-truskawkowy',               'A')   -- baby mousse
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', '4'),
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', '1'),
    ('Diamant', 'Cukier Biały', '2'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', '1'),
    ('Harnaś', 'Harnaś jasne pełne', '3'),
    ('VAN PUR S.A', 'Łomża piwo jasne bezalkoholowe', '4'),
    ('Karmi', 'Karmi o smaku żurawina', '4'),
    ('Żywiec', 'Limonż 0%', '4'),
    ('Polski Cukier', 'Cukier biały', '2'),
    ('Łomża', 'Łomża jasne', '4'),
    ('Kompania Piwowarska', 'Kozel cerny', '3'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', '4'),
    ('Tyskie', 'Bier "Tyskie Gronie"', '3'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', '4'),
    ('Książęce', 'Książęce czerwony lager', '4'),
    ('Lech', 'Lech Premium', '3'),
    ('Zatecky', 'Zatecky 0%', '4'),
    ('Kompania Piwowarska', 'Lech free', '4'),
    ('Łomża', 'Radler 0,0%', '4'),
    ('Łomża', 'Bière sans alcool', '4'),
    ('Warka', 'Piwo Warka Radler', '4'),
    ('Nestlé', 'Przyprawa Maggi', '4'),
    ('Gryzzale', 'polutry kabanos sausages', '4'),
    ('Carlsberg', 'Pilsner 0.0%', '4'),
    ('Lech', 'Lech Free Lime Mint', '4'),
    ('Amber', 'Amber IPA zero', '4'),
    ('Unknown', 'LECH FREE CITRUS SOUR', '3'),
    ('Shroom', 'Shroom power', '4'),
    ('Christkindl', 'Christkindl Glühwein', '4'),
    ('Go Active', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', '4'),
    ('Heineken', 'Heineken Beer', '3'),
    ('Just 0.', 'Just 0 White alcoholfree', '4'),
    ('Just 0.', 'Just 0. Red', '3'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', '3'),
    ('Ikea', 'Glühwein', '4'),
    ('Choya', 'Silver', '3'),
    ('Carlo Rossi', 'Vin carlo rossi', '4'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', '4'),
    -- batch 2 (non-alcoholic)
    ('Just 0',                         'Just 0. Red',                                      '1'),  -- natural wine dealcoholized
    ('Just 0',                         'Just 0 White alcoholfree',                          '1'),
    ('Seth & Riley''S Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', '4'),  -- flavored beverage
    ('Van Pur S.A',                    'Łomża piwo jasne bezalkoholowe',                     '3'),  -- brewed beer, dealcoholized
    ('Owolovo',                        'Truskawkowo Mus jabłkowo-truskawkowy',               '1')   -- fruit mousse, minimal processing
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Alcohol');
