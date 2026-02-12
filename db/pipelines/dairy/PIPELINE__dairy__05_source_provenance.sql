-- PIPELINE (Dairy): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Piątnica', 'Twój Smak Serek śmietankowy', 'https://world.openfoodfacts.org/product/5900531000508', '5900531000508'),
    ('Mlekpol', 'Łaciate 3,2%', 'https://world.openfoodfacts.org/product/5900820000011', '5900820000011'),
    ('Piątnica', 'Twaróg wiejski półtłusty', 'https://world.openfoodfacts.org/product/5900531004018', '5900531004018'),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'https://world.openfoodfacts.org/product/5902409703887', '5902409703887'),
    ('Mleczna Dolina', 'Mleko Świeże 2,0%', 'https://world.openfoodfacts.org/product/5900820009854', '5900820009854'),
    ('Biedronka', 'Kefir naturalny 1,5 % tłuszczu', 'https://world.openfoodfacts.org/product/5900120005136', '5900120005136'),
    ('Piątnica', 'Skyr z mango i marakują', 'https://world.openfoodfacts.org/product/5900531004704', '5900531004704'),
    ('Wieluń', 'Twarożek "Mój ulubiony"', 'https://world.openfoodfacts.org/product/5904903000677', '5904903000677'),
    ('Piątnica', 'Śmietana 18%', 'https://world.openfoodfacts.org/product/5900531001130', '5900531001130'),
    ('Sierpc', 'Ser królewski', 'https://world.openfoodfacts.org/product/5901753000628', '5901753000628'),
    ('Piątnica', 'Mleko wieskie świeże 2%', 'https://world.openfoodfacts.org/product/5901939000770', '5901939000770'),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 'https://world.openfoodfacts.org/product/5900512850023', '5900512850023'),
    ('Almette', 'Serek Almette z ziołami', 'https://world.openfoodfacts.org/product/5902899101651', '5902899101651'),
    ('Mlekpol', 'Świeże mleko', 'https://world.openfoodfacts.org/product/5900820012229', '5900820012229'),
    ('Delikate', 'Twarożek grani klasyczny', 'https://world.openfoodfacts.org/product/5900820021955', '5900820021955'),
    ('Zott', 'Primo śmietanka 30%', 'https://world.openfoodfacts.org/product/5906040063225', '5906040063225'),
    ('Gostyńskie', 'Mleko zagęszczone słodzone', 'https://world.openfoodfacts.org/product/5900691031114', '5900691031114'),
    ('Piątnica', 'Twarożek Domowy grani naturalny', 'https://world.openfoodfacts.org/product/5900531000300', '5900531000300'),
    ('SM Gostyń', 'Kajmak masa krówkowa gostyńska', 'https://world.openfoodfacts.org/product/5900691031329', '5900691031329'),
    ('Piątnica', 'Koktail Białkowy malina & granat', 'https://world.openfoodfacts.org/product/5901939006017', '5901939006017'),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', 'https://world.openfoodfacts.org/product/5900197023842', '5900197023842'),
    ('Hochland', 'Ser żółty w plastrach Gouda', 'https://world.openfoodfacts.org/product/5902899141688', '5902899141688'),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 'https://world.openfoodfacts.org/product/5900512320359', '5900512320359'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'https://world.openfoodfacts.org/product/5900531004537', '5900531004537'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'https://world.openfoodfacts.org/product/5901939103068', '5901939103068'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'https://world.openfoodfacts.org/product/5901939103099', '5901939103099'),
    ('Piątnica', 'Skyr Wanilia', 'https://world.openfoodfacts.org/product/5901939103075', '5901939103075'),
    ('Robico', 'Kefir Robcio', 'https://world.openfoodfacts.org/product/5908312380078', '5908312380078'),
    ('Piątnica', 'Skyr Naturalny', 'https://world.openfoodfacts.org/product/5900531004544', '5900531004544'),
    ('Piątnica', 'Soured cream 18%', 'https://world.openfoodfacts.org/product/5900531001031', '5900531001031'),
    ('Zott', 'Jogurt naturalny', 'https://world.openfoodfacts.org/product/5906040063515', '5906040063515'),
    ('Mlekpol', 'Mleko UHT 2%', 'https://world.openfoodfacts.org/product/5900820000042', '5900820000042'),
    ('Almette', 'Puszysty Serek Jogurtowy', 'https://world.openfoodfacts.org/product/5902899117225', '5902899117225'),
    ('Spółdzielnia Mleczarska Ryki', 'Ser Rycki Edam kl.I', 'https://world.openfoodfacts.org/product/5902208000811', '5902208000811'),
    ('Mleczna Dolina', 'Mleko 1,5% bez laktozy', 'https://world.openfoodfacts.org/product/5900120010277', '5900120010277'),
    ('Mlekovita', 'Mleko UHT 3,2%', 'https://world.openfoodfacts.org/product/5900512300320', '5900512300320'),
    ('Piątnica', 'Icelandic type yoghurt natural', 'https://world.openfoodfacts.org/product/5900531004735', '5900531004735'),
    ('Favita', 'Favita', 'https://world.openfoodfacts.org/product/5900512700014', '5900512700014'),
    ('Almette', 'Almette z chrzanem', 'https://world.openfoodfacts.org/product/5902899104652', '5902899104652'),
    ('Mlekovita', 'Mleko 2%', 'https://world.openfoodfacts.org/product/5900512320335', '5900512320335'),
    ('Mleczna Dolina', 'Mleko 1,5%', 'https://world.openfoodfacts.org/product/5900512320618', '5900512320618'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 'https://world.openfoodfacts.org/product/5900531011023', '5900531011023'),
    ('Mlekovita', 'Jogurt Grecki naturalny', 'https://world.openfoodfacts.org/product/5900512350080', '5900512350080'),
    ('Delikate', 'Delikate Serek Smetankowy', 'https://world.openfoodfacts.org/product/5900120072480', '5900120072480'),
    ('Mleczna dolina', 'Śmietana', 'https://world.openfoodfacts.org/product/5907180315847', '5907180315847'),
    ('OSM Łowicz', 'Mleko UHT 3,2', 'https://world.openfoodfacts.org/product/5900120011199', '5900120011199')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Dairy' AND p.is_deprecated IS NOT TRUE;
