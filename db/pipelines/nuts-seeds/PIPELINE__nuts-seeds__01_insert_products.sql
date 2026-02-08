-- PIPELINE (NUTS-SEEDS): insert products
-- PIPELINE__nuts-seeds__01_insert_products.sql
-- 28 verified products from the Polish market.
-- Data sourced from Open Food Facts (openfoodfacts.org) — EANs verified.
-- Last updated: 2026-02-08

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
-- ── ALESTO / Lidl (raw & roasted nuts) ─────────────────────────────────
-- EAN 4056489444701 — Alesto Migdały (raw almonds, NOVA 1)
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Migdały','ready to eat','Lidl','none','4056489444701'),
-- EAN 4056489443862 — Alesto Orzechy Nerkowca (raw cashews, NOVA 1)
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Nerkowca','ready to eat','Lidl','none','4056489443862'),
-- EAN 4056489304920 — Alesto Orzechy Włoskie (raw walnuts, NOVA 1)
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Włoskie','ready to eat','Lidl','none','4056489304920'),
-- EAN 4056489488415 — Alesto Orzechy Laskowe (raw hazelnuts, NOVA 1)
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Laskowe','ready to eat','Lidl','none','4056489488415'),
-- EAN 4056489267126 — Alesto Migdały Prażone Solone (roasted salted almonds, NOVA 3)
('PL','Alesto','Roasted Nuts','Nuts, Seeds & Legumes','Alesto Migdały Prażone Solone','roasted','Lidl','none','4056489267126'),
-- EAN 4056489443848 — Alesto Orzechy Nerkowca Prażone Solone (roasted salted cashews, NOVA 3)
('PL','Alesto','Roasted Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Nerkowca Prażone Solone','roasted','Lidl','none','4056489443848'),

-- ── SANTE (seeds & health foods) ───────────────────────────────────────
-- EAN 5900617002440 — Sante Nasiona Słonecznika (raw sunflower seeds, NOVA 1)
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Nasiona Słonecznika','ready to eat','Biedronka;Lidl;Carrefour','none','5900617002440'),
-- EAN 5900617003874 — Sante Pestki Dyni (raw pumpkin seeds, NOVA 1)
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Pestki Dyni','ready to eat','Biedronka;Lidl;Carrefour','none','5900617003874'),
-- EAN 5900617052278 — Sante Nasiona Chia (chia seeds, NOVA 1)
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Nasiona Chia','ready to eat','Biedronka;Lidl;Carrefour','none','5900617052278'),
-- EAN 5900617049087 — Sante Siemię Lniane (flax seeds, NOVA 1)
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Siemię Lniane','ready to eat','Biedronka;Lidl;Carrefour','none','5900617049087'),

-- ── HELIO / Maspex (nut butters) ───────────────────────────────────────
-- EAN 5900073021863 — Helio Masło Orzechowe Naturalne (peanut butter, NOVA 3)
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Orzechowe Naturalne','ready to eat','Biedronka;Lidl;Żabka','none','5900073021863'),
-- EAN 5900073022112 — Helio Masło Orzechowe Kremowe (creamy peanut butter with salt/sugar, NOVA 3)
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Orzechowe Kremowe','ready to eat','Biedronka;Lidl;Żabka','none','5900073022112'),
-- EAN 5900073063256 — Helio Masło Migdałowe (almond butter, NOVA 3)
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Migdałowe','ready to eat','Biedronka;Lidl','none','5900073063256'),

-- ── NATURAVENA (legumes & seeds) ───────────────────────────────────────
-- EAN 5907568710397 — Naturavena Soczewica Czerwona (red lentils, NOVA 1)
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Soczewica Czerwona','requires cooking','Biedronka;Carrefour','none','5907568710397'),
-- EAN 5907568710403 — Naturavena Soczewica Zielona (green lentils, NOVA 1)
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Soczewica Zielona','requires cooking','Biedronka;Carrefour','none','5907568710403'),
-- EAN 5907568710380 — Naturavena Ciecierzyca (chickpeas, NOVA 1)
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Ciecierzyca','requires cooking','Biedronka;Carrefour','none','5907568710380'),
-- EAN 5907568710373 — Naturavena Fasola Biała (white beans, NOVA 1)
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Fasola Biała','requires cooking','Biedronka;Carrefour','none','5907568710373'),
-- EAN 5907568710366 — Naturavena Fasola Czerwona (red kidney beans, NOVA 1)
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Fasola Czerwona','requires cooking','Biedronka;Carrefour','none','5907568710366'),

