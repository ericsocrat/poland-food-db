import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { OnboardingProgress } from "./OnboardingProgress";

describe("OnboardingProgress", () => {
  it("renders a progressbar", () => {
    render(<OnboardingProgress currentStep={2} totalSteps={5} />);
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
  });

  it("sets value to current step", () => {
    render(<OnboardingProgress currentStep={3} totalSteps={5} />);
    const bar = screen.getByRole("progressbar");
    expect(bar).toHaveAttribute("value", "3");
  });

  it("sets max to totalSteps", () => {
    render(<OnboardingProgress currentStep={2} totalSteps={5} />);
    const bar = screen.getByRole("progressbar");
    expect(bar).toHaveAttribute("max", "5");
  });

  it("renders correct number of step bars", () => {
    const { container } = render(
      <OnboardingProgress currentStep={2} totalSteps={5} />,
    );
    const bars = container.querySelectorAll('[class*="rounded-full"]');
    expect(bars).toHaveLength(5);
  });

  it("renders step text", () => {
    render(<OnboardingProgress currentStep={2} totalSteps={5} />);
    expect(screen.getByText("Step 2 of 5")).toBeInTheDocument();
  });
});
