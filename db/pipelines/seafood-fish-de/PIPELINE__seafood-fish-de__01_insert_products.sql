-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061458027458', '4061461356569', '4057295250227', '4056489452676', '4061458017367', '4061458016599', '4061458110754', '4006451000312', '4020500920819', '4061458011235', '4061462746543', '4061462633591', '4061458034838', '4061458049474', '4006451000596', '4061462739293', '4061458027489', '4047247687317', '4047247423748', '4061458027533', '4056489237846', '4008366011940', '4030800078943', '4061458017107', '4056489554967', '4061458025188', '4061458043083', '4056489144083', '4009239512298', '4021900008817', '4056489638353', '4061462698781', '4061461758158', '4021900010698', '4064872000250', '4311501715307', '4088500649598', '4056489639992', '4337256782623', '20442484', '4061458024105', '4061458032551', '4061458043090', '4006451000152', '4337256843973', '4021900006561', '4056489919339', '4061458026918', '4061458156165', '4316268643160', '4056489672074')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Aldi', 'Grocery', 'Seafood & Fish', 'ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 'smoked', 'Aldi', 'none', '4061458027458'),
  ('DE', 'Aldi Archiv', 'Grocery', 'Seafood & Fish', 'Räucherlachs Bio', 'smoked', 'Aldi', 'none', '4061461356569'),
  ('DE', 'ArcticFish', 'Grocery', 'Seafood & Fish', 'Pures Grün Räucherlachs', 'smoked', 'Lidl', 'none', '4057295250227'),
  ('DE', 'Lidl', 'Grocery', 'Seafood & Fish', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 'smoked', 'Lidl', 'none', '4056489452676'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Fischstäbchen', 'not-applicable', 'Aldi', 'none', '4061458017367'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 'smoked', 'Aldi', 'none', '4061458016599'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 'smoked', 'Aldi', 'none', '4061458110754'),
  ('DE', 'Krone', 'Grocery', 'Seafood & Fish', 'Räucherlachs', 'smoked', null, 'none', '4006451000312'),
  ('DE', 'Appel', 'Grocery', 'Seafood & Fish', 'Bratheringe in würzigem Aufguss', 'not-applicable', 'Aldi', 'none', '4020500920819'),
  ('DE', 'Aldi', 'Grocery', 'Seafood & Fish', 'Bio-Räucherlachs', 'smoked', 'Aldi', 'none', '4061458011235'),
  ('DE', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 'not-applicable', 'Aldi', 'none', '4061462746543'),
  ('DE', 'Aldi', 'Grocery', 'Seafood & Fish', 'Thunfischfilets in Sonnenblumenöl', 'not-applicable', 'Aldi', 'none', '4061462633591'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Riesengarnelenschwänze - Provencale', 'not-applicable', 'Aldi', 'none', '4061458034838'),
  ('DE', 'Aldi', 'Grocery', 'Seafood & Fish', 'Knusper-Filets - Käse-Kräuter', 'not-applicable', null, 'none', '4061458049474'),
  ('DE', 'Krone Fisch', 'Grocery', 'Seafood & Fish', 'Lachs aus verantwortungsvoller Fischzucht', 'smoked', 'Kaufland', 'none', '4006451000596'),
  ('DE', 'Aldi', 'Grocery', 'Seafood & Fish', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 'not-applicable', 'Aldi', 'none', '4061462739293'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Stremellachs - Pfeffer', 'smoked', 'Aldi', 'none', '4061458027489'),
  ('DE', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Lachs', 'smoked', 'Aldi', 'none', '4047247687317'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Matjes Blister', 'not-applicable', 'Aldi', 'none', '4047247423748'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Stremellachs - Natur', 'smoked', 'Aldi', 'none', '4061458027533'),
  ('DE', 'Ocean sea', 'Grocery', 'Seafood & Fish', 'King Prawns - White Tiger Garnelen', 'not-applicable', 'Lidl', 'none', '4056489237846'),
  ('DE', 'Frosta', 'Grocery', 'Seafood & Fish', 'Backofen Fisch (Knusprig Kross)', 'raw', 'Kaufland', 'none', '4008366011940'),
  ('DE', 'Nordsee', 'Grocery', 'Seafood & Fish', 'Fischfrikadellen', 'not-applicable', 'Lidl', 'none', '4030800078943'),
  ('DE', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Lachsforelle', 'smoked', 'Aldi', 'none', '4061458017107'),
  ('DE', 'Lidl', 'Grocery', 'Seafood & Fish', 'Bio Stremel Lachs', 'not-applicable', 'Lidl', 'none', '4056489554967'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Marinierte Garnelen - Tomate-Chili', 'not-applicable', 'Aldi', 'none', '4061458025188'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Matjesfilets mit Honig-Senf-Sauce', 'not-applicable', 'Aldi', 'none', '4061458043083'),
  ('DE', 'Lidl', 'Grocery', 'Seafood & Fish', 'Smoke Salmon Slices', 'smoked', 'Lidl', 'none', '4056489144083'),
  ('DE', 'Deutsche See GmbH', 'Grocery', 'Seafood & Fish', 'Lachsfilet', 'not-applicable', null, 'none', '4009239512298'),
  ('DE', 'Homann Feinkost', 'Grocery', 'Seafood & Fish', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'not-applicable', 'Lidl', 'none', '4021900008817'),
  ('DE', 'Select & Go', 'Grocery', 'Seafood & Fish', 'Sushi Box', 'not-applicable', 'Lidl', 'none', '4056489638353'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 'not-applicable', 'Aldi', 'none', '4061462698781'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'White-Tiger-Garnelen', 'not-applicable', 'Aldi', 'none', '4061461758158'),
  ('DE', 'Nordsee', 'Grocery', 'Seafood & Fish', 'Backfisch in knuspriger Panade mit Remoulade', 'not-applicable', null, 'none', '4021900010698'),
  ('DE', 'Krone', 'Grocery', 'Seafood & Fish', 'Bio-Lachs', 'smoked', null, 'none', '4064872000250'),
  ('DE', 'Edeka', 'Grocery', 'Seafood & Fish', 'Räucherlachs', 'smoked', null, 'none', '4311501715307'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Wildlachsfilet', 'not-applicable', null, 'none', '4088500649598'),
  ('DE', 'Fischerstolz', 'Grocery', 'Seafood & Fish', 'Frisches Lachsforellen-Filet mit Haut', 'not-applicable', null, 'none', '4056489639992'),
  ('DE', 'REWE Bio', 'Grocery', 'Seafood & Fish', 'Räucherlachs', 'smoked', null, 'none', '4337256782623'),
  ('DE', 'Natürlich für uns', 'Grocery', 'Seafood & Fish', 'Bio Räucherlachs', 'smoked', 'Lidl', 'none', '20442484'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Lachsfilet-Portion mit Haut aus Norwegen', 'not-applicable', null, 'none', '4061458024105'),
  ('DE', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Lachsfilet', 'not-applicable', null, 'none', '4061458032551'),
  ('DE', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Matjesfilets mit Sauce nach Sylter Art', 'not-applicable', null, 'none', '4061458043090'),
  ('DE', 'Krone', 'Grocery', 'Seafood & Fish', 'Kodiak Wildlachs', 'not-applicable', null, 'none', '4006451000152'),
  ('DE', 'Ja!', 'Grocery', 'Seafood & Fish', 'Regenbogenforelle Geräuchert', 'smoked', null, 'none', '4337256843973'),
  ('DE', 'Nadler', 'Grocery', 'Seafood & Fish', 'Alaska Seelachs Mus', 'not-applicable', null, 'none', '4021900006561'),
  ('DE', 'Fischerstolz', 'Grocery', 'Seafood & Fish', 'Bio Lachsfiletportionen', 'not-applicable', null, 'none', '4056489919339'),
  ('DE', 'Almare', 'Grocery', 'Seafood & Fish', 'Shrimps- Salat', 'not-applicable', null, 'none', '4061458026918'),
  ('DE', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Lachsfilet in Cranberry-Chili-Sauce', 'not-applicable', null, 'none', '4061458156165'),
  ('DE', 'Sea Gold', 'Grocery', 'Seafood & Fish', 'Fischstäbchen', 'not-applicable', 'Netto', 'none', '4316268643160'),
  ('DE', 'Fischersolz', 'Grocery', 'Seafood & Fish', 'Norwegische Lachsfiletportionen', 'not-applicable', null, 'none', '4056489672074')
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
where country = 'DE' and category = 'Seafood & Fish'
  and is_deprecated is not true
  and product_name not in ('ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 'Räucherlachs Bio', 'Pures Grün Räucherlachs', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 'Fischstäbchen', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 'Räucherlachs', 'Bratheringe in würzigem Aufguss', 'Bio-Räucherlachs', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 'Thunfischfilets in Sonnenblumenöl', 'Riesengarnelenschwänze - Provencale', 'Knusper-Filets - Käse-Kräuter', 'Lachs aus verantwortungsvoller Fischzucht', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 'Stremellachs - Pfeffer', 'Lachs', 'Matjes Blister', 'Stremellachs - Natur', 'King Prawns - White Tiger Garnelen', 'Backofen Fisch (Knusprig Kross)', 'Fischfrikadellen', 'Lachsforelle', 'Bio Stremel Lachs', 'Marinierte Garnelen - Tomate-Chili', 'Matjesfilets mit Honig-Senf-Sauce', 'Smoke Salmon Slices', 'Lachsfilet', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'Sushi Box', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 'White-Tiger-Garnelen', 'Backfisch in knuspriger Panade mit Remoulade', 'Bio-Lachs', 'Räucherlachs', 'Wildlachsfilet', 'Frisches Lachsforellen-Filet mit Haut', 'Räucherlachs', 'Bio Räucherlachs', 'Lachsfilet-Portion mit Haut aus Norwegen', 'Lachsfilet', 'Matjesfilets mit Sauce nach Sylter Art', 'Kodiak Wildlachs', 'Regenbogenforelle Geräuchert', 'Alaska Seelachs Mus', 'Bio Lachsfiletportionen', 'Shrimps- Salat', 'Lachsfilet in Cranberry-Chili-Sauce', 'Fischstäbchen', 'Norwegische Lachsfiletportionen');
