import type { NutrientDV, DVLevel } from "@/lib/types";
import { useTranslation } from "@/lib/i18n";

const LEVEL_COLORS: Record<DVLevel, { bar: string; text: string }> = {
  low: { bar: "bg-green-500", text: "text-green-700" },
  moderate: { bar: "bg-amber-500", text: "text-amber-700" },
  high: { bar: "bg-red-500", text: "text-red-700" },
};

interface NutritionDVBarProps {
  readonly label: string;
  readonly rawValue: string;
  readonly dv: NutrientDV | null;
}

export function NutritionDVBar({ label, rawValue, dv }: NutritionDVBarProps) {
  const { t } = useTranslation();

  if (!dv) {
    return (
      <tr className="border-b border-gray-100">
        <td className="py-2 text-gray-600">{label}</td>
        <td className="py-2 text-right font-medium text-gray-900">
          {rawValue}
        </td>
        <td className="w-32 py-2 pl-3" />
      </tr>
    );
  }

  const colors = LEVEL_COLORS[dv.level];
  const widthPct = Math.min(dv.pct, 100);

  return (
    <tr className="border-b border-gray-100">
      <td className="py-2 text-gray-600">{label}</td>
      <td className="py-2 text-right font-medium text-gray-900">{rawValue}</td>
      <td className="w-32 py-2 pl-3">
        <div className="flex items-center gap-2">
          <div className="relative h-2 flex-1 overflow-hidden rounded-full bg-gray-200">
            <div
              className={`h-full rounded-full ${colors.bar}`}
              style={{ width: `${widthPct}%` }}
            />
            <progress
              className="sr-only"
              value={dv.pct}
              max={100}
              aria-label={t("product.dvBarLabel", {
                nutrient: label,
                pct: dv.pct,
              })}
            />
          </div>
          <span className={`text-xs font-medium ${colors.text}`}>
            {dv.pct}%
          </span>
        </div>
      </td>
    </tr>
  );
}
