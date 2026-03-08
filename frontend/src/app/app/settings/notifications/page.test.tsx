import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import NotificationSettingsPage from "./page";

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

const mockGetPrefs = vi.fn();
const mockSetPrefs = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetPrefs(...args),
  setUserPreferences: (...args: unknown[]) => mockSetPrefs(...args),
  savePushSubscription: vi.fn().mockResolvedValue({ ok: true }),
  deletePushSubscription: vi.fn().mockResolvedValue({ ok: true }),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

// Push manager — default to unsupported (push tests skipped in jsdom)
vi.mock("@/lib/push-manager", () => ({
  isPushSupported: vi.fn().mockReturnValue(false),
  getNotificationPermission: vi.fn().mockReturnValue("default" as NotificationPermission),
  requestNotificationPermission: vi.fn().mockResolvedValue("granted"),
  subscribeToPush: vi.fn().mockResolvedValue(null),
  unsubscribeFromPush: vi.fn().mockResolvedValue(undefined),
  getCurrentPushSubscription: vi.fn().mockResolvedValue(null),
  extractSubscriptionData: vi.fn().mockReturnValue(null),
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
  notification_score_changes: true,
  notification_frequency: "immediate",
};

beforeEach(() => {
  vi.clearAllMocks();
  localStorage.clear();
  mockGetPrefs.mockResolvedValue({ ok: true, data: mockPrefsData });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("NotificationSettingsPage", () => {
  // ─── Rendering ────────────────────────────────────────────────────────────

  it("renders page title after loading", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Notifications/i }),
      ).toBeInTheDocument();
    });
  });

  it("renders score changes section", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-section")).toBeInTheDocument();
    });
  });

  it("renders frequency section with three options", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("frequency-section")).toBeInTheDocument();
    });

    expect(
      screen.getByTestId("frequency-option-immediate"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("frequency-option-daily_digest"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("frequency-option-weekly_digest"),
    ).toBeInTheDocument();
  });

  it("renders score change toggle checked by default", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeChecked();
    });
  });

  it("renders score change toggle unchecked when prefs say false", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, notification_score_changes: false },
    });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).not.toBeChecked();
    });
  });

  it("does not render push section when push is unsupported", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-section")).toBeInTheDocument();
    });

    expect(
      screen.queryByTestId("push-notifications-section"),
    ).not.toBeInTheDocument();
  });

  // ─── Interaction ──────────────────────────────────────────────────────────

  it("shows save button after toggling score changes", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("score-changes-toggle"));

    expect(screen.getByTestId("save-notification-prefs")).toBeInTheDocument();
  });

  it("shows save button after changing frequency", async () => {
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByTestId("frequency-option-daily_digest"),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("frequency-option-daily_digest"));

    expect(screen.getByTestId("save-notification-prefs")).toBeInTheDocument();
  });

  it("calls setUserPreferences with score changes false on save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeInTheDocument();
    });

    // Toggle score changes off
    await user.click(screen.getByTestId("score-changes-toggle"));
    await user.click(screen.getByTestId("save-notification-prefs"));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          p_notification_score_changes: false,
          p_notification_frequency: "immediate",
        }),
      );
    });
  });

  it("calls setUserPreferences with weekly_digest frequency on save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByTestId("frequency-option-weekly_digest"),
      ).toBeInTheDocument();
    });

    // Select weekly digest
    await user.click(screen.getByTestId("frequency-option-weekly_digest"));
    await user.click(screen.getByTestId("save-notification-prefs"));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          p_notification_score_changes: true,
          p_notification_frequency: "weekly_digest",
        }),
      );
    });
  });

  it("hides save button after successful save", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("score-changes-toggle"));
    await user.click(screen.getByTestId("save-notification-prefs"));

    await waitFor(() => {
      expect(
        screen.queryByTestId("save-notification-prefs"),
      ).not.toBeInTheDocument();
    });
  });

  // ─── Error handling ───────────────────────────────────────────────────────

  it("shows error toast when save fails", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSetPrefs.mockResolvedValue({
      ok: false,
      error: { code: "INTERNAL", message: "DB error" },
    });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("score-changes-toggle"));
    await user.click(screen.getByTestId("save-notification-prefs"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
  });

  // ─── Loading state ────────────────────────────────────────────────────────

  it("shows loading spinner while preferences load", () => {
    mockGetPrefs.mockReturnValue(new Promise(() => {})); // never resolves
    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    expect(screen.getByRole("status")).toBeInTheDocument();
  });

  // ─── Frequency selection persists from prefs ──────────────────────────────

  it("selects daily_digest from prefs data", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, notification_frequency: "daily_digest" },
    });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      const dailyOption = screen.getByTestId("frequency-option-daily_digest");
      const radio = dailyOption.querySelector(
        "input[type='radio']",
      ) as HTMLInputElement;
      expect(radio.checked).toBe(true);
    });
  });

  it("passes through country and language from prefs when saving", async () => {
    mockGetPrefs.mockResolvedValue({
      ok: true,
      data: { ...mockPrefsData, country: "DE", preferred_language: "de" },
    });
    mockSetPrefs.mockResolvedValue({ ok: true });

    render(<NotificationSettingsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByTestId("score-changes-toggle")).toBeInTheDocument();
    });

    await user.click(screen.getByTestId("score-changes-toggle"));
    await user.click(screen.getByTestId("save-notification-prefs"));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          p_country: "DE",
          p_preferred_language: "de",
        }),
      );
    });
  });

  // ─── Push Notification Flows ──────────────────────────────────────────────

  describe("when push is supported", () => {
    beforeEach(async () => {
      const pushManager = await import("@/lib/push-manager");
      vi.mocked(pushManager.isPushSupported).mockReturnValue(true);
      vi.mocked(pushManager.getNotificationPermission).mockReturnValue(
        "default",
      );
      vi.mocked(pushManager.getCurrentPushSubscription).mockResolvedValue(null);
    });

    it("renders push notifications section", async () => {
      render(<NotificationSettingsPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getByTestId("push-notifications-section"),
        ).toBeInTheDocument();
      });
    });

    it("renders enable button when permission is default", async () => {
      render(<NotificationSettingsPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("push-toggle-button")).toBeInTheDocument();
      });
    });

    it("renders denied message when permission is denied", async () => {
      const pushManager = await import("@/lib/push-manager");
      vi.mocked(pushManager.getNotificationPermission).mockReturnValue(
        "denied",
      );

      render(<NotificationSettingsPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getByTestId("push-denied-message"),
        ).toBeInTheDocument();
      });
    });

    it("enables push when permission is granted", async () => {
      const pushManager = await import("@/lib/push-manager");
      const { showToast } = await import("@/lib/toast");
      const mockSub = { endpoint: "https://example.com/push" } as PushSubscription;

      vi.mocked(pushManager.requestNotificationPermission).mockResolvedValue(
        "granted",
      );
      vi.mocked(pushManager.subscribeToPush).mockResolvedValue(mockSub);
      vi.mocked(pushManager.extractSubscriptionData).mockReturnValue({
        endpoint: "https://example.com/push",
        p256dh: "key1",
        auth: "key2",
      });
      vi.stubEnv("NEXT_PUBLIC_VAPID_PUBLIC_KEY", "test-vapid-key");

      render(<NotificationSettingsPage />, { wrapper: createWrapper() });
      const user = userEvent.setup();

      await waitFor(() => {
        expect(screen.getByTestId("push-toggle-button")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("push-toggle-button"));

      await waitFor(() => {
        expect(pushManager.subscribeToPush).toHaveBeenCalledWith(
          "test-vapid-key",
        );
      });
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "success" }),
      );

      vi.unstubAllEnvs();
    });

    it("shows error toast when permission is denied by user", async () => {
      const pushManager = await import("@/lib/push-manager");
      const { showToast } = await import("@/lib/toast");

      vi.mocked(pushManager.requestNotificationPermission).mockResolvedValue(
        "denied",
      );

      render(<NotificationSettingsPage />, { wrapper: createWrapper() });
      const user = userEvent.setup();

      await waitFor(() => {
        expect(screen.getByTestId("push-toggle-button")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("push-toggle-button"));

      await waitFor(() => {
        expect(showToast).toHaveBeenCalledWith(
          expect.objectContaining({
            type: "error",
            messageKey: "notifications.permissionDenied",
          }),
        );
      });
    });

    it("disables push when already enabled", async () => {
      const pushManager = await import("@/lib/push-manager");
      const { showToast } = await import("@/lib/toast");
      const mockSub = { endpoint: "https://example.com/push" } as PushSubscription;

      vi.mocked(pushManager.getCurrentPushSubscription).mockResolvedValue(
        mockSub,
      );
      vi.mocked(pushManager.extractSubscriptionData).mockReturnValue({
        endpoint: "https://example.com/push",
        p256dh: "key1",
        auth: "key2",
      });

      render(<NotificationSettingsPage />, { wrapper: createWrapper() });
      const user = userEvent.setup();

      await waitFor(() => {
        expect(screen.getByTestId("push-toggle-button")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("push-toggle-button"));

      await waitFor(() => {
        expect(pushManager.unsubscribeFromPush).toHaveBeenCalled();
      });
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "success" }),
      );
    });

    it("shows error toast when toggle push throws", async () => {
      const pushManager = await import("@/lib/push-manager");
      const { showToast } = await import("@/lib/toast");

      vi.mocked(pushManager.requestNotificationPermission).mockRejectedValue(
        new Error("network error"),
      );

      render(<NotificationSettingsPage />, { wrapper: createWrapper() });
      const user = userEvent.setup();

      await waitFor(() => {
        expect(screen.getByTestId("push-toggle-button")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("push-toggle-button"));

      await waitFor(() => {
        expect(showToast).toHaveBeenCalledWith(
          expect.objectContaining({
            type: "error",
            messageKey: "common.error",
          }),
        );
      });
    });
  });
});
