"use client";

import { useTranslation } from "@/lib/i18n";
import type { ProfileAllergens } from "@/lib/types";
import { AlertTriangle, ShieldCheck } from "lucide-react";

interface AllergenQuickBadgesProps {
  readonly allergens: ProfileAllergens;
}

function parseList(csv: string): string[] {
  if (!csv) return [];
  return csv.split(",").map((s) => s.trim()).filter(Boolean);
}

export function AllergenQuickBadges({ allergens }: AllergenQuickBadgesProps) {
  const { t } = useTranslation();
  const contains = parseList(allergens.contains);
  const traces = parseList(allergens.traces);

  if (contains.length === 0 && traces.length === 0) {
    return (
      <div className="card">
        <div className="flex items-center gap-2 text-sm text-score-green-text">
          <ShieldCheck className="h-4 w-4 flex-shrink-0" aria-hidden />
          <span>{t("product.noKnownAllergens")}</span>
        </div>
      </div>
    );
  }

  return (
    <div className="card">
      <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-foreground-muted">
        {t("allergenMatrix.title")}
      </p>
      <div className="flex flex-wrap gap-1.5">
        {contains.map((a) => (
          <span
            key={`c-${a}`}
            className="inline-flex items-center gap-1 rounded-full bg-error-bg px-2 py-0.5 text-xs font-medium text-error-text"
          >
            <AlertTriangle className="h-3 w-3 flex-shrink-0" aria-hidden />
            {a}
          </span>
        ))}
        {traces.map((a) => (
          <span
            key={`t-${a}`}
            className="rounded-full bg-warning-bg px-2 py-0.5 text-xs text-warning-text"
            title={t("allergenMatrix.traces")}
          >
            {a}
          </span>
        ))}
      </div>
    </div>
  );
}
