// ─── Category Score Bar — mini score range visualization ─────────────────────

import { type ScoreColorBand, scoreColorFromScore } from "@/lib/constants";

// Tailwind-safe bg classes for each 5-band color token
const BAND_BG: Record<ScoreColorBand, string> = {
  green: "bg-score-green",
  yellow: "bg-score-yellow",
  orange: "bg-score-orange",
  red: "bg-score-red",
  darkred: "bg-score-darkred",
};

interface CategoryScoreBarProps {
  /** Unhealthiness score — minimum in the category (1-100) */
  minScore: number;
  /** Unhealthiness score — maximum in the category (1-100) */
  maxScore: number;
  /** Unhealthiness score — average in the category */
  avgScore: number;
}

/**
 * Mini horizontal bar showing the score range for a category.
 * Renders a filled segment from minScore to maxScore with the average
 * band's color, on a neutral track background.
 */
export function CategoryScoreBar({
  minScore,
  maxScore,
  avgScore,
}: Readonly<CategoryScoreBarProps>) {
  const band = scoreColorFromScore(avgScore);
  const left = Math.max(0, Math.min(100, minScore));
  const right = Math.max(0, Math.min(100, maxScore));
  const width = Math.max(2, right - left); // minimum 2% so tiny ranges are visible

  return (
    <div
      className="relative h-1.5 w-full overflow-hidden rounded-full bg-surface-subtle"
      role="img"
      aria-label={`Score range ${minScore} to ${maxScore}`}
    >
      <div
        className={`absolute inset-y-0 rounded-full ${BAND_BG[band]}`}
        style={{ left: `${left}%`, width: `${width}%` }}
      />
    </div>
  );
}
