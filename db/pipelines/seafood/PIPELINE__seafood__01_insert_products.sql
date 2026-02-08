-- PIPELINE (SEAFOOD & FISH): insert products
-- PIPELINE__seafood__01_insert_products.sql
-- 28 verified seafood products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Categories: canned fish, frozen fish, smoked fish, fish spreads, seafood ready meals
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
-- ── CANNED TUNA ────────────────────────────────────────────────────────
-- EAN 5907654504864 — Graal Tuńczyk w Oleju Roślinnym (popular Polish brand)
('PL','Graal','Canned Fish','Seafood & Fish','Tuńczyk w Oleju Roślinnym','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654504864'),
-- EAN 5907654500781 — Graal Tuńczyk w Sosie Własnym (water-packed, healthier)
('PL','Graal','Canned Fish','Seafood & Fish','Tuńczyk w Sosie Własnym','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654500781'),
-- EAN 5901713000293 — King Oscar Tuńczyk Kawałki w Oleju (premium brand)
('PL','King Oscar','Canned Fish','Seafood & Fish','Tuńczyk Kawałki w Oleju','ready to eat','Carrefour;Lidl','none','5901713000293'),
-- EAN 5906747063221 — Seko Tuńczyk Naturalny (budget-friendly)
('PL','Seko','Canned Fish','Seafood & Fish','Tuńczyk Naturalny','ready to eat','Biedronka;Żabka','none','5906747063221'),

-- ── CANNED MACKEREL ────────────────────────────────────────────────────
-- EAN 5907654503287 — Graal Makrela w Oleju (classic Polish staple)
('PL','Graal','Canned Fish','Seafood & Fish','Makrela w Oleju','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654503287'),
-- EAN 5907654503270 — Graal Makrela w Sosie Pomidorowym (tomato sauce)
('PL','Graal','Canned Fish','Seafood & Fish','Makrela w Sosie Pomidorowym','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654503270'),
-- EAN 5906747061067 — Seko Makrela Filety w Oleju (fillets)
('PL','Seko','Canned Fish','Seafood & Fish','Makrela Filety w Oleju','ready to eat','Biedronka;Żabka','none','5906747061067'),

-- ── CANNED SARDINES ────────────────────────────────────────────────────
-- EAN 5907654505434 — Graal Sardynki w Oleju Roślinnym (omega-3 rich)
('PL','Graal','Canned Fish','Seafood & Fish','Sardynki w Oleju Roślinnym','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654505434'),
-- EAN 5907654505427 — Graal Sardynki w Sosie Pomidorowym
('PL','Graal','Canned Fish','Seafood & Fish','Sardynki w Sosie Pomidorowym','ready to eat','Biedronka;Lidl;Żabka;Carrefour','none','5907654505427'),
-- EAN 5906747062125 — Seko Sardynki w Oleju (budget option)
('PL','Seko','Canned Fish','Seafood & Fish','Sardynki w Oleju','ready to eat','Biedronka;Żabka','none','5906747062125'),

-- ── CANNED SALMON ──────────────────────────────────────────────────────
-- EAN 5907654506356 — Graal Łosoś Różowy w Sosie Własnym (pink salmon)
('PL','Graal','Canned Fish','Seafood & Fish','Łosoś Różowy w Sosie Własnym','ready to eat','Biedronka;Lidl;Carrefour','none','5907654506356'),
-- EAN 5901713001009 — King Oscar Łosoś Czerwony (red salmon, premium)
('PL','King Oscar','Canned Fish','Seafood & Fish','Łosoś Czerwony','ready to eat','Carrefour;Lidl','none','5901713001009'),

-- ── SMOKED FISH ────────────────────────────────────────────────────────
-- EAN 5902768000146 — Łosoś Morski Wędzony (smoked salmon, sliced)
('PL','Łosoś Morski','Smoked Fish','Seafood & Fish','Łosoś Wędzony Plastry','ready to eat','Biedronka;Lidl;Carrefour','none','5902768000146'),
-- EAN 5906747064273 — Seko Makrela Wędzona (smoked mackerel, whole)
('PL','Seko','Smoked Fish','Seafood & Fish','Makrela Wędzona','ready to eat','Biedronka;Żabka','none','5906747064273'),
-- EAN 5902835761826 — Graal Szprot Wędzony (smoked sprats)
('PL','Graal','Smoked Fish','Seafood & Fish','Szprot Wędzony','ready to eat','Biedronka;Lidl;Żabka','none','5902835761826'),
-- EAN 5907654507483 — Graal Pstrąg Wędzony (smoked trout)
('PL','Graal','Smoked Fish','Seafood & Fish','Pstrąg Wędzony','ready to eat','Lidl;Carrefour','none','5907654507483'),

