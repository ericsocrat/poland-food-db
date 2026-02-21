import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import {
  hasPrivacyConsent,
  acceptPrivacyConsent,
  revokePrivacyConsent,
} from "./privacy";

// ─── localStorage mock ──────────────────────────────────────────────────────

const store: Record<string, string> = {};

const localStorageMock = {
  getItem: vi.fn((key: string) => store[key] ?? null),
  setItem: vi.fn((key: string, value: string) => {
    store[key] = value;
  }),
  removeItem: vi.fn((key: string) => {
    delete store[key];
  }),
};

Object.defineProperty(globalThis, "localStorage", {
  value: localStorageMock,
  writable: true,
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("privacy", () => {
  const CONSENT_KEY = "fooddb:image-search-privacy-accepted";

  beforeEach(() => {
    vi.clearAllMocks();
    // Clear store
    Object.keys(store).forEach((key) => delete store[key]);
  });

  // ── hasPrivacyConsent ──────────────────────────────────────────────────

  describe("hasPrivacyConsent", () => {
    it("returns false when no consent stored", () => {
      expect(hasPrivacyConsent()).toBe(false);
      expect(localStorageMock.getItem).toHaveBeenCalledWith(CONSENT_KEY);
    });

    it("returns true when consent is '1'", () => {
      store[CONSENT_KEY] = "1";
      expect(hasPrivacyConsent()).toBe(true);
    });

    it("returns false when consent value is not '1'", () => {
      store[CONSENT_KEY] = "yes";
      expect(hasPrivacyConsent()).toBe(false);
    });
  });

  // ── acceptPrivacyConsent ───────────────────────────────────────────────

  describe("acceptPrivacyConsent", () => {
    it("stores '1' in localStorage", () => {
      acceptPrivacyConsent();
      expect(localStorageMock.setItem).toHaveBeenCalledWith(CONSENT_KEY, "1");
      expect(store[CONSENT_KEY]).toBe("1");
    });

    it("makes hasPrivacyConsent return true", () => {
      acceptPrivacyConsent();
      expect(hasPrivacyConsent()).toBe(true);
    });
  });

  // ── revokePrivacyConsent ───────────────────────────────────────────────

  describe("revokePrivacyConsent", () => {
    it("removes consent from localStorage", () => {
      store[CONSENT_KEY] = "1";
      revokePrivacyConsent();
      expect(localStorageMock.removeItem).toHaveBeenCalledWith(CONSENT_KEY);
      expect(store[CONSENT_KEY]).toBeUndefined();
    });

    it("makes hasPrivacyConsent return false", () => {
      acceptPrivacyConsent();
      revokePrivacyConsent();
      expect(hasPrivacyConsent()).toBe(false);
    });
  });

  // ── releaseImageData re-export ─────────────────────────────────────────

  describe("releaseImageData re-export", () => {
    it("re-exports releaseImageData from enforcement", async () => {
      const { releaseImageData } = await import("./privacy");
      expect(typeof releaseImageData).toBe("function");
    });
  });

  // ── SSR guards (typeof window === "undefined") ─────────────────────────

  describe("SSR guards", () => {
    let origWindow: typeof globalThis.window;

    beforeEach(() => {
      origWindow = globalThis.window;
      // Make typeof window === "undefined"
      Object.defineProperty(globalThis, "window", {
        value: undefined,
        configurable: true,
      });
    });

    afterEach(() => {
      Object.defineProperty(globalThis, "window", {
        value: origWindow,
        configurable: true,
      });
    });

    it("hasPrivacyConsent returns true on server (SSR)", () => {
      expect(hasPrivacyConsent()).toBe(true);
    });

    it("acceptPrivacyConsent is a no-op on server", () => {
      acceptPrivacyConsent();
      // Should not throw and should not touch localStorage
      expect(localStorageMock.setItem).not.toHaveBeenCalled();
    });

    it("revokePrivacyConsent is a no-op on server", () => {
      revokePrivacyConsent();
      expect(localStorageMock.removeItem).not.toHaveBeenCalled();
    });
  });
});
