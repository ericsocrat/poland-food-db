-- Migration: purge all deprecated products and their child rows
-- Date: 2026-02-10
-- Reason: 1,068 deprecated products + 3,644 child rows are dead weight.
--         They are excluded from v_master and all queries via is_deprecated filter.
--         Removing them reduces table sizes by ~65% and simplifies maintenance.

BEGIN;

-- Delete child rows first (no FK cascades defined)
DELETE FROM nutrition_facts WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);
DELETE FROM scores         WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);
DELETE FROM servings        WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);
DELETE FROM ingredients     WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);

-- Delete the deprecated products themselves
DELETE FROM products WHERE is_deprecated = true;

COMMIT;
