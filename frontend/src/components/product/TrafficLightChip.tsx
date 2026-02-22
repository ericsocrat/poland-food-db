// ─── FSA Traffic-Light Chip ──────────────────────────────────────────────────
// Displays a green / amber / red chip next to a nutrient value based on
// UK FSA / EFSA traffic-light thresholds (per 100 g for food).
//
// Thresholds are defined in the centralized utility:
//   frontend/src/lib/nutrition-banding.ts
//
// Beneficial nutrients (fibre, protein) use INVERTED colours:
// high = green (good), low = red (less ideal).

import {
  getNutritionBand,
  BENEFICIAL_NUTRIENTS,
  type NutritionBand,
} from "@/lib/nutrition-banding";

export { BENEFICIAL_NUTRIENTS } from "@/lib/nutrition-banding";

export type TrafficLight = "green" | "amber" | "red";

/** Invert green ↔ red while keeping amber unchanged. */
function invertLight(level: TrafficLight): TrafficLight {
  if (level === "green") return "red";
  if (level === "red") return "green";
  return "amber";
}

/** Map NutritionBand → base TrafficLight colour (before beneficial inversion). */
const BAND_TO_LIGHT: Record<Exclude<NutritionBand, "none">, TrafficLight> = {
  low: "green",
  medium: "amber",
  high: "red",
};

/** Resolve the traffic-light level for a nutrient using centralized thresholds. */
export function getTrafficLight(
  nutrient: string,
  valuePer100g: number | null,
): TrafficLight | null {
  const band = getNutritionBand(nutrient, valuePer100g);
  if (band === "none") return null;

  const light = BAND_TO_LIGHT[band];
  return BENEFICIAL_NUTRIENTS.has(nutrient) ? invertLight(light) : light;
}

const TL_STYLES: Record<TrafficLight, string> = {
  green: "bg-green-500",
  amber: "bg-amber-500",
  red: "bg-red-500",
};

const TL_LABELS: Record<TrafficLight, string> = {
  green: "Low",
  amber: "Medium",
  red: "High",
};

interface TrafficLightChipProps {
  readonly level: TrafficLight;
}

export function TrafficLightChip({ level }: TrafficLightChipProps) {
  return (
    <span
      className={`inline-flex h-4 items-center rounded px-1.5 text-[10px] font-semibold leading-none text-white ${TL_STYLES[level]}`}
      title={TL_LABELS[level]}
      aria-label={TL_LABELS[level]}
    >
      {TL_LABELS[level]}
    </span>
  );
}
