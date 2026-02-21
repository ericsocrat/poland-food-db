"use client";

import { useTranslation } from "@/lib/i18n";
import { AlertTriangle } from "lucide-react";

interface DisclaimerProps {
  /** Optional additional classes */
  readonly className?: string;
}

/**
 * Medical/dietary disclaimer banner shown on all /learn pages.
 * Uses amber styling to draw attention without alarming.
 */
export function Disclaimer({ className = "" }: DisclaimerProps) {
  const { t } = useTranslation();

  return (
    <aside
      role="note"
      aria-label={t("learn.disclaimerLabel")}
      className={`rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900 dark:border-amber-800 dark:bg-amber-950/30 dark:text-amber-200 ${className}`}
    >
      <p className="flex items-start gap-2">
        <AlertTriangle
          size={18}
          className="mt-0.5 shrink-0"
          aria-hidden="true"
        />
        <span>{t("learn.disclaimer")}</span>
      </p>
    </aside>
  );
}
