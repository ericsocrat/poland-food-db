"use client";

// ─── Step 3: Diet preference ────────────────────────────────────────────────

import { DIET_OPTIONS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { StepProps } from "../types";

export function DietStep({ data, onChange, onNext, onBack }: StepProps) {
  const { t } = useTranslation();

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.dietTitle")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.dietSubtitle")}
      </p>

      <div className="grid grid-cols-3 gap-2">
        {DIET_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            onClick={() => onChange({ diet: opt.value })}
            className={`rounded-lg border-2 px-3 py-3 text-sm transition-colors ${
              data.diet === opt.value
                ? "border-brand-500 bg-brand-50 font-medium text-brand-700"
                : "border text-foreground-secondary hover:border-strong"
            }`}
            data-testid={`diet-${opt.value}`}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {/* Strict diet toggle */}
      {data.diet !== "none" && (
        <label className="mt-6 flex cursor-pointer items-center gap-3">
          <input
            type="checkbox"
            checked={data.strictDiet}
            onChange={(e) => onChange({ strictDiet: e.target.checked })}
            className="h-4 w-4 rounded border-strong text-brand-600 focus:ring-brand-500"
          />
          <span className="text-sm text-foreground-secondary">
            {t("onboarding.strictDiet")}
          </span>
        </label>
      )}

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
