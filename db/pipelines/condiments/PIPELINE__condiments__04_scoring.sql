-- PIPELINE (Condiments): scoring
-- Generated: 2026-02-11

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Kotlin', 'Ketchup Łagodny', 'D'),
    ('Heinz', 'Ketchup łagodny', 'D'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 'C'),
    ('Pudliszki', 'Ketchup Łagodny Premium', 'D'),
    ('Roleski', 'Ketchup łagodny markowy', 'D'),
    ('Kotliński specjał', 'Ketchup łagodny', 'D'),
    ('Pudliszki', 'Ketchup łagodny Pudliszek', 'E'),
    ('Agro Nova Food', 'Ketchup pikantny z pomidorów z Kujaw', 'D'),
    ('Dawtona', 'Ketchup łagodny', 'E'),
    ('Kamis', 'Ketchup włoski', 'D'),
    ('Tomatini', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup markowy łagodny', 'D'),
    ('Madero', 'Ketchup łagodny', 'D'),
    ('Unknown', 'Ketchup łagodny', 'D'),
    ('Pegaz', 'Musztarda stołowa', 'D'),
    ('Pudliszki', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup Premium Łagodny', 'C'),
    ('Roleski', 'Ketchup premium meksykański KETO', 'C'),
    ('Międzychód', 'Ketchup łagodny', 'C'),
    ('Na Szlaku Smaku', 'Ketchup łagodny', 'E'),
    ('Polskie przetwory', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Ketchup łagodny', 'D'),
    ('Kotlin', 'Ketchup z truskawką', 'D'),
    ('Reypol', 'Ketchup Ziołowy Premium z Nasionami Konopi', 'D'),
    ('Reypol', 'Ketchup premium łagodny', 'D'),
    ('Lewiatan', 'Ketchup Łagodny', 'C'),
    ('Kotliński', 'Ketchup łagodny', 'D'),
    ('Roleski', 'Musztarda Stołowa', 'D'),
    ('Kotlin', 'Ketchup hot', 'D'),
    ('Madero', 'Ketchup pikantny', 'E'),
    ('Madero', 'Ketchup junior', 'D'),
    ('Roleski', 'Ketchup Premium', 'D'),
    ('Kotlin sp. z o. o', 'Ketchup kotliński', 'D'),
    ('Develey', 'Ketchup z dodatkiem miodu, czosnku i tymianku', 'D'),
    ('Dawtona', 'Ketchup pikantny', 'D'),
    ('Włocławek', 'Ketchup', 'D'),
    ('Roleski', 'Ketchup premium Pikantny', 'D'),
    ('Roleski', 'Ketchup premium jalapeño KETO', 'C'),
    ('Kotlin', 'Kotlin Ketchup Premium', 'D'),
    ('Madero', 'Premium ketchup pikantny', 'D'),
    ('Kotlin', 'Ketchup pikantny', 'D'),
    ('Madero', 'Ketchup classic', 'D'),
    ('Fenex', 'Ketchup nr. VII', 'E'),
    ('Fenex', 'Ketchup nr VII', 'E'),
    ('Włocławek', 'Ketchup pikantny', 'D'),
    ('Krajowa Spółka Cukrowa', 'Ketchup lagoduy', 'UNKNOWN'),
    ('Pudliszki', 'Ketchup Super Pikantny', 'E'),
    ('Develey', 'Ketchup Pikantny', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Kotlin', 'Ketchup Łagodny', '4'),
    ('Heinz', 'Ketchup łagodny', '3'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', '4'),
    ('Pudliszki', 'Ketchup Łagodny Premium', '4'),
    ('Roleski', 'Ketchup łagodny markowy', '3'),
    ('Kotliński specjał', 'Ketchup łagodny', '4'),
    ('Pudliszki', 'Ketchup łagodny Pudliszek', '4'),
    ('Agro Nova Food', 'Ketchup pikantny z pomidorów z Kujaw', '4'),
    ('Dawtona', 'Ketchup łagodny', '4'),
    ('Kamis', 'Ketchup włoski', '4'),
    ('Tomatini', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup markowy łagodny', '3'),
    ('Madero', 'Ketchup łagodny', '4'),
    ('Unknown', 'Ketchup łagodny', '4'),
    ('Pegaz', 'Musztarda stołowa', '3'),
    ('Pudliszki', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup Premium Łagodny', '4'),
    ('Roleski', 'Ketchup premium meksykański KETO', '4'),
    ('Międzychód', 'Ketchup łagodny', '3'),
    ('Na Szlaku Smaku', 'Ketchup łagodny', '4'),
    ('Polskie przetwory', 'Ketchup łagodny', '4'),
    ('Roleski', 'Ketchup łagodny', '4'),
    ('Kotlin', 'Ketchup z truskawką', '4'),
    ('Reypol', 'Ketchup Ziołowy Premium z Nasionami Konopi', '3'),
    ('Reypol', 'Ketchup premium łagodny', '4'),
    ('Lewiatan', 'Ketchup Łagodny', '4'),
    ('Kotliński', 'Ketchup łagodny', '4'),
    ('Roleski', 'Musztarda Stołowa', '3'),
    ('Kotlin', 'Ketchup hot', '4'),
    ('Madero', 'Ketchup pikantny', '4'),
    ('Madero', 'Ketchup junior', '3'),
    ('Roleski', 'Ketchup Premium', '3'),
    ('Kotlin sp. z o. o', 'Ketchup kotliński', '4'),
    ('Develey', 'Ketchup z dodatkiem miodu, czosnku i tymianku', '3'),
    ('Dawtona', 'Ketchup pikantny', '4'),
    ('Włocławek', 'Ketchup', '4'),
    ('Roleski', 'Ketchup premium Pikantny', '3'),
    ('Roleski', 'Ketchup premium jalapeño KETO', '4'),
    ('Kotlin', 'Kotlin Ketchup Premium', '4'),
    ('Madero', 'Premium ketchup pikantny', '4'),
    ('Kotlin', 'Ketchup pikantny', '4'),
    ('Madero', 'Ketchup classic', '4'),
    ('Fenex', 'Ketchup nr. VII', '4'),
    ('Fenex', 'Ketchup nr VII', '4'),
    ('Włocławek', 'Ketchup pikantny', '4'),
    ('Krajowa Spółka Cukrowa', 'Ketchup lagoduy', '4'),
    ('Pudliszki', 'Ketchup Super Pikantny', '4'),
    ('Develey', 'Ketchup Pikantny', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Condiments');
