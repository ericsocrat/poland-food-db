import {
  INITIAL_ONBOARDING_DATA,
  type OnboardingData,
} from "@/app/onboarding/types";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { WelcomeRegionStep } from "./WelcomeRegionStep";

describe("WelcomeRegionStep", () => {
  const onChange = vi.fn();
  const onNext = vi.fn();
  const onBack = vi.fn();
  const onSkipAll = vi.fn();

  function renderStep(data: Partial<OnboardingData> = {}) {
    return render(
      <WelcomeRegionStep
        data={{ ...INITIAL_ONBOARDING_DATA, ...data }}
        onChange={onChange}
        onNext={onNext}
        onBack={onBack}
        onSkipAll={onSkipAll}
      />,
    );
  }

  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ─── Welcome section ──────────────────────────────────────────────────────

  it("renders the apple emoji", () => {
    renderStep();
    expect(screen.getByText("🍎")).toBeInTheDocument();
  });

  it("renders the welcome title", () => {
    renderStep();
    expect(
      screen.getByText("Let's personalize your experience"),
    ).toBeInTheDocument();
  });

  it("renders the welcome subtitle", () => {
    renderStep();
    expect(
      screen.getByText(/We'll ask a few quick questions/),
    ).toBeInTheDocument();
  });

  // ─── Region section ───────────────────────────────────────────────────────

  it("renders the region title", () => {
    renderStep();
    expect(screen.getByText("Where are you located?")).toBeInTheDocument();
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
    expect(screen.getByTestId("onboarding-get-started")).toBeDisabled();
  });

  it("enables Next button when country is selected", () => {
    renderStep({ country: "PL", language: "en" });
    expect(screen.getByTestId("onboarding-get-started")).toBeEnabled();
  });

  it("calls onChange with country and default language when selecting PL", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("country-PL"));
    expect(onChange).toHaveBeenCalledWith({ country: "PL", language: "en" });
  });

  it("calls onChange with country and default language when selecting DE", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("country-DE"));
    expect(onChange).toHaveBeenCalledWith({ country: "DE", language: "en" });
  });

  it("shows checkmark for selected country", () => {
    renderStep({ country: "PL", language: "en" });
    const checkSpan = document.querySelector(".text-brand svg");
    expect(checkSpan).toBeTruthy();
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

  // ─── Navigation ───────────────────────────────────────────────────────────

  it("calls onNext when Next is clicked", async () => {
    const user = userEvent.setup();
    renderStep({ country: "PL", language: "en" });
    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(onNext).toHaveBeenCalledOnce();
  });

  it("calls onSkipAll when Skip All is clicked", async () => {
    const user = userEvent.setup();
    renderStep();
    await user.click(screen.getByTestId("onboarding-skip-all"));
    expect(onSkipAll).toHaveBeenCalledOnce();
  });
});
