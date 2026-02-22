// ─── Centralized Nutrition Banding ────────────────────────────────────────────
//
// Single source of truth for nutrition-band thresholds and classification.
// Used by TrafficLightChip, NutritionDVBar, and any other component that needs
// to classify a nutrient value as low / medium / high.
//
// Thresholds: UK FSA traffic-light guidance (per 100 g for food)
// Reference : https://www.food.gov.uk/business-guidance/signposting-and-traffic-light-labelling
//
// Fibre / protein thresholds follow EU Regulation 1924/2006:
//   - "Source of fibre" ≥ 3 g / 100 g
//   - "High fibre"     ≥ 6 g / 100 g
//
// ──────────────────────────────────────────────────────────────────────────────

/** Qualitative band for a nutrient value. `"none"` means no band applies (0, null, or unknown nutrient). */
export type NutritionBand = "none" | "low" | "medium" | "high";

export interface NutrientThresholds {
  /** Values ≤ this are classified as "low". */
  readonly low: number;
  /** Values ≥ this are classified as "high". Values between low and high are "medium". */
  readonly high: number;
}

/**
 * FSA / EFSA per-100 g thresholds.
 *
 * | Nutrient      | Low (≤)  | High (≥)  | Source                    |
 * | ------------- | -------- | --------- | ------------------------- |
 * | Total fat     | 3.0 g    | 17.5 g    | UK FSA traffic-light      |
 * | Saturated fat | 1.5 g    | 5.0 g     | UK FSA traffic-light      |
 * | Sugars        | 5.0 g    | 22.5 g    | UK FSA traffic-light      |
 * | Salt          | 0.3 g    | 1.5 g     | UK FSA traffic-light      |
 * | Fibre         | 3.0 g    | 6.0 g     | EU Reg 1924/2006          |
 * | Protein       | 8.0 g    | 16.0 g    | UK FSA traffic-light      |
 */
export const NUTRITION_THRESHOLDS: Readonly<Record<string, NutrientThresholds>> = {
  total_fat: { low: 3, high: 17.5 },
  saturated_fat: { low: 1.5, high: 5 },
  sugars: { low: 5, high: 22.5 },
  salt: { low: 0.3, high: 1.5 },
  fibre: { low: 3, high: 6 },
  fiber: { low: 3, high: 6 }, // US spelling alias
  protein: { low: 8, high: 16 },
};

/**
 * Nutrients where higher values are positive (green / good).
 * For these nutrients the traffic-light colours are inverted at the display
 * level: high → green (good), low → red (concerning).
 */
export const BENEFICIAL_NUTRIENTS: ReadonlySet<string> = new Set([
  "fibre",
  "fiber",
  "protein",
]);

/**
 * Classify a nutrient value into a qualitative band.
 *
 * - `null`, `undefined`, `0`, and negative values → `"none"` (no band displayed)
 * - Unknown nutrient keys → `"none"`
 * - Otherwise → `"low"` / `"medium"` / `"high"` based on FSA thresholds
 *
 * **Note:** the returned band always describes the *amount* of the nutrient,
 * regardless of whether the nutrient is beneficial or harmful. Colour
 * inversion for beneficial nutrients happens at the display layer.
 */
export function getNutritionBand(
  nutrient: string,
  valuePer100g: number | null | undefined,
): NutritionBand {
  if (valuePer100g == null) return "none";
  if (valuePer100g <= 0) return "none"; // 0 g or negative → no meaningful band
  const t = NUTRITION_THRESHOLDS[nutrient];
  if (!t) return "none";
  if (valuePer100g <= t.low) return "low";
  if (valuePer100g >= t.high) return "high";
  return "medium";
}
