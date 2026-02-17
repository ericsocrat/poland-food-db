import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { HealthGoalsStep } from "./HealthGoalsStep";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("HealthGoalsStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <HealthGoalsStep
        data={{ ...INITIAL_ONBOARDING_DATA, ...data }}
        onChange={onChange}
        onNext={onNext}
        onBack={onBack}
      />,
    );
  }

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders all 5 health goal buttons", () => {
    renderStep();
    expect(screen.getByTestId("goal-diabetes")).toBeInTheDocument();
    expect(screen.getByTestId("goal-low_sodium")).toBeInTheDocument();
    expect(screen.getByTestId("goal-heart_health")).toBeInTheDocument();
    expect(screen.getByTestId("goal-weight_management")).toBeInTheDocument();
    expect(screen.getByTestId("goal-general_wellness")).toBeInTheDocument();
  });

  it("renders goal labels and descriptions", () => {
    renderStep();
    expect(screen.getByText("Diabetes management")).toBeInTheDocument();
    expect(screen.getByText("Low sodium")).toBeInTheDocument();
    expect(screen.getByText("Heart health")).toBeInTheDocument();
  });

  it("toggles goal on when clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("goal-diabetes"));
    expect(onChange).toHaveBeenCalledWith({ healthGoals: ["diabetes"] });
  });

  it("toggles goal off when already selected", async () => {
    const user = userEvent.setup();
    renderStep({ healthGoals: ["diabetes", "low_sodium"] });
    await user.click(screen.getByTestId("goal-diabetes"));
    expect(onChange).toHaveBeenCalledWith({ healthGoals: ["low_sodium"] });
  });

  it("allows multiple goals", async () => {
    const user = userEvent.setup();
    renderStep({ healthGoals: ["diabetes"] });
    await user.click(screen.getByTestId("goal-heart_health"));
    expect(onChange).toHaveBeenCalledWith({
      healthGoals: ["diabetes", "heart_health"],
    });
  });

  it("calls onBack when Back is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByText("Back"));
    expect(onBack).toHaveBeenCalledOnce();
  });

  it("calls onNext when Next is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByText("Next"));
    expect(onNext).toHaveBeenCalledOnce();
  });
});
