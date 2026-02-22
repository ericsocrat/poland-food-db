"use client";

import { useSyncExternalStore } from "react";

// ─── Online status hook ─────────────────────────────────────────────────────
// Provides a reactive boolean for navigator.onLine, synced via
// useSyncExternalStore for consistent behavior across SSR/hydration.

function subscribe(callback: () => void) {
  globalThis.addEventListener("online", callback);
  globalThis.addEventListener("offline", callback);
  return () => {
    globalThis.removeEventListener("online", callback);
    globalThis.removeEventListener("offline", callback);
  };
}

function getSnapshot(): boolean {
  return navigator.onLine;
}

function getServerSnapshot(): boolean {
  // Assume online during SSR
  return true;
}

/**
 * Returns `true` when the browser has network connectivity, `false` otherwise.
 * Automatically updates when online/offline events fire.
 */
export function useOnlineStatus(): boolean {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}
