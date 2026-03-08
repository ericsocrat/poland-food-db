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
      <p className="text-sm font-medium text-success-text">
        {savings.headline || `${scoreDelta} points healthier`}
      </p>

      {/* Nutrient savings chips */}
      <div className="flex flex-wrap gap-1.5">
        {savings.calories_saved > 0 && (
          <span className="inline-flex items-center rounded-full bg-info-bg px-2 py-0.5 text-xs font-medium text-info-text">
            -{Math.round(savings.calories_saved)} kcal
          </span>
        )}
        {savings.sugar_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-warning-bg px-2 py-0.5 text-xs font-medium text-warning-text">
            -{savings.sugar_saved_g.toFixed(1)}g sugar
          </span>
        )}
        {savings.sat_fat_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-warning-bg px-2 py-0.5 text-xs font-medium text-warning-text">
            -{savings.sat_fat_saved_g.toFixed(1)}g sat fat
          </span>
        )}
        {savings.salt_saved_g > 0 && (
          <span className="inline-flex items-center rounded-full bg-error-bg px-2 py-0.5 text-xs font-medium text-error-text">
            -{savings.salt_saved_g.toFixed(1)}g salt
          </span>
        )}
      </div>

      {/* Tags row */}
      {(isCrossCategory || palmOilFree) && (
        <div className="flex gap-1.5">
          {isCrossCategory && (
            <span className="inline-flex items-center rounded bg-tag-purple-bg px-1.5 py-0.5 text-xs text-tag-purple-text">
              Cross-category
            </span>
          )}
          {palmOilFree && (
            <span className="inline-flex items-center rounded bg-tag-emerald-bg px-1.5 py-0.5 text-xs text-tag-emerald-text">
              No palm oil
            </span>
          )}
        </div>
      )}
    </div>
  );
}
