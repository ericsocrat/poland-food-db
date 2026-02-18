"use client";

// ─── NutritionTip — cycling daily health tip card ───────────────────────────

import { useTranslation } from "@/lib/i18n";

/** Total number of tips available in i18n files (dashboard.tip.0 … tip.N-1). */
const TIP_COUNT = 14;

/**
 * Deterministic tip index based on the current day of the year.
 * Cycles through all tips, so each day shows a different one.
 */
export function tipIndexForToday(): number {
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 0);
  const dayOfYear = Math.floor(
    (now.getTime() - start.getTime()) / (1000 * 60 * 60 * 24),
  );
  return dayOfYear % TIP_COUNT;
}

export function NutritionTip() {
  const { t } = useTranslation();
  const index = tipIndexForToday();

  return (
    <section
      className="rounded-xl border bg-surface p-4 shadow-sm"
      aria-label={t("dashboard.tipTitle")}
    >
      <div className="flex items-start gap-3">
        <span className="text-2xl" aria-hidden="true">
          💡
        </span>
        <div className="min-w-0">
          <h3 className="text-sm font-semibold text-foreground">
            {t("dashboard.tipTitle")}
          </h3>
          <p className="mt-0.5 text-sm leading-relaxed text-muted-foreground">
            {t(`dashboard.tip.${index}`)}
          </p>
        </div>
      </div>
    </section>
  );
}
