import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import AccountSettingsPage from "./page";

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
const mockDeleteUserData = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetPrefs(...args),
  deleteUserData: (...args: unknown[]) => mockDeleteUserData(...args),
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

const mockClipboardWriteText = vi.fn().mockResolvedValue(undefined);

beforeEach(() => {
  vi.clearAllMocks();
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

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AccountSettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Account/i, level: 1 }),
      ).toBeInTheDocument();
    });
  });

  it("renders sign out button", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Sign out" }),
      ).toBeInTheDocument();
    });
  });

  it("shows email as primary identifier, not raw UUID", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });

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
    render(<AccountSettingsPage />, { wrapper: createWrapper() });
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

    render(<AccountSettingsPage />, { wrapper: createWrapper() });

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

  it("redirects to login on sign out", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });
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

  /* ── Delete Account ────────────────────────────────────────────────────── */

  it("renders delete account button", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("delete-account-button")).toBeInTheDocument();
    });
  });

  it("opens delete dialog when delete button clicked", async () => {
    render(<AccountSettingsPage />, { wrapper: createWrapper() });
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

    render(<AccountSettingsPage />, { wrapper: createWrapper() });
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

    render(<AccountSettingsPage />, { wrapper: createWrapper() });
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
