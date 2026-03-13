-- PIPELINE (Spices & Seasonings): source provenance
-- Generated: 2026-03-13

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', 'https://world.openfoodfacts.org/product/5901135046749', '5901135046749'),
    ('Donatello', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 'https://world.openfoodfacts.org/product/5907476533863', '5907476533863'),
    ('Prymat', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 'https://world.openfoodfacts.org/product/5901135000062', '5901135000062'),
    ('Kamis', 'Przyprawa kuchni włoskiej', 'https://world.openfoodfacts.org/product/5900084188012', '5900084188012'),
    ('Donatello', 'Antipasti nadziewane serkiem wiśniowe papryczki', 'https://world.openfoodfacts.org/product/5904194908683', '5904194908683'),
    ('Kamis', 'Przyprawa do dań z ziemniaków', 'https://world.openfoodfacts.org/product/5900084079013', '5900084079013'),
    ('Planteon', 'Pieprz ziołowy', 'https://world.openfoodfacts.org/product/5902605224124', '5902605224124'),
    ('Prymat', 'Przyprawa do kurczaka złocista skórka', 'https://world.openfoodfacts.org/product/5901135015233', '5901135015233'),
    ('Kucharek', 'Przyprawa do mięs', 'https://world.openfoodfacts.org/product/5901135050302', '5901135050302'),
    ('Prymat', 'Przyprawa do mięs', 'https://world.openfoodfacts.org/product/5901135030731', '5901135030731'),
    ('Promienie Słońca', 'Papryka słodka wędzona', 'https://world.openfoodfacts.org/product/5903766142166', '5903766142166'),
    ('Perla', 'Pełna dobra papryczkę czerwone i pepperoni', 'https://world.openfoodfacts.org/product/5904194907808', '5904194907808'),
    ('Kotanyi', 'Anyż cały', 'https://world.openfoodfacts.org/product/5901032034009', '5901032034009'),
    ('Herbapol', 'Mięta', 'https://world.openfoodfacts.org/product/5900956002309', '5900956002309'),
    ('Knorr', 'Przyprawa do mięs', 'https://world.openfoodfacts.org/product/5900300543717', '5900300543717'),
    ('Kamis', 'Przyprawa do gyrosa', 'https://world.openfoodfacts.org/product/5900084204873', '5900084204873'),
    ('Prymat', 'Przyprawa do sałatek sosów i dipów', 'https://world.openfoodfacts.org/product/5901135000338', '5901135000338'),
    ('Culineo', 'Cebulka zapiekana', 'https://world.openfoodfacts.org/product/5902020779018', '5902020779018'),
    ('Sainsbury''s', 'Black Peppercorns', 'https://world.openfoodfacts.org/product/5900862213530', '5900862213530'),
    ('Casa de mexico', 'Papryka zielona krojona', 'https://world.openfoodfacts.org/product/5901752703971', '5901752703971'),
    ('Kamis', 'Curry', 'https://world.openfoodfacts.org/product/5900084235136', '5900084235136'),
    ('Prymat', 'Przyprawa do kurczaka', 'https://world.openfoodfacts.org/product/5901135000321', '5901135000321'),
    ('Kamis', 'Seasoning for fish', 'https://world.openfoodfacts.org/product/5900084235198', '5900084235198'),
    ('Kamis', 'Cynamon', 'https://world.openfoodfacts.org/product/5900084274074', '5900084274074'),
    ('Prymat', 'Grill klasyczny', 'https://world.openfoodfacts.org/product/5901135000383', '5901135000383'),
    ('Prymat', 'Kebab gyros', 'https://world.openfoodfacts.org/product/5901135012522', '5901135012522'),
    ('Casa del sur', 'Pepperoni pepper imp', 'https://world.openfoodfacts.org/product/5902898822458', '5902898822458'),
    ('Prymat', 'Przyprawa Kebab Gyros klasyczna', 'https://world.openfoodfacts.org/product/5901135021814', '5901135021814'),
    ('Kamis', 'Przyprawa do spaghetti bolognese', 'https://world.openfoodfacts.org/product/5900084238144', '5900084238144'),
    ('Planteon', 'Papryka ostra mielona 60 ASTA', 'https://world.openfoodfacts.org/product/5902605220980', '5902605220980'),
    ('Prymat', 'Przyprawa do ryb', 'https://world.openfoodfacts.org/product/5901135000666', '5901135000666'),
    ('Lewiatan', 'Chipsy paprykowe', 'https://world.openfoodfacts.org/product/5903760705329', '5903760705329'),
    ('El Toro Rojo', 'Kapary w zalewie', 'https://world.openfoodfacts.org/product/5904378644192', '5904378644192'),
    ('Lidl', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 'https://world.openfoodfacts.org/product/4335619165502', '4335619165502'),
    ('Dr. Oetker', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 'https://world.openfoodfacts.org/product/5900437082677', '5900437082677'),
    ('El Tequito', 'Jalapeños', 'https://world.openfoodfacts.org/product/20484804', '20484804'),
    ('Lidl', 'Ground chili peppers in olive oil', 'https://world.openfoodfacts.org/product/20422103', '20422103'),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'https://world.openfoodfacts.org/product/4056489123651', '4056489123651'),
    ('Eridanous', 'Gyros', 'https://world.openfoodfacts.org/product/4056489644286', '4056489644286'),
    ('Knorr', 'Czosnek', 'https://world.openfoodfacts.org/product/8722700255710', '8722700255710'),
    ('Vilgain', 'Koření na pizzu', 'https://world.openfoodfacts.org/product/8595717700418', '8595717700418'),
    ('All Seasons', 'Papryka konserwowa', 'https://world.openfoodfacts.org/product/4065059003194', '4065059003194')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Spices & Seasonings' AND p.is_deprecated IS NOT TRUE;
