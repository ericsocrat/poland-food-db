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
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ScoreBadgeSize = "sm" | "md" | "lg";

export interface ScoreBadgeProps {
  /** Unhealthiness score 1–100. Null/undefined → "N/A" badge. */
  readonly score: number | null | undefined;
  /** Size preset. @default "md" */
  readonly size?: ScoreBadgeSize;
  /** Show the band label text alongside the score. */
  readonly showLabel?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Score band mapping ─────────────────────────────────────────────────────

interface BandConfig {
  label: string;
  bg: string;
  text: string;
}

const BANDS: BandConfig[] = [
  { label: "Low", bg: "bg-score-green/10", text: "text-score-green" },
  { label: "Moderate", bg: "bg-score-yellow/10", text: "text-score-yellow" },
  { label: "High", bg: "bg-score-orange/10", text: "text-score-orange" },
  { label: "Very High", bg: "bg-score-red/10", text: "text-score-red" },
  { label: "Extreme", bg: "bg-score-darkred/10", text: "text-score-darkred" },
];

function getBand(score: number): BandConfig {
  if (score <= 20) return BANDS[0];
  if (score <= 40) return BANDS[1];
  if (score <= 60) return BANDS[2];
  if (score <= 80) return BANDS[3];
  return BANDS[4];
}

const NA_BAND: BandConfig = {
  label: "N/A",
  bg: "bg-surface-muted",
  text: "text-foreground-muted",
};

// ─── Size maps ──────────────────────────────────────────────────────────────

const SIZE_CLASSES: Record<ScoreBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
  lg: "px-3 py-1.5 text-base",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const ScoreBadge = React.memo(function ScoreBadge({
  score,
  size = "md",
  showLabel = false,
  className = "",
}: Readonly<ScoreBadgeProps>) {
  const isValid = score != null && score >= 1 && score <= 100;
  const band = isValid ? getBand(score) : NA_BAND;
  const displayText = isValid ? String(score) : "N/A";

  if (!isValid && score != null) {
    if (process.env.NODE_ENV === "development") {
      console.warn(`ScoreBadge: invalid score ${score}, expected 1–100`);
    }
  }

  return (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full font-semibold whitespace-nowrap",
        band.bg,
        band.text,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`Score: ${displayText}${showLabel ? `, ${band.label}` : ""}`}
    >
      {displayText}
      {showLabel && <span className="font-medium">{band.label}</span>}
    </span>
  );
});
