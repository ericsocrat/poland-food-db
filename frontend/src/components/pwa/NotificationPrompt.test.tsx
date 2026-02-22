import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { NotificationPrompt } from "./NotificationPrompt";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({
    track: vi.fn(),
  }),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  savePushSubscription: vi.fn().mockResolvedValue({ ok: true }),
}));

const mockIsPushSupported = vi.fn().mockReturnValue(true);
const mockGetNotificationPermission = vi.fn().mockReturnValue("default");
const mockRequestNotificationPermission = vi.fn().mockResolvedValue("granted");
const mockSubscribeToPush = vi.fn().mockResolvedValue({
  endpoint: "https://push.example.com/sub/123",
  getKey: (name: string) => {
    if (name === "p256dh") return new ArrayBuffer(65);
    if (name === "auth") return new ArrayBuffer(16);
    return null;
  },
});
const mockExtractSubscriptionData = vi.fn().mockReturnValue({
  endpoint: "https://push.example.com/sub/123",
  p256dh: "test-p256dh",
  auth: "test-auth",
});

vi.mock("@/lib/push-manager", () => ({
  isPushSupported: () => mockIsPushSupported(),
  getNotificationPermission: () => mockGetNotificationPermission(),
  requestNotificationPermission: () => mockRequestNotificationPermission(),
  subscribeToPush: (...args: unknown[]) => mockSubscribeToPush(...args),
  extractSubscriptionData: (...args: unknown[]) => mockExtractSubscriptionData(...args),
}));

describe("NotificationPrompt", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockIsPushSupported.mockReturnValue(true);
    mockGetNotificationPermission.mockReturnValue("default");
    // Set the env var
    process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY = "test-vapid-key";
  });

  it("renders the prompt when push is supported and permission is default", () => {
    render(<NotificationPrompt />);
    expect(screen.getByTestId("notification-prompt")).toBeInTheDocument();
    expect(screen.getByText("notifications.promptTitle")).toBeInTheDocument();
    expect(screen.getByText("notifications.promptDescription")).toBeInTheDocument();
    expect(screen.getByTestId("enable-notifications-button")).toBeInTheDocument();
  });

  it("does not render when push is not supported", () => {
    mockIsPushSupported.mockReturnValue(false);
    const { container } = render(<NotificationPrompt />);
    expect(container.innerHTML).toBe("");
  });

  it("does not render when permission is already granted", () => {
    mockGetNotificationPermission.mockReturnValue("granted");
    const { container } = render(<NotificationPrompt />);
    expect(container.innerHTML).toBe("");
  });

  it("does not render when permission is denied", () => {
    mockGetNotificationPermission.mockReturnValue("denied");
    const { container } = render(<NotificationPrompt />);
    expect(container.innerHTML).toBe("");
  });

  it("calls onDismiss when dismiss button is clicked", () => {
    const onDismiss = vi.fn();
    render(<NotificationPrompt onDismiss={onDismiss} />);
    fireEvent.click(screen.getByTestId("dismiss-notification-prompt"));
    expect(onDismiss).toHaveBeenCalled();
  });

  it("enables notifications on button click", async () => {
    const onDismiss = vi.fn();
    render(<NotificationPrompt onDismiss={onDismiss} />);

    fireEvent.click(screen.getByTestId("enable-notifications-button"));

    await waitFor(() => {
      expect(mockRequestNotificationPermission).toHaveBeenCalled();
      expect(mockSubscribeToPush).toHaveBeenCalledWith("test-vapid-key");
      expect(onDismiss).toHaveBeenCalled();
    });
  });

  it("calls onDismiss when permission is denied", async () => {
    mockRequestNotificationPermission.mockResolvedValue("denied");
    const onDismiss = vi.fn();
    render(<NotificationPrompt onDismiss={onDismiss} />);

    fireEvent.click(screen.getByTestId("enable-notifications-button"));

    await waitFor(() => {
      expect(onDismiss).toHaveBeenCalled();
    });
  });

  it("has accessible alert role", () => {
    render(<NotificationPrompt />);
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("dismiss button has accessible label", () => {
    render(<NotificationPrompt />);
    expect(screen.getByLabelText("common.dismiss")).toBeInTheDocument();
  });
});
