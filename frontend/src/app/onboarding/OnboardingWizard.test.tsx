import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { OnboardingWizard } from "./OnboardingWizard";

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
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("OnboardingWizard", () => {
  // ── Rendering ─────────────────────────────────────────────────────────

  it("renders the wizard container", () => {
    render(<OnboardingWizard />);
    expect(screen.getByTestId("onboarding-wizard")).toBeInTheDocument();
  });

  it("starts on the Welcome step", () => {
    render(<OnboardingWizard />);
    expect(screen.getByTestId("onboarding-get-started")).toBeInTheDocument();
  });

  it("does not show progress bar on Welcome step", () => {
    render(<OnboardingWizard />);
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
  });

  // ── Step Navigation ───────────────────────────────────────────────────

  it("navigates from Welcome to Region step", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-get-started"));

    // Region step should be visible
    expect(screen.getByTestId("country-PL")).toBeInTheDocument();
    expect(screen.getByTestId("country-DE")).toBeInTheDocument();
  });

  it("shows progress bar on inner steps", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
  });

  it("navigates through all 7 steps to Done", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Step 0 → 1: Welcome → Region
    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(screen.getByTestId("country-PL")).toBeInTheDocument();

    // Select Poland and continue
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByText("Next"));

    // Step 2: Diet
    expect(screen.getByTestId("diet-none")).toBeInTheDocument();
    await user.click(screen.getByText("Next"));

    // Step 3: Allergens
    expect(screen.getByTestId("allergen-gluten")).toBeInTheDocument();
    await user.click(screen.getByText("Next"));

    // Step 4: Health Goals
    expect(screen.getByTestId("goal-diabetes")).toBeInTheDocument();
    await user.click(screen.getByText("Next"));

    // Step 5: Categories
    expect(screen.getByTestId("category-chips")).toBeInTheDocument();
    await user.click(screen.getByText("Next"));

    // Step 6: Done
    expect(screen.getByTestId("onboarding-complete")).toBeInTheDocument();
  });

  it("navigates back from Region to Welcome", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-get-started"));
    expect(screen.getByTestId("country-PL")).toBeInTheDocument();

    await user.click(screen.getByText("Back"));
    expect(screen.getByTestId("onboarding-get-started")).toBeInTheDocument();
  });

  // ── Skip All ──────────────────────────────────────────────────────────

  it("calls skipOnboarding when clicking Skip on Welcome", async () => {
    mockSkipOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    await user.click(screen.getByTestId("onboarding-skip-all"));

    await waitFor(() => {
      expect(mockSkipOnboarding).toHaveBeenCalled();
    });
    expect(mockPush).toHaveBeenCalledWith("/app/search");
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

    // Navigate to Region step
    await user.click(screen.getByTestId("onboarding-get-started"));

    // The skip-all link in the wizard footer (not the Welcome button)
    expect(screen.getByTestId("onboarding-skip-all")).toBeInTheDocument();
  });

  // ── Complete ──────────────────────────────────────────────────────────

  it("calls completeOnboarding with accumulated data on Done step", async () => {
    mockCompleteOnboarding.mockResolvedValue({ ok: true, data: {} });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Navigate through all steps
    await user.click(screen.getByTestId("onboarding-get-started"));
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("diet-vegetarian"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("allergen-gluten"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("goal-diabetes"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByTestId("category-chips"));
    await user.click(screen.getByText("Next"));

    // Click complete on Done step
    await user.click(screen.getByTestId("onboarding-complete"));

    await waitFor(() => {
      expect(mockCompleteOnboarding).toHaveBeenCalledWith(
        expect.anything(), // supabase client
        expect.objectContaining({
          country: "PL",
          diet: "vegetarian",
          allergens: ["gluten"],
          health_goals: ["diabetes"],
          favorite_categories: ["chips"],
        }),
      );
    });
    expect(mockPush).toHaveBeenCalledWith("/app/search");
  });

  it("shows error on completion failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockCompleteOnboarding.mockResolvedValue({
      ok: false,
      error: { message: "Save failed" },
    });
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Navigate to Done step quickly
    await user.click(screen.getByTestId("onboarding-get-started"));
    await user.click(screen.getByTestId("country-DE"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByText("Next"));
    await user.click(screen.getByText("Next"));

    await user.click(screen.getByTestId("onboarding-complete"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  // ── Data Accumulation ─────────────────────────────────────────────────

  it("accumulates selections across steps in Done summary", async () => {
    const user = userEvent.setup();
    render(<OnboardingWizard />);

    // Welcome → Region
    await user.click(screen.getByTestId("onboarding-get-started"));
    await user.click(screen.getByTestId("country-PL"));
    await user.click(screen.getByText("Next"));

    // Diet: select vegan
    await user.click(screen.getByTestId("diet-vegan"));
    await user.click(screen.getByText("Next"));

    // Allergens: select gluten + milk
    await user.click(screen.getByTestId("allergen-gluten"));
    await user.click(screen.getByTestId("allergen-milk"));
    await user.click(screen.getByText("Next"));

    // Health goals: skip (click next)
    await user.click(screen.getByText("Next"));

    // Categories: skip (click next)
    await user.click(screen.getByText("Next"));

    // Done step should show summary
    expect(screen.getByText("Poland")).toBeInTheDocument();
    expect(screen.getByText("Vegan")).toBeInTheDocument();
    expect(screen.getByText(/Gluten.*Milk|Milk.*Gluten/)).toBeInTheDocument();
  });
});
