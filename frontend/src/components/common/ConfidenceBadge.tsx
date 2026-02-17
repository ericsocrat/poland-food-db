/**
 * ConfidenceBadge — data confidence indicator for user trust.
 *
 * Uses `--color-confidence-high/medium/low` design tokens.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ConfidenceLevel = "high" | "medium" | "low";
export type ConfidenceBadgeSize = "sm" | "md";

export interface ConfidenceBadgeProps {
  /** Confidence level. */
  readonly level: ConfidenceLevel | null | undefined;
  /** Optional percentage to display alongside the level. */
  readonly percentage?: number;
  /** Size preset. @default "sm" */
  readonly size?: ConfidenceBadgeSize;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Level styling ──────────────────────────────────────────────────────────

interface ConfidenceConfig {
  label: string;
  bg: string;
  text: string;
}

const LEVEL_CONFIGS: Record<ConfidenceLevel, ConfidenceConfig> = {
  high: {
    label: "High",
    bg: "bg-confidence-high/10",
    text: "text-confidence-high",
  },
  medium: {
    label: "Medium",
    bg: "bg-confidence-medium/10",
    text: "text-confidence-medium",
  },
  low: {
    label: "Low",
    bg: "bg-confidence-low/10",
    text: "text-confidence-low",
  },
};

const FALLBACK: ConfidenceConfig = {
  label: "Unknown",
  bg: "bg-surface-muted",
  text: "text-foreground-muted",
};

const SIZE_CLASSES: Record<ConfidenceBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const ConfidenceBadge = React.memo(function ConfidenceBadge({
  level,
  percentage,
  size = "sm",
  className = "",
}: Readonly<ConfidenceBadgeProps>) {
  const config = level ? (LEVEL_CONFIGS[level] ?? FALLBACK) : FALLBACK;
  const showPercentage =
    percentage != null && percentage >= 0 && percentage <= 100;

  return (
    <span
      className={[
        "inline-flex items-center gap-1 rounded-full font-medium whitespace-nowrap",
        config.bg,
        config.text,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`Confidence: ${config.label}${showPercentage ? ` (${percentage}%)` : ""}`}
    >
      {config.label}
      {showPercentage && <span className="opacity-75">{percentage}%</span>}
    </span>
  );
});
