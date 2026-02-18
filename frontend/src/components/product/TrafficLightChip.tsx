// ─── FSA Traffic-Light Chip ──────────────────────────────────────────────────
// Displays a green / amber / red chip next to a nutrient value based on
// UK FSA / EFSA traffic-light thresholds (per 100 g for food).
//
// Thresholds: https://www.food.gov.uk/business-guidance/signposting-and-traffic-light-labelling
//
// | Nutrient      | Green (Low) | Amber (Medium) | Red (High) |
// | ------------- | ----------- | -------------- | ---------- |
// | Total fat     | ≤ 3.0 g     | 3.1–17.5 g     | > 17.5 g   |
// | Saturated fat | ≤ 1.5 g     | 1.6–5.0 g      | > 5.0 g    |
// | Sugars        | ≤ 5.0 g     | 5.1–22.5 g     | > 22.5 g   |
// | Salt          | ≤ 0.3 g     | 0.31–1.5 g     | > 1.5 g    |
//
// Beneficial nutrients (fibre, protein) use INVERTED colours:
// high = green (good), low = red (less ideal).
//
// Fibre thresholds (EU Regulation 1924/2006):
// | Level  | Threshold   | Colour (inverted) |
// | ------ | ----------- | ----------------- |
// | Low    | < 3.0 g     | Red (bad)         |
// | Source | 3.0–5.9 g   | Amber             |
// | High   | ≥ 6.0 g     | Green (good)      |

export type TrafficLight = "green" | "amber" | "red";

interface Threshold {
  greenMax: number;
  amberMax: number;
}

const THRESHOLDS: Record<string, Threshold> = {
  total_fat: { greenMax: 3, amberMax: 17.5 },
  saturated_fat: { greenMax: 1.5, amberMax: 5 },
  sugars: { greenMax: 5, amberMax: 22.5 },
  salt: { greenMax: 0.3, amberMax: 1.5 },
  fibre: { greenMax: 3, amberMax: 6 },
  fiber: { greenMax: 3, amberMax: 6 },
  protein: { greenMax: 8, amberMax: 16 },
};

/**
 * Beneficial nutrients where high values are positive (green).
 * For these, the traffic light colours are inverted: high → green, low → red.
 */
export const BENEFICIAL_NUTRIENTS = new Set(["fibre", "fiber", "protein"]);

/** Invert green ↔ red while keeping amber unchanged. */
function invertLight(level: TrafficLight): TrafficLight {
  if (level === "green") return "red";
  if (level === "red") return "green";
  return "amber";
}

/** Resolve the traffic-light level for a nutrient. */
export function getTrafficLight(
  nutrient: string,
  valuePer100g: number | null,
): TrafficLight | null {
  if (valuePer100g === null || valuePer100g === undefined) return null;
  const t = THRESHOLDS[nutrient];
  if (!t) return null;

  let level: TrafficLight;
  if (valuePer100g <= t.greenMax) level = "green";
  else if (valuePer100g <= t.amberMax) level = "amber";
  else level = "red";

  // Beneficial nutrients: high is good (green), low is bad (red)
  return BENEFICIAL_NUTRIENTS.has(nutrient) ? invertLight(level) : level;
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
