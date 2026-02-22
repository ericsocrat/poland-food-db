import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SettingsPage from "./page";
import { useLanguageStore } from "@/stores/language-store";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
const mockRefresh = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush, refresh: mockRefresh }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: { signOut: vi.fn().mockResolvedValue({}) },
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
  mockGetPrefs.mockResolvedValue({ ok: true, data: mockPrefsData });
});

describe("SettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /Settings/i })).toBeInTheDocument();
    });
  });

  it("renders country buttons", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });
    expect(screen.getByText("Polska")).toBeInTheDocument();
  });

  it("renders diet preference options", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("No restriction")).toBeInTheDocument();
    });
    expect(screen.getByText("Vegetarian")).toBeInTheDocument();
    // "Vegan" appears in both diet options and allergen presets — check at least one exists
    expect(screen.getAllByText("Vegan").length).toBeGreaterThanOrEqual(1);
  });

  it("renders allergen tags", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Gluten")).toBeInTheDocument();
    });
    expect(screen.getByText("Eggs")).toBeInTheDocument();
  });

  it("renders HealthProfileSection", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-profile-section")).toBeInTheDocument();
    });
  });

  it("renders HealthProfileSection exactly once", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-profile-section")).toBeInTheDocument();
    });

    const sections = screen.getAllByTestId("health-profile-section");
    expect(sections).toHaveLength(1);
  });

  it("renders sign out button", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Sign out" }),
      ).toBeInTheDocument();
    });
  });

  it("shows user ID snippet", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/User ID: abc12345/)).toBeInTheDocument();
    });
  });

  it("does not show save button when no changes made", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /Settings/i })).toBeInTheDocument();
    });
    expect(
      screen.queryByRole("button", { name: "Save changes" }),
    ).not.toBeInTheDocument();
  });

  it("shows save button after changing country", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));

    expect(
      screen.getByRole("button", { name: "Save changes" }),
    ).toBeInTheDocument();
  });

  it("shows save button after changing diet", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
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

    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/strict.*exclude/i)).toBeInTheDocument();
    });
  });

  it("shows allergen strictness toggles when allergens selected", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, avoid_allergens: ["en:gluten"] },
    });

    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Strict allergen matching")).toBeInTheDocument();
    });
    expect(screen.getByText(/may contain/i)).toBeInTheDocument();
  });

  it("calls setUserPreferences on save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<SettingsPage />, { wrapper: createWrapper() });
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

  it("shows success toast after saving", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<SettingsPage />, { wrapper: createWrapper() });
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
    render(<SettingsPage />, { wrapper: createWrapper() });
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

  it("redirects to login on sign out", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Sign out" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Sign out" }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/auth/login");
      expect(mockRefresh).toHaveBeenCalled();
    });
  });

  it("shows only 2 language options for selected country (native + English)", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /Settings/i })).toBeInTheDocument();
    });

    // Poland = Polski + English (2 options, NOT Deutsch)
    expect(screen.getByText("Polski")).toBeInTheDocument();
    expect(screen.getByText("English")).toBeInTheDocument();
    expect(screen.queryByText("Deutsch")).not.toBeInTheDocument();
  });

  it("auto-switches language when country changes", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    // Switch to Germany
    await user.click(screen.getByText("Deutschland"));

    // Language options should now be Deutsch + English (not Polski)
    await waitFor(() => {
      expect(screen.getByText("Deutsch")).toBeInTheDocument();
    });
    expect(screen.getByText("English")).toBeInTheDocument();
    expect(screen.queryByText("Polski")).not.toBeInTheDocument();
  });

  // ─── Allergen presets ───────────────────────────────────────────────────

  it("renders allergen preset buttons", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("allergen-presets")).toBeInTheDocument();
    });

    expect(screen.getByText("Gluten-free")).toBeInTheDocument();
    expect(screen.getByText("Dairy-free")).toBeInTheDocument();
    expect(screen.getByText("Nut-free")).toBeInTheDocument();
    // "Vegan" appears in both diet options and presets — use within() for precision
    const presetContainer = screen.getByTestId("allergen-presets");
    expect(presetContainer).toHaveTextContent("Vegan");
  });

  it("clicking Gluten-free preset selects the gluten allergen", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
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
    render(<SettingsPage />, { wrapper: createWrapper() });
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
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Dairy-free")).toBeInTheDocument();
    });

    // Select then deselect
    await user.click(screen.getByText("Dairy-free"));
    await user.click(screen.getByText("Dairy-free"));

    // Save button should still be visible since dirty was set
    // But no strictness toggles since allergens are now empty again
    expect(
      screen.queryByText("Strict allergen matching"),
    ).not.toBeInTheDocument();
  });

  it("settings form has max-w-2xl container for desktop", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /Settings/i })).toBeInTheDocument();
    });

    const container = screen.getByRole("heading", { name: /Settings/i }).parentElement!;
    expect(container.className).toContain("max-w-2xl");
  });
});
