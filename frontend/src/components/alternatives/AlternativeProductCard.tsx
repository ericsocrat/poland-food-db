// ─── AlternativeProductCard — visual comparison card ────────────────────────
// Rich card showing how an alternative compares to the current product:
// score badge, delta, comparison bar, verdict text, and similarity badge.

import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { ScoreComparisonBar } from "@/components/alternatives/ScoreComparisonBar";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { toTryVitScore } from "@/lib/score-utils";
import type { ProfileAlternative } from "@/lib/types";
import Link from "next/link";

interface AlternativeProductCardProps {
  alt: ProfileAlternative;
  /** Current product's unhealthiness score for comparison bar */
  currentScore: number;
}

/** Map score_delta to a verdict translation key */
function getVerdictKey(delta: number): string {
  if (delta >= 20) return "product.verdictMuchHealthier";
  if (delta >= 10) return "product.verdictHealthier";
  return "product.verdictSlightlyHealthier";
}

export function AlternativeProductCard({
  alt,
  currentScore,
}: Readonly<AlternativeProductCardProps>) {
  const { t } = useTranslation();
  const band = scoreBandFromScore(alt.unhealthiness_score);
  const bandStyle = SCORE_BANDS[band];

  return (
    <Link
      href={`/app/product/${alt.product_id}`}
      data-testid="alternative-card"
    >
      <div className="card hover-lift-press space-y-3 p-4">
        {/* Top row: score badge + product info + Nutri-Score */}
        <div className="flex items-start gap-3">
          <div
            className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${bandStyle.bg} ${bandStyle.color}`}
          >
            {toTryVitScore(alt.unhealthiness_score)}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate font-medium text-foreground">
              {alt.product_name}
            </p>
            <p className="text-sm text-foreground-secondary">{alt.brand}</p>
          </div>
          <NutriScoreBadge grade={alt.nutri_score} size="sm" showTooltip />
        </div>

        {/* Score comparison bar */}
        <ScoreComparisonBar
          currentScore={currentScore}
          alternativeScore={alt.unhealthiness_score}
        />

        {/* Bottom row: delta + verdict + similarity */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-sm font-semibold text-success-text">
              {t("product.pointsBetter", { points: alt.score_delta })}
            </span>
            <span className="text-xs text-foreground-muted">
              {t(getVerdictKey(alt.score_delta))}
            </span>
          </div>
          {alt.similarity > 0 && (
            <span className="rounded-full bg-surface-subtle px-2 py-0.5 text-xs text-foreground-secondary">
              {Math.round(alt.similarity * 100)}% {t("product.ingredientMatch")}
            </span>
          )}
        </div>
      </div>
    </Link>
  );
}
