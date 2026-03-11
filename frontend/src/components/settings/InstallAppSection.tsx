"use client";

// ─── Install App section — PWA install prompt ──────────────────────────────

import { useAnalytics } from "@/hooks/use-analytics";
import { useInstallPrompt } from "@/hooks/use-install-prompt";
import { useTranslation } from "@/lib/i18n";
import { Download, Share } from "lucide-react";

export function InstallAppSection() {
  const { t } = useTranslation();
  const { track } = useAnalytics();
  const { isIOS, isInstalled, triggerInstall, deferredPrompt } =
    useInstallPrompt();

  // Already installed — no need to show
  if (isInstalled) return null;

  const handleInstall = async () => {
    track("pwa_install_prompted");
    const outcome = await triggerInstall();
    if (outcome === "accepted") {
      track("pwa_install_accepted");
    } else if (outcome === "dismissed") {
      track("pwa_install_dismissed");
    }
  };

  return (
    <section className="card" data-testid="install-app-section">
      <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
        {t("pwa.installTitle")}
      </h2>
      <p className="mb-3 text-sm text-foreground-secondary">
        {t("pwa.installDescription")}
      </p>
      {isIOS ? (
        <div className="flex items-start gap-2 rounded-lg bg-warning-bg p-3 text-sm text-warning-text">
          <Share
            size={16}
            className="mt-0.5 shrink-0"
            aria-hidden="true"
          />
          <p>{t("pwa.iosInstallHint")}</p>
        </div>
      ) : (
        <button
          type="button"
          onClick={handleInstall}
          disabled={!deferredPrompt}
          className="inline-flex items-center gap-2 rounded-lg border border-brand/30 px-4 py-2 text-sm font-medium text-brand transition-colors hover:bg-brand-subtle disabled:opacity-50 disabled:cursor-not-allowed"
          data-testid="settings-install-button"
        >
          <Download size={14} aria-hidden="true" />
          {t("common.install")}
        </button>
      )}
    </section>
  );
}
