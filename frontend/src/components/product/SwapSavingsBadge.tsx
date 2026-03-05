"use client";

import type { SwapSavings } from "@/lib/types";

// ─── Props ──────────────────────────────────────────────────────────────────

export interface SwapSavingsBadgeProps {
  /** Swap savings data from the v2 alternatives API */
  savings: SwapSavings;
  /** Whether this alternative is from a different category */
  isCrossCategory?: boolean;
  /** Whether this alternative is palm-oil-free */
  palmOilFree?: boolean;
}

// ─── Component ──────────────────────────────────────────────────────────────

/**
 * Displays a compact badge showing key swap savings when switching to an
 * alternative product. Shows the headline (e.g. "28 points healthier — 91% less
 * sugar") and optional cross-category / palm-oil-free tags.
 */
export function SwapSavingsBadge({
  savings,
  isCrossCategory = false,
  palmOilFree = false,
}: SwapSavingsBadgeProps) {
  const scoreDelta = Math.abs(savings.score_delta);

  return (
    <div className="flex flex-col gap-1">
      {/* Primary headline */}
      <p className="text-sm font-medium text-green-700 dark:text-green-400">
        {savings.headline || `${scoreDelta} points healthier`}
      </p>

      {/* Nutrient savings chips */}
      <div className="flex flex-wrap gap-1.5">
        {savings.calories_saved > 0 && (
          <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs font-medium text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
            -{Math.round(savings.calories_saved)} kcal
          </span>
        )}
        {savings.sugar_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-700 dark:bg-amber-900/30 dark:text-amber-300">
            -{savings.sugar_saved_g.toFixed(1)}g sugar
          </span>
        )}
        {savings.sat_fat_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-orange-50 px-2 py-0.5 text-xs font-medium text-orange-700 dark:bg-orange-900/30 dark:text-orange-300">
            -{savings.sat_fat_saved_g.toFixed(1)}g sat fat
          </span>
        )}
        {savings.salt_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700 dark:bg-red-900/30 dark:text-red-300">
            -{savings.salt_saved_g.toFixed(1)}g salt
          </span>
        )}
      </div>

      {/* Tags row */}
      {(isCrossCategory || palmOilFree) && (
        <div className="flex gap-1.5">
          {isCrossCategory && (
            <span className="inline-flex items-center rounded bg-purple-50 px-1.5 py-0.5 text-xs text-purple-600 dark:bg-purple-900/30 dark:text-purple-300">
              Cross-category
            </span>
          )}
          {palmOilFree && (
            <span className="inline-flex items-center rounded bg-emerald-50 px-1.5 py-0.5 text-xs text-emerald-600 dark:bg-emerald-900/30 dark:text-emerald-300">
              No palm oil
            </span>
          )}
        </div>
      )}
    </div>
  );
}
