// ─── Constants: countries, allergens, diets ─────────────────────────────────
// Keeping these in sync with backend reference tables.

export const COUNTRIES = [
  { code: "DE", name: "Germany", native: "Deutschland", flag: "🇩🇪" },
  { code: "PL", name: "Poland", native: "Polska", flag: "🇵🇱" },
] as const;

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
  low: { label: "Low", color: "text-green-600", bg: "bg-green-100" },
  moderate: { label: "Moderate", color: "text-amber-600", bg: "bg-amber-100" },
  high: { label: "High", color: "text-orange-600", bg: "bg-orange-100" },
  very_high: { label: "Very High", color: "text-red-600", bg: "bg-red-100" },
} as const;

// Nutri-Score display config
export const NUTRI_COLORS: Record<string, string> = {
  A: "bg-nutri-A text-white",
  B: "bg-nutri-B text-white",
  C: "bg-nutri-C text-gray-900",
  D: "bg-nutri-D text-white",
  E: "bg-nutri-E text-white",
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
    color: "text-red-700",
    bg: "bg-red-50",
    border: "border-red-200",
  },
  high: {
    label: "High",
    color: "text-orange-700",
    bg: "bg-orange-50",
    border: "border-orange-200",
  },
  moderate: {
    label: "Moderate",
    color: "text-amber-700",
    bg: "bg-amber-50",
    border: "border-amber-200",
  },
} as const;
