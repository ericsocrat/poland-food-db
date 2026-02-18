/**
 * ScoreGauge — circular SVG gauge ring for product unhealthiness scores.
 *
 * Uses `stroke-dasharray` on an SVG `<circle>` to create a fill-arc
 * proportional to the score (0–100). Color follows the SCORE_BANDS system:
 *   1–25 → green, 26–50 → yellow, 51–75 → orange, 76–100 → red.
 *
 * Falls back to a gray neutral ring when score is null/undefined.
 */

import React from "react";
import { scoreBandFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { ScoreBand } from "@/lib/types";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ScoreGaugeSize = "sm" | "md" | "lg";

export interface ScoreGaugeProps {
  /** Unhealthiness score 0–100. Null → neutral gauge. */
  readonly score: number | null | undefined;
  /** Size preset. @default "md" */
  readonly size?: ScoreGaugeSize;
  /** Additional CSS classes on the wrapper. */
  readonly className?: string;
}

// ─── Configuration ──────────────────────────────────────────────────────────

const SIZE_CONFIG: Record<
  ScoreGaugeSize,
  {
    svgSize: number;
    radius: number;
    strokeWidth: number;
    fontSize: string;
    subFontSize: string;
  }
> = {
  sm: {
    svgSize: 48,
    radius: 18,
    strokeWidth: 4,
    fontSize: "text-sm",
    subFontSize: "text-[7px]",
  },
  md: {
    svgSize: 64,
    radius: 24,
    strokeWidth: 5,
    fontSize: "text-xl",
    subFontSize: "text-[9px]",
  },
  lg: {
    svgSize: 80,
    radius: 30,
    strokeWidth: 6,
    fontSize: "text-2xl",
    subFontSize: "text-[10px]",
  },
};

/**
 * Maps score bands to their CSS custom property color values.
 * These match the --color-score-* tokens from globals.css.
 */
const BAND_STROKE_COLORS: Record<ScoreBand, string> = {
  low: "var(--color-score-green)",
  moderate: "var(--color-score-yellow)",
  high: "var(--color-score-orange)",
  very_high: "var(--color-score-red)",
};

const NEUTRAL_STROKE = "var(--color-foreground-muted, #9ca3af)";
const TRACK_STROKE = "var(--color-surface-muted, #e5e7eb)";

// ─── Component ──────────────────────────────────────────────────────────────

export const ScoreGauge = React.memo(function ScoreGauge({
  score,
  size = "md",
  className = "",
}: Readonly<ScoreGaugeProps>) {
  const { t } = useTranslation();
  const config = SIZE_CONFIG[size];
  const { svgSize, radius, strokeWidth, fontSize, subFontSize } = config;

  const circumference = 2 * Math.PI * radius;
  const hasScore = score != null && !Number.isNaN(score);

  // Clamp to 0–100 for the arc calculation
  const clampedScore = hasScore ? Math.max(0, Math.min(100, score)) : 0;
  const fillFraction = clampedScore / 100;
  const dashArray = `${circumference * fillFraction} ${circumference * (1 - fillFraction)}`;

  // Rotate -90° so the arc starts from the top (12 o'clock)
  const strokeColor = hasScore
    ? BAND_STROKE_COLORS[scoreBandFromScore(score)]
    : NEUTRAL_STROKE;

  const center = svgSize / 2;

  return (
    <div
      className={`relative inline-flex flex-shrink-0 items-center justify-center ${className}`}
      style={{ width: svgSize, height: svgSize }}
      role="img"
      aria-label={
        hasScore
          ? t("scoreGauge.label", { score: String(score) })
          : t("scoreGauge.noScore")
      }
    >
      <svg
        width={svgSize}
        height={svgSize}
        viewBox={`0 0 ${svgSize} ${svgSize}`}
        className="absolute inset-0"
      >
        {/* Background track */}
        <circle
          cx={center}
          cy={center}
          r={radius}
          fill="none"
          stroke={TRACK_STROKE}
          strokeWidth={strokeWidth}
        />
        {/* Filled arc */}
        {hasScore && (
          <circle
            cx={center}
            cy={center}
            r={radius}
            fill="none"
            stroke={strokeColor}
            strokeWidth={strokeWidth}
            strokeDasharray={dashArray}
            strokeDashoffset={circumference * 0.25}
            strokeLinecap="round"
            className="transition-[stroke-dasharray] duration-500 ease-out"
            data-testid="gauge-arc"
          />
        )}
      </svg>
      {/* Center text */}
      <div className="relative flex flex-col items-center leading-none">
        <span className={`${fontSize} font-bold text-foreground`}>
          {hasScore ? score : "—"}
        </span>
        <span className={`${subFontSize} font-medium text-foreground-muted`}>
          {hasScore ? t("scoreGauge.outOf") : ""}
        </span>
      </div>
    </div>
  );
});
