/**
 * Compare domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_get_products_for_compare
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema, ScoreBandSchema } from "./helpers";

// ─── api_get_products_for_compare ───────────────────────────────────────────

const CompareProductSchema = z
  .object({
    product_id: z.number(),
    ean: z.string().nullable(),
    product_name: z.string(),
    brand: z.string(),
    category: z.string(),
    category_display: z.string(),
    category_icon: z.string(),
    unhealthiness_score: z.number(),
    score_band: ScoreBandSchema,
    nutri_score: NutriGradeSchema,
    nova_group: z.string(),
    processing_risk: z.string(),
    calories: z.number(),
    total_fat_g: z.number(),
    saturated_fat_g: z.number(),
    trans_fat_g: z.number().nullable(),
    carbs_g: z.number(),
    sugars_g: z.number(),
    fibre_g: z.number().nullable(),
    protein_g: z.number(),
    salt_g: z.number(),
    high_salt: z.boolean(),
    high_sugar: z.boolean(),
    high_sat_fat: z.boolean(),
    high_additive_load: z.boolean(),
    additives_count: z.number(),
    ingredient_count: z.number(),
    allergen_count: z.number(),
    allergen_tags: z.string().nullable(),
    trace_tags: z.string().nullable(),
    confidence: z.string(),
    data_completeness_pct: z.number(),
  })
  .passthrough();

export const CompareContract = z
  .object({
    api_version: z.string(),
    product_count: z.number(),
    products: z.array(CompareProductSchema),
  })
  .passthrough();
