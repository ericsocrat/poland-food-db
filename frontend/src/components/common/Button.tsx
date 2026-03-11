/**
 * Button / ButtonLink — standardized button components replacing `.btn-primary`
 * / `.btn-secondary` CSS classes.
 *
 * Button: Renders `<button>` — supports loading spinner, icons, disabled state.
 * ButtonLink: Renders Next.js `<Link>` with identical visual styling — for
 * navigation actions that should look like buttons.
 *
 * Both support 4 variants (primary, secondary, ghost, danger), 3 sizes,
 * and full-width mode. All styling via design tokens.
 */

import Link from "next/link";
import { forwardRef, type AnchorHTMLAttributes, type ButtonHTMLAttributes, type ReactNode } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
export type ButtonSize = "sm" | "md" | "lg";

export interface ButtonProps extends Omit<
  ButtonHTMLAttributes<HTMLButtonElement>,
  "children"
> {
  /** Visual style variant. @default "primary" */
  readonly variant?: ButtonVariant;
  /** Size preset. @default "md" */
  readonly size?: ButtonSize;
  /** Show a loading spinner and disable interactions. */
  readonly loading?: boolean;
  /** Icon element rendered before children. */
  readonly icon?: ReactNode;
  /** Icon element rendered after children. */
  readonly iconRight?: ReactNode;
  /** Stretch to fill container width. */
  readonly fullWidth?: boolean;
  /** Button content. */
  readonly children: ReactNode;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const VARIANT_CLASSES: Record<ButtonVariant, string> = {
  primary:
    "bg-brand text-foreground-inverse shadow-sm hover:bg-brand-hover focus-visible:outline-brand",
  secondary:
    "border border-strong bg-surface text-foreground-secondary shadow-sm hover:bg-surface-subtle focus-visible:outline-brand",
  ghost:
    "text-foreground-secondary hover:bg-surface-subtle focus-visible:outline-brand",
  danger:
    "bg-error text-foreground-inverse shadow-sm hover:opacity-90 focus-visible:outline-error",
};

const SIZE_CLASSES: Record<ButtonSize, string> = {
  sm: "px-3 py-1.5 text-xs gap-1.5 rounded-md",
  md: "px-4 py-2.5 text-sm gap-2 rounded-lg min-h-[44px]",
  lg: "px-6 py-3 text-base gap-2.5 rounded-lg min-h-[44px]",
};

const SPINNER_SIZES: Record<ButtonSize, string> = {
  sm: "h-3 w-3 border-[1.5px]",
  md: "h-4 w-4 border-2",
  lg: "h-5 w-5 border-2",
};

// ─── Shared helpers ─────────────────────────────────────────────────────────

const BASE_CLASSES = [
  "inline-flex items-center justify-center font-semibold transition-colors press-scale",
  "focus-visible:outline-2 focus-visible:outline-offset-2",
].join(" ");

/** Build the full className string for button-styled elements. */
export function buttonClasses(
  variant: ButtonVariant = "primary",
  size: ButtonSize = "md",
  opts?: { fullWidth?: boolean; className?: string },
): string {
  return [
    BASE_CLASSES,
    VARIANT_CLASSES[variant],
    SIZE_CLASSES[size],
    opts?.fullWidth ? "w-full" : "",
    opts?.className ?? "",
  ]
    .filter(Boolean)
    .join(" ");
}

// ─── Button Component ───────────────────────────────────────────────────────

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  function Button(
    {
      variant = "primary",
      size = "md",
      loading = false,
      icon,
      iconRight,
      fullWidth = false,
      disabled,
      className = "",
      children,
      ...rest
    },
    ref,
  ) {
    const isDisabled = disabled || loading;

    return (
      <button
        ref={ref}
        disabled={isDisabled}
        aria-busy={loading || undefined}
        className={[
          BASE_CLASSES,
          "disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none!",
          VARIANT_CLASSES[variant],
          SIZE_CLASSES[size],
          fullWidth ? "w-full" : "",
          className,
        ]
          .filter(Boolean)
          .join(" ")}
        style={{ touchAction: "manipulation" }}
        {...rest}
      >
        {loading && (
          <span
            className={`animate-spin rounded-full border-current border-t-transparent ${SPINNER_SIZES[size]}`}
            aria-hidden="true"
          />
        )}
        {!loading && icon && (
          <span className="shrink-0" aria-hidden="true">
            {icon}
          </span>
        )}
        {children}
        {iconRight && !loading ? (
          <span className="shrink-0" aria-hidden="true">
            {iconRight}
          </span>
        ) : null}
      </button>
    );
  },
);

// ─── ButtonLink Component ───────────────────────────────────────────────────

export interface ButtonLinkProps
  extends Omit<AnchorHTMLAttributes<HTMLAnchorElement>, "href"> {
  /** Destination URL (required). */
  readonly href: string;
  /** Visual style variant. @default "primary" */
  readonly variant?: ButtonVariant;
  /** Size preset. @default "md" */
  readonly size?: ButtonSize;
  /** Icon element rendered before children. */
  readonly icon?: ReactNode;
  /** Icon element rendered after children. */
  readonly iconRight?: ReactNode;
  /** Stretch to fill container width. */
  readonly fullWidth?: boolean;
  /** Link content. */
  readonly children: ReactNode;
}

export const ButtonLink = forwardRef<HTMLAnchorElement, ButtonLinkProps>(
  function ButtonLink(
    {
      href,
      variant = "primary",
      size = "md",
      icon,
      iconRight,
      fullWidth = false,
      className = "",
      children,
      ...rest
    },
    ref,
  ) {
    return (
      <Link
        ref={ref}
        href={href}
        className={buttonClasses(variant, size, { fullWidth, className })}
        style={{ touchAction: "manipulation" }}
        {...rest}
      >
        {icon && (
          <span className="shrink-0" aria-hidden="true">
            {icon}
          </span>
        )}
        {children}
        {iconRight && (
          <span className="shrink-0" aria-hidden="true">
            {iconRight}
          </span>
        )}
      </Link>
    );
  },
);
