// ─── useTheme — 3-mode theme hook (light / dark / system) ───────────────────
// Reads/writes theme preference to localStorage.
// Applies the resolved theme (light or dark) to `data-theme` on <html>.
// Listens to prefers-color-scheme media query when mode = 'system'.
//
// For authenticated users, the preference can be synced to user_preferences
// via the Settings page save flow (not handled here — this is the client-only
// primitive that the ThemeToggle component and Settings sync build on).

import { useState, useEffect, useCallback, useMemo } from "react";

export type ThemeMode = "light" | "dark" | "system";
export type ResolvedTheme = "light" | "dark";

const STORAGE_KEY = "theme";

/** Read the persisted theme mode from localStorage. */
function getStoredTheme(): ThemeMode {
  if (globalThis.window === undefined) return "system";
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored === "light" || stored === "dark" || stored === "system") {
      return stored;
    }
  } catch {
    // localStorage blocked (e.g. Safari private browsing)
  }
  return "system";
}

/** Resolve the actual theme (light or dark) from a mode. */
function resolveTheme(mode: ThemeMode): ResolvedTheme {
  if (mode === "light" || mode === "dark") return mode;
  // 'system' — check OS preference
  if (globalThis.window === undefined) return "light";
  return globalThis.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

/** Apply the resolved theme to the document. */
function applyTheme(resolved: ResolvedTheme) {
  if (typeof document === "undefined") return;
  document.documentElement.dataset.theme = resolved;
  // Update meta theme-color for mobile browsers
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) {
    meta.setAttribute("content", resolved === "dark" ? "#111827" : "#16a34a");
  }
}

/**
 * Custom hook for theme management.
 *
 * @returns `{ mode, resolved, setMode }` where:
 *  - `mode` is the user's chosen preference ('light' | 'dark' | 'system')
 *  - `resolved` is the actual applied theme ('light' | 'dark')
 *  - `setMode` changes the preference and persists it
 *
 * @example
 * ```tsx
 * const { mode, resolved, setMode } = useTheme();
 * <button onClick={() => setMode('dark')}>Dark</button>
 * ```
 */
export function useTheme() {
  const [mode, setMode] = useState<ThemeMode>(getStoredTheme);
  const [resolved, setResolved] = useState<ResolvedTheme>(() =>
    resolveTheme(mode),
  );

  const updateMode = useCallback((newMode: ThemeMode) => {
    setMode(newMode);
    try {
      localStorage.setItem(STORAGE_KEY, newMode);
    } catch {
      // localStorage unavailable
    }
    const newResolved = resolveTheme(newMode);
    setResolved(newResolved);
    applyTheme(newResolved);
  }, []);

  // Listen to system preference changes when mode = 'system'
  useEffect(() => {
    if (mode !== "system") return;

    const mql = globalThis.matchMedia("(prefers-color-scheme: dark)");
    const handler = (e: MediaQueryListEvent) => {
      const newResolved = e.matches ? "dark" : "light";
      setResolved(newResolved);
      applyTheme(newResolved);
    };
    mql.addEventListener("change", handler);
    return () => mql.removeEventListener("change", handler);
  }, [mode]);

  // On mount, ensure the DOM attribute matches (in case the inline script
  // didn't run or hydration reset it)
  useEffect(() => {
    applyTheme(resolved);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return useMemo(() => ({ mode, resolved, setMode: updateMode }), [mode, resolved, updateMode]);
}
