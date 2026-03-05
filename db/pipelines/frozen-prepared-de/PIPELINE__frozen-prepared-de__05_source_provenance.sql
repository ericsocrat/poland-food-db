-- PIPELINE (Frozen & Prepared): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Frosta', 'Bratkartoffel Hähnchen Pfanne', 'https://world.openfoodfacts.org/product/4008366001484', '4008366001484'),
    ('Frosta', 'Fischstäbchen ( Frosta)', 'https://world.openfoodfacts.org/product/4008366010387', '4008366010387'),
    ('Frosta', 'Hühnerfrikassee', 'https://world.openfoodfacts.org/product/4008366008582', '4008366008582'),
    ('Frosta', 'Tortellini Käse-Sahne (vegetarisch)', 'https://world.openfoodfacts.org/product/4008366009961', '4008366009961'),
    ('Frosta', 'Gemüse Pfanne alla Toscana', 'https://world.openfoodfacts.org/product/4008366006915', '4008366006915'),
    ('Frosta', 'Hähnchen Curry', 'https://world.openfoodfacts.org/product/4008366001347', '4008366001347'),
    ('Speisezeit', 'Süßkartoffel-Pommes', 'https://world.openfoodfacts.org/product/4061458128407', '4061458128407'),
    ('Original Wagner', 'Piccolinis Drei-Käse Pizza', 'https://world.openfoodfacts.org/product/4009233014347', '4009233014347'),
    ('Nur Nur Natur', 'Bio-Dinkel-Steinofenpizza - Grillgemüse', 'https://world.openfoodfacts.org/product/4061463214911', '4061463214911'),
    ('Dr. Oetker', 'Die Ofenfrische Vier Käse', 'https://world.openfoodfacts.org/product/4001724011118', '4001724011118'),
    ('Frosta', 'Wildlachs in Kräuterrahm', 'https://world.openfoodfacts.org/product/4008366015535', '4008366015535'),
    ('Frosta', 'Paprika Sahne Hähnchen mit Bandnudeln', 'https://world.openfoodfacts.org/product/4008366010981', '4008366010981'),
    ('Frosta', 'Gemüsepfanne a la Provence', 'https://world.openfoodfacts.org/product/4008366006953', '4008366006953'),
    ('Frosta', 'Gemüse Pfanne Style Asia Curry', 'https://world.openfoodfacts.org/product/4008366009336', '4008366009336'),
    ('Frosta', 'Reis Hähnchen Pfanne', 'https://world.openfoodfacts.org/product/4008366010042', '4008366010042'),
    ('Golden Seafood', 'Riesengarnelenschwänze - Natur', 'https://world.openfoodfacts.org/product/4061458034807', '4061458034807'),
    ('Freshona', 'Gemüsepfanne Bio Mediterrane Art', 'https://world.openfoodfacts.org/product/4056489289241', '4056489289241'),
    ('Frost', 'Pfannenfisch Müllerin Art', 'https://world.openfoodfacts.org/product/4008366011964', '4008366011964'),
    ('Frosta', 'Gemüse-Bowl - Pikanter Bulgur mit schwarzen Bohnen', 'https://world.openfoodfacts.org/product/4008366883448', '4008366883448'),
    ('Frosta', 'Bami Goreng', 'https://world.openfoodfacts.org/product/4008366001309', '4008366001309'),
    ('Frosta', 'Butter Chicken', 'https://world.openfoodfacts.org/product/4008366003587', '4008366003587'),
    ('Original Wagner', 'Pizza Die Backfrische Mozzarella', 'https://world.openfoodfacts.org/product/4009233006847', '4009233006847'),
    ('Frosta', 'Nice Rice - Korean Style', 'https://world.openfoodfacts.org/product/4008366883301', '4008366883301'),
    ('Dr. Oetker', 'Ristorante PIZZA TONNO', 'https://world.openfoodfacts.org/product/4001724038993', '4001724038993'),
    ('Frosta', 'Paella', 'https://world.openfoodfacts.org/product/4008366015337', '4008366015337'),
    ('Dr. Oetker', 'Suprema Pizza Calabrese & ''Nduja', 'https://world.openfoodfacts.org/product/4001724049906', '4001724049906'),
    ('Original Wagner', 'Steinofen-Pizza Mozzarella Vegetarisch', 'https://world.openfoodfacts.org/product/4009233003952', '4009233003952'),
    ('Dr. Oetker', 'Die Ofenfrische Margherita', 'https://world.openfoodfacts.org/product/4001724015420', '4001724015420'),
    ('Greenyard Frozen Langemark', 'Buckwheat & broccoli', 'https://world.openfoodfacts.org/product/4056489456476', '4056489456476'),
    ('Frosta', 'Fisch Schlemmerfilet Mediterraner Art', 'https://world.openfoodfacts.org/product/4008366009787', '4008366009787'),
    ('Frosta', 'Fettuccine Wildlachs', 'https://world.openfoodfacts.org/product/4008366015511', '4008366015511'),
    ('Dr. Oetker', 'Pizza Tradizionale Margherita', 'https://world.openfoodfacts.org/product/4001724038597', '4001724038597'),
    ('Original Wagner', 'Steinofen-Pizza - Diavolo', 'https://world.openfoodfacts.org/product/4009233003655', '4009233003655'),
    ('Dr. Oetker', 'Die Ofenfrische Speciale', 'https://world.openfoodfacts.org/product/4001724011057', '4001724011057'),
    ('Dr. Oetker', 'Pizza Salame Ristorante', 'https://world.openfoodfacts.org/product/4001724038900', '4001724038900'),
    ('Vemondo', 'Vegan pizza Verdura', 'https://world.openfoodfacts.org/product/4056489451044', '4056489451044'),
    ('Dr. Oetker', 'Die Ofenfrische Salami', 'https://world.openfoodfacts.org/product/4001724011170', '4001724011170'),
    ('Frosta', 'Fisch Schlemmerfilet Brokkoli Mandel', 'https://world.openfoodfacts.org/product/4008366009763', '4008366009763'),
    ('Dr. Oetker', 'La Mia Grande Rucola', 'https://world.openfoodfacts.org/product/4001724040538', '4001724040538'),
    ('GiaPizza', 'Bio-Dinkel-Steinofenpizza - Spinat', 'https://world.openfoodfacts.org/product/4061463213211', '4061463213211'),
    ('Nestlé', 'Pizza Speciale', 'https://world.openfoodfacts.org/product/4009233003587', '4009233003587'),
    ('Dr. Oetker', 'La Mia Grande Pizza Margherita', 'https://world.openfoodfacts.org/product/4001724027195', '4001724027195'),
    ('Speise Zeit', 'Wellenschnitt Pommes', 'https://world.openfoodfacts.org/product/4061458042192', '4061458042192'),
    ('Frosta', 'Nom Nom Noodles', 'https://world.openfoodfacts.org/product/4008366000500', '4008366000500'),
    ('Dr. Oetker', 'Pizza Traditionale Verdure Grigliate', 'https://world.openfoodfacts.org/product/4001724038658', '4001724038658'),
    ('Dr. Oetker', 'Ristorante Pizza Pasta', 'https://world.openfoodfacts.org/product/4001724039389', '4001724039389'),
    ('Nur Nur Natur', 'Bio-Eiscreme - Vanille', 'https://world.openfoodfacts.org/product/4061462826344', '4061462826344'),
    ('Nestlé', 'Steinofen-Pizza Thunfisch', 'https://world.openfoodfacts.org/product/4009233003921', '4009233003921'),
    ('Aldi', 'Pommes Frites', 'https://world.openfoodfacts.org/product/4061458041942', '4061458041942'),
    ('All Seasons', 'Rahm-Spinat', 'https://world.openfoodfacts.org/product/4061458011228', '4061458011228'),
    ('Vemondo', 'Pumpkin & quinoa', 'https://world.openfoodfacts.org/product/4056489456483', '4056489456483')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Frozen & Prepared' AND p.is_deprecated IS NOT TRUE;
