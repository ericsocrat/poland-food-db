"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { Compass } from "lucide-react";
import type { DashboardCategoryDiversity } from "@/lib/types";

interface CategoryDiversityProps {
  diversity: DashboardCategoryDiversity;
}

/**
 * Shows how many product categories the user has explored out of the total,
 * with a small progress bar and a CTA to discover more.
 */
export function CategoryDiversity({
  diversity,
}: Readonly<CategoryDiversityProps>) {
  const { t } = useTranslation();

  if (diversity.explored === 0) return null;

  const pct = Math.round((diversity.explored / diversity.total) * 100);

  return (
    <div data-testid="category-diversity">
      <div className="flex items-center gap-2">
        <Compass
          size={16}
          aria-hidden="true"
          className="text-foreground-muted"
        />
        <span className="text-sm font-semibold text-foreground">
          {t("dashboard.categoryDiversityTitle")}
        </span>
      </div>

      <div className="mt-2 flex items-center gap-2">
        {/* Progress bar */}
        <div className="h-2 flex-1 overflow-hidden rounded-full bg-surface-muted">
          <div
            className="h-full rounded-full bg-brand transition-all duration-500"
            style={{ width: `${pct}%` }}
            role="progressbar"
            aria-valuenow={diversity.explored}
            aria-valuemin={0}
            aria-valuemax={diversity.total}
            aria-label={t("dashboard.categoryDiversityAria", {
              explored: String(diversity.explored),
              total: String(diversity.total),
            })}
          />
        </div>
        <span className="text-sm font-bold tabular-nums text-foreground">
          {diversity.explored}/{diversity.total}
        </span>
      </div>

      <p className="mt-1 text-xs text-foreground-secondary">
        {t("dashboard.categoryDiversityBody", {
          explored: String(diversity.explored),
          total: String(diversity.total),
        })}
      </p>

      {diversity.explored < diversity.total && (
        <Link
          href="/app/categories"
          className="mt-1.5 inline-block text-xs font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.categoryDiversityDiscover")} →
        </Link>
      )}
    </div>
  );
}
