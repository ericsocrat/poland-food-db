/**
 * ScoreGauge — circular SVG gauge ring for product TryVit Score.
 *
 * Receives `unhealthiness_score` (0–100), displays inverted TryVit Score
 * (higher = healthier). Stroke color stays mapped to the original
 * unhealthiness bands: green = healthy, red = unhealthy.
 */

import { scoreColorFromScore, type ScoreColorBand } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { toTryVitScore } from "@/lib/score-utils";
import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ScoreGaugeSize = "sm" | "md" | "lg" | "xl";

export interface ScoreGaugeProps {
  /** Unhealthiness score 0–100 (API value). Displayed as TryVit Score (inverted). */
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
    subFontSize: "text-[9px]",
  },
  md: {
    svgSize: 64,
    radius: 24,
    strokeWidth: 5,
    fontSize: "text-xl",
    subFontSize: "text-[10px]",
  },
  lg: {
    svgSize: 80,
    radius: 30,
    strokeWidth: 6,
    fontSize: "text-2xl",
    subFontSize: "text-xxs",
  },
  xl: {
    svgSize: 120,
    radius: 46,
    strokeWidth: 8,
    fontSize: "text-4xl",
    subFontSize: "text-xs",
  },
};

/**
 * Maps 5-band color tokens to their CSS custom property color values.
 * These match the --color-score-* tokens from globals.css.
 */
const BAND_STROKE_COLORS: Record<ScoreColorBand, string> = {
  green: "var(--color-score-green)",
  yellow: "var(--color-score-yellow)",
  orange: "var(--color-score-orange)",
  red: "var(--color-score-red)",
  darkred: "var(--color-score-darkred)",
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

  // Invert to TryVit Score (higher = healthier) for display
  const tryVitScore = hasScore ? toTryVitScore(Math.max(0, Math.min(100, score))) : 0;
  const fillFraction = tryVitScore / 100;
  const dashArray = `${circumference * fillFraction} ${circumference * (1 - fillFraction)}`;

  // Rotate -90° so the arc starts from the top (12 o'clock)
  const strokeColor = hasScore
    ? BAND_STROKE_COLORS[scoreColorFromScore(score)]
    : NEUTRAL_STROKE;

  const center = svgSize / 2;

  return (
    <figure
      className={`relative inline-flex shrink-0 items-center justify-center ${className}`}
      style={{ width: svgSize, height: svgSize }}
      aria-label={
        hasScore
          ? t("scoreGauge.label", { score: String(tryVitScore) })
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
            className="transition-[stroke-dasharray] duration-slow ease-decelerate"
            data-testid="gauge-arc"
          />
        )}
      </svg>
      {/* Center text */}
      <div className="relative flex flex-col items-center leading-none">
        <span className={`${fontSize} font-bold text-foreground`}>
          {hasScore ? tryVitScore : "—"}
        </span>
        <span className={`${subFontSize} font-medium text-foreground-muted`}>
          {hasScore ? t("scoreGauge.outOf") : ""}
        </span>
      </div>
    </figure>
  );
});
