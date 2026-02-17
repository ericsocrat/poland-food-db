/**
 * AllergenBadge — color-coded allergen warning badge.
 *
 * Statuses:
 *   present → red (allergen confirmed present)
 *   traces  → yellow/amber (may contain traces)
 *   free    → green (allergen-free)
 *
 * Uses `--color-allergen-*` design tokens. Shows generic warning icon for
 * unknown allergens.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type AllergenStatus = "present" | "traces" | "free";
export type AllergenBadgeSize = "sm" | "md";

export interface AllergenBadgeProps {
  /** Allergen presence status. */
  readonly status: AllergenStatus;
  /** Human-readable allergen name. */
  readonly allergenName: string;
  /** Size preset. @default "sm" */
  readonly size?: AllergenBadgeSize;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Status styling ─────────────────────────────────────────────────────────

interface StatusConfig {
  icon: string;
  bg: string;
  text: string;
  srLabel: string;
}

const STATUS_CONFIGS: Record<AllergenStatus, StatusConfig> = {
  present: {
    icon: "⚠️",
    bg: "bg-allergen-present/10",
    text: "text-allergen-present",
    srLabel: "Contains",
  },
  traces: {
    icon: "⚡",
    bg: "bg-allergen-traces/10",
    text: "text-allergen-traces",
    srLabel: "May contain traces of",
  },
  free: {
    icon: "✓",
    bg: "bg-allergen-free/10",
    text: "text-allergen-free",
    srLabel: "Free from",
  },
};

const SIZE_CLASSES: Record<AllergenBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const AllergenBadge = React.memo(function AllergenBadge({
  status,
  allergenName,
  size = "sm",
  className = "",
}: Readonly<AllergenBadgeProps>) {
  const config = STATUS_CONFIGS[status] ?? STATUS_CONFIGS.present;

  return (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full font-medium whitespace-nowrap",
        config.bg,
        config.text,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`${config.srLabel} ${allergenName}`}
    >
      <span aria-hidden="true">{config.icon}</span>
      {allergenName}
    </span>
  );
});
