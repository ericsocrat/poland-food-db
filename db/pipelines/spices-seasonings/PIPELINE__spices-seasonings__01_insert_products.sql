-- PIPELINE (Spices & Seasonings): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Spices & Seasonings'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901135046749', '5907476533863', '5901135000062', '5900084188012', '5904194908683', '5900084079013', '5902605224124', '5901135015233', '5901135050302', '5901135030731', '5903766142166', '5904194907808', '5901032034009', '5900956002309', '5900300543717', '5900084204873', '5901135000338', '5902020779018', '5900862213530', '5901752703971', '5900084235136', '5901135000321', '5900084235198', '5900084274074', '5901135000383', '5901135012522', '5902898822458', '5901135021814', '5900084238144', '5902605220980', '5901135000666', '5903760705329', '5904378644192', '4335619165502', '5900437082677', '20484804', '20422103', '4056489123651', '4056489644286', '8722700255710', '8595717700418', '4065059003194')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Spices & Seasonings by pipeline',
    ean = null
where country = 'PL'
  and category != 'Spices & Seasonings'
  and identity_key in ('0fd6c4c292c7157cc03fd68b000bca81', '11074211923baf6b38c0429e65090e3c', '138d890e8184256e4175b2b0454a62a2', '1adbb28a9d7c29f6f8bd5cb61f1509b1', '1aeb1e97f9c98027f45146b1a4c5e5cb', '28fdb546bfa142c493d1245a7f074930', '2c85cdf95915ded23fb68eb15adfbdd3', '34070869f41ea17ffb304e679fd34eeb', '363238786b3d695ff74b32cb3296c701', '3747228c46b0bd6d06218a4a19cfc82c', '3831afa7b0bbe8324acd0b8847222ff6', '38bd686c8a6074d911df4813a877b2e3', '392feb1b9c9e1e6cc1f74d78b785a504', '3c20d8f0f0674fe0a22260a5ce842dbb', '3ff10b8d6814c5b70294595f0fbf744f', '406a584982bda7dc9abbf140ecc4babc', '504dd14e9b9a578eefd4936c80d05515', '50842e29069c6fc5df4c5696cbb5bff0', '5e2ad65c68ef32c99e175c5ed79ae4c7', '5f76ab7e6de7935bfd27011f152c6f5b', '6ea3a91a9bf593789dceabd898dd9088', '8115fcc824930d5bfa16e866cbca105e', '828d19a53c085446ee24b95640ca36c8', '8440f6ff50882e6d4d0443fb45d33b8a', '84ee61602ba05ea75b2829a94952751c', '867860450e798480817ee930bf763f69', '882da3d1b9b543c5f1de2154b02769fe', '889b2217be41c2044aba8702c982f449', '8a88d3b89a30fb04ecd4b4f442e2c5a2', 'a6142fdb61c683c2d3ed35b29b04fe23', 'a6e8ba0df88fac86e15400aa0d968e8c', 'b0db110e36a05231556136ac41242f59', 'cce759c737573518f710a59ed3d22888', 'd162fdb5894e5459ed0beec20281af83', 'e08423319de5caf8278974cf92181bc8', 'e1d15390c44a96bde3ce9ebd9c074bdc', 'e37d5bed53308b3c597e4946437cc658', 'e5b877fc3310e8049a5aa64c03a05968', 'ed5ba9655b392a6c2f78b21da4702117', 'ee6e55998c64283c47174c0fee340601', 'f647a07c746cd876998edb4a397f55b5', 'f9a045b1e2ef67b7bb87e92890968214')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Kucharek', 'Grocery', 'Spices & Seasonings', 'Przyprawa do potraw z obniżoną zawartością soli', 'not-applicable', 'Kaufland', 'none', '5901135046749'),
  ('PL', 'Donatello', 'Grocery', 'Spices & Seasonings', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 'not-applicable', null, 'none', '5907476533863'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 'not-applicable', null, 'none', '5901135000062'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Przyprawa kuchni włoskiej', 'not-applicable', null, 'none', '5900084188012'),
  ('PL', 'Donatello', 'Grocery', 'Spices & Seasonings', 'Antipasti nadziewane serkiem wiśniowe papryczki', 'not-applicable', null, 'none', '5904194908683'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Przyprawa do dań z ziemniaków', 'not-applicable', null, 'none', '5900084079013'),
  ('PL', 'Planteon', 'Grocery', 'Spices & Seasonings', 'Pieprz ziołowy', 'not-applicable', null, 'none', '5902605224124'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do kurczaka złocista skórka', 'not-applicable', null, 'none', '5901135015233'),
  ('PL', 'Kucharek', 'Grocery', 'Spices & Seasonings', 'Przyprawa do mięs', 'not-applicable', null, 'none', '5901135050302'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do mięs', 'not-applicable', null, 'none', '5901135030731'),
  ('PL', 'Promienie Słońca', 'Grocery', 'Spices & Seasonings', 'Papryka słodka wędzona', 'smoked', null, 'none', '5903766142166'),
  ('PL', 'Perla', 'Grocery', 'Spices & Seasonings', 'Pełna dobra papryczkę czerwone i pepperoni', 'not-applicable', null, 'none', '5904194907808'),
  ('PL', 'Kotanyi', 'Grocery', 'Spices & Seasonings', 'Anyż cały', 'not-applicable', null, 'none', '5901032034009'),
  ('PL', 'Herbapol', 'Grocery', 'Spices & Seasonings', 'Mięta', 'not-applicable', null, 'none', '5900956002309'),
  ('PL', 'Knorr', 'Grocery', 'Spices & Seasonings', 'Przyprawa do mięs', 'not-applicable', null, 'none', '5900300543717'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Przyprawa do gyrosa', 'not-applicable', 'Biedronka', 'none', '5900084204873'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do sałatek sosów i dipów', 'not-applicable', null, 'none', '5901135000338'),
  ('PL', 'Culineo', 'Grocery', 'Spices & Seasonings', 'Cebulka zapiekana', 'not-applicable', 'Biedronka', 'none', '5902020779018'),
  ('PL', 'Sainsbury''s', 'Grocery', 'Spices & Seasonings', 'Black Peppercorns', 'not-applicable', null, 'none', '5900862213530'),
  ('PL', 'Casa de mexico', 'Grocery', 'Spices & Seasonings', 'Papryka zielona krojona', 'not-applicable', null, 'none', '5901752703971'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Curry', 'not-applicable', null, 'none', '5900084235136'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do kurczaka', 'not-applicable', null, 'none', '5901135000321'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Seasoning for fish', 'not-applicable', null, 'none', '5900084235198'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Cynamon', 'not-applicable', null, 'none', '5900084274074'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Grill klasyczny', 'grilled', null, 'none', '5901135000383'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Kebab gyros', 'not-applicable', null, 'none', '5901135012522'),
  ('PL', 'Casa del sur', 'Grocery', 'Spices & Seasonings', 'Pepperoni pepper imp', 'not-applicable', null, 'none', '5902898822458'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa Kebab Gyros klasyczna', 'not-applicable', null, 'none', '5901135021814'),
  ('PL', 'Kamis', 'Grocery', 'Spices & Seasonings', 'Przyprawa do spaghetti bolognese', 'not-applicable', null, 'none', '5900084238144'),
  ('PL', 'Planteon', 'Grocery', 'Spices & Seasonings', 'Papryka ostra mielona 60 ASTA', 'not-applicable', null, 'none', '5902605220980'),
  ('PL', 'Prymat', 'Grocery', 'Spices & Seasonings', 'Przyprawa do ryb', 'not-applicable', null, 'none', '5901135000666'),
  ('PL', 'Lewiatan', 'Grocery', 'Spices & Seasonings', 'Chipsy paprykowe', 'not-applicable', null, 'none', '5903760705329'),
  ('PL', 'El Toro Rojo', 'Grocery', 'Spices & Seasonings', 'Kapary w zalewie', 'not-applicable', null, 'none', '5904378644192'),
  ('PL', 'Lidl', 'Grocery', 'Spices & Seasonings', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 'not-applicable', null, 'none', '4335619165502'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Spices & Seasonings', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 'not-applicable', null, 'none', '5900437082677'),
  ('PL', 'El Tequito', 'Grocery', 'Spices & Seasonings', 'Jalapeños', 'not-applicable', 'Lidl', 'none', '20484804'),
  ('PL', 'Lidl', 'Grocery', 'Spices & Seasonings', 'Ground chili peppers in olive oil', 'not-applicable', 'Lidl', 'none', '20422103'),
  ('PL', 'Kania', 'Grocery', 'Spices & Seasonings', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'not-applicable', 'Lidl', 'none', '4056489123651'),
  ('PL', 'Eridanous', 'Grocery', 'Spices & Seasonings', 'Gyros', 'not-applicable', 'Lidl', 'none', '4056489644286'),
  ('PL', 'Knorr', 'Grocery', 'Spices & Seasonings', 'Czosnek', 'not-applicable', null, 'none', '8722700255710'),
  ('PL', 'Vilgain', 'Grocery', 'Spices & Seasonings', 'Koření na pizzu', 'dried', null, 'none', '8595717700418'),
  ('PL', 'All Seasons', 'Grocery', 'Spices & Seasonings', 'Papryka konserwowa', 'not-applicable', null, 'none', '4065059003194')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Spices & Seasonings'
  and is_deprecated is not true
  and product_name not in ('Przyprawa do potraw z obniżoną zawartością soli', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 'Przyprawa kuchni włoskiej', 'Antipasti nadziewane serkiem wiśniowe papryczki', 'Przyprawa do dań z ziemniaków', 'Pieprz ziołowy', 'Przyprawa do kurczaka złocista skórka', 'Przyprawa do mięs', 'Przyprawa do mięs', 'Papryka słodka wędzona', 'Pełna dobra papryczkę czerwone i pepperoni', 'Anyż cały', 'Mięta', 'Przyprawa do mięs', 'Przyprawa do gyrosa', 'Przyprawa do sałatek sosów i dipów', 'Cebulka zapiekana', 'Black Peppercorns', 'Papryka zielona krojona', 'Curry', 'Przyprawa do kurczaka', 'Seasoning for fish', 'Cynamon', 'Grill klasyczny', 'Kebab gyros', 'Pepperoni pepper imp', 'Przyprawa Kebab Gyros klasyczna', 'Przyprawa do spaghetti bolognese', 'Papryka ostra mielona 60 ASTA', 'Przyprawa do ryb', 'Chipsy paprykowe', 'Kapary w zalewie', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 'Jalapeños', 'Ground chili peppers in olive oil', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'Gyros', 'Czosnek', 'Koření na pizzu', 'Papryka konserwowa');
