-- PIPELINE (Frozen & Prepared): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Frozen & Prepared'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4008366001484', '4008366010387', '4008366008582', '4008366009961', '4008366006915', '4008366001347', '4061458128407', '4009233014347', '4061463214911', '4001724011118', '4008366015535', '4008366010981', '4008366006953', '4008366009336', '4008366010042', '4061458034807', '4056489289241', '4008366011964', '4008366883448', '4008366001309', '4008366003587', '4009233006847', '4008366883301', '4001724038993', '4008366015337', '4001724049906', '4009233003952', '4001724015420', '4056489456476', '4008366009787', '4008366015511', '4001724038597', '4009233003655', '4001724011057', '4001724038900', '4056489451044', '4001724011170', '4008366009763', '4001724040538', '4061463213211', '4009233003587', '4001724027195', '4061458042192', '4008366000500', '4001724038658', '4001724039389', '4061462826344', '4009233003921', '4061458041942', '4061458011228', '4056489456483')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Bratkartoffel Hähnchen Pfanne', 'not-applicable', 'Kaufland', 'none', '4008366001484'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Fischstäbchen ( Frosta)', 'not-applicable', 'Kaufland', 'none', '4008366010387'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Hühnerfrikassee', 'not-applicable', 'Lidl', 'none', '4008366008582'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Tortellini Käse-Sahne (vegetarisch)', 'not-applicable', null, 'none', '4008366009961'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Gemüse Pfanne alla Toscana', 'not-applicable', null, 'none', '4008366006915'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Hähnchen Curry', 'not-applicable', 'Kaufland', 'none', '4008366001347'),
  ('DE', 'Speisezeit', 'Grocery', 'Frozen & Prepared', 'Süßkartoffel-Pommes', 'fried', 'Aldi', 'none', '4061458128407'),
  ('DE', 'Original Wagner', 'Grocery', 'Frozen & Prepared', 'Piccolinis Drei-Käse Pizza', 'not-applicable', null, 'none', '4009233014347'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Frozen & Prepared', 'Bio-Dinkel-Steinofenpizza - Grillgemüse', 'not-applicable', 'Aldi', 'none', '4061463214911'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Die Ofenfrische Vier Käse', 'not-applicable', null, 'none', '4001724011118'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Wildlachs in Kräuterrahm', 'not-applicable', null, 'none', '4008366015535'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Paprika Sahne Hähnchen mit Bandnudeln', 'not-applicable', null, 'none', '4008366010981'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Gemüsepfanne a la Provence', 'not-applicable', null, 'none', '4008366006953'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Gemüse Pfanne Style Asia Curry', 'fried', null, 'none', '4008366009336'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Reis Hähnchen Pfanne', 'not-applicable', null, 'none', '4008366010042'),
  ('DE', 'Golden Seafood', 'Grocery', 'Frozen & Prepared', 'Riesengarnelenschwänze - Natur', 'not-applicable', null, 'none', '4061458034807'),
  ('DE', 'Freshona', 'Grocery', 'Frozen & Prepared', 'Gemüsepfanne Bio Mediterrane Art', 'not-applicable', null, 'none', '4056489289241'),
  ('DE', 'Frost', 'Grocery', 'Frozen & Prepared', 'Pfannenfisch Müllerin Art', 'not-applicable', null, 'none', '4008366011964'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Gemüse-Bowl - Pikanter Bulgur mit schwarzen Bohnen', 'not-applicable', null, 'none', '4008366883448'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Bami Goreng', 'not-applicable', 'Kaufland', 'none', '4008366001309'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Butter Chicken', 'not-applicable', null, 'none', '4008366003587'),
  ('DE', 'Original Wagner', 'Grocery', 'Frozen & Prepared', 'Pizza Die Backfrische Mozzarella', 'not-applicable', null, 'none', '4009233006847'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Nice Rice - Korean Style', 'not-applicable', null, 'none', '4008366883301'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Ristorante PIZZA TONNO', 'not-applicable', 'Penny', 'none', '4001724038993'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Paella', 'not-applicable', 'Kaufland', 'none', '4008366015337'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Suprema Pizza Calabrese & ''Nduja', 'not-applicable', null, 'none', '4001724049906'),
  ('DE', 'Original Wagner', 'Grocery', 'Frozen & Prepared', 'Steinofen-Pizza Mozzarella Vegetarisch', 'not-applicable', 'Lidl', 'none', '4009233003952'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Die Ofenfrische Margherita', 'not-applicable', null, 'none', '4001724015420'),
  ('DE', 'Greenyard Frozen Langemark', 'Grocery', 'Frozen & Prepared', 'Buckwheat & broccoli', 'not-applicable', 'Lidl', 'none', '4056489456476'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Fisch Schlemmerfilet Mediterraner Art', 'not-applicable', null, 'none', '4008366009787'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Fettuccine Wildlachs', 'not-applicable', null, 'none', '4008366015511'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza Tradizionale Margherita', 'not-applicable', null, 'none', '4001724038597'),
  ('DE', 'Original Wagner', 'Grocery', 'Frozen & Prepared', 'Steinofen-Pizza - Diavolo', 'not-applicable', 'Netto', 'none', '4009233003655'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Die Ofenfrische Speciale', 'not-applicable', 'Netto', 'none', '4001724011057'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza Salame Ristorante', 'not-applicable', 'Lidl', 'none', '4001724038900'),
  ('DE', 'Vemondo', 'Grocery', 'Frozen & Prepared', 'Vegan pizza Verdura', 'not-applicable', 'Lidl', 'none', '4056489451044'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Die Ofenfrische Salami', 'not-applicable', 'Lidl', 'none', '4001724011170'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Fisch Schlemmerfilet Brokkoli Mandel', 'not-applicable', null, 'none', '4008366009763'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'La Mia Grande Rucola', 'not-applicable', null, 'none', '4001724040538'),
  ('DE', 'GiaPizza', 'Grocery', 'Frozen & Prepared', 'Bio-Dinkel-Steinofenpizza - Spinat', 'not-applicable', 'Aldi', 'none', '4061463213211'),
  ('DE', 'Nestlé', 'Grocery', 'Frozen & Prepared', 'Pizza Speciale', 'not-applicable', 'Netto', 'none', '4009233003587'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'La Mia Grande Pizza Margherita', 'not-applicable', null, 'none', '4001724027195'),
  ('DE', 'Speise Zeit', 'Grocery', 'Frozen & Prepared', 'Wellenschnitt Pommes', 'fried', 'Aldi', 'none', '4061458042192'),
  ('DE', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Nom Nom Noodles', 'not-applicable', null, 'none', '4008366000500'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza Traditionale Verdure Grigliate', 'not-applicable', null, 'none', '4001724038658'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Ristorante Pizza Pasta', 'not-applicable', null, 'none', '4001724039389'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Frozen & Prepared', 'Bio-Eiscreme - Vanille', 'not-applicable', 'Aldi', 'none', '4061462826344'),
  ('DE', 'Nestlé', 'Grocery', 'Frozen & Prepared', 'Steinofen-Pizza Thunfisch', 'not-applicable', null, 'none', '4009233003921'),
  ('DE', 'Aldi', 'Grocery', 'Frozen & Prepared', 'Pommes Frites', 'fried', 'Aldi', 'none', '4061458041942'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen & Prepared', 'Rahm-Spinat', 'not-applicable', 'Aldi', 'none', '4061458011228'),
  ('DE', 'Vemondo', 'Grocery', 'Frozen & Prepared', 'Pumpkin & quinoa', 'not-applicable', 'Lidl', 'none', '4056489456483')
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
where country = 'DE' and category = 'Frozen & Prepared'
  and is_deprecated is not true
  and product_name not in ('Bratkartoffel Hähnchen Pfanne', 'Fischstäbchen ( Frosta)', 'Hühnerfrikassee', 'Tortellini Käse-Sahne (vegetarisch)', 'Gemüse Pfanne alla Toscana', 'Hähnchen Curry', 'Süßkartoffel-Pommes', 'Piccolinis Drei-Käse Pizza', 'Bio-Dinkel-Steinofenpizza - Grillgemüse', 'Die Ofenfrische Vier Käse', 'Wildlachs in Kräuterrahm', 'Paprika Sahne Hähnchen mit Bandnudeln', 'Gemüsepfanne a la Provence', 'Gemüse Pfanne Style Asia Curry', 'Reis Hähnchen Pfanne', 'Riesengarnelenschwänze - Natur', 'Gemüsepfanne Bio Mediterrane Art', 'Pfannenfisch Müllerin Art', 'Gemüse-Bowl - Pikanter Bulgur mit schwarzen Bohnen', 'Bami Goreng', 'Butter Chicken', 'Pizza Die Backfrische Mozzarella', 'Nice Rice - Korean Style', 'Ristorante PIZZA TONNO', 'Paella', 'Suprema Pizza Calabrese & ''Nduja', 'Steinofen-Pizza Mozzarella Vegetarisch', 'Die Ofenfrische Margherita', 'Buckwheat & broccoli', 'Fisch Schlemmerfilet Mediterraner Art', 'Fettuccine Wildlachs', 'Pizza Tradizionale Margherita', 'Steinofen-Pizza - Diavolo', 'Die Ofenfrische Speciale', 'Pizza Salame Ristorante', 'Vegan pizza Verdura', 'Die Ofenfrische Salami', 'Fisch Schlemmerfilet Brokkoli Mandel', 'La Mia Grande Rucola', 'Bio-Dinkel-Steinofenpizza - Spinat', 'Pizza Speciale', 'La Mia Grande Pizza Margherita', 'Wellenschnitt Pommes', 'Nom Nom Noodles', 'Pizza Traditionale Verdure Grigliate', 'Ristorante Pizza Pasta', 'Bio-Eiscreme - Vanille', 'Steinofen-Pizza Thunfisch', 'Pommes Frites', 'Rahm-Spinat', 'Pumpkin & quinoa');
