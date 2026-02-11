-- PIPELINE (Baby): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true
  and sc.product_id is null;

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  )
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'UNKNOWN'),
    ('Diamant', 'Cukier Biały', 'E'),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'A'),
    ('OwoLovo', 'OwoLowo Jabłkowo', 'A'),
    ('Mlekovita', 'Bezwodny tłuszcz mleczny, Masło klarowane', 'E'),
    ('Vital Fresh', 'Surówka Smakołyk', 'A'),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 'NOT-APPLICABLE'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'NOT-APPLICABLE'),
    ('Polski Cukier', 'Cukier biały', 'E'),
    ('Piątnica', 'Twaróg wiejski tłusty', 'UNKNOWN'),
    ('Vital Fresh', 'Mus 100% owoców jabłko gruszka', 'A'),
    ('kubuś', 'kubuś malina', 'B'),
    ('owolovo', 'mus jabłkowo-malinowo', 'B'),
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
    ('OWOLOVO', 'BRZOSKWINIOWO', 'A'),
    ('Leibniz', 'Minis classic', 'UNKNOWN'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'NOT-APPLICABLE'),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 'NOT-APPLICABLE'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', 'NOT-APPLICABLE'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 'NOT-APPLICABLE'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 'NOT-APPLICABLE'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 'NOT-APPLICABLE'),
    ('Pudliszki', 'Pudliszki', 'UNKNOWN'),
    ('Kamis', 'Kamis Musztarda Kremska 185G.', 'UNKNOWN'),
    ('tarczyński', 'gryzzale', 'UNKNOWN'),
    ('Dolina Dobra', '5908226815710', 'UNKNOWN'),
    ('Hyperfood', 'Eatyx Wanilla', 'NOT-APPLICABLE'),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'A'),
    ('Vitanella', 'Ciastka Czekolada & Zboża', 'UNKNOWN'),
    ('Vitanella', 'Baton select orzeszki ziemne, migdały, sól morska', 'UNKNOWN'),
    ('Maribel', 'Ahorn sirup', 'E'),
    ('Nestlé', 'Nestle Sinlac', 'NOT-APPLICABLE'),
    ('Hipp', 'Dynia z indykiem', 'NOT-APPLICABLE'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'NOT-APPLICABLE'),
    ('Go active', 'Pudding proteinowy', 'A'),
    ('Nestlé', 'Bulion drobiowy', 'C'),
    ('GO Active', 'pudding czekolada', 'A'),
    ('Tastino', 'Papryka Barbecue', 'D')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 3. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Magnetic', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', '1'),
    ('Diamant', 'Cukier Biały', '2'),
    ('owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', '1'),
    ('OwoLovo', 'OwoLowo Jabłkowo', '1'),
    ('Mlekovita', 'Bezwodny tłuszcz mleczny, Masło klarowane', '1'),
    ('Vital Fresh', 'Surówka Smakołyk', '4'),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', '3'),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', '3'),
    ('Polski Cukier', 'Cukier biały', '2'),
    ('Piątnica', 'Twaróg wiejski tłusty', '4'),
    ('Vital Fresh', 'Mus 100% owoców jabłko gruszka', '1'),
    ('kubuś', 'kubuś malina', '4'),
    ('owolovo', 'mus jabłkowo-malinowo', '4'),
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
    ('OWOLOVO', 'BRZOSKWINIOWO', '1'),
    ('Leibniz', 'Minis classic', '4'),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', '3'),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', '3'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', '3'),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', '3'),
    ('BoboVita', 'BoboVita Jabłka z marchewka', '1'),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', '4'),
    ('Pudliszki', 'Pudliszki', '4'),
    ('Kamis', 'Kamis Musztarda Kremska 185G.', '4'),
    ('tarczyński', 'gryzzale', '4'),
    ('Dolina Dobra', '5908226815710', '4'),
    ('Hyperfood', 'Eatyx Wanilla', '4'),
    ('GO ACTIVE', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', '4'),
    ('Vitanella', 'Ciastka Czekolada & Zboża', '4'),
    ('Vitanella', 'Baton select orzeszki ziemne, migdały, sól morska', '4'),
    ('Maribel', 'Ahorn sirup', '2'),
    ('Nestlé', 'Nestle Sinlac', '4'),
    ('Hipp', 'Dynia z indykiem', '1'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', '4'),
    ('Go active', 'Pudding proteinowy', '4'),
    ('Nestlé', 'Bulion drobiowy', '4'),
    ('GO Active', 'pudding czekolada', '4'),
    ('Tastino', 'Papryka Barbecue', '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;
