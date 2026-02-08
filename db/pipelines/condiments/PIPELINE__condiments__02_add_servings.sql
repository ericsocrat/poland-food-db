-- =====================================================================
-- PIPELINE: Condiments - Step 2: Add Servings
-- =====================================================================
-- Purpose: Create standardized serving information for condiment products
-- Serving Basis: per 100 g (standard for all condiments)
-- Last Updated: 2026-02-08
-- =====================================================================

-- =====================================================================
-- Section 1: Insert Servings for All Condiment Products
-- =====================================================================
INSERT INTO servings (product_id, serving_basis, serving_amount_g_ml)
SELECT p.product_id, 'per 100 g', 100
FROM products p
LEFT JOIN servings s ON s.product_id = p.product_id AND s.serving_basis = 'per 100 g'
WHERE p.country='PL' AND p.category='Condiments'
  AND s.serving_id IS NULL;
