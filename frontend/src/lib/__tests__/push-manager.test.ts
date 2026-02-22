import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  isPushSupported,
  getNotificationPermission,
  requestNotificationPermission,
  urlBase64ToUint8Array,
  getCurrentPushSubscription,
  subscribeToPush,
  unsubscribeFromPush,
  extractSubscriptionData,
} from "../push-manager";

// ─── Mock service worker registration ───────────────────────────────────────

const mockSubscription = {
  endpoint: "https://push.example.com/sub/123",
  getKey: vi.fn((name: string) => {
    if (name === "p256dh") return new ArrayBuffer(65);
    if (name === "auth") return new ArrayBuffer(16);
    return null;
  }),
  unsubscribe: vi.fn().mockResolvedValue(true),
  toJSON: vi.fn().mockReturnValue({
    endpoint: "https://push.example.com/sub/123",
    keys: { p256dh: "test-p256dh", auth: "test-auth" },
  }),
} as unknown as PushSubscription;

const mockPushManager = {
  getSubscription: vi.fn().mockResolvedValue(null),
  subscribe: vi.fn().mockResolvedValue(mockSubscription),
};

const mockRegistration = {
  pushManager: mockPushManager,
  showNotification: vi.fn(),
} as unknown as ServiceWorkerRegistration;

