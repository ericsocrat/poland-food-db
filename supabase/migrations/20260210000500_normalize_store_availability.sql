-- Migration: normalize store_availability + add sources.category index
-- Date: 2026-02-10
-- Reason: store_availability had 94 distinct values with casing inconsistencies
--         (lidl/Lidl/LIDL), comma-separated international store lists, and
--         non-Polish stores. Normalize to primary Polish chain or NULL.
--         Also add index on sources.category for v_master equijoin performance.

BEGIN;

-- 1. Normalize store_availability to primary Polish chain
-- Uses case-insensitive regex match, picking highest-priority Polish chain
WITH polish_chains(chain, priority) AS (
  VALUES
    ('Biedronka', 1), ('Lidl', 2), ('Żabka', 3), ('Kaufland', 4),
    ('Auchan', 5), ('Dino', 6), ('Carrefour', 7), ('Netto', 8),
    ('Stokrotka', 9), ('Tesco', 10), ('Lewiatan', 11), ('Aldi', 12),
    ('Penny', 13), ('Selgros', 14), ('Delikatesy Centrum', 15),
    ('Dealz', 16), ('Ikea', 17), ('Rossmann', 18)
),
product_best AS (
  SELECT p.product_id,
         (SELECT pc.chain FROM polish_chains pc
          WHERE p.store_availability ~* pc.chain
          ORDER BY pc.priority
          LIMIT 1) AS best_chain
  FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND p.store_availability IS NOT NULL
)
UPDATE products p
SET store_availability = pb.best_chain
FROM product_best pb
WHERE p.product_id = pb.product_id
  AND pb.best_chain IS NOT NULL
  AND p.store_availability IS DISTINCT FROM pb.best_chain;

-- 2. Set non-Polish stores to NULL
UPDATE products
SET store_availability = NULL
WHERE is_deprecated IS NOT TRUE
  AND store_availability IS NOT NULL
  AND store_availability !~* ('Biedronka|Lidl|Żabka|Kaufland|Auchan|Dino|'
    || 'Carrefour|Netto|Stokrotka|Tesco|Lewiatan|Aldi|Penny|Selgros|'
    || 'Delikatesy Centrum|Dealz|Ikea|Rossmann');

-- 3. Add index on sources.category for v_master equijoin
CREATE INDEX IF NOT EXISTS sources_category_idx ON sources (category);

COMMIT;
