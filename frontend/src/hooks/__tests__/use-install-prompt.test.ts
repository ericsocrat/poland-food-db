import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import {
  useInstallPrompt,
  isDismissCooldownActive,
  incrementVisitCount,
  getVisitCount,
  isIOSDevice,
  isStandalone,
  markInstalled,
  markDismissed,
  STORAGE_KEY_DISMISSED,
  STORAGE_KEY_VISITS,
  STORAGE_KEY_INSTALLED,
  DISMISS_COOLDOWN_MS,
  MIN_VISITS_FOR_BANNER,
  type BeforeInstallPromptEvent,
} from "../use-install-prompt";

/* ── Helpers ─────────────────────────────────────────────────────────────── */

function mockStandalone(val: boolean) {
  Object.defineProperty(globalThis, "matchMedia", {
    writable: true,
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: query === "(display-mode: standalone)" ? val : false,
      media: query,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    })),
  });
}

function createBIP(): BeforeInstallPromptEvent {
  const e = new Event("beforeinstallprompt", {
    cancelable: true,
  }) as unknown as BeforeInstallPromptEvent;
  (e as { prompt: () => Promise<void> }).prompt = vi
    .fn()
    .mockResolvedValue(undefined);
  (
    e as {
      userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
    }
  ).userChoice = Promise.resolve({ outcome: "accepted" as const });
  return e;
}

function createBIPDismissed(): BeforeInstallPromptEvent {
  const e = createBIP();
  (
    e as {
      userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
    }
  ).userChoice = Promise.resolve({ outcome: "dismissed" as const });
  return e;
}

/* ── Tests ────────────────────────────────────────────────────────────────── */

