// ─── Traffic Light Summary Strip ────────────────────────────────────────────
// Horizontal strip of traffic-light indicators for key nutrients (per 100g).
// Shows at-a-glance green/amber/red status for Fat, Saturated Fat, Sugars, Salt
// based on EFSA/FSA reference thresholds.

import { getTrafficLight, type TrafficLight } from "./TrafficLightChip";
import { TRAFFIC_LIGHT_NUTRIENTS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

interface NutritionValues {
  readonly total_fat_g: number;
  readonly saturated_fat_g: number;
  readonly sugars_g: number;
  readonly salt_g: number;
}

const TL_DOT_STYLES: Record<TrafficLight, string> = {
  green: "bg-green-500",
  amber: "bg-amber-500",
  red: "bg-red-500",
};

interface TrafficLightStripProps {
  readonly nutrition: NutritionValues;
}

export function TrafficLightStrip({ nutrition }: TrafficLightStripProps) {
  const { t } = useTranslation();

  const nutrientValues: Record<string, number> = {
    total_fat: nutrition.total_fat_g,
    saturated_fat: nutrition.saturated_fat_g,
    sugars: nutrition.sugars_g,
    salt: nutrition.salt_g,
  };

  const items = TRAFFIC_LIGHT_NUTRIENTS.map(({ nutrient, labelKey }) => ({
    nutrient,
    label: t(labelKey),
    level: getTrafficLight(nutrient, nutrientValues[nutrient] ?? null),
  })).filter((item) => item.level !== null);

  if (items.length === 0) return null;

  return (
    <fieldset
      className="flex items-center gap-3 rounded-lg border-0 bg-surface-muted p-0 px-3 py-2"
      aria-label={t("product.trafficLightSummary")}
    >
      {items.map((item) => (
        <div key={item.nutrient} className="flex items-center gap-1.5">
          <span
            className={`inline-block h-3 w-3 rounded-full ${TL_DOT_STYLES[item.level!]}`}
            aria-hidden="true"
          />
          <span className="text-xs text-foreground-secondary">
            {item.label}
          </span>
        </div>
      ))}
    </fieldset>
  );
}
