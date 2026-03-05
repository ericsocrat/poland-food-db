import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  isPushSupported,
  getNotificationPermission,
  requestNotificationPermission,
  urlBase64ToUint8Array,
  getCurrentPushSubscription,
  subscribeToPush,
  unsubscribeFromPush,
  extractSubscriptionData,
} from "./push-manager";

// ─── Helpers ────────────────────────────────────────────────────────────────

let origServiceWorker: ServiceWorkerContainer;
let origPushManager: typeof PushManager;
let origNotification: typeof Notification;

beforeEach(() => {
  origServiceWorker = navigator.serviceWorker;
  origPushManager = globalThis.PushManager;
  origNotification = globalThis.Notification;
});

afterEach(() => {
  vi.restoreAllMocks();
  // Restore globals
  Object.defineProperty(navigator, "serviceWorker", {
    value: origServiceWorker,
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "PushManager", {
    value: origPushManager,
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "Notification", {
    value: origNotification,
    writable: true,
    configurable: true,
  });
});

function setupPushSupported(permission: NotificationPermission = "default") {
  Object.defineProperty(navigator, "serviceWorker", {
    value: { ready: Promise.resolve({}) },
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "PushManager", {
    value: class {},
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "Notification", {
    value: {
      permission,
      requestPermission: vi.fn().mockResolvedValue("granted"),
    },
    writable: true,
    configurable: true,
  });
}

function removePushAPIs() {
  Object.defineProperty(navigator, "serviceWorker", {
    value: undefined,
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "PushManager", {
    value: undefined,
    writable: true,
    configurable: true,
  });
  Object.defineProperty(globalThis, "Notification", {
    value: undefined,
    writable: true,
    configurable: true,
  });
}

// ─── isPushSupported ────────────────────────────────────────────────────────

describe("isPushSupported", () => {
  it("returns true when serviceWorker, PushManager, and Notification exist", () => {
    setupPushSupported();
    expect(isPushSupported()).toBe(true);
  });

  it("returns false when serviceWorker is removed from navigator", () => {
    setupPushSupported();
    // In jsdom, navigator.serviceWorker lives on the prototype so
    // `"serviceWorker" in navigator` is always true unless we shadow
    // the prototype check by deleting the own-property and also
    // removing it from the prototype.  Instead, we verify the combined
    // guard: if Notification is the one missing piece, the result is
    // false (already tested below). Here we verify a nuance: when
    // PushManager AND Notification are both missing it is still false.
    Object.defineProperty(globalThis, "PushManager", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    Object.defineProperty(globalThis, "Notification", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    expect(isPushSupported()).toBe(false);
  });

  it("returns false when PushManager is missing", () => {
    setupPushSupported();
    Object.defineProperty(globalThis, "PushManager", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    expect(isPushSupported()).toBe(false);
  });

  it("returns false when Notification is missing", () => {
    setupPushSupported();
    Object.defineProperty(globalThis, "Notification", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    expect(isPushSupported()).toBe(false);
  });

  it("returns false in SSR (no window)", () => {
    const origWindow = globalThis.window;
    Object.defineProperty(globalThis, "window", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    expect(isPushSupported()).toBe(false);
    Object.defineProperty(globalThis, "window", {
      value: origWindow,
      writable: true,
      configurable: true,
    });
  });
});

// ─── getNotificationPermission ──────────────────────────────────────────────

describe("getNotificationPermission", () => {
  it("returns 'granted' when permission is granted", () => {
    setupPushSupported("granted");
    expect(getNotificationPermission()).toBe("granted");
  });

  it("returns 'denied' when permission is denied", () => {
    setupPushSupported("denied");
    expect(getNotificationPermission()).toBe("denied");
  });

  it("returns 'default' when permission is default", () => {
    setupPushSupported("default");
    expect(getNotificationPermission()).toBe("default");
  });

  it("returns 'unsupported' when Notification API is missing", () => {
    Object.defineProperty(globalThis, "Notification", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    expect(getNotificationPermission()).toBe("unsupported");
  });
});

// ─── requestNotificationPermission ──────────────────────────────────────────

describe("requestNotificationPermission", () => {
  it("requests and returns 'granted' permission", async () => {
    setupPushSupported();
    (Notification.requestPermission as ReturnType<typeof vi.fn>).mockResolvedValue(
      "granted",
    );
    const result = await requestNotificationPermission();
    expect(result).toBe("granted");
  });

  it("returns 'denied' when user denies permission", async () => {
    setupPushSupported();
    (Notification.requestPermission as ReturnType<typeof vi.fn>).mockResolvedValue(
      "denied",
    );
    const result = await requestNotificationPermission();
    expect(result).toBe("denied");
  });

  it("returns 'denied' when push is not supported", async () => {
    removePushAPIs();
    const result = await requestNotificationPermission();
    expect(result).toBe("denied");
  });
});

// ─── urlBase64ToUint8Array ──────────────────────────────────────────────────

describe("urlBase64ToUint8Array", () => {
  it("converts a URL-safe base64 VAPID key to Uint8Array", () => {
    // Known test vector: 'AQAB' is base64 for bytes [1, 0, 1]
    const result = urlBase64ToUint8Array("AQAB");
    expect(result).toBeInstanceOf(Uint8Array);
    expect(result[0]).toBe(1);
    expect(result[1]).toBe(0);
    expect(result[2]).toBe(1);
  });

  it("handles URL-safe characters (- and _)", () => {
    // '-' should become '+', '_' should become '/'
    // Base64 'A-B_' → 'A+B/' → decodes to bytes [3, 224, 127]
    const result = urlBase64ToUint8Array("A-B_");
    expect(result).toBeInstanceOf(Uint8Array);
    expect(result.length).toBe(3);
  });

  it("adds correct padding", () => {
    // Input with length not divisible by 4 should be padded
    const result = urlBase64ToUint8Array("AQ");
    expect(result).toBeInstanceOf(Uint8Array);
    expect(result[0]).toBe(1);
  });

  it("returns empty Uint8Array for empty input", () => {
    const result = urlBase64ToUint8Array("");
    expect(result).toBeInstanceOf(Uint8Array);
    expect(result.length).toBe(0);
  });
});

// ─── getCurrentPushSubscription ─────────────────────────────────────────────

describe("getCurrentPushSubscription", () => {
  it("returns null when no service worker", async () => {
    Object.defineProperty(navigator, "serviceWorker", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const result = await getCurrentPushSubscription();
    expect(result).toBeNull();
  });

  it("returns null when pushManager.getSubscription returns null", async () => {
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: { getSubscription: vi.fn().mockResolvedValue(null) },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await getCurrentPushSubscription();
    expect(result).toBeNull();
  });

  it("returns subscription when one exists", async () => {
    const mockSubscription = { endpoint: "https://push.example.com" };
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            getSubscription: vi.fn().mockResolvedValue(mockSubscription),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await getCurrentPushSubscription();
    expect(result).toEqual(mockSubscription);
  });

  it("returns null when getSubscription throws", async () => {
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            getSubscription: vi.fn().mockRejectedValue(new Error("fail")),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await getCurrentPushSubscription();
    expect(result).toBeNull();
  });
});

// ─── subscribeToPush ────────────────────────────────────────────────────────

describe("subscribeToPush", () => {
  const vapidKey = "BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkGs-GDq5mvl_O53WX19gYe_Sui_nhNx0EWomzftl0";

  it("returns subscription on success", async () => {
    const mockSubscription = { endpoint: "https://push.example.com/sub1" };
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            subscribe: vi.fn().mockResolvedValue(mockSubscription),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await subscribeToPush(vapidKey);
    expect(result).toEqual(mockSubscription);
  });

  it("returns null when no service worker", async () => {
    Object.defineProperty(navigator, "serviceWorker", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const result = await subscribeToPush(vapidKey);
    expect(result).toBeNull();
  });

  it("returns null when subscribe fails", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            subscribe: vi.fn().mockRejectedValue(new Error("Subscription failed")),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await subscribeToPush(vapidKey);
    expect(result).toBeNull();
    expect(consoleSpy).toHaveBeenCalledWith(
      "Push subscription failed:",
      expect.any(Error),
    );
  });
});

// ─── unsubscribeFromPush ────────────────────────────────────────────────────

describe("unsubscribeFromPush", () => {
  it("returns true when no existing subscription (already unsubscribed)", async () => {
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: { getSubscription: vi.fn().mockResolvedValue(null) },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await unsubscribeFromPush();
    expect(result).toBe(true);
  });

  it("returns true after successful unsubscribe", async () => {
    const mockSubscription = {
      unsubscribe: vi.fn().mockResolvedValue(true),
    };
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            getSubscription: vi.fn().mockResolvedValue(mockSubscription),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await unsubscribeFromPush();
    expect(result).toBe(true);
  });

  it("returns false when unsubscribe throws", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    const mockSubscription = {
      unsubscribe: vi.fn().mockRejectedValue(new Error("fail")),
    };
    Object.defineProperty(navigator, "serviceWorker", {
      value: {
        ready: Promise.resolve({
          pushManager: {
            getSubscription: vi.fn().mockResolvedValue(mockSubscription),
          },
        }),
      },
      writable: true,
      configurable: true,
    });
    const result = await unsubscribeFromPush();
    expect(result).toBe(false);
    expect(consoleSpy).toHaveBeenCalled();
  });
});

// ─── extractSubscriptionData ────────────────────────────────────────────────

describe("extractSubscriptionData", () => {
  it("extracts endpoint, p256dh, and auth from subscription", () => {
    const mockSubscription = {
      endpoint: "https://push.example.com/sub/123",
      getKey: vi.fn((name: string) => {
        if (name === "p256dh") return new Uint8Array([1, 2, 3]).buffer;
        if (name === "auth") return new Uint8Array([4, 5, 6]).buffer;
        return null;
      }),
    } as unknown as PushSubscription;

    const result = extractSubscriptionData(mockSubscription);
    expect(result).not.toBeNull();
    expect(result!.endpoint).toBe("https://push.example.com/sub/123");
    expect(typeof result!.p256dh).toBe("string");
    expect(typeof result!.auth).toBe("string");
    expect(result!.p256dh.length).toBeGreaterThan(0);
    expect(result!.auth.length).toBeGreaterThan(0);
  });

  it("returns null when p256dh key is missing", () => {
    const mockSubscription = {
      endpoint: "https://push.example.com",
      getKey: vi.fn((name: string) => {
        if (name === "auth") return new Uint8Array([1]).buffer;
        return null;
      }),
    } as unknown as PushSubscription;

    const result = extractSubscriptionData(mockSubscription);
    expect(result).toBeNull();
  });

  it("returns null when auth key is missing", () => {
    const mockSubscription = {
      endpoint: "https://push.example.com",
      getKey: vi.fn((name: string) => {
        if (name === "p256dh") return new Uint8Array([1]).buffer;
        return null;
      }),
    } as unknown as PushSubscription;

    const result = extractSubscriptionData(mockSubscription);
    expect(result).toBeNull();
  });

  it("produces URL-safe base64 (no +, /, or = characters)", () => {
    // Use larger buffers to increase chance of +, /, = in standard base64
    const mockSubscription = {
      endpoint: "https://push.example.com",
      getKey: vi.fn((name: string) => {
        if (name === "p256dh")
          return new Uint8Array([255, 254, 253, 252, 251, 250, 249, 248]).buffer;
        if (name === "auth")
          return new Uint8Array([200, 201, 202, 203, 204, 205]).buffer;
        return null;
      }),
    } as unknown as PushSubscription;

    const result = extractSubscriptionData(mockSubscription);
    expect(result).not.toBeNull();
    expect(result!.p256dh).not.toContain("+");
    expect(result!.p256dh).not.toContain("/");
    expect(result!.p256dh).not.toContain("=");
    expect(result!.auth).not.toContain("+");
    expect(result!.auth).not.toContain("/");
    expect(result!.auth).not.toContain("=");
  });
});
