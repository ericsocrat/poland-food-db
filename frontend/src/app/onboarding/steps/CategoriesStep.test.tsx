import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { CategoriesStep } from "./CategoriesStep";
import { FOOD_CATEGORIES } from "@/lib/constants";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("CategoriesStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <CategoriesStep
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

  it("renders all 17 food category buttons", () => {
    renderStep();
    for (const cat of FOOD_CATEGORIES) {
      expect(screen.getByTestId(`category-${cat.slug}`)).toBeInTheDocument();
    }
  });

  it("renders category emojis", () => {
    renderStep();
    expect(screen.getByText("🍞")).toBeInTheDocument();
    expect(screen.getByText("🍟")).toBeInTheDocument();
    expect(screen.getByText("🧀")).toBeInTheDocument();
  });

  it("toggles category on when clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("category-chips"));
    expect(onChange).toHaveBeenCalledWith({
      favoriteCategories: ["chips"],
    });
  });

  it("toggles category off when already selected", async () => {
    const user = userEvent.setup();
    renderStep({ favoriteCategories: ["chips", "dairy"] });
    await user.click(screen.getByTestId("category-chips"));
    expect(onChange).toHaveBeenCalledWith({
      favoriteCategories: ["dairy"],
    });
  });

  it("allows multiple categories", async () => {
    const user = userEvent.setup();
    renderStep({ favoriteCategories: ["chips"] });
    await user.click(screen.getByTestId("category-dairy"));
    expect(onChange).toHaveBeenCalledWith({
      favoriteCategories: ["chips", "dairy"],
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
