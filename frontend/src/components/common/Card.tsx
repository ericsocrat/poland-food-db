/**
 * Card — semantic container component replacing `.card` CSS class.
 *
 * Supports variants (default, elevated, outlined), padding sizes, and
 * semantic HTML via the `as` prop. All styling via design tokens.
 */

import {
  forwardRef,
  type HTMLAttributes,
  type ElementType,
  type ReactNode,
} from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type CardVariant = "default" | "elevated" | "outlined";
export type CardPadding = "none" | "sm" | "md" | "lg";

export interface CardProps extends Omit<
  HTMLAttributes<HTMLElement>,
  "children"
> {
  /** Visual style variant. @default "default" */
  readonly variant?: CardVariant;
  /** Padding preset. @default "md" */
  readonly padding?: CardPadding;
  /** Semantic HTML element. @default "div" */
  readonly as?: ElementType;
  /** Card content. */
  readonly children: ReactNode;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const VARIANT_CLASSES: Record<CardVariant, string> = {
  default: "rounded-xl border bg-surface shadow-sm",
  elevated: "rounded-xl bg-surface shadow-md",
  outlined: "rounded-xl border-2 border-strong bg-transparent",
};

const PADDING_CLASSES: Record<CardPadding, string> = {
  none: "",
  sm: "p-3",
  md: "p-4",
  lg: "p-6",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const Card = forwardRef<HTMLElement, CardProps>(function Card(
  {
    variant = "default",
    padding = "md",
    as: Component = "div",
    className = "",
    children,
    ...rest
  },
  ref,
) {
  return (
    <Component
      ref={ref}
      className={[VARIANT_CLASSES[variant], PADDING_CLASSES[padding], className]
        .filter(Boolean)
        .join(" ")}
      {...rest}
    >
      {children}
    </Component>
  );
});
