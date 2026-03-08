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
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
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

  // ─── Clear Cache ────────────────────────────────────────────────────────

  it("clears cache and shows success toast", async () => {
    const { clearAllCaches, getCachedProductCount } = await import(
      "@/lib/cache-manager"
    );
    const { showToast } = await import("@/lib/toast");
    vi.mocked(getCachedProductCount).mockResolvedValue(5);

    render(<PrivacySettingsPage />);
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText(/5/)).toBeInTheDocument();
    });

    const clearButton = screen.getByRole("button", { name: /Clear offline cache/i });
    expect(clearButton).toBeEnabled();

    await user.click(clearButton);

    await waitFor(() => {
      expect(clearAllCaches).toHaveBeenCalled();
    });
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ type: "success" }),
    );
  });

  it("shows error toast when clear cache fails", async () => {
    const { clearAllCaches, getCachedProductCount } = await import(
      "@/lib/cache-manager"
    );
    const { showToast } = await import("@/lib/toast");
    vi.mocked(getCachedProductCount).mockResolvedValue(3);
    vi.mocked(clearAllCaches).mockRejectedValue(new Error("fail"));

    render(<PrivacySettingsPage />);
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText(/3/)).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: /Clear offline cache/i }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
  });

  it("disables clear cache button when count is 0", async () => {
    const { getCachedProductCount } = await import("@/lib/cache-manager");
    vi.mocked(getCachedProductCount).mockResolvedValue(0);

    render(<PrivacySettingsPage />);

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Offline Cache/i }),
      ).toBeInTheDocument();
    });

    expect(screen.getByRole("button", { name: /Clear offline cache/i })).toBeDisabled();
  });
});
