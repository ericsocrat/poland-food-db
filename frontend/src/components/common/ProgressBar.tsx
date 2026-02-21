/**
 * ProgressBar — visual progress indicator for achievements, nutrition DV bars, etc.
 *
 * Supports brand, score-based, and custom color variants with optional label.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ProgressVariant =
  | "brand"
  | "success"
  | "warning"
  | "error"
  | "score";
export type ProgressSize = "sm" | "md" | "lg";

export interface ProgressBarProps {
  /** Progress value 0–100. Clamped to valid range. */
  readonly value: number;
  /** Visual style variant. @default "brand" */
  readonly variant?: ProgressVariant;
  /** Size preset. @default "md" */
  readonly size?: ProgressSize;
  /** Show percentage label inside or beside the bar. */
  readonly showLabel?: boolean;
  /** Custom label text (overrides default "XX%"). */
  readonly label?: string;
  /** Accessible description. @default "Progress: XX%" */
  readonly ariaLabel?: string;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const VARIANT_CLASSES: Record<ProgressVariant, string> = {
  brand: "bg-brand",
  success: "bg-success",
  warning: "bg-warning",
  error: "bg-error",
  score: "bg-brand", // dynamically overridden for score variant
};

const TRACK_SIZES: Record<ProgressSize, string> = {
  sm: "h-1.5",
  md: "h-2.5",
  lg: "h-4",
};

/**
 * For the "score" variant, map the value to a score color.
 */
function getScoreBarColor(value: number): string {
  if (value <= 20) return "bg-score-green";
  if (value <= 40) return "bg-score-yellow";
  if (value <= 60) return "bg-score-orange";
  if (value <= 80) return "bg-score-red";
  return "bg-score-darkred";
}

// ─── Component ──────────────────────────────────────────────────────────────

export const ProgressBar = React.memo(function ProgressBar({
  value,
  variant = "brand",
  size = "md",
  showLabel = false,
  label,
  ariaLabel,
  className = "",
}: Readonly<ProgressBarProps>) {
  const clamped = Math.max(0, Math.min(100, value));
  const barColor =
    variant === "score" ? getScoreBarColor(clamped) : VARIANT_CLASSES[variant];
  const displayLabel = label ?? `${Math.round(clamped)}%`;

  return (
    <div className={className}>
      {/* Native progress for screen readers */}
      <progress
        className="sr-only"
        value={clamped}
        max={100}
        aria-label={ariaLabel ?? `Progress: ${Math.round(clamped)}%`}
      />
      {/* Visual bar */}
      <div
        aria-hidden="true"
        className={[
          "w-full overflow-hidden rounded-full bg-surface-muted",
          TRACK_SIZES[size],
        ].join(" ")}
      >
        <div
          className={`h-full rounded-full transition-[width] duration-slow ease-decelerate ${barColor}`}
          style={{ width: `${clamped}%` }}
        />
      </div>
      {showLabel && (
        <span className="mt-1 block text-xs text-foreground-muted">
          {displayLabel}
        </span>
      )}
    </div>
  );
});
