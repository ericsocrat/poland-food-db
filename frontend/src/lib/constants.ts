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

/**
 * Common allergen presets — each preset maps to a set of ALLERGEN_TAGS entries.
 * Used by the settings page for quick-select allergen profiles.
 */
export const ALLERGEN_PRESETS = [
  {
    key: "glutenFree",
    labelKey: "allergenPreset.glutenFree",
    tags: ["en:gluten"],
  },
  {
    key: "dairyFree",
    labelKey: "allergenPreset.dairyFree",
    tags: ["en:milk"],
  },
  {
    key: "nutFree",
    labelKey: "allergenPreset.nutFree",
    tags: ["en:nuts", "en:peanuts"],
  },
  {
    key: "vegan",
    labelKey: "allergenPreset.vegan",
    tags: ["en:milk", "en:eggs", "en:fish", "en:crustaceans", "en:molluscs"],
  },
] as const;

export const DIET_OPTIONS = [
  { value: "none", label: "No restriction" },
  { value: "vegetarian", label: "Vegetarian" },
  { value: "vegan", label: "Vegan" },
] as const;

export const HEALTH_GOALS = [
  { value: "diabetes", labelKey: "onboarding.goalDiabetes", descKey: "onboarding.goalDiabetesDesc" },
  { value: "low_sodium", labelKey: "onboarding.goalLowSodium", descKey: "onboarding.goalLowSodiumDesc" },
  { value: "heart_health", labelKey: "onboarding.goalHeartHealth", descKey: "onboarding.goalHeartHealthDesc" },
  { value: "weight_management", labelKey: "onboarding.goalWeightMgmt", descKey: "onboarding.goalWeightMgmtDesc" },
  { value: "general_wellness", labelKey: "onboarding.goalWellness", descKey: "onboarding.goalWellnessDesc" },
] as const;

export const FOOD_CATEGORIES = [
  { slug: "bread", emoji: "🍞", labelKey: "onboarding.catBread" },
  { slug: "breakfast-grain-based", emoji: "🥣", labelKey: "onboarding.catBreakfast" },
  { slug: "canned-goods", emoji: "🥫", labelKey: "onboarding.catCanned" },
  { slug: "cereals", emoji: "🥣", labelKey: "onboarding.catCereals" },
  { slug: "chips", emoji: "🍟", labelKey: "onboarding.catChips" },
  { slug: "condiments", emoji: "🫙", labelKey: "onboarding.catCondiments" },
  { slug: "dairy", emoji: "🧀", labelKey: "onboarding.catDairy" },
  { slug: "drinks", emoji: "🥤", labelKey: "onboarding.catDrinks" },
  { slug: "frozen-prepared", emoji: "🧊", labelKey: "onboarding.catFrozen" },
  { slug: "instant-frozen", emoji: "🍜", labelKey: "onboarding.catInstant" },
  { slug: "meat", emoji: "🥩", labelKey: "onboarding.catMeat" },
  { slug: "nuts-seeds-legumes", emoji: "🥜", labelKey: "onboarding.catNuts" },
  { slug: "plant-based-alternatives", emoji: "🌱", labelKey: "onboarding.catPlantBased" },
  { slug: "sauces", emoji: "🫗", labelKey: "onboarding.catSauces" },
  { slug: "seafood-fish", emoji: "🐟", labelKey: "onboarding.catSeafood" },
  { slug: "snacks", emoji: "🍿", labelKey: "onboarding.catSnacks" },
  { slug: "sweets", emoji: "🍫", labelKey: "onboarding.catSweets" },
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

/** Maps concern tier number to its i18n label key (ingredient.tierNone etc.). */
export const CONCERN_TIER_LABEL_KEYS: Record<number, string> = {
  0: "ingredient.tierNone",
  1: "ingredient.tierLow",
  2: "ingredient.tierModerate",
  3: "ingredient.tierHigh",
};

/**
 * Score interpretation bands — maps score ranges to i18n keys and colors.
 * Used for the expandable "What does this score mean?" section on product detail.
 */
export const SCORE_INTERPRETATION_BANDS = [
  { min: 0, max: 20, key: "scoreInterpretation.green", color: "text-green-700", bg: "bg-green-50" },
  { min: 21, max: 40, key: "scoreInterpretation.yellow", color: "text-yellow-700", bg: "bg-yellow-50" },
  { min: 41, max: 60, key: "scoreInterpretation.orange", color: "text-orange-700", bg: "bg-orange-50" },
  { min: 61, max: 80, key: "scoreInterpretation.red", color: "text-red-700", bg: "bg-red-50" },
  { min: 81, max: 100, key: "scoreInterpretation.darkRed", color: "text-red-900", bg: "bg-red-100" },
] as const;

/** Get the score interpretation band for a given 0-100 score. */
export function getScoreInterpretation(score: number) {
  return (
    SCORE_INTERPRETATION_BANDS.find((b) => score >= b.min && score <= b.max) ??
    SCORE_INTERPRETATION_BANDS[SCORE_INTERPRETATION_BANDS.length - 1]
  );
}

/**
 * Traffic-light thresholds per nutrient (per 100g), used by TrafficLightStrip.
 * Mirrors the thresholds in TrafficLightChip but includes fibre as beneficial.
 */
export const TRAFFIC_LIGHT_NUTRIENTS = [
  { nutrient: "total_fat", labelKey: "product.totalFat" },
  { nutrient: "saturated_fat", labelKey: "product.saturatedFat" },
  { nutrient: "sugars", labelKey: "product.sugars" },
  { nutrient: "salt", labelKey: "product.salt" },
] as const;
