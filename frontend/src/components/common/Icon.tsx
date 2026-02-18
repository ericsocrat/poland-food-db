// ─── Icon — Unified icon wrapper for Lucide React icons ─────────────────────
// Standardizes icon rendering with consistent sizing, accessibility, and color.
// All icons use currentColor by default for automatic theme adaptation.
//
// Issue #65 — Iconography & Illustration System

import type { LucideIcon, LucideProps } from "lucide-react";

/* ── Size scale ──────────────────────────────────────────────────────────── */

const SIZE_MAP = {
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
} as const;

export type IconSize = keyof typeof SIZE_MAP;

/* ── Props ───────────────────────────────────────────────────────────────── */

export interface IconProps extends Omit<LucideProps, "size" | "ref"> {
  /** Lucide icon component (e.g., `Search`, `Home`, `Camera`) */
  readonly icon: LucideIcon;
  /** Predefined size. @default "lg" (24px) */
  readonly size?: IconSize;
  /** aria-label for informational icons. Omit for decorative icons. */
  readonly label?: string;
}

/* ── Component ───────────────────────────────────────────────────────────── */

/**
 * Renders a Lucide icon with standardized sizing and accessibility.
 *
 * - **Decorative** (no `label`): `aria-hidden="true"`, invisible to screen readers.
 * - **Informational** (with `label`): `aria-label` set, `role="img"`.
 *
 * @example
 * // Decorative icon alongside text
 * <Icon icon={Search} size="md" />
 *
 * // Informational icon (only visual indicator)
 * <Icon icon={AlertTriangle} size="lg" label="Warning" />
 */
export function Icon({
  icon: LucideComponent,
  size = "lg",
  label,
  className = "",
  ...rest
}: IconProps) {
  const px = SIZE_MAP[size];
  const isDecorative = !label;

  return (
    <LucideComponent
      size={px}
      className={className}
      aria-hidden={isDecorative ? "true" : undefined}
      aria-label={label}
      role={label ? "img" : undefined}
      {...rest}
    />
  );
}
