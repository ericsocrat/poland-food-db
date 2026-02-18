"use client";

// ─── CompareFloatingButton — FAB showing compare selection count ────────────
// Appears when ≥2 products are selected. Click navigates to /app/compare.

import { useRouter } from "next/navigation";
import { useCompareStore } from "@/stores/compare-store";
import { useTranslation } from "@/lib/i18n";
import { Scale } from "lucide-react";

export function CompareFloatingButton() {
  const { t } = useTranslation();
  const count = useCompareStore((s) => s.count());
  const getIds = useCompareStore((s) => s.getIds);
  const clear = useCompareStore((s) => s.clear);
  const router = useRouter();

  if (count < 2) return null;

  function handleCompare() {
    const ids = getIds();
    router.push(`/app/compare?ids=${ids.join(",")}`);
  }

  return (
    <div className="fixed bottom-20 right-4 z-50 flex items-center gap-2 lg:hidden">
      {/* Clear button */}
      <button
        type="button"
        onClick={clear}
        className="touch-target flex h-11 w-11 items-center justify-center rounded-full bg-surface-muted text-foreground-secondary shadow-md transition-colors hover:bg-surface-subtle"
        title={t("compare.clearSelection")}
      >
        ✕
      </button>

      {/* Compare button */}
      <button
        type="button"
        onClick={handleCompare}
        className="flex items-center gap-2 rounded-full bg-brand-600 px-5 py-3 font-medium text-white shadow-lg transition-transform hover:scale-105 hover:bg-brand-700 active:scale-95"
      >
        <span className="flex items-center justify-center">
          <Scale size={20} aria-hidden="true" />
        </span>
        {t("compare.compareCount", { count })}
        <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/20 text-xs font-bold">
          {count}
        </span>
      </button>
    </div>
  );
}
