/**
 * NutrientTrafficLight — FSA/EFSA traffic-light indicator for nutrients.
 *
 * Thresholds (per 100g, based on UK FSA front-of-pack scheme):
 *   Fat:       ≤3g green, 3.1–17.5g amber, >17.5g red
 *   Saturates: ≤1.5g green, 1.6–5g amber, >5g red
 *   Sugars:    ≤5g green, 5.1–22.5g amber, >22.5g red
 *   Salt:      ≤0.3g green, 0.31–1.5g amber, >1.5g red
 *
 * Uses `--color-nutrient-low/medium/high` design tokens.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type TrafficLightLevel = "low" | "medium" | "high";
export type NutrientType = "fat" | "saturates" | "sugars" | "salt";

export interface NutrientTrafficLightProps {
  /** Nutrient type — determines thresholds. */
  readonly nutrient: NutrientType;
  /** Nutrient value per 100g. */
  readonly value: number;
  /** Display unit. @default "g" */
  readonly unit?: string;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── FSA thresholds (per 100g) ──────────────────────────────────────────────

const THRESHOLDS: Record<NutrientType, { green: number; amber: number }> = {
  fat: { green: 3, amber: 17.5 },
  saturates: { green: 1.5, amber: 5 },
  sugars: { green: 5, amber: 22.5 },
  salt: { green: 0.3, amber: 1.5 },
};

const NUTRIENT_LABELS: Record<NutrientType, string> = {
  fat: "Fat",
  saturates: "Saturates",
  sugars: "Sugars",
  salt: "Salt",
};

function classifyLevel(
  nutrient: NutrientType,
  value: number,
): TrafficLightLevel {
  const t = THRESHOLDS[nutrient];
  if (value <= t.green) return "low";
  if (value <= t.amber) return "medium";
  return "high";
}

// ─── Level styling ──────────────────────────────────────────────────────────

const LEVEL_CLASSES: Record<
  TrafficLightLevel,
  { bg: string; text: string; label: string }
> = {
  low: { bg: "bg-nutrient-low/10", text: "text-nutrient-low", label: "Low" },
  medium: {
    bg: "bg-nutrient-medium/10",
    text: "text-nutrient-medium",
    label: "Medium",
  },
  high: {
    bg: "bg-nutrient-high/10",
    text: "text-nutrient-high",
    label: "High",
  },
};

// ─── Component ──────────────────────────────────────────────────────────────

export const NutrientTrafficLight = React.memo(function NutrientTrafficLight({
  nutrient,
  value,
  unit = "g",
  className = "",
}: Readonly<NutrientTrafficLightProps>) {
  const level = classifyLevel(nutrient, value);
  const config = LEVEL_CLASSES[level];
  const nutrientLabel = NUTRIENT_LABELS[nutrient];

  return (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-xs font-medium whitespace-nowrap",
        config.bg,
        config.text,
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`${nutrientLabel}: ${value}${unit} (${config.label})`}
    >
      <span
        className={`inline-block h-2 w-2 rounded-full ${
          level === "low"
            ? "bg-nutrient-low"
            : level === "medium"
              ? "bg-nutrient-medium"
              : "bg-nutrient-high"
        }`}
        aria-hidden="true"
      />
      <span className="font-semibold">{nutrientLabel}</span>
      <span>
        {value}
        {unit}
      </span>
    </span>
  );
});

/** Exported for testing purposes. */
export { classifyLevel, THRESHOLDS };
