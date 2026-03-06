import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";

import {
  STORAGE_KEY_DISMISSED,
  STORAGE_KEY_VISITS,
  STORAGE_KEY_INSTALLED,
  DISMISS_COOLDOWN_MS,
  isDismissCooldownActive,
  incrementVisitCount,
  getVisitCount,
  isIOSDevice,
  isStandalone,
  markInstalled,
  markDismissed,
} from "./use-install-prompt";

// ─── localStorage Mock ──────────────────────────────────────────────────────

let storage: Record<string, string>;

beforeEach(() => {
  storage = {};
  vi.stubGlobal("localStorage", {
    getItem: vi.fn((key: string) => storage[key] ?? null),
    setItem: vi.fn((key: string, value: string) => {
      storage[key] = value;
    }),
    removeItem: vi.fn((key: string) => {
      delete storage[key];
    }),
  });
});

afterEach(() => {
  vi.restoreAllMocks();
});

// ─── isDismissCooldownActive ────────────────────────────────────────────────

describe("isDismissCooldownActive", () => {
  it("returns false when no dismissed timestamp exists", () => {
    expect(isDismissCooldownActive()).toBe(false);
  });

  it("returns true during the cooldown period", () => {
    storage[STORAGE_KEY_DISMISSED] = String(Date.now() - 1000);
    expect(isDismissCooldownActive()).toBe(true);
  });

  it("returns false after the cooldown period has elapsed", () => {
    storage[STORAGE_KEY_DISMISSED] = String(
      Date.now() - DISMISS_COOLDOWN_MS - 1,
    );
    expect(isDismissCooldownActive()).toBe(false);
  });

  it("returns false when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      getItem: () => {
        throw new Error("SecurityError");
      },
    });
    expect(isDismissCooldownActive()).toBe(false);
  });
});

// ─── incrementVisitCount ────────────────────────────────────────────────────

describe("incrementVisitCount", () => {
  it("increments from 0 to 1 on first call", () => {
    expect(incrementVisitCount()).toBe(1);
    expect(storage[STORAGE_KEY_VISITS]).toBe("1");
  });

  it("increments existing value", () => {
    storage[STORAGE_KEY_VISITS] = "5";
    expect(incrementVisitCount()).toBe(6);
    expect(storage[STORAGE_KEY_VISITS]).toBe("6");
  });

  it("returns 1 when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      getItem: () => {
        throw new Error("SecurityError");
      },
      setItem: vi.fn(),
    });
    expect(incrementVisitCount()).toBe(1);
  });
});

// ─── getVisitCount ──────────────────────────────────────────────────────────

describe("getVisitCount", () => {
  it("returns 0 when no visits recorded", () => {
    expect(getVisitCount()).toBe(0);
  });

  it("returns the stored count", () => {
    storage[STORAGE_KEY_VISITS] = "7";
    expect(getVisitCount()).toBe(7);
  });

  it("returns 0 when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      getItem: () => {
        throw new Error("SecurityError");
      },
    });
    expect(getVisitCount()).toBe(0);
  });
});

// ─── isIOSDevice ────────────────────────────────────────────────────────────

describe("isIOSDevice", () => {
  it("returns false in jsdom (no iOS user agent)", () => {
    expect(isIOSDevice()).toBe(false);
  });

  it("returns true for iPhone user agent", () => {
    vi.stubGlobal("navigator", {
      userAgent:
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15",
    });
    expect(isIOSDevice()).toBe(true);
  });

  it("returns true for iPad user agent", () => {
    vi.stubGlobal("navigator", {
      userAgent:
        "Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15",
    });
    expect(isIOSDevice()).toBe(true);
  });

  it("returns false when navigator is undefined", () => {
    const original = globalThis.navigator;
    // @ts-expect-error — testing SSR-like environment
    delete globalThis.navigator;
    expect(isIOSDevice()).toBe(false);
    globalThis.navigator = original;
  });
});

// ─── isStandalone ───────────────────────────────────────────────────────────

describe("isStandalone", () => {
  it("returns false when matchMedia returns no match", () => {
    vi.stubGlobal("matchMedia", vi.fn(() => ({ matches: false })));
    expect(isStandalone()).toBe(false);
  });

  it("returns true when display-mode is standalone", () => {
    vi.stubGlobal("matchMedia", vi.fn(() => ({ matches: true })));
    expect(isStandalone()).toBe(true);
  });

  it("returns false when matchMedia is not a function", () => {
    vi.stubGlobal("matchMedia", undefined);
    expect(isStandalone()).toBe(false);
  });
});

// ─── markInstalled ──────────────────────────────────────────────────────────

describe("markInstalled", () => {
  it("writes a timestamp to localStorage", () => {
    markInstalled();
    expect(storage[STORAGE_KEY_INSTALLED]).toBeDefined();
    const ts = Number(storage[STORAGE_KEY_INSTALLED]);
    expect(ts).toBeGreaterThan(0);
  });

  it("does not throw when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      setItem: () => {
        throw new Error("QuotaExceededError");
      },
    });
    expect(() => markInstalled()).not.toThrow();
  });
});

// ─── markDismissed ──────────────────────────────────────────────────────────

describe("markDismissed", () => {
  it("writes a timestamp to localStorage", () => {
    markDismissed();
    expect(storage[STORAGE_KEY_DISMISSED]).toBeDefined();
    const ts = Number(storage[STORAGE_KEY_DISMISSED]);
    expect(ts).toBeGreaterThan(0);
  });

  it("does not throw when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      setItem: () => {
        throw new Error("QuotaExceededError");
      },
    });
    expect(() => markDismissed()).not.toThrow();
  });
});
