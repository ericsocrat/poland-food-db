import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import OnboardingRegionPage from "./page";

vi.mock("./RegionForm", () => ({
  RegionForm: () => <div data-testid="region-form" />,
}));

describe("OnboardingRegionPage", () => {
  it("renders the RegionForm", () => {
    render(<OnboardingRegionPage />);
    expect(screen.getByTestId("region-form")).toBeInTheDocument();
  });

  it("exports dynamic = force-dynamic", async () => {
    const mod = await import("./page");
    expect(mod.dynamic).toBe("force-dynamic");
  });
});