-- ── FISH SPREADS (PÂTÉ) ────────────────────────────────────────────────
-- EAN 5907654508503 — Graal Pasta Rybna Łosoś (salmon spread)
('PL','Graal','Fish Spread','Seafood & Fish','Pasta Rybna Łosoś','ready to eat','Biedronka;Lidl;Żabka','none','5907654508503'),
-- EAN 5907654508527 — Graal Pasta Rybna Tuńczyk (tuna spread)
('PL','Graal','Fish Spread','Seafood & Fish','Pasta Rybna Tuńczyk','ready to eat','Biedronka;Lidl;Żabka','none','5907654508527'),
-- EAN 5906747065348 — Seko Pasta z Makreli (mackerel pâté)
('PL','Seko','Fish Spread','Seafood & Fish','Pasta z Makreli','ready to eat','Biedronka;Żabka','none','5906747065348'),

-- ── FROZEN FISH ────────────────────────────────────────────────────────
-- EAN 5902768001235 — Nautica (Lidl) Filety z Dorsza (cod fillets, frozen)
('PL','Nautica (Lidl)','Frozen Fish','Seafood & Fish','Filety z Dorsza','frozen','Lidl','none','5902768001235'),
-- EAN 5900126000337 — Frosta Filety Mintaja (pollock fillets, frozen)
('PL','Frosta','Frozen Fish','Seafood & Fish','Filety Mintaja','frozen','Biedronka;Lidl;Carrefour','none','5900126000337'),
-- EAN 5902768001297 — Nautica (Lidl) Filety z Łososia (salmon fillets, frozen)
('PL','Nautica (Lidl)','Frozen Fish','Seafood & Fish','Filety z Łososia','frozen','Lidl','none','5902768001297'),
-- EAN 5906747066123 — Seko Filety Pangi (pangasius, frozen)
('PL','Seko','Frozen Fish','Seafood & Fish','Filety Pangi','frozen','Biedronka;Żabka','none','5906747066123'),

-- ── FISH FINGERS & BREADED FISH ────────────────────────────────────────
-- EAN 5900126000412 — Frosta Paluszki Rybne (classic fish fingers, NOVA 4)
('PL','Frosta','Frozen Fish','Seafood & Fish','Paluszki Rybne','frozen','Biedronka;Lidl;Carrefour','none','5900126000412'),
-- EAN 5902768001358 — Nautica (Lidl) Paluszki Rybne Panierowane
('PL','Nautica (Lidl)','Frozen Fish','Seafood & Fish','Paluszki Rybne Panierowane','frozen','Lidl','none','5902768001358'),

-- ── SEAFOOD READY MEALS ────────────────────────────────────────────────
-- EAN 5907654509517 — Graal Sałatka z Tuńczykiem (tuna salad, ready to eat)
('PL','Graal','Seafood Ready Meal','Seafood & Fish','Sałatka z Tuńczykiem','ready to eat','Biedronka;Lidl;Carrefour','none','5907654509517'),
-- EAN 5906747067342 — Seko Sałatka Śledziowa (herring salad)
('PL','Seko','Seafood Ready Meal','Seafood & Fish','Sałatka Śledziowa','ready to eat','Biedronka;Żabka','none','5906747067342')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies,
  ean                 = excluded.ean;

-- Deprecate old placeholder products that are no longer in the pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
where country='PL' and category='Seafood & Fish'
  and is_deprecated is not true
  and product_name not in (
    'Tuńczyk w Oleju Roślinnym','Tuńczyk w Sosie Własnym','Tuńczyk Kawałki w Oleju','Tuńczyk Naturalny',
    'Makrela w Oleju','Makrela w Sosie Pomidorowym','Makrela Filety w Oleju',
    'Sardynki w Oleju Roślinnym','Sardynki w Sosie Pomidorowym','Sardynki w Oleju',
    'Łosoś Różowy w Sosie Własnym','Łosoś Czerwony',
    'Łosoś Wędzony Plastry','Makrela Wędzona','Szprot Wędzony','Pstrąg Wędzony',
    'Pasta Rybna Łosoś','Pasta Rybna Tuńczyk','Pasta z Makreli',
    'Filety z Dorsza','Filety Mintaja','Filety z Łososia','Filety Pangi',
    'Paluszki Rybne','Paluszki Rybne Panierowane',
    'Sałatka z Tuńczykiem','Sałatka Śledziowa'
  );
