/**
 * Data Provenance domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_product_provenance, admin_provenance_dashboard,
 *         validate_product_for_country
 *
 * @see Issue #193 — Data Provenance & Freshness Governance
 */

import { z } from "zod";

// ─── Field source entry ─────────────────────────────────────────────────────

const FieldSourceSchema = z
  .object({
    source: z.string(),
    last_updated: z.string(),
    confidence: z.number(),
  })
  .passthrough();

const WeakestAreaSchema = z
  .object({
    field: z.string().nullable(),
    confidence: z.number().nullable(),
  })
  .passthrough();

// ─── api_product_provenance ─────────────────────────────────────────────────

/** Full provenance summary for a single product. */
export const ProductProvenanceContract = z
  .object({
    api_version: z.string(),
    product_id: z.number(),
    product_name: z.string(),
    overall_trust_score: z.number().nullable(),
    freshness_status: z.string(),
    source_count: z.number().nullable(),
    data_completeness_pct: z.number().nullable(),
    field_sources: z.record(z.string(), FieldSourceSchema).nullable(),
    trust_explanation: z.string(),
    weakest_area: WeakestAreaSchema,
  })
  .passthrough();

// ─── Validation issue ───────────────────────────────────────────────────────

const ValidationIssueSchema = z
  .object({
    check: z.string(),
    status: z.enum(["fail", "warning"]),
    detail: z.string(),
  })
  .passthrough();

// ─── validate_product_for_country ───────────────────────────────────────────

/** Country validation result for a product. */
export const CountryValidationContract = z
  .object({
    product_id: z.number(),
    country: z.string(),
    ready_for_publish: z.boolean(),
    overall_confidence: z.number().nullable(),
    staleness_risk: z.string().nullable(),
    source_diversity: z.number().nullable(),
    issues: z.array(ValidationIssueSchema),
    validated_at: z.string(),
  })
  .passthrough();

// ─── Freshness policy ───────────────────────────────────────────────────────

const FreshnessPolicySchema = z
  .object({
    field_group: z.string(),
    max_age_days: z.number(),
    warning_age_days: z.number(),
    refresh_strategy: z.string(),
  })
  .passthrough();

// ─── admin_provenance_dashboard ─────────────────────────────────────────────

/** Admin provenance health overview per country. */
export const ProvenanceDashboardContract = z
  .object({
    api_version: z.string(),
    country: z.string(),
    generated_at: z.string(),
    total_products: z.number(),
    with_provenance: z.number(),
    without_provenance: z.number(),
    open_conflicts: z.number(),
    critical_conflicts: z.number(),
    source_distribution: z.record(z.string(), z.number()).nullable(),
    policies: z.array(FreshnessPolicySchema),
  })
  .passthrough();
