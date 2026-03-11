"use client";

/**
 * NotificationPrompt — shown after the user's first watchlist add.
 * Prompts them to enable push notifications for score changes.
 * Dismissible; only shown when permission is "default" (not yet asked).
 */

import { useState, useCallback } from "react";
import { Bell, X } from "lucide-react";
import { Button } from "@/components/common/Button";
import { Icon } from "@/components/common/Icon";
import { useTranslation } from "@/lib/i18n";
import { useAnalytics } from "@/hooks/use-analytics";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import { savePushSubscription } from "@/lib/api";
import {
  isPushSupported,
  getNotificationPermission,
  requestNotificationPermission,
  subscribeToPush,
  extractSubscriptionData,
} from "@/lib/push-manager";

interface NotificationPromptProps {
  /** Called when prompt is dismissed (either accepted or declined) */
  onDismiss?: () => void;
}

export function NotificationPrompt({
  onDismiss,
}: Readonly<NotificationPromptProps>) {
  const { t } = useTranslation();
  const { track } = useAnalytics();
  const [enabling, setEnabling] = useState(false);

  const handleDismiss = useCallback(() => {
    track("push_notification_dismissed");
    onDismiss?.();
  }, [track, onDismiss]);

  // Don't render if push isn't supported or permission already decided
  if (!isPushSupported() || getNotificationPermission() !== "default") {
    return null;
  }

  const handleEnable = async () => {
    setEnabling(true);
    try {
      const permission = await requestNotificationPermission();
      if (permission !== "granted") {
        track("push_notification_denied");
        onDismiss?.();
        return;
      }

      const vapidKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
      if (!vapidKey) {
        console.error("VAPID public key not configured");
        onDismiss?.();
        return;
      }

      const subscription = await subscribeToPush(vapidKey);
      if (!subscription) {
        showToast({ type: "error", messageKey: "common.error" });
        onDismiss?.();
        return;
      }

      // Save subscription to backend
      const subData = extractSubscriptionData(subscription);
      if (subData) {
        const supabase = createClient();
        await savePushSubscription(
          supabase,
          subData.endpoint,
          subData.p256dh,
          subData.auth,
        );
      }

      track("push_notification_enabled");
      showToast({ type: "success", messageKey: "notifications.enabled" });
    } catch {
      showToast({ type: "error", messageKey: "common.error" });
    } finally {
      setEnabling(false);
      onDismiss?.();
    }
  };

  return (
    <div
      role="alert"
      className="mt-3 flex items-start gap-3 rounded-lg border border-brand/20 bg-brand-subtle p-3"
      data-testid="notification-prompt"
    >
      <div className="shrink-0 mt-0.5">
        <Icon icon={Bell} size="sm" className="text-brand" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-foreground">
          {t("notifications.promptTitle")}
        </p>
        <p className="mt-0.5 text-xs text-foreground-secondary">
          {t("notifications.promptDescription")}
        </p>
        <Button
          size="sm"
          onClick={handleEnable}
          disabled={enabling}
          className="mt-2"
          data-testid="enable-notifications-button"
        >
          {enabling ? t("common.loading") : t("notifications.enable")}
        </Button>
      </div>
      <button
        onClick={handleDismiss}
        className="shrink-0 text-foreground-secondary hover:text-foreground transition-colors"
        aria-label={t("common.dismiss")}
        data-testid="dismiss-notification-prompt"
      >
        <Icon icon={X} size="sm" />
      </button>
    </div>
  );
}
