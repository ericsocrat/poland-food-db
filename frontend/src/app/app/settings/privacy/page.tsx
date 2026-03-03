"use client";

// ─── Settings — Privacy & Data (Push, Offline Cache, GDPR Export) ──────────

import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ExportDataSection } from "@/components/settings/ExportDataSection";
import { useAnalytics } from "@/hooks/use-analytics";
import {
    deletePushSubscription,
    savePushSubscription,
} from "@/lib/api";
import { clearAllCaches, getCachedProductCount } from "@/lib/cache-manager";
import { useTranslation } from "@/lib/i18n";
import {
    extractSubscriptionData,
    getCurrentPushSubscription,
    getNotificationPermission,
    isPushSupported,
    requestNotificationPermission,
    subscribeToPush,
    unsubscribeFromPush,
} from "@/lib/push-manager";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import { Bell, BellOff, Trash2 } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

export default function PrivacySettingsPage() {
  const supabase = createClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const [cachedCount, setCachedCount] = useState(0);
  const [clearingCache, setClearingCache] = useState(false);
  const [pushEnabled, setPushEnabled] = useState(false);
  const [pushSupported, setPushSupported] = useState(false);
  const [pushPermission, setPushPermission] = useState<
    NotificationPermission | "unsupported"
  >("unsupported");
  const [togglingPush, setTogglingPush] = useState(false);

  // Fetch offline cache count
  useEffect(() => {
    getCachedProductCount()
      .then(setCachedCount)
      .catch(() => setCachedCount(0));
  }, []);

  // Check push notification status
  useEffect(() => {
    const supported = isPushSupported();
    setPushSupported(supported);
    setPushPermission(getNotificationPermission());
    if (supported) {
      getCurrentPushSubscription()
        .then((sub) => setPushEnabled(!!sub))
        .catch(() => setPushEnabled(false));
    }
  }, []);

  const handleClearCache = useCallback(async () => {
    setClearingCache(true);
    try {
      await clearAllCaches();
      setCachedCount(0);
      track("offline_cache_cleared");
      showToast({ type: "success", messageKey: "settings.cacheCleared" });
    } catch {
      showToast({ type: "error", messageKey: "common.error" });
    } finally {
      setClearingCache(false);
    }
  }, [track]);

  /** Unsubscribe from push */
  const disablePush = useCallback(async () => {
    const sub = await getCurrentPushSubscription();
    if (sub) {
      const subData = extractSubscriptionData(sub);
      if (subData) {
        await deletePushSubscription(supabase, subData.endpoint);
      }
      await unsubscribeFromPush();
    }
    setPushEnabled(false);
    track("push_notification_disabled");
    showToast({ type: "success", messageKey: "notifications.disabled" });
  }, [supabase, track]);

  /** Subscribe to push */
  const enablePush = useCallback(async () => {
    const permission = await requestNotificationPermission();
    setPushPermission(permission);
    if (permission !== "granted") {
      showToast({
        type: "error",
        messageKey: "notifications.permissionDenied",
      });
      return;
    }

    const vapidKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
    if (!vapidKey) {
      showToast({ type: "error", messageKey: "common.error" });
      return;
    }

    const subscription = await subscribeToPush(vapidKey);
    if (!subscription) {
      showToast({ type: "error", messageKey: "common.error" });
      return;
    }

    const subData = extractSubscriptionData(subscription);
    if (subData) {
      await savePushSubscription(
        supabase,
        subData.endpoint,
        subData.p256dh,
        subData.auth,
      );
    }

    setPushEnabled(true);
    track("push_notification_enabled");
    showToast({ type: "success", messageKey: "notifications.enabled" });
  }, [supabase, track]);

  const handleTogglePush = useCallback(async () => {
    setTogglingPush(true);
    try {
      if (pushEnabled) {
        await disablePush();
      } else {
        await enablePush();
      }
    } catch {
      showToast({ type: "error", messageKey: "common.error" });
    } finally {
      setTogglingPush(false);
    }
  }, [pushEnabled, disablePush, enablePush]);

  return (
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings", href: "/app/settings" },
          { labelKey: "settings.tabPrivacy" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.tabPrivacy")}
      </h1>

      {/* Push Notifications */}
      {pushSupported && (
        <section className="card" data-testid="push-notifications-section">
          <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("notifications.title")}
          </h2>
          <p className="mb-3 text-sm text-foreground-secondary">
            {t("notifications.settingsDescription")}
          </p>
          {pushPermission === "denied" ? (
            <p
              className="text-sm text-amber-600"
              data-testid="push-denied-message"
            >
              {t("notifications.blockedByBrowser")}
            </p>
          ) : (
            <button
              type="button"
              onClick={handleTogglePush}
              disabled={togglingPush}
              className={`inline-flex items-center gap-2 rounded-lg border px-4 py-2 text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                pushEnabled
                  ? "border-red-200 text-red-600 hover:bg-red-50"
                  : "border-brand/30 text-brand hover:bg-brand-subtle"
              }`}
              data-testid="push-toggle-button"
            >
              {pushEnabled ? (
                <BellOff size={14} aria-hidden="true" />
              ) : (
                <Bell size={14} aria-hidden="true" />
              )}
              {togglingPush && t("common.loading")}
              {!togglingPush && pushEnabled && t("notifications.disable")}
              {!togglingPush && !pushEnabled && t("notifications.enable")}
            </button>
          )}
        </section>
      )}

      {/* Offline Cache */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.offlineCache")}
        </h2>
        <p className="mb-3 text-sm text-foreground-secondary">
          {t("settings.offlineCacheDescription", { count: cachedCount })}
        </p>
        <button
          type="button"
          onClick={handleClearCache}
          disabled={clearingCache || cachedCount === 0}
          className="inline-flex items-center gap-2 rounded-lg border border-amber-200 px-4 py-2 text-sm font-medium text-amber-700 transition-colors hover:bg-amber-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Trash2 size={14} aria-hidden="true" />
          {clearingCache ? t("common.loading") : t("settings.clearCache")}
        </button>
      </section>

      {/* Export Data (GDPR Art. 20) */}
      <ExportDataSection />
    </div>
  );
}
