-- ============================================================
-- Migration: Ingredient normalization (Phase 1-3)
-- Creates canonical ingredient dictionary, product-ingredient
-- junction, allergen/trace tracking, and ingredient properties.
-- ============================================================

BEGIN;

-- ────────────────────────────────────────────────────────────
-- 1. ingredient_ref — canonical ingredient dictionary
-- ────────────────────────────────────────────────────────────
CREATE TABLE ingredient_ref (
    ingredient_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    taxonomy_id     TEXT NOT NULL UNIQUE,          -- e.g. 'en:sugar', 'en:e322'
    name_en         TEXT NOT NULL,                 -- e.g. 'sugar', 'e322'
    is_additive     BOOLEAN NOT NULL DEFAULT false,-- true for E-numbers
    is_in_taxonomy  BOOLEAN NOT NULL DEFAULT true, -- OFF taxonomy coverage
    vegan           TEXT DEFAULT 'unknown',        -- yes/no/maybe/unknown
    vegetarian      TEXT DEFAULT 'unknown',        -- yes/no/maybe/unknown
    from_palm_oil   TEXT DEFAULT 'unknown',        -- yes/no/maybe/unknown
    concern_tier    SMALLINT DEFAULT 0,            -- 0=benign, 1=watch, 2=avoid, 3=banned-elsewhere
    concern_reason  TEXT,                          -- e.g. 'Banned in EU since 2022 (titanium dioxide)'
    created_at      TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT chk_vegan_values
        CHECK (vegan IN ('yes','no','maybe','unknown')),
    CONSTRAINT chk_vegetarian_values
        CHECK (vegetarian IN ('yes','no','maybe','unknown')),
    CONSTRAINT chk_palm_oil_values
        CHECK (from_palm_oil IN ('yes','no','maybe','unknown')),
    CONSTRAINT chk_concern_tier_range
        CHECK (concern_tier BETWEEN 0 AND 3)
);

CREATE INDEX idx_ingredient_ref_name     ON ingredient_ref (name_en);
CREATE INDEX idx_ingredient_ref_additive ON ingredient_ref (is_additive) WHERE is_additive = true;
CREATE INDEX idx_ingredient_ref_concern  ON ingredient_ref (concern_tier) WHERE concern_tier > 0;

COMMENT ON TABLE  ingredient_ref IS 'Canonical ingredient dictionary sourced from OFF taxonomy';
COMMENT ON COLUMN ingredient_ref.taxonomy_id    IS 'OFF taxonomy ID, e.g. en:sugar, en:e322';
COMMENT ON COLUMN ingredient_ref.concern_tier   IS '0=benign, 1=watch (limited evidence), 2=avoid (EFSA concern), 3=banned elsewhere';
COMMENT ON COLUMN ingredient_ref.from_palm_oil  IS 'Whether this ingredient is derived from palm oil';

-- ────────────────────────────────────────────────────────────
-- 2. product_ingredient — many-to-many junction
-- ────────────────────────────────────────────────────────────
CREATE TABLE product_ingredient (
    product_id          BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    ingredient_id       BIGINT NOT NULL REFERENCES ingredient_ref(ingredient_id) ON DELETE CASCADE,
    position            SMALLINT NOT NULL,            -- 1-based order on label
    percent             NUMERIC,                      -- declared % if available
    percent_estimate    NUMERIC,                      -- OFF-estimated %
    is_sub_ingredient   BOOLEAN NOT NULL DEFAULT false,
    parent_ingredient_id BIGINT REFERENCES ingredient_ref(ingredient_id),

    PRIMARY KEY (product_id, ingredient_id, position),

    CONSTRAINT chk_percent_range
        CHECK (percent IS NULL OR (percent >= 0 AND percent <= 100)),
    CONSTRAINT chk_percent_estimate_range
        CHECK (percent_estimate IS NULL OR percent_estimate >= 0),
    CONSTRAINT chk_sub_has_parent
        CHECK ((is_sub_ingredient = false AND parent_ingredient_id IS NULL)
            OR (is_sub_ingredient = true AND parent_ingredient_id IS NOT NULL))
);

CREATE INDEX idx_prod_ingr_product    ON product_ingredient (product_id);
CREATE INDEX idx_prod_ingr_ingredient ON product_ingredient (ingredient_id);
CREATE INDEX idx_prod_ingr_sub        ON product_ingredient (parent_ingredient_id) WHERE parent_ingredient_id IS NOT NULL;

COMMENT ON TABLE  product_ingredient IS 'Links products to their ingredients with position and percentage';
COMMENT ON COLUMN product_ingredient.position IS '1-based ingredient list position (1 = most abundant)';

-- ────────────────────────────────────────────────────────────
-- 3. product_allergen — declared allergens per product
-- ────────────────────────────────────────────────────────────
CREATE TABLE product_allergen (
    product_id      BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    allergen_tag    TEXT NOT NULL,          -- e.g. 'en:gluten', 'en:milk'
    source          TEXT DEFAULT 'off',     -- where the data came from

    PRIMARY KEY (product_id, allergen_tag)
);

CREATE INDEX idx_allergen_tag ON product_allergen (allergen_tag);

COMMENT ON TABLE product_allergen IS 'Declared allergens per product (from OFF allergens_tags)';

-- ────────────────────────────────────────────────────────────
-- 4. product_trace — "may contain" allergens per product
-- ────────────────────────────────────────────────────────────
CREATE TABLE product_trace (
    product_id      BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    trace_tag       TEXT NOT NULL,          -- e.g. 'en:nuts', 'en:milk'
    source          TEXT DEFAULT 'off',

    PRIMARY KEY (product_id, trace_tag)
);

CREATE INDEX idx_trace_tag ON product_trace (trace_tag);

COMMENT ON TABLE product_trace IS 'Trace allergens (may contain) per product (from OFF traces_tags)';

COMMIT;
