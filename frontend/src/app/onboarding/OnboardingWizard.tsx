"use client";

// ─── OnboardingWizard — Multi-step onboarding flow ──────────────────────────
// Manages step state, accumulates preferences, submits atomically on completion.
// Issue #42: 7-step wizard (Welcome → Region → Diet → Allergens → Health Goals → Categories → Done).

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { completeOnboarding, skipOnboarding } from "@/lib/api";
import { showToast } from "@/lib/toast";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import { OnboardingProgress } from "./OnboardingProgress";
import { WelcomeStep } from "./steps/WelcomeStep";
import { RegionStep } from "./steps/RegionStep";
import { DietStep } from "./steps/DietStep";
import { AllergensStep } from "./steps/AllergensStep";
import { HealthGoalsStep } from "./steps/HealthGoalsStep";
import { CategoriesStep } from "./steps/CategoriesStep";
import { DoneStep } from "./steps/DoneStep";
import { INITIAL_ONBOARDING_DATA, TOTAL_STEPS } from "./types";
import type { OnboardingData } from "./types";

export function OnboardingWizard() {
  const router = useRouter();
  const supabase = createClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const [step, setStep] = useState(0); // 0-indexed
  const [data, setData] = useState<OnboardingData>(INITIAL_ONBOARDING_DATA);
  const [loading, setLoading] = useState(false);

  const updateData = useCallback((patch: Partial<OnboardingData>) => {
    setData((prev) => ({ ...prev, ...patch }));
  }, []);

  const goNext = useCallback(() => {
    setStep((s) => Math.min(s + 1, TOTAL_STEPS - 1));
  }, []);

  const goBack = useCallback(() => {
    setStep((s) => Math.max(s - 1, 0));
  }, []);

  async function handleSkipAll() {
    setLoading(true);
    const result = await skipOnboarding(supabase);
    setLoading(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    track("onboarding_completed", { skipped: true });
    router.push("/app/search");
    router.refresh();
  }

  async function handleComplete() {
    setLoading(true);
    const result = await completeOnboarding(supabase, {
      country: data.country,
      language: data.language || undefined,
      diet: data.diet,
      allergens: data.allergens,
      strict_allergen: data.strictAllergen,
      strict_diet: data.strictDiet,
      treat_may_contain_as_unsafe: data.treatMayContain,
      health_goals: data.healthGoals,
      favorite_categories: data.favoriteCategories,
    });
    setLoading(false);

    if (!result.ok) {
      showToast({
        type: "error",
        messageKey: "onboarding.onboardingFailed",
      });
      return;
    }

    track("onboarding_completed", {
      skipped: false,
      diet: data.diet,
      allergen_count: data.allergens.length,
      health_goal_count: data.healthGoals.length,
      category_count: data.favoriteCategories.length,
    });
    showToast({ type: "success", messageKey: "onboarding.preferencesSaved" });
    router.push("/app/search");
    router.refresh();
  }

  const stepProps = {
    data,
    onChange: updateData,
    onNext: goNext,
    onBack: goBack,
  };

  return (
    <div data-testid="onboarding-wizard">
      {/* Progress bar (hidden on Welcome and Done steps) */}
      {step > 0 && step < TOTAL_STEPS - 1 && (
        <OnboardingProgress currentStep={step} totalSteps={TOTAL_STEPS - 2} />
      )}

      {/* Step content */}
      {step === 0 && <WelcomeStep onNext={goNext} onSkipAll={handleSkipAll} />}
      {step === 1 && <RegionStep {...stepProps} />}
      {step === 2 && <DietStep {...stepProps} />}
      {step === 3 && <AllergensStep {...stepProps} />}
      {step === 4 && <HealthGoalsStep {...stepProps} />}
      {step === 5 && <CategoriesStep {...stepProps} />}
      {step === 6 && (
        <DoneStep data={data} loading={loading} onComplete={handleComplete} />
      )}

      {/* Skip all link (shown on steps 1–5, not on Welcome or Done) */}
      {step > 0 && step < TOTAL_STEPS - 1 && (
        <div className="mt-6 text-center">
          <button
            onClick={handleSkipAll}
            disabled={loading}
            className="text-sm text-foreground-secondary underline hover:text-foreground"
            data-testid="onboarding-skip-all"
          >
            {t("onboarding.skipAll")}
          </button>
        </div>
      )}
    </div>
  );
}
