"use client";

/**
 * ScoreTrendChart — SVG sparkline showing score history over time.
 * Used on product profile and watchlist cards.
 */

import { useTranslation } from "@/lib/i18n";
import type { ScoreTrend } from "@/lib/types";

export interface SparklinePoint {
  date: string;
  score: number;
}

interface ScoreTrendChartProps {
  history: SparklinePoint[];
  trend: ScoreTrend;
  width?: number;
  height?: number;
  className?: string;
}

const TREND_COLORS: Record<ScoreTrend, string> = {
  improving: "var(--color-success, #16a34a)",
  worsening: "var(--color-error, #dc2626)",
  stable: "var(--color-foreground-secondary, #6b7280)",
};

export function ScoreTrendChart({
  history,
  trend,
  width = 120,
  height = 40,
  className,
}: Readonly<ScoreTrendChartProps>) {
  const { t } = useTranslation();

  if (history.length === 0) {
    return (
      <div
        className={`flex items-center justify-center text-xs text-foreground-secondary ${className ?? ""}`}
        style={{ width, height }}
        data-testid="score-trend-empty"
      >
        {t("watchlist.noHistory")}
      </div>
    );
  }

  // Sort by date ascending for left-to-right rendering
  const sorted = [...history].sort(
    (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
  );

  const scores = sorted.map((p) => p.score);
  const minScore = Math.min(...scores);
  const maxScore = Math.max(...scores);
  const range = maxScore - minScore || 1;

  // Padding for the sparkline
  const padX = 4;
  const padY = 4;
  const plotW = width - padX * 2;
  const plotH = height - padY * 2;

  // Build polyline points
  const points = sorted.map((p, i) => {
    const x =
      padX +
      (sorted.length === 1 ? plotW / 2 : (i / (sorted.length - 1)) * plotW);
    const y = padY + ((p.score - minScore) / range) * plotH;
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  });

  const strokeColor = TREND_COLORS[trend];
  const label = t("watchlist.trendLabel", {
    trend: t(`watchlist.trend.${trend}`),
    count: String(history.length),
  });

  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      aria-label={label}
      className={className}
      data-testid="score-trend-chart"
    >
      <title>{label}</title>
      <polyline
        points={points.join(" ")}
        fill="none"
        stroke={strokeColor}
        strokeWidth={1.5}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      {sorted.length > 0 && (
        <circle
          cx={Number.parseFloat(points.at(-1)!.split(",")[0])}
          cy={Number.parseFloat(points.at(-1)!.split(",")[1])}
          r={2.5}
          fill={strokeColor}
        />
      )}
    </svg>
  );
}
