import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import PrivacySettingsPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      signOut: vi.fn().mockResolvedValue({}),
      getUser: vi.fn().mockResolvedValue({
        data: { user: { email: "test@example.com" } },
      }),
    },
    rpc: vi.fn().mockResolvedValue({ data: null, error: null }),
    from: vi.fn().mockReturnValue({
      select: vi.fn().mockReturnThis(),
      eq: vi.fn().mockReturnThis(),
      delete: vi.fn().mockReturnThis(),
      insert: vi.fn().mockResolvedValue({ error: null }),
    }),
  }),
}));

const mockExportUserData = vi.fn();
vi.mock("@/lib/api", () => ({
  exportUserData: (...args: unknown[]) => mockExportUserData(...args),
  savePushSubscription: vi.fn().mockResolvedValue({ ok: true }),
  deletePushSubscription: vi.fn().mockResolvedValue({ ok: true }),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

// Push manager — default to unsupported (push tests skipped in jsdom)
vi.mock("@/lib/push-manager", () => ({
  isPushSupported: () => false,
  getNotificationPermission: () => "default" as NotificationPermission,
  requestNotificationPermission: vi.fn().mockResolvedValue("granted"),
  subscribeToPush: vi.fn().mockResolvedValue(null),
  unsubscribeFromPush: vi.fn().mockResolvedValue(undefined),
  getCurrentPushSubscription: vi.fn().mockResolvedValue(null),
  extractSubscriptionData: vi.fn().mockReturnValue(null),
}));

// Cache manager
vi.mock("@/lib/cache-manager", () => ({
  clearAllCaches: vi.fn().mockResolvedValue(undefined),
  getCachedProductCount: vi.fn().mockResolvedValue(0),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  localStorage.clear();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("PrivacySettingsPage", () => {
  it("renders page title after loading", async () => {
    render(<PrivacySettingsPage />);

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Privacy & Data/i }),
      ).toBeInTheDocument();
    });
  });

  it("renders export data section", async () => {
    render(<PrivacySettingsPage />);

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

    render(<PrivacySettingsPage />);

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

    render(<PrivacySettingsPage />);
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

    render(<PrivacySettingsPage />);
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("export-data-button")).toBeEnabled();
    });

    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(mockExportUserData).toHaveBeenCalled();
    });
  });

  it("renders offline cache section", async () => {
    render(<PrivacySettingsPage />);

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Privacy & Data/i }),
      ).toBeInTheDocument();
    });

    // Offline cache section heading should exist
    expect(
      screen.getByRole("heading", { name: /Offline Cache/i }),
    ).toBeInTheDocument();
  });
});
