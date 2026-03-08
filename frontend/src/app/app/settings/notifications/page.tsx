"use client";

// ─── Settings — Notifications (Push Toggle, Score Alerts, Frequency) ────────

import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useAnalytics } from "@/hooks/use-analytics";
import {
    deletePushSubscription,
    getUserPreferences,
    savePushSubscription,
    setUserPreferences,
} from "@/lib/api";
import { NOTIFICATION_FREQUENCY_OPTIONS } from "@/lib/constants";
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
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { NotificationFrequency } from "@/lib/types";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, BellOff, BellRing, Clock } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

export default function NotificationSettingsPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();

  // ─── Push notification state ────────────────────────────────────────────────
  const [pushEnabled, setPushEnabled] = useState(false);
  const [pushSupported, setPushSupported] = useState(false);
  const [pushPermission, setPushPermission] = useState<
    NotificationPermission | "unsupported"
  >("unsupported");
  const [togglingPush, setTogglingPush] = useState(false);

  // ─── Score change preference state ──────────────────────────────────────────
  const [scoreChanges, setScoreChanges] = useState(true);
  const [frequency, setFrequency] = useState<NotificationFrequency>("immediate");
  const [savingPrefs, setSavingPrefs] = useState(false);
  const [dirty, setDirty] = useState(false);

  // ─── Load user preferences ─────────────────────────────────────────────────
  const { data: prefs, isLoading } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  // ─── Populate from fetched prefs ────────────────────────────────────────────
  useEffect(() => {
    if (prefs) {
      setScoreChanges(prefs.notification_score_changes ?? true);
      setFrequency(prefs.notification_frequency ?? "immediate");
    }
  }, [prefs]);

  // ─── Check push notification status ─────────────────────────────────────────
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

  // ─── Push toggle handlers ──────────────────────────────────────────────────
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

  // ─── Save notification preferences ─────────────────────────────────────────
  async function handleSavePreferences() {
    setSavingPrefs(true);
    const result = await setUserPreferences(supabase, {
      p_country: prefs?.country ?? "PL",
      p_preferred_language: prefs?.preferred_language ?? "en",
      p_notification_score_changes: scoreChanges,
      p_notification_frequency: frequency,
    });
    setSavingPrefs(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    setDirty(false);
    track("notification_preferences_updated", {
      score_changes: scoreChanges,
      frequency,
    });
    showToast({ type: "success", messageKey: "notifications.preferencesSaved" });
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings", href: "/app/settings" },
          { labelKey: "settings.tabNotifications" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.tabNotifications")}
      </h1>

      {/* ─── Push Notifications ──────────────────────────────────────────── */}
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

      {/* ─── Score Change Alerts ──────────────────────────────────────────── */}
      <section className="card" data-testid="score-changes-section">
        <div className="flex items-start gap-3">
          <BellRing
            size={20}
            className="mt-0.5 shrink-0 text-brand"
            aria-hidden="true"
          />
          <div className="flex-1">
            <h2 className="text-sm font-semibold text-foreground-secondary lg:text-base">
              {t("notifications.scoreChangesTitle")}
            </h2>
            <p className="mt-1 text-sm text-foreground-secondary">
              {t("notifications.scoreChangesDescription")}
            </p>
          </div>
          <label className="relative inline-flex cursor-pointer items-center">
            <input
              type="checkbox"
              checked={scoreChanges}
              onChange={(e) => {
                setScoreChanges(e.target.checked);
                setDirty(true);
              }}
              className="peer sr-only"
              data-testid="score-changes-toggle"
            />
            <div className="peer h-6 w-11 rounded-full bg-surface-muted after:absolute after:left-[2px] after:top-[2px] after:h-5 after:w-5 after:rounded-full after:border after:border-strong after:bg-white after:transition-all after:content-[''] peer-checked:bg-brand peer-checked:after:translate-x-full peer-checked:after:border-white peer-focus-visible:outline-none peer-focus-visible:ring-2 peer-focus-visible:ring-brand/40" />
          </label>
        </div>
      </section>

      {/* ─── Notification Frequency ──────────────────────────────────────── */}
      <section className="card" data-testid="frequency-section">
        <div className="flex items-center gap-2 mb-3">
          <Clock
            size={20}
            className="shrink-0 text-brand"
            aria-hidden="true"
          />
          <h2 className="text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("notifications.frequencyTitle")}
          </h2>
        </div>
        <p className="mb-4 text-sm text-foreground-secondary">
          {t("notifications.frequencyDescription")}
        </p>
        <div className="space-y-2">
          {NOTIFICATION_FREQUENCY_OPTIONS.map((option) => (
            <label
              key={option.value}
              className={`flex cursor-pointer items-center gap-3 rounded-lg border p-3 transition-colors ${
                frequency === option.value
                  ? "border-brand bg-brand-subtle"
                  : "border-border hover:bg-surface-hover"
              }`}
              data-testid={`frequency-option-${option.value}`}
            >
              <input
                type="radio"
                name="notification-frequency"
                value={option.value}
                checked={frequency === option.value}
                onChange={() => {
                  setFrequency(option.value as NotificationFrequency);
                  setDirty(true);
                }}
                className="sr-only"
              />
              <div
                className={`h-4 w-4 shrink-0 rounded-full border-2 ${
                  frequency === option.value
                    ? "border-brand bg-brand"
                    : "border-strong"
                }`}
              >
                {frequency === option.value && (
                  <div className="m-0.5 h-2 w-2 rounded-full bg-white" />
                )}
              </div>
              <div>
                <p className="text-sm font-medium text-foreground">
                  {t(option.labelKey)}
                </p>
                <p className="text-xs text-foreground-secondary">
                  {t(option.descKey)}
                </p>
              </div>
            </label>
          ))}
        </div>
      </section>

      {/* ─── Save button ──────────────────────────────────────────────────── */}
      {dirty && (
        <div className="flex justify-end">
          <button
            type="button"
            onClick={handleSavePreferences}
            disabled={savingPrefs}
            className="rounded-lg bg-brand px-6 py-2.5 text-sm font-medium text-white transition-colors hover:bg-brand-hover disabled:opacity-50 disabled:cursor-not-allowed"
            data-testid="save-notification-prefs"
          >
            {savingPrefs ? t("common.loading") : t("common.save")}
          </button>
        </div>
      )}
    </div>
  );
}
