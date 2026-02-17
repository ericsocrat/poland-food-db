import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { DietStep } from "./DietStep";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("DietStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <DietStep
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

  it("renders all diet options", () => {
    renderStep();
    expect(screen.getByTestId("diet-none")).toBeInTheDocument();
    expect(screen.getByTestId("diet-vegetarian")).toBeInTheDocument();
    expect(screen.getByTestId("diet-vegan")).toBeInTheDocument();
  });

  it("renders diet labels", () => {
    renderStep();
    expect(screen.getByText("No restriction")).toBeInTheDocument();
    expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    expect(screen.getByText("Vegan")).toBeInTheDocument();
  });

  it("calls onChange with diet value when clicking an option", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("diet-vegetarian"));
    expect(onChange).toHaveBeenCalledWith({ diet: "vegetarian" });
  });

  it("does not show strict diet toggle when diet is none", () => {
    renderStep({ diet: "none" });
    expect(screen.queryByRole("checkbox")).not.toBeInTheDocument();
  });

  it("shows strict diet toggle when diet is vegetarian", () => {
    renderStep({ diet: "vegetarian" });
    expect(screen.getByRole("checkbox")).toBeInTheDocument();
  });

  it("shows strict diet toggle when diet is vegan", () => {
    renderStep({ diet: "vegan" });
    expect(screen.getByRole("checkbox")).toBeInTheDocument();
  });

  it("calls onChange with strictDiet when toggling checkbox", async () => {
    const user = userEvent.setup();
    renderStep({ diet: "vegan" });
    const checkbox = screen.getByRole("checkbox");
    await user.click(checkbox);
    expect(onChange).toHaveBeenCalledWith({ strictDiet: true });
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
