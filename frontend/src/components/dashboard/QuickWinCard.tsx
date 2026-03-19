"use client";

// ─── QuickWinCard — swap suggestion for worst-scoring product ───────────────

import { ScoreGauge } from "@/components/product/ScoreGauge";
import { useAlternativesV2 } from "@/hooks/use-alternatives-v2";
import { useTranslation } from "@/lib/i18n";
import { toTryVitScore } from "@/lib/score-utils";
import type { RecentlyViewedProduct } from "@/lib/types";
import { ArrowRight } from "lucide-react";
import Link from "next/link";
import { useMemo } from "react";

interface QuickWinCardProps {
  products: RecentlyViewedProduct[];
}

export function QuickWinCard({ products }: Readonly<QuickWinCardProps>) {
  const { t } = useTranslation();

  const worstProduct = useMemo(() => {
    const scored = products.filter(
      (p): p is typeof p & { unhealthiness_score: number } =>
        p.unhealthiness_score != null,
    );
    if (scored.length === 0) return null;
    return scored.reduce((worst, p) =>
      p.unhealthiness_score > worst.unhealthiness_score ? p : worst,
    scored[0]);
  }, [products]);

  const { data, isLoading } = useAlternativesV2({
    productId: worstProduct?.product_id ?? 0,
    limit: 1,
    enabled: !!worstProduct,
  });

  if (!worstProduct) return null;

  const alternative = data?.alternatives?.[0];

  // Hide the entire card when no swap is available (not just the text)
  if (!isLoading && !alternative) return null;

  const worstScore = worstProduct.unhealthiness_score;
  const scoreDelta = alternative
    ? toTryVitScore(alternative.unhealthiness_score) -
      toTryVitScore(worstScore)
    : 0;

  return (
    <section
      data-testid="quick-win-card"
      className="card p-4 lg:p-6"
      aria-label={t("dashboard.quickWinTitle")}
    >
      <h2 className="mb-3 text-sm font-semibold text-foreground-secondary">
        {t("dashboard.quickWinTitle")}
      </h2>

      {isLoading && (
        <p data-testid="quick-win-loading" className="text-sm text-foreground-secondary">
          {t("dashboard.quickWinLoading")}
        </p>
      )}

      {!isLoading && alternative && (
        <div className="space-y-3">
          <p className="text-sm">
            {t("dashboard.quickWinSwap", {
              from: worstProduct.product_name,
              to: alternative.product_name,
            })}
          </p>

          {/* Score comparison */}
          <div className="flex items-center gap-3">
            <div data-testid="quick-win-from-score">
              <ScoreGauge score={worstScore} size="sm" />
            </div>
            <ArrowRight className="h-4 w-4 text-foreground-secondary" aria-hidden="true" />
            <div data-testid="quick-win-to-score">
              <ScoreGauge score={alternative.unhealthiness_score} size="sm" />
            </div>
            {scoreDelta > 0 && (
              <span
                data-testid="quick-win-gain"
                className="text-sm font-semibold text-score-green-text"
              >
                {t("dashboard.quickWinGain", { points: scoreDelta })}
              </span>
            )}
          </div>

          <Link
            href={`/app/product/${alternative.product_id}`}
            className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
          >
            {t("dashboard.quickWinViewSwap")}
            <ArrowRight className="h-3.5 w-3.5" aria-hidden="true" />
          </Link>
        </div>
      )}
    </section>
  );
}
