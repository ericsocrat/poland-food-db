-- Migration: Ingredient concern scoring (Phase 4)
-- Adds EFSA-based concern_tier (0-3) to ingredient_ref for food additives,
-- computes per-product ingredient_concern_score (0-100),
-- creates v3.2 scoring function with 9 factors, and re-scores all products.
--
-- Concern tier classification (EFSA-based):
--   Tier 0: No concern — natural substances, vitamins, minerals, enzymes
--   Tier 1: Low concern — generally safe, common emulsifiers/stabilizers, sugar alcohols
--   Tier 2: Moderate concern — artificial colors, artificial sweeteners, EFSA-monitored
--   Tier 3: High concern — nitrites/nitrates (IARC 2A carcinogen pathway)

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Add concern_tier column to ingredient_ref
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE ingredient_ref ADD COLUMN IF NOT EXISTS concern_tier smallint DEFAULT 0;

-- Non-additives keep default 0; only additives get classified
-- Default 0 for all tier-0 additives (natural/benign) — no UPDATE needed for them

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Classify tier 1 — low concern
--    Common preservatives (sorbates, propionates), phosphates, emulsifiers,
--    sugar alcohols, stevia, flavor enhancers, modified starches
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE ingredient_ref SET concern_tier = 1
WHERE name_en IN (
    'e150',   -- caramel color (unspecified type)
    'e172',   -- iron oxides (mineral-based color)
    'e200',   -- sorbic acid (preservative)
    'e202',   -- potassium sorbate (preservative)
    'e281',   -- sodium propionate (preservative)
    'e282',   -- calcium propionate (preservative)
    'e338',   -- phosphoric acid (cola acidifier, bone density debate)
    'e339',   -- sodium phosphates
    'e340',   -- potassium phosphates
    'e341',   -- calcium phosphates
    'e407a',  -- processed eucheuma seaweed
    'e420',   -- sorbitol (sugar alcohol, laxative effect)
    'e425',   -- konjac (thickener)
    'e445',   -- glycerol esters of wood rosin
    'e450',   -- diphosphates
    'e450i',  -- disodium diphosphate
    'e451',   -- triphosphates
    'e451i',  -- pentasodium triphosphate
    'e452',   -- polyphosphates
    'e452i',  -- sodium polyphosphate
    'e461',   -- methylcellulose
    'e471',   -- mono- and diglycerides of fatty acids
    'e472b',  -- lactic acid esters of mono/diglycerides
    'e472e',  -- DATEM
    'e475',   -- polyglycerol esters of fatty acids
    'e476',   -- polyglycerol polyricinoleate (PGPR)
    'e481',   -- sodium stearoyl-2-lactylate (SSL)
    'e482',   -- calcium stearoyl-2-lactylate (CSL)
    'e492',   -- sorbitan tristearate
    'e627',   -- disodium guanylate (flavor enhancer)
    'e631',   -- disodium inosinate (flavor enhancer)
    'e635',   -- disodium 5'-ribonucleotides (flavor enhancer)
    'e920',   -- L-cysteine (amino acid, processing aid)
    'e960',   -- steviol glycosides
    'e960a',  -- steviol glycosides
    'e965',   -- maltitol (sugar alcohol)
    'e1420'   -- acetylated starch (modified starch)
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Classify tier 2 — moderate concern
--    Artificial colors, artificial sweeteners (EFSA re-evaluated),
--    sulphites (allergen trigger), TBHQ, EDTA, carrageenan, MSG, CMC
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE ingredient_ref SET concern_tier = 2
WHERE name_en IN (
    'e133',   -- brilliant blue FCF (artificial color)
    'e150d',  -- sulphite ammonia caramel (4-MEI byproduct concern)
    'e211',   -- sodium benzoate (benzene formation with ascorbic acid)
    'e220',   -- sulphur dioxide (sulphite — asthma/allergen trigger)
    'e223',   -- sodium metabisulphite (sulphite)
    'e319',   -- TBHQ (tert-butylhydroquinone — restricted ADI, liver concerns)
    'e385',   -- calcium disodium EDTA (chelating agent, mineral binding)
    'e407',   -- carrageenan (gut inflammation debate, EFSA monitoring)
    'e466',   -- carboxymethyl cellulose (gut microbiome concerns in studies)
    'e621',   -- monosodium glutamate (EFSA reduced ADI to 30mg/kg in 2017)
    'e950',   -- acesulfame K (genotoxicity discussion, EFSA monitoring)
    'e951',   -- aspartame (IARC 2B possibly carcinogenic 2023, EFSA maintained ADI)
    'e954',   -- saccharin (historical cancer concern, now mostly cleared)
    'e955'    -- sucralose (gut microbiome effects, chlorinated compound)
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Classify tier 3 — high concern
--    Nitrites and nitrates: IARC Group 2A carcinogen pathway via
--    nitrosamine formation in processed meats. EFSA re-evaluation 2017+.
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE ingredient_ref SET concern_tier = 3
WHERE name_en IN (
    'e250',   -- sodium nitrite (nitrosamine formation, IARC 2A processed meat)
    'e252'    -- potassium nitrate (converts to nitrite in vivo, same pathway)
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Add ingredient_concern_score column to scores table
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE scores ADD COLUMN IF NOT EXISTS ingredient_concern_score numeric(5,2);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Compute and store ingredient_concern_score for all products
--    Formula: LEAST(100, max_tier * 25 + (sum_tiers - max_tier) * 5)
--    - Only additive ingredients count (is_additive = true)
--    - Products without additive data → 0
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE scores sc
SET ingredient_concern_score = sub.concern_score
FROM (
    SELECT
        p.product_id,
        CASE WHEN MAX(ir.concern_tier) IS NOT NULL
            THEN LEAST(100,
                MAX(ir.concern_tier) * 25
                + (SUM(ir.concern_tier) - MAX(ir.concern_tier)) * 5
            )
            ELSE 0
        END AS concern_score
    FROM products p
    LEFT JOIN product_ingredient pi ON pi.product_id = p.product_id
    LEFT JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id AND ir.is_additive = true
    WHERE p.is_deprecated IS NOT TRUE
    GROUP BY p.product_id
) sub
WHERE sc.product_id = sub.product_id;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Create v3.2 scoring function (9 factors)
--    New weight distribution (sum = 1.00):
--      sat_fat: 0.17 (was 0.18)    sugars: 0.17 (was 0.18)
--      salt: 0.17 (was 0.18)       calories: 0.10 (unchanged)
--      trans_fat: 0.11 (was 0.12)  additives: 0.07 (unchanged)
--      prep_method: 0.08 (was 0.09) controversies: 0.08 (unchanged)
--      concern_score: 0.05 (NEW)
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.compute_unhealthiness_v32(
    p_saturated_fat_g numeric,
    p_sugars_g numeric,
    p_salt_g numeric,
    p_calories numeric,
    p_trans_fat_g numeric,
    p_additives_count numeric,
    p_prep_method text,
    p_controversies text,
    p_concern_score numeric
)
RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
    SELECT GREATEST(1, LEAST(100, round(
        LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) * 0.17 +
        LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) * 0.10 +
        LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) * 0.11 +
        LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) * 0.07 +
        (CASE p_prep_method
           WHEN 'air-popped'  THEN 20
           WHEN 'steamed'     THEN 30
           WHEN 'baked'       THEN 40
           WHEN 'grilled'     THEN 60
           WHEN 'smoked'      THEN 65
           WHEN 'fried'       THEN 80
           WHEN 'deep-fried'  THEN 100
           ELSE 50
         END) * 0.08 +
        (CASE p_controversies
           WHEN 'none' THEN 0 WHEN 'minor' THEN 30
           WHEN 'moderate' THEN 60 WHEN 'serious' THEN 100 ELSE 0
         END) * 0.08 +
        LEAST(100, COALESCE(p_concern_score, 0)) * 0.05
    )))::integer;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Re-score all products using v3.2
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE scores sc
SET
    unhealthiness_score = compute_unhealthiness_v32(
        nf.saturated_fat_g,
        nf.sugars_g,
        nf.salt_g,
        nf.calories,
        nf.trans_fat_g,
        i.additives_count,
        p.prep_method,
        p.controversies,
        sc.ingredient_concern_score
    ),
    scoring_version = 'v3.2',
    scored_at = NOW()
