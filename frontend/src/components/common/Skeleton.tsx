/**
 * Skeleton — shimmer-animated placeholder for loading states.
 *
 * Variants:
 *   text   — single-line text block (default)
 *   circle — avatar / icon placeholder
 *   rect   — generic rectangular block
 *   card   — full product-card-shaped placeholder
 *
 * Respects prefers-reduced-motion (static gray via CSS).
 * Dark-mode colors come from design tokens automatically.
 */

import type { CSSProperties, ReactNode } from "react";

export type SkeletonVariant = "text" | "circle" | "rect" | "card";

interface SkeletonProps {
  /** Shape variant. @default "text" */
  variant?: SkeletonVariant;
  /** Width — CSS value or Tailwind class via className. @default "100%" */
  width?: string | number;
  /** Height — CSS value. @default varies by variant */
  height?: string | number;
  /** Number of skeleton lines to repeat (text variant only). @default 1 */
  lines?: number;
  /** Additional CSS classes */
  className?: string;
}

const VARIANT_DEFAULTS: Record<
  SkeletonVariant,
  { width: string; height: string; borderRadius?: string }
> = {
  text: { width: "100%", height: "1rem" },
  circle: {
    width: "2.5rem",
    height: "2.5rem",
    borderRadius: "var(--radius-full)",
  },
  rect: { width: "100%", height: "4rem" },
  card: { width: "100%", height: "8rem", borderRadius: "var(--radius-lg)" },
};

function toCSS(v: string | number | undefined, fallback: string): string {
  if (v === undefined) return fallback;
  return typeof v === "number" ? `${v}px` : v;
}

export function Skeleton({
  variant = "text",
  width,
  height,
  lines = 1,
  className = "",
}: Readonly<SkeletonProps>) {
  const defaults = VARIANT_DEFAULTS[variant];
  const style: CSSProperties = {
    width: toCSS(width, defaults.width),
    height: toCSS(height, defaults.height),
    ...(defaults.borderRadius ? { borderRadius: defaults.borderRadius } : {}),
  };

  if (variant === "text" && lines > 1) {
    return (
      <div className={`space-y-2 ${className}`} aria-hidden="true">
        {Array.from({ length: lines }, (_, i) => (
          <div
            key={i}
            className="skeleton"
            style={{
              ...style,
              // Last line is shorter for a natural look
              width: i === lines - 1 ? "66%" : toCSS(width, defaults.width),
            }}
          />
        ))}
      </div>
    );
  }

  return (
    <div className={`skeleton ${className}`} style={style} aria-hidden="true" />
  );
}

// ─── Skeleton Container ─────────────────────────────────────────────────────
// Wraps page-level skeleton sets with proper a11y attributes.

interface SkeletonContainerProps {
  /** Accessible label for screen readers */
  label?: string;
  /** Additional CSS classes */
  className?: string;
  children: ReactNode;
}

export function SkeletonContainer({
  label = "Loading",
  className = "",
  children,
}: Readonly<SkeletonContainerProps>) {
  return (
    <div
      role="status"
      aria-busy="true"
      aria-label={label}
      className={className}
    >
      {children}
      <span className="sr-only">{label}</span>
    </div>
  );
}
