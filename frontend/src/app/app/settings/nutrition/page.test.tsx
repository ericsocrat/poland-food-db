import { useLanguageStore } from "@/stores/language-store";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import NutritionSettingsPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      signOut: vi.fn().mockResolvedValue({}),
      getUser: vi.fn().mockResolvedValue({
        data: { user: { email: "test@example.com" } },
      }),
    },
  }),
}));

const mockGetPrefs = vi.fn();
const mockSetPrefs = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetPrefs(...args),
  setUserPreferences: (...args: unknown[]) => mockSetPrefs(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

// Stub HealthProfileSection since it's tested separately
vi.mock("@/components/settings/HealthProfileSection", () => ({
  HealthProfileSection: () => (
    <div data-testid="health-profile-section">Health Profile</div>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

const mockPrefsData = {
  user_id: "abc12345-6789-def0-1234-567890abcdef",
  country: "PL",
  preferred_language: "en",
  diet_preference: "none",
  avoid_allergens: [] as string[],
  strict_diet: false,
  strict_allergen: false,
  treat_may_contain_as_unsafe: false,
};

beforeEach(() => {
  vi.clearAllMocks();
  useLanguageStore.getState().reset();
  localStorage.clear();
  mockGetPrefs.mockResolvedValue({ ok: true, data: mockPrefsData });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("NutritionSettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Nutrition & Diet/i }),
      ).toBeInTheDocument();
    });
  });

  it("renders diet preference options", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("No restriction")).toBeInTheDocument();
    });
    expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    // "Vegan" appears in both diet options and allergen presets — check at least one exists
    expect(screen.getAllByText("Vegan").length).toBeGreaterThanOrEqual(1);
  });

  it("renders allergen tags", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Gluten")).toBeInTheDocument();
    });
    expect(screen.getByText("Eggs")).toBeInTheDocument();
  });

  it("renders HealthProfileSection", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-profile-section")).toBeInTheDocument();
    });
  });

  it("renders HealthProfileSection exactly once", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-profile-section")).toBeInTheDocument();
    });

    const sections = screen.getAllByTestId("health-profile-section");
    expect(sections).toHaveLength(1);
  });

  it("shows save button after changing diet", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Vegetarian"));

    expect(
      screen.getByRole("button", { name: "Save changes" }),
    ).toBeInTheDocument();
  });

  it("shows strict diet toggle when non-none diet selected", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, diet_preference: "vegan" },
    });

    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/strict.*exclude/i)).toBeInTheDocument();
    });
  });

  it("shows allergen strictness toggles when allergens selected", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, avoid_allergens: ["gluten"] },
    });

    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Strict allergen matching")).toBeInTheDocument();
    });
    expect(screen.getByText(/may contain/i)).toBeInTheDocument();
  });

  it("calls setUserPreferences on save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    });

    // Change diet to make dirty
    await user.click(screen.getByText("Vegetarian"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ p_diet_preference: "vegetarian" }),
      );
    });
  });

  it("passes through country/language from prefs when saving", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, country: "DE", preferred_language: "de" },
    });
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Vegetarian"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          p_country: "DE",
          p_preferred_language: "de",
          p_diet_preference: "vegetarian",
        }),
      );
    });
  });

  it("shows success toast after saving", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Vegetarian"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "success",
          messageKey: "settings.preferencesSaved",
        }),
      );
    });
  });

  it("shows error toast on save failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({
      ok: false,
      error: { message: "Save failed" },
    });
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Vegetarian"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error", message: "Save failed" }),
      );
    });
  });

  // ─── Allergen presets ───────────────────────────────────────────────────

  it("renders allergen preset buttons", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("allergen-presets")).toBeInTheDocument();
    });

    expect(screen.getByText("Gluten-free")).toBeInTheDocument();
    expect(screen.getByText("Dairy-free")).toBeInTheDocument();
    expect(screen.getByText("Nut-free")).toBeInTheDocument();
    const presetContainer = screen.getByTestId("allergen-presets");
    expect(presetContainer).toHaveTextContent("Vegan");
  });

  it("clicking Gluten-free preset selects the gluten allergen", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Gluten-free")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Gluten-free"));

    // Gluten tag should now be selected — save button should appear (dirty)
    expect(
      screen.getByRole("button", { name: "Save changes" }),
    ).toBeInTheDocument();
  });

  it("clicking Nut-free preset selects both Tree Nuts and Peanuts", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Nut-free")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Nut-free"));

    // Should show strictness toggles since allergens are now selected
    await waitFor(() => {
      expect(screen.getByText("Strict allergen matching")).toBeInTheDocument();
    });
  });

  it("clicking a preset twice toggles the allergens off", async () => {
    render(<NutritionSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Dairy-free")).toBeInTheDocument();
    });

    // Select then deselect
    await user.click(screen.getByText("Dairy-free"));
    await user.click(screen.getByText("Dairy-free"));

    // No strictness toggles since allergens are now empty again
    expect(
      screen.queryByText("Strict allergen matching"),
    ).not.toBeInTheDocument();
  });
});
