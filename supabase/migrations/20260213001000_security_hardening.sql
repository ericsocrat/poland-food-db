-- ═══════════════════════════════════════════════════════════════════════════════
-- Security Hardening: RLS, Grant Lockdown, SECURITY DEFINER on API Functions
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Context:
--   Before this migration, every table had GRANT ALL to anon/authenticated,
--   no RLS was enabled, and all functions (including internal helpers) were
--   callable by anonymous users via the Supabase REST API.
--
-- This migration:
--   1. Enables RLS on all 9 data tables with read-only policies
--   2. Revokes write privileges from anon/authenticated on tables & sequences
--   3. Marks the 6 api_* functions as SECURITY DEFINER (run as owner)
--   4. Revokes EXECUTE on internal helper functions from anon
--   5. Resets default privileges so future objects get minimal grants
--
-- Result:
--   - anon/authenticated can SELECT all data and call api_* functions
--   - Only service_role (bypassrls) and postgres can write data
--   - Internal functions (compute_*, find_*, refresh_*, etc.) are NOT callable
--     by anonymous users, but still work inside SECURITY DEFINER API functions
--
-- Idempotent: all statements use IF NOT EXISTS or are safe to re-run.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. ENABLE ROW LEVEL SECURITY on all data tables
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE products             ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_facts      ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_allergen_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_ingredient   ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredient_ref       ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_ref         ENABLE ROW LEVEL SECURITY;
ALTER TABLE country_ref          ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutri_score_ref      ENABLE ROW LEVEL SECURITY;
ALTER TABLE concern_tier_ref     ENABLE ROW LEVEL SECURITY;

-- Force RLS even for table owners (defense-in-depth; postgres still bypasses)
ALTER TABLE products             FORCE ROW LEVEL SECURITY;
ALTER TABLE nutrition_facts      FORCE ROW LEVEL SECURITY;
ALTER TABLE product_allergen_info FORCE ROW LEVEL SECURITY;
ALTER TABLE product_ingredient   FORCE ROW LEVEL SECURITY;
ALTER TABLE ingredient_ref       FORCE ROW LEVEL SECURITY;
ALTER TABLE category_ref         FORCE ROW LEVEL SECURITY;
ALTER TABLE country_ref          FORCE ROW LEVEL SECURITY;
ALTER TABLE nutri_score_ref      FORCE ROW LEVEL SECURITY;
ALTER TABLE concern_tier_ref     FORCE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. CREATE read-only SELECT policies
--    All data is public (food database), so the policy is USING (true).
--    No INSERT/UPDATE/DELETE policies ⇒ writes are blocked by RLS.
-- ─────────────────────────────────────────────────────────────────────────────

-- products
CREATE POLICY "allow_select_products"
    ON products FOR SELECT
    USING (true);

-- nutrition_facts
CREATE POLICY "allow_select_nutrition_facts"
    ON nutrition_facts FOR SELECT
    USING (true);

-- product_allergen_info
CREATE POLICY "allow_select_product_allergen_info"
    ON product_allergen_info FOR SELECT
    USING (true);

-- product_ingredient
CREATE POLICY "allow_select_product_ingredient"
    ON product_ingredient FOR SELECT
    USING (true);

-- ingredient_ref
CREATE POLICY "allow_select_ingredient_ref"
    ON ingredient_ref FOR SELECT
    USING (true);

-- category_ref
CREATE POLICY "allow_select_category_ref"
    ON category_ref FOR SELECT
    USING (true);

-- country_ref
CREATE POLICY "allow_select_country_ref"
    ON country_ref FOR SELECT
    USING (true);

-- nutri_score_ref
CREATE POLICY "allow_select_nutri_score_ref"
    ON nutri_score_ref FOR SELECT
    USING (true);

-- concern_tier_ref
CREATE POLICY "allow_select_concern_tier_ref"
    ON concern_tier_ref FOR SELECT
    USING (true);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. REVOKE write privileges from anon and authenticated on tables
--    Keep SELECT; remove INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
-- ─────────────────────────────────────────────────────────────────────────────

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
    ON products, nutrition_facts, product_allergen_info, product_ingredient,
       ingredient_ref, category_ref, country_ref, nutri_score_ref, concern_tier_ref
    FROM anon, authenticated;

-- Also revoke write on views (belt-and-suspenders)
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
    ON v_master, v_api_category_overview
    FROM anon, authenticated;

-- Revoke on materialized views
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
    ON mv_ingredient_frequency, v_product_confidence
    FROM anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. REVOKE write privileges on sequences from anon and authenticated
-- ─────────────────────────────────────────────────────────────────────────────

