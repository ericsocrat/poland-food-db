-- PIPELINE (Dairy): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-25

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Dairy'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061458047685', '4002671157751', '4061458047692', '4002468084017', '4006402046192', '4032549018105', '4040900117251', '4023600013511', '4061458280334', '40466002', '4036300005311', '4061458047708', '4061458163903', '4002468210454', '4002468210478', '4002566010703', '4061459193312', '4061458229838', '4019300005307', '4008452027602', '4056489012788', '4016241030603', '4061462842986', '4003490323600', '4003751002848', '4002971243703', '4061459193695', '4061462842764', '4016241030917', '4056489216162', '4061458028820', '4046700001806', '4045357004383', '4061462864803', '4006402020413', '4056489013105', '4061458028813', '4002671151353', '4002971243802', '4002468134361', '4061462865015', '4036300005304', '4056489014003', '4002334113032', '4056489118190', '4008452011007', '4061458018531', '4061458005548', '4056489379850', '4061458244404', '4061462843723')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Frischkäse natur', 'fermented', 'Aldi', 'none', '4061458047685'),
  ('DE', 'Gervais', 'Grocery', 'Dairy', 'Hüttenkäse Original', 'fermented', null, 'none', '4002671157751'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Körniger Frischkäse, Halbfettstufe', 'fermented', 'Aldi', 'none', '4061458047692'),
  ('DE', 'Almette', 'Grocery', 'Dairy', 'Almette Kräuter', 'fermented', 'Netto', 'none', '4002468084017'),
  ('DE', 'Bergader', 'Grocery', 'Dairy', 'Bergbauern mild nussig Käse', 'fermented', 'Penny', 'none', '4006402046192'),
  ('DE', 'DOVGAN Family', 'Grocery', 'Dairy', 'Körniger Frischkäse 33 % Fett', 'fermented', 'Lidl', 'none', '4032549018105'),
  ('DE', 'BMI Biobauern', 'Grocery', 'Dairy', 'Bio-Landkäse mild-nussig', 'fermented', 'Lidl', 'none', '4040900117251'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Dairy', 'High Protein Pudding Grieß', 'not-applicable', 'Lidl', 'none', '4023600013511'),
  ('DE', 'Milsan', 'Grocery', 'Dairy', 'Grießpudding High-Protein - Zimt', 'not-applicable', 'Aldi', 'none', '4061458280334'),
  ('DE', 'Milram', 'Grocery', 'Dairy', 'Frühlingsquark Original', 'fermented', 'Lidl', 'none', '40466002'),
  ('DE', 'DMK', 'Grocery', 'Dairy', 'Müritzer original', 'fermented', 'Netto', 'none', '4036300005311'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Körniger Frischkäse - Magerstufe', 'fermented', 'Aldi', 'none', '4061458047708'),
  ('DE', 'AF Deutschland', 'Grocery', 'Dairy', 'Hirtenkäse', 'fermented', 'Aldi', 'none', '4061458163903'),
  ('DE', 'Grünländer', 'Grocery', 'Dairy', 'Grünländer Mild & Nussig', 'fermented', 'Kaufland', 'none', '4002468210454'),
  ('DE', 'Grünländer', 'Grocery', 'Dairy', 'Grünländer Leicht', 'fermented', 'Kaufland', 'none', '4002468210478'),
  ('DE', 'Gazi', 'Grocery', 'Dairy', 'Grill- und Pfannenkäse', 'grilled', 'Kaufland', 'none', '4002566010703'),
  ('DE', 'Bio', 'Grocery', 'Dairy', 'ALDI GUT BIO Milch Frische Bio-Milch 1.5 % Fett Aus der Kühlung 1l 1.15€ Fettarme Milch', 'not-applicable', 'Aldi', 'none', '4061459193312'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'fermented', 'Aldi', 'none', '4061458229838'),
  ('DE', 'Karwendel', 'Grocery', 'Dairy', 'Exquisa Balance Frischkäse', 'fermented', null, 'none', '4019300005307'),
  ('DE', 'Weihenstephan', 'Grocery', 'Dairy', 'H-Milch 3,5%', 'pasteurized', 'Lidl', 'none', '4008452027602'),
  ('DE', 'Milbona', 'Grocery', 'Dairy', 'Skyr', 'fermented', 'Lidl', 'none', '4056489012788'),
  ('DE', 'Arla', 'Grocery', 'Dairy', 'Skyr Natur', 'fermented', 'Kaufland', 'none', '4016241030603'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'H-Vollmilch 3,5 % Fett', 'pasteurized', 'Aldi', 'none', '4061462842986'),
  ('DE', 'Elinas', 'Grocery', 'Dairy', 'Joghurt Griechischer Art', 'fermented', null, 'none', '4003490323600'),
  ('DE', 'Alpenhain', 'Grocery', 'Dairy', 'Obazda klassisch', 'fermented', null, 'none', '4003751002848'),
  ('DE', 'Ehrmann', 'Grocery', 'Dairy', 'High Protein Chocolate Pudding', 'not-applicable', 'Netto', 'none', '4002971243703'),
  ('DE', 'Bio', 'Grocery', 'Dairy', 'Frische Bio-Vollmilch 3,8 % Fett', 'not-applicable', 'Aldi', 'none', '4061459193695'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Haltbare Fettarme Milch', 'not-applicable', 'Aldi', 'none', '4061462842764'),
  ('DE', 'Arla', 'Grocery', 'Dairy', 'Skyr Bourbon Vanille', 'fermented', null, 'none', '4016241030917'),
  ('DE', 'Milbona', 'Grocery', 'Dairy', 'High Protein Chocolate Flavour Pudding', 'not-applicable', 'Lidl', 'none', '4056489216162'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Joghurt mild 3,5 % Fett', 'fermented', 'Aldi', 'none', '4061458028820'),
  ('DE', 'Schwarzwaldmilch', 'Grocery', 'Dairy', 'Protein Milch', 'not-applicable', 'Kaufland', 'none', '4046700001806'),
  ('DE', 'Bresso', 'Grocery', 'Dairy', 'Bresso', 'fermented', 'Netto', 'none', '4045357004383'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Milch', 'not-applicable', 'Aldi', 'none', '4061462864803'),
  ('DE', 'Bergader', 'Grocery', 'Dairy', 'Bavaria Blu', 'fermented', null, 'none', '4006402020413'),
  ('DE', 'Aldi', 'Grocery', 'Dairy', 'Milch, haltbar, 1,5 %, Bio', 'pasteurized', 'Lidl', 'none', '4056489013105'),
  ('DE', 'Aldi', 'Grocery', 'Dairy', 'A/Joghurt mild 3,5% Fett', 'fermented', 'Aldi', 'none', '4061458028813'),
  ('DE', 'Patros', 'Grocery', 'Dairy', 'Patros Natur', 'fermented', null, 'none', '4002671151353'),
  ('DE', 'Ehrmann', 'Grocery', 'Dairy', 'High-Protein-Pudding - Vanilla', 'not-applicable', 'Netto', 'none', '4002971243802'),
  ('DE', 'Patros', 'Grocery', 'Dairy', 'Feta (Schaf- & Ziegenmilch)', 'fermented', 'Kaufland', 'none', '4002468134361'),
  ('DE', 'Milsani', 'Grocery', 'Dairy', 'Frische Vollmilch 3,5%', 'not-applicable', 'Aldi', 'none', '4061462865015'),
  ('DE', 'Milram', 'Grocery', 'Dairy', 'Benjamin', 'fermented', 'Kaufland', 'none', '4036300005304'),
  ('DE', 'Milbona', 'Grocery', 'Dairy', 'Bio Fettarmer Joghurt mild', 'fermented', null, 'none', '4056489014003'),
  ('DE', 'Bauer', 'Grocery', 'Dairy', 'Kirsche', 'fermented', null, 'none', '4002334113032'),
  ('DE', 'Milbona', 'Grocery', 'Dairy', 'Skyr Vanilla', 'fermented', 'Lidl', 'none', '4056489118190'),
  ('DE', 'Weihenstephan', 'Grocery', 'Dairy', 'Joghurt Natur 3,5 % Fett', 'fermented', 'Kaufland', 'none', '4008452011007'),
  ('DE', 'Cucina Nobile', 'Grocery', 'Dairy', 'Mozzarella', 'fermented', 'Aldi', 'none', '4061458018531'),
  ('DE', 'Bio', 'Grocery', 'Dairy', 'Bio-Feta', 'fermented', 'Aldi', 'none', '4061458005548'),
  ('DE', 'Ein gutes Stück Bayern', 'Grocery', 'Dairy', 'Haltbare Bio Vollmilch', 'pasteurized', 'Lidl', 'none', '4056489379850'),
  ('DE', 'Lyttos', 'Grocery', 'Dairy', 'Griechischer Joghurt', 'fermented', 'Aldi', 'none', '4061458244404'),
  ('DE', 'AF Deutschland', 'Grocery', 'Dairy', 'Fettarme Milch (laktosefrei; 1,5% Fett)', 'pasteurized', 'Aldi', 'none', '4061462843723')
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
where country = 'DE' and category = 'Dairy'
  and is_deprecated is not true
  and product_name not in ('Frischkäse natur', 'Hüttenkäse Original', 'Körniger Frischkäse, Halbfettstufe', 'Almette Kräuter', 'Bergbauern mild nussig Käse', 'Körniger Frischkäse 33 % Fett', 'Bio-Landkäse mild-nussig', 'High Protein Pudding Grieß', 'Grießpudding High-Protein - Zimt', 'Frühlingsquark Original', 'Müritzer original', 'Körniger Frischkäse - Magerstufe', 'Hirtenkäse', 'Grünländer Mild & Nussig', 'Grünländer Leicht', 'Grill- und Pfannenkäse', 'ALDI GUT BIO Milch Frische Bio-Milch 1.5 % Fett Aus der Kühlung 1l 1.15€ Fettarme Milch', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'Exquisa Balance Frischkäse', 'H-Milch 3,5%', 'Skyr', 'Skyr Natur', 'H-Vollmilch 3,5 % Fett', 'Joghurt Griechischer Art', 'Obazda klassisch', 'High Protein Chocolate Pudding', 'Frische Bio-Vollmilch 3,8 % Fett', 'Haltbare Fettarme Milch', 'Skyr Bourbon Vanille', 'High Protein Chocolate Flavour Pudding', 'Joghurt mild 3,5 % Fett', 'Protein Milch', 'Bresso', 'Milch', 'Bavaria Blu', 'Milch, haltbar, 1,5 %, Bio', 'A/Joghurt mild 3,5% Fett', 'Patros Natur', 'High-Protein-Pudding - Vanilla', 'Feta (Schaf- & Ziegenmilch)', 'Frische Vollmilch 3,5%', 'Benjamin', 'Bio Fettarmer Joghurt mild', 'Kirsche', 'Skyr Vanilla', 'Joghurt Natur 3,5 % Fett', 'Mozzarella', 'Bio-Feta', 'Haltbare Bio Vollmilch', 'Griechischer Joghurt', 'Fettarme Milch (laktosefrei; 1,5% Fett)');
