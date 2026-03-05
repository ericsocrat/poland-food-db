"use client";

// ─── Settings — Privacy & Data (Offline Cache, GDPR Export) ─────────────────

import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ExportDataSection } from "@/components/settings/ExportDataSection";
import { useAnalytics } from "@/hooks/use-analytics";
import { clearAllCaches, getCachedProductCount } from "@/lib/cache-manager";
import { useTranslation } from "@/lib/i18n";
import { showToast } from "@/lib/toast";
import { Trash2 } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

export default function PrivacySettingsPage() {
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const [cachedCount, setCachedCount] = useState(0);
  const [clearingCache, setClearingCache] = useState(false);

  // Fetch offline cache count
  useEffect(() => {
    getCachedProductCount()
      .then(setCachedCount)
      .catch(() => setCachedCount(0));
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
