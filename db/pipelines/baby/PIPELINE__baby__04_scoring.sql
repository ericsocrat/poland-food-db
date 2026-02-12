-- PIPELINE (Baby): scoring
-- Generated: 2026-02-09

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'UNKNOWN'),
    ('Diamant', 'Cukier Biały', 'E'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'A'),
    ('Owolovo', 'OwoLowo Jabłkowo', 'A'),
    ('Mlekovita', 'Bezwodny tłuszcz mleczny, Masło klarowane', 'E'),
    ('Vital Fresh', 'Surówka Smakołyk', 'A'),
    ('BoboVita', 'Pomidorowa z kurczakiem i ryżem', 'NOT-APPLICABLE'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'NOT-APPLICABLE'),
    ('Polski Cukier', 'Cukier biały', 'E'),
    ('Piątnica', 'Twaróg wiejski tłusty', 'UNKNOWN'),
    ('Vital Fresh', 'Mus 100% owoców jabłko gruszka', 'A'),
    ('Kubuś', 'Kubuś malina', 'B'),
    ('Owolovo', 'mus jabłkowo-malinowo', 'B'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 'UNKNOWN'),
    ('Nestlé', 'Barszcz czerwony', 'E'),
    ('Swojska Chata', 'Pierogi ruskie', 'C'),
    ('Kraina Wędlin', 'POLĘDWICA SOPOCKA', 'UNKNOWN'),
    ('Kapitan navi', 'Śledzie po kołobrzesku', 'UNKNOWN'),
    ('Magnetic', 'QuickCao', 'UNKNOWN'),
    ('Królewski', 'Cukier 1 kg', 'E'),
    ('Nestlé', 'Przyprawa Maggi', 'E'),
    ('Gryzzale', 'polutry kabanos sausages', 'UNKNOWN'),
    ('Dania Express Biedronka', 'Lasagne Bolognese', 'C'),
    ('Owolovo', 'Owolovo ananasowo', 'A'),
    ('Tarczyński', 'Kabanosy Z Kurczaka Protein', 'E'),
    ('Owolovo', 'BRZOSKWINIOWO', 'A'),
    ('Leibniz', 'Minis classic', 'UNKNOWN'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'NOT-APPLICABLE'),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 'NOT-APPLICABLE'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', 'NOT-APPLICABLE'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'NOT-APPLICABLE'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'NOT-APPLICABLE'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'NOT-APPLICABLE'),
    ('Pudliszki', 'Pudliszki', 'UNKNOWN'),
    ('Kamis', 'Kamis Musztarda Kremska 185G', 'UNKNOWN'),
    ('Tarczyński', 'gryzzale', 'UNKNOWN'),
    ('Hyperfood', 'Eatyx Wanilla', 'NOT-APPLICABLE'),
    ('Go Active', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'A'),
    ('Vitanella', 'Ciastka Czekolada & Zboża', 'UNKNOWN'),
    ('Vitanella', 'Baton select orzeszki ziemne, migdały, sól morska', 'UNKNOWN'),
    ('Maribel', 'Ahorn sirup', 'E'),
    ('Nestlé', 'Nestle Sinlac', 'NOT-APPLICABLE'),
    ('Hipp', 'Dynia z indykiem', 'NOT-APPLICABLE'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'NOT-APPLICABLE'),
    ('Go Active', 'Pudding proteinowy', 'A'),
    ('Nestlé', 'Bulion drobiowy', 'C'),
    ('Go Active', 'pudding czekolada', 'A'),
    ('Tastino', 'Papryka Barbecue', 'D')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', '1'),
    ('Diamant', 'Cukier Biały', '2'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', '1'),
    ('Owolovo', 'OwoLowo Jabłkowo', '1'),
    ('Mlekovita', 'Bezwodny tłuszcz mleczny, Masło klarowane', '1'),
    ('Vital Fresh', 'Surówka Smakołyk', '4'),
    ('BoboVita', 'Pomidorowa z kurczakiem i ryżem', '3'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', '3'),
    ('Polski Cukier', 'Cukier biały', '2'),
    ('Piątnica', 'Twaróg wiejski tłusty', '4'),
    ('Vital Fresh', 'Mus 100% owoców jabłko gruszka', '1'),
    ('Kubuś', 'Kubuś malina', '4'),
    ('Owolovo', 'mus jabłkowo-malinowo', '4'),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', '4'),
    ('Nestlé', 'Barszcz czerwony', '4'),
    ('Swojska Chata', 'Pierogi ruskie', '3'),
    ('Kraina Wędlin', 'POLĘDWICA SOPOCKA', '4'),
    ('Kapitan navi', 'Śledzie po kołobrzesku', '4'),
    ('Magnetic', 'QuickCao', '4'),
    ('Królewski', 'Cukier 1 kg', '2'),
    ('Nestlé', 'Przyprawa Maggi', '4'),
    ('Gryzzale', 'polutry kabanos sausages', '4'),
    ('Dania Express Biedronka', 'Lasagne Bolognese', '4'),
    ('Owolovo', 'Owolovo ananasowo', '1'),
    ('Tarczyński', 'Kabanosy Z Kurczaka Protein', '4'),
    ('Owolovo', 'BRZOSKWINIOWO', '1'),
    ('Leibniz', 'Minis classic', '4'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', '3'),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', '3'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', '3'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', '3'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', '1'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', '4'),
    ('Pudliszki', 'Pudliszki', '4'),
    ('Kamis', 'Kamis Musztarda Kremska 185G', '4'),
    ('Tarczyński', 'gryzzale', '4'),
    ('Hyperfood', 'Eatyx Wanilla', '4'),
    ('Go Active', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', '4'),
    ('Vitanella', 'Ciastka Czekolada & Zboża', '4'),
    ('Vitanella', 'Baton select orzeszki ziemne, migdały, sól morska', '4'),
    ('Maribel', 'Ahorn sirup', '2'),
    ('Nestlé', 'Nestle Sinlac', '4'),
    ('Hipp', 'Dynia z indykiem', '1'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', '4'),
    ('Go Active', 'Pudding proteinowy', '4'),
    ('Nestlé', 'Bulion drobiowy', '4'),
    ('Go Active', 'pudding czekolada', '4'),
    ('Tastino', 'Papryka Barbecue', '4')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Baby');
