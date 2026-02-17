// ─── Tests for useTheme hook ─────────────────────────────────────────────────

import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useTheme } from "@/hooks/use-theme";

// ─── Helpers ────────────────────────────────────────────────────────────────

let mockMatchesDark = false;
let mediaListeners: Array<(e: { matches: boolean }) => void> = [];

function mockMatchMedia() {
  Object.defineProperty(window, "matchMedia", {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: query.includes("dark") ? mockMatchesDark : false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: (_: string, fn: (e: { matches: boolean }) => void) => {
        mediaListeners.push(fn);
      },
      removeEventListener: (_: string, fn: (e: { matches: boolean }) => void) => {
        mediaListeners = mediaListeners.filter((l) => l !== fn);
      },
      dispatchEvent: vi.fn(),
    })),
  });
}

beforeEach(() => {
  localStorage.clear();
  mockMatchesDark = false;
  mediaListeners = [];
  mockMatchMedia();
  document.documentElement.removeAttribute("data-theme");
});

afterEach(() => {
  vi.restoreAllMocks();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useTheme", () => {
  it("defaults to 'system' mode when no localStorage value", () => {
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("system");
  });

  it("resolves to 'light' when system preference is light", () => {
    mockMatchesDark = false;
    mockMatchMedia();
    const { result } = renderHook(() => useTheme());
    expect(result.current.resolved).toBe("light");
  });

  it("resolves to 'dark' when system preference is dark", () => {
    mockMatchesDark = true;
    mockMatchMedia();
    const { result } = renderHook(() => useTheme());
    expect(result.current.resolved).toBe("dark");
  });

  it("reads 'light' from localStorage", () => {
    localStorage.setItem("theme", "light");
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("light");
    expect(result.current.resolved).toBe("light");
  });

  it("reads 'dark' from localStorage", () => {
    localStorage.setItem("theme", "dark");
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("dark");
    expect(result.current.resolved).toBe("dark");
  });

  it("reads 'system' from localStorage", () => {
    localStorage.setItem("theme", "system");
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("system");
  });

  it("ignores invalid localStorage values", () => {
    localStorage.setItem("theme", "invalid-value");
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("system");
  });

  it("switches to dark mode via setMode", () => {
    const { result } = renderHook(() => useTheme());
    act(() => {
      result.current.setMode("dark");
    });
    expect(result.current.mode).toBe("dark");
    expect(result.current.resolved).toBe("dark");
    expect(localStorage.getItem("theme")).toBe("dark");
  });

  it("switches to light mode via setMode", () => {
    localStorage.setItem("theme", "dark");
    const { result } = renderHook(() => useTheme());
    act(() => {
      result.current.setMode("light");
    });
    expect(result.current.mode).toBe("light");
    expect(result.current.resolved).toBe("light");
    expect(localStorage.getItem("theme")).toBe("light");
  });

  it("switches to system mode via setMode", () => {
    localStorage.setItem("theme", "dark");
    const { result } = renderHook(() => useTheme());
    act(() => {
      result.current.setMode("system");
    });
    expect(result.current.mode).toBe("system");
    expect(localStorage.getItem("theme")).toBe("system");
  });

  it("applies data-theme attribute to html element", () => {
    const { result } = renderHook(() => useTheme());
    act(() => {
      result.current.setMode("dark");
    });
    expect(document.documentElement.getAttribute("data-theme")).toBe("dark");

    act(() => {
      result.current.setMode("light");
    });
    expect(document.documentElement.getAttribute("data-theme")).toBe("light");
  });

  it("listens to system preference changes when mode is 'system'", () => {
    const { result } = renderHook(() => useTheme());
    expect(result.current.mode).toBe("system");
    expect(mediaListeners.length).toBeGreaterThan(0);

    // Simulate OS switching to dark
    act(() => {
      mediaListeners.forEach((fn) => fn({ matches: true }));
    });
    expect(result.current.resolved).toBe("dark");

    // Simulate OS switching back to light
    act(() => {
      mediaListeners.forEach((fn) => fn({ matches: false }));
    });
    expect(result.current.resolved).toBe("light");
  });

  it("does not listen to system changes when mode is explicit", () => {
    const { result } = renderHook(() => useTheme());
    act(() => {
      result.current.setMode("dark");
    });
    // Listeners should be cleaned up (no system listening)
    const listenerCountAfterExplicit = mediaListeners.length;
    act(() => {
      result.current.setMode("light");
    });
    // Should still not be listening more
    expect(mediaListeners.length).toBeLessThanOrEqual(listenerCountAfterExplicit);
  });

  it("cycles through all three modes", () => {
    const { result } = renderHook(() => useTheme());

    act(() => result.current.setMode("light"));
    expect(result.current.mode).toBe("light");
    expect(result.current.resolved).toBe("light");

    act(() => result.current.setMode("dark"));
    expect(result.current.mode).toBe("dark");
    expect(result.current.resolved).toBe("dark");

    act(() => result.current.setMode("system"));
    expect(result.current.mode).toBe("system");
    // resolved depends on matchMedia mock
  });
});
