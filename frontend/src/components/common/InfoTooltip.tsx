/**
 * InfoTooltip — accessible tooltip using Radix UI primitives.
 *
 * Supports i18n message keys with optional interpolation params,
 * or raw string content. Handles hover (desktop), tap (mobile),
 * focus (keyboard), and `aria-describedby` automatically.
 *
 * Renders in a portal to avoid z-index/overflow issues.
 * Dark-mode-ready via CSS custom properties.
 */

"use client";

import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { type ReactNode } from "react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

export type InfoTooltipSide = "top" | "right" | "bottom" | "left";
export type InfoTooltipAlign = "start" | "center" | "end";

export interface InfoTooltipProps {
  /** i18n key for the tooltip main text — resolved via useTranslation. */
  readonly messageKey?: string;
  /** Optional i18n key for a longer secondary description. */
  readonly descriptionKey?: string;
  /** Interpolation params for messageKey and descriptionKey. */
  readonly params?: Record<string, string | number>;
  /** Raw content string (bypasses i18n). Use messageKey when possible. */
  readonly content?: string;
  /** Placement side relative to trigger. @default "top" */
  readonly side?: InfoTooltipSide;
  /** Alignment within the placement side. @default "center" */
  readonly align?: InfoTooltipAlign;
  /** Milliseconds before tooltip appears on hover. @default 300 */
  readonly delayDuration?: number;
  /** The trigger element. */
  readonly children: ReactNode;
  /** Max width of the tooltip content. @default 280 */
  readonly maxWidth?: number;
  /** Additional CSS classes on the content container. */
  readonly className?: string;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function InfoTooltip({
  messageKey,
  descriptionKey,
  params,
  content,
  side = "top",
  align = "center",
  delayDuration = 300,
  children,
  maxWidth = 280,
  className = "",
}: Readonly<InfoTooltipProps>) {
  const { t } = useTranslation();

  const mainText = messageKey ? t(messageKey, params) : (content ?? "");
  const descText = descriptionKey ? t(descriptionKey, params) : undefined;

  // Don't render tooltip wrapper if there's no content
  if (!mainText) {
    return <>{children}</>;
  }

  return (
    <TooltipPrimitive.Root delayDuration={delayDuration}>
      <TooltipPrimitive.Trigger asChild>{children}</TooltipPrimitive.Trigger>
      <TooltipPrimitive.Portal>
        <TooltipPrimitive.Content
          side={side}
          align={align}
          sideOffset={6}
          className={[
            "z-50 rounded-md px-3 py-2 text-xs leading-relaxed",
            "bg-surface-subtle text-foreground border border-strong shadow-md",
            "animate-in fade-in-0 zoom-in-95",
            "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95",
            "data-[side=top]:slide-in-from-bottom-2",
            "data-[side=bottom]:slide-in-from-top-2",
            "data-[side=left]:slide-in-from-right-2",
            "data-[side=right]:slide-in-from-left-2",
            className,
          ]
            .filter(Boolean)
            .join(" ")}
          style={{ maxWidth }}
        >
          <p className="font-medium">{mainText}</p>
          {descText && (
            <p className="mt-1 text-foreground-secondary opacity-90">
              {descText}
            </p>
          )}
          <TooltipPrimitive.Arrow className="fill-surface-subtle" />
        </TooltipPrimitive.Content>
      </TooltipPrimitive.Portal>
    </TooltipPrimitive.Root>
  );
}
