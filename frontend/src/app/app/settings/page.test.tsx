import { useLanguageStore } from "@/stores/language-store";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ProfileSettingsPage from "./page";

// ─── Polyfills ──────────────────────────────────────────────────────────────

HTMLDialogElement.prototype.showModal ??= function (this: HTMLDialogElement) {
  this.setAttribute("open", "");
};
HTMLDialogElement.prototype.close ??= function (this: HTMLDialogElement) {
  this.removeAttribute("open");
};

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockConfirmNav = vi.fn();
const mockCancelNav = vi.fn();
let mockShowDialog = false;

vi.mock("@/hooks/use-unsaved-changes", () => ({
  useUnsavedChanges: () => ({
    showConfirmDialog: mockShowDialog,
    confirmNavigation: mockConfirmNav,
    cancelNavigation: mockCancelNav,
  }),
}));

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
  mockShowDialog = false;
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ProfileSettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Profile & Preferences/i }),
      ).toBeInTheDocument();
    });
  });

  it("renders country buttons", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });
    expect(screen.getByText("Polska")).toBeInTheDocument();
  });

  it("does not show save button when no changes made", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Profile & Preferences/i }),
      ).toBeInTheDocument();
    });
    expect(
      screen.queryByRole("button", { name: "Save changes" }),
    ).not.toBeInTheDocument();
  });

  it("shows save button after changing country", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));

    expect(
      screen.getByRole("button", { name: "Save changes" }),
    ).toBeInTheDocument();
  });

  it("shows only 2 language options for selected country (native + English)", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    // Wait for country state to be populated from prefs (PL) via useEffect,
    // which triggers getLanguagesForCountry("PL") → Polski + English
    await waitFor(() => {
      expect(screen.getByText("Polski")).toBeInTheDocument();
    });
    expect(screen.getByText("English")).toBeInTheDocument();
    expect(screen.queryByText("Deutsch")).not.toBeInTheDocument();
  });

  it("auto-switches language when country changes", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
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

  it("calls setUserPreferences on save with country change", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ p_country: "DE" }),
      );
    });
  });

  it("passes through diet/allergen values from prefs when saving", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: {
        ...mockPrefsData,
        diet_preference: "vegan",
        avoid_allergens: ["gluten"],
      },
    });
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          p_country: "DE",
          p_diet_preference: "vegan",
          p_avoid_allergens: ["gluten"],
        }),
      );
    });
  });

  it("shows success toast after saving", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({ ok: true });
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));
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
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));
    await user.click(screen.getByRole("button", { name: "Save changes" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error", message: "Save failed" }),
      );
    });
  });

  // ─── Unsaved changes integration ────────────────────────────────────────

  it("shows unsaved changes indicator when dirty", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Deutschland")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Deutschland"));

    expect(screen.getByText("Unsaved changes")).toBeInTheDocument();
  });

  it("does not show unsaved indicator when clean", async () => {
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Profile & Preferences/i }),
      ).toBeInTheDocument();
    });

    expect(screen.queryByText("Unsaved changes")).not.toBeInTheDocument();
  });

  it("shows discard confirmation dialog when showConfirmDialog is true", async () => {
    mockShowDialog = true;
    render(<ProfileSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Unsaved changes", { selector: "h3" }),
      ).toBeInTheDocument();
    });
  });
});
