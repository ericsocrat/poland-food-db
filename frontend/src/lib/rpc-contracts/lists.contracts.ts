/**
 * Lists domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_get_lists, api_get_list_items
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { ListTypeSchema } from "./helpers";

// ─── api_get_lists ──────────────────────────────────────────────────────────

export const ListsContract = z
  .object({
    api_version: z.string(),
    lists: z.array(
      z
        .object({
          id: z.string(),
          name: z.string(),
          description: z.string().nullable(),
          list_type: ListTypeSchema,
          is_default: z.boolean(),
          share_enabled: z.boolean(),
          share_token: z.string().nullable(),
          item_count: z.number(),
          created_at: z.string(),
          updated_at: z.string(),
        })
        .passthrough(),
    ),
  })
  .passthrough();

// ─── api_get_list_items ─────────────────────────────────────────────────────

export const ListItemsContract = z
  .object({
    api_version: z.string(),
    list_id: z.string(),
    list_name: z.string(),
    list_type: ListTypeSchema,
    description: z.string().nullable(),
    total_count: z.number(),
    limit: z.number(),
    offset: z.number(),
    items: z.array(
      z
        .object({
          item_id: z.string(),
          product_id: z.number(),
          position: z.number(),
          notes: z.string().nullable(),
          added_at: z.string(),
          product_name: z.string(),
          brand: z.string(),
          category: z.string(),
          unhealthiness_score: z.number(),
          nutri_score_label: z.string(),
          nova_classification: z.string(),
          calories: z.number().nullable(),
        })
        .passthrough(),
    ),
  })
  .passthrough();
