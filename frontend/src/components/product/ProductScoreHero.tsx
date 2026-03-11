"use client";

import { ScoreGauge } from "@/components/product/ScoreGauge";
import { useTranslation } from "@/lib/i18n";
import { getScoreBand } from "@/lib/score-utils";

interface ProductScoreHeroProps {
  readonly unhealthinessScore: number;
  readonly headline: string;
}

export function ProductScoreHero({
  unhealthinessScore,
  headline,
}: ProductScoreHeroProps) {
  const { t } = useTranslation();
  const band = getScoreBand(unhealthinessScore);

  if (!band) return null;

  return (
    <div className={`card ${band.bgColor} border-0`}>
      <div className="flex flex-col items-center gap-3 py-2">
        <ScoreGauge score={unhealthinessScore} size="xl" />
        <div className="text-center">
          <p className={`text-lg font-bold ${band.textColor}`}>
            {t(`scoreInterpretation.${band.band === "darkred" ? "darkRed" : band.band}`)}
          </p>
          <p className="mt-1 text-sm text-foreground-secondary">
            {headline}
          </p>
        </div>
      </div>
    </div>
  );
}
