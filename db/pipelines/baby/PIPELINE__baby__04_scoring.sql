-- PIPELINE (Baby): scoring
-- Generated: 2026-03-12

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Diamant', 'Cukier Biały', 'E'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'A'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'NOT-APPLICABLE'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 'UNKNOWN'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'NOT-APPLICABLE'),
    ('Nestle Gerber', 'Owoce jabłka z truskawkami i jagodami', 'NOT-APPLICABLE'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'NOT-APPLICABLE'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'NOT-APPLICABLE'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'NOT-APPLICABLE'),
    ('Nestlé', 'Nestle Sinlac', 'NOT-APPLICABLE'),
    ('Hipp', 'Dynia z indykiem', 'NOT-APPLICABLE'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'NOT-APPLICABLE')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Diamant', 'Cukier Biały', '2'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', '1'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', '3'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', '4'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', '3'),
    ('Nestle Gerber', 'Owoce jabłka z truskawkami i jagodami', '3'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', '3'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', '1'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', '4'),
    ('Nestlé', 'Nestle Sinlac', '4'),
    ('Hipp', 'Dynia z indykiem', '1'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Baby', 100, 'PL');
