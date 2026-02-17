import { describe, expect, it, vi } from "vitest";
import { redirect } from "next/navigation";
import OnboardingRegionPage from "./page";

vi.mock("next/navigation", () => ({
  redirect: vi.fn(),
}));

describe("OnboardingRegionPage", () => {
  it("redirects to /onboarding", () => {
    try {
      OnboardingRegionPage();
    } catch {
      // redirect() throws in Next.js
    }
    expect(redirect).toHaveBeenCalledWith("/onboarding");
  });
});
