// ─── SectionError — Inline error card for failed data sections ──────────
// A presentation component for TanStack Query error states.
// Unlike ErrorBoundary (which catches render-time throws), this is used
// when a query returns an error object:
//
//   const { error, refetch } = useQuery(...);
//   if (error) return <SectionError error={error} onRetry={refetch} />;
//
// Shows a dashed-border card with an appropriate message and retry button.

"use client";

import { buttonClasses } from "@/components/common/Button";
import { classifyError, type ErrorCategory } from "@/lib/error-classifier";
import { useTranslation } from "@/lib/i18n";
import { AlertTriangle, RefreshCw, WifiOff } from "lucide-react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface SectionErrorProps {
  /** The error object from a failed query or operation. */
  error: Error;
  /** Callback to retry the failed operation (e.g., TanStack Query `refetch`). */
  onRetry?: () => void;
  /** Optional section label for context (e.g., "Nutrition data"). */
  label?: string;
}

// ─── Icon per error category ────────────────────────────────────────────────

const CATEGORY_ICON: Record<ErrorCategory, typeof AlertTriangle> = {
  network: WifiOff,
  auth: AlertTriangle,
  server: AlertTriangle,
  unknown: AlertTriangle,
};

const CATEGORY_I18N: Record<ErrorCategory, string> = {
  network: "sectionError.network",
  auth: "sectionError.auth",
  server: "sectionError.server",
  unknown: "sectionError.unknown",
};

// ─── Component ──────────────────────────────────────────────────────────────

export function SectionError({ error, onRetry, label }: SectionErrorProps) {
  const { t } = useTranslation();
  const category = classifyError(error);
  const Icon = CATEGORY_ICON[category];
  const messageKey = CATEGORY_I18N[category];

  return (
    <div
      className="my-4 flex flex-col items-center justify-center rounded-lg border border-dashed border-strong p-6 text-center"
      role="alert"
      data-testid="section-error"
      data-error-category={category}
    >
      <Icon
        size={24}
        className="mb-2 text-foreground-muted"
        aria-hidden="true"
      />
      <p className="mb-1 text-sm font-medium text-foreground">
        {label
          ? t("sectionError.labeledMessage", { label })
          : t(messageKey)}
      </p>
      {onRetry && (
        <button
          onClick={onRetry}
          className={buttonClasses("primary", "sm")}
          data-testid="section-error-retry"
        >
          <RefreshCw size={14} className="mr-1 inline" aria-hidden="true" />
          {t("common.tryAgain")}
        </button>
      )}
    </div>
  );
}
