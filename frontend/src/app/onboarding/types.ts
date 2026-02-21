// ─── Shared types for the onboarding wizard ─────────────────────────────────

export interface OnboardingData {
  country: string;
  language: string;
  diet: string;
  allergens: string[];
  strictAllergen: boolean;
  strictDiet: boolean;
  treatMayContain: boolean;
  healthGoals: string[];
  favoriteCategories: string[];
}

export const INITIAL_ONBOARDING_DATA: OnboardingData = {
  country: "",
  language: "",
  diet: "none",
  allergens: [],
  strictAllergen: false,
  strictDiet: false,
  treatMayContain: false,
  healthGoals: [],
  favoriteCategories: [],
};

export interface StepProps {
  readonly data: OnboardingData;
  readonly onChange: (patch: Partial<OnboardingData>) => void;
  readonly onNext: () => void;
  readonly onBack: () => void;
}

/** Total number of wizard steps (Welcome through Done). */
export const TOTAL_STEPS = 7;
