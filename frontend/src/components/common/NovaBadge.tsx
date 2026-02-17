/**
 * NovaBadge — NOVA food processing classification badge.
 *
 * Groups:
 *   1 → Unprocessed/minimally processed (green)
 *   2 → Processed culinary ingredients (yellow)
 *   3 → Processed foods (orange)
 *   4 → Ultra-processed (red)
 *
 * Uses `--color-nova-1` through `--color-nova-4` design tokens.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type NovaGroup = 1 | 2 | 3 | 4;
export type NovaBadgeSize = "sm" | "md" | "lg";

export interface NovaBadgeProps {
  /** NOVA group 1–4. Null/invalid → neutral badge. */
  readonly group: number | null | undefined;
  /** Size preset. @default "md" */
  readonly size?: NovaBadgeSize;
  /** Show group label text. */
  readonly showLabel?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Group styling ──────────────────────────────────────────────────────────

interface NovaConfig {
  label: string;
  bg: string;
  text: string;
}

const GROUP_CONFIGS: Record<NovaGroup, NovaConfig> = {
  1: { label: "Unprocessed", bg: "bg-nova-1/10", text: "text-nova-1" },
  2: {
    label: "Processed ingredients",
    bg: "bg-nova-2/10",
    text: "text-nova-2",
  },
  3: { label: "Processed", bg: "bg-nova-3/10", text: "text-nova-3" },
  4: { label: "Ultra-processed", bg: "bg-nova-4/10", text: "text-nova-4" },
};

const SIZE_CLASSES: Record<NovaBadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
  lg: "px-3 py-1.5 text-base",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const NovaBadge = React.memo(function NovaBadge({
  group,
  size = "md",
  showLabel = false,
  className = "",
}: Readonly<NovaBadgeProps>) {
  const isValid =
    group != null && Number.isInteger(group) && group >= 1 && group <= 4;
  const config = isValid
    ? GROUP_CONFIGS[group as NovaGroup]
    : {
        label: "Unknown",
        bg: "bg-surface-muted",
        text: "text-foreground-muted",
      };

  if (!isValid && group != null && process.env.NODE_ENV === "development") {
    console.warn(`NovaBadge: unexpected group ${group}, expected 1–4`);
  }

  return (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full font-semibold whitespace-nowrap",
        config.bg,
        config.text,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`NOVA ${isValid ? `Group ${group}: ${config.label}` : "unknown"}`}
    >
      {isValid ? group : "?"}
      {showLabel && <span className="font-medium">{config.label}</span>}
    </span>
  );
});
