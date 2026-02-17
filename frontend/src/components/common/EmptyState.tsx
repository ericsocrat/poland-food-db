"use client";

// ─── EmptyState ─────────────────────────────────────────────────────────────
// Reusable empty-state component with four preset variants. Provides consistent
// layout, i18n, and accessibility across all collection/list/search pages.

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

interface EmptyStateAction {
  /** i18n key for the button / link label. */
  labelKey: string;
  /** If provided, renders as a Next.js Link. */
  href?: string;
  /** If provided (without href), renders as a <button>. */
  onClick?: () => void;
}

export interface EmptyStateProps {
  /** Variant determines the default icon. */
  readonly variant: "no-data" | "no-results" | "error" | "offline";
  /** Custom icon node — overrides the default emoji for the variant. */
  readonly icon?: React.ReactNode;
  /** i18n key resolved to the title heading. */
  readonly titleKey: string;
  /** i18n key resolved to the description paragraph. */
  readonly descriptionKey?: string;
  /** i18n interpolation params for titleKey. */
  readonly titleParams?: Record<string, string | number>;
  /** i18n interpolation params for descriptionKey. */
  readonly descriptionParams?: Record<string, string | number>;
  /** Primary call-to-action. */
  readonly action?: EmptyStateAction;
  /** Optional secondary call-to-action. */
  readonly secondaryAction?: EmptyStateAction;
  /** Additional CSS classes on the root container. */
  readonly className?: string;
}

// ─── Default icons per variant ──────────────────────────────────────────────

const DEFAULT_ICONS: Record<EmptyStateProps["variant"], string> = {
  "no-data": "📋",
  "no-results": "🔍",
  error: "⚠️",
  offline: "📡",
};

// ─── Component ──────────────────────────────────────────────────────────────

/**
 * Standard empty-state card with icon, title, optional description, and up to
 * two CTA actions. All text comes from i18n dictionaries.
 */
export function EmptyState({
  variant,
  icon,
  titleKey,
  descriptionKey,
  titleParams,
  descriptionParams,
  action,
  secondaryAction,
  className = "",
}: EmptyStateProps) {
  const { t } = useTranslation();

  return (
    <div
      className={`flex min-h-[180px] flex-col items-center justify-center py-12 text-center ${className}`}
      data-testid="empty-state"
      data-variant={variant}
    >
      {/* Icon — decorative, hidden from screen readers */}
      <p className="mb-3 text-4xl" aria-hidden="true">
        {icon ?? DEFAULT_ICONS[variant]}
      </p>

      {/* Title */}
      <h3 className="mb-1 text-sm font-semibold text-gray-600">
        {t(titleKey, titleParams)}
      </h3>

      {/* Description */}
      {descriptionKey && (
        <p className="mb-4 max-w-xs text-xs text-gray-400">
          {t(descriptionKey, descriptionParams)}
        </p>
      )}

      {/* Actions */}
      {(action || secondaryAction) && (
        <div className="mt-2 flex flex-wrap items-center justify-center gap-2">
          {action && <ActionButton action={action} primary />}
          {secondaryAction && <ActionButton action={secondaryAction} />}
        </div>
      )}
    </div>
  );
}

// ─── Internal: Action Button / Link ─────────────────────────────────────────

function ActionButton({
  action,
  primary = false,
}: Readonly<{
  action: EmptyStateAction;
  primary?: boolean;
}>) {
  const { t } = useTranslation();
  const label = t(action.labelKey);

  const baseClasses = primary
    ? "rounded-lg bg-brand-600 px-4 py-2 text-xs font-medium text-white hover:bg-brand-700 transition-colors"
    : "text-xs font-medium text-brand-600 hover:text-brand-700 underline underline-offset-2 transition-colors";

  if (action.href) {
    return (
      <Link href={action.href} className={baseClasses}>
        {label}
      </Link>
    );
  }

  if (action.onClick) {
    return (
      <button type="button" onClick={action.onClick} className={baseClasses}>
        {label}
      </button>
    );
  }

  return null;
}
