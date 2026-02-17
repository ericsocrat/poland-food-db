/**
 * Badge — generic label/tag component with semantic variants.
 *
 * For info pills, status indicators, category tags.
 * Domain-specific badges (ScoreBadge, NutriScoreBadge, etc.) extend this pattern.
 */

import type { ReactNode } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type BadgeVariant = "info" | "success" | "warning" | "error" | "neutral";
export type BadgeSize = "sm" | "md";

export interface BadgeProps {
  /** Visual style variant. @default "neutral" */
  readonly variant?: BadgeVariant;
  /** Size preset. @default "sm" */
  readonly size?: BadgeSize;
  /** Show a colored dot indicator before children. */
  readonly dot?: boolean;
  /** Badge content. */
  readonly children: ReactNode;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const VARIANT_CLASSES: Record<
  BadgeVariant,
  { bg: string; text: string; dot: string }
> = {
  info: { bg: "bg-info/10", text: "text-info", dot: "bg-info" },
  success: { bg: "bg-success/10", text: "text-success", dot: "bg-success" },
  warning: { bg: "bg-warning/10", text: "text-warning", dot: "bg-warning" },
  error: { bg: "bg-error/10", text: "text-error", dot: "bg-error" },
  neutral: {
    bg: "bg-surface-muted",
    text: "text-foreground-secondary",
    dot: "bg-foreground-muted",
  },
};

const SIZE_CLASSES: Record<BadgeSize, string> = {
  sm: "px-2 py-0.5 text-xs",
  md: "px-2.5 py-1 text-sm",
};

// ─── Component ──────────────────────────────────────────────────────────────

export function Badge({
  variant = "neutral",
  size = "sm",
  dot = false,
  children,
  className = "",
}: Readonly<BadgeProps>) {
  const styles = VARIANT_CLASSES[variant];

  return (
    <span
      className={[
        "inline-flex items-center gap-1.5 rounded-full font-medium whitespace-nowrap",
        styles.bg,
        styles.text,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
    >
      {dot && (
        <span
          className={`inline-block h-1.5 w-1.5 rounded-full ${styles.dot}`}
          aria-hidden="true"
        />
      )}
      {children}
    </span>
  );
}
