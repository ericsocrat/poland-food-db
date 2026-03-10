"use client";

// ─── RecentlyViewed — compact recently viewed product list ──────────────────

import { useTranslation } from "@/lib/i18n";
import { getScoreBand, toTryVitScore } from "@/lib/score-utils";
import type { RecentlyViewedProduct } from "@/lib/types";
import { ArrowRight } from "lucide-react";
import Link from "next/link";
import { useMemo } from "react";

const MAX_ITEMS = 5;

interface RecentlyViewedProps {
  products: RecentlyViewedProduct[];
}

/**
 * Compact relative time string ("1m", "2h", "3d", "1w").
 * Intentionally terse for dashboard cards.
 */
export function relativeTimeAgo(isoDate: string): string {
  const now = Date.now();
  const then = new Date(isoDate).getTime();
  const diffMs = Math.max(0, now - then);
  const minutes = Math.floor(diffMs / 60_000);
  if (minutes < 1) return "now";
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d`;
  const weeks = Math.floor(days / 7);
  return `${weeks}w`;
}

export function RecentlyViewed({ products }: Readonly<RecentlyViewedProps>) {
  const { t } = useTranslation();

  const items = useMemo(() => products.slice(0, MAX_ITEMS), [products]);

  if (items.length === 0) return null;

  return (
    <section
      data-testid="recently-viewed-compact"
      aria-label={t("dashboard.recentlyViewedCompact")}
    >
      <div className="mb-3 flex items-center justify-between">
        <h2 className="text-sm font-semibold text-foreground-secondary">
          {t("dashboard.recentlyViewedCompact")}
        </h2>
        <Link
          href="/app/search"
          className="inline-flex items-center gap-1 text-xs font-medium text-primary hover:underline"
        >
          {t("dashboard.viewAll")}
          <ArrowRight className="h-3 w-3" aria-hidden="true" />
        </Link>
      </div>

      <div className="space-y-2">
        {items.map((product) => {
          const tryVit =
            product.unhealthiness_score != null
              ? toTryVitScore(product.unhealthiness_score)
              : null;
          const band =
            product.unhealthiness_score != null
              ? getScoreBand(product.unhealthiness_score)
              : null;
          const timeAgo = relativeTimeAgo(product.viewed_at);

          return (
            <Link
              key={product.product_id}
              href={`/app/product/${product.product_id}`}
              data-testid="recently-viewed-item"
              className="card hover-lift-press flex items-center gap-3 px-3 py-2.5 transition-shadow hover:shadow-md"
            >
              {/* Score circle */}
              <div
                className={`flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-full ${band?.bgColor ?? "bg-muted"}`}
              >
                <span
                  className={`text-xs font-bold tabular-nums ${band?.textColor ?? "text-foreground-secondary"}`}
                >
                  {tryVit ?? "–"}
                </span>
              </div>

              {/* Name + brand */}
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium">{product.product_name}</p>
                {product.brand && (
                  <p className="truncate text-xs text-foreground-secondary">
                    {product.brand}
                  </p>
                )}
              </div>

              {/* Relative time */}
              <span className="flex-shrink-0 text-xs tabular-nums text-foreground-secondary">
                {timeAgo}
              </span>
            </Link>
          );
        })}
      </div>
    </section>
  );
}
