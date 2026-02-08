-- Migration: Add verified EANs to Dairy category (23 products)
-- Date: 2026-02-08
-- Found via Open Food Facts API research
-- All EANs validated using GS1 Modulo-10 checksum
-- Success rate: 23/28 (82.1%)

UPDATE products SET ean = '5900197011955' WHERE brand = 'Bakoma' AND product_name = 'Bakoma Kefir Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '5900197017575' WHERE brand = 'Bakoma' AND product_name = 'Bakoma Satino Kawowy' AND category = 'Dairy';
UPDATE products SET ean = '5900643048580' WHERE brand = 'Danio' AND product_name = 'Danio Serek Waniliowy' AND category = 'Dairy';
UPDATE products SET ean = '5900643049273' WHERE brand = 'Danone' AND product_name = 'Activia Jogurt Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '5900643033746' WHERE brand = 'Danone' AND product_name = 'Danonki Truskawka' AND category = 'Dairy';
UPDATE products SET ean = '5902899139661' WHERE brand = 'Hochland' AND product_name = 'Hochland Kanapkowy ze Szczypiorkiem' AND category = 'Dairy';
UPDATE products SET ean = '5902899141701' WHERE brand = 'Hochland' AND product_name = 'Hochland Kremowy ze Śmietanką' AND category = 'Dairy';
UPDATE products SET ean = '5900820000257' WHERE brand = 'Łaciate' AND product_name = 'Łaciate Masło Extra' AND category = 'Dairy';
UPDATE products SET ean = '5900512110271' WHERE brand = 'Mlekovita' AND product_name = 'Mlekovita Gouda' AND category = 'Dairy';
UPDATE products SET ean = '5902901004055' WHERE brand = 'Mlekovita' AND product_name = 'Mlekovita Kefir Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '5900512220130' WHERE brand = 'Mlekovita' AND product_name = 'Mlekovita Masło Ekstra' AND category = 'Dairy';
UPDATE products SET ean = '5900512982335' WHERE brand = 'Mlekovita' AND product_name = 'Mlekovita Mleko UHT 2%' AND category = 'Dairy';
UPDATE products SET ean = '5900820004088' WHERE brand = 'Mlekpol' AND product_name = 'Jogurt Augustowski Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '42373261' WHERE brand = 'Müller' AND product_name = 'Müller Jogurt Choco Balls' AND category = 'Dairy';
UPDATE products SET ean = '7622201695521' WHERE brand = 'Philadelphia' AND product_name = 'Philadelphia Original' AND category = 'Dairy';
UPDATE products SET ean = '5900531000010' WHERE brand = 'Piątnica' AND product_name = 'Piątnica Serek Wiejski' AND category = 'Dairy';
UPDATE products SET ean = '5901939103068' WHERE brand = 'Piątnica' AND product_name = 'Piątnica Skyr Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '5900531001130' WHERE brand = 'Piątnica' AND product_name = 'Piątnica Śmietana 18%' AND category = 'Dairy';
UPDATE products SET ean = '3228021170039' WHERE brand = 'Président' AND product_name = 'Président Camembert' AND category = 'Dairy';
UPDATE products SET ean = '5901753000895' WHERE brand = 'Sierpc' AND product_name = 'Sierpc Ser Królewski' AND category = 'Dairy';
UPDATE products SET ean = '4014500006093' WHERE brand = 'Zott' AND product_name = 'Jogobella Brzoskwinia' AND category = 'Dairy';
UPDATE products SET ean = '5906040063089' WHERE brand = 'Zott' AND product_name = 'Zott Jogurt Naturalny' AND category = 'Dairy';
UPDATE products SET ean = '4014500036830' WHERE brand = 'Zott' AND product_name = 'Zott Monte' AND category = 'Dairy';
