-- PIPELINE (Sweets): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Sweets'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901588017457', '5905858671592', '5900102009978', '5907180316417', '5907443600222', '5907180316431', '5902581687609', '5902581687593', '5903189076314', '5901588018713', '5900352012292', '5900102027699', '5900649085152', '5901588017938', '5909000776340', '5900102022762', '5901588018195', '5901588018768', '5901588018775', '5900352004891', '5901588016443', '5901588018409', '5901588017839', '5905858670755', '5901588018652', '5901588017617', '5901588016498', '5904358565844', '5907443604817', '5902581689771', '5901912621701', '5900102023745', '5907443600970', '5900102018161', '5900102021215', '5900102020584', '5900102028382', '5900102025473', '5900102025091', '5900102028481', '5907443604190', '5901588018423', '5900102009138', '5900102312610', '5900102025480', '5902581689764', '5901588018751', '5901677000612', '5900915028890', '5901588017822')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'E.Wedel', 'Grocery', 'Sweets', 'Czekolada gorzka Wiśniowa', 'not-applicable', 'Auchan', 'none', '5901588017457'),
  ('PL', 'Choctopus', 'Grocery', 'Sweets', 'Czekolada bąbelkowa mleczna', 'not-applicable', 'Żabka', 'none', '5905858671592'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', 'not-applicable', 'Auchan', 'none', '5900102009978'),
  ('PL', 'Biedronka', 'Grocery', 'Sweets', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', 'not-applicable', 'Biedronka', 'none', '5907180316417'),
  ('PL', 'Milano', 'Grocery', 'Sweets', 'Czekolada mleczna z całymi orzechami laskowymi', 'not-applicable', 'Biedronka', 'none', '5907443600222'),
  ('PL', 'Biedronka', 'Grocery', 'Sweets', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami', 'not-applicable', 'Biedronka', 'none', '5907180316431'),
  ('PL', 'Magnetic', 'Grocery', 'Sweets', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', 'not-applicable', 'Biedronka', 'none', '5902581687609'),
  ('PL', 'Magnetic', 'Grocery', 'Sweets', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', 'not-applicable', 'Biedronka', 'none', '5902581687593'),
  ('PL', 'Alpen Gold', 'Grocery', 'Sweets', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'not-applicable', null, 'none', '5903189076314'),
  ('PL', 'Wedel', 'Grocery', 'Sweets', 'Czekolada biała', 'not-applicable', null, 'none', '5901588018713'),
  ('PL', 'Mella', 'Grocery', 'Sweets', 'Galaretka w czekoladzie o smaku wiśniowym', 'not-applicable', null, 'none', '5900352012292'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Vege now z pastą z orzecha laskowego', 'not-applicable', null, 'none', '5900102027699'),
  ('PL', 'Mokate', 'Grocery', 'Sweets', 'Czekolada biała napój o smaku białej czekolady', 'not-applicable', null, 'none', '5900649085152'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada biała', 'not-applicable', null, 'none', '5901588017938'),
  ('PL', 'Royal Nut', 'Grocery', 'Sweets', 'Czekolada mleczna z całymi orzechami laskowymi', 'not-applicable', null, 'none', '5909000776340'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Piernikowa ze śliwką', 'not-applicable', null, 'none', '5900102022762'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada mocno gorzka 80%', 'not-applicable', 'Biedronka', 'none', '5901588018195'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada klasyczna gorzka 64%', 'not-applicable', 'Żabka', 'none', '5901588018768'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Mleczna klasyczna', 'not-applicable', 'Żabka', 'none', '5901588018775'),
  ('PL', 'Goplana', 'Grocery', 'Sweets', 'Gorzka 1912', 'not-applicable', 'Kaufland', 'none', '5900352004891'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Mleczna Truskawkowa', 'not-applicable', 'Żabka', 'none', '5901588016443'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Wedel extra dark chocolate', 'not-applicable', 'Auchan', 'none', '5901588018409'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Gorzka Kokosowa', 'not-applicable', 'Żabka', 'none', '5901588017839'),
  ('PL', 'Mellie', 'Grocery', 'Sweets', 'Dark Chocolate Orange', 'not-applicable', 'Biedronka', 'none', '5905858670755'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Mocno Mleczna', 'not-applicable', 'Żabka', 'none', '5901588018652'),
  ('PL', 'E.Wedel', 'Grocery', 'Sweets', 'Czekolada Tiramisu', 'not-applicable', 'Biedronka', 'none', '5901588017617'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Mleczna malinowa', 'not-applicable', 'Żabka', 'none', '5901588016498'),
  ('PL', 'Biedronka', 'Grocery', 'Sweets', 'Czekolada gorzka 95% kakao', 'not-applicable', 'Biedronka', 'none', '5904358565844'),
  ('PL', 'Unknown', 'Grocery', 'Sweets', 'Czekolada Biała z chrupkami kakaowymi', 'not-applicable', null, 'none', '5907443604817'),
  ('PL', 'Magnetic', 'Grocery', 'Sweets', 'Czekolada Gorzka', 'not-applicable', 'Biedronka', 'none', '5902581689771'),
  ('PL', 'Deliss', 'Grocery', 'Sweets', 'Czekolada mleczna z całymi orzechami laskowymi', 'not-applicable', null, 'none', '5901912621701'),
  ('PL', 'Wedel', 'Grocery', 'Sweets', 'Czekolada gorzka 70%', 'not-applicable', 'Auchan', 'none', '5900102023745'),
  ('PL', 'Magnetic', 'Grocery', 'Sweets', 'Czekolada mleczna truskawkowa', 'not-applicable', 'Biedronka', 'none', '5907443600970'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Czekolada deserowa 43% cocoa', 'not-applicable', 'Auchan', 'none', '5900102018161'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Tiramisu czekolada nadziewana', 'not-applicable', 'Biedronka', 'none', '5900102021215'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Truskawkowa czekolada nadziewana', 'not-applicable', 'Biedronka', 'none', '5900102020584'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Gorzka Extra', 'not-applicable', null, 'none', '5900102028382'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Gorzka 70%', 'not-applicable', null, 'none', '5900102025473'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', '100% Cocoa Ekstra Gorzka', 'not-applicable', null, 'none', '5900102025091'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Czekolada Gorzka 64%', 'not-applicable', null, 'none', '5900102028481'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada Gorzka O Smaku Espresso', 'not-applicable', null, 'none', '5901588018423'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Wawel - Kasztanki - Czekolada Nadziewana', 'not-applicable', null, 'none', '5900102009138'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Czekolada gorzka 70%', 'not-applicable', null, 'none', '5900102312610'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Mleczna', 'not-applicable', null, 'none', '5900102025480'),
  ('PL', 'Magnetic', 'Grocery', 'Sweets', 'Czekolada mleczna', 'not-applicable', null, 'none', '5902581689764'),
  ('PL', 'Allegro', 'Grocery', 'Sweets', 'Czekolada mleczna', 'not-applicable', null, 'none', '5901677000612'),
  ('PL', 'Terravita', 'Grocery', 'Sweets', 'Czekolada deserowa', 'not-applicable', null, 'none', '5900915028890'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Jedyna Czekolada Wyborowa', 'not-applicable', null, 'none', '5901588017822')
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
where country = 'PL' and category = 'Sweets'
  and is_deprecated is not true
  and product_name not in ('Czekolada gorzka Wiśniowa', 'Czekolada bąbelkowa mleczna', 'Czekolada gorzka z kandyzowaną skórką pomarańczy', 'Belgijska czekolada mleczna z kawałkami słonego karmelu', 'Czekolada mleczna z całymi orzechami laskowymi', 'Belgijska czekolada deserowa ze skórką pomarańczy i migdałami', 'Czekolada mleczna z nadzieniem orzechowym i kawałkami orzechów laskowych', 'Czekolada deserowa z nadzieniem o smaku pistacjowym z kawałkami migdałów i orzechów pistacjowych', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'Czekolada biała', 'Galaretka w czekoladzie o smaku wiśniowym', 'Vege now z pastą z orzecha laskowego', 'Czekolada biała napój o smaku białej czekolady', 'Czekolada biała', 'Czekolada mleczna z całymi orzechami laskowymi', 'Piernikowa ze śliwką', 'Czekolada mocno gorzka 80%', 'Czekolada klasyczna gorzka 64%', 'Mleczna klasyczna', 'Gorzka 1912', 'Mleczna Truskawkowa', 'Wedel extra dark chocolate', 'Gorzka Kokosowa', 'Dark Chocolate Orange', 'Mocno Mleczna', 'Czekolada Tiramisu', 'Mleczna malinowa', 'Czekolada gorzka 95% kakao', 'Czekolada Biała z chrupkami kakaowymi', 'Czekolada Gorzka', 'Czekolada mleczna z całymi orzechami laskowymi', 'Czekolada gorzka 70%', 'Czekolada mleczna truskawkowa', 'Czekolada deserowa 43% cocoa', 'Tiramisu czekolada nadziewana', 'Truskawkowa czekolada nadziewana', 'Gorzka Extra', 'Gorzka 70%', '100% Cocoa Ekstra Gorzka', 'Czekolada Gorzka 64%', 'whole nutty', 'Czekolada Gorzka O Smaku Espresso', 'Wawel - Kasztanki - Czekolada Nadziewana', 'Czekolada gorzka 70%', 'Mleczna', 'Czekolada mleczna', 'chocolat noir 50%', 'Czekolada mleczna', 'Czekolada deserowa', 'Jedyna Czekolada Wyborowa');
