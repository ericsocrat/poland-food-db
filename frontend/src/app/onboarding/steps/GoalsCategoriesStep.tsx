"use client";

// ─── Step 3: Health Goals + Categories ──────────────────────────────────────
// Combines health goals selection with favorite category selection.
// Issue #701: streamline onboarding from 7 steps to 4.

import type { StepProps } from "@/app/onboarding/types";
import { CategoryIcon } from "@/components/common/CategoryIcon";
import { FOOD_CATEGORIES, HEALTH_GOALS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

export function GoalsCategoriesStep({
  data,
  onChange,
  onNext,
  onBack,
}: Readonly<StepProps>) {
  const { t } = useTranslation();

  function toggleGoal(value: string) {
    const updated = data.healthGoals.includes(value)
      ? data.healthGoals.filter((g) => g !== value)
      : [...data.healthGoals, value];
    onChange({ healthGoals: updated });
  }

  function toggleCategory(slug: string) {
    const updated = data.favoriteCategories.includes(slug)
      ? data.favoriteCategories.filter((c) => c !== slug)
      : [...data.favoriteCategories, slug];
    onChange({ favoriteCategories: updated });
  }

  return (
    <div>
      {/* ── Health Goals section ── */}
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.healthGoalsTitle")}
      </h1>
      <p className="mb-6 text-sm text-foreground-secondary">
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

      {/* ── Categories section ── */}
      <div className="mt-8 border-t border-border pt-6">
        <h2 className="mb-2 text-lg font-semibold text-foreground">
          {t("onboarding.categoriesTitle")}
        </h2>
        <p className="mb-4 text-sm text-foreground-secondary">
          {t("onboarding.categoriesSubtitle")}
        </p>

        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
          {FOOD_CATEGORIES.map((cat) => (
            <button
              key={cat.slug}
              onClick={() => toggleCategory(cat.slug)}
              className={`flex items-center gap-2 rounded-lg border-2 px-3 py-2.5 text-sm transition-colors ${
                data.favoriteCategories.includes(cat.slug)
                  ? "border-brand bg-brand-subtle font-medium text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
              data-testid={`category-${cat.slug}`}
            >
              <CategoryIcon slug={cat.slug} size="md" />
              <span>{t(cat.labelKey)}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="mt-8 flex gap-3">
        <button onClick={onBack} className="btn-secondary flex-1">
          {t("onboarding.back")}
        </button>
        <button
          onClick={onNext}
          className="btn-primary flex-1"
          data-testid="onboarding-complete"
        >
          {t("onboarding.finish")}
        </button>
      </div>
    </div>
  );
}
