"use client";

import { useTranslation } from "@/lib/i18n";
import type { IngredientUsage } from "@/lib/types";

interface IngredientUsageStatsProps {
  readonly usage: IngredientUsage;
}

/**
 * Card showing how widely an ingredient is used: total product count and
 * category breakdown bar chart.
 */
export function IngredientUsageStats({ usage }: IngredientUsageStatsProps) {
  const { t } = useTranslation();
  const maxCount = Math.max(...usage.category_breakdown.map((c) => c.count), 1);

  return (
    <div className="card">
      <h2 className="mb-2 text-sm font-semibold text-gray-700">
        {t("ingredient.usage")}
      </h2>
      <p className="mb-3 text-2xl font-bold text-gray-900">
        {usage.product_count.toLocaleString()}{" "}
        <span className="text-sm font-normal text-gray-500">
          {t("ingredient.productsContaining")}
        </span>
      </p>

      {usage.category_breakdown.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-medium text-gray-500 uppercase">
            {t("ingredient.byCategory")}
          </p>
          {usage.category_breakdown.map((cat) => (
            <div key={cat.category} className="flex items-center gap-2">
              <span className="w-28 truncate text-xs text-gray-600">
                {cat.category}
              </span>
              <div className="h-2 flex-1 overflow-hidden rounded-full bg-gray-100">
                <div
                  className="h-full rounded-full bg-brand-500"
                  style={{ width: `${(cat.count / maxCount) * 100}%` }}
                />
              </div>
              <span className="w-8 text-right text-xs text-gray-400">
                {cat.count}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
