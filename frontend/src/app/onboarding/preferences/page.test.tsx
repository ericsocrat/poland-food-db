import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import OnboardingPreferencesPage from "./page";

vi.mock("./PreferencesForm", () => ({
  PreferencesForm: () => <div data-testid="preferences-form" />,
}));

describe("OnboardingPreferencesPage", () => {
  it("renders the PreferencesForm", () => {
    render(<OnboardingPreferencesPage />);
    expect(screen.getByTestId("preferences-form")).toBeInTheDocument();
  });

  it("exports dynamic = force-dynamic", async () => {
    const mod = await import("./page");
    expect(mod.dynamic).toBe("force-dynamic");
  });
});
