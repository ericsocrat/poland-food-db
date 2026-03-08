"use client";

// ─── OnboardingWizard — Streamlined 3-step onboarding flow ──────────────────
// Issue #701: Merged from 7 steps → 3 visible steps + auto-complete.
// Step 0: Welcome + Region — Step 1: Diet + Allergens — Step 2: Goals + Categories
// Auto-saves to localStorage so refresh doesn't lose progress.

import { useAnalytics } from "@/hooks/use-analytics";
import { completeOnboarding, skipOnboarding } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { OnboardingProgress } from "./OnboardingProgress";
import { DietAllergensStep } from "./steps/DietAllergensStep";
import { GoalsCategoriesStep } from "./steps/GoalsCategoriesStep";
import { WelcomeRegionStep } from "./steps/WelcomeRegionStep";
import {
  INITIAL_ONBOARDING_DATA,
  ONBOARDING_STORAGE_KEY,
  TOTAL_STEPS,
  type OnboardingData,
} from "./types";

const STEP_NAMES = ["welcome_region", "diet_allergens", "goals_categories"] as const;

function loadPersistedState(): { step: number; data: OnboardingData } | null {
  try {
    const raw = localStorage.getItem(ONBOARDING_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { step: number; data: OnboardingData };
    if (typeof parsed.step !== "number" || !parsed.data) return null;
    return parsed;
  } catch {
    return null;
  }
}

export function OnboardingWizard() {
  const router = useRouter();
  const supabase = createClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const [step, setStep] = useState(() => loadPersistedState()?.step ?? 0);
  const [data, setData] = useState<OnboardingData>(
    () => loadPersistedState()?.data ?? INITIAL_ONBOARDING_DATA,
  );
  const [loading, setLoading] = useState(false);

  // Persist step + data to localStorage on every change
  useEffect(() => {
    try {
      localStorage.setItem(
        ONBOARDING_STORAGE_KEY,
        JSON.stringify({ step, data }),
      );
    } catch {
      // localStorage unavailable — silently ignore
    }
  }, [step, data]);

  const updateData = useCallback((patch: Partial<OnboardingData>) => {
    setData((prev) => ({ ...prev, ...patch }));
  }, []);

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

    // Clear persisted progress after successful save
    try {
      localStorage.removeItem(ONBOARDING_STORAGE_KEY);
    } catch {
      // noop
    }

    track("onboarding_completed", {
      skipped: false,
      diet: data.diet,
      allergen_count: data.allergens.length,
      health_goal_count: data.healthGoals.length,
      category_count: data.favoriteCategories.length,
    });
    showToast({ type: "success", messageKey: "onboarding.preferencesSaved" });
    router.push("/app/categories");
    router.refresh();
  }

  const goNext = useCallback(() => {
    setStep((s) => {
      const next = Math.min(s + 1, TOTAL_STEPS - 1);
      track("onboarding_step", { step: STEP_NAMES[next], step_index: next });
      return next;
    });
  }, [track]);

  const goBack = useCallback(() => {
    setStep((s) => {
      const prev = Math.max(s - 1, 0);
      track("onboarding_step", {
        step: STEP_NAMES[prev],
        step_index: prev,
        direction: "back",
      });
      return prev;
    });
  }, [track]);

  async function handleSkipAll() {
    setLoading(true);
    const result = await skipOnboarding(supabase);
    setLoading(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    // Clear persisted progress
    try {
      localStorage.removeItem(ONBOARDING_STORAGE_KEY);
    } catch {
      // noop
    }

    track("onboarding_completed", { skipped: true });
    router.push("/app/categories");
    router.refresh();
  }

  const stepProps = {
    data,
    onChange: updateData,
    onNext: step === TOTAL_STEPS - 1 ? handleComplete : goNext,
    onBack: goBack,
  };

  return (
    <div data-testid="onboarding-wizard">
      {/* Progress bar (shown on all steps) */}
      <OnboardingProgress currentStep={step + 1} totalSteps={TOTAL_STEPS} />

      {/* Step content */}
      {step === 0 && (
        <WelcomeRegionStep {...stepProps} onSkipAll={handleSkipAll} />
      )}
      {step === 1 && <DietAllergensStep {...stepProps} />}
      {step === 2 && <GoalsCategoriesStep {...stepProps} />}

      {/* Skip link (shown on steps 1+; step 0 has its own skip button) */}
      {step > 0 && (
        <div className="mt-6 text-center">
          <button
            onClick={handleSkipAll}
            disabled={loading}
            className="text-sm text-foreground-secondary underline hover:text-foreground"
            data-testid="onboarding-skip-all"
          >
            {t("onboarding.skipForNow")}
          </button>
        </div>
      )}
    </div>
  );
}
