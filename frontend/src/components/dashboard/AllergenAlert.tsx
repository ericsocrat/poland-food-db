"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { AlertTriangle } from "lucide-react";
import type { DashboardAllergenAlerts } from "@/lib/types";

interface AllergenAlertProps {
  alerts: DashboardAllergenAlerts;
}

/**
 * Surfaces a warning when favorites contain allergens the user wants to avoid.
 * Only rendered when count > 0.
 */
export function AllergenAlert({ alerts }: Readonly<AllergenAlertProps>) {
  const { t } = useTranslation();

  if (alerts.count === 0) return null;

  // Deduplicate allergen tags for the summary
  // Tags are bare canonical IDs; strip legacy en: prefix as fallback
  const uniqueAllergens = [
    ...new Set(alerts.products.map((p) => p.allergen.replace("en:", ""))),
  ];

  return (
    <div
      className="rounded-xl border border-score-orange/30 bg-score-orange/5 p-3 lg:p-4"
      role="alert"
      data-testid="allergen-alert"
    >
      <div className="flex items-start gap-2.5">
        <AlertTriangle
          size={20}
          className="mt-0.5 shrink-0 text-score-orange"
          aria-hidden="true"
        />
        <div className="min-w-0">
          <p className="text-sm font-semibold text-foreground">
            {t("dashboard.allergenAlertTitle")}
          </p>
          <p className="mt-0.5 text-sm leading-relaxed text-foreground-secondary">
            {t("dashboard.allergenAlertBody", {
              count: String(alerts.count),
              allergens: uniqueAllergens.join(", "),
            })}
          </p>
          <Link
            href="/app/lists"
            className="mt-1.5 inline-block text-xs font-medium text-brand transition-colors hover:text-brand-hover"
          >
            {t("dashboard.allergenAlertReview")} →
          </Link>
        </div>
      </div>
    </div>
  );
}
