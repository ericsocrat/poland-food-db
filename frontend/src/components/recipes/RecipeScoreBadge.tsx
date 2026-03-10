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
  high: { label: "High confidence", className: "text-success-text" },
  medium: { label: "Medium confidence", className: "text-warning-text" },
  low: { label: "Low confidence", className: "text-error-text" },
};

// ─── NutrientBar — visual bar for a single nutrient value ───────────────────

interface NutrientBarProps {
  readonly label: string;
  readonly value: number | null | undefined;
  readonly unit: string;
  /** Daily reference intake ceiling for the bar. */
  readonly max: number;
  /** Positive nutrient (protein, fibre) — use brand color instead of warning. */
  readonly positive?: boolean;
}

function NutrientBar({ label, value, unit, max, positive }: NutrientBarProps) {
  if (value == null) return null;
  const pct = Math.min(Math.round((value / max) * 100), 100);
  const barColor = positive ? "bg-success" : pct > 75 ? "bg-warning" : "bg-brand-primary";

  return (
    <div className="text-xs" data-testid={`nutrient-bar-${label.toLowerCase()}`}>
      <div className="flex items-center justify-between text-foreground-muted mb-0.5">
        <span>{label}</span>
        <span>
          {value} {unit}
        </span>
      </div>
      <div className="h-1.5 w-full rounded-full bg-surface-muted overflow-hidden">
        <div
          className={`h-full rounded-full ${barColor} transition-all duration-500`}
          style={{ width: `${pct}%` }}
          role="progressbar"
          aria-valuenow={value}
          aria-valuemin={0}
          aria-valuemax={max}
          aria-label={`${label}: ${value} ${unit}`}
        />
      </div>
    </div>
  );
}

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
        <div className="mt-3 space-y-2" data-testid="recipe-score-nutrition">
          <NutrientBar label="Calories" value={score.nutrition_summary.avg_calories} unit="kcal" max={2000} />
          <NutrientBar label="Protein" value={score.nutrition_summary.avg_protein_g} unit="g" max={50} positive />
          <NutrientBar label="Fat" value={score.nutrition_summary.avg_total_fat_g} unit="g" max={70} />
          <NutrientBar label="Sugars" value={score.nutrition_summary.avg_sugars_g} unit="g" max={90} />
          <NutrientBar label="Salt" value={score.nutrition_summary.avg_salt_g} unit="g" max={6} />
          <NutrientBar label="Fibre" value={score.nutrition_summary.avg_fibre_g} unit="g" max={30} positive />
        </div>
      )}
    </div>
  );
});
