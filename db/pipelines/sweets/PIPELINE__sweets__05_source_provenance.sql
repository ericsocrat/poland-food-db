-- PIPELINE (Sweets): source provenance
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
    ('E.Wedel', 'Czekolada gorzka Wiśniowa', 'https://world.openfoodfacts.org/product/5901588017457', '5901588017457'),
    ('Choctopus', 'Czekolada bąbelkowa mleczna', 'https://world.openfoodfacts.org/product/5905858671592', '5905858671592'),
    ('Wawel', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', 'https://world.openfoodfacts.org/product/5900102009978', '5900102009978'),
    ('Biedronka', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', 'https://world.openfoodfacts.org/product/5907180316417', '5907180316417'),
    ('Milano', 'Czekolada mleczna z całymi orzechami laskowymi', 'https://world.openfoodfacts.org/product/5907443600222', '5907443600222'),
    ('Biedronka', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami.', 'https://world.openfoodfacts.org/product/5907180316431', '5907180316431'),
    ('Magnetic', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', 'https://world.openfoodfacts.org/product/5902581687609', '5902581687609'),
    ('Magnetic', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', 'https://world.openfoodfacts.org/product/5902581687593', '5902581687593'),
    ('Alpen Gold', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'https://world.openfoodfacts.org/product/5903189076314', '5903189076314'),
    ('Wedel', 'Czekolada biała', 'https://world.openfoodfacts.org/product/5901588018713', '5901588018713'),
    ('Mella', 'Galaretka w czekoladzie o smaku wiśniowym', 'https://world.openfoodfacts.org/product/5900352012292', '5900352012292'),
    ('Wawel', 'Vege now z pastą z orzecha laskowego', 'https://world.openfoodfacts.org/product/5900102027699', '5900102027699'),
    ('Mokate', 'Czekolada biała napój o smaku białej czekolady', 'https://world.openfoodfacts.org/product/5900649085152', '5900649085152'),
    ('E. Wedel', 'Czekolada biała', 'https://world.openfoodfacts.org/product/5901588017938', '5901588017938'),
    ('Royal Nut', 'Czekolada mleczna z całymi orzechami laskowymi', 'https://world.openfoodfacts.org/product/5909000776340', '5909000776340'),
    ('Wawel', 'Piernikowa ze śliwką', 'https://world.openfoodfacts.org/product/5900102022762', '5900102022762'),
    ('E. Wedel', 'Czekolada mocno gorzka 80%', 'https://world.openfoodfacts.org/product/5901588018195', '5901588018195'),
    ('E. Wedel', 'Czekolada klasyczna gorzka 64%', 'https://world.openfoodfacts.org/product/5901588018768', '5901588018768'),
    ('E. Wedel', 'Mleczna klasyczna', 'https://world.openfoodfacts.org/product/5901588018775', '5901588018775'),
    ('Goplana', 'Gorzka 1912', 'https://world.openfoodfacts.org/product/5900352004891', '5900352004891'),
    ('E. Wedel', 'Mleczna Truskawkowa', 'https://world.openfoodfacts.org/product/5901588016443', '5901588016443'),
    ('E. Wedel', 'Wedel extra dark chocolate', 'https://world.openfoodfacts.org/product/5901588018409', '5901588018409'),
    ('E. Wedel', 'Gorzka Kokosowa', 'https://world.openfoodfacts.org/product/5901588017839', '5901588017839'),
    ('Mellie', 'Dark Chocolate Orange', 'https://world.openfoodfacts.org/product/5905858670755', '5905858670755'),
    ('E. Wedel', 'Mocno Mleczna', 'https://world.openfoodfacts.org/product/5901588018652', '5901588018652'),
    ('E.Wedel', 'Czekolada Tiramisu', 'https://world.openfoodfacts.org/product/5901588017617', '5901588017617'),
    ('E. Wedel', 'Mleczna malinowa', 'https://world.openfoodfacts.org/product/5901588016498', '5901588016498'),
    ('Biedronka', 'Czekolada gorzka 95% kakao', 'https://world.openfoodfacts.org/product/5904358565844', '5904358565844'),
    ('Unknown', 'Czekolada Biała z chrupkami kakaowymi', 'https://world.openfoodfacts.org/product/5907443604817', '5907443604817'),
    ('Magnetic', 'Czekolada Gorzka', 'https://world.openfoodfacts.org/product/5902581689771', '5902581689771'),
    ('Deliss', 'Czekolada mleczna z całymi orzechami laskowymi', 'https://world.openfoodfacts.org/product/5901912621701', '5901912621701'),
    ('Wedel', 'Czekolada gorzka 70%', 'https://world.openfoodfacts.org/product/5900102023745', '5900102023745'),
    ('Magnetic', 'Czekolada mleczna truskawkowa', 'https://world.openfoodfacts.org/product/5907443600970', '5907443600970'),
    ('Wawel', 'Czekolada deserowa 43% cocoa', 'https://world.openfoodfacts.org/product/5900102018161', '5900102018161'),
    ('Wawel', 'Tiramisu czekolada nadziewana', 'https://world.openfoodfacts.org/product/5900102021215', '5900102021215'),
    ('Wawel', 'Truskawkowa czekolada nadziewana', 'https://world.openfoodfacts.org/product/5900102020584', '5900102020584'),
    ('Wawel', 'Gorzka Extra', 'https://world.openfoodfacts.org/product/5900102028382', '5900102028382'),
    ('Wawel', 'Gorzka 70%', 'https://world.openfoodfacts.org/product/5900102025473', '5900102025473'),
    ('Wawel', '100% Cocoa Ekstra Gorzka', 'https://world.openfoodfacts.org/product/5900102025091', '5900102025091'),
    ('Wawel', 'Czekolada Gorzka 64%', 'https://world.openfoodfacts.org/product/5900102028481', '5900102028481'),
    ('Baron', 'whole nutty', 'https://world.openfoodfacts.org/product/5907443604190', '5907443604190'),
    ('E. Wedel', 'Czekolada Gorzka O Smaku Espresso', 'https://world.openfoodfacts.org/product/5901588018423', '5901588018423'),
    ('Wawel', 'Wawel - Kasztanki - Czekolada Nadziewana', 'https://world.openfoodfacts.org/product/5900102009138', '5900102009138'),
    ('Wawel', 'Czekolada gorzka 70%', 'https://world.openfoodfacts.org/product/5900102312610', '5900102312610'),
    ('Wawel', 'Mleczna', 'https://world.openfoodfacts.org/product/5900102025480', '5900102025480'),
    ('Magnetic', 'Czekolada mleczna', 'https://world.openfoodfacts.org/product/5902581689764', '5902581689764'),
    ('E. Wedel', 'chocolat noir 50%', 'https://world.openfoodfacts.org/product/5901588018751', '5901588018751'),
    ('Allegro', 'Czekolada mleczna', 'https://world.openfoodfacts.org/product/5901677000612', '5901677000612'),
    ('Terravita', 'Czekolada deserowa', 'https://world.openfoodfacts.org/product/5900915028890', '5900915028890'),
    ('E. Wedel', 'Jedyna Czekolada Wyborowa', 'https://world.openfoodfacts.org/product/5901588017822', '5901588017822')
) AS d(brand, product_name, source_url, source_ean)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Sweets' AND p.is_deprecated IS NOT TRUE
ON CONFLICT DO NOTHING;
