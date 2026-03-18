// ─── Constants: countries, allergens, diets ─────────────────────────────────
// Keeping these in sync with backend reference tables.

import type { ScoreBand } from "@/lib/types";

export const COUNTRIES = [
  { code: "DE", name: "Germany", native: "Deutschland", flag: "🇩🇪" },
  { code: "PL", name: "Poland", native: "Polska", flag: "🇵🇱" },
] as const;

export const LANGUAGES = [
  { code: "en", name: "English", native: "English" },
  { code: "pl", name: "Polish", native: "Polski" },
  { code: "de", name: "German", native: "Deutsch" },
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

/** Get flag emoji for any ISO 3166-1 alpha-2 country code via regional indicator symbols. */
export function getCountryFlag(code: string): string {
  if (!/^[A-Z]{2}$/i.test(code)) return "🌐";
  const upper = code.toUpperCase();
  return String.fromCodePoint(
    ...([...upper].map((c) => 0x1f1e6 + c.charCodeAt(0) - 65)),
  );
}

/** Get English display name for a country code. Falls back to the code itself. */
export function getCountryName(code: string): string {
  return COUNTRIES.find((c) => c.code === code)?.name ?? code;
}

/** Get the available languages for a country: [native, English]. */
export function getLanguagesForCountry(countryCode: string) {
  const nativeLang = COUNTRY_DEFAULT_LANGUAGES[countryCode] ?? "en";
  return LANGUAGES.filter((l) => l.code === nativeLang || l.code === "en");
}

export const ALLERGEN_TAGS = [
  { tag: "gluten", labelKey: "allergens.gluten" },
  { tag: "milk", labelKey: "allergens.milk" },
  { tag: "eggs", labelKey: "allergens.eggs" },
  { tag: "tree-nuts", labelKey: "allergens.tree-nuts" },
  { tag: "peanuts", labelKey: "allergens.peanuts" },
  { tag: "soybeans", labelKey: "allergens.soybeans" },
  { tag: "fish", labelKey: "allergens.fish" },
  { tag: "crustaceans", labelKey: "allergens.crustaceans" },
  { tag: "celery", labelKey: "allergens.celery" },
  { tag: "mustard", labelKey: "allergens.mustard" },
  { tag: "sesame", labelKey: "allergens.sesame" },
  { tag: "sulphites", labelKey: "allergens.sulphites" },
  { tag: "lupin", labelKey: "allergens.lupin" },
  { tag: "molluscs", labelKey: "allergens.molluscs" },
] as const;

/**
 * Common allergen presets — each preset maps to a set of ALLERGEN_TAGS entries.
 * Used by the settings page for quick-select allergen profiles.
 */
export const ALLERGEN_PRESETS = [
  {
    key: "glutenFree",
    labelKey: "allergenPreset.glutenFree",
    tags: ["gluten"],
  },
  {
    key: "dairyFree",
    labelKey: "allergenPreset.dairyFree",
    tags: ["milk"],
  },
  {
    key: "nutFree",
    labelKey: "allergenPreset.nutFree",
    tags: ["tree-nuts", "peanuts"],
  },
  {
    key: "vegan",
    labelKey: "allergenPreset.vegan",
    tags: ["milk", "eggs", "fish", "crustaceans", "molluscs"],
  },
] as const;

export const DIET_OPTIONS = [
  { value: "none", labelKey: "diet.none" },
  { value: "vegetarian", labelKey: "diet.vegetarian" },
  { value: "vegan", labelKey: "diet.vegan" },
] as const;

export const HEALTH_GOALS = [
  { value: "diabetes", labelKey: "onboarding.goalDiabetes", descKey: "onboarding.goalDiabetesDesc" },
  { value: "low_sodium", labelKey: "onboarding.goalLowSodium", descKey: "onboarding.goalLowSodiumDesc" },
  { value: "heart_health", labelKey: "onboarding.goalHeartHealth", descKey: "onboarding.goalHeartHealthDesc" },
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
  { slug: "oils-vinegars", emoji: "🫒", labelKey: "onboarding.catOils" },
  { slug: "plant-based-alternatives", emoji: "🌱", labelKey: "onboarding.catPlantBased" },
  { slug: "sauces", emoji: "🫗", labelKey: "onboarding.catSauces" },
  { slug: "seafood-fish", emoji: "🐟", labelKey: "onboarding.catSeafood" },
  { slug: "snacks", emoji: "🍿", labelKey: "onboarding.catSnacks" },
  { slug: "spreads-dips", emoji: "🫕", labelKey: "onboarding.catSpreads" },
  { slug: "sweets", emoji: "🍫", labelKey: "onboarding.catSweets" },
] as const;

// Score band display config
export const SCORE_BANDS = {
  low: { labelKey: "scoreBand.excellent", color: "text-score-green-text", bg: "bg-score-green/10" },
  moderate: { labelKey: "scoreBand.good", color: "text-score-yellow-text", bg: "bg-score-yellow/10" },
  high: { labelKey: "scoreBand.moderate", color: "text-score-orange-text", bg: "bg-score-orange/10" },
  very_high: { labelKey: "scoreBand.poor", color: "text-score-red-text", bg: "bg-score-red/10" },
} as const;

/** Map a 0-100 unhealthiness score to a score band key. */
export function scoreBandFromScore(score: number): ScoreBand {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

// ─── 5-band score color system ──────────────────────────────────────────────

/**
 * 5-band color token names matching CSS custom properties:
 *   green (1–20), yellow (21–40), orange (41–60), red (61–80), darkred (81–100).
 */
export type ScoreColorBand = "green" | "yellow" | "orange" | "red" | "darkred";

/** Map a 0-100 unhealthiness score to a 5-band color token name. */
export function scoreColorFromScore(score: number): ScoreColorBand {
  if (score <= 20) return "green";
  if (score <= 40) return "yellow";
  if (score <= 60) return "orange";
  if (score <= 80) return "red";
  return "darkred";
}

/**
 * 5-band display config for visual score indicators (gauge rings, badges).
 * Uses the score-* CSS token classes from the design system.
 */
export const SCORE_5BAND_DISPLAY: Record<ScoreColorBand, { color: string; bg: string }> = {
  green: { color: "text-score-green-text", bg: "bg-score-green/10" },
  yellow: { color: "text-score-yellow-text", bg: "bg-score-yellow/10" },
  orange: { color: "text-score-orange-text", bg: "bg-score-orange/10" },
  red: { color: "text-score-red-text", bg: "bg-score-red/10" },
  darkred: { color: "text-score-darkred-text", bg: "bg-score-darkred/10" },
};

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
  { value: "diabetes", labelKey: "healthCondition.diabetes", icon: "🩸" },
  { value: "hypertension", labelKey: "healthCondition.hypertension", icon: "💓" },
  { value: "heart_disease", labelKey: "healthCondition.heartDisease", icon: "❤️" },
  { value: "celiac_disease", labelKey: "healthCondition.celiacDisease", icon: "🌾" },
  { value: "gout", labelKey: "healthCondition.gout", icon: "🦴" },
  { value: "kidney_disease", labelKey: "healthCondition.kidneyDisease", icon: "🫘" },
  { value: "ibs", labelKey: "healthCondition.ibs", icon: "🫃" },
] as const;

// Warning severity display config
export const WARNING_SEVERITY = {
  critical: {
    labelKey: "warningSeverity.critical",
    color: "text-error",
    bg: "bg-error/10",
    border: "border-error/30",
  },
  high: {
    labelKey: "warningSeverity.high",
    color: "text-warning",
    bg: "bg-warning/10",
    border: "border-warning/30",
  },
  moderate: {
    labelKey: "warningSeverity.moderate",
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
 * Score interpretation bands — maps TryVit Score ranges to i18n keys and colors.
 * TryVit Score = 100 − unhealthiness. Higher = healthier.
 * Used for the expandable "What does this score mean?" section on product detail.
 */
export const SCORE_INTERPRETATION_BANDS = [
  { min: 80, max: 100, key: "scoreInterpretation.green", color: "text-score-green-text", bg: "bg-score-green/10" },
  { min: 60, max: 79, key: "scoreInterpretation.yellow", color: "text-score-yellow-text", bg: "bg-score-yellow/10" },
  { min: 40, max: 59, key: "scoreInterpretation.orange", color: "text-score-orange-text", bg: "bg-score-orange/10" },
  { min: 20, max: 39, key: "scoreInterpretation.red", color: "text-score-red-text", bg: "bg-score-red/10" },
  { min: 0, max: 19, key: "scoreInterpretation.darkRed", color: "text-score-darkred-text", bg: "bg-score-darkred/10" },
] as const;

/** Get the score interpretation band for a given TryVit Score (0-100, higher = healthier). */
export function getScoreInterpretation(tryVitScore: number) {
  return (
    SCORE_INTERPRETATION_BANDS.find((b) => tryVitScore >= b.min && tryVitScore <= b.max) ??
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

// ─── Notification frequency options ─────────────────────────────────────────
export const NOTIFICATION_FREQUENCY_OPTIONS = [
  { value: "immediate",     labelKey: "notifications.frequencyImmediate",  descKey: "notifications.frequencyImmediateDescription" },
  { value: "daily_digest",  labelKey: "notifications.frequencyDaily",      descKey: "notifications.frequencyDailyDescription" },
  { value: "weekly_digest", labelKey: "notifications.frequencyWeekly",     descKey: "notifications.frequencyWeeklyDescription" },
] as const;

// ─── Feature flags ──────────────────────────────────────────────────────────
// Flip to `true` when the corresponding feature is production-ready.
export const FEATURES = {
  /** Show the Environmental Impact / Eco-Score section on product pages. */
  ECO_SCORE: false,
} as const;
