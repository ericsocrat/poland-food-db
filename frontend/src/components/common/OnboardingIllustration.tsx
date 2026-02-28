// ─── OnboardingIllustration ──────────────────────────────────────────
// Maps 5 onboarding step types to branded SVG illustrations (280×280).
// Each step has a contextual illustration that visually reinforces the
// wizard step's purpose. Drop-in for any onboarding step layout.
// ─────────────────────────────────────────────────────────────────────

import Image from "next/image";

// ─── Types ───────────────────────────────────────────────────────────

/**
 * Onboarding step illustration types.
 * Each maps to a dedicated SVG in public/illustrations/onboarding/.
 */
export type OnboardingStep =
  | "welcome"
  | "country"
  | "diet"
  | "allergens"
  | "ready";

export interface OnboardingIllustrationProps {
  /** Which onboarding step illustration to display */
  readonly step: OnboardingStep;
  /** Override the default width (280) */
  readonly width?: number;
  /** Override the default height (280) */
  readonly height?: number;
  /** Additional CSS classes on the wrapper */
  readonly className?: string;
  /** Whether to use priority loading (above the fold) */
  readonly priority?: boolean;
}

// ─── Illustration Metadata ───────────────────────────────────────────

interface StepMeta {
  /** Alt text for the illustration image */
  alt: string;
  /** Path to the SVG file in public/ */
  src: string;
}

const STEP_META: Record<OnboardingStep, StepMeta> = {
  welcome: {
    alt: "Shield-leaf logo with food motifs — welcome to the app",
    src: "/illustrations/onboarding/step-1-welcome.svg",
  },
  country: {
    alt: "Globe with country selection pins — choose your region",
    src: "/illustrations/onboarding/step-2-country.svg",
  },
  diet: {
    alt: "Plate with food group sections — select your diet preferences",
    src: "/illustrations/onboarding/step-3-diet.svg",
  },
  allergens: {
    alt: "Shield with allergen icons — set your allergen alerts",
    src: "/illustrations/onboarding/step-4-allergens.svg",
  },
  ready: {
    alt: "Checkmark with confetti — setup complete, ready to explore",
    src: "/illustrations/onboarding/step-5-ready.svg",
  },
};

// ─── Utilities ───────────────────────────────────────────────────────

/** Returns all available onboarding step strings. */
export function getOnboardingSteps(): OnboardingStep[] {
  return Object.keys(STEP_META) as OnboardingStep[];
}

/** Returns metadata for a given onboarding step. */
export function getOnboardingStepMeta(step: OnboardingStep): StepMeta {
  return STEP_META[step];
}

// ─── Component ───────────────────────────────────────────────────────

/**
 * Branded SVG illustration for onboarding wizard steps.
 *
 * All illustrations are 280×280 with dark mode support via
 * `prefers-color-scheme` media queries embedded in the SVGs.
 */
export function OnboardingIllustration({
  step,
  width = 280,
  height = 280,
  className,
  priority = false,
}: OnboardingIllustrationProps) {
  const meta = STEP_META[step];

  return (
    <div
      className={className}
      data-testid="onboarding-illustration"
      data-step={step}
    >
      <Image
        src={meta.src}
        alt={meta.alt}
        width={width}
        height={height}
        priority={priority}
        data-illustration={step}
      />
    </div>
  );
}
