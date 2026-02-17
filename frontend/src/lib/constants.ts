// ─── Constants: countries, allergens, diets ─────────────────────────────────
// Keeping these in sync with backend reference tables.

import type { ScoreBand } from "@/lib/types";

export const COUNTRIES = [
  { code: "DE", name: "Germany", native: "Deutschland", flag: "🇩🇪" },
  { code: "PL", name: "Poland", native: "Polska", flag: "🇵🇱" },
] as const;

export const LANGUAGES = [
  { code: "en", name: "English", native: "English", flag: "🇬🇧" },
  { code: "pl", name: "Polish", native: "Polski", flag: "🇵🇱" },
  { code: "de", name: "German", native: "Deutsch", flag: "🇩🇪" },
] as const;

/**
 * Maps country codes to their default (native) language.
 * Each country offers exactly 2 languages: its native language + English.
 * Kept in sync with country_ref.default_language in the database.
 */
export const COUNTRY_DEFAULT_LANGUAGES: Record<string, string> = {
  PL: "pl",
  DE: "de",
} as const;

/** Get the available languages for a country: [native, English]. */
export function getLanguagesForCountry(countryCode: string) {
  const nativeLang = COUNTRY_DEFAULT_LANGUAGES[countryCode] ?? "en";
  return LANGUAGES.filter((l) => l.code === nativeLang || l.code === "en");
}

export const ALLERGEN_TAGS = [
  { tag: "en:gluten", label: "Gluten" },
  { tag: "en:milk", label: "Milk / Dairy" },
  { tag: "en:eggs", label: "Eggs" },
  { tag: "en:nuts", label: "Tree Nuts" },
  { tag: "en:peanuts", label: "Peanuts" },
  { tag: "en:soybeans", label: "Soy" },
  { tag: "en:fish", label: "Fish" },
  { tag: "en:crustaceans", label: "Crustaceans" },
  { tag: "en:celery", label: "Celery" },
  { tag: "en:mustard", label: "Mustard" },
  { tag: "en:sesame-seeds", label: "Sesame" },
  { tag: "en:sulphur-dioxide-and-sulphites", label: "Sulphites" },
  { tag: "en:lupin", label: "Lupin" },
  { tag: "en:molluscs", label: "Molluscs" },
] as const;

export const DIET_OPTIONS = [
  { value: "none", label: "No restriction" },
  { value: "vegetarian", label: "Vegetarian" },
  { value: "vegan", label: "Vegan" },
] as const;

// Score band display config
export const SCORE_BANDS = {
  low: { label: "Low", color: "text-score-green", bg: "bg-score-green/10" },
  moderate: { label: "Moderate", color: "text-score-yellow", bg: "bg-score-yellow/10" },
  high: { label: "High", color: "text-score-orange", bg: "bg-score-orange/10" },
  very_high: { label: "Very High", color: "text-score-red", bg: "bg-score-red/10" },
} as const;

/** Map a 0-100 unhealthiness score to a score band key. */
export function scoreBandFromScore(score: number): ScoreBand {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

// Nutri-Score display config
export const NUTRI_COLORS: Record<string, string> = {
  A: "bg-nutri-A text-foreground-inverse",
  B: "bg-nutri-B text-foreground-inverse",
  C: "bg-nutri-C text-foreground",
  D: "bg-nutri-D text-foreground-inverse",
  E: "bg-nutri-E text-foreground-inverse",
};

// Health conditions for personal health profiles
export const HEALTH_CONDITIONS = [
  { value: "diabetes", label: "Diabetes", icon: "🩸" },
  { value: "hypertension", label: "Hypertension", icon: "💓" },
  { value: "heart_disease", label: "Heart Disease", icon: "❤️" },
  { value: "celiac_disease", label: "Celiac Disease", icon: "🌾" },
  { value: "gout", label: "Gout", icon: "🦴" },
  { value: "kidney_disease", label: "Kidney Disease", icon: "🫘" },
  { value: "ibs", label: "IBS", icon: "🫃" },
] as const;

// Warning severity display config
export const WARNING_SEVERITY = {
  critical: {
    label: "Critical",
    color: "text-error",
    bg: "bg-error/10",
    border: "border-error/30",
  },
  high: {
    label: "High",
    color: "text-warning",
    bg: "bg-warning/10",
    border: "border-warning/30",
  },
  moderate: {
    label: "Moderate",
    color: "text-warning",
    bg: "bg-warning/10",
    border: "border-warning/30",
  },
} as const;

/** Concern-tier styling: maps tier 0-3 to colors matching EFSA risk bands. */
export const CONCERN_TIER_STYLES: Record<
  number,
  { color: string; bg: string; border: string }
> = {
  0: { color: "text-confidence-high", bg: "bg-confidence-high/10", border: "border-confidence-high/30" },
  1: { color: "text-confidence-medium", bg: "bg-confidence-medium/10", border: "border-confidence-medium/30" },
  2: { color: "text-warning", bg: "bg-warning/10", border: "border-warning/30" },
  3: { color: "text-error", bg: "bg-error/10", border: "border-error/30" },
};
