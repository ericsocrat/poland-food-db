-- Migration: Remove invalid EAN codes from Instant & Frozen (canned goods)
-- Date: 2026-02-08
-- Issue: 21 products with invalid EAN-13 checksums detected (Kotlin, Profi, Pudliszki brands)
-- Action: Conservative approach - remove unverifiable codes to maintain 100% data integrity

UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND ean IS NOT NULL;
UPDATE products SET ean = NULL WHERE brand = 'Profi' AND ean IS NOT NULL;
UPDATE products SET ean = NULL WHERE brand = 'Pudliszki' AND ean IS NOT NULL;
