import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { WelcomeStep } from "./WelcomeStep";

describe("WelcomeStep", () => {
  const onNext = vi.fn();
  const onSkipAll = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders the welcome title", () => {
    render(<WelcomeStep onNext={onNext} onSkipAll={onSkipAll} />);
    expect(
      screen.getByText("Let's personalize your experience"),
    ).toBeInTheDocument();
  });

  it("renders the apple emoji", () => {
    render(<WelcomeStep onNext={onNext} onSkipAll={onSkipAll} />);
    expect(screen.getByText("🍎")).toBeInTheDocument();
  });

  it('calls onNext when "Get Started" is clicked', async () => {
    const user = userEvent.setup();
    render(<WelcomeStep onNext={onNext} onSkipAll={onSkipAll} />);
    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(onNext).toHaveBeenCalledOnce();
  });

  it('calls onSkipAll when "Skip" is clicked', async () => {
    const user = userEvent.setup();
    render(<WelcomeStep onNext={onNext} onSkipAll={onSkipAll} />);
    await user.click(screen.getByTestId("onboarding-skip-all"));
    expect(onSkipAll).toHaveBeenCalledOnce();
  });
});
