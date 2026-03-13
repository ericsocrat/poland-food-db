-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900125001508', '5906395015344', '5901473560303', '5904378645595', '5902020163213', '5903548002008', '5908230530753', '5906012000852', '5900617002945', '5902180240106', '5900125001478', '5900766000076', '5902172000695', '5907180315090', '5904142000018', '5907771443218', '5907500500014', '5906827022605', '5900125001485', '5906716208707', '5904645001727', '5901713001245', '5906827018141', '5901713020659', '5901549093483', '5900783003968', '5906716208042', '5901713016799', '5901844101661', '20809539', '5907544132431', '5900977011595', '5901844101685', '20355968', '4056489717607', '8410134026876', '4770205128866', '5908267100073', '8586024422537', '8586024420113', '20229030', '20173074', '4056489529712', '4056489067566', '4335896750729', '8002920016675', '8445290493125', '4056489717591', '4056489587026', '4056489064503', '4001163111929', '5202390023576', '20282516', '8435493398006', '8712355263178')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Plant-Based & Alternatives by pipeline',
    ean = null
where country = 'PL'
  and category != 'Plant-Based & Alternatives'
  and identity_key in ('07ff9834bab19511595c139447bcf214', '0813f47f6a6b5b05c351cfd1c120f172', '0cd21723b0b3f1e433f0f3bf53b3aaf1', '176d4ed19ee93f1b7ded010466f2f255', '19828b0f873ccab92bf51d7a8547bbce', '1bad05e7dec41123c8524ab49a133ed5', '21fc9b668f177ba67dbda110b6471ab8', '267d91ddbd553dbbb92e37389fd377e4', '2de54e341e578c1a4143bc613faf16fa', '2f8972c01dd81f2eeb49b9523a7e5c0f', '34c3683af33c5073c3c0a7cca267d6cb', '35dba10e820868aad512f2f845427f62', '3c8fcf5dc6bb578d241eb54ce0872b16', '3def426c7056a3116f33c31acb12ddec', '44b3ccfe1792326580bf3d4a3a7c2610', '4910afd97f8db32f9c7d590c011344f6', '4c03b640e565f82403a96c04cbfe9e5c', '4c41e112275ea7a7a61609f1bfc9b157', '4cf7b0790af72e5c5efecd8d8c97d61a', '5ac7ffce8b29104a03fc03e297c384ae', '64a816f09d8b1fe425fd886e5142a8a0', '64b7c3317138b454660886f387b7a349', '65bd701921520c234cf35dae8701af7f', '689187f425a9f4780eef23179d67fbbd', '6d3c03605bc0843e06c0033fc42541c5', '6e6b69f53273c243fd1958e710d5616b', '76cf2cef431d798a77ad0e60873aa909', '788f6a2df632e6b915df63672fa622a7', '7ed7b311070776ff3d97dd0d32dc202f', '7f180397ec0ce0fb8778a84417697b21', '80383b4df886bffbd0e0d7ba6b07176d', '86deaa7ac6121742f0f04e7a8341765d', '88acd5d562c87f7a3de75b4be22ffea6', '8bdcd671fd93f6ffdcf64f544dcb0cd9', '8c7531e00bae0a2213644f271f2b2022', '9093618703c6c69dd6d23cf6b8b45518', '93bc2180744967fb7575cae18e526c34', '9f654a963441161fe375bf605dd3fe4a', 'a11051b063986d8c719a3ae75863369d', 'a24506efde88ef3737ab6ba59c78cb79', 'ad0f9f75c3ebadd4c0d3ad71985f6ef7', 'b49fbd1288157f41c9a061a8c712179b', 'b506d2729e17d560bf21e37d6c2f42bc', 'b9f9666a5aa227fc992af3b4080bd922', 'bcb1f7562efd6c7c05d8c6ee919be185', 'c52272e29845caa7d722561174341693', 'c703b6cc81b8fabdf00dc2cd0fc6c96f', 'cabb994f611a9a42dcca13fa47845013', 'cfb934270ef8446619df50ffb8be2984', 'd23b51da852bfd63bfa2cc4a8dc2e906', 'd4b6fe0a6671e52c71b316546b375bc5', 'dca665f0ebcba0429c5a36152ce0b06a', 'e68e6dc92c8aeadd540d5109e09714b5', 'edf0c9ead845487a663cddeddbf95b87', 'f014be4fd789752bb8a5f0f89ceb23b6')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Pano', 'Grocery', 'Plant-Based & Alternatives', 'Wafle Ryżowe Wieloziarnisty', 'not-applicable', 'Biedronka', 'none', '5900125001508'),
  ('PL', 'Pri', 'Grocery', 'Plant-Based & Alternatives', 'Ziemniaczki Już Gotowe z papryką', 'steamed', 'Biedronka', 'none', '5906395015344'),
  ('PL', 'Go Vege', 'Grocery', 'Plant-Based & Alternatives', 'Parówki sojowe klasyczne', 'not-applicable', 'Biedronka', 'none', '5901473560303'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Plant-Based & Alternatives', 'Nasza Spiżarnia Korniszony z chilli', 'not-applicable', 'Biedronka', 'none', '5904378645595'),
  ('PL', 'Basia', 'Grocery', 'Plant-Based & Alternatives', 'Mąka Tortowa Extra typ 405 Basia', 'not-applicable', 'Dino', 'none', '5902020163213'),
  ('PL', 'Dobra-kaloria', 'Grocery', 'Plant-Based & Alternatives', 'Baton owocowy chrupiący orzech', 'not-applicable', 'Lidl', 'none', '5903548002008'),
  ('PL', 'Tarczyński', 'Grocery', 'Plant-Based & Alternatives', 'Rośl-inne Kabanosy 3 Ziarna', 'not-applicable', 'Biedronka', 'none', '5908230530753'),
  ('PL', 'Złote Pola', 'Grocery', 'Plant-Based & Alternatives', 'Mąka tortowa pszenna. Typ 450', 'not-applicable', 'Biedronka', 'none', '5906012000852'),
  ('PL', 'Sante', 'Grocery', 'Plant-Based & Alternatives', 'Otręby owsiane', 'not-applicable', 'Dino', 'none', '5900617002945'),
  ('PL', 'Sonko', 'Grocery', 'Plant-Based & Alternatives', 'Kasza jęczmienna perłowa', 'not-applicable', 'Tesco', 'none', '5902180240106'),
  ('PL', 'Pano', 'Grocery', 'Plant-Based & Alternatives', 'Wafle Kukurydziane sól morska', 'not-applicable', null, 'none', '5900125001478'),
  ('PL', 'Polskie Mlyny', 'Grocery', 'Plant-Based & Alternatives', 'Mąka pszenna Szymanowska 480', 'not-applicable', null, 'none', '5900766000076'),
  ('PL', 'Kupiec', 'Grocery', 'Plant-Based & Alternatives', 'Kasza manna błyskawiczna', 'not-applicable', null, 'none', '5902172000695'),
  ('PL', 'GustoBello', 'Grocery', 'Plant-Based & Alternatives', 'Mąka do pizzy neapolitańskiej typ 00', 'not-applicable', null, 'none', '5907180315090'),
  ('PL', 'PZZ Kraków', 'Grocery', 'Plant-Based & Alternatives', 'Mąka pszenna tortowa', 'not-applicable', null, 'none', '5904142000018'),
  ('PL', 'Uniflora', 'Grocery', 'Plant-Based & Alternatives', 'Kiełki rzodkiewki', 'not-applicable', null, 'none', '5907771443218'),
  ('PL', 'Szczepanki', 'Grocery', 'Plant-Based & Alternatives', 'Mąka pszenna wrocławska typ 500', 'not-applicable', null, 'none', '5907500500014'),
  ('PL', 'Unknown', 'Grocery', 'Plant-Based & Alternatives', 'Kasza gryczana prażona', 'not-applicable', null, 'none', '5906827022605'),
  ('PL', 'Pani', 'Grocery', 'Plant-Based & Alternatives', 'Wafle Prowansalskie', 'not-applicable', 'Biedronka', 'none', '5900125001485'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat Pomidorowy 30%', 'not-applicable', 'Biedronka', 'none', '5906716208707'),
  ('PL', 'Madero', 'Grocery', 'Plant-Based & Alternatives', 'Chrzan tarty', 'not-applicable', 'Biedronka', 'none', '5904645001727'),
  ('PL', 'Dawtona', 'Grocery', 'Plant-Based & Alternatives', 'Sűrített paradicsom', 'not-applicable', 'Kaufland', 'none', '5901713001245'),
  ('PL', 'Melvit', 'Grocery', 'Plant-Based & Alternatives', 'Natural Mix', 'not-applicable', 'Biedronka', 'none', '5906827018141'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat pomidorowy', 'not-applicable', null, 'none', '5901713020659'),
  ('PL', 'Wojan team', 'Grocery', 'Plant-Based & Alternatives', 'Wojanek', 'not-applicable', null, 'none', '5901549093483'),
  ('PL', 'Pudliszki', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat pomidorowy', 'not-applicable', null, 'none', '5900783003968'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Plant-Based & Alternatives', 'Fasola czerwona', 'not-applicable', null, 'none', '5906716208042'),
  ('PL', 'Dawtona', 'Grocery', 'Plant-Based & Alternatives', 'Koncentrat pomidorowy', 'not-applicable', null, 'none', '5901713016799'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Pasta z czosnkiem', 'not-applicable', null, 'none', '5901844101661'),
  ('PL', 'Biedronka', 'Grocery', 'Plant-Based & Alternatives', 'Borówka amerykańska odmiany Brightwell', 'not-applicable', 'Biedronka', 'none', '20809539'),
  ('PL', 'GustoBello', 'Grocery', 'Plant-Based & Alternatives', 'Gnocchi Di Patate', 'not-applicable', null, 'none', '5907544132431'),
  ('PL', 'Plony natury', 'Grocery', 'Plant-Based & Alternatives', 'Kasza manna', 'not-applicable', null, 'none', '5900977011595'),
  ('PL', 'Culineo', 'Grocery', 'Plant-Based & Alternatives', 'Passata klasyczna', 'not-applicable', null, 'none', '5901844101685'),
  ('PL', 'Anecoop', 'Grocery', 'Plant-Based & Alternatives', 'Włoszczyzna', 'not-applicable', 'Biedronka', 'none', '20355968'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu wędzone', 'smoked', null, 'none', '4056489717607'),
  ('PL', 'El Toro Rojo', 'Grocery', 'Plant-Based & Alternatives', 'Oliwki zielone nadziewane pastą paprykową', 'not-applicable', null, 'none', '8410134026876'),
  ('PL', 'Plony Natury', 'Grocery', 'Plant-Based & Alternatives', 'Kasza Gryczana Biała', 'not-applicable', null, 'none', '4770205128866'),
  ('PL', 'Janex', 'Grocery', 'Plant-Based & Alternatives', 'Kasza Gryczana', 'not-applicable', null, 'none', '5908267100073'),
  ('PL', 'Go Vege', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Naturalne', 'not-applicable', 'Biedronka', 'none', '8586024422537'),
  ('PL', 'Go VEGE', 'Grocery', 'Plant-Based & Alternatives', 'Tofu sweet chili', 'marinated', 'Biedronka', 'none', '8586024420113'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Avocados', 'not-applicable', 'Lidl', 'none', '20229030'),
  ('PL', 'Kania', 'Grocery', 'Plant-Based & Alternatives', 'Crispy Fried Onions', 'fried', 'Lidl', 'none', '20173074'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu plain', 'not-applicable', 'Lidl', 'none', '4056489529712'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu naturalne', 'not-applicable', 'Lidl', 'none', '4056489067566'),
  ('PL', 'K-take it veggie', 'Grocery', 'Plant-Based & Alternatives', 'Tofu natur eco', 'not-applicable', 'Kaufland', 'none', '4335896750729'),
  ('PL', 'GustoBello', 'Grocery', 'Plant-Based & Alternatives', 'Polpa di pomodoro', 'not-applicable', null, 'none', '8002920016675'),
  ('PL', 'Garden Gourmet', 'Grocery', 'Plant-Based & Alternatives', 'Veggie Balls', 'not-applicable', null, 'none', '8445290493125'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu', 'not-applicable', null, 'none', '4056489717591'),
  ('PL', 'Tastino', 'Grocery', 'Plant-Based & Alternatives', 'Wafle Kukurydziane', 'not-applicable', null, 'none', '4056489587026'),
  ('PL', 'Crownfield', 'Grocery', 'Plant-Based & Alternatives', 'Owsianka Truskawkowa', 'not-applicable', null, 'none', '4056489064503'),
  ('PL', 'Bakello', 'Grocery', 'Plant-Based & Alternatives', 'Ciasto francuskie', 'not-applicable', null, 'none', '4001163111929'),
  ('PL', 'Violife', 'Grocery', 'Plant-Based & Alternatives', 'Cheddar flavour slices', 'not-applicable', null, 'none', '5202390023576'),
  ('PL', 'Golden Sun Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Kasza manna', 'not-applicable', null, 'none', '20282516'),
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Plant-Based & Alternatives', 'Ananas Plastry', 'not-applicable', null, 'none', '8435493398006'),
  ('PL', 'Unknown', 'Grocery', 'Plant-Based & Alternatives', 'Awokado hass', 'not-applicable', null, 'none', '8712355263178')
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
where country = 'PL' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Wafle Ryżowe Wieloziarnisty', 'Ziemniaczki Już Gotowe z papryką', 'Parówki sojowe klasyczne', 'Nasza Spiżarnia Korniszony z chilli', 'Mąka Tortowa Extra typ 405 Basia', 'Baton owocowy chrupiący orzech', 'Rośl-inne Kabanosy 3 Ziarna', 'Mąka tortowa pszenna. Typ 450', 'Otręby owsiane', 'Kasza jęczmienna perłowa', 'Wafle Kukurydziane sól morska', 'Mąka pszenna Szymanowska 480', 'Kasza manna błyskawiczna', 'Mąka do pizzy neapolitańskiej typ 00', 'Mąka pszenna tortowa', 'Kiełki rzodkiewki', 'Mąka pszenna wrocławska typ 500', 'Kasza gryczana prażona', 'Wafle Prowansalskie', 'Koncentrat Pomidorowy 30%', 'Chrzan tarty', 'Sűrített paradicsom', 'Natural Mix', 'Koncentrat pomidorowy', 'Wojanek', 'Koncentrat pomidorowy', 'Fasola czerwona', 'Koncentrat pomidorowy', 'Pasta z czosnkiem', 'Borówka amerykańska odmiany Brightwell', 'Gnocchi Di Patate', 'Kasza manna', 'Passata klasyczna', 'Włoszczyzna', 'Tofu wędzone', 'Oliwki zielone nadziewane pastą paprykową', 'Kasza Gryczana Biała', 'Kasza Gryczana', 'Tofu Naturalne', 'Tofu sweet chili', 'Avocados', 'Crispy Fried Onions', 'Tofu plain', 'Tofu naturalne', 'Tofu natur eco', 'Polpa di pomodoro', 'Veggie Balls', 'Tofu', 'Wafle Kukurydziane', 'Owsianka Truskawkowa', 'Ciasto francuskie', 'Cheddar flavour slices', 'Kasza manna', 'Ananas Plastry', 'Awokado hass');
