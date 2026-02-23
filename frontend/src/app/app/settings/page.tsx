"use client";

// ─── Settings page — view/edit preferences, logout ──────────────────────────

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import {
  getUserPreferences,
  setUserPreferences,
  savePushSubscription,
  deletePushSubscription,
  exportUserData,
  deleteUserData,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  ChevronDown,
  Copy,
  Check,
  Trash2,
  Bell,
  BellOff,
  Download,
  Share,
  FileDown,
} from "lucide-react";
import {
  COUNTRIES,
  COUNTRY_DEFAULT_LANGUAGES,
  DIET_OPTIONS,
  ALLERGEN_TAGS,
  ALLERGEN_PRESETS,
  getLanguagesForCountry,
} from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { HealthProfileSection } from "@/components/settings/HealthProfileSection";
import { ThemeToggle } from "@/components/settings/ThemeToggle";
import { useAnalytics } from "@/hooks/use-analytics";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useTranslation } from "@/lib/i18n";
import {
  useLanguageStore,
  type SupportedLanguage,
} from "@/stores/language-store";
import { clearAllCaches, getCachedProductCount } from "@/lib/cache-manager";
import {
  isPushSupported,
  getNotificationPermission,
  requestNotificationPermission,
  subscribeToPush,
  unsubscribeFromPush,
  getCurrentPushSubscription,
  extractSubscriptionData,
} from "@/lib/push-manager";
import { DeleteAccountDialog } from "@/components/settings/DeleteAccountDialog";
import { useInstallPrompt } from "@/hooks/use-install-prompt";

