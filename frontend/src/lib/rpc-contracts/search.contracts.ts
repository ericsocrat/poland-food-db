/**
 * Search domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_search_products, api_search_autocomplete,
 *         api_get_filter_options, api_get_saved_searches
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema, ScoreBandSchema } from "./helpers";

// ─── api_search_products ────────────────────────────────────────────────────

const SearchResultSchema = z
  .object({
    product_id: z.number(),
    product_name: z.string(),
    product_name_en: z.string().nullable(),
    product_name_display: z.string(),
    brand: z.string(),
    category: z.string(),
    category_display: z.string(),
    category_icon: z.string(),
    unhealthiness_score: z.number(),
    score_band: ScoreBandSchema,
    nutri_score: NutriGradeSchema,
    nova_group: z.string(),
    calories: z.number().nullable(),
    high_salt: z.boolean(),
    high_sugar: z.boolean(),
    high_sat_fat: z.boolean(),
    high_additive_load: z.boolean(),
    is_avoided: z.boolean(),
    relevance: z.number(),
    image_thumb_url: z.string().nullable(),
  })
  .passthrough();

export const SearchProductsContract = z
  .object({
    api_version: z.string(),
    query: z.string().nullable(),
    country: z.string(),
    total: z.number(),
    page: z.number(),
    pages: z.number(),
    page_size: z.number(),
    filters_applied: z.record(z.string(), z.unknown()).nullable(),
    results: z.array(SearchResultSchema),
  })
  .passthrough();

// ─── api_search_autocomplete ────────────────────────────────────────────────

const AutocompleteSuggestionSchema = z
  .object({
    product_id: z.number(),
    product_name: z.string(),
    product_name_en: z.string().nullable(),
    product_name_display: z.string(),
    brand: z.string(),
    category: z.string(),
    nutri_score: NutriGradeSchema,
    unhealthiness_score: z.number(),
    score_band: ScoreBandSchema,
  })
  .passthrough();

export const SearchAutocompleteContract = z
  .object({
    api_version: z.string(),
    query: z.string(),
    suggestions: z.array(AutocompleteSuggestionSchema),
  })
  .passthrough();

// ─── api_get_filter_options ─────────────────────────────────────────────────

export const FilterOptionsContract = z
  .object({
    api_version: z.string(),
    country: z.string(),
    categories: z.array(
      z
        .object({
          category: z.string(),
          display_name: z.string(),
          icon_emoji: z.string(),
          count: z.number(),
        })
        .passthrough(),
    ),
    nutri_scores: z.array(
      z
        .object({
          label: z.string(),
          count: z.number(),
        })
        .passthrough(),
    ),
    nova_groups: z.array(
      z
        .object({
          group: z.string(),
          count: z.number(),
        })
        .passthrough(),
    ),
    allergens: z.array(
      z
        .object({
          tag: z.string(),
          count: z.number(),
        })
        .passthrough(),
    ),
  })
  .passthrough();

// ─── api_get_saved_searches ─────────────────────────────────────────────────

export const SavedSearchesContract = z
  .object({
    api_version: z.string(),
    searches: z.array(
      z
        .object({
          id: z.string(),
          name: z.string(),
          query: z.string().nullable(),
          filters: z.record(z.string(), z.unknown()),
          created_at: z.string(),
        })
        .passthrough(),
    ),
  })
  .passthrough();

// ─── search_quality_report ──────────────────────────────────────────────────

const PlannedMetricsSchema = z
  .object({
    total_searches: z.number().nullable(),
    unique_queries: z.number().nullable(),
    zero_result_rate: z.number().nullable(),
    click_through_rate: z.number().nullable(),
    mean_reciprocal_rank: z.number().nullable(),
    avg_results_per_query: z.number().nullable(),
    top_zero_result_queries: z.array(z.unknown()),
    top_queries: z.array(z.unknown()),
  })
  .passthrough();

export const SearchQualityReportContract = z
  .object({
    api_version: z.string(),
    status: z.string(),
    period_days: z.number(),
    country: z.string(),
    planned_metrics: PlannedMetricsSchema,
  })
  .passthrough();

