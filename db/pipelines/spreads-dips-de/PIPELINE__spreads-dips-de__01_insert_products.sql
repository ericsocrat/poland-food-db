-- PIPELINE (Spreads & Dips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-08

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Spreads & Dips'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061461937348', '4058094300021', '4061459397161', '4061459397048', '4061459673012', '4061459397116', '4061458024082', '40466156', '4061462591938', '4061463929853', '4051009041989', '4061462642463', '4061458024068', '4058094300014', '4061458024037', '4063367405440', '4058094300083', '4061461937430', '4067796010831', '4056489550600', '4063367170713', '4056489459545', '4058094310105', '4061461937362', '4056489550617', '4045800719635', '4056489665588', '4061461825140', '4061461937409', '4056489963004', '4061461559175', '4061461568948', '4013182024098', '4056489242079', '4061458023238', '4061461825225', '4045800505269', '4063367146978', '4056489456544', '4051009026733', '4061461825263', '4056489459514', '4061461825249', '4006495162700', '4051009035636', '4047247622004', '4061459397062', '4056489008170', '4058094300113', '4001242108239', '4001242108222')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Spreads & Dips by pipeline',
    ean = null
where country = 'DE'
  and category != 'Spreads & Dips'
  and identity_key in ('01251f0671e0c48071fba2456559ec2b', '043bf60fbbc572b5edb4caca2ccf9fcb', '05996c149496e85c3f07a321abf02857', '062db50fdc1242c5909b0f834b99ebb7', '0a36aaecfcade06d1695adaeb4f65aa6', '0d646c9e182e7db04b9145b0a339026b', '154a9a7d93f251843eda1d311d71658e', '15ed4ddf7928224eb7f4569f1c5dc32f', '18657ec7223331382f054557ccc61244', '1969f38f91e6b5526735a5680dc7f56d', '228bb86461b16f44614be173b7b57945', '25ff210993ccbd9433328f1967a7e66f', '2987224f0671ba26dc191b296a110f98', '3185f027246e56e5555f8b941c6ca956', '408b4aad43a395cc2d0b4c1f33629085', '4b079e9adc55872d70e54c99001d9d5a', '5629d15fe758091a6be9ad58262d176c', '5af091d27f1ae17d2d90fd53bf683bf3', '5f002af01052925d9b43ac3fcd815bf3', '5f97d67d86e7a105e6d11b5821650cf4', '62788ba6f45ff562f1bd29c01e280955', '6510f491bdc592ce0118b93dfc5f7d95', '70fe1e7d6251fe21d812f7f9d0429ab7', '72e0f55edf28fdca602ee5894178fd6c', '74d0eb77fba242c3bc40767f3ae4d189', '7586c845aaadcd9da2aa14fba32e581e', '75b1d769fe5c703e64541e5620b5a9c8', '7af35fb71df22defc710427d98fd20f8', '7dba3ef0cb957b888c937b3c67c256f7', '98137e09656b3373c2a7cdd13945888f', 'ab85f582926cb062f5b018bd7cf52d22', 'ac4a17fe5c0ad618d2963a4652854b5b', 'b082e21285cf6dbac2eb3441b227debd', 'b2eaf9a19ce449edcde5808e06740b76', 'be1f6faaf58173e22c844ba2e618223f', 'bebcfad118a83cd4419fc642be98e6c7', 'bf2954620252e349fbf217b5eddfca49', 'c45df460b8425fee3d6110e0a54b74cc', 'c88efa44d437cf548153b97a123b0345', 'c9dc3dc92536e9e263f5a3aa3d2ec852', 'd0caf278b8bb1f1db807383e88872f88', 'd4ed5ce14b671ed06e984dc15a05e40a', 'd8d855bfd73a68c14f676205870da392', 'da9f64b28635fc7b43c1c56edfe3908a', 'f329823434ba86db7fa990ea18108dce', 'f4e2aa775a125fdc670c7f1f54368c13', 'f6086773fc2e80734876e2e5120a947d', 'fbb84fe79190e6a5027fd6ef6f22070e', 'fcd52273f44439b8b27d6ebeaaff95fb', 'fe065bc2fef0bd6e51638bd37d6b8c4c', 'fed8125ba1a734177461e15d97671a55')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Vegane Bio-Streichcreme - Kräuter-Tomate', 'not-applicable', 'Aldi', 'none', '4061461937348'),
  ('DE', 'Noa', 'Grocery', 'Spreads & Dips', 'Noa Brotaufstrich Hummus Kräuter', 'not-applicable', null, 'none', '4058094300021'),
  ('DE', 'Lyttos', 'Grocery', 'Spreads & Dips', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 'not-applicable', 'Aldi', 'none', '4061459397161'),
  ('DE', 'Lyttos', 'Grocery', 'Spreads & Dips', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 'not-applicable', 'Aldi', 'none', '4061459397048'),
  ('DE', 'Unknown', 'Grocery', 'Spreads & Dips', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 'not-applicable', 'Aldi', 'none', '4061459673012'),
  ('DE', 'Lyttos', 'Grocery', 'Spreads & Dips', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 'not-applicable', 'Aldi', 'none', '4061459397116'),
  ('DE', 'Menken Salades & Sauzen', 'Grocery', 'Spreads & Dips', 'Hummus - Kürbis', 'not-applicable', 'Aldi', 'none', '4061458024082'),
  ('DE', 'Milram', 'Grocery', 'Spreads & Dips', 'Fein-würzige Sour Cream', 'not-applicable', null, 'none', '40466156'),
  ('DE', 'BLM', 'Grocery', 'Spreads & Dips', 'Bruschetta-Creme mit Paprika und Ricottakäse', 'not-applicable', null, 'none', '4061462591938'),
  ('DE', 'Sun Snacks', 'Grocery', 'Spreads & Dips', 'Salsa Dip Käse', 'not-applicable', null, 'none', '4061463929853'),
  ('DE', 'Kühlmann', 'Grocery', 'Spreads & Dips', 'Kichererbsenpüree', 'not-applicable', null, 'none', '4051009041989'),
  ('DE', 'W', 'Grocery', 'Spreads & Dips', 'Bio Hummus - Kichererbsenpüree mit Sesam und rotem Pesto', 'not-applicable', null, 'none', '4061462642463'),
  ('DE', 'Schätze des Orients', 'Grocery', 'Spreads & Dips', 'Hummus Natur', 'not-applicable', 'Aldi', 'none', '4061458024068'),
  ('DE', 'NOA', 'Grocery', 'Spreads & Dips', 'Hummus , Natur', 'not-applicable', 'Kaufland', 'none', '4058094300014'),
  ('DE', 'Heinrich Kuhmann GmbH', 'Grocery', 'Spreads & Dips', 'Hummus - Pikant', 'not-applicable', 'Aldi', 'none', '4061458024037'),
  ('DE', 'K Bio (Kaufland)', 'Grocery', 'Spreads & Dips', 'Bio Hummus Classic', 'not-applicable', 'Kaufland', 'none', '4063367405440'),
  ('DE', 'Noa', 'Grocery', 'Spreads & Dips', 'Hummus Paprika-Chili', 'not-applicable', 'Lidl', 'none', '4058094300083'),
  ('DE', 'My Vay', 'Grocery', 'Spreads & Dips', 'Bio Streichcreme', 'not-applicable', 'Aldi', 'none', '4061461937430'),
  ('DE', 'DmBio', 'Grocery', 'Spreads & Dips', 'Hummus Natur', 'not-applicable', null, 'none', '4067796010831'),
  ('DE', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Bio Hummus Natur', 'not-applicable', 'Lidl', 'none', '4056489550600'),
  ('DE', 'Kaufland', 'Grocery', 'Spreads & Dips', 'Veganer Hummus Classic', 'not-applicable', 'Kaufland', 'none', '4063367170713'),
  ('DE', 'Deluxe', 'Grocery', 'Spreads & Dips', 'Hummus und Guacamole', 'not-applicable', 'Lidl', 'none', '4056489459545'),
  ('DE', 'Noa', 'Grocery', 'Spreads & Dips', 'Brotaufstrich Kichererbse Tomate-Basilikum', 'not-applicable', null, 'none', '4058094310105'),
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Vegane Bio-Streichcreme - Aubergine', 'not-applicable', 'Aldi', 'none', '4061461937362'),
  ('DE', 'Chef select', 'Grocery', 'Spreads & Dips', 'Bio organic humus', 'not-applicable', 'Lidl', 'none', '4056489550617'),
  ('DE', 'Feinkost Popp', 'Grocery', 'Spreads & Dips', 'Hummus Klassisch', 'not-applicable', null, 'none', '4045800719635'),
  ('DE', 'Milbona', 'Grocery', 'Spreads & Dips', 'Zaziki', 'fermented', 'Lidl', 'none', '4056489665588'),
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Bio-Hummus - Natur', 'not-applicable', 'Aldi', 'none', '4061461825140'),
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 'not-applicable', 'Aldi', 'none', '4061461937409'),
  ('DE', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Guacamole scharf', 'not-applicable', 'Lidl', 'none', '4056489963004'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Spreads & Dips', 'Bio Humus Paprika Kurkuma Chili', 'not-applicable', 'Aldi', 'none', '4061461559175'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Spreads & Dips', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 'not-applicable', 'Aldi', 'none', '4061461568948'),
  ('DE', 'Nabio', 'Grocery', 'Spreads & Dips', 'Gegrillte Paprika Cashew', 'not-applicable', null, 'none', '4013182024098'),
  ('DE', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Guacamole Avocado-Dip mild', 'not-applicable', 'Lidl', 'none', '4056489242079'),
  ('DE', 'Wonnemeyer', 'Grocery', 'Spreads & Dips', 'Antipasticreme - Feta', 'not-applicable', 'Aldi', 'none', '4061458023238'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Spreads & Dips', 'Bio-Hummus - Tomate', 'not-applicable', 'Aldi', 'none', '4061461825225'),
  ('DE', 'Popp', 'Grocery', 'Spreads & Dips', 'Brotaufstrich Bruschetta', 'not-applicable', null, 'none', '4045800505269'),
  ('DE', 'Kaufland', 'Grocery', 'Spreads & Dips', 'Guacamole', 'not-applicable', 'Kaufland', 'none', '4063367146978'),
  ('DE', 'Chef select', 'Grocery', 'Spreads & Dips', 'Hummus Nature', 'not-applicable', 'Lidl', 'none', '4056489456544'),
  ('DE', 'Kühlmann', 'Grocery', 'Spreads & Dips', 'Hummus Trio', 'not-applicable', null, 'none', '4051009026733'),
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Bio-Hummus - Rote Beete', 'not-applicable', 'Aldi', 'none', '4061461825263'),
  ('DE', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Hummus bruschetta', 'not-applicable', 'Lidl', 'none', '4056489459514'),
  ('DE', 'Aldi', 'Grocery', 'Spreads & Dips', 'Bio-Hummus - Paprika', 'not-applicable', 'Aldi', 'none', '4061461825249'),
  ('DE', 'Grossmann', 'Grocery', 'Spreads & Dips', 'Knoblauch-Dip', 'not-applicable', null, 'none', '4006495162700'),
  ('DE', 'Kaufland', 'Grocery', 'Spreads & Dips', 'Hummus mit Topping Grünes Pesto', 'not-applicable', null, 'none', '4051009035636'),
  ('DE', 'Wonnemeyer', 'Grocery', 'Spreads & Dips', 'Antipasticreme - Dattel-Curry', 'not-applicable', 'Aldi', 'none', '4047247622004'),
  ('DE', 'Lyttos', 'Grocery', 'Spreads & Dips', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 'not-applicable', 'Aldi', 'none', '4061459397062'),
  ('DE', 'Chef Select', 'Grocery', 'Spreads & Dips', 'Kirschpaprika Antipasti-Creme', 'not-applicable', 'Lidl', 'none', '4056489008170'),
  ('DE', 'Noa', 'Grocery', 'Spreads & Dips', 'Hummus Dattel Curry', 'not-applicable', null, 'none', '4058094300113'),
  ('DE', 'Chio', 'Grocery', 'Spreads & Dips', 'Hot Cheese Dip!', 'not-applicable', null, 'none', '4001242108239'),
  ('DE', 'Chio', 'Grocery', 'Spreads & Dips', 'Chip dip', 'not-applicable', null, 'none', '4001242108222')
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
where country = 'DE' and category = 'Spreads & Dips'
  and is_deprecated is not true
  and product_name not in ('Vegane Bio-Streichcreme - Kräuter-Tomate', 'Noa Brotaufstrich Hummus Kräuter', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 'Hummus - Kürbis', 'Fein-würzige Sour Cream', 'Bruschetta-Creme mit Paprika und Ricottakäse', 'Salsa Dip Käse', 'Kichererbsenpüree', 'Bio Hummus - Kichererbsenpüree mit Sesam und rotem Pesto', 'Hummus Natur', 'Hummus , Natur', 'Hummus - Pikant', 'Bio Hummus Classic', 'Hummus Paprika-Chili', 'Bio Streichcreme', 'Hummus Natur', 'Bio Hummus Natur', 'Veganer Hummus Classic', 'Hummus und Guacamole', 'Brotaufstrich Kichererbse Tomate-Basilikum', 'Vegane Bio-Streichcreme - Aubergine', 'Bio organic humus', 'Hummus Klassisch', 'Zaziki', 'Bio-Hummus - Natur', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 'Guacamole scharf', 'Bio Humus Paprika Kurkuma Chili', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 'Gegrillte Paprika Cashew', 'Guacamole Avocado-Dip mild', 'Antipasticreme - Feta', 'Bio-Hummus - Tomate', 'Brotaufstrich Bruschetta', 'Guacamole', 'Hummus Nature', 'Hummus Trio', 'Bio-Hummus - Rote Beete', 'Hummus bruschetta', 'Bio-Hummus - Paprika', 'Knoblauch-Dip', 'Hummus mit Topping Grünes Pesto', 'Antipasticreme - Dattel-Curry', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 'Kirschpaprika Antipasti-Creme', 'Hummus Dattel Curry', 'Hot Cheese Dip!', 'Chip dip');
