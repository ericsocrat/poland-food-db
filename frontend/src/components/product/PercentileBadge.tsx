"use client";

/**
 * PercentileBadge — shows "Better than X% of {category}" as a pill badge.
 *
 * Computes the percentile from the product's rank within its category.
 * Colour-coded by quartile: green (top 25%), amber (middle 50%), muted (bottom 25%).
 *
 * Returns `null` when data is missing or invalid (rank/total ≤ 0).
 */

import { Icon } from "@/components/common/Icon";
import { useTranslation } from "@/lib/i18n";
import { TrendingUp } from "lucide-react";

interface PercentileBadgeProps {
  /** Product rank within category (1 = best). */
  readonly rank: number | null | undefined;
  /** Total products in category. */
  readonly total: number | null | undefined;
  /** Optional extra class names. */
  readonly className?: string;
}

/**
 * Compute integer percentile: percentage of products this one is better than.
 *
 * @example rank 1 of 100 → 99  (better than 99%)
 * @example rank 50 of 100 → 50  (better than 50%)
 * @example rank 100 of 100 → 0  (better than 0%)
 */
function computePercentile(rank: number, total: number): number {
  if (total <= 1) return 100; // sole product → top 100%
  return Math.round(((total - rank) / (total - 1)) * 100);
}

/**
 * Resolve Tailwind classes based on the percentile quartile.
 */
function getPercentileStyle(pct: number): { bg: string; text: string } {
  if (pct >= 75) return { bg: "bg-score-green/10", text: "text-score-green-text" };
  if (pct >= 25) return { bg: "bg-score-yellow/10", text: "text-score-yellow-text" };
  return { bg: "bg-surface-muted", text: "text-foreground-secondary" };
}

export function PercentileBadge({
  rank,
  total,
  className,
}: PercentileBadgeProps) {
  const { t } = useTranslation();

  // Guard: bail out on missing / invalid data
  if (rank == null || total == null || rank <= 0 || total <= 0) return null;

  const percentile = computePercentile(rank, total);
  const style = getPercentileStyle(percentile);

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${style.bg} ${style.text} ${className ?? ""}`}
      data-testid="percentile-badge"
      title={t("product.percentileTooltip", { rank, total })}
    >
      <Icon icon={TrendingUp} size="sm" />
      {t("product.betterThan", { pct: percentile })}
    </span>
  );
}
