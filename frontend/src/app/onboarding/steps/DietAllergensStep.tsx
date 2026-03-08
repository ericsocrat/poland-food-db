"use client";

// ─── Step 2: Diet + Allergens ───────────────────────────────────────────────
// Combines diet preference selection with allergen checklist in a single step.
// Issue #701: streamline onboarding from 7 steps to 4.

import type { StepProps } from "@/app/onboarding/types";
import { Button } from "@/components/common/Button";
import { ALLERGEN_TAGS, DIET_OPTIONS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

export function DietAllergensStep({
  data,
  onChange,
  onNext,
  onBack,
}: Readonly<StepProps>) {
  const { t } = useTranslation();

  function toggleAllergen(tag: string) {
    const updated = data.allergens.includes(tag)
      ? data.allergens.filter((a) => a !== tag)
      : [...data.allergens, tag];
    onChange({ allergens: updated });
  }

  return (
    <div>
      {/* ── Diet section ── */}
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.dietTitle")}
      </h1>
      <p className="mb-6 text-sm text-foreground-secondary">
        {t("onboarding.dietSubtitle")}
      </p>

      <div className="grid grid-cols-3 gap-2">
        {DIET_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            onClick={() => onChange({ diet: opt.value })}
            className={`rounded-lg border-2 px-3 py-3 text-sm transition-colors ${
              data.diet === opt.value
                ? "border-brand bg-brand-subtle font-medium text-brand"
                : "border text-foreground-secondary hover:border-strong"
            }`}
            data-testid={`diet-${opt.value}`}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {data.diet !== "none" && (
        <label className="mt-4 flex cursor-pointer items-center gap-3">
          <input
            type="checkbox"
            checked={data.strictDiet}
            onChange={(e) => onChange({ strictDiet: e.target.checked })}
            className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
          />
          <span className="text-sm text-foreground-secondary">
            {t("onboarding.strictDiet")}
          </span>
        </label>
      )}

      {/* ── Allergens section ── */}
      <div className="mt-8 border-t border-border pt-6">
        <h2 className="mb-2 text-lg font-semibold text-foreground">
          {t("onboarding.allergenTitle")}
        </h2>
        <p className="mb-4 text-sm text-foreground-secondary">
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

        {data.allergens.length > 0 && (
          <div className="mt-4 space-y-3">
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={data.strictAllergen}
                onChange={(e) =>
                  onChange({ strictAllergen: e.target.checked })
                }
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("onboarding.strictAllergen")}
              </span>
            </label>
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={data.treatMayContain}
                onChange={(e) =>
                  onChange({ treatMayContain: e.target.checked })
                }
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("onboarding.treatMayContain")}
              </span>
            </label>
          </div>
        )}
      </div>

      <div className="mt-8 flex gap-3">
        <Button variant="secondary" onClick={onBack} className="flex-1">
          {t("onboarding.back")}
        </Button>
        <Button onClick={onNext} className="flex-1">
          {t("onboarding.next")}
        </Button>
      </div>
    </div>
  );
}
