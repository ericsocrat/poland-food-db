-- PIPELINE (Żabka): source provenance
-- Generated: 2026-02-12

-- 1. Update source info on products (no EAN available — match by product_name)
UPDATE products p SET
  source_type = 'off_api',
  source_url = 'https://world.openfoodfacts.org/api/v2/search',
  source_ean = NULL
FROM (
  VALUES
    ('Szamamm', 'Gnocchi z kurczakiem'),
    ('Szamamm', 'Kotlet de Volaille'),
    ('Szamamm', 'Kotlet Drobiowy'),
    ('Szamamm', 'Naleśniki z jabłkami i cynamonem'),
    ('Szamamm', 'Panierowane skrzydełka z kurczaka'),
    ('Szamamm', 'Penne z kurczakiem'),
    ('Szamamm', 'Pierogi ruskie ze smażoną cebulką'),
    ('Szamamm', 'Placki ziemniaczane'),
    ('Tomcio Paluch', 'Bajgiel z salami'),
    ('Tomcio Paluch', 'BBQ Strips'),
    ('Tomcio Paluch', 'High 24g protein'),
    ('Tomcio Paluch', 'Kanapka Cezar'),
    ('Tomcio Paluch', 'Kebab z kurczaka'),
    ('Tomcio Paluch', 'Pasta jajeczna, por, jajko gotowane'),
    ('Tomcio Paluch', 'Pieczony bekon, sałata, jajko'),
    ('Tomcio Paluch', 'Szynka & Jajko'),
    ('Żabka', 'Bao Burger'),
    ('Żabka', 'Burger Kibica'),
    ('Żabka', 'Falafel Rollo'),
    ('Żabka', 'Kulki owsiane z czekoladą'),
    ('Żabka', 'Kurczaker'),
    ('Żabka', 'Meksykaner'),
    ('Żabka', 'Panini z kurczakiem'),
    ('Żabka', 'Panini z serem cheddar'),
    ('Żabka', 'Wegger'),
    ('Żabka', 'Wieprzowiner'),
    ('Żabka', 'Wołowiner Ser Kozi')
) AS d(brand, product_name)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;
