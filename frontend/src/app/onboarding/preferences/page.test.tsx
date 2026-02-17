import { describe, expect, it, vi } from "vitest";
import { redirect } from "next/navigation";
import OnboardingPreferencesPage from "./page";

vi.mock("next/navigation", () => ({
  redirect: vi.fn(),
}));

describe("OnboardingPreferencesPage", () => {
  it("redirects to /onboarding", () => {
    try {
      OnboardingPreferencesPage();
    } catch {
      // redirect() throws in Next.js
    }
    expect(redirect).toHaveBeenCalledWith("/onboarding");
  });
});
