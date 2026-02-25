-- PIPELINE (Dairy): source provenance
-- Generated: 2026-02-25

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Milsani', 'Frischkäse natur', 'https://world.openfoodfacts.org/product/4061458047685', '4061458047685'),
    ('Gervais', 'Hüttenkäse Original', 'https://world.openfoodfacts.org/product/4002671157751', '4002671157751'),
    ('Milsani', 'Körniger Frischkäse, Halbfettstufe', 'https://world.openfoodfacts.org/product/4061458047692', '4061458047692'),
    ('Almette', 'Almette Kräuter', 'https://world.openfoodfacts.org/product/4002468084017', '4002468084017'),
    ('Bergader', 'Bergbauern mild nussig Käse', 'https://world.openfoodfacts.org/product/4006402046192', '4006402046192'),
    ('DOVGAN Family', 'Körniger Frischkäse 33 % Fett', 'https://world.openfoodfacts.org/product/4032549018105', '4032549018105'),
    ('BMI Biobauern', 'Bio-Landkäse mild-nussig', 'https://world.openfoodfacts.org/product/4040900117251', '4040900117251'),
    ('Dr. Oetker', 'High Protein Pudding Grieß', 'https://world.openfoodfacts.org/product/4023600013511', '4023600013511'),
    ('Milsan', 'Grießpudding High-Protein - Zimt', 'https://world.openfoodfacts.org/product/4061458280334', '4061458280334'),
    ('Milram', 'Frühlingsquark Original', 'https://world.openfoodfacts.org/product/40466002', '40466002'),
    ('DMK', 'Müritzer original', 'https://world.openfoodfacts.org/product/4036300005311', '4036300005311'),
    ('Milsani', 'Körniger Frischkäse - Magerstufe', 'https://world.openfoodfacts.org/product/4061458047708', '4061458047708'),
    ('AF Deutschland', 'Hirtenkäse', 'https://world.openfoodfacts.org/product/4061458163903', '4061458163903'),
    ('Grünländer', 'Grünländer Mild & Nussig', 'https://world.openfoodfacts.org/product/4002468210454', '4002468210454'),
    ('Grünländer', 'Grünländer Leicht', 'https://world.openfoodfacts.org/product/4002468210478', '4002468210478'),
    ('Gazi', 'Grill- und Pfannenkäse', 'https://world.openfoodfacts.org/product/4002566010703', '4002566010703'),
    ('Bio', 'ALDI GUT BIO Milch Frische Bio-Milch 1.5 % Fett Aus der Kühlung 1l 1.15€ Fettarme Milch', 'https://world.openfoodfacts.org/product/4061459193312', '4061459193312'),
    ('Milsani', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'https://world.openfoodfacts.org/product/4061458229838', '4061458229838'),
    ('Karwendel', 'Exquisa Balance Frischkäse', 'https://world.openfoodfacts.org/product/4019300005307', '4019300005307'),
    ('Weihenstephan', 'H-Milch 3,5%', 'https://world.openfoodfacts.org/product/4008452027602', '4008452027602'),
    ('Milbona', 'Skyr', 'https://world.openfoodfacts.org/product/4056489012788', '4056489012788'),
    ('Arla', 'Skyr Natur', 'https://world.openfoodfacts.org/product/4016241030603', '4016241030603'),
    ('Milsani', 'H-Vollmilch 3,5 % Fett', 'https://world.openfoodfacts.org/product/4061462842986', '4061462842986'),
    ('Elinas', 'Joghurt Griechischer Art', 'https://world.openfoodfacts.org/product/4003490323600', '4003490323600'),
    ('Alpenhain', 'Obazda klassisch', 'https://world.openfoodfacts.org/product/4003751002848', '4003751002848'),
    ('Ehrmann', 'High Protein Chocolate Pudding', 'https://world.openfoodfacts.org/product/4002971243703', '4002971243703'),
    ('Bio', 'Frische Bio-Vollmilch 3,8 % Fett', 'https://world.openfoodfacts.org/product/4061459193695', '4061459193695'),
    ('Milsani', 'Haltbare Fettarme Milch', 'https://world.openfoodfacts.org/product/4061462842764', '4061462842764'),
    ('Arla', 'Skyr Bourbon Vanille', 'https://world.openfoodfacts.org/product/4016241030917', '4016241030917'),
    ('Milbona', 'High Protein Chocolate Flavour Pudding', 'https://world.openfoodfacts.org/product/4056489216162', '4056489216162'),
    ('Milsani', 'Joghurt mild 3,5 % Fett', 'https://world.openfoodfacts.org/product/4061458028820', '4061458028820'),
    ('Schwarzwaldmilch', 'Protein Milch', 'https://world.openfoodfacts.org/product/4046700001806', '4046700001806'),
    ('Bresso', 'Bresso', 'https://world.openfoodfacts.org/product/4045357004383', '4045357004383'),
    ('Milsani', 'Milch', 'https://world.openfoodfacts.org/product/4061462864803', '4061462864803'),
    ('Bergader', 'Bavaria Blu', 'https://world.openfoodfacts.org/product/4006402020413', '4006402020413'),
    ('Aldi', 'Milch, haltbar, 1,5 %, Bio', 'https://world.openfoodfacts.org/product/4056489013105', '4056489013105'),
    ('Aldi', 'A/Joghurt mild 3,5% Fett', 'https://world.openfoodfacts.org/product/4061458028813', '4061458028813'),
    ('Patros', 'Patros Natur', 'https://world.openfoodfacts.org/product/4002671151353', '4002671151353'),
    ('Ehrmann', 'High-Protein-Pudding - Vanilla', 'https://world.openfoodfacts.org/product/4002971243802', '4002971243802'),
    ('Patros', 'Feta (Schaf- & Ziegenmilch)', 'https://world.openfoodfacts.org/product/4002468134361', '4002468134361'),
    ('Milsani', 'Frische Vollmilch 3,5%', 'https://world.openfoodfacts.org/product/4061462865015', '4061462865015'),
    ('Milram', 'Benjamin', 'https://world.openfoodfacts.org/product/4036300005304', '4036300005304'),
    ('Milbona', 'Bio Fettarmer Joghurt mild', 'https://world.openfoodfacts.org/product/4056489014003', '4056489014003'),
    ('Bauer', 'Kirsche', 'https://world.openfoodfacts.org/product/4002334113032', '4002334113032'),
    ('Milbona', 'Skyr Vanilla', 'https://world.openfoodfacts.org/product/4056489118190', '4056489118190'),
    ('Weihenstephan', 'Joghurt Natur 3,5 % Fett', 'https://world.openfoodfacts.org/product/4008452011007', '4008452011007'),
    ('Cucina Nobile', 'Mozzarella', 'https://world.openfoodfacts.org/product/4061458018531', '4061458018531'),
    ('Bio', 'Bio-Feta', 'https://world.openfoodfacts.org/product/4061458005548', '4061458005548'),
    ('Ein gutes Stück Bayern', 'Haltbare Bio Vollmilch', 'https://world.openfoodfacts.org/product/4056489379850', '4056489379850'),
    ('Lyttos', 'Griechischer Joghurt', 'https://world.openfoodfacts.org/product/4061458244404', '4061458244404'),
    ('AF Deutschland', 'Fettarme Milch (laktosefrei; 1,5% Fett)', 'https://world.openfoodfacts.org/product/4061462843723', '4061462843723')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Dairy' AND p.is_deprecated IS NOT TRUE;
