"use client";

// ─── Step 1: Welcome ────────────────────────────────────────────────────────

import { useTranslation } from "@/lib/i18n";

interface WelcomeStepProps {
  readonly onNext: () => void;
  readonly onSkipAll: () => void;
}

export function WelcomeStep({ onNext, onSkipAll }: WelcomeStepProps) {
  const { t } = useTranslation();

  return (
    <div className="text-center">
      <div className="mb-6 text-6xl">🍎</div>

      <h1 className="mb-3 text-2xl font-bold text-foreground">
        {t("onboarding.welcomeTitle")}
      </h1>
      <p className="mb-10 text-sm text-foreground-secondary">
        {t("onboarding.welcomeSubtitle")}
      </p>

      <button
        onClick={onNext}
        className="btn-primary mb-4 w-full"
        data-testid="onboarding-get-started"
      >
        {t("onboarding.getStarted")}
      </button>

      <button
        onClick={onSkipAll}
        className="w-full text-sm text-foreground-secondary underline hover:text-foreground"
        data-testid="onboarding-skip-all"
      >
        {t("onboarding.skipAll")}
      </button>
    </div>
  );
}
