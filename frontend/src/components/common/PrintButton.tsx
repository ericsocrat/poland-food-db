"use client";

import { useTranslation } from "@/lib/i18n";
import { Printer } from "lucide-react";

interface PrintButtonProps {
  /** Optional additional classes */
  readonly className?: string;
}

/**
 * Subtle print button that triggers window.print().
 * Hidden in print mode via the `no-print` class.
 */
export function PrintButton({ className = "" }: PrintButtonProps) {
  const { t } = useTranslation();

  return (
    <button
      type="button"
      onClick={() => globalThis.print()}
      className={`no-print inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm text-foreground-secondary transition-colors hover:bg-surface-subtle hover:text-foreground ${className}`}
      aria-label={t("print.printPage")}
    >
      <Printer size={16} aria-hidden="true" />{" "}
      <span className="hidden sm:inline">{t("print.button")}</span>
    </button>
  );
}