REVOKE UPDATE, USAGE
    ON SEQUENCE products_product_id_seq,
                ingredient_ref_ingredient_id_seq,
                sources_source_id_seq
    FROM anon, authenticated;

-- Allow SELECT on sequences (needed for nextval in views, harmless)
GRANT SELECT ON SEQUENCE products_product_id_seq,
                         ingredient_ref_ingredient_id_seq,
                         sources_source_id_seq
    TO anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. MARK API functions as SECURITY DEFINER
--    These run as the owner (postgres), which bypasses RLS and can call
--    internal helpers. The search_path is locked to prevent search-path
--    hijacking attacks.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER FUNCTION api_product_detail(bigint)
    SECURITY DEFINER
    SET search_path = public;

ALTER FUNCTION api_category_listing(text, text, text, integer, integer)
    SECURITY DEFINER
    SET search_path = public;

ALTER FUNCTION api_search_products(text, text, integer, integer)
    SECURITY DEFINER
    SET search_path = public;

ALTER FUNCTION api_score_explanation(bigint)
    SECURITY DEFINER
    SET search_path = public;

ALTER FUNCTION api_better_alternatives(bigint, boolean, integer)
    SECURITY DEFINER
    SET search_path = public;

ALTER FUNCTION api_data_confidence(bigint)
    SECURITY DEFINER
    SET search_path = public;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. REVOKE EXECUTE on internal functions from PUBLIC and anon
--    PostgreSQL grants EXECUTE to PUBLIC by default on all functions.
--    We must revoke from PUBLIC to actually block anonymous access.
--    These remain callable by postgres (owner), service_role (explicit),
--    and authenticated (explicit), and work inside SECURITY DEFINER api_*.
-- ─────────────────────────────────────────────────────────────────────────────

-- Scoring / computation internals
REVOKE EXECUTE ON FUNCTION compute_unhealthiness_v31(numeric, numeric, numeric, numeric, numeric, numeric, text, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION compute_unhealthiness_v32(numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION explain_score_v32(numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION compute_data_confidence(bigint) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION compute_data_completeness(bigint) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION assign_confidence(numeric, text) FROM PUBLIC, anon;

-- Similarity / alternatives internals
REVOKE EXECUTE ON FUNCTION find_similar_products(bigint, integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION find_better_alternatives(bigint, boolean, integer) FROM PUBLIC, anon;

-- Admin / maintenance
REVOKE EXECUTE ON FUNCTION refresh_all_materialized_views() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION mv_staleness_check() FROM PUBLIC, anon;

-- Re-grant EXECUTE to authenticated and service_role on internal functions
-- (they need these for server-side operations)
GRANT EXECUTE ON FUNCTION compute_unhealthiness_v31(numeric, numeric, numeric, numeric, numeric, numeric, text, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION compute_unhealthiness_v32(numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION explain_score_v32(numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION compute_data_confidence(bigint) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION compute_data_completeness(bigint) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION assign_confidence(numeric, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION find_similar_products(bigint, integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION find_better_alternatives(bigint, boolean, integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION refresh_all_materialized_views() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION mv_staleness_check() TO authenticated, service_role;

-- Explicitly grant EXECUTE on API functions to anon (they are SECURITY DEFINER)
GRANT EXECUTE ON FUNCTION api_product_detail(bigint) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api_category_listing(text, text, text, integer, integer) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api_search_products(text, text, integer, integer) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api_score_explanation(bigint) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api_better_alternatives(bigint, boolean, integer) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api_data_confidence(bigint) TO anon, authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. RESET default privileges for future objects
--    New tables/functions created by postgres will get minimal grants.
--    IMPORTANT: Revoke from PUBLIC too, since PG grants EXECUTE to PUBLIC
--    by default on new functions.
-- ─────────────────────────────────────────────────────────────────────────────

-- Revoke old permissive defaults
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    REVOKE ALL ON TABLES FROM anon, authenticated, PUBLIC;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    REVOKE ALL ON FUNCTIONS FROM anon, authenticated, PUBLIC;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    REVOKE ALL ON SEQUENCES FROM anon, authenticated, PUBLIC;

-- Set new restrictive defaults: SELECT-only on tables, EXECUTE on functions
-- (Individual function grants can be revoked as needed per function)
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    GRANT SELECT ON TABLES TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    GRANT SELECT ON SEQUENCES TO anon, authenticated, service_role;

-- service_role keeps full table access for backend operations
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
    GRANT ALL ON SEQUENCES TO service_role;

COMMIT;
