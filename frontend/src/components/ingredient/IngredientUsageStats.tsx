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
      <h2 className="mb-2 text-sm font-semibold text-foreground-secondary">
        {t("ingredient.usage")}
      </h2>
      <p className="mb-3 text-2xl font-bold text-foreground">
        {usage.product_count.toLocaleString()}{" "}
        <span className="text-sm font-normal text-foreground-secondary">
          {t("ingredient.productsContaining")}
        </span>
      </p>

      {usage.category_breakdown.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-medium text-foreground-secondary uppercase">
            {t("ingredient.byCategory")}
          </p>
          {usage.category_breakdown.map((cat) => (
            <div key={cat.category} className="flex items-center gap-2">
              <span className="w-28 truncate text-xs text-foreground-secondary">
                {cat.category}
              </span>
              <div className="h-2 flex-1 overflow-hidden rounded-full bg-surface-muted">
                <div
                  className="h-full rounded-full bg-brand-500"
                  style={{ width: `${(cat.count / maxCount) * 100}%` }}
                />
              </div>
              <span className="w-8 text-right text-xs text-foreground-muted">
                {cat.count}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
