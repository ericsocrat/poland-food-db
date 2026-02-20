"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { Scale } from "lucide-react";
import type { DashboardRecentComparison } from "@/lib/types";

interface RecentComparisonsProps {
  comparisons: DashboardRecentComparison[];
}

/**
 * Shows the user's last 2 saved comparisons as compact cards.
 * Hidden when the array is empty.
 */
export function RecentComparisons({
  comparisons,
}: Readonly<RecentComparisonsProps>) {
  const { t } = useTranslation();

  if (comparisons.length === 0) return null;

  return (
    <section data-testid="recent-comparisons">
      <div className="mb-2 flex items-center justify-between lg:mb-3">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground lg:text-xl">
          <Scale size={20} aria-hidden="true" />{" "}
          {t("dashboard.recentComparisons")}
        </h2>
        <Link
          href="/app/compare"
          className="text-sm font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.viewAll")}
        </Link>
      </div>

      <div className="space-y-2">
        {comparisons.map((c) => (
          <Link
            key={c.id}
            href={`/app/compare?ids=${c.id}`}
            className="card hover-lift-press flex items-center gap-3"
          >
            <Scale
              size={16}
              aria-hidden="true"
              className="text-foreground-muted"
            />
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-medium text-foreground">
                {c.title ?? t("dashboard.untitledComparison")}
              </p>
              <p className="text-xs text-foreground-secondary">
                {t("dashboard.comparisonProducts", {
                  count: String(c.product_count),
                })}{" "}
                · {new Date(c.created_at).toLocaleDateString()}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
