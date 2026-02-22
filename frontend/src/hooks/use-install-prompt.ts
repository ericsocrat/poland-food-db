"use client";

/**
 * useInstallPrompt — centralises PWA install-prompt logic.
 *
 * Responsibilities:
 *  - Capture the browser's `beforeinstallprompt` event (Chrome/Edge/Samsung)
 *  - Detect standalone mode (already installed)
 *  - Detect iOS Safari (no native prompt – manual instructions instead)
 *  - Track visits via localStorage, gating the banner on ≥ 2 visits
 *  - 30-day dismiss cooldown
 *  - Track `appinstalled` event
 */

import { useEffect, useState, useCallback, useRef } from "react";

/* ── Public type re-export ─────────────────────────────────────────────────── */
export interface BeforeInstallPromptEvent extends Event {
  prompt(): Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

/* ── Constants (exported for tests) ────────────────────────────────────────── */
export const STORAGE_KEY_DISMISSED = "pwa-install-dismissed-at";
export const STORAGE_KEY_VISITS = "pwa-install-visit-count";
export const STORAGE_KEY_INSTALLED = "pwa-installed";
export const DISMISS_COOLDOWN_MS = 30 * 24 * 60 * 60 * 1000; // 30 days
export const MIN_VISITS_FOR_BANNER = 2;

/* ── Pure helpers (exported for direct use + tests) ────────────────────────── */

/** True while the 30-day dismiss cooldown is still active. */
export function isDismissCooldownActive(): boolean {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_DISMISSED);
    if (!raw) return false;
    return Date.now() - Number(raw) < DISMISS_COOLDOWN_MS;
  } catch {
    return false;
  }
}

/** Increment visit counter and return the new count. */
export function incrementVisitCount(): number {
  try {
    const current = Number(localStorage.getItem(STORAGE_KEY_VISITS) ?? "0");
    const next = current + 1;
    localStorage.setItem(STORAGE_KEY_VISITS, String(next));
    return next;
  } catch {
    return 1;
  }
}

/** Read the current visit count without incrementing. */
export function getVisitCount(): number {
  try {
    return Number(localStorage.getItem(STORAGE_KEY_VISITS) ?? "0");
  } catch {
    return 0;
  }
}

/** Detect iOS Safari (no `beforeinstallprompt`, manual instructions needed). */
export function isIOSDevice(): boolean {
  if (typeof navigator === "undefined") return false;
  return (
    /iPad|iPhone|iPod/.test(navigator.userAgent) ||
    (navigator.userAgent.includes("Mac") && "ontouchend" in document)
  );
}

/** True if app is running in standalone / installed mode. */
export function isStandalone(): boolean {
  if (typeof globalThis.matchMedia !== "function") return false;
  return globalThis.matchMedia("(display-mode: standalone)").matches;
}

/** Record that the PWA was installed. */
export function markInstalled(): void {
  try {
    localStorage.setItem(STORAGE_KEY_INSTALLED, String(Date.now()));
  } catch {
    /* quota exceeded — ignore */
  }
}

/** Record that the user dismissed the banner. */
export function markDismissed(): void {
  try {
    localStorage.setItem(STORAGE_KEY_DISMISSED, String(Date.now()));
  } catch {
    /* quota exceeded — ignore */
  }
}

/* ── Hook return type ──────────────────────────────────────────────────────── */
export interface UseInstallPromptReturn {
  /** The deferred browser prompt — null when not available. */
  deferredPrompt: BeforeInstallPromptEvent | null;
  /** True when the device is iOS (show manual instructions). */
  isIOS: boolean;
  /** True when the PWA is already installed as standalone. */
  isInstalled: boolean;
  /** True when the install banner should be visible. */
  canShowBanner: boolean;
  /** Trigger the native install prompt (Android/Desktop). */
  triggerInstall: () => Promise<"accepted" | "dismissed" | "unavailable">;
  /** Dismiss the banner (sets 30-day cooldown). */
  dismiss: () => void;
}

/* ── Hook ──────────────────────────────────────────────────────────────────── */

export function useInstallPrompt(): UseInstallPromptReturn {
  const [deferredPrompt, setDeferredPrompt] =
    useState<BeforeInstallPromptEvent | null>(null);
  const [isIOS, setIsIOS] = useState(false);
  const [isInstalled, setIsInstalled] = useState(false);
  const [dismissed, setDismissed] = useState(false);
  const [enoughVisits, setEnoughVisits] = useState(false);
  const promptRef = useRef<BeforeInstallPromptEvent | null>(null);

  useEffect(() => {
    // Already installed
    if (isStandalone()) {
      setIsInstalled(true);
      return;
    }

    // Dismiss cooldown active
    if (isDismissCooldownActive()) {
      setDismissed(true);
      return;
    }

    // Increment visit count on mount, check threshold
    const count = incrementVisitCount();
    setEnoughVisits(count >= MIN_VISITS_FOR_BANNER);

    // iOS detection
    setIsIOS(isIOSDevice());

    // Listen for beforeinstallprompt (Chromium browsers)
    const bipHandler = (e: Event) => {
      e.preventDefault();
      const bip = e as BeforeInstallPromptEvent;
      promptRef.current = bip;
      setDeferredPrompt(bip);
    };
    globalThis.addEventListener("beforeinstallprompt", bipHandler);

    // Listen for appinstalled
    const installedHandler = () => {
      setIsInstalled(true);
      markInstalled();
      setDeferredPrompt(null);
      promptRef.current = null;
    };
    globalThis.addEventListener("appinstalled", installedHandler);

    return () => {
      globalThis.removeEventListener("beforeinstallprompt", bipHandler);
      globalThis.removeEventListener("appinstalled", installedHandler);
    };
  }, []);

  const triggerInstall = useCallback(async (): Promise<
    "accepted" | "dismissed" | "unavailable"
  > => {
    const prompt = promptRef.current;
    if (!prompt) return "unavailable";
    await prompt.prompt();
    const { outcome } = await prompt.userChoice;
    if (outcome === "accepted") {
      setDeferredPrompt(null);
      promptRef.current = null;
    }
    return outcome;
  }, []);

  const dismiss = useCallback(() => {
    setDismissed(true);
    setDeferredPrompt(null);
    promptRef.current = null;
    markDismissed();
  }, []);

  const canShowBanner =
    !isInstalled &&
    !dismissed &&
    enoughVisits &&
    (!!deferredPrompt || isIOS);

  return {
    deferredPrompt,
    isIOS,
    isInstalled,
    canShowBanner,
    triggerInstall,
    dismiss,
  };
}
