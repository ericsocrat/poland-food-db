import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { PreferencesForm } from "./PreferencesForm";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
const mockRefresh = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush, refresh: mockRefresh }),
}));

const mockSetPrefs = vi.fn();
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  setUserPreferences: (...args: unknown[]) => mockSetPrefs(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

beforeEach(() => {
  vi.clearAllMocks();
});

describe("PreferencesForm", () => {
  it("renders the diet type options", () => {
    render(<PreferencesForm />);
    expect(screen.getByText("No restriction")).toBeInTheDocument();
    expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    expect(screen.getByText("Vegan")).toBeInTheDocument();
  });

  it("renders allergen tags", () => {
    render(<PreferencesForm />);
    expect(screen.getByText("Gluten")).toBeInTheDocument();
    expect(screen.getByText("Milk / Dairy")).toBeInTheDocument();
    expect(screen.getByText("Eggs")).toBeInTheDocument();
    expect(screen.getByText("Peanuts")).toBeInTheDocument();
  });

  it("renders skip and save buttons", () => {
    render(<PreferencesForm />);
    expect(
      screen.getByRole("button", { name: "Skip for now" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Save & Continue" }),
    ).toBeInTheDocument();
  });

  it("renders progress indicator (step 2)", () => {
    render(<PreferencesForm />);
    expect(screen.getByText("Dietary preferences")).toBeInTheDocument();
  });

  it("navigates to search on skip", async () => {
    const user = userEvent.setup();
    render(<PreferencesForm />);

    await user.click(screen.getByRole("button", { name: "Skip for now" }));

    expect(mockPush).toHaveBeenCalledWith("/app/search");
    expect(mockRefresh).toHaveBeenCalled();
  });

  it("does not show strict diet toggle when 'No restriction' is selected", () => {
    render(<PreferencesForm />);
    expect(screen.queryByText(/strict mode/i)).not.toBeInTheDocument();
  });

  it("shows strict diet toggle after selecting a diet", async () => {
    const user = userEvent.setup();
    render(<PreferencesForm />);

    await user.click(screen.getByText("Vegetarian"));

    expect(screen.getByText(/strict mode/i)).toBeInTheDocument();
  });

  it("does not show allergen strictness toggles when no allergens selected", () => {
    render(<PreferencesForm />);
    expect(
      screen.queryByText("Strict allergen matching"),
    ).not.toBeInTheDocument();
    expect(screen.queryByText(/may contain/i)).not.toBeInTheDocument();
  });

  it("shows allergen strictness toggles after selecting an allergen", async () => {
    const user = userEvent.setup();
    render(<PreferencesForm />);

    await user.click(screen.getByText("Gluten"));

    expect(screen.getByText("Strict allergen matching")).toBeInTheDocument();
    expect(screen.getByText(/may contain/i)).toBeInTheDocument();
  });

  it("toggles allergen on and off", async () => {
    const user = userEvent.setup();
    render(<PreferencesForm />);

    // Click to select
    await user.click(screen.getByText("Eggs"));
    expect(screen.getByText("Strict allergen matching")).toBeInTheDocument();

    // Click again to deselect
    await user.click(screen.getByText("Eggs"));
    expect(
      screen.queryByText("Strict allergen matching"),
    ).not.toBeInTheDocument();
  });

  it("calls setUserPreferences with diet and allergens on save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<PreferencesForm />);
    await user.click(screen.getByText("Vegan"));
    await user.click(screen.getByText("Gluten"));
    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(expect.anything(), {
        p_diet_preference: "vegan",
        p_avoid_allergens: ["en:gluten"],
        p_strict_diet: false,
        p_strict_allergen: false,
        p_treat_may_contain_as_unsafe: false,
      });
    });
  });

  it("navigates to search on successful save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<PreferencesForm />);
    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/app/search");
      expect(mockRefresh).toHaveBeenCalled();
    });
  });

  it("shows success toast on save", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<PreferencesForm />);
    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "success",
          messageKey: "onboarding.preferencesSaved",
        }),
      );
    });
  });

  it("shows error toast on API failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({
      ok: false,
      error: { message: "Save failed" },
    });
    const user = userEvent.setup();

    render(<PreferencesForm />);
    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error", message: "Save failed" }),
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("shows saving state", async () => {
    mockSetPrefs.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<PreferencesForm />);
    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(screen.getByText("Saving…")).toBeInTheDocument();
    });
  });

  it("saves strict toggles when enabled", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<PreferencesForm />);
    // Select diet + enable strict diet
    await user.click(screen.getByText("Vegetarian"));
    await user.click(screen.getByLabelText(/strict mode/i));

    // Select allergen + enable strict allergen + may contain
    await user.click(screen.getByText("Milk / Dairy"));
    await user.click(screen.getByLabelText("Strict allergen matching"));
    await user.click(screen.getByLabelText(/may contain/i));

    await user.click(screen.getByRole("button", { name: "Save & Continue" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(expect.anything(), {
        p_diet_preference: "vegetarian",
        p_avoid_allergens: ["en:milk"],
        p_strict_diet: true,
        p_strict_allergen: true,
        p_treat_may_contain_as_unsafe: true,
      });
    });
  });
});
