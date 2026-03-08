import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { OnboardingWizard } from "./OnboardingWizard";
import { ONBOARDING_STORAGE_KEY } from "./types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
const mockRefresh = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush, refresh: mockRefresh }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockCompleteOnboarding = vi.fn();
const mockSkipOnboarding = vi.fn();
vi.mock("@/lib/api", () => ({
  completeOnboarding: (...args: unknown[]) => mockCompleteOnboarding(...args),
  skipOnboarding: (...args: unknown[]) => mockSkipOnboarding(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

beforeEach(() => {
  vi.clearAllMocks();
  localStorage.clear();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("OnboardingWizard", () => {
  // ── Rendering ─────────────────────────────────────────────────────────

  it("renders the wizard container", () => {
    render(<OnboardingWizard />);
    expect(screen.getByTestId("onboarding-wizard")).toBeInTheDocument();
  });

  it("starts on the Welcome+Region step", () => {
    render(<OnboardingWizard />);
    expect(screen.getByTestId("onboarding-get-started")).toBeInTheDocument();
    expect(screen.getByTestId("country-PL")).toBeInTheDocument();
  });

  it("shows progress bar on all steps", () => {
    render(<OnboardingWizard />);
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
  });

  // ── Step Navigation (3-step flow) ─────────────────────────────────────

  it("navigates from Welcome+Region to Diet+Allergens step", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));

    // Diet + Allergens step
    expect(screen.getByTestId("diet-none")).toBeInTheDocument();
    expect(screen.getByTestId("allergen-gluten")).toBeInTheDocument();
  });

  it("navigates from Diet+Allergens to Goals+Categories step", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Step 0 → 1
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));

    // Step 1 → 2
    await user.click(screen.getByText("Next"));

    expect(screen.getByTestId("goal-diabetes")).toBeInTheDocument();
    expect(screen.getByTestId("category-bread")).toBeInTheDocument();
  });

  it("navigates back from Diet+Allergens to Welcome+Region", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(screen.getByTestId("diet-none")).toBeInTheDocument();

    await user.click(screen.getByText("Back"));
    expect(screen.getByTestId("onboarding-get-started")).toBeInTheDocument();
  });

  // ── Skip All ──────────────────────────────────────────────────────────

  it("calls skipOnboarding from Welcome step skip button", async () => {
    mockSkipOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-skip-all"));

    await waitFor(() => {
      expect(mockSkipOnboarding).toHaveBeenCalled();
    });
    expect(mockPush).toHaveBeenCalledWith("/app/categories");
  });

  it("shows error toast when skip fails", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSkipOnboarding.mockResolvedValue({
      ok: false,
      error: { message: "Skip failed" },
    });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-skip-all"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("skip all link is visible on inner steps", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Navigate to step 1 (Diet+Allergens)
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));

    expect(screen.getByTestId("onboarding-skip-all")).toBeInTheDocument();
  });

  // ── Complete ──────────────────────────────────────────────────────────

  it("calls completeOnboarding with accumulated data on Finish", async () => {
    mockCompleteOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Step 0: Select country + click next
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));

    // Step 1: Select diet + allergen
    await user.click(screen.getByTestId("diet-vegetarian"));
    await user.click(screen.getByTestId("allergen-gluten"));
    await user.click(screen.getByText("Next"));

    // Step 2: Select goal + category, click Finish
    await user.click(screen.getByTestId("goal-diabetes"));
    await user.click(screen.getByTestId("category-chips"));
    await user.click(screen.getByTestId("onboarding-complete"));

    await waitFor(() => {
      expect(mockCompleteOnboarding).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          country: "PL",
          diet: "vegetarian",
          allergens: ["gluten"],
          health_goals: ["diabetes"],
          favorite_categories: ["chips"],
        }),
      );
    });
    expect(mockPush).toHaveBeenCalledWith("/app/categories");
  });

  it("shows error on completion failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockCompleteOnboarding.mockResolvedValue({
      ok: false,
      error: { message: "Save failed" },
    });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Navigate through all steps quickly
    await user.click(screen.getByTestId("country-DE"));
    await user.click(screen.getByTestId("onboarding-get-started"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("onboarding-complete"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  // ── localStorage Persistence ──────────────────────────────────────────

  it("persists step and data to localStorage", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));

    await waitFor(() => {
      const stored = JSON.parse(
        localStorage.getItem(ONBOARDING_STORAGE_KEY) || "{}",
      );
      expect(stored.step).toBe(1);
      expect(stored.data.country).toBe("PL");
    });
  });

  it("restores persisted state on mount", () => {
    localStorage.setItem(
      ONBOARDING_STORAGE_KEY,
      JSON.stringify({
        step: 1,
        data: {
          country: "DE",
          language: "",
          diet: "vegan",
          allergens: [],
          strictAllergen: false,
          strictDiet: false,
          treatMayContain: false,
          healthGoals: [],
          favoriteCategories: [],
        },
      }),
    );

    render(<OnboardingWizard />);

    // Should be on step 1 (Diet+Allergens), not step 0
    expect(screen.getByTestId("diet-none")).toBeInTheDocument();
    expect(screen.queryByTestId("onboarding-get-started")).not.toBeInTheDocument();
  });

  it("clears localStorage after successful completion", async () => {
    mockCompleteOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByTestId("onboarding-get-started"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("onboarding-complete"));

    await waitFor(() => {
      expect(localStorage.getItem(ONBOARDING_STORAGE_KEY)).toBeNull();
    });
  });

  it("clears localStorage after skip", async () => {
    mockSkipOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-skip-all"));

    await waitFor(() => {
      expect(localStorage.getItem(ONBOARDING_STORAGE_KEY)).toBeNull();
    });
  });
});