FROM products p
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
JOIN ingredients i ON i.product_id = p.product_id
WHERE sc.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Re-sync high_additive_load flag (unchanged logic, just ensure consistency)
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE scores sc
SET high_additive_load =
    CASE WHEN i.additives_count >= 5 THEN 'YES' ELSE 'NO' END
FROM ingredients i
WHERE i.product_id = sc.product_id;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Update v_master to include ingredient_concern_score
-- ═══════════════════════════════════════════════════════════════════════════
DROP VIEW IF EXISTS public.v_master;

CREATE VIEW public.v_master AS
SELECT
    p.product_id,
    p.country,
    p.brand,
    p.product_type,
    p.category,
    p.product_name,
    p.prep_method,
    p.store_availability,
    p.is_deprecated,
    p.deprecated_reason,
    -- Nutrition (per 100 g basis)
    sv.serving_basis,
    sv.serving_amount_g_ml,
    n.calories,
    n.total_fat_g,
    n.saturated_fat_g,
    n.trans_fat_g,
    n.carbs_g,
    n.sugars_g,
    n.fibre_g,
    n.protein_g,
    n.salt_g,
    -- Per-serving data (NULL when no real serving size found)
    sv_real.serving_amount_g_ml AS serving_qty_g,
    ns.calories       AS per_serving_calories,
    ns.total_fat_g    AS per_serving_total_fat_g,
    ns.saturated_fat_g AS per_serving_saturated_fat_g,
    ns.trans_fat_g    AS per_serving_trans_fat_g,
    ns.carbs_g        AS per_serving_carbs_g,
    ns.sugars_g       AS per_serving_sugars_g,
    ns.fibre_g        AS per_serving_fibre_g,
    ns.protein_g      AS per_serving_protein_g,
    ns.salt_g         AS per_serving_salt_g,
    -- Scores
    s.unhealthiness_score,
    s.nutri_score_label,
    s.processing_risk,
    s.nova_classification,
    s.scoring_version,
    s.scored_at,
    s.data_completeness_pct,
    s.confidence,
    s.ingredient_concern_score,
    -- Flags
    s.high_salt_flag,
    s.high_sugar_flag,
    s.high_sat_fat_flag,
    s.high_additive_load,
    -- Product metadata
    p.controversies,
    -- Ingredients
    i.ingredients_raw,
    i.additives_count,
    -- Ingredient analytics (from normalized tables)
    ingr_stats.ingredient_count,
    ingr_stats.additive_names,
    ingr_stats.has_palm_oil,
    ingr_stats.vegan_status,
    ingr_stats.vegetarian_status,
    allergen_agg.allergen_count,
    allergen_agg.allergen_tags,
    trace_agg.trace_count,
    trace_agg.trace_tags,
    -- Source provenance
    p.ean,
    src.source_type,
    src.ref AS source_ref,
    src.url AS source_url,
    src.notes AS source_notes
