import {
  INITIAL_ONBOARDING_DATA,
  type OnboardingData,
} from "@/app/onboarding/types";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { DietAllergensStep } from "./DietAllergensStep";

describe("DietAllergensStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <DietAllergensStep
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

  // ─── Diet section ─────────────────────────────────────────────────────────

  it("renders diet title", () => {
    renderStep();
    expect(screen.getByText("Your diet")).toBeInTheDocument();
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

  it("shows strict diet toggle when diet is vegan", () => {
    renderStep({ diet: "vegan" });
    const checkboxes = screen.getAllByRole("checkbox");
    expect(checkboxes.length).toBeGreaterThanOrEqual(1);
  });

  it("calls onChange with strictDiet when toggling checkbox", async () => {
    const user = userEvent.setup();
    renderStep({ diet: "vegan" });
    const checkboxes = screen.getAllByRole("checkbox");
    await user.click(checkboxes[0]);
    expect(onChange).toHaveBeenCalledWith({ strictDiet: true });
  });

  // ─── Allergen section ─────────────────────────────────────────────────────

  it("renders allergen title", () => {
    renderStep();
    expect(screen.getByText("Allergens to avoid")).toBeInTheDocument();
  });

  it("renders allergen tags", () => {
    renderStep();
    expect(screen.getByTestId("allergen-gluten")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-milk")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-eggs")).toBeInTheDocument();
  });

  it("calls onChange with allergen toggled on", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("allergen-gluten"));
    expect(onChange).toHaveBeenCalledWith({ allergens: ["gluten"] });
  });

  it("calls onChange with allergen toggled off", async () => {
    const user = userEvent.setup();
    renderStep({ allergens: ["gluten", "milk"] });
    await user.click(screen.getByTestId("allergen-gluten"));
    expect(onChange).toHaveBeenCalledWith({ allergens: ["milk"] });
  });

  it("shows strict allergen toggles when allergens are selected", () => {
    renderStep({ allergens: ["gluten"] });
    expect(
      screen.getByText("Strict allergen matching"),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/Treat .* as unsafe/),
    ).toBeInTheDocument();
  });

  it("hides allergen toggles when no allergens selected", () => {
    renderStep({ allergens: [] });
    expect(
      screen.queryByText("Strict allergen matching"),
    ).not.toBeInTheDocument();
  });

  it("calls onChange with strictAllergen when toggling", async () => {
    const user = userEvent.setup();
    renderStep({ allergens: ["gluten"] });
    const checkboxes = screen.getAllByRole("checkbox");
    // First checkbox is strictAllergen
    await user.click(checkboxes[0]);
    expect(onChange).toHaveBeenCalledWith({ strictAllergen: true });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────

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