describe("push-manager", () => {
  const originalNavigator = { ...navigator };

  beforeEach(() => {
    vi.clearAllMocks();
    // Setup default Push API support
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve(mockRegistration),
        controller: {},
      },
      writable: true,
      configurable: true,
    });
    Object.defineProperty(window, "PushManager", {
      value: class PushManager {},
      writable: true,
      configurable: true,
    });
    Object.defineProperty(window, "Notification", {
      value: class Notification {
        static permission: NotificationPermission = "default";
        static requestPermission = vi.fn().mockResolvedValue("granted");
      },
      writable: true,
      configurable: true,
    });
  });

  afterEach(() => {
    // Restore
    Object.defineProperty(navigator, "serviceWorker", {
      value: originalNavigator.serviceWorker,
      writable: true,
      configurable: true,
    });
  });

  // ─── isPushSupported ──────────────────────────────────────────────────

  describe("isPushSupported", () => {
    it("returns true when all APIs are available", () => {
      expect(isPushSupported()).toBe(true);
    });

    it("returns false when PushManager is missing", () => {
      Object.defineProperty(window, "PushManager", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      expect(isPushSupported()).toBe(false);
    });

    it("returns false when Notification is missing", () => {
      Object.defineProperty(window, "Notification", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      expect(isPushSupported()).toBe(false);
    });
  });

  // ─── getNotificationPermission ────────────────────────────────────────

  describe("getNotificationPermission", () => {
    it('returns current permission state ("default")', () => {
      expect(getNotificationPermission()).toBe("default");
    });

    it("returns 'granted' when permission is granted", () => {
      Object.defineProperty(window, "Notification", {
        value: { permission: "granted" },
        writable: true,
        configurable: true,
      });
      expect(getNotificationPermission()).toBe("granted");
    });

    it("returns 'denied' when permission is denied", () => {
      Object.defineProperty(window, "Notification", {
        value: { permission: "denied" },
        writable: true,
        configurable: true,
      });
      expect(getNotificationPermission()).toBe("denied");
    });
  });

  // ─── requestNotificationPermission ────────────────────────────────────

  describe("requestNotificationPermission", () => {
    it("requests and returns permission", async () => {
      const result = await requestNotificationPermission();
      expect(Notification.requestPermission).toHaveBeenCalled();
      expect(result).toBe("granted");
    });

    it('returns "denied" when push is not supported', async () => {
      Object.defineProperty(window, "PushManager", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await requestNotificationPermission();
      expect(result).toBe("denied");
    });
  });

  // ─── urlBase64ToUint8Array ────────────────────────────────────────────

  describe("urlBase64ToUint8Array", () => {
    it("converts a base64 string to Uint8Array", () => {
      // "SGVsbG8" = base64url of "Hello"
      const result = urlBase64ToUint8Array("SGVsbG8");
      expect(result).toBeInstanceOf(Uint8Array);
      expect(result.length).toBe(5); // "Hello" = 5 bytes
      expect(String.fromCharCode(...result)).toBe("Hello");
    });

    it("handles URL-safe characters (- and _)", () => {
      // Standard base64 uses + and /, URL-safe uses - and _
      const input = "dGVzdC1f"; // "test-_" in base64url
      const result = urlBase64ToUint8Array(input);
      expect(result).toBeInstanceOf(Uint8Array);
    });

    it("handles empty string", () => {
      const result = urlBase64ToUint8Array("");
      expect(result.length).toBe(0);
    });
  });

  // ─── getCurrentPushSubscription ───────────────────────────────────────

  describe("getCurrentPushSubscription", () => {
    it("returns null when no subscription exists", async () => {
      mockPushManager.getSubscription.mockResolvedValueOnce(null);
      const result = await getCurrentPushSubscription();
      expect(result).toBeNull();
    });

    it("returns the existing subscription", async () => {
      mockPushManager.getSubscription.mockResolvedValueOnce(mockSubscription);
      const result = await getCurrentPushSubscription();
      expect(result).toBe(mockSubscription);
    });

    it("returns null when service worker is unavailable", async () => {
      Object.defineProperty(navigator, "serviceWorker", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await getCurrentPushSubscription();
      expect(result).toBeNull();
    });
  });

  // ─── subscribeToPush ─────────────────────────────────────────────────

  describe("subscribeToPush", () => {
    it("subscribes with VAPID public key", async () => {
      const result = await subscribeToPush("BFakeVapidPublicKey123");
      expect(mockPushManager.subscribe).toHaveBeenCalledWith({
        userVisibleOnly: true,
        applicationServerKey: expect.any(ArrayBuffer),
      });
      expect(result).toBe(mockSubscription);
    });

    it("returns null on subscribe error", async () => {
      mockPushManager.subscribe.mockRejectedValueOnce(new Error("fail"));
      const result = await subscribeToPush("BFakeVapidPublicKey123");
      expect(result).toBeNull();
    });

    it("returns null when service worker is unavailable", async () => {
      Object.defineProperty(navigator, "serviceWorker", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await subscribeToPush("BFakeVapidPublicKey123");
      expect(result).toBeNull();
    });
  });

  // ─── unsubscribeFromPush ──────────────────────────────────────────────

  describe("unsubscribeFromPush", () => {
    it("returns true when already unsubscribed (no subscription)", async () => {
      mockPushManager.getSubscription.mockResolvedValueOnce(null);
      const result = await unsubscribeFromPush();
      expect(result).toBe(true);
    });

    it("unsubscribes existing subscription", async () => {
      mockPushManager.getSubscription.mockResolvedValueOnce(mockSubscription);
      const result = await unsubscribeFromPush();
      expect(mockSubscription.unsubscribe).toHaveBeenCalled();
      expect(result).toBe(true);
    });

    it("returns false on unsubscribe error", async () => {
      const failSub = {
        ...mockSubscription,
        unsubscribe: vi.fn().mockRejectedValue(new Error("fail")),
      };
      mockPushManager.getSubscription.mockResolvedValueOnce(failSub as unknown as PushSubscription);
      const result = await unsubscribeFromPush();
      expect(result).toBe(false);
    });
  });

  // ─── extractSubscriptionData ──────────────────────────────────────────

  describe("extractSubscriptionData", () => {
    it("extracts endpoint and keys from subscription", () => {
      const result = extractSubscriptionData(mockSubscription);
      expect(result).not.toBeNull();
      expect(result!.endpoint).toBe("https://push.example.com/sub/123");
      expect(typeof result!.p256dh).toBe("string");
      expect(typeof result!.auth).toBe("string");
    });

    it("returns null when keys are missing", () => {
      const noKeySub = {
        ...mockSubscription,
        getKey: vi.fn().mockReturnValue(null),
      } as unknown as PushSubscription;
      const result = extractSubscriptionData(noKeySub);
      expect(result).toBeNull();
    });
  });
});
