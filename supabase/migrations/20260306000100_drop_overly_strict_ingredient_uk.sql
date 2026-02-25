-- Drop the overly strict UNIQUE constraint on product_ingredient(product_id, ingredient_id).
--
-- The PK is (product_id, ingredient_id, position) which correctly allows the same
-- ingredient to appear at multiple positions (e.g., "sugar" as a top-level ingredient
-- AND as a sub-ingredient of "chocolate coating").
--
-- The additional UK on (product_id, ingredient_id) contradicts the PK by preventing
-- valid ingredient data from the OFF API where sub-ingredients share ingredient_ref
-- entries with their parent or sibling ingredients.
--
-- Rollback: ALTER TABLE product_ingredient ADD CONSTRAINT uq_product_ingredient UNIQUE (product_id, ingredient_id);

ALTER TABLE product_ingredient DROP CONSTRAINT IF EXISTS uq_product_ingredient;
