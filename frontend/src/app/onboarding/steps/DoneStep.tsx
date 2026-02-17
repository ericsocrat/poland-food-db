"use client";

// ─── Step 7: Done — Summary + CTA ──────────────────────────────────────────

import { COUNTRIES, DIET_OPTIONS, ALLERGEN_TAGS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { OnboardingData } from "../types";

interface DoneStepProps {
  data: OnboardingData;
  loading: boolean;
  onComplete: () => void;
}

export function DoneStep({ data, loading, onComplete }: DoneStepProps) {
  const { t } = useTranslation();

  const countryName =
    COUNTRIES.find((c) => c.code === data.country)?.name ?? data.country;
  const dietLabel =
    DIET_OPTIONS.find((d) => d.value === data.diet)?.label ?? data.diet;
  const allergenLabels = data.allergens
    .map((tag) => ALLERGEN_TAGS.find((a) => a.tag === tag)?.label ?? tag)
    .join(", ");

  function summaryRow(label: string, value: string) {
    return (
      <div className="flex justify-between border-b border-gray-100 py-2">
        <span className="text-sm text-gray-500">{label}</span>
        <span className="text-sm font-medium text-gray-900">{value}</span>
      </div>
    );
  }

  return (
    <div className="text-center">
      <div className="mb-4 text-5xl">🎉</div>
      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        {t("onboarding.doneTitle")}
      </h1>
      <p className="mb-8 text-sm text-gray-500">
        {t("onboarding.doneSubtitle")}
      </p>

      {/* Summary card */}
      <div className="mb-8 rounded-xl border border-gray-200 bg-white p-4 text-left">
        {summaryRow(t("onboarding.summaryRegion"), countryName)}
        {summaryRow(t("onboarding.summaryDiet"), dietLabel)}
        {summaryRow(
          t("onboarding.summaryAllergens"),
          allergenLabels || t("onboarding.noneSelected"),
        )}
        {summaryRow(
          t("onboarding.summaryHealthGoals"),
          data.healthGoals.length > 0
            ? data.healthGoals.length.toString()
            : t("onboarding.noneSelected"),
        )}
        {summaryRow(
          t("onboarding.summaryCategories"),
          data.favoriteCategories.length > 0
            ? data.favoriteCategories.length.toString()
            : t("onboarding.noneSelected"),
        )}
      </div>

      <button
        onClick={onComplete}
        disabled={loading}
        className="btn-primary w-full"
        data-testid="onboarding-complete"
      >
        {loading ? t("onboarding.saving") : t("onboarding.goToDashboard")}
      </button>
    </div>
  );
}
