/**
 * ScoreBreakdownPanel — "Why this score?" collapsible panel.
 *
 * Fetches the score explanation via `api_score_explanation` and renders
 * a human-readable breakdown of the 9 scoring factors with progress bars.
 * Usable on the product profile page.
 */

"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getScoreExplanation } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { useTranslation } from "@/lib/i18n";
import { Skeleton } from "@/components/common/Skeleton";
import { BarChart3, AlertTriangle } from "lucide-react";
import type { ScoreExplanation } from "@/lib/types";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface ScoreBreakdownPanelProps {
  /** Product ID to load explanation for. */
  readonly productId: number;
  /** Current score (for display in header). */
  readonly score: number;
  /** Current score band label (e.g., "Elevated Risk"). */
  readonly scoreBand: string;
  /** Start expanded. @default false */
  readonly defaultOpen?: boolean;
}

// ─── Factor bar color mapping ───────────────────────────────────────────────

function getFactorColor(raw: number): string {
  if (raw <= 20) return "bg-score-green";
  if (raw <= 40) return "bg-score-yellow";
  if (raw <= 60) return "bg-score-orange";
  if (raw <= 80) return "bg-score-red";
  return "bg-score-darkred";
}

// ─── Component ──────────────────────────────────────────────────────────────

export function ScoreBreakdownPanel({
  productId,
  score,
  scoreBand,
  defaultOpen = false,
}: Readonly<ScoreBreakdownPanelProps>) {
  const [isOpen, setIsOpen] = useState(defaultOpen);
  const { t } = useTranslation();
  const supabase = createClient();

  const {
    data: explanation,
    isLoading,
    error,
  } = useQuery({
    queryKey: queryKeys.scoreExplanation(productId),
    queryFn: async () => {
      const result = await getScoreExplanation(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.productProfile,
    enabled: isOpen,
  });

  return (
    <div className="card" data-testid="score-breakdown-panel">
      <button
        type="button"
        onClick={() => setIsOpen((v) => !v)}
        className="flex w-full items-center justify-between text-left"
        aria-expanded={isOpen}
        aria-controls="score-breakdown-content"
      >
        <div className="flex items-center gap-2">
          <span className="shrink-0" aria-hidden="true">
            <BarChart3 size={18} />
          </span>
          <span className="text-sm font-semibold text-foreground">
            {t("tooltip.scoreBreakdown.title")}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-foreground-secondary">
            {score}/100 — {scoreBand}
          </span>
          <svg
            className={`h-4 w-4 text-foreground-muted transition-transform duration-200 ${
              isOpen ? "rotate-180" : ""
            }`}
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
              clipRule="evenodd"
            />
          </svg>
        </div>
      </button>

      {isOpen && (
        <div id="score-breakdown-content" className="mt-4 space-y-3">
          {isLoading && <BreakdownSkeleton />}
          {error && (
            <p className="text-xs text-error">
              {t("tooltip.scoreBreakdown.error")}
            </p>
          )}
          {explanation && <BreakdownContent explanation={explanation} />}
        </div>
      )}
    </div>
  );
}

// ─── Breakdown Content ──────────────────────────────────────────────────────

function BreakdownContent({
  explanation,
}: Readonly<{ explanation: ScoreExplanation }>) {
  const { t } = useTranslation();
  const factors = explanation.top_factors ?? [];

  return (
    <div className="space-y-3">
      {/* Summary headline */}
      <p className="text-xs text-foreground-secondary">
        {explanation.summary?.headline}
      </p>

      {/* Factor bars */}
      {factors.length > 0 && (
        <div className="space-y-2">
          {factors.map((f) => (
            <div key={f.factor} className="space-y-0.5">
              <div className="flex items-center justify-between text-xs">
                <span className="text-foreground-secondary">{f.factor}</span>
                <span className="font-medium text-foreground tabular-nums">
                  +{f.weighted.toFixed(1)} pts
                </span>
              </div>
              <div className="h-1.5 w-full rounded-full bg-surface-muted">
                <div
                  className={`h-1.5 rounded-full transition-all duration-300 ${getFactorColor(f.raw)}`}
                  style={{ width: `${Math.min(f.raw, 100)}%` }}
                  role="progressbar"
                  aria-label={`${f.factor}: ${f.raw}/100`}
                  aria-valuenow={f.raw}
                  aria-valuemin={0}
                  aria-valuemax={100}
                />
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Category context */}
      {explanation.category_context && (
        <div className="rounded-md bg-surface-muted px-3 py-2 text-xs text-foreground-secondary">
          <p>
            {t("tooltip.scoreBreakdown.rank", {
              rank: String(explanation.category_context.category_rank),
              total: String(explanation.category_context.category_total),
            })}
          </p>
          <p>
            {t("tooltip.scoreBreakdown.categoryAvg", {
              avg: String(
                Math.round(explanation.category_context.category_avg_score),
              ),
            })}
          </p>
        </div>
      )}

      {/* Warnings */}
      {explanation.warnings && explanation.warnings.length > 0 && (
        <div className="space-y-1">
          {explanation.warnings.map((w) => (
            <p
              key={w.type}
              className="flex items-center gap-1 text-xs text-warning"
            >
              <AlertTriangle size={14} aria-hidden="true" /> {w.message}
            </p>
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Skeleton ───────────────────────────────────────────────────────────────

function BreakdownSkeleton() {
  return (
    <div className="space-y-2">
      <Skeleton className="h-3 w-3/4" />
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="space-y-1">
          <div className="flex justify-between">
            <Skeleton className="h-3 w-24" />
            <Skeleton className="h-3 w-12" />
          </div>
          <Skeleton className="h-1.5 w-full" />
        </div>
      ))}
    </div>
  );
}
