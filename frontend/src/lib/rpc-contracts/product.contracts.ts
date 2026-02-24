/**
 * Product domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_product_detail, api_better_alternatives,
 *         api_score_explanation, api_data_confidence
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema, ScoreBandSchema } from "./helpers";

// ─── api_product_detail ─────────────────────────────────────────────────────

const ProductScoresSchema = z
  .object({
    unhealthiness_score: z.number(),
    score_band: ScoreBandSchema,
    nutri_score: NutriGradeSchema,
    nutri_score_color: z.string(),
    nova_group: z.string(),
    processing_risk: z.string(),
  })
  .passthrough();

const ProductFlagsSchema = z
  .object({
    high_salt: z.boolean(),
    high_sugar: z.boolean(),
    high_sat_fat: z.boolean(),
    high_additive_load: z.boolean(),
    has_palm_oil: z.boolean(),
  })
  .passthrough();

const NutritionPer100gSchema = z
  .object({
    calories: z.number(),
    total_fat_g: z.number(),
    saturated_fat_g: z.number(),
    trans_fat_g: z.number().nullable(),
    carbs_g: z.number(),
    sugars_g: z.number(),
    fibre_g: z.number().nullable(),
    protein_g: z.number(),
    salt_g: z.number(),
  })
  .passthrough();

const IngredientsSchema = z
  .object({
    count: z.number(),
    additives_count: z.number(),
    additive_names: z.array(z.string()),
    vegan_status: z.string(),
    vegetarian_status: z.string(),
    data_quality: z.string(),
  })
  .passthrough();

const AllergensSchema = z
  .object({
    count: z.number(),
    tags: z.array(z.string()),
    trace_count: z.number(),
    trace_tags: z.array(z.string()),
  })
  .passthrough();

const TrustSchema = z
  .object({
    confidence: z.string(),
    data_completeness_pct: z.number(),
    source_type: z.string(),
    nutrition_data_quality: z.string(),
    ingredient_data_quality: z.string(),
  })
  .passthrough();

const FreshnessSchema = z
  .object({
    created_at: z.string(),
    updated_at: z.string(),
    data_age_days: z.number(),
  })
  .passthrough();

/** Full product detail envelope. */
export const ProductDetailContract = z
  .object({
    api_version: z.string(),
    product_id: z.number(),
    ean: z.string().nullable(),
    product_name: z.string(),
    product_name_en: z.string().nullable(),
    product_name_display: z.string(),
    original_language: z.string(),
    brand: z.string(),
    category: z.string(),
    category_display: z.string(),
    category_icon: z.string(),
    product_type: z.string().nullable(),
    country: z.string(),
    store_availability: z.string().nullable(),
    prep_method: z.string().nullable(),
    scores: ProductScoresSchema,
    flags: ProductFlagsSchema,
    nutrition_per_100g: NutritionPer100gSchema,
    ingredients: IngredientsSchema,
    allergens: AllergensSchema,
    trust: TrustSchema,
    freshness: FreshnessSchema,
  })
  .passthrough();

// ─── api_better_alternatives ────────────────────────────────────────────────

const AlternativeSchema = z
  .object({
    product_id: z.number(),
    product_name: z.string(),
    brand: z.string(),
    category: z.string(),
    unhealthiness_score: z.number(),
    score_improvement: z.number(),
    nutri_score: NutriGradeSchema,
    similarity: z.number(),
    shared_ingredients: z.number(),
  })
  .passthrough();

export const BetterAlternativesContract = z
  .object({
    api_version: z.string(),
    source_product: z
      .object({
        product_id: z.number(),
        product_name: z.string(),
        brand: z.string(),
        category: z.string(),
        unhealthiness_score: z.number(),
        nutri_score: NutriGradeSchema,
      })
      .passthrough(),
    search_scope: z.string(),
    alternatives: z.array(AlternativeSchema),
    alternatives_count: z.number(),
  })
  .passthrough();

// ─── api_score_explanation ──────────────────────────────────────────────────

export const ScoreExplanationContract = z
  .object({
    api_version: z.string(),
    product_id: z.number(),
    product_name: z.string(),
    brand: z.string(),
    category: z.string(),
    score_breakdown: z.record(z.string(), z.unknown()),
    model_version: z.string().nullable().optional(),
    scored_at: z.string().nullable().optional(),
    summary: z
      .object({
        score: z.number(),
        score_band: ScoreBandSchema,
        headline: z.string(),
        nutri_score: NutriGradeSchema,
        nova_group: z.string(),
        processing_risk: z.string(),
      })
      .passthrough(),
    top_factors: z.array(
      z
        .object({
          factor: z.string(),
          raw: z.number(),
          weighted: z.number(),
        })
        .passthrough(),
    ),
    warnings: z.array(
      z
        .object({
          type: z.string(),
          message: z.string(),
        })
        .passthrough(),
    ),
    category_context: z
      .object({
        category_avg_score: z.number(),
        category_rank: z.number(),
        category_total: z.number(),
        relative_position: z.string(),
      })
      .passthrough(),
  })
  .passthrough();

// ─── api_data_confidence ────────────────────────────────────────────────────

/** Loose contract — DataConfidence has many dynamic fields. */
export const DataConfidenceContract = z
  .object({
    api_version: z.string(),
  })
  .passthrough();
