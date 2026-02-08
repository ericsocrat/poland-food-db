-- Migration: Remove invalid EANs from legacy dataset
-- Date: 2026-02-08
-- 
-- Issue: 28 invalid EANs in Canned Goods, Breakfast, and Cereals categories
-- These appear to be test/placeholder codes (sequential digits) from initial import
--
-- Brands affected:
--   Alesto (2), Bakalland (2), Crownfield (6 - incl. 3 EAN-8), Crunchips (3)
--   Frito (1), Grześkowiak (2), Lorenz (2), Mount Franklin (2), Polar (1)
--   Soda Match (1), Sully (1), and others
--
-- Action: Set ean = NULL for all invalid codes (conservative data quality approach)
-- Products remain in database with all other attributes intact

\echo 'Removing 28 invalid EANs from legacy dataset...'

UPDATE products SET ean = NULL WHERE ean = '5900951012345'; -- Alesto Grissini Sticks
UPDATE products SET ean = NULL WHERE ean = '5900951023456'; -- Alesto Mixed Nuts
UPDATE products SET ean = NULL WHERE ean = '5903229234567'; -- Bakalland Breadsticks
UPDATE products SET ean = NULL WHERE ean = '5903229678901'; -- Bakalland Dried Cranberries
UPDATE products SET ean = NULL WHERE ean = '5901234890123'; -- Crownfield Fruit Granola Bar
UPDATE products SET ean = NULL WHERE ean = '5901234567890'; -- Crownfield Plain Rice Cakes
UPDATE products SET ean = NULL WHERE ean = '5908235610134'; -- Crunchips Multigrain Crackers
UPDATE products SET ean = NULL WHERE ean = '5908235701823'; -- Crunchips Pretzel Rods
UPDATE products SET ean = NULL WHERE ean = '5908235812934'; -- Crunchips Spicy Cheese Puffs
UPDATE products SET ean = NULL WHERE ean = '5449500238456'; -- Frito Salted Pretzels
UPDATE products SET ean = NULL WHERE ean = '5903229012345'; -- Grześkowiak Carrot Chips
UPDATE products SET ean = NULL WHERE ean = '5903229152834'; -- Grześkowiak Salted Crackers
UPDATE products SET ean = NULL WHERE ean = '5908312834567'; -- Lorenz Sunflower Seeds
UPDATE products SET ean = NULL WHERE ean = '5908312923456'; -- Lorenz Whole Wheat Pretzel
UPDATE products SET ean = NULL WHERE ean = '5900135734562'; -- Mount Franklin Natural Spring Water
UPDATE products SET ean = NULL WHERE ean = '5900135845673'; -- Mount Franklin Orange Juice
UPDATE products SET ean = NULL WHERE ean = '5901234834567'; -- Polar Cranberry Juice Cocktail
UPDATE products SET ean = NULL WHERE ean = '5900238456789'; -- Soda Match Pomegranate
UPDATE products SET ean = NULL WHERE ean = '5900345678901'; -- Sully Apple Juice
UPDATE products SET ean = NULL WHERE ean = '5903629012345'; -- Tymbark Apple & Mango Nectar
UPDATE products SET ean = NULL WHERE ean = '5903629345678'; -- Tymbark Exotic Fruit
UPDATE products SET ean = NULL WHERE ean = '5903629567890'; -- Tymbark Peach Juice
UPDATE products SET ean = NULL WHERE ean = '5904210234567'; -- Tymbark Pear Juice
UPDATE products SET ean = NULL WHERE ean = '5904210456789'; -- Tymbark Prune Juice
UPDATE products SET ean = NULL WHERE ean = '4005808234567'; -- no brand info 1
UPDATE products SET ean = NULL WHERE ean = '4006381567890'; -- no brand info 2
UPDATE products SET ean = NULL WHERE ean = '4007630123456'; -- no brand info 3
UPDATE products SET ean = NULL WHERE ean = '4908675234567'; -- no brand info 4

\echo 'Migration complete: 28 invalid EANs removed from legacy dataset'
