-- PIPELINE (Instant & Frozen): scoring
-- Generated: 2026-03-12

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 'UNKNOWN'),
    ('Ajinomoto', 'Oyakata w stylu japoński klasyczny', 'UNKNOWN'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'UNKNOWN'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', 'UNKNOWN'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 'UNKNOWN'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'UNKNOWN'),
    ('Vifon', 'Korean Hot Beef', 'UNKNOWN'),
    ('Vifon', 'Kimchi', 'UNKNOWN'),
    ('Goong', 'Curry Noodles', 'UNKNOWN'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', 'UNKNOWN'),
    ('Vifon', 'Ramen Soy Souce', 'UNKNOWN'),
    ('Vifon', 'Ramen Tonkotsu', 'UNKNOWN'),
    ('Sam Smak', 'Pomidorowa', 'UNKNOWN'),
    ('Oyakata', 'Ramen Miso et Légumes', 'UNKNOWN'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 'UNKNOWN'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 'UNKNOWN'),
    ('Oyakata', 'Nouilles de blé', 'UNKNOWN'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 'UNKNOWN'),
    ('Oyakata', 'Ramen Barbecue', 'UNKNOWN'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 'UNKNOWN'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 'UNKNOWN'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', 'UNKNOWN'),
    ('Ajinomoto', 'Tomato soup', 'UNKNOWN'),
    ('Ajinomoto', 'Mushrood soup', 'UNKNOWN'),
    ('Vifon', 'Zupka hińska', 'UNKNOWN'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'UNKNOWN'),
    ('Nongshim', 'Kimchi Bowl Noodles', 'UNKNOWN'),
    ('Nongshim', 'Super Spicy Red Shin', 'UNKNOWN'),
    ('Indomie', 'Noodles Chicken Flavour', 'UNKNOWN'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 'UNKNOWN'),
    ('NongshimSamyang', 'Ramen kimchi', 'UNKNOWN'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'UNKNOWN'),
    ('มาม่า', 'Mala Beef Instant Noodle', 'UNKNOWN'),
    ('Mama', 'Mama salted egg', 'UNKNOWN'),
    ('Reeva', 'Zupa o smaku sera i boczku', 'UNKNOWN'),
    ('Knorr', 'Nudle Pieczony kurczak', 'UNKNOWN'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', 'UNKNOWN'),
    ('Unknown', 'Chicken flavour', 'UNKNOWN'),
    ('Nongshim', 'Shin Kimchi Noodles', 'UNKNOWN'),
    ('Ko-Lee', 'Instant noodles curry flavour', 'UNKNOWN'),
    ('Namdong', 'Beef Jjigae k-noodles', 'UNKNOWN'),
    ('Knorr', 'Makaron ser z bekonem', 'UNKNOWN'),
    ('Knorr', 'Makaron 4 sery', 'UNKNOWN')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', '4'),
    ('Ajinomoto', 'Oyakata w stylu japoński klasyczny', '4'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', '4'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', '4'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', '4'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', '4'),
    ('Vifon', 'Korean Hot Beef', '4'),
    ('Vifon', 'Kimchi', '4'),
    ('Goong', 'Curry Noodles', '4'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', '4'),
    ('Vifon', 'Ramen Soy Souce', '4'),
    ('Vifon', 'Ramen Tonkotsu', '4'),
    ('Sam Smak', 'Pomidorowa', '4'),
    ('Oyakata', 'Ramen Miso et Légumes', '4'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', '4'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', '4'),
    ('Oyakata', 'Nouilles de blé', '4'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', '4'),
    ('Oyakata', 'Ramen Barbecue', '4'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', '4'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', '4'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', '4'),
    ('Ajinomoto', 'Tomato soup', '4'),
    ('Ajinomoto', 'Mushrood soup', '4'),
    ('Vifon', 'Zupka hińska', '4'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', '4'),
    ('Nongshim', 'Kimchi Bowl Noodles', '4'),
    ('Nongshim', 'Super Spicy Red Shin', '4'),
    ('Indomie', 'Noodles Chicken Flavour', '4'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', '4'),
    ('NongshimSamyang', 'Ramen kimchi', '4'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', '4'),
    ('มาม่า', 'Mala Beef Instant Noodle', '4'),
    ('Mama', 'Mama salted egg', '4'),
    ('Reeva', 'Zupa o smaku sera i boczku', '4'),
    ('Knorr', 'Nudle Pieczony kurczak', '4'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', '4'),
    ('Unknown', 'Chicken flavour', '4'),
    ('Nongshim', 'Shin Kimchi Noodles', '4'),
    ('Ko-Lee', 'Instant noodles curry flavour', '4'),
    ('Namdong', 'Beef Jjigae k-noodles', '4'),
    ('Knorr', 'Makaron ser z bekonem', '4'),
    ('Knorr', 'Makaron 4 sery', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Instant & Frozen', 100, 'PL');
