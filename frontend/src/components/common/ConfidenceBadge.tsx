/**
 * ConfidenceBadge — data confidence indicator with shield icon.
 *
 * Levels:
 *   high / verified  → shield ✓ (green)
 *   medium / estimated → shield ~ (amber)
 *   low              → shield ! (red)
 *
 * Uses `--color-confidence-high/medium/low` design tokens.
 * Accepts both DB band values (high/medium/low) and assign_confidence()
 * values (verified/estimated/low) via normalization.
 */

import React from "react";
import { InfoTooltip } from "./InfoTooltip";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ConfidenceLevel = "high" | "medium" | "low";
export type ConfidenceBadgeSize = "sm" | "md";

export interface ConfidenceBadgeProps {
  /** Confidence level. Accepts 'high'/'medium'/'low' or 'verified'/'estimated'. */
  readonly level: string | null | undefined;
  /** Optional percentage to display alongside the level. */
  readonly percentage?: number;
  /** Show the text label. @default true */
  readonly showLabel?: boolean;
  /** Size preset. @default "sm" */
  readonly size?: ConfidenceBadgeSize;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Level styling ──────────────────────────────────────────────────────────

interface ConfidenceConfig {
  label: string;
  bg: string;
  text: string;
  /** Shield symbol: ✓, ~, ! */
  symbol: string;
}

/** Normalize DB assign_confidence() values to band keys. */
const LEVEL_ALIASES: Record<string, ConfidenceLevel> = {
  high: "high",
  verified: "high",
  medium: "medium",
  estimated: "medium",
  low: "low",
};

const LEVEL_CONFIGS: Record<ConfidenceLevel, ConfidenceConfig> = {
  high: {
    label: "Verified",
    bg: "bg-confidence-high/10",
    text: "text-confidence-high",
    symbol: "✓",
  },
  medium: {
    label: "Estimated",
    bg: "bg-confidence-medium/10",
    text: "text-confidence-medium",
    symbol: "~",
  },
  low: {
    label: "Low",
    bg: "bg-confidence-low/10",
    text: "text-confidence-low",
    symbol: "!",
  },
};

const FALLBACK: ConfidenceConfig = {
  label: "Unknown",
  bg: "bg-surface-muted",
  text: "text-foreground-muted",
  symbol: "?",
};

const SIZE_CLASSES: Record<ConfidenceBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

const SHIELD_SIZE: Record<ConfidenceBadgeSize, number> = {
  sm: 14,
  md: 18,
};

// ─── Shield SVG ─────────────────────────────────────────────────────────────

function ShieldIcon({
  symbol,
  size,
  className,
}: {
  symbol: string;
  size: number;
  className: string;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 18"
      fill="none"
      className={`inline-block flex-shrink-0 ${className}`}
      aria-hidden="true"
      data-testid="shield-icon"
    >
      {/* Shield outline */}
      <path
        d="M8 1L2 4v4c0 4.5 2.6 7.3 6 9 3.4-1.7 6-4.5 6-9V4L8 1z"
        fill="currentColor"
        opacity={0.15}
        stroke="currentColor"
        strokeWidth={1.2}
        strokeLinejoin="round"
      />
      {/* Symbol inside shield */}
      <text
        x="8"
        y="10.5"
        textAnchor="middle"
        dominantBaseline="central"
        fill="currentColor"
        style={{ fontSize: "8px", fontWeight: 700 }}
      >
        {symbol}
      </text>
    </svg>
  );
}

// ─── Component ──────────────────────────────────────────────────────────────

export const ConfidenceBadge = React.memo(function ConfidenceBadge({
  level,
  percentage,
  showLabel = true,
  size = "sm",
  showTooltip = false,
  className = "",
}: Readonly<ConfidenceBadgeProps>) {
  const normalized = level ? LEVEL_ALIASES[level.toLowerCase()] : undefined;
  const config = normalized ? LEVEL_CONFIGS[normalized] : FALLBACK;
  const showPercentage =
    percentage != null && percentage >= 0 && percentage <= 100;
  const tooltipKey = normalized
    ? `tooltip.confidence.${normalized}`
    : undefined;

  const badge = (
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
      aria-label={[
        `Confidence: ${config.label}`,
        showPercentage ? `(${percentage}%)` : "",
      ]
        .filter(Boolean)
        .join(" ")}
    >
      <ShieldIcon
        symbol={config.symbol}
        size={SHIELD_SIZE[size]}
        className={config.text}
      />
      {showLabel && config.label}
      {showPercentage && <span className="opacity-75">{percentage}%</span>}
    </span>
  );

  if (showTooltip && tooltipKey) {
    return <InfoTooltip messageKey={tooltipKey}>{badge}</InfoTooltip>;
  }

  return badge;
});
