"use client";

import { useTranslation } from "@/lib/i18n";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { TrendingUp, TrendingDown, Minus, Activity } from "lucide-react";
import type { ScoreTrend } from "@/lib/types";

interface HealthInsightsSummaryProps {
  avgScore: number;
  scoreTrend: ScoreTrend;
}

const TREND_ICONS = {
  improving: TrendingDown, // lower score = healthier
  worsening: TrendingUp,
  stable: Minus,
} as const;

const TREND_COLORS = {
  improving: "text-score-green",
  worsening: "text-score-red",
  stable: "text-foreground-muted",
} as const;

/**
 * Summary card showing the user's average favorites score and score trend.
 * avgScore is 0-100 unhealthiness (lower = healthier).
 */
export function HealthInsightsSummary({
  avgScore,
  scoreTrend,
}: Readonly<HealthInsightsSummaryProps>) {
  const { t } = useTranslation();

  const band = scoreBandFromScore(avgScore);
  const bandCfg = SCORE_BANDS[band];
  const TrendIcon = TREND_ICONS[scoreTrend];

  return (
    <div data-testid="health-insights-summary">
      <div className="flex items-center gap-2">
        <Activity
          size={16}
          aria-hidden="true"
          className="text-foreground-muted"
        />
        <span className="text-sm font-semibold text-foreground">
          {t("dashboard.healthInsightsTitle")}
        </span>
      </div>

      <div className="mt-2 flex items-center gap-3">
        {/* Average score donut-like pill */}
        <div
          className={`flex h-14 w-14 items-center justify-center rounded-full border-4 ${bandCfg.bg}`}
          style={{
            borderColor: `var(--color-${bandCfg.color.replace("text-", "")})`,
          }}
          data-testid="avg-score-circle"
        >
          <span className={`text-lg font-bold tabular-nums ${bandCfg.color}`}>
            {Math.round(avgScore)}
          </span>
        </div>

        <div className="min-w-0 flex-1">
          <p className="text-sm text-foreground-secondary">
            {t("dashboard.avgScoreLabel")}
          </p>
          <p className={`text-xs font-medium ${bandCfg.color}`}>
            {t(`dashboard.scoreBand.${band}`)}
          </p>

          {/* Trend */}
          <div className="mt-1 flex items-center gap-1">
            <TrendIcon
              size={14}
              aria-hidden="true"
              className={TREND_COLORS[scoreTrend]}
            />
            <span className={`text-xs font-medium ${TREND_COLORS[scoreTrend]}`}>
              {t(`dashboard.scoreTrend.${scoreTrend}`)}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