FROM public.products p
LEFT JOIN public.servings sv
    ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
LEFT JOIN public.nutrition_facts n
    ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
LEFT JOIN public.servings sv_real
    ON sv_real.product_id = p.product_id AND sv_real.serving_basis = 'per serving'
LEFT JOIN public.nutrition_facts ns
    ON ns.product_id = p.product_id AND ns.serving_id = sv_real.serving_id
LEFT JOIN public.scores s ON s.product_id = p.product_id
LEFT JOIN public.ingredients i ON i.product_id = p.product_id
LEFT JOIN public.sources src ON src.category = p.category
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS ingredient_count,
        STRING_AGG(CASE WHEN ir.is_additive THEN ir.name_en END, ', ' ORDER BY pi.position) AS additive_names,
        BOOL_OR(ir.from_palm_oil = 'yes') AS has_palm_oil,
        CASE
            WHEN BOOL_AND(ir.vegan IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegan = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegan_status,
        CASE
            WHEN BOOL_AND(ir.vegetarian IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegetarian = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegetarian_status
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
    GROUP BY pi.product_id
) ingr_stats ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS allergen_count,
        STRING_AGG(allergen_tag, ', ' ORDER BY allergen_tag) AS allergen_tags
    FROM product_allergen pa
    WHERE pa.product_id = p.product_id
    GROUP BY pa.product_id
) allergen_agg ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS trace_count,
        STRING_AGG(trace_tag, ', ' ORDER BY trace_tag) AS trace_tags
    FROM product_trace pt
    WHERE pt.product_id = p.product_id
    GROUP BY pt.product_id
) trace_agg ON true
WHERE p.is_deprecated IS NOT TRUE;
