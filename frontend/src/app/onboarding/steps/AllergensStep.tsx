"use client";

// ─── Step 4: Allergen selection ─────────────────────────────────────────────

import { ALLERGEN_TAGS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { StepProps } from "../types";

export function AllergensStep({ data, onChange, onNext, onBack }: StepProps) {
  const { t } = useTranslation();

  function toggleAllergen(tag: string) {
    const updated = data.allergens.includes(tag)
      ? data.allergens.filter((a) => a !== tag)
      : [...data.allergens, tag];
    onChange({ allergens: updated });
  }

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.allergenTitle")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.allergenSubtitle")}
      </p>

      <div className="flex flex-wrap gap-2">
        {ALLERGEN_TAGS.map((a) => (
          <button
            key={a.tag}
            onClick={() => toggleAllergen(a.tag)}
            className={`rounded-full border px-3 py-1.5 text-sm transition-colors ${
              data.allergens.includes(a.tag)
                ? "border-red-300 bg-red-50 text-red-700"
                : "border text-foreground-secondary hover:border-strong"
            }`}
            data-testid={`allergen-${a.tag}`}
          >
            {a.label}
          </button>
        ))}
      </div>

      {/* Allergen strictness toggles */}
      {data.allergens.length > 0 && (
        <div className="mt-6 space-y-3">
          <label className="flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={data.strictAllergen}
              onChange={(e) => onChange({ strictAllergen: e.target.checked })}
              className="h-4 w-4 rounded border-strong text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-foreground-secondary">
              {t("onboarding.strictAllergen")}
            </span>
          </label>
          <label className="flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={data.treatMayContain}
              onChange={(e) => onChange({ treatMayContain: e.target.checked })}
              className="h-4 w-4 rounded border-strong text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-foreground-secondary">
              {t("onboarding.treatMayContain")}
            </span>
          </label>
        </div>
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
