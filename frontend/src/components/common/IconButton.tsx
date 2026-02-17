/**
 * IconButton — square button for toolbar/icon-only actions.
 *
 * Always requires an accessible `label` (rendered as `aria-label`).
 * Variants and sizes match the Button component.
 */

import { forwardRef, type ButtonHTMLAttributes, type ReactNode } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type IconButtonVariant = "primary" | "secondary" | "ghost" | "danger";
export type IconButtonSize = "sm" | "md" | "lg";

export interface IconButtonProps extends Omit<
  ButtonHTMLAttributes<HTMLButtonElement>,
  "children"
> {
  /** The icon element to render. */
  readonly icon: ReactNode;
  /** Accessible label (aria-label). Required for icon-only buttons. */
  readonly label: string;
  /** Visual style variant. @default "ghost" */
  readonly variant?: IconButtonVariant;
  /** Size preset. @default "md" */
  readonly size?: IconButtonSize;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const VARIANT_CLASSES: Record<IconButtonVariant, string> = {
  primary:
    "bg-brand text-foreground-inverse hover:bg-brand-hover focus-visible:outline-brand",
  secondary:
    "border border-strong bg-surface text-foreground-secondary hover:bg-surface-subtle focus-visible:outline-brand",
  ghost:
    "text-foreground-secondary hover:bg-surface-subtle focus-visible:outline-brand",
  danger: "text-error hover:bg-error/10 focus-visible:outline-error",
};

const SIZE_CLASSES: Record<IconButtonSize, string> = {
  sm: "h-7 w-7 text-sm rounded-md",
  md: "h-9 w-9 text-base rounded-lg",
  lg: "h-11 w-11 text-lg rounded-lg",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const IconButton = forwardRef<HTMLButtonElement, IconButtonProps>(
  function IconButton(
    {
      icon,
      label,
      variant = "ghost",
      size = "md",
      className = "",
      disabled,
      ...rest
    },
    ref,
  ) {
    return (
      <button
        ref={ref}
        aria-label={label}
        disabled={disabled}
        className={[
          "inline-flex items-center justify-center transition-colors",
          "focus-visible:outline-2 focus-visible:outline-offset-2",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          VARIANT_CLASSES[variant],
          SIZE_CLASSES[size],
          className,
        ]
          .filter(Boolean)
          .join(" ")}
        style={{ touchAction: "manipulation" }}
        {...rest}
      >
        {icon}
      </button>
    );
  },
);
