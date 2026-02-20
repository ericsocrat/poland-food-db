"use client";

import { useEffect, useState } from "react";
import { useTranslation } from "@/lib/i18n";

interface BeforeInstallPromptEvent extends Event {
  prompt(): Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

/* ── Constants ─────────────────────────────────────────────────────────────── */
const STORAGE_KEY = "pwa-install-dismissed-at";
const DISMISS_COOLDOWN_MS = 14 * 24 * 60 * 60 * 1000; // 14 days
const SHOW_DELAY_MS = 30_000; // 30 seconds after page load

/** Returns true if the dismiss cooldown has NOT yet expired. */
function isDismissCooldownActive(): boolean {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return false;
    return Date.now() - Number(raw) < DISMISS_COOLDOWN_MS;
  } catch {
    return false;
  }
}

/** Detect iOS Safari (no `beforeinstallprompt`, manual instructions needed). */
function isIOS(): boolean {
  if (typeof navigator === "undefined") return false;
  return (
    /iPad|iPhone|iPod/.test(navigator.userAgent) ||
    (navigator.userAgent.includes("Mac") && "ontouchend" in document)
  );
}

export function InstallPrompt() {
  const { t } = useTranslation();
  const [deferredPrompt, setDeferredPrompt] =
    useState<BeforeInstallPromptEvent | null>(null);
  const [showIOSTip, setShowIOSTip] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    // Already installed as standalone — nothing to show
    if (window.matchMedia("(display-mode: standalone)").matches) return;

    // Dismiss cooldown still active
    if (isDismissCooldownActive()) return;

    // ── Android / Desktop: listen for the native prompt ──────────────────
    const handler = (e: Event) => {
      e.preventDefault();
      // Delay so the prompt isn't intrusive on first visit
      setTimeout(() => setDeferredPrompt(e as BeforeInstallPromptEvent), SHOW_DELAY_MS);
    };

    window.addEventListener("beforeinstallprompt", handler);

    // ── iOS: show manual instructions after a delay ──────────────────────
    let iosTimer: ReturnType<typeof setTimeout> | undefined;
    if (isIOS()) {
      iosTimer = setTimeout(() => setShowIOSTip(true), SHOW_DELAY_MS);
    }

    return () => {
      window.removeEventListener("beforeinstallprompt", handler);
      if (iosTimer) clearTimeout(iosTimer);
    };
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;
    await deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") {
      setDeferredPrompt(null);
    }
  };

  const handleDismiss = () => {
    setDismissed(true);
    setDeferredPrompt(null);
    setShowIOSTip(false);
    try {
      localStorage.setItem(STORAGE_KEY, String(Date.now()));
    } catch {
      /* storage full — ignore */
    }
  };

  // Nothing to show
  const showNative = !!deferredPrompt && !dismissed;
  const showIOS = showIOSTip && !dismissed;
  if (!showNative && !showIOS) return null;

  return (
    <div className="fixed bottom-20 left-4 right-4 z-50 mx-auto max-w-sm animate-[slideUp_0.3s_ease-out] rounded-xl border border bg-surface p-4 shadow-lg sm:left-auto sm:right-4 sm:max-w-xs">
      <div className="flex items-start gap-3">
        <span className="text-2xl" aria-hidden="true">📲</span>
        <div className="flex-1">
          <p className="text-sm font-semibold text-foreground">
            {t("pwa.installTitle")}
          </p>
          <p className="mt-0.5 text-xs text-foreground-secondary">
            {showIOS ? t("pwa.iosInstallHint") : t("pwa.installDescription")}
          </p>
        </div>
        <button
          onClick={handleDismiss}
          className="text-foreground-muted hover:text-foreground-secondary"
          aria-label={t("pwa.dismissInstall")}
        >
          ✕
        </button>
      </div>

      {/* Native install button (Android / Desktop) */}
      {showNative && (
        <button
          onClick={handleInstall}
          className="btn-primary mt-3 w-full text-sm"
        >
          {t("common.install")}
        </button>
      )}
    </div>
  );
}
