/**
 * Alert — inline feedback banner for form errors, deprecation notices, etc.
 *
 * Supports 4 semantic variants, optional title, dismissible mode, and
 * custom icon. All styling via design tokens.
 */

"use client";

import { useState, type ReactNode } from "react";
import { Info, CheckCircle, AlertTriangle, XCircle, X } from "lucide-react";
import type { LucideIcon } from "lucide-react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type AlertVariant = "info" | "success" | "warning" | "error";

export interface AlertProps {
  /** Semantic variant. @default "info" */
  readonly variant?: AlertVariant;
  /** Optional bold title above the message. */
  readonly title?: string;
  /** Alert body content. */
  readonly children: ReactNode;
  /** Show a dismiss (✕) button. */
  readonly dismissible?: boolean;
  /** Custom icon node — overrides default variant icon. */
  readonly icon?: ReactNode;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Variant styling ────────────────────────────────────────────────────────

interface VariantConfig {
  bg: string;
  border: string;
  text: string;
  icon: LucideIcon;
}

const VARIANT_CONFIGS: Record<AlertVariant, VariantConfig> = {
  info: {
    bg: "bg-info/10",
    border: "border-info/30",
    text: "text-info",
    icon: Info,
  },
  success: {
    bg: "bg-success/10",
    border: "border-success/30",
    text: "text-success",
    icon: CheckCircle,
  },
  warning: {
    bg: "bg-warning/10",
    border: "border-warning/30",
    text: "text-warning",
    icon: AlertTriangle,
  },
  error: {
    bg: "bg-error/10",
    border: "border-error/30",
    text: "text-error",
    icon: XCircle,
  },
};

// ─── Component ──────────────────────────────────────────────────────────────

export function Alert({
  variant = "info",
  title,
  children,
  dismissible = false,
  icon,
  className = "",
}: Readonly<AlertProps>) {
  const [dismissed, setDismissed] = useState(false);

  if (dismissed) return null;

  const config = VARIANT_CONFIGS[variant];

  return (
    <div
      role="alert"
      className={[
        "flex gap-3 rounded-lg border p-4",
        config.bg,
        config.border,
        className,
      ]
        .filter(Boolean)
        .join(" ")}
    >
      <span className="shrink-0" aria-hidden="true">
        {icon ?? <config.icon size={20} />}
      </span>
      <div className="flex-1 min-w-0">
        {title && (
          <p className={`font-semibold text-sm ${config.text}`}>{title}</p>
        )}
        <div
          className={`text-sm ${title ? "mt-1" : ""} text-foreground-secondary`}
        >
          {children}
        </div>
      </div>
      {dismissible && (
        <button
          type="button"
          onClick={() => setDismissed(true)}
          className="shrink-0 text-foreground-muted hover:text-foreground transition-colors"
          aria-label="Dismiss"
        >
          <X size={18} aria-hidden="true" />
        </button>
      )}
    </div>
  );
}
