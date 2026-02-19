"use client";

// ─── ComparisonTray — floating tray for product comparison ──────────────────
// Shows selected products with names. Collapse/expand. Navigate to compare page.
// Desktop only (hidden below lg via CSS). Replaces CompareFloatingButton on lg+.

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { Scale, ChevronDown, ChevronUp, X } from "lucide-react";
import { useCompareStore } from "@/stores/compare-store";
import { useTranslation } from "@/lib/i18n";

export function ComparisonTray() {
  const { t } = useTranslation();
  const router = useRouter();
  const [collapsed, setCollapsed] = useState(false);

  const count = useCompareStore((s) => s.count());
  const getIds = useCompareStore((s) => s.getIds);
  const getName = useCompareStore((s) => s.getName);
  const remove = useCompareStore((s) => s.remove);
  const clear = useCompareStore((s) => s.clear);

  const handleCompare = useCallback(() => {
    const ids = getIds();
    router.push(`/app/compare?ids=${ids.join(",")}`);
  }, [getIds, router]);

  // Don't render if no products selected
  if (count === 0) return null;

  const ids = getIds();

  return (
    <aside
      className="fixed bottom-6 right-6 z-50 hidden w-72 overflow-hidden rounded-2xl border border-border bg-surface shadow-xl lg:block"
      aria-label={t("comparisonTray.title")}
    >
      {/* Header */}
      <div className="flex items-center justify-between border-b border-border bg-surface-muted/50 px-4 py-2.5">
        <div className="flex items-center gap-2">
          <Scale size={16} aria-hidden="true" className="text-brand" />
          <span className="text-sm font-semibold text-foreground">
            {t("comparisonTray.title")}
          </span>
          <span className="flex h-5 min-w-[1.25rem] items-center justify-center rounded-full bg-brand px-1.5 text-xs font-bold text-white">
            {count}
          </span>
        </div>
        <div className="flex items-center gap-1">
          <button
            type="button"
            onClick={() => setCollapsed((c) => !c)}
            className="flex h-7 w-7 cursor-pointer items-center justify-center rounded text-foreground-secondary transition-colors hover:bg-surface-subtle hover:text-foreground"
            aria-label={
              collapsed
                ? t("comparisonTray.expand")
                : t("comparisonTray.collapse")
            }
          >
            {collapsed ? (
              <ChevronUp size={14} aria-hidden="true" />
            ) : (
              <ChevronDown size={14} aria-hidden="true" />
            )}
          </button>
          <button
            type="button"
            onClick={clear}
            className="flex h-7 w-7 cursor-pointer items-center justify-center rounded text-foreground-secondary transition-colors hover:bg-red-50 hover:text-red-600"
            aria-label={t("compare.clearSelection")}
          >
            <X size={14} aria-hidden="true" />
          </button>
        </div>
      </div>

      {/* Product list (shown when expanded) */}
      {!collapsed && (
        <>
          <ul className="max-h-48 divide-y divide-border/50 overflow-y-auto">
            {ids.map((id) => (
              <li
                key={id}
                className="flex items-center gap-2 px-4 py-2 text-sm"
              >
                <span className="min-w-0 flex-1 truncate text-foreground">
                  {getName(id)}
                </span>
                <button
                  type="button"
                  onClick={() => remove(id)}
                  className="flex h-6 w-6 shrink-0 cursor-pointer items-center justify-center rounded text-foreground-secondary/60 transition-colors hover:bg-red-50 hover:text-red-600"
                  aria-label={t("compare.removeFromComparison")}
                >
                  <X size={12} aria-hidden="true" />
                </button>
              </li>
            ))}
          </ul>

          {/* Compare button */}
          <div className="border-t border-border px-4 py-3">
            {count >= 2 ? (
              <button
                type="button"
                onClick={handleCompare}
                className="btn-primary w-full text-sm"
              >
                {t("comparisonTray.compareNow")}
              </button>
            ) : (
              <p className="text-center text-xs text-foreground-secondary">
                {t("compare.selectAtLeast2")}
              </p>
            )}
          </div>
        </>
      )}
    </aside>
  );
}
