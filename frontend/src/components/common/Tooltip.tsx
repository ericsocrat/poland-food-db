/**
 * Tooltip — accessible hover/focus/tap tooltip.
 *
 * Pure CSS approach using `group` + opacity transition.
 * Supports 4 placement sides with arrow. Accessible via aria-describedby.
 */

import { useId, type ReactNode } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type TooltipSide = "top" | "right" | "bottom" | "left";

export interface TooltipProps {
  /** Tooltip text content. */
  readonly content: string;
  /** Placement side. @default "top" */
  readonly side?: TooltipSide;
  /** The trigger element (wrapped in a span). */
  readonly children: ReactNode;
  /** Additional CSS classes on the outer wrapper. */
  readonly className?: string;
}

// ─── Position classes ───────────────────────────────────────────────────────

const POSITION_CLASSES: Record<TooltipSide, string> = {
  top: "bottom-full left-1/2 -translate-x-1/2 mb-2",
  bottom: "top-full left-1/2 -translate-x-1/2 mt-2",
  left: "right-full top-1/2 -translate-y-1/2 mr-2",
  right: "left-full top-1/2 -translate-y-1/2 ml-2",
};

// ─── Component ──────────────────────────────────────────────────────────────

export function Tooltip({
  content,
  side = "top",
  children,
  className = "",
}: Readonly<TooltipProps>) {
  const tooltipId = useId();

  return (
    <span
      className={`relative inline-flex group ${className}`}
      aria-describedby={tooltipId}
    >
      {children}
      <span
        id={tooltipId}
        role="tooltip"
        className={[
          "pointer-events-none absolute z-50 whitespace-nowrap rounded-md px-2.5 py-1.5 text-xs font-medium",
          "bg-surface-overlay text-foreground shadow-md border border-strong",
          "opacity-0 transition-opacity duration-fast",
          "group-hover:opacity-100 group-focus-within:opacity-100",
          POSITION_CLASSES[side],
        ].join(" ")}
      >
        {content}
      </span>
    </span>
  );
}
