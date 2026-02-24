/**
 * Scan domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_get_scan_history
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";
import { NutriGradeSchema } from "./helpers";

// ─── api_get_scan_history ───────────────────────────────────────────────────

const ScanHistoryItemSchema = z
  .object({
    scan_id: z.string(),
    ean: z.string(),
    found: z.boolean(),
    scanned_at: z.string(),
    product_id: z.number().nullable(),
    product_name: z.string().nullable(),
    brand: z.string().nullable(),
    category: z.string().nullable(),
    unhealthiness_score: z.number().nullable(),
    nutri_score: NutriGradeSchema,
    submission_status: z.string().nullable(),
  })
  .passthrough();

export const ScanHistoryContract = z
  .object({
    api_version: z.string(),
    total: z.number(),
    page: z.number(),
    pages: z.number(),
    page_size: z.number(),
    filter: z.string(),
    scans: z.array(ScanHistoryItemSchema),
  })
  .passthrough();
