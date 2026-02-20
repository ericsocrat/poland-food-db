"use client";

/**
 * ScoreChangeIndicator — small badge showing score delta (↑5 / ↓3 / ─).
 * Used on product cards, watchlist items, and search results.
 */

import { useTranslation } from "@/lib/i18n";

interface ScoreChangeIndicatorProps {
  delta: number | null;
  className?: string;
}

export function ScoreChangeIndicator({
  delta,
  className,
}: Readonly<ScoreChangeIndicatorProps>) {
  const { t } = useTranslation();

  if (delta == null || delta === 0) return null;

  // Higher score = worse (unhealthiness). Positive delta = worsened.
  const isWorse = delta > 0;
  const arrow = isWorse ? "↑" : "↓";
  const colorClass = isWorse
    ? "text-error bg-error/10"
    : "text-success bg-success/10";
  const label = isWorse
    ? t("watchlist.scoreWorsened", { delta: String(Math.abs(delta)) })
    : t("watchlist.scoreImproved", { delta: String(Math.abs(delta)) });

  return (
    <span
      className={`inline-flex items-center gap-0.5 rounded-full px-1.5 py-0.5 text-xs font-medium ${colorClass} ${className ?? ""}`}
      aria-label={label}
      data-testid="score-change-indicator"
    >
      {arrow}
      {Math.abs(delta)}
    </span>
  );
}
