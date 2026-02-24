/**
 * Dashboard domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_get_dashboard_data, api_get_recently_viewed
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema } from "./helpers";

// ─── Shared fragments ───────────────────────────────────────────────────────

const RecentlyViewedProductSchema = z
  .object({
    product_id: z.number(),
    product_name: z.string(),
    brand: z.string().nullable(),
    category: z.string(),
    country: z.string(),
    unhealthiness_score: z.number().nullable(),
    nutri_score_label: NutriGradeSchema,
    viewed_at: z.string(),
    image_thumb_url: z.string().nullable(),
  })
  .passthrough();

// ─── api_get_dashboard_data ─────────────────────────────────────────────────

export const DashboardDataContract = z
  .object({
    api_version: z.string(),
    recently_viewed: z.array(RecentlyViewedProductSchema),
    favorites_preview: z.array(
      z
        .object({
          product_id: z.number(),
          product_name: z.string(),
          brand: z.string().nullable(),
          category: z.string(),
          country: z.string(),
          unhealthiness_score: z.number().nullable(),
          nutri_score_label: NutriGradeSchema,
          added_at: z.string(),
          image_thumb_url: z.string().nullable(),
        })
        .passthrough(),
    ),
    new_products: z.array(
      z
        .object({
          product_id: z.number(),
          product_name: z.string(),
          brand: z.string().nullable(),
          category: z.string(),
          country: z.string(),
          unhealthiness_score: z.number().nullable(),
          nutri_score_label: NutriGradeSchema,
          image_thumb_url: z.string().nullable(),
        })
        .passthrough(),
    ),
    stats: z
      .object({
        total_scanned: z.number(),
        total_viewed: z.number(),
        lists_count: z.number(),
        favorites_count: z.number(),
        most_viewed_category: z.string().nullable(),
      })
      .passthrough(),
  })
  .passthrough();

// ─── api_get_recently_viewed ────────────────────────────────────────────────

export const RecentlyViewedContract = z
  .object({
    api_version: z.string(),
    products: z.array(RecentlyViewedProductSchema),
  })
  .passthrough();
