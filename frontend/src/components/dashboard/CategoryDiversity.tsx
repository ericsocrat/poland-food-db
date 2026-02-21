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
        <progress
          className="h-2 flex-1 appearance-none overflow-hidden rounded-full bg-surface-muted [&::-webkit-progress-bar]:bg-surface-muted [&::-webkit-progress-bar]:rounded-full [&::-webkit-progress-value]:bg-brand [&::-webkit-progress-value]:rounded-full [&::-webkit-progress-value]:transition-all [&::-webkit-progress-value]:duration-500 [&::-moz-progress-bar]:bg-brand [&::-moz-progress-bar]:rounded-full"
          value={diversity.explored}
          max={diversity.total}
          aria-label={t("dashboard.categoryDiversityAria", {
            explored: String(diversity.explored),
            total: String(diversity.total),
          })}
        />
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
