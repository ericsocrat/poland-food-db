-- PIPELINE (NUTS-SEEDS): insert products
-- PIPELINE__nuts-seeds__01_insert_products.sql
-- 28 products from the Polish market (EANs removed - unverifiable).
-- Data sourced from Open Food Facts (openfoodfacts.org).
-- Last updated: 2026-02-08
-- NOTE: EAN codes removed on 2026-02-08 due to 37% checksum failure rate (10/27 invalid) and inability to verify via Open Food Facts

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
-- ── ALESTO / Lidl (raw & roasted nuts) ─────────────────────────────────
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Migdały','ready to eat','Lidl','none'),
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Nerkowca','ready to eat','Lidl','none'),
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Włoskie','ready to eat','Lidl','none'),
('PL','Alesto','Raw Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Laskowe','ready to eat','Lidl','none'),
('PL','Alesto','Roasted Nuts','Nuts, Seeds & Legumes','Alesto Migdały Prażone Solone','roasted','Lidl','none'),
('PL','Alesto','Roasted Nuts','Nuts, Seeds & Legumes','Alesto Orzechy Nerkowca Prażone Solone','roasted','Lidl','none'),

-- ── SANTE (seeds & health foods) ───────────────────────────────────────
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Nasiona Słonecznika','ready to eat','Biedronka;Lidl;Carrefour','none'),
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Pestki Dyni','ready to eat','Biedronka;Lidl;Carrefour','none'),
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Nasiona Chia','ready to eat','Biedronka;Lidl;Carrefour','none'),
('PL','Sante','Seeds','Nuts, Seeds & Legumes','Sante Siemię Lniane','ready to eat','Biedronka;Lidl;Carrefour','none'),

-- ── HELIO / Maspex (nut butters) ───────────────────────────────────────
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Orzechowe Naturalne','ready to eat','Biedronka;Lidl;Żabka','none'),
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Orzechowe Kremowe','ready to eat','Biedronka;Lidl;Żabka','none'),
('PL','Helio','Nut Butter','Nuts, Seeds & Legumes','Helio Masło Migdałowe','ready to eat','Biedronka;Lidl','none'),

-- ── NATURAVENA (legumes & seeds) ───────────────────────────────────────
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Soczewica Czerwona','requires cooking','Biedronka;Carrefour','none'),
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Soczewica Zielona','requires cooking','Biedronka;Carrefour','none'),
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Ciecierzyca','requires cooking','Biedronka;Carrefour','none'),
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Fasola Biała','requires cooking','Biedronka;Carrefour','none'),
('PL','Naturavena','Dried Legumes','Nuts, Seeds & Legumes','Naturavena Fasola Czerwona','requires cooking','Biedronka;Carrefour','none'),

-- ── FASTING (nuts & seeds) ─────────────────────────────────────────────
('PL','Fasting','Roasted Nuts','Nuts, Seeds & Legumes','Fasting Orzeszki Ziemne Solone','roasted','Biedronka;Lidl;Carrefour;Żabka','none'),
('PL','Fasting','Roasted Nuts','Nuts, Seeds & Legumes','Fasting Migdały Prażone','roasted','Biedronka;Lidl;Carrefour','none'),

-- ── BAKALLAND (premium nuts & seeds) ───────────────────────────────────
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Orzechy Włoskie','ready to eat','Biedronka;Carrefour;Lidl','none'),
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Migdały','ready to eat','Biedronka;Carrefour;Lidl','none'),
('PL','Bakalland','Raw Nuts','Nuts, Seeds & Legumes','Bakalland Orzechy Laskowe','ready to eat','Biedronka;Carrefour;Lidl','none'),

-- ── TARGROCH (seeds specialist) ────────────────────────────────────────
('PL','Targroch','Seeds','Nuts, Seeds & Legumes','Targroch Pestki Dyni Prażone Solone','roasted','Carrefour;Auchan','none'),
('PL','Targroch','Seeds','Nuts, Seeds & Legumes','Targroch Nasiona Słonecznika Prażone','roasted','Carrefour;Auchan','none'),

-- ── SPOŁEM (cooperative legumes) ───────────────────────────────────────
('PL','Społem','Dried Legumes','Nuts, Seeds & Legumes','Społem Fasola Jaś','requires cooking','Biedronka;Carrefour','none'),
('PL','Społem','Dried Legumes','Nuts, Seeds & Legumes','Społem Soczewica Brązowa','requires cooking','Biedronka;Carrefour','none')

on conflict (country, brand, product_name)
do update set
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies;

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

