/**
 * Category domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_category_overview, api_category_listing
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema, ScoreBandSchema } from "./helpers";

// ─── api_category_overview ──────────────────────────────────────────────────

export const CategoryOverviewItemSchema = z
  .object({
    category: z.string(),
    slug: z.string(),
    display_name: z.string(),
    product_count: z.number(),
  })
  .passthrough();

export const CategoryOverviewContract = z
  .object({
    api_version: z.string(),
    country: z.string(),
    categories: z.array(CategoryOverviewItemSchema),
  })
  .passthrough();

// ─── api_category_listing ───────────────────────────────────────────────────

const CategoryProductSchema = z
  .object({
    product_id: z.number(),
    ean: z.string().nullable(),
    product_name: z.string(),
    brand: z.string(),
    unhealthiness_score: z.number(),
    score_band: ScoreBandSchema,
    nutri_score: NutriGradeSchema,
    nova_group: z.string(),
    processing_risk: z.string(),
    calories: z.number(),
    total_fat_g: z.number(),
    protein_g: z.number(),
    sugars_g: z.number(),
    salt_g: z.number(),
    high_salt_flag: z.boolean(),
    high_sugar_flag: z.boolean(),
    high_sat_fat_flag: z.boolean(),
    confidence: z.string(),
    data_completeness_pct: z.number(),
    image_thumb_url: z.string().nullable(),
  })
  .passthrough();

export const CategoryListingContract = z
  .object({
    api_version: z.string(),
    category: z.string(),
    country: z.string(),
    total_count: z.number(),
    limit: z.number(),
    offset: z.number(),
    sort_by: z.string(),
    sort_dir: z.string(),
    products: z.array(CategoryProductSchema),
  })
  .passthrough();
