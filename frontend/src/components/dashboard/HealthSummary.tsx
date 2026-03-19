"use client";

// ─── HealthSummary — avg TryVit score + band distribution bar ───────────────

import { ScoreGauge } from "@/components/product/ScoreGauge";
import { useTranslation } from "@/lib/i18n";
import {
    getAllBands,
    getScoreBand,
    SCORE_BAND_HEX,
    toTryVitScore,
} from "@/lib/score-utils";
import type { RecentlyViewedProduct } from "@/lib/types";
import { useMemo } from "react";

interface HealthSummaryProps {
  products: RecentlyViewedProduct[];
}

export function HealthSummary({ products }: Readonly<HealthSummaryProps>) {
  const { t } = useTranslation();

  const analysis = useMemo(() => {
    const scored = products.filter(
      (p): p is typeof p & { unhealthiness_score: number } =>
        p.unhealthiness_score != null,
    );
    if (scored.length === 0) return null;

    const avgUnhealthiness = Math.round(
      scored.reduce((sum, p) => sum + p.unhealthiness_score, 0) / scored.length,
    );
    const avgTryVit = toTryVitScore(avgUnhealthiness);
    const band = getScoreBand(avgUnhealthiness);

    // Count products per band
    const allBands = getAllBands();
    const distribution = allBands.map((b) => ({
      ...b,
      count: scored.filter((p) => {
        const pb = getScoreBand(p.unhealthiness_score);
        return pb?.band === b.band;
      }).length,
    }));

    return { avgTryVit, band, distribution, total: scored.length };
  }, [products]);

  if (!analysis) {
    return (
      <section
        data-testid="health-summary"
        className="card p-4 lg:p-6"
        aria-label={t("dashboard.healthSummaryTitle")}
      >
        <p className="text-sm text-foreground-secondary">
          {t("dashboard.healthSummaryNoData")}
        </p>
      </section>
    );
  }

  const { avgTryVit, distribution, total } = analysis;

  return (
    <section
      data-testid="health-summary"
      className="card p-4 lg:p-6"
      aria-label={t("dashboard.healthSummaryTitle")}
    >
      <div className="flex items-center gap-4">
        {/* Score gauge */}
        <div className="animate-scale-in" data-testid="health-score-gauge">
          <ScoreGauge score={100 - avgTryVit} size="lg" />
        </div>

        <div className="min-w-0 flex-1">
          <h2 className="text-sm font-medium text-foreground-secondary">
            {t("dashboard.healthSummaryAvg")}
          </h2>
          <p className="text-xs text-foreground-secondary">
            {t("dashboard.healthSummaryProducts", { count: total })}
          </p>
        </div>
      </div>

      {/* Band distribution bar */}
      <div
        data-testid="health-distribution-bar"
        className="mt-4 flex h-3 overflow-hidden rounded-full"
        role="img"
        aria-label={distribution
          .filter((d) => d.count > 0)
          .map((d) => `${t(d.labelKey)}: ${d.count}`)
          .join(", ")}
      >
        {distribution.map((d) =>
          d.count > 0 ? (
            <div
              key={d.band}
              className="transition-all duration-300 first:rounded-l-full last:rounded-r-full"
              style={{
                width: `${(d.count / total) * 100}%`,
                backgroundColor:
                  SCORE_BAND_HEX[d.band as keyof typeof SCORE_BAND_HEX],
              }}
            />
          ) : null,
        )}
      </div>

      {/* Band legend */}
      <div
        data-testid="health-distribution-legend"
        className="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-muted-foreground"
      >
        {distribution
          .filter((d) => d.count > 0)
          .map((d) => (
            <span key={d.band} className="inline-flex items-center gap-1">
              <span
                className="inline-block h-2 w-2 rounded-full"
                style={{
                  backgroundColor:
                    SCORE_BAND_HEX[d.band as keyof typeof SCORE_BAND_HEX],
                }}
              />
              {t(d.labelKey)} ({d.count})
            </span>
          ))}
      </div>
    </section>
  );
}
