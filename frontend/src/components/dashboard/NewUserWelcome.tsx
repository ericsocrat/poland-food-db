"use client";

// ─── NewUserWelcome — onboarding CTA for users with no activity ─────────────

import { useTranslation } from "@/lib/i18n";
import { Camera, Grid3X3 } from "lucide-react";
import Link from "next/link";
import { tipIndexForToday } from "./NutritionTip";

/**
 * Reuses existing tip keys (dashboard.tip.0 … tip.13) for the fun fact.
 * Same count as NutritionTip's TIP_COUNT.
 */
const FUN_FACT_COUNT = 14;

export function NewUserWelcome() {
  const { t } = useTranslation();
  const factIndex = tipIndexForToday() % FUN_FACT_COUNT;

  return (
    <section
      className="space-y-4"
      aria-label={t("dashboard.newUserTitle")}
      data-testid="new-user-welcome"
    >
      {/* Header */}
      <div className="text-center">
        <h2 className="text-lg font-semibold">{t("dashboard.newUserTitle")}</h2>
        <p className="text-sm text-foreground-secondary">
          {t("dashboard.newUserSubtitle")}
        </p>
      </div>

      {/* Action cards */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
        {/* Scan CTA */}
        <Link
          href="/app/scan"
          className="card hover-lift-press flex items-center gap-4 rounded-xl border bg-surface p-4 shadow-sm"
          data-testid="new-user-scan-cta"
        >
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-brand/10">
            <Camera size={24} className="text-brand" />
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold">
              {t("dashboard.newUserScanTitle")}
            </p>
            <p className="text-xs text-foreground-secondary">
              {t("dashboard.newUserScanDesc")}
            </p>
          </div>
        </Link>

        {/* Browse CTA */}
        <Link
          href="/app/categories"
          className="card hover-lift-press flex items-center gap-4 rounded-xl border bg-surface p-4 shadow-sm"
          data-testid="new-user-browse-cta"
        >
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-brand/10">
            <Grid3X3 size={24} className="text-brand" />
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold">
              {t("dashboard.newUserBrowseTitle")}
            </p>
            <p className="text-xs text-foreground-secondary">
              {t("dashboard.newUserBrowseDesc")}
            </p>
          </div>
        </Link>
      </div>

      {/* Fun fact */}
      <div
        className="rounded-xl border bg-surface p-4 shadow-sm"
        data-testid="new-user-fun-fact"
      >
        <p className="text-xs font-semibold uppercase tracking-wide text-foreground-secondary">
          {t("dashboard.newUserFunFact")}
        </p>
        <p className="mt-1 text-sm">{t(`dashboard.tip.${factIndex}`)}</p>
      </div>
    </section>
  );
}
