"use client";

// ─── Onboarding Progress Indicator ──────────────────────────────────────────
// Accessible step progress bar for the onboarding wizard.

import { useTranslation } from "@/lib/i18n";

interface OnboardingProgressProps {
  readonly currentStep: number;
  readonly totalSteps: number;
}

export function OnboardingProgress({
  currentStep,
  totalSteps,
}: OnboardingProgressProps) {
  const { t } = useTranslation();

  return (
    <div className="mb-8">
      {/* Native progress for screen readers */}
      <progress
        className="sr-only"
        value={currentStep}
        max={totalSteps}
        aria-label={t("onboarding.stepOf", {
          current: String(currentStep),
          total: String(totalSteps),
        })}
      />
      {/* Visual segmented bar */}
      <div className="mb-2 flex gap-1.5" aria-hidden="true">
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
