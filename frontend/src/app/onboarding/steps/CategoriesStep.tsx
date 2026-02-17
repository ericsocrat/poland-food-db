"use client";

// ─── Step 6: Favorite Food Categories ───────────────────────────────────────

import { FOOD_CATEGORIES } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { StepProps } from "../types";

export function CategoriesStep({ data, onChange, onNext, onBack }: StepProps) {
  const { t } = useTranslation();

  function toggleCategory(slug: string) {
    const updated = data.favoriteCategories.includes(slug)
      ? data.favoriteCategories.filter((c) => c !== slug)
      : [...data.favoriteCategories, slug];
    onChange({ favoriteCategories: updated });
  }

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        {t("onboarding.categoriesTitle")}
      </h1>
      <p className="mb-8 text-sm text-gray-500">
        {t("onboarding.categoriesSubtitle")}
      </p>

      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
        {FOOD_CATEGORIES.map((cat) => (
          <button
            key={cat.slug}
            onClick={() => toggleCategory(cat.slug)}
            className={`flex items-center gap-2 rounded-lg border-2 px-3 py-2.5 text-sm transition-colors ${
              data.favoriteCategories.includes(cat.slug)
                ? "border-brand-500 bg-brand-50 font-medium text-brand-700"
                : "border-gray-200 text-gray-700 hover:border-gray-300"
            }`}
            data-testid={`category-${cat.slug}`}
          >
            <span className="text-lg">{cat.emoji}</span>
            <span>{t(cat.labelKey)}</span>
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
