// ─── useReducedMotion hook tests ─────────────────────────────────────────────

import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useReducedMotion } from "./use-reduced-motion";

describe("useReducedMotion", () => {
  let listeners: Map<string, (e: MediaQueryListEvent) => void>;
  let matches: boolean;

  beforeEach(() => {
    listeners = new Map();
    matches = false;

    vi.stubGlobal(
      "matchMedia",
      vi.fn().mockImplementation((query: string) => ({
        matches,
        media: query,
        addEventListener: (_type: string, fn: (e: MediaQueryListEvent) => void) => {
          listeners.set(_type, fn);
        },
        removeEventListener: (_type: string) => {
          listeners.delete(_type);
        },
      })),
    );
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("returns false when user has no motion preference", () => {
    matches = false;
    const { result } = renderHook(() => useReducedMotion());
    expect(result.current).toBe(false);
  });

  it("returns true when user prefers reduced motion", () => {
    matches = true;
    const { result } = renderHook(() => useReducedMotion());
    expect(result.current).toBe(true);
  });

  it("responds to media query changes", () => {
    matches = false;
    const { result } = renderHook(() => useReducedMotion());
    expect(result.current).toBe(false);

    // Simulate user changing preference
    act(() => {
      const onChange = listeners.get("change");
      onChange?.({ matches: true } as MediaQueryListEvent);
    });
    expect(result.current).toBe(true);
  });

  it("queries the correct media query", () => {
    renderHook(() => useReducedMotion());
    expect(window.matchMedia).toHaveBeenCalledWith(
      "(prefers-reduced-motion: reduce)",
    );
  });

  it("cleans up listener on unmount", () => {
    const { unmount } = renderHook(() => useReducedMotion());
    expect(listeners.has("change")).toBe(true);
    unmount();
    expect(listeners.has("change")).toBe(false);
  });
});
