/**
 * Zod validation schemas — single source of truth for all form validation.
 *
 * Error message values are i18n keys (e.g. "validation.email_invalid").
 * The consuming form passes these keys through `t()` before display.
 *
 * @see Issue #69 — Form Validation UX Standard
 */

import { z } from "zod";

// ─── Reusable field validators ──────────────────────────────────────────────

/** Valid email address. */
export const emailSchema = z.email({ message: "validation.email_invalid" });

/** Non-empty required string. `key` is used to build the i18n error key. */
export const requiredStringSchema = (key: string) =>
  z.string().check(
    z.minLength(1, { message: `validation.${key}_required` }),
  );

/** Password with minimum length. */
export const passwordSchema = z.string().check(
  z.minLength(6, { message: "validation.password_min_length" }),
);

// ─── Form-specific schemas ──────────────────────────────────────────────────

/** Auth — Login form. */
export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().check(
    z.minLength(1, { message: "validation.password_required" }),
  ),
});
export type LoginFormData = z.infer<typeof loginSchema>;

/** Auth — Signup form. */
export const signupSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});
export type SignupFormData = z.infer<typeof signupSchema>;

/** Onboarding wizard. */
export const onboardingSchema = z.object({
  country: z.enum(["PL", "DE"], { message: "validation.country_required" }),
  language: z.enum(["en", "pl", "de"], {
    message: "validation.language_required",
  }),
  diet: z.string().optional(),
  allergens: z.array(z.string()).default([]),
  healthGoals: z.array(z.string()).default([]),
  favoriteCategories: z.array(z.string()).default([]),
});
export type OnboardingFormData = z.infer<typeof onboardingSchema>;

/** List create / edit. */
export const listSchema = z.object({
  name: z.string().check(
    z.minLength(1, { message: "validation.list_name_required" }),
    z.maxLength(100, { message: "validation.list_name_too_long" }),
  ),
  description: z
    .string()
    .check(z.maxLength(500, { message: "validation.description_too_long" }))
    .optional(),
});
export type ListFormData = z.infer<typeof listSchema>;

/** Health profile. */
export const healthProfileSchema = z.object({
  name: z.string().check(
    z.minLength(1, { message: "validation.profile_name_required" }),
  ),
  conditions: z.array(z.string()).default([]),
  sugarLimitG: z
    .number()
    .min(0, { message: "validation.must_be_positive" })
    .max(500, { message: "validation.limit_too_high" })
    .optional(),
  sodiumLimitMg: z
    .number()
    .min(0, { message: "validation.must_be_positive" })
    .max(10000, { message: "validation.limit_too_high" })
    .optional(),
  saturatedFatLimitG: z
    .number()
    .min(0, { message: "validation.must_be_positive" })
    .max(200, { message: "validation.limit_too_high" })
    .optional(),
});
export type HealthProfileFormData = z.infer<typeof healthProfileSchema>;

/** Contact / feedback form. */
export const contactSchema = z.object({
  email: emailSchema,
  message: z.string().check(
    z.minLength(10, { message: "validation.message_too_short" }),
    z.maxLength(2000, { message: "validation.message_too_long" }),
  ),
});
export type ContactFormData = z.infer<typeof contactSchema>;

/** Product submission form. */
export const productSubmissionSchema = z.object({
  ean: z
    .string()
    .check(
      z.minLength(1, { message: "validation.ean_required" }),
      z.regex(/^\d{8}$|^\d{13}$/, { message: "validation.ean_format" }),
    ),
  name: z.string().check(
    z.minLength(1, { message: "validation.product_name_required" }),
  ),
  brand: z.string().optional(),
  category: z.string().optional(),
  notes: z
    .string()
    .check(z.maxLength(500, { message: "validation.notes_too_long" }))
    .optional(),
});
export type ProductSubmissionFormData = z.infer<typeof productSubmissionSchema>;
