"use client";

// ─── Onboarding Progress Indicator ──────────────────────────────────────────
// Accessible step progress bar for the onboarding wizard.

import { useTranslation } from "@/lib/i18n";

interface OnboardingProgressProps {
  currentStep: number;
  totalSteps: number;
}

export function OnboardingProgress({
  currentStep,
  totalSteps,
}: OnboardingProgressProps) {
  const { t } = useTranslation();

  return (
    <div className="mb-8">
      <div
        className="mb-2 flex gap-1.5"
        role="progressbar"
        aria-valuenow={currentStep}
        aria-valuemin={1}
        aria-valuemax={totalSteps}
        aria-label={t("onboarding.stepOf", {
          current: String(currentStep),
          total: String(totalSteps),
        })}
      >
        {Array.from({ length: totalSteps }, (_, i) => (
          <div
            key={i}
            className={`h-2 flex-1 rounded-full transition-colors ${
              i < currentStep ? "bg-brand-subtle0" : "bg-surface-muted"
            }`}
          />
        ))}
      </div>
      <p className="text-center text-xs text-foreground-secondary">
        {t("onboarding.stepOf", {
          current: String(currentStep),
          total: String(totalSteps),
        })}
      </p>
    </div>
  );
}