-- ── FASTING (nuts & seeds) ─────────────────────────────────────────────
-- EAN 5907222040553 — Fasting Orzeszki Ziemne Solone (salted roasted peanuts, NOVA 3)
('PL','Fasting','Roasted Nuts','Nuts, Seeds & Legumes','Fasting Orzeszki Ziemne Solone','roasted','Biedronka;Lidl;Carrefour;Żabka','none','5907222040553'),
-- EAN 5907222040577 — Fasting Migdały Prażone (roasted almonds, NOVA 3)
('PL','Fasting','Roasted Nuts','Nuts, Seeds & Legumes','Fasting Migdały Prażone','roasted','Biedronka;Lidl;Carrefour','none','5907222040577'),

-- ── BAKALLAND (premium nuts & seeds) ───────────────────────────────────
-- EAN 5900073021658 — Bakalland Orzechy Włoskie (raw walnuts, NOVA 1)
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Orzechy Włoskie','ready to eat','Biedronka;Carrefour;Lidl','none','5900073021658'),
-- EAN 5900073020866 — Bakalland Migdały (raw almonds, NOVA 1)
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Migdały','ready to eat','Biedronka;Carrefour;Lidl','none','5900073020866'),
-- EAN 5900073022228 — Bakalland Orzechy Laskowe (raw hazelnuts, NOVA 1)
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Orzechy Laskowe','ready to eat','Biedronka;Carrefour;Lidl','none','5900073022228'),

-- ── TARGROCH (seeds specialist) ────────────────────────────────────────
-- EAN 5900672151381 — Targroch Pestki Dyni Prażone Solone (roasted salted pumpkin seeds, NOVA 3)
('PL','Targroch','Seeds','Nuts, Seeds & Legumes','Targroch Pestki Dyni Prażone Solone','roasted','Carrefour;Auchan','none','5900672151381'),
-- EAN 5900672151374 — Targroch Nasiona Słonecznika Prażone (roasted sunflower seeds, NOVA 3)
('PL','Targroch','Seeds','Nuts, Seeds & Legumes','Targroch Nasiona Słonecznika Prażone','roasted','Carrefour;Auchan','none','5900672151374'),

-- ── SPOŁEM (cooperative legumes) ───────────────────────────────────────
-- EAN 5901044003481 — Społem Fasola Jaś (large white beans, NOVA 1)
('PL','Społem','Dried Legumes','Nuts, Seeds & Legumes','Społem Fasola Jaś','requires cooking','Biedronka;Carrefour','none','5901044003481'),
-- EAN 5901044003467 — Soczewica Brązowa (brown lentils, NOVA 1)
('PL','Społem','Dried Legumes','Nuts, Seeds & Legumes','Społem Soczewica Brązowa','requires cooking','Biedronka;Carrefour','none','5901044003467')

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
where country='PL' and category='Nuts, Seeds & Legumes'
  and is_deprecated is not true
  and product_name not in (
    'Alesto Migdały','Alesto Orzechy Nerkowca','Alesto Orzechy Włoskie','Alesto Orzechy Laskowe',
    'Alesto Migdały Prażone Solone','Alesto Orzechy Nerkowca Prażone Solone',
    'Sante Nasiona Słonecznika','Sante Pestki Dyni','Sante Nasiona Chia','Sante Siemię Lniane',
    'Helio Masło Orzechowe Naturalne','Helio Masło Orzechowe Kremowe','Helio Masło Migdałowe',
    'Naturavena Soczewica Czerwona','Naturavena Soczewica Zielona','Naturavena Ciecierzyca',
    'Naturavena Fasola Biała','Naturavena Fasola Czerwona',
    'Fasting Orzeszki Ziemne Solone','Fasting Migdały Prażone',
    'Bakalland Orzechy Włoskie','Bakalland Migdały','Bakalland Orzechy Laskowe',
    'Targroch Pestki Dyni Prażone Solone','Targroch Nasiona Słonecznika Prażone',
    'Społem Fasola Jaś','Społem Soczewica Brązowa'
  );
