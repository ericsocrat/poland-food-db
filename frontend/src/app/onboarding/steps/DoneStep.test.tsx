import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { DoneStep } from "./DoneStep";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("DoneStep", () => {
  const onComplete = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}, loading = false) {
    return render(
      <DoneStep
        data={{ ...INITIAL_ONBOARDING_DATA, ...data }}
        loading={loading}
        onComplete={onComplete}
      />,
    );
  }

  it("renders the party emoji", () => {
    renderStep();
    expect(screen.getByText("🎉")).toBeInTheDocument();
  });

  it("renders the done title", () => {
    renderStep();
    expect(screen.getByText("You're all set!")).toBeInTheDocument();
  });

  it("renders the Go to Dashboard button", () => {
    renderStep();
    expect(screen.getByTestId("onboarding-complete")).toBeInTheDocument();
  });

  it("shows country name in summary", () => {
    renderStep({ country: "PL" });
    expect(screen.getByText("Poland")).toBeInTheDocument();
  });

  it("shows diet label in summary", () => {
    renderStep({ diet: "vegan" });
    expect(screen.getByText("Vegan")).toBeInTheDocument();
  });

  it("shows allergen labels in summary", () => {
    renderStep({ allergens: ["en:gluten", "en:milk"] });
    expect(screen.getByText("Gluten, Milk / Dairy")).toBeInTheDocument();
  });

  it('shows "None selected" when no allergens', () => {
    renderStep();
    // Multiple "None selected" texts for empty allergens, goals, categories
    const noneTexts = screen.getAllByText("None selected");
    expect(noneTexts.length).toBeGreaterThanOrEqual(1);
  });

  it("shows health goal count in summary", () => {
    renderStep({ healthGoals: ["diabetes", "low_sodium"] });
    expect(screen.getByText("2")).toBeInTheDocument();
  });

  it("shows category count in summary", () => {
    renderStep({ favoriteCategories: ["chips", "dairy", "meat"] });
    expect(screen.getByText("3")).toBeInTheDocument();
  });

  it("calls onComplete when button clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("onboarding-complete"));
    expect(onComplete).toHaveBeenCalledOnce();
  });

  it("disables button when loading", () => {
    renderStep({}, true);
    expect(screen.getByTestId("onboarding-complete")).toBeDisabled();
  });

  it('shows "Saving..." when loading', () => {
    renderStep({}, true);
    expect(screen.getByText("Saving...")).toBeInTheDocument();
  });
});
