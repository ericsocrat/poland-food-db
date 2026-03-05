/**
 * RecipeScoreBadge — Aggregate TryVit Score badge for a recipe.
 *
 * Displays the average unhealthiness score computed from linked product scores,
 * with coverage indicator showing what percentage of ingredients are linked.
 * Confidence band (high/medium/low) is derived from coverage.
 *
 * Issue #616.
 */

"use client";

import React from "react";
import { getScoreBand } from "@/lib/score-utils";
import type { RecipeScore } from "@/lib/types";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface RecipeScoreBadgeProps {
  /** Recipe score data from api_get_recipe_score. */
  readonly score: RecipeScore | null | undefined;
  /** Show nutrition summary details. @default false */
  readonly showNutrition?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Confidence styling ─────────────────────────────────────────────────────

const CONFIDENCE_STYLE: Record<string, { label: string; className: string }> = {
  high: { label: "High confidence", className: "text-emerald-600 dark:text-emerald-400" },
  medium: { label: "Medium confidence", className: "text-amber-600 dark:text-amber-400" },
  low: { label: "Low confidence", className: "text-red-500 dark:text-red-400" },
};

// ─── Component ──────────────────────────────────────────────────────────────

export const RecipeScoreBadge = React.memo(function RecipeScoreBadge({
  score,
  showNutrition = false,
  className = "",
}: Readonly<RecipeScoreBadgeProps>) {
  // ─── No data state ──────────────────────────────────────────────────────

  if (!score) {
    return null;
  }

  // ─── Error state (recipe not found) ─────────────────────────────────────

  if ("error" in score) {
    return null;
  }

  // ─── No linked products → informational state ──────────────────────────

  if (score.linked_count === 0) {
    return (
      <div
        className={[
          "rounded-xl border border-border bg-surface-card p-4",
          className,
        ]
          .filter(Boolean)
          .join(" ")}
        data-testid="recipe-score-empty"
      >
        <p className="text-sm text-foreground-muted">
          No linked products yet — score will appear when ingredients are mapped.
        </p>
      </div>
    );
  }

  // ─── Score display ──────────────────────────────────────────────────────

  const band = getScoreBand(score.aggregate_score);
  const bgClass = band?.bgColor ?? "bg-surface-muted";
  const textClass = band?.textColor ?? "text-foreground-muted";
  const bandLabel = band?.label ?? "N/A";
  const conf = CONFIDENCE_STYLE[score.confidence] ?? CONFIDENCE_STYLE.low;

  return (
    <div
      className={[
        "rounded-xl border border-border bg-surface-card p-4",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      data-testid="recipe-score-badge"
    >
      {/* Header row: score pill + label */}
      <div className="flex items-center gap-3">
        <span
          className={[
            "inline-flex items-center justify-center rounded-full px-3 py-1 text-lg font-bold",
            bgClass,
            textClass,
          ].join(" ")}
          aria-label={`Recipe score: ${score.aggregate_score}`}
        >
          {score.aggregate_score}
        </span>
        <div className="flex flex-col">
          <span className={`text-sm font-semibold ${textClass}`}>
            {bandLabel}
          </span>
          <span className="text-xs text-foreground-muted">
            Based on {score.linked_count} of {score.ingredient_count} ingredients
          </span>
        </div>
      </div>

      {/* Coverage bar */}
      <div className="mt-3" data-testid="recipe-score-coverage">
        <div className="flex items-center justify-between text-xs text-foreground-muted mb-1">
          <span>{score.coverage_pct}% ingredient coverage</span>
          <span className={conf.className}>{conf.label}</span>
        </div>
        <div className="h-1.5 w-full rounded-full bg-surface-muted overflow-hidden">
          <div
            className="h-full rounded-full bg-brand-primary transition-all duration-500"
            style={{ width: `${Math.min(score.coverage_pct, 100)}%` }}
            role="progressbar"
            aria-valuenow={score.coverage_pct}
            aria-valuemin={0}
            aria-valuemax={100}
          />
        </div>
      </div>

      {/* Optional nutrition summary */}
      {showNutrition && score.nutrition_summary && (
        <div className="mt-3 grid grid-cols-2 gap-x-4 gap-y-1 text-xs text-foreground-muted" data-testid="recipe-score-nutrition">
          {score.nutrition_summary.avg_calories != null && (
            <span>Calories: {score.nutrition_summary.avg_calories} kcal</span>
          )}
          {score.nutrition_summary.avg_protein_g != null && (
            <span>Protein: {score.nutrition_summary.avg_protein_g} g</span>
          )}
          {score.nutrition_summary.avg_total_fat_g != null && (
            <span>Fat: {score.nutrition_summary.avg_total_fat_g} g</span>
          )}
          {score.nutrition_summary.avg_sugars_g != null && (
            <span>Sugars: {score.nutrition_summary.avg_sugars_g} g</span>
          )}
          {score.nutrition_summary.avg_salt_g != null && (
            <span>Salt: {score.nutrition_summary.avg_salt_g} g</span>
          )}
          {score.nutrition_summary.avg_fibre_g != null && (
            <span>Fibre: {score.nutrition_summary.avg_fibre_g} g</span>
          )}
        </div>
      )}
    </div>
  );
});
