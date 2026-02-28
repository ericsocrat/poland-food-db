/**
 * ScoreBadge — unhealthiness score badge with correct band color mapping.
 *
 * Score ranges:
 *   1–20  → green  (low)
 *   21–40 → yellow (moderate)
 *   41–60 → orange (high)
 *   61–80 → red    (very high)
 *   81–100 → dark red (extreme)
 *
 * Uses `--color-score-*` design tokens. Falls back gracefully for null/invalid.
 *
 * Size variants:
 *   sm  → 32×32 compact pill (number only)
 *   md  → 48-height pill (number + optional label)
 *   lg  → 80×80 circular SVG ring with animated fill arc
 */

import React from "react";
import { getScoreBand } from "@/lib/score-utils";
import { InfoTooltip } from "./InfoTooltip";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ScoreBadgeSize = "sm" | "md" | "lg";

export interface ScoreBadgeProps {
  /** Unhealthiness score 1–100. Null/undefined → "N/A" badge. */
  readonly score: number | null | undefined;
  /** Size preset. @default "md" */
  readonly size?: ScoreBadgeSize;
  /** Show the band label text alongside the score. */
  readonly showLabel?: boolean;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
  /** Enable progress ring animation (lg only). @default true */
  readonly animated?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Size maps ──────────────────────────────────────────────────────────────

const SIZE_CLASSES: Record<ScoreBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
  lg: "px-3 py-1.5 text-base",
};

// ─── Ring constants (lg size) ───────────────────────────────────────────────

const RING_SIZE = 80;
const RING_RADIUS = 30;
const RING_STROKE = 6;
const RING_CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;

// ─── Component ──────────────────────────────────────────────────────────────

export const ScoreBadge = React.memo(function ScoreBadge({
  score,
  size = "md",
  showLabel = false,
  showTooltip = false,
  animated = true,
  className = "",
}: Readonly<ScoreBadgeProps>) {
  const band = getScoreBand(score);
  const isValid = band !== null;
  const displayText = isValid ? String(score) : "N/A";
  const tooltipKey = isValid ? `tooltip.score.${band.band}` : undefined;
  const bandLabel = isValid ? band.label : "N/A";
  const bgClass = isValid ? band.bgColor : "bg-surface-muted";
  const textClass = isValid ? band.textColor : "text-foreground-muted";

  if (!isValid && score != null) {
    if (process.env.NODE_ENV === "development") {
      console.warn(`ScoreBadge: invalid score ${score}, expected 1–100`);
    }
  }

  // ─── Large: circular SVG ring ───────────────────────────────────────────

  if (size === "lg" && isValid) {
    const fillFraction = (score as number) / 100;
    const dashArray = `${RING_CIRCUMFERENCE * fillFraction} ${RING_CIRCUMFERENCE * (1 - fillFraction)}`;

    const ring = (
      <div
        className={["inline-flex flex-col items-center gap-1", className]
          .filter(Boolean)
          .join(" ")}
        aria-label={[`Score: ${displayText}`, showLabel ? bandLabel : ""]
          .filter(Boolean)
          .join(", ")}
        role="img"
      >
        <svg
          width={RING_SIZE}
          height={RING_SIZE}
          viewBox={`0 0 ${RING_SIZE} ${RING_SIZE}`}
          className="block"
        >
          {/* Track ring */}
          <circle
            cx={RING_SIZE / 2}
            cy={RING_SIZE / 2}
            r={RING_RADIUS}
            fill="none"
            stroke="var(--color-surface-muted, #e5e7eb)"
            strokeWidth={RING_STROKE}
          />
          {/* Fill arc */}
          <circle
            cx={RING_SIZE / 2}
            cy={RING_SIZE / 2}
            r={RING_RADIUS}
            fill="none"
            stroke={band.color}
            strokeWidth={RING_STROKE}
            strokeLinecap="round"
            strokeDasharray={dashArray}
            strokeDashoffset={0}
            transform={`rotate(-90 ${RING_SIZE / 2} ${RING_SIZE / 2})`}
            className={
              animated
                ? "transition-[stroke-dasharray] duration-700 ease-out"
                : ""
            }
            data-testid="score-ring"
          />
          {/* Score text */}
          <text
            x="50%"
            y="50%"
            textAnchor="middle"
            dominantBaseline="central"
            className={`fill-current ${textClass} text-2xl font-bold`}
            style={{ fontSize: "1.5rem" }}
          >
            {displayText}
          </text>
        </svg>
        {showLabel && (
          <span className={`text-sm font-medium ${textClass}`}>
            {bandLabel}
          </span>
        )}
      </div>
    );

    if (showTooltip && tooltipKey) {
      return <InfoTooltip messageKey={tooltipKey}>{ring}</InfoTooltip>;
    }

    return ring;
  }

  // ─── Small / Medium: pill badge ─────────────────────────────────────────

  const badge = (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full font-semibold whitespace-nowrap animate-scale-in",
        bgClass,
        textClass,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={[`Score: ${displayText}`, showLabel ? bandLabel : ""]
        .filter(Boolean)
        .join(", ")}
    >
      {displayText}
      {showLabel && <span className="font-medium">{bandLabel}</span>}
    </span>
  );

  if (showTooltip && tooltipKey) {
    return <InfoTooltip messageKey={tooltipKey}>{badge}</InfoTooltip>;
  }

  return badge;
});