/* ── Install App section (extracted to avoid hook-ordering issues) ────────── */
function InstallAppSection() {
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
        <div className="flex items-start gap-2 rounded-lg bg-amber-50 p-3 text-sm text-amber-800">
          <Share
            size={16}
            className="mt-0.5 flex-shrink-0"
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

/* ── Export Data section (GDPR Art. 20) ──────────────────────────────────── */
function ExportDataSection() {
  const { t } = useTranslation();
  const { track } = useAnalytics();
  const supabase = createClient();
  const [exporting, setExporting] = useState(false);
  const [cooldownMin, setCooldownMin] = useState(0);

  useEffect(() => {
    // Dynamic import to avoid SSR issues
    import("@/lib/download").then(({ getExportCooldownRemaining }) => {
      const ms = getExportCooldownRemaining();
      setCooldownMin(Math.ceil(ms / 60_000));
    });
  }, []);

  const handleExport = useCallback(async () => {
    setExporting(true);
    try {
      const result = await exportUserData(supabase);
      if (!result.ok) {
        showToast({ type: "error", messageKey: "settings.exportError" });
        return;
      }

      const { downloadJson, setExportTimestamp } =
        await import("@/lib/download");
      const { size } = downloadJson(
        result.data,
        `fooddb-export-${Date.now()}.json`,
      );
      setExportTimestamp();
      setCooldownMin(60);

      const sizeStr =
        size > 1024 * 1024
          ? `${(size / (1024 * 1024)).toFixed(1)} MB`
          : `${Math.round(size / 1024)} KB`;

      track("user_data_exported");
      showToast({
        type: "success",
        message: t("settings.exportSuccess", { size: sizeStr }),
      });
    } catch {
      showToast({ type: "error", messageKey: "settings.exportError" });
    } finally {
      setExporting(false);
    }
  }, [supabase, track, t]);

  return (
    <section className="card" data-testid="export-data-section">
      <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
        {t("settings.exportData")}
      </h2>
      <p className="mb-3 text-sm text-foreground-secondary">
        {t("settings.exportDataDescription")}
      </p>
      <button
        type="button"
        onClick={handleExport}
        disabled={exporting || cooldownMin > 0}
        className="inline-flex items-center gap-2 rounded-lg border border-brand/30 px-4 py-2 text-sm font-medium text-brand transition-colors hover:bg-brand-subtle disabled:opacity-50 disabled:cursor-not-allowed"
        data-testid="export-data-button"
      >
        <FileDown size={14} aria-hidden="true" />
        {exporting && t("settings.exportInProgress")}
        {!exporting &&
          cooldownMin > 0 &&
          t("settings.exportCooldown", { minutes: cooldownMin })}
        {!exporting && cooldownMin <= 0 && t("settings.exportData")}
      </button>
    </section>
  );
}

export default function SettingsPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const setStoreLanguage = useLanguageStore((s) => s.setLanguage);

  const { data: prefs, isLoading } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  const [country, setCountry] = useState("");
  const [language, setLanguage] = useState<SupportedLanguage>("en");
  const [diet, setDiet] = useState("none");
  const [allergens, setAllergens] = useState<string[]>([]);
  const [strictDiet, setStrictDiet] = useState(false);
  const [strictAllergen, setStrictAllergen] = useState(false);
  const [treatMayContain, setTreatMayContain] = useState(false);
  const [saving, setSaving] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [email, setEmail] = useState<string | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [copied, setCopied] = useState(false);
  const [cachedCount, setCachedCount] = useState(0);
  const [clearingCache, setClearingCache] = useState(false);
  const [pushEnabled, setPushEnabled] = useState(false);
  const [pushSupported, setPushSupported] = useState(false);
  const [pushPermission, setPushPermission] = useState<
    NotificationPermission | "unsupported"
  >("unsupported");
  const [togglingPush, setTogglingPush] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);

  // Fetch user email from auth session
  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setEmail(data.user?.email ?? null);
    });
  }, [supabase]);

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

  /** Unsubscribe from push — extracted to reduce cognitive complexity. */
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

  /** Subscribe to push — extracted to reduce cognitive complexity. */
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

  const handleCopyUserId = useCallback(async () => {
    if (!prefs?.user_id) return;
    await navigator.clipboard.writeText(prefs.user_id);
    setCopied(true);
    showToast({ type: "success", messageKey: "settings.copiedToClipboard" });
    setTimeout(() => setCopied(false), 2000);
  }, [prefs?.user_id]);

  // Populate from fetched prefs
  useEffect(() => {
    if (prefs) {
      setCountry(prefs.country ?? "");
      setLanguage((prefs.preferred_language ?? "en") as SupportedLanguage);
      setDiet(prefs.diet_preference ?? "none");
      setAllergens(prefs.avoid_allergens ?? []);
      setStrictDiet(prefs.strict_diet);
      setStrictAllergen(prefs.strict_allergen);
      setTreatMayContain(prefs.treat_may_contain_as_unsafe);
    }
  }, [prefs]);

  function markDirty() {
    setDirty(true);
  }

  function toggleAllergen(tag: string) {
    setAllergens((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag],
    );
    markDirty();
  }

  function togglePreset(tags: readonly string[], allSelected: boolean) {
    setAllergens((prev) => {
      const newSet = new Set(prev);
      if (allSelected) {
        tags.forEach((tag) => newSet.delete(tag));
      } else {
        tags.forEach((tag) => newSet.add(tag));
      }
      return Array.from(newSet);
    });
    markDirty();
  }

  async function handleSave() {
    setSaving(true);
    const result = await setUserPreferences(supabase, {
      p_country: country,
      p_preferred_language: language,
      p_diet_preference: diet,
      p_avoid_allergens: allergens.length > 0 ? allergens : undefined,
      p_strict_diet: strictDiet,
      p_strict_allergen: strictAllergen,
      p_treat_may_contain_as_unsafe: treatMayContain,
    });
    setSaving(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    // Sync the language store so the entire UI re-renders in the new language
    setStoreLanguage(language);

    // Invalidate all product-related caches since country/diet/language may have changed
    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    await queryClient.invalidateQueries({ queryKey: ["search"] });
    await queryClient.invalidateQueries({ queryKey: ["category-listing"] });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.categoryOverview,
    });

    setDirty(false);
    track("preferences_updated", {
      country,
      language,
      diet,
      allergen_count: allergens.length,
    });
    showToast({ type: "success", messageKey: "settings.preferencesSaved" });
  }

  async function handleLogout() {
    await supabase.auth.signOut();
    queryClient.clear();
    router.push("/auth/login");
    router.refresh();
  }

  async function handleDeleteAccount() {
    setDeleting(true);
    try {
      const result = await deleteUserData(supabase);
      if (!result.ok) {
        showToast({ type: "error", messageKey: "settings.deleteAccountError" });
        setDeleting(false);
        return;
      }
      track("account_deleted");
      showToast({
        type: "success",
        messageKey: "settings.deleteAccountSuccess",
      });
      queryClient.clear();
      router.push("/");
      router.refresh();
    } catch {
      showToast({ type: "error", messageKey: "settings.deleteAccountError" });
      setDeleting(false);
    }
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="max-w-2xl space-y-6 lg:space-y-8">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.title")}
      </h1>

      {/* Country */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.country")}
        </h2>
        <div className="grid grid-cols-2 gap-2">
          {COUNTRIES.map((c) => (
            <button
              key={c.code}
              onClick={() => {
                setCountry(c.code);
                // Auto-switch language to new country's default
                const newDefault = (COUNTRY_DEFAULT_LANGUAGES[c.code] ??
                  "en") as SupportedLanguage;
                setLanguage(newDefault);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-3 text-center transition-colors ${
                country === c.code
                  ? "border-brand bg-brand-subtle text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              <span className="text-2xl">{c.flag}</span>
              <p className="mt-1 text-sm font-medium">{c.native}</p>
            </button>
          ))}
        </div>
      </section>

      {/* Language — filtered by selected country (native + English) */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.language")}
        </h2>
        <div className="grid grid-cols-2 gap-2">
          {getLanguagesForCountry(country).map((lang) => (
            <button
              key={lang.code}
              onClick={() => {
                setLanguage(lang.code as SupportedLanguage);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-3 text-center transition-colors ${
                language === lang.code
                  ? "border-brand bg-brand-subtle text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              <span className="text-2xl">{lang.flag}</span>
              <p className="mt-1 text-sm font-medium">{lang.native}</p>
            </button>
          ))}
        </div>
      </section>

      {/* Theme */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.theme")}
        </h2>
        <ThemeToggle />
      </section>

      {/* Diet */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.dietPreference")}
        </h2>
        <div className="grid grid-cols-3 gap-2">
          {DIET_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => {
                setDiet(opt.value);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-2 text-sm transition-colors ${
                diet === opt.value
                  ? "border-brand bg-brand-subtle font-medium text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
        {diet !== "none" && (
          <label className="mt-3 flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={strictDiet}
              onChange={(e) => {
                setStrictDiet(e.target.checked);
                markDirty();
              }}
              className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
            />
            <span className="text-sm text-foreground-secondary">
              {t("settings.strictDiet")}
            </span>
          </label>
        )}
      </section>

      {/* Allergens */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.allergensToAvoid")}
        </h2>

        {/* Quick presets */}
        <div
          className="mb-3 flex flex-wrap gap-2"
          data-testid="allergen-presets"
        >
          {ALLERGEN_PRESETS.map((preset) => {
            const allSelected = preset.tags.every((tag) =>
              allergens.includes(tag),
            );
            return (
              <button
                key={preset.key}
                onClick={() => togglePreset(preset.tags, allSelected)}
                className={`rounded-full border px-3 py-1.5 text-xs font-medium transition-colors ${
                  allSelected
                    ? "border-brand bg-brand-subtle text-brand"
                    : "border-dashed border-foreground-muted text-foreground-secondary hover:border-strong"
                }`}
              >
                {t(preset.labelKey)}
              </button>
            );
          })}
        </div>

        <div className="flex flex-wrap gap-2">
          {ALLERGEN_TAGS.map((a) => (
            <button
              key={a.tag}
              onClick={() => toggleAllergen(a.tag)}
              className={`rounded-full border px-3 py-1.5 text-sm transition-colors ${
                allergens.includes(a.tag)
                  ? "border-red-300 bg-red-50 text-red-700"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              {a.label}
            </button>
          ))}
        </div>
        {allergens.length > 0 && (
          <div className="mt-3 space-y-2">
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={strictAllergen}
                onChange={(e) => {
                  setStrictAllergen(e.target.checked);
                  markDirty();
                }}
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("settings.strictAllergen")}
              </span>
            </label>
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={treatMayContain}
                onChange={(e) => {
                  setTreatMayContain(e.target.checked);
                  markDirty();
                }}
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("settings.treatMayContain")}
              </span>
            </label>
          </div>
        )}
      </section>

      {/* Health Profiles */}
      <HealthProfileSection />

      {/* Save button */}
      {dirty && (
        <button
          onClick={handleSave}
          disabled={saving}
          className="btn-primary w-full"
        >
          {saving ? t("common.saving") : t("settings.saveChanges")}
        </button>
      )}

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

      {/* Install App */}
      <InstallAppSection />

      {/* Export Data (GDPR Art. 20) */}
      <ExportDataSection />

      {/* Account section */}
      <section className="card border-red-100">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.account")}
        </h2>

        {/* Primary identifier: email */}
        {email && (
          <p className="mb-3 text-sm text-foreground-secondary">{email}</p>
        )}

        {/* Expandable account details with masked UUID + copy */}
        {prefs?.user_id && (
          <div className="mb-3">
            <button
              type="button"
              onClick={() => setShowDetails((prev) => !prev)}
              className="flex items-center gap-1 text-xs text-foreground-secondary hover:text-foreground-primary transition-colors"
              aria-expanded={showDetails}
            >
              <ChevronDown
                size={14}
                aria-hidden="true"
                className={`transition-transform ${showDetails ? "rotate-180" : ""}`}
              />
              {t("settings.accountDetails")}
            </button>

            {showDetails && (
              <div
                className="mt-2 flex items-center gap-2"
                data-testid="account-details"
              >
                <code className="text-xs text-foreground-secondary">
                  {prefs.user_id.slice(0, 4)}…{prefs.user_id.slice(-4)}
                </code>
                <button
                  type="button"
                  onClick={handleCopyUserId}
                  className="flex items-center gap-1 rounded border border-gray-200 px-2 py-0.5 text-xs text-foreground-secondary hover:bg-gray-50 transition-colors"
                  aria-label={t("settings.copyUserId")}
                >
                  {copied ? (
                    <Check size={12} aria-hidden="true" />
                  ) : (
                    <Copy size={12} aria-hidden="true" />
                  )}
                  {t("settings.copyUserId")}
                </button>
              </div>
            )}
          </div>
        )}

        <button
          onClick={handleLogout}
          className="w-full rounded-lg border border-red-200 px-4 py-2 text-sm font-medium text-red-600 transition-colors hover:bg-red-50"
        >
          {t("settings.signOut")}
        </button>

        <button
          type="button"
          onClick={() => setDeleteDialogOpen(true)}
          className="mt-3 w-full rounded-lg bg-error px-4 py-2 text-sm font-medium text-foreground-inverse transition-colors hover:bg-error/90"
          data-testid="delete-account-button"
        >
          {t("settings.deleteAccount")}
        </button>

        <DeleteAccountDialog
          open={deleteDialogOpen}
          loading={deleting}
          onConfirm={handleDeleteAccount}
          onCancel={() => setDeleteDialogOpen(false)}
        />
      </section>
    </div>
  );
}
