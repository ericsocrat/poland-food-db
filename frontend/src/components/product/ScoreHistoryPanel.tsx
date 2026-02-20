"use client";

/**
 * ScoreHistoryPanel — collapsible panel on the product profile
 * showing score trend chart and history table.
 */

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  ChevronDown,
  ChevronUp,
  TrendingDown,
  TrendingUp,
  Minus,
} from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import { useSupabase } from "@/lib/supabase/client";
import { getScoreHistory } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { ScoreTrendChart } from "./ScoreTrendChart";
import { ScoreChangeIndicator } from "./ScoreChangeIndicator";
import { ReformulationBadge } from "./ReformulationBadge";
import type { ScoreTrend } from "@/lib/types";

interface ScoreHistoryPanelProps {
  productId: number;
  defaultOpen?: boolean;
  className?: string;
}

const TREND_ICONS: Record<ScoreTrend, typeof TrendingUp> = {
  improving: TrendingDown,
  worsening: TrendingUp,
  stable: Minus,
};

const TREND_COLORS: Record<ScoreTrend, string> = {
  improving: "text-success",
  worsening: "text-error",
  stable: "text-foreground-secondary",
};

export function ScoreHistoryPanel({
  productId,
  defaultOpen = false,
  className,
}: Readonly<ScoreHistoryPanelProps>) {
  const { t } = useTranslation();
  const supabase = useSupabase();
  const [open, setOpen] = useState(defaultOpen);

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.scoreHistory(productId),
    queryFn: () => getScoreHistory(supabase, productId),
    staleTime: staleTimes.scoreHistory,
    enabled: open,
  });

  const history = data?.data;

  return (
    <div
      className={`rounded-xl border border-border bg-surface ${className ?? ""}`}
      data-testid="score-history-panel"
    >
      <button
        onClick={() => setOpen(!open)}
        className="flex w-full items-center justify-between px-4 py-3 text-left"
        aria-expanded={open}
      >
        <span className="text-sm font-semibold text-foreground">
          {t("watchlist.scoreHistory")}
        </span>
        <Icon
          icon={open ? ChevronUp : ChevronDown}
          size="sm"
          className="text-foreground-secondary"
        />
      </button>

      {open && (
        <div className="border-t border-border px-4 py-3">
          {isLoading && (
            <div className="flex items-center justify-center py-6">
              <div className="h-5 w-5 animate-spin rounded-full border-2 border-brand border-t-transparent" />
            </div>
          )}

          {error && (
            <p className="text-sm text-error" data-testid="score-history-error">
              {t("watchlist.historyError")}
            </p>
          )}

          {history && (
            <div className="space-y-4">
              {/* Overview row: trend + sparkline + reformulation */}
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2">
                  <Icon
                    icon={TREND_ICONS[history.trend]}
                    size="sm"
                    className={TREND_COLORS[history.trend]}
                  />
                  <span
                    className={`text-sm font-medium ${TREND_COLORS[history.trend]}`}
                  >
                    {t(`watchlist.trend.${history.trend}`)}
                  </span>
                </div>

                {history.history.length > 1 && (
                  <ScoreTrendChart
                    history={history.history.map((h) => ({
                      date: h.date,
                      score: h.score,
                    }))}
                    trend={history.trend}
                    width={100}
                    height={32}
                  />
                )}

                <ScoreChangeIndicator delta={history.delta} />
                <ReformulationBadge detected={history.reformulation_detected} />
              </div>

              {/* Snapshot count */}
              <p className="text-xs text-foreground-secondary">
                {t("watchlist.snapshotCount", {
                  count: String(history.total_snapshots),
                })}
              </p>

              {/* History table */}
              {history.history.length > 0 && (
                <div className="max-h-48 overflow-y-auto">
                  <table
                    className="w-full text-xs"
                    data-testid="score-history-table"
                  >
                    <thead>
                      <tr className="border-b border-border text-foreground-secondary">
                        <th className="pb-1 text-left font-medium">
                          {t("watchlist.historyDate")}
                        </th>
                        <th className="pb-1 text-right font-medium">
                          {t("watchlist.historyScore")}
                        </th>
                        <th className="pb-1 text-right font-medium">
                          {t("watchlist.historyDelta")}
                        </th>
                        <th className="pb-1 text-left font-medium">
                          {t("watchlist.historySource")}
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {history.history.map((entry) => (
                        <tr
                          key={entry.date}
                          className="border-b border-border/50 last:border-none"
                        >
                          <td className="py-1 text-foreground-secondary">
                            {new Date(entry.date).toLocaleDateString()}
                          </td>
                          <td className="py-1 text-right font-medium text-foreground">
                            {entry.score}
                          </td>
                          <td className="py-1 text-right">
                            <ScoreChangeIndicator delta={entry.delta} />
                          </td>
                          <td className="py-1 text-foreground-secondary">
                            {entry.source}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {history.history.length === 0 && (
                <p className="text-sm text-foreground-secondary">
                  {t("watchlist.noHistoryYet")}
                </p>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
