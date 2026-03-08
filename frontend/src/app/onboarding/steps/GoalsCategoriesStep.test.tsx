import {
  INITIAL_ONBOARDING_DATA,
  type OnboardingData,
} from "@/app/onboarding/types";
import { FOOD_CATEGORIES, HEALTH_GOALS } from "@/lib/constants";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { GoalsCategoriesStep } from "./GoalsCategoriesStep";

describe("GoalsCategoriesStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <GoalsCategoriesStep
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

  // ─── Health Goals section ─────────────────────────────────────────────────

  it("renders health goals title", () => {
    renderStep();
    expect(screen.getByText("Health goals")).toBeInTheDocument();
  });

  it("renders all health goal options", () => {
    renderStep();
    for (const goal of HEALTH_GOALS) {
      expect(screen.getByTestId(`goal-${goal.value}`)).toBeInTheDocument();
    }
  });

  it("renders goal labels and descriptions", () => {
    renderStep();
    expect(screen.getByText("Diabetes management")).toBeInTheDocument();
    expect(
      screen.getByText(/Track sugar content/),
    ).toBeInTheDocument();
  });

  it("calls onChange with goal toggled on", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("goal-diabetes"));
    expect(onChange).toHaveBeenCalledWith({ healthGoals: ["diabetes"] });
  });

  it("calls onChange with goal toggled off", async () => {
    const user = userEvent.setup();
    renderStep({ healthGoals: ["diabetes", "low_sodium"] });
    await user.click(screen.getByTestId("goal-diabetes"));
    expect(onChange).toHaveBeenCalledWith({ healthGoals: ["low_sodium"] });
  });

  // ─── Categories section ───────────────────────────────────────────────────

  it("renders categories title", () => {
    renderStep();
    expect(
      screen.getByText("Favorite food categories"),
    ).toBeInTheDocument();
  });

  it("renders all category options", () => {
    renderStep();
    for (const cat of FOOD_CATEGORIES) {
      expect(screen.getByTestId(`category-${cat.slug}`)).toBeInTheDocument();
    }
  });

  it("calls onChange with category toggled on", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("category-bread"));
    expect(onChange).toHaveBeenCalledWith({
      favoriteCategories: ["bread"],
    });
  });

  it("calls onChange with category toggled off", async () => {
    const user = userEvent.setup();
    renderStep({ favoriteCategories: ["bread", "dairy"] });
    await user.click(screen.getByTestId("category-bread"));
    expect(onChange).toHaveBeenCalledWith({
      favoriteCategories: ["dairy"],
    });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────

  it("calls onBack when Back is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByText("Back"));
    expect(onBack).toHaveBeenCalledOnce();
  });

  it('renders the Finish button', () => {
    renderStep();
    expect(screen.getByTestId("onboarding-complete")).toBeInTheDocument();
    expect(screen.getByText("Finish")).toBeInTheDocument();
  });

  it("calls onNext when Finish is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("onboarding-complete"));
    expect(onNext).toHaveBeenCalledOnce();
  });
});
