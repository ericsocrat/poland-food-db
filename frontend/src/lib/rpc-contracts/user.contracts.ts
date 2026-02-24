/**
 * User preferences domain RPC contracts — Zod schemas for response validation.
 *
 * Covers: api_get_user_preferences
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

import { z } from "zod";

// ─── api_get_user_preferences ───────────────────────────────────────────────

export const UserPreferencesContract = z
  .object({
    api_version: z.string(),
    user_id: z.string(),
    country: z.string().nullable(),
    preferred_language: z.string(),
    diet_preference: z.string().nullable(),
    avoid_allergens: z.array(z.string()),
    strict_allergen: z.boolean(),
    strict_diet: z.boolean(),
    treat_may_contain_as_unsafe: z.boolean(),
    health_goals: z.array(z.string()),
    favorite_categories: z.array(z.string()),
    onboarding_complete: z.boolean(),
    onboarding_completed: z.boolean(),
    onboarding_skipped: z.boolean(),
    created_at: z.string(),
    updated_at: z.string(),
  })
  .passthrough();
