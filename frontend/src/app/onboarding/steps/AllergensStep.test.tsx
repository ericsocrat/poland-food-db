import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { AllergensStep } from "./AllergensStep";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("AllergensStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <AllergensStep
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

  it("renders all 14 EU allergen buttons", () => {
    renderStep();
    expect(screen.getByTestId("allergen-en:gluten")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:milk")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:eggs")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:nuts")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:peanuts")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:soybeans")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:fish")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:crustaceans")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:celery")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:mustard")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:sesame-seeds")).toBeInTheDocument();
    expect(
      screen.getByTestId("allergen-en:sulphur-dioxide-and-sulphites"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:lupin")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-en:molluscs")).toBeInTheDocument();
  });

  it("renders allergen labels", () => {
    renderStep();
    expect(screen.getByText("Gluten")).toBeInTheDocument();
    expect(screen.getByText("Milk / Dairy")).toBeInTheDocument();
    expect(screen.getByText("Peanuts")).toBeInTheDocument();
  });

  it("toggles allergen on when clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("allergen-en:gluten"));
    expect(onChange).toHaveBeenCalledWith({ allergens: ["en:gluten"] });
  });

  it("toggles allergen off when already selected", async () => {
    const user = userEvent.setup();
    renderStep({ allergens: ["en:gluten", "en:milk"] });
    await user.click(screen.getByTestId("allergen-en:gluten"));
    expect(onChange).toHaveBeenCalledWith({ allergens: ["en:milk"] });
  });

  it("does not show strictness toggles when no allergens selected", () => {
    renderStep();
    expect(screen.queryByRole("checkbox")).not.toBeInTheDocument();
  });

  it("shows strict allergen and may-contain toggles when allergens selected", () => {
    renderStep({ allergens: ["en:gluten"] });
    const checkboxes = screen.getAllByRole("checkbox");
    expect(checkboxes).toHaveLength(2);
  });

  it("calls onChange with strictAllergen when toggling strict checkbox", async () => {
    const user = userEvent.setup();
    renderStep({ allergens: ["en:gluten"] });
    const checkboxes = screen.getAllByRole("checkbox");
    await user.click(checkboxes[0]);
    expect(onChange).toHaveBeenCalledWith({ strictAllergen: true });
  });

  it("calls onChange with treatMayContain when toggling may-contain checkbox", async () => {
    const user = userEvent.setup();
    renderStep({ allergens: ["en:gluten"] });
    const checkboxes = screen.getAllByRole("checkbox");
    await user.click(checkboxes[1]);
    expect(onChange).toHaveBeenCalledWith({ treatMayContain: true });
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
