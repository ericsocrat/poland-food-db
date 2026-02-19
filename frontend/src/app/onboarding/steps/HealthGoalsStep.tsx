"use client";

// ─── Step 5: Health Goals ───────────────────────────────────────────────────

import { HEALTH_GOALS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { StepProps } from "../types";

export function HealthGoalsStep({ data, onChange, onNext, onBack }: StepProps) {
  const { t } = useTranslation();

  function toggleGoal(value: string) {
    const updated = data.healthGoals.includes(value)
      ? data.healthGoals.filter((g) => g !== value)
      : [...data.healthGoals, value];
    onChange({ healthGoals: updated });
  }

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.healthGoalsTitle")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.healthGoalsSubtitle")}
      </p>

      <div className="space-y-3">
        {HEALTH_GOALS.map((goal) => (
          <button
            key={goal.value}
            onClick={() => toggleGoal(goal.value)}
            className={`flex w-full flex-col rounded-xl border-2 p-4 text-left transition-colors ${
              data.healthGoals.includes(goal.value)
                ? "border-brand bg-brand-subtle"
                : "border bg-surface hover:border-strong"
            }`}
            data-testid={`goal-${goal.value}`}
          >
            <span className="font-semibold text-foreground">
              {t(goal.labelKey)}
            </span>
            <span className="mt-1 text-sm text-foreground-secondary">
              {t(goal.descKey)}
            </span>
          </button>
        ))}
      </div>

      <div className="mt-8 flex gap-3">
        <button onClick={onBack} className="btn-secondary flex-1">
          {t("onboarding.back")}
        </button>
        <button onClick={onNext} className="btn-primary flex-1">
          {t("onboarding.next")}
        </button>
      </div>
    </div>
  );
}
