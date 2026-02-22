"use client";

import { X } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { useAnalytics } from "@/hooks/use-analytics";
import { useInstallPrompt } from "@/hooks/use-install-prompt";

export function InstallPrompt() {
  const { t } = useTranslation();
  const { track } = useAnalytics();
  const { canShowBanner, isIOS, triggerInstall, dismiss } =
    useInstallPrompt();

  if (!canShowBanner) return null;

  const handleInstall = async () => {
    track("pwa_install_prompted");
    const outcome = await triggerInstall();
    if (outcome === "accepted") {
      track("pwa_install_accepted");
    } else if (outcome === "dismissed") {
      track("pwa_install_dismissed");
    }
  };

  const handleDismiss = () => {
    track("pwa_install_dismissed");
    dismiss();
  };

  return (
    <div
      className="fixed bottom-20 left-4 right-4 z-50 mx-auto max-w-sm animate-[slideUp_0.3s_ease-out] rounded-xl border border-border bg-surface p-4 shadow-lg sm:left-auto sm:right-4 sm:max-w-xs"
      data-testid="install-prompt"
    >
      <div className="flex items-start gap-3">
        <span className="text-2xl" aria-hidden="true">
          📲
        </span>
        <div className="flex-1">
          <p className="text-sm font-semibold text-foreground">
            {t("pwa.installTitle")}
          </p>
          <p className="mt-0.5 text-xs text-foreground-secondary">
            {isIOS ? t("pwa.iosInstallHint") : t("pwa.installDescription")}
          </p>
        </div>
        <button
          onClick={handleDismiss}
          className="text-foreground-muted hover:text-foreground-secondary"
          aria-label={t("pwa.dismissInstall")}
          data-testid="dismiss-install-prompt"
        >
          <X size={16} aria-hidden="true" />
        </button>
      </div>

      {/* Native install button (Android / Desktop) */}
      {!isIOS && (
        <button
          onClick={handleInstall}
          className="btn-primary mt-3 w-full text-sm"
          data-testid="install-button"
        >
          {t("common.install")}
        </button>
      )}
    </div>
  );
}
