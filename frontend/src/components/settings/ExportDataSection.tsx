"use client";

// ─── Export Data section — GDPR Art. 20 data portability ───────────────────

import { useAnalytics } from "@/hooks/use-analytics";
import { exportUserData } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import { FileDown } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

export function ExportDataSection() {
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
        `tryvit-export-${Date.now()}.json`,
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
