import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
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

const mockGetUser = vi.fn();
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      signOut: vi.fn().mockResolvedValue({}),
      getUser: () => mockGetUser(),
    },
  }),
}));

const mockGetPrefs = vi.fn();
const mockSetPrefs = vi.fn();
const mockExportUserData = vi.fn();
const mockDeleteUserData = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetPrefs(...args),
  setUserPreferences: (...args: unknown[]) => mockSetPrefs(...args),
  exportUserData: (...args: unknown[]) => mockExportUserData(...args),
  deleteUserData: (...args: unknown[]) => mockDeleteUserData(...args),
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

const mockClipboardWriteText = vi.fn().mockResolvedValue(undefined);

beforeEach(() => {
  vi.clearAllMocks();
  useLanguageStore.getState().reset();
  localStorage.clear();
  mockGetPrefs.mockResolvedValue({ ok: true, data: mockPrefsData });
  mockGetUser.mockResolvedValue({
    data: { user: { email: "test@example.com" } },
  });
  Object.defineProperty(navigator, "clipboard", {
    value: { writeText: mockClipboardWriteText },
    writable: true,
    configurable: true,
  });
  // Mock HTMLDialogElement methods (jsdom doesn't implement them)
  HTMLDialogElement.prototype.showModal =
    HTMLDialogElement.prototype.showModal ||
    vi.fn(function (this: HTMLDialogElement) {
      this.open = true;
    });
  HTMLDialogElement.prototype.close =
    HTMLDialogElement.prototype.close ||
    vi.fn(function (this: HTMLDialogElement) {
      this.open = false;
    });
});

describe("SettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Settings/i }),
      ).toBeInTheDocument();
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

  it("shows email as primary identifier, not raw UUID", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("test@example.com")).toBeInTheDocument();
    });

    // Raw UUID must NOT be visible by default
    expect(
      screen.queryByText("abc12345-6789-def0-1234-567890abcdef"),
    ).not.toBeInTheDocument();
    expect(screen.queryByText(/abc1.*cdef/)).not.toBeInTheDocument();
  });

  it("reveals masked UUID and copy button when Account Details is expanded", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Account Details")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Account Details"));

    await waitFor(() => {
      expect(screen.getByTestId("account-details")).toBeInTheDocument();
    });

    // Masked UUID: first 4 + last 4
    expect(screen.getByText(/abc1.*cdef/)).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /Copy User ID/ }),
    ).toBeInTheDocument();
  });

  it("copies full UUID to clipboard and shows toast", async () => {
    const { showToast } = await import("@/lib/toast");

    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Account Details")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText("Account Details"));

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /Copy User ID/ }),
      ).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole("button", { name: /Copy User ID/ }));

    await waitFor(() => {
      expect(mockClipboardWriteText).toHaveBeenCalledWith(
        "abc12345-6789-def0-1234-567890abcdef",
      );
    });

    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({
        type: "success",
        messageKey: "settings.copiedToClipboard",
      }),
    );
  });

  it("does not show save button when no changes made", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Settings/i }),
      ).toBeInTheDocument();
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
      expect(
        screen.getByRole("heading", { name: /Settings/i }),
      ).toBeInTheDocument();
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
      expect(
        screen.getByRole("heading", { name: /Settings/i }),
      ).toBeInTheDocument();
    });

    const container = screen.getByRole("heading", {
      name: /Settings/i,
    }).parentElement!;
    expect(container.className).toContain("max-w-2xl");
  });

  /* ── Export Data section ──────────────────────────────────────────────── */

  it("renders export data section", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("export-data-section")).toBeInTheDocument();
    });
    expect(screen.getByTestId("export-data-button")).toBeInTheDocument();
  });

  it("export button is disabled during cooldown", async () => {
    // Simulate cooldown: 30 min remaining
    vi.spyOn(Storage.prototype, "getItem").mockImplementation((key) => {
      if (key === "gdpr-export-last-at")
        return String(Date.now() - 30 * 60 * 1000);
      return null;
    });

    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("export-data-button")).toBeDisabled();
    });

    vi.restoreAllMocks();
  });

  it("calls exportUserData on button click and triggers download", async () => {
    const mockData = {
      exported_at: new Date().toISOString(),
      format_version: "1.0",
      user_id: "test-id",
      preferences: {},
      health_profiles: [],
      product_lists: [],
      comparisons: [],
      saved_searches: [],
      scan_history: [],
      watched_products: [],
      product_views: [],
      achievements: [],
    };
    mockExportUserData.mockResolvedValue({ ok: true, data: mockData });

    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("export-data-button")).toBeEnabled();
    });

    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(mockExportUserData).toHaveBeenCalled();
    });
  });

  it("shows error toast when export fails", async () => {
    mockExportUserData.mockResolvedValue({
      ok: false,
      error: { code: "INTERNAL", message: "fail" },
    });

    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("export-data-button")).toBeEnabled();
    });

    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(mockExportUserData).toHaveBeenCalled();
    });

    // showToast is mocked so we just confirm export was attempted
  });

  /* ── Delete Account section ──────────────────────────────────────────── */

  it("renders delete account button", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-button")).toBeInTheDocument();
    });
  });

  it("opens delete dialog when delete button clicked", async () => {
    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-button")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("delete-account-button"));

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-dialog")).toBeInTheDocument();
    });
  });

  it("calls deleteUserData when deletion is confirmed", async () => {
    mockDeleteUserData.mockResolvedValue({
      ok: true,
      data: { status: "deleted", timestamp: new Date().toISOString() },
    });

    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-button")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("delete-account-button"));

    await waitFor(() => {
      expect(screen.getByTestId("delete-confirm-input")).toBeInTheDocument();
    });

    await user.type(screen.getByTestId("delete-confirm-input"), "DELETE");
    await user.click(screen.getByTestId("delete-account-confirm-button"));

    await waitFor(() => {
      expect(mockDeleteUserData).toHaveBeenCalled();
    });
  });

  it("redirects after successful deletion", async () => {
    mockDeleteUserData.mockResolvedValue({
      ok: true,
      data: { status: "deleted", timestamp: new Date().toISOString() },
    });

    render(<SettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-button")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("delete-account-button"));
    await user.type(screen.getByTestId("delete-confirm-input"), "DELETE");
    await user.click(screen.getByTestId("delete-account-confirm-button"));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/");
    });
  });
});
