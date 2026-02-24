/**
 * Shared Zod schema fragments for RPC contract validation.
 *
 * These enums and utility schemas are reused across multiple domain contracts.
 * All schemas use `.passthrough()` on objects to allow forward-compatible
 * additions without breaking existing contract tests.
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";

// ─── Shared enums ───────────────────────────────────────────────────────────

/** Score severity band (matches `ScoreBand` TypeScript type). */
export const ScoreBandSchema = z.enum(["low", "moderate", "high", "very_high"]);

/** Nutri-Score grade A–E, nullable when unavailable. */
export const NutriGradeSchema = z
  .enum(["A", "B", "C", "D", "E"])
  .nullable();

/** User-created list type. */
export const ListTypeSchema = z.enum(["favorites", "avoid", "custom"]);

/** Health warning severity levels. */
export const WarningSeveritySchema = z.enum(["critical", "high", "moderate"]);

/** Supported health conditions. */
export const HealthConditionSchema = z.enum([
  "diabetes",
  "hypertension",
  "heart_disease",
  "celiac_disease",
  "gout",
  "kidney_disease",
  "ibs",
]);

// ─── Shared fragments ───────────────────────────────────────────────────────

/** Every envelope response includes `api_version`. */
export const ApiVersionFragment = z.object({
  api_version: z.string(),
});
