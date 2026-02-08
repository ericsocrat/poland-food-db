-- Migration: Remove invalid EAN codes from Seafood/Fish and Frozen categories
-- Date: 2026-02-08
-- Issue: 13 products with invalid EAN-13 checksums detected
-- Action: Conservative approach - remove unverifiable codes to maintain 100% data integrity

-- Frosta (Frozen fish products) - 2 invalid EANs
UPDATE products SET ean = NULL WHERE brand = 'Frosta' AND product_name = 'Filety Mintaja';
UPDATE products SET ean = NULL WHERE brand = 'Frosta' AND product_name = 'Paluszki Rybne';

-- Graal (Fish products) - 10+ invalid EANs
UPDATE products SET ean = NULL WHERE brand = 'Graal' AND ean IS NOT NULL;
