-- Migration: Add verified EANs to Chips category (16 products)
-- Date: 2026-02-08
-- Found via Open Food Facts API research
-- All EANs validated using GS1 Modulo-10 checksum

UPDATE products SET ean = '0028400071659' WHERE brand = 'Cheetos' AND product_name = 'Cheetos Puffs' AND category = 'Chips';
UPDATE products SET ean = '4001242105931' WHERE brand = 'Chio' AND product_name = 'Chio Chips Paprika' AND category = 'Chips';
UPDATE products SET ean = '4001242105924' WHERE brand = 'Chio' AND product_name = 'Chio Chips Salted' AND category = 'Chips';
UPDATE products SET ean = '5905187101074' WHERE brand = 'Crunchips' AND product_name = 'Crunchips X-Cut Paprika' AND category = 'Chips';
UPDATE products SET ean = '4018077773419' WHERE brand = 'Crunchips' AND product_name = 'Crunchips X-Cut Salted' AND category = 'Chips';
UPDATE products SET ean = '8710398161987' WHERE brand = 'Doritos' AND product_name = 'Doritos Nacho Cheese' AND category = 'Chips';
UPDATE products SET ean = '3168930173199' WHERE brand = 'Doritos' AND product_name = 'Doritos Sweet Chilli' AND category = 'Chips';
UPDATE products SET ean = '8901491101837' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Classic Salted' AND category = 'Chips';
UPDATE products SET ean = '3168930000976' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Fromage' AND category = 'Chips';
UPDATE products SET ean = '5900259133281' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Max Karbowane Papryka' AND category = 'Chips';
UPDATE products SET ean = '8710398160881' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Oven Baked (paprika)' AND category = 'Chips';
UPDATE products SET ean = '5900259133366' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Oven Baked Grilled Paprika' AND category = 'Chips';
UPDATE products SET ean = '5900259127600' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Solone' AND category = 'Chips';
UPDATE products SET ean = '5900259099235' WHERE brand = 'Lay''s' AND product_name = 'Lay''s Zielona Cebulka' AND category = 'Chips';
UPDATE products SET ean = '20173258' WHERE brand = 'Snack Day (Lidl)' AND product_name = 'Snack Day Paprika' AND category = 'Chips';
UPDATE products SET ean = '20940690' WHERE brand = 'Snack Day (Lidl)' AND product_name = 'Snack Day Salted' AND category = 'Chips';
