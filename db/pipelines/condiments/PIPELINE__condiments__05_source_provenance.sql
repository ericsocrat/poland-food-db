-- PIPELINE (Condiments): source provenance
-- Generated: 2026-02-11

-- 1. Populate product_sources (one row per product from OFF API)
INSERT INTO product_sources
       (product_id, source_type, source_url, source_ean, fields_populated,
        confidence_pct, is_primary)
SELECT p.product_id,
       'off_api',
       d.source_url,
       d.source_ean,
       ARRAY['product_name','brand','category','product_type','ean',
             'prep_method','store_availability','controversies',
             'calories','total_fat_g','saturated_fat_g',
             'carbs_g','sugars_g','protein_g',
             'fibre_g','salt_g','trans_fat_g'],
       90,
       true
FROM (
  VALUES
    ('Kotlin', 'Ketchup Łagodny', 'https://world.openfoodfacts.org/product/5900385012573', '5900385012573'),
    ('Heinz', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5900783004996', '5900783004996'),
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', 'https://world.openfoodfacts.org/product/5900783003043', '5900783003043'),
    ('Pudliszki', 'Ketchup Łagodny Premium', 'https://world.openfoodfacts.org/product/5900783008581', '5900783008581'),
    ('Roleski', 'Ketchup łagodny markowy', 'https://world.openfoodfacts.org/product/5901044011074', '5901044011074'),
    ('Kotliński specjał', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901307001309', '5901307001309'),
    ('Pudliszki', 'Ketchup łagodny Pudliszek', 'https://world.openfoodfacts.org/product/5900783008673', '5900783008673'),
    ('Agro Nova Food', 'Ketchup pikantny z pomidorów z Kujaw', 'https://world.openfoodfacts.org/product/5901248001444', '5901248001444'),
    ('Dawtona', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901713012173', '5901713012173'),
    ('Kamis', 'Ketchup włoski', 'https://world.openfoodfacts.org/product/5900084254700', '5900084254700'),
    ('Tomatini', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901713012647', '5901713012647'),
    ('Roleski', 'Ketchup markowy łagodny', 'https://world.openfoodfacts.org/product/5901044015652', '5901044015652'),
    ('Madero', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5906425121830', '5906425121830'),
    ('Unknown', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901529031436', '5901529031436'),
    ('Pegaz', 'Musztarda stołowa', 'https://world.openfoodfacts.org/product/5901658000020', '5901658000020'),
    ('Pudliszki', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5900783008680', '5900783008680'),
    ('Kotlin', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5900385500148', '5900385500148'),
    ('Roleski', 'Ketchup Premium Łagodny', 'https://world.openfoodfacts.org/product/5901044022896', '5901044022896'),
    ('Madero', 'Ketchup Łagodny', 'https://world.openfoodfacts.org/product/5900385501756', '5900385501756'),
    ('Roleski', 'Ketchup premium meksykański KETO', 'https://world.openfoodfacts.org/product/5901044027532', '5901044027532'),
    ('Międzychód', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901619150948', '5901619150948'),
    ('Na Szlaku Smaku', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5906734827294', '5906734827294'),
    ('Polskie przetwory', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901986081050', '5901986081050'),
    ('Roleski', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5908235940083', '5908235940083'),
    ('Kotlin', 'Ketchup z truskawką', 'https://world.openfoodfacts.org/product/5900385501640', '5900385501640'),
    ('Reypol', 'Ketchup Ziołowy Premium z Nasionami Konopi', 'https://world.openfoodfacts.org/product/5902501342007', '5902501342007'),
    ('Reypol', 'Ketchup premium łagodny', 'https://world.openfoodfacts.org/product/5902501339007', '5902501339007'),
    ('Lewiatan', 'Ketchup Łagodny', 'https://world.openfoodfacts.org/product/5903760706135', '5903760706135'),
    ('Kotliński', 'Ketchup łagodny', 'https://world.openfoodfacts.org/product/5901307004973', '5901307004973'),
    ('Roleski', 'Musztarda Stołowa', 'https://world.openfoodfacts.org/product/5901044003581', '5901044003581'),
    ('Kotlin', 'Ketchup hot', 'https://world.openfoodfacts.org/product/5900385012528', '5900385012528'),
    ('Madero', 'Ketchup pikantny', 'https://world.openfoodfacts.org/product/5901713012692', '5901713012692'),
    ('Madero', 'Ketchup junior', 'https://world.openfoodfacts.org/product/5906425121397', '5906425121397'),
    ('Roleski', 'Ketchup Premium', 'https://world.openfoodfacts.org/product/5901044022872', '5901044022872'),
    ('Kotlin sp. z o. o.', 'Ketchup kotliński', 'https://world.openfoodfacts.org/product/5901307006519', '5901307006519'),
    ('Develey', 'Ketchup z dodatkiem miodu, czosnku i tymianku.', 'https://world.openfoodfacts.org/product/5906425121243', '5906425121243'),
    ('Dawtona', 'Ketchup pikantny', 'https://world.openfoodfacts.org/product/5901713012654', '5901713012654'),
    ('Włocławek', 'Ketchup', 'https://world.openfoodfacts.org/product/5901248002076', '5901248002076'),
    ('Roleski', 'Ketchup premium Pikantny', 'https://world.openfoodfacts.org/product/5901044022889', '5901044022889'),
    ('Roleski', 'Ketchup premium jalapeño KETO', 'https://world.openfoodfacts.org/product/5901044027556', '5901044027556'),
    ('Kotlin', 'Kotlin Ketchup Premium', 'https://world.openfoodfacts.org/product/5900385501688', '5900385501688'),
    ('Madero', 'Premium ketchup pikantny', 'https://world.openfoodfacts.org/product/5906425121861', '5906425121861'),
    ('Kotlin', 'Ketchup pikantny', 'https://world.openfoodfacts.org/product/5900385500391', '5900385500391'),
    ('Madero', 'Ketchup classic', 'https://world.openfoodfacts.org/product/5906425121434', '5906425121434'),
    ('Fenex', 'Ketchup nr. VII', 'https://world.openfoodfacts.org/product/5900854002555', '5900854002555'),
    ('Fenex', 'Ketchup nr VII', 'https://world.openfoodfacts.org/product/5900854002890', '5900854002890'),
    ('Włocławek', 'Ketchup pikantny', 'https://world.openfoodfacts.org/product/5901248001123', '5901248001123'),
    ('Krajowa Spółka Cukrowa', 'Ketchup lagoduy', 'https://world.openfoodfacts.org/product/5901986081111', '5901986081111'),
    ('Pudliszki', 'Ketchup Super Pikantny', 'https://world.openfoodfacts.org/product/5900783006426', '5900783006426'),
    ('Develey', 'Ketchup Pikantny', 'https://world.openfoodfacts.org/product/5906425120215', '5906425120215')
) AS d(brand, product_name, source_url, source_ean)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Condiments' AND p.is_deprecated IS NOT TRUE
ON CONFLICT DO NOTHING;
