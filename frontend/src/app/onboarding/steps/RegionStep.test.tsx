import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { RegionStep } from "./RegionStep";
import { INITIAL_ONBOARDING_DATA } from "../types";
import type { OnboardingData } from "../types";

describe("RegionStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <RegionStep
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

  it("renders country buttons for PL and DE", () => {
    renderStep();
    expect(screen.getByTestId("country-PL")).toBeInTheDocument();
    expect(screen.getByTestId("country-DE")).toBeInTheDocument();
  });

  it("renders country names", () => {
    renderStep();
    expect(screen.getByText("Poland")).toBeInTheDocument();
    expect(screen.getByText("Germany")).toBeInTheDocument();
  });

  it("renders native country names", () => {
    renderStep();
    expect(screen.getByText("Polska")).toBeInTheDocument();
    expect(screen.getByText("Deutschland")).toBeInTheDocument();
  });

  it("renders country flags", () => {
    renderStep();
    expect(screen.getByText("🇵🇱")).toBeInTheDocument();
    expect(screen.getByText("🇩🇪")).toBeInTheDocument();
  });

  it("disables Next button when no country selected", () => {
    renderStep();
    expect(screen.getByText("Next")).toBeDisabled();
  });

  it("enables Next button when country is selected", () => {
    renderStep({ country: "PL", language: "pl" });
    expect(screen.getByText("Next")).toBeEnabled();
  });

  it("calls onChange with country and first available language when selecting PL", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("country-PL"));
    // getLanguagesForCountry returns [en, pl] — first is en
    expect(onChange).toHaveBeenCalledWith({ country: "PL", language: "en" });
  });

  it("calls onChange with country and first available language when selecting DE", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("country-DE"));
    // getLanguagesForCountry returns [en, de] — first is en
    expect(onChange).toHaveBeenCalledWith({ country: "DE", language: "en" });
  });

  it("shows checkmark for selected country", () => {
    renderStep({ country: "PL", language: "pl" });
    expect(screen.getByText("✓")).toBeInTheDocument();
  });

  it("shows language selector after country selection", () => {
    renderStep({ country: "PL", language: "pl" });
    expect(screen.getByText("Polski")).toBeInTheDocument();
    expect(screen.getByText("English")).toBeInTheDocument();
  });

  it("calls onChange with language when clicking a language option", async () => {
    const user = userEvent.setup();
    renderStep({ country: "PL", language: "pl" });
    await user.click(screen.getByText("English"));
    expect(onChange).toHaveBeenCalledWith({ language: "en" });
  });

  it("calls onBack when Back is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByText("Back"));
    expect(onBack).toHaveBeenCalledOnce();
  });

  it("calls onNext when Next is clicked", async () => {
    const user = userEvent.setup();
    renderStep({ country: "PL", language: "pl" });
    await user.click(screen.getByText("Next"));
    expect(onNext).toHaveBeenCalledOnce();
  });
});
