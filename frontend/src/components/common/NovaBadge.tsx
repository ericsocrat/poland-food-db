/**
 * NovaBadge — NOVA food processing classification badge.
 *
 * Groups:
 *   1 → Unprocessed/minimally processed (green)
 *   2 → Processed culinary ingredients (lime)
 *   3 → Processed foods (amber)
 *   4 → Ultra-processed (red)
 *
 * Uses `--color-nova-1` through `--color-nova-4` design tokens.
 *
 * Size variants:
 *   sm  → compact text pill
 *   md  → standard text pill
 *   lg  → circular SVG badge with large number + optional label
 */

import React from "react";
import { InfoTooltip } from "./InfoTooltip";

// ─── Types ──────────────────────────────────────────────────────────────────

export type NovaGroup = 1 | 2 | 3 | 4;
export type NovaBadgeSize = "sm" | "md" | "lg";

export interface NovaBadgeProps {
  /** NOVA group 1–4. Null/invalid → neutral badge. */
  readonly group: number | null | undefined;
  /** Size preset. sm/md = pill, lg = circular SVG. @default "md" */
  readonly size?: NovaBadgeSize;
  /** Show group label text. */
  readonly showLabel?: boolean;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Group styling ──────────────────────────────────────────────────────────

interface NovaConfig {
  label: string;
  bg: string;
  text: string;
  /** CSS variable for SVG fill (lg circle). */
  color: string;
}

const GROUP_CONFIGS: Record<NovaGroup, NovaConfig> = {
  1: {
    label: "Unprocessed",
    bg: "bg-nova-1/10",
    text: "text-nova-1",
    color: "var(--color-nova-1)",
  },
  2: {
    label: "Processed ingredients",
    bg: "bg-nova-2/10",
    text: "text-nova-2",
    color: "var(--color-nova-2)",
  },
  3: {
    label: "Processed",
    bg: "bg-nova-3/10",
    text: "text-nova-3",
    color: "var(--color-nova-3)",
  },
  4: {
    label: "Ultra-processed",
    bg: "bg-nova-4/10",
    text: "text-nova-4",
    color: "var(--color-nova-4)",
  },
};

const FALLBACK_CONFIG: NovaConfig = {
  label: "Unknown",
  bg: "bg-surface-muted",
  text: "text-foreground-muted",
  color: "var(--color-surface-muted, #e5e7eb)",
};

const SIZE_CLASSES: Record<"sm" | "md", string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

// ─── Circle constants (lg size) ─────────────────────────────────────────────

const CIRCLE_SIZE = 40;
const CIRCLE_RADIUS = CIRCLE_SIZE / 2 - 2;

// ─── Component ──────────────────────────────────────────────────────────────

export const NovaBadge = React.memo(function NovaBadge({
  group,
  size = "md",
  showLabel = false,
  showTooltip = false,
  className = "",
}: Readonly<NovaBadgeProps>) {
  const isValid =
    group != null && Number.isInteger(group) && group >= 1 && group <= 4;
  const config = isValid ? GROUP_CONFIGS[group as NovaGroup] : FALLBACK_CONFIG;

  if (!isValid && group != null && process.env.NODE_ENV === "development") {
    console.warn(`NovaBadge: unexpected group ${group}, expected 1–4`);
  }

  const tooltipKey = isValid ? `tooltip.nova.${group}` : undefined;
  const ariaLabel = isValid
    ? `NOVA Group ${group}: ${config.label}`
    : "NOVA unknown";

  // ─── lg: circular SVG badge ─────────────────────────────────────────────

  if (size === "lg") {
    const fillColor = config.color;
    const textFill = isValid
      ? group === 2 || group === 3
        ? "var(--color-text-primary, #1f2937)"
        : "var(--color-text-inverse, #fff)"
      : "var(--color-text-muted, #9ca3af)";

    const circle = (
      <span
        className={["inline-flex flex-col items-center gap-1", className]
          .filter(Boolean)
          .join(" ")}
        aria-label={ariaLabel}
        role="img"
      >
        <svg
          width={CIRCLE_SIZE}
          height={CIRCLE_SIZE}
          viewBox={`0 0 ${CIRCLE_SIZE} ${CIRCLE_SIZE}`}
          className="block"
          data-testid="nova-circle"
        >
          <circle
            cx={CIRCLE_SIZE / 2}
            cy={CIRCLE_SIZE / 2}
            r={CIRCLE_RADIUS}
            fill={fillColor}
          />
          <text
            x="50%"
            y="50%"
            textAnchor="middle"
            dominantBaseline="central"
            fill={textFill}
            style={{ fontSize: "1.125rem", fontWeight: 700 }}
          >
            {isValid ? group : "?"}
          </text>
        </svg>
        {showLabel && (
          <span className="text-xs font-medium text-foreground-secondary whitespace-nowrap">
            {config.label}
          </span>
        )}
      </span>
    );

    if (showTooltip && tooltipKey) {
      return <InfoTooltip messageKey={tooltipKey}>{circle}</InfoTooltip>;
    }
    return circle;
  }

  // ─── sm / md: pill badge ────────────────────────────────────────────────

  const badge = (
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
      aria-label={ariaLabel}
    >
      {isValid ? group : "?"}
      {showLabel && <span className="font-medium">{config.label}</span>}
    </span>
  );

  if (showTooltip && tooltipKey) {
    return <InfoTooltip messageKey={tooltipKey}>{badge}</InfoTooltip>;
  }

  return badge;
});
