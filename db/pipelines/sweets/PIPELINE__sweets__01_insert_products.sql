-- PIPELINE (Sweets): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Sweets'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Alpen Gold', 'Grocery', 'Sweets', 'Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'not-applicable', null, 'none', '5903189076314'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada mocno gorzka 80%', 'not-applicable', 'Tesco', 'none', '5901588018195'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Czekolada klasyczna gorzka 64%', 'not-applicable', 'Żabka', 'none', '5901588018768'),
  ('PL', 'E. Wedel', 'Grocery', 'Sweets', 'Mleczna klasyczna', 'not-applicable', 'Żabka', 'none', '5901588018775'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Gorzka Extra', 'not-applicable', null, 'none', '5900102028382'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', '100% Cocoa Ekstra Gorzka', 'not-applicable', null, 'none', '5900102025091'),
  ('PL', 'Wawel', 'Grocery', 'Sweets', 'Gorzka 70%', 'not-applicable', null, 'none', '5900102025473'),
  ('PL', 'Unknown', 'Grocery', 'Sweets', 'Czekolada gorzka Luximo', 'not-applicable', null, 'none', '5901669488824'),
  ('PL', 'Luximo', 'Grocery', 'Sweets', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', 'not-applicable', null, 'none', '5901669488831'),
  ('PL', 'fin CARRÉ', 'Grocery', 'Sweets', 'Extra dark 74% Cocoa', 'not-applicable', 'Lidl', 'none', '20022464'),
  ('PL', 'Lindt Excellence', 'Grocery', 'Sweets', 'Excellence 85% Cacao Rich Dark', 'not-applicable', 'Carrefour,Asda,Kaufland,Оливье', 'none', '3046920028363'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Chocolat au lait', 'not-applicable', 'Intermarché,Leclerc,Carrefour,Aldi,eroski,Woolworths,REWE,Coles,Auchan,Netto', 'none', '3045140105502'),
  ('PL', 'Toblerone', 'Grocery', 'Sweets', 'Milk Chocolate with Honey and Almond Nougat', 'not-applicable', 'Coop,Delhaize,Lidl,Kmart,Flow,Farmacorp,Chocolandia', 'none', '7614500010013'),
  ('PL', 'Storck', 'Grocery', 'Sweets', 'Merci Finest Selection Assorted Chocolates', 'not-applicable', 'Delhaize,Coop,Tesco', 'none', '4014400901191'),
  ('PL', 'Fin Carré', 'Grocery', 'Sweets', 'Milk Chocolate', 'not-applicable', 'Lidl', 'none', '20005825'),
  ('PL', 'fin Carré', 'Grocery', 'Sweets', 'Dunkle Schokolade mit ganzen Haselnüssen', 'not-applicable', 'Lidl', 'none', '20815356'),
  ('PL', 'Lindt', 'Grocery', 'Sweets', 'Lindt Excellence Dark Orange Intense', 'not-applicable', 'Tesco,Irma.dk,COOP,Ahorramás', 'none', '3046920028370'),
  ('PL', 'Fin Carré', 'Grocery', 'Sweets', 'Weiße Schokolade', 'not-applicable', 'Lidl', 'none', '20368197'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Milka chocolate Hazelnuts', 'not-applicable', 'HIT,Żabka', 'none', '4025700001023'),
  ('PL', 'Fin Carré', 'Grocery', 'Sweets', 'Extra Dark 85% Cocoa', 'not-applicable', 'lidl', 'none', '4056489366461'),
  ('PL', 'Ritter SPORT', 'Grocery', 'Sweets', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', 'not-applicable', 'Lidl,Irma.dk,Delhaize,REWE,Eurospar,Спар,Пятёрочка,Перекресток,Магнит,Визит,Сам Самыч,Willy''s,Соседи,Netto,Σκλαβενίτης', 'none', '4000417025005'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Happy Cow', 'not-applicable', 'Nahkauf,Lidl,Żabka', 'none', '7622400005190'),
  ('PL', 'Heidi', 'Grocery', 'Sweets', 'Dark Intense', 'not-applicable', 'Auchan,Carrefour,Penny', 'none', '5941021001261'),
  ('PL', 'Schogetten', 'Grocery', 'Sweets', 'Schogetten alpine milk chocolate', 'not-applicable', 'Lidl,Stokrotka', 'none', '4000607850004'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Milka Mmmax Oreo', 'not-applicable', 'Żabka', 'none', '7622210240200'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Schokolade Joghurt', 'not-applicable', 'Rewe,Żabka', 'none', '4025700001450'),
  ('PL', 'Milka', 'Grocery', 'Sweets', 'Strawberry', 'not-applicable', 'Żabka', 'palm oil', '7622200007332'),
  ('PL', 'Hatherwood', 'Grocery', 'Sweets', 'Salted Caramel Style', 'not-applicable', 'Lidl', 'none', '4056489350392')
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
  and product_name not in ('Nussbeisser czekolada mleczna z całymi orzechami laskowymi', 'Czekolada mocno gorzka 80%', 'Czekolada klasyczna gorzka 64%', 'Mleczna klasyczna', 'Gorzka Extra', '100% Cocoa Ekstra Gorzka', 'Gorzka 70%', 'Czekolada gorzka Luximo', 'Czekolada Gorzka (Z Platkami Pomaranczowymi)', 'Extra dark 74% Cocoa', 'Excellence 85% Cacao Rich Dark', 'Chocolat au lait', 'Milk Chocolate with Honey and Almond Nougat', 'Merci Finest Selection Assorted Chocolates', 'Milk Chocolate', 'Dunkle Schokolade mit ganzen Haselnüssen', 'Lindt Excellence Dark Orange Intense', 'Weiße Schokolade', 'Milka chocolate Hazelnuts', 'Extra Dark 85% Cocoa', 'MARZIPAN DARK CHOCOLATE WITH MARZIPAN', 'Happy Cow', 'Dark Intense', 'Schogetten alpine milk chocolate', 'Milka Mmmax Oreo', 'Schokolade Joghurt', 'Strawberry', 'Salted Caramel Style');
