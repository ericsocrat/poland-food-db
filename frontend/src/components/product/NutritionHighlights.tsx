"use client";

import { getTrafficLight } from "@/components/product/TrafficLightChip";
import { TRAFFIC_LIGHT_NUTRIENTS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

interface NutritionHighlightsProps {
  readonly nutrition: {
    readonly total_fat_g: number;
    readonly saturated_fat_g: number;
    readonly sugars_g: number;
    readonly salt_g: number;
  };
}

const BAR_COLORS = {
  green: "bg-nutrient-low",
  amber: "bg-nutrient-medium",
  red: "bg-nutrient-high",
} as const;

/** Max values for bar width scaling (per 100g reference). */
const MAX_VALUES: Record<string, number> = {
  total_fat: 40,
  saturated_fat: 15,
  sugars: 50,
  salt: 5,
};

const UNITS: Record<string, string> = {
  total_fat: "g",
  saturated_fat: "g",
  sugars: "g",
  salt: "g",
};

export function NutritionHighlights({ nutrition }: NutritionHighlightsProps) {
  const { t } = useTranslation();

  const nutrientValues: Record<string, number> = {
    total_fat: nutrition.total_fat_g,
    saturated_fat: nutrition.saturated_fat_g,
    sugars: nutrition.sugars_g,
    salt: nutrition.salt_g,
  };

  const items = TRAFFIC_LIGHT_NUTRIENTS.map(({ nutrient, labelKey }) => {
    const value = nutrientValues[nutrient] ?? 0;
    const level = getTrafficLight(nutrient, value);
    const max = MAX_VALUES[nutrient] ?? 50;
    const pct = Math.min(100, (value / max) * 100);
    return { nutrient, label: t(labelKey), value, level, pct, unit: UNITS[nutrient] ?? "g" };
  });

  return (
    <div className="card">
      <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-foreground-muted">
        {t("product.keyNutrients")}
      </p>
      <div className="space-y-2.5">
        {items.map((item) => (
          <div key={item.nutrient}>
            <div className="mb-0.5 flex items-baseline justify-between text-xs">
              <span className="text-foreground-secondary">{item.label}</span>
              <span className="font-medium tabular-nums text-foreground">
                {item.value.toFixed(1)}{item.unit}
              </span>
            </div>
            <div
              className="h-2 overflow-hidden rounded-full bg-surface-muted"
              role="progressbar"
              aria-label={`${item.label}: ${item.value.toFixed(1)}${item.unit}`}
              aria-valuenow={item.value}
              aria-valuemin={0}
              aria-valuemax={MAX_VALUES[item.nutrient] ?? 50}
            >
              <div
                className={`h-full rounded-full transition-all ${
                  item.level ? BAR_COLORS[item.level] : "bg-foreground-muted"
                }`}
                style={{ width: `${item.pct}%` }}
              />
            </div>
          </div>
        ))}
      </div>
      <p className="mt-2 text-xxs text-foreground-muted">
        {t("product.per100g")}
      </p>
    </div>
  );
}
