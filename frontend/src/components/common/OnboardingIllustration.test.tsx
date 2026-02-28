import { describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/react";
import {
  OnboardingIllustration,
  getOnboardingSteps,
  getOnboardingStepMeta,
} from "./OnboardingIllustration";
import type { OnboardingStep } from "./OnboardingIllustration";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/image", () => ({
  default: ({ priority, ...props }: Record<string, unknown>) => (
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    <img {...props} data-priority={priority ? "true" : "false"} />
  ),
}));

// ─── Step Types ─────────────────────────────────────────────────────────────

const ALL_STEPS: OnboardingStep[] = [
  "welcome",
  "country",
  "diet",
  "allergens",
  "ready",
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("OnboardingIllustration", () => {
  // ── Rendering per step ────────────────────────────────────────────────

  describe("renders correct illustration for each step", () => {
    it.each(ALL_STEPS)("renders %s illustration", (step) => {
      const { container } = render(<OnboardingIllustration step={step} />);

      const img = container.querySelector(
        `img[data-illustration="${step}"]`,
      ) as HTMLImageElement;
      expect(img).toBeInTheDocument();
    });
  });

  // ── SVG source paths ─────────────────────────────────────────────────

  describe("uses correct SVG source paths", () => {
    it.each([
      ["welcome", "/illustrations/onboarding/step-1-welcome.svg"],
      ["country", "/illustrations/onboarding/step-2-country.svg"],
      ["diet", "/illustrations/onboarding/step-3-diet.svg"],
      ["allergens", "/illustrations/onboarding/step-4-allergens.svg"],
      ["ready", "/illustrations/onboarding/step-5-ready.svg"],
    ] as [OnboardingStep, string][])(
      "%s uses %s",
      (step, expectedSrc) => {
        const { container } = render(<OnboardingIllustration step={step} />);
        const img = container.querySelector("img") as HTMLImageElement;
        expect(img.getAttribute("src")).toBe(expectedSrc);
      },
    );
  });

  // ── Alt text ──────────────────────────────────────────────────────────

  describe("sets descriptive alt text per step", () => {
    it("welcome mentions the app", () => {
      const { container } = render(<OnboardingIllustration step="welcome" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("welcome");
    });

    it("country mentions region selection", () => {
      const { container } = render(<OnboardingIllustration step="country" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("region");
    });

    it("diet mentions diet preferences", () => {
      const { container } = render(<OnboardingIllustration step="diet" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("diet");
    });

    it("allergens mentions allergen alerts", () => {
      const { container } = render(
        <OnboardingIllustration step="allergens" />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("allergen");
    });

    it("ready mentions setup complete", () => {
      const { container } = render(<OnboardingIllustration step="ready" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("complete");
    });
  });

  // ── Default dimensions ────────────────────────────────────────────────

  it("renders at default 280×280 dimensions", () => {
    const { container } = render(<OnboardingIllustration step="welcome" />);
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("width")).toBe("280");
    expect(img.getAttribute("height")).toBe("280");
  });

  // ── Custom dimensions ─────────────────────────────────────────────────

  it("accepts custom width and height", () => {
    const { container } = render(
      <OnboardingIllustration step="country" width={200} height={200} />,
    );
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("width")).toBe("200");
    expect(img.getAttribute("height")).toBe("200");
  });

  // ── data-testid ───────────────────────────────────────────────────────

  it("renders with data-testid onboarding-illustration", () => {
    const { container } = render(<OnboardingIllustration step="diet" />);
    const wrapper = container.querySelector(
      '[data-testid="onboarding-illustration"]',
    );
    expect(wrapper).toBeInTheDocument();
  });

  // ── data-step attribute ───────────────────────────────────────────────

  it.each(ALL_STEPS)("sets data-step=%s on wrapper", (step) => {
    const { container } = render(<OnboardingIllustration step={step} />);
    const wrapper = container.querySelector(`[data-step="${step}"]`);
    expect(wrapper).toBeInTheDocument();
  });

  // ── data-illustration attribute ───────────────────────────────────────

  it.each(ALL_STEPS)("sets data-illustration=%s on the image", (step) => {
    const { container } = render(<OnboardingIllustration step={step} />);
    const img = container.querySelector(`[data-illustration="${step}"]`);
    expect(img).toBeInTheDocument();
  });

  // ── className passthrough ─────────────────────────────────────────────

  it("passes className to wrapper div", () => {
    const { container } = render(
      <OnboardingIllustration step="ready" className="mx-auto mt-4" />,
    );
    const wrapper = container.querySelector(
      '[data-testid="onboarding-illustration"]',
    );
    expect(wrapper?.className).toContain("mx-auto mt-4");
  });

  // ── priority loading ──────────────────────────────────────────────────

  it("sets priority=false by default", () => {
    const { container } = render(<OnboardingIllustration step="welcome" />);
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("data-priority")).toBe("false");
  });

  it("passes priority=true when specified", () => {
    const { container } = render(
      <OnboardingIllustration step="welcome" priority />,
    );
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("data-priority")).toBe("true");
  });
});

// ─── Utility Functions ──────────────────────────────────────────────────────

describe("getOnboardingSteps", () => {
  it("returns all 5 onboarding steps", () => {
    const steps = getOnboardingSteps();
    expect(steps).toHaveLength(5);
    expect(steps).toEqual(expect.arrayContaining(ALL_STEPS));
  });
});

describe("getOnboardingStepMeta", () => {
  it("returns metadata with alt and src for each step", () => {
    for (const step of ALL_STEPS) {
      const meta = getOnboardingStepMeta(step);
      expect(meta.alt).toBeTruthy();
      expect(meta.src).toContain("onboarding");
      expect(meta.src).toMatch(/\.svg$/);
    }
  });

  it("returns correct src path for welcome", () => {
    const meta = getOnboardingStepMeta("welcome");
    expect(meta.src).toBe("/illustrations/onboarding/step-1-welcome.svg");
  });

  it("returns correct src path for ready", () => {
    const meta = getOnboardingStepMeta("ready");
    expect(meta.src).toBe("/illustrations/onboarding/step-5-ready.svg");
  });
});