describe("use-install-prompt", () => {
  beforeEach(() => {
    localStorage.clear();
    mockStandalone(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  /* ── Pure helpers ─────────────────────────────────────────────────────── */

  describe("isDismissCooldownActive", () => {
    it("returns false when nothing stored", () => {
      expect(isDismissCooldownActive()).toBe(false);
    });

    it("returns true when dismissed 10 days ago", () => {
      localStorage.setItem(
        STORAGE_KEY_DISMISSED,
        String(Date.now() - 10 * 24 * 60 * 60 * 1000),
      );
      expect(isDismissCooldownActive()).toBe(true);
    });

    it("returns false when dismissed 31 days ago", () => {
      localStorage.setItem(
        STORAGE_KEY_DISMISSED,
        String(Date.now() - 31 * 24 * 60 * 60 * 1000),
      );
      expect(isDismissCooldownActive()).toBe(false);
    });

    it("returns false on storage error", () => {
      const spy = vi
        .spyOn(Storage.prototype, "getItem")
        .mockImplementation(() => {
          throw new Error("quota");
        });
      expect(isDismissCooldownActive()).toBe(false);
      spy.mockRestore();
    });
  });

  describe("incrementVisitCount / getVisitCount", () => {
    it("starts at 0", () => {
      expect(getVisitCount()).toBe(0);
    });

    it("increments and returns new value", () => {
      expect(incrementVisitCount()).toBe(1);
      expect(incrementVisitCount()).toBe(2);
      expect(getVisitCount()).toBe(2);
    });

    it("returns 1 on storage error", () => {
      vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
        throw new Error("fail");
      });
      expect(incrementVisitCount()).toBe(1);
    });

    it("returns 0 on getVisitCount storage error", () => {
      vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
        throw new Error("fail");
      });
      expect(getVisitCount()).toBe(0);
    });
  });

  describe("isIOSDevice", () => {
    it("returns false in JSDOM (no iOS UA)", () => {
      expect(isIOSDevice()).toBe(false);
    });

    it("returns true for iPhone UA", () => {
      Object.defineProperty(navigator, "userAgent", {
        value:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
        configurable: true,
      });
      expect(isIOSDevice()).toBe(true);
    });
  });

  describe("isStandalone", () => {
    it("returns false when not standalone", () => {
      mockStandalone(false);
      expect(isStandalone()).toBe(false);
    });

    it("returns true when standalone", () => {
      mockStandalone(true);
      expect(isStandalone()).toBe(true);
    });

    it("returns false when matchMedia is unavailable", () => {
      Object.defineProperty(globalThis, "matchMedia", {
        writable: true,
        configurable: true,
        value: undefined,
      });
      expect(isStandalone()).toBe(false);
    });
  });

  describe("markInstalled / markDismissed", () => {
    it("markInstalled sets timestamp", () => {
      markInstalled();
      expect(localStorage.getItem(STORAGE_KEY_INSTALLED)).toBeTruthy();
    });

    it("markDismissed sets timestamp", () => {
      markDismissed();
      expect(localStorage.getItem(STORAGE_KEY_DISMISSED)).toBeTruthy();
    });

    it("markInstalled handles storage error gracefully", () => {
      vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
        throw new Error("quota");
      });
      expect(() => markInstalled()).not.toThrow();
    });
  });

  /* ── Hook: useInstallPrompt ──────────────────────────────────────────── */

  describe("useInstallPrompt hook", () => {
    it("canShowBanner is false initially (not enough visits)", () => {
      const { result } = renderHook(() => useInstallPrompt());
      expect(result.current.canShowBanner).toBe(false);
      expect(result.current.isInstalled).toBe(false);
    });

    it("canShowBanner is false when standalone", () => {
      mockStandalone(true);
      const { result } = renderHook(() => useInstallPrompt());
      expect(result.current.isInstalled).toBe(true);
      expect(result.current.canShowBanner).toBe(false);
    });

    it("canShowBanner is false when cooldown active", () => {
      localStorage.setItem(
        STORAGE_KEY_DISMISSED,
        String(Date.now() - 5 * 24 * 60 * 60 * 1000),
      );
      // Even with enough visits pre-set
      localStorage.setItem(STORAGE_KEY_VISITS, "5");
      const { result } = renderHook(() => useInstallPrompt());
      expect(result.current.canShowBanner).toBe(false);
    });

    it("canShowBanner true when ≥2 visits + beforeinstallprompt fires", () => {
      // Pre-set 1 visit so on mount it becomes 2
      localStorage.setItem(STORAGE_KEY_VISITS, "1");

      const { result } = renderHook(() => useInstallPrompt());

      // Fire BIP event
      const bip = createBIP();
      act(() => {
        globalThis.dispatchEvent(bip);
      });

      expect(result.current.canShowBanner).toBe(true);
      expect(result.current.deferredPrompt).toBeTruthy();
    });

    it("canShowBanner false with only 1 visit even if BIP fires", () => {
      // No pre-visits: mount = visit 1
      const { result } = renderHook(() => useInstallPrompt());

      const bip = createBIP();
      act(() => {
        globalThis.dispatchEvent(bip);
      });

      expect(result.current.canShowBanner).toBe(false);
    });

    it("triggerInstall returns accepted and clears prompt", async () => {
      localStorage.setItem(STORAGE_KEY_VISITS, "1");
      const { result } = renderHook(() => useInstallPrompt());

      const bip = createBIP();
      act(() => {
        globalThis.dispatchEvent(bip);
      });

      let outcome: string | undefined;
      await act(async () => {
        outcome = await result.current.triggerInstall();
      });

      expect(outcome).toBe("accepted");
      expect(result.current.deferredPrompt).toBeNull();
    });

    it("triggerInstall returns dismissed and keeps prompt", async () => {
      localStorage.setItem(STORAGE_KEY_VISITS, "1");
      const { result } = renderHook(() => useInstallPrompt());

      const bip = createBIPDismissed();
      act(() => {
        globalThis.dispatchEvent(bip);
      });

      let outcome: string | undefined;
      await act(async () => {
        outcome = await result.current.triggerInstall();
      });

      expect(outcome).toBe("dismissed");
    });

    it("triggerInstall returns unavailable when no prompt", async () => {
      const { result } = renderHook(() => useInstallPrompt());

      let outcome: string | undefined;
      await act(async () => {
        outcome = await result.current.triggerInstall();
      });

      expect(outcome).toBe("unavailable");
    });

    it("dismiss sets cooldown and hides banner", () => {
      localStorage.setItem(STORAGE_KEY_VISITS, "1");
      const { result } = renderHook(() => useInstallPrompt());

      const bip = createBIP();
      act(() => {
        globalThis.dispatchEvent(bip);
      });
      expect(result.current.canShowBanner).toBe(true);

      act(() => {
        result.current.dismiss();
      });

      expect(result.current.canShowBanner).toBe(false);
      expect(localStorage.getItem(STORAGE_KEY_DISMISSED)).toBeTruthy();
    });

    it("appinstalled event marks isInstalled", () => {
      localStorage.setItem(STORAGE_KEY_VISITS, "1");
      const { result } = renderHook(() => useInstallPrompt());

      act(() => {
        globalThis.dispatchEvent(new Event("appinstalled"));
      });

      expect(result.current.isInstalled).toBe(true);
      expect(result.current.canShowBanner).toBe(false);
      expect(localStorage.getItem(STORAGE_KEY_INSTALLED)).toBeTruthy();
    });

    it("cleans up event listeners on unmount", () => {
      const addSpy = vi.spyOn(globalThis, "addEventListener");
      const removeSpy = vi.spyOn(globalThis, "removeEventListener");

      const { unmount } = renderHook(() => useInstallPrompt());

      expect(addSpy).toHaveBeenCalledWith(
        "beforeinstallprompt",
        expect.any(Function),
      );
      expect(addSpy).toHaveBeenCalledWith(
        "appinstalled",
        expect.any(Function),
      );

      unmount();

      expect(removeSpy).toHaveBeenCalledWith(
        "beforeinstallprompt",
        expect.any(Function),
      );
      expect(removeSpy).toHaveBeenCalledWith(
        "appinstalled",
        expect.any(Function),
      );

      addSpy.mockRestore();
      removeSpy.mockRestore();
    });
  });

  /* ── Constants sanity ────────────────────────────────────────────────── */

  describe("constants", () => {
    it("DISMISS_COOLDOWN_MS is 30 days", () => {
      expect(DISMISS_COOLDOWN_MS).toBe(30 * 24 * 60 * 60 * 1000);
    });

    it("MIN_VISITS_FOR_BANNER is 2", () => {
      expect(MIN_VISITS_FOR_BANNER).toBe(2);
    });
  });
});
