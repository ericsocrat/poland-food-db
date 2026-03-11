// ─── ScoreComparisonBar — visual side-by-side score comparison ──────────────
// Renders two horizontal bars showing the TryVit Score of the current product
// vs an alternative. Higher = healthier (green), lower = worse (red).

import { scoreColorFromScore } from "@/lib/constants";
import { toTryVitScore } from "@/lib/score-utils";

interface ScoreComparisonBarProps {
  /** Current product unhealthiness score (0–100) */
  currentScore: number;
  /** Alternative product unhealthiness score (0–100) */
  alternativeScore: number;
}

const COLOR_MAP: Record<string, string> = {
  green: "bg-score-green",
  yellow: "bg-score-yellow",
  orange: "bg-score-orange",
  red: "bg-score-red",
  darkred: "bg-score-darkred",
};

export function ScoreComparisonBar({
  currentScore,
  alternativeScore,
}: Readonly<ScoreComparisonBarProps>) {
  const currentTryVit = toTryVitScore(currentScore);
  const altTryVit = toTryVitScore(alternativeScore);

  const currentColor = COLOR_MAP[scoreColorFromScore(currentScore)];
  const altColor = COLOR_MAP[scoreColorFromScore(alternativeScore)];

  // Ensure minimum 4% width for visibility
  const currentWidth = Math.max(4, currentTryVit);
  const altWidth = Math.max(4, altTryVit);

  return (
    <div
      className="flex flex-col gap-1"
      role="img"
      aria-label={`Score comparison: alternative ${altTryVit} vs current ${currentTryVit}`}
    >
      <div className="flex items-center gap-2">
        <span className="w-7 text-right text-xs font-semibold text-foreground">
          {altTryVit}
        </span>
        <div className="h-2 flex-1 overflow-hidden rounded-full bg-surface-subtle">
          <div
            className={`h-full rounded-full transition-all ${altColor}`}
            style={{ width: `${altWidth}%` }}
            data-testid="alt-bar"
          />
        </div>
      </div>
      <div className="flex items-center gap-2">
        <span className="w-7 text-right text-xs text-foreground-muted">
          {currentTryVit}
        </span>
        <div className="h-2 flex-1 overflow-hidden rounded-full bg-surface-subtle">
          <div
            className={`h-full rounded-full transition-all ${currentColor}`}
            style={{ width: `${currentWidth}%` }}
            data-testid="current-bar"
          />
        </div>
      </div>
    </div>
  );
}
