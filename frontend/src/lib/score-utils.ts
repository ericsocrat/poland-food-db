/**
 * TryVit Score utilities — consumer-friendly score inversion and band mapping.
 *
 * The API returns `unhealthiness_score` (1–100, lower = healthier).
 * The frontend displays the **TryVit Score** (1–100, higher = healthier):
 *
 *   TryVit Score = 100 − unhealthiness_score
 *
 * Band mapping (by unhealthiness input):
 *   1–20  → green  (Excellent)
 *   21–40 → yellow (Good)
 *   41–60 → orange (Moderate)
 *   61–80 → red    (Poor)
 *   81–100 → dark red (Bad)
 *
 * @see docs/SCORING_METHODOLOGY.md
 */

import type { ScoreColorBand } from "@/lib/constants";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface ScoreBand {
  /** Band key: "green" | "yellow" | "orange" | "red" | "darkred". */
  readonly band: ScoreColorBand;
  /** Consumer-facing label: "Excellent", "Good", "Moderate", "Poor", "Bad". */
  readonly label: string;
  /** CSS variable reference for the band's primary color. */
  readonly color: string;
  /** Tailwind background class (10% opacity). */
  readonly bgColor: string;
  /** Tailwind text class (WCAG-adjusted contrast). */
  readonly textColor: string;
}

// ─── Band configuration ─────────────────────────────────────────────────────

const BAND_CONFIG: Record<ScoreColorBand, Omit<ScoreBand, "band">> = {
  green: {
    label: "Excellent",
    color: "var(--color-score-green)",
    bgColor: "bg-score-green/10",
    textColor: "text-score-green-text",
  },
  yellow: {
    label: "Good",
    color: "var(--color-score-yellow)",
    bgColor: "bg-score-yellow/10",
    textColor: "text-score-yellow-text",
  },
  orange: {
    label: "Moderate",
    color: "var(--color-score-orange)",
    bgColor: "bg-score-orange/10",
    textColor: "text-score-orange-text",
  },
  red: {
    label: "Poor",
    color: "var(--color-score-red)",
    bgColor: "bg-score-red/10",
    textColor: "text-score-red-text",
  },
  darkred: {
    label: "Bad",
    color: "var(--color-score-darkred)",
    bgColor: "bg-score-darkred/10",
    textColor: "text-score-darkred-text",
  },
};

// ─── Public API ─────────────────────────────────────────────────────────────

/**
 * Convert an API unhealthiness score (1–100, lower = healthier) to a
 * consumer-friendly TryVit Score (0–100, higher = healthier).
 *
 * Formula: `TryVit Score = 100 − unhealthiness_score`, clamped to [0, 100].
 *
 * @example
 * ```ts
 * toTryVitScore(8);   // → 92  (excellent)
 * toTryVitScore(57);  // → 43  (moderate)
 * toTryVitScore(100); // → 0   (worst)
 * toTryVitScore(0);   // → 100 (best, edge case)
 * ```
 */
export function toTryVitScore(unhealthinessScore: number): number {
  return Math.max(0, Math.min(100, 100 - unhealthinessScore));
}

/**
 * Resolve an unhealthiness score (1–100) to its full band configuration.
 *
 * The score input is the raw **unhealthiness** value from the API.
 * Band color assignment: low unhealthiness → green, high → darkred.
 *
 * Returns `null` for invalid inputs (null, undefined, NaN, out of range).
 *
 * @example
 * ```ts
 * getScoreBand(8);
 * // → { band: "green", label: "Excellent", color: "var(--color-score-green)", … }
 *
 * getScoreBand(null);  // → null
 * getScoreBand(0);     // → null (out of range)
 * getScoreBand(101);   // → null (out of range)
 * ```
 */
export function getScoreBand(
  score: number | null | undefined,
): ScoreBand | null {
  if (score == null || !Number.isFinite(score) || score < 1 || score > 100) {
    return null;
  }

  const band = resolveKey(score);
  return { band, ...BAND_CONFIG[band] };
}

/**
 * Get all 5 band definitions as an ordered array (green → darkred).
 * Useful for legends, filter dropdowns, and documentation.
 */
export function getAllBands(): readonly ScoreBand[] {
  return BAND_ORDER.map((band) => ({ band, ...BAND_CONFIG[band] }));
}

// ─── Internal helpers ───────────────────────────────────────────────────────

const BAND_ORDER: readonly ScoreColorBand[] = [
  "green",
  "yellow",
  "orange",
  "red",
  "darkred",
] as const;

function resolveKey(score: number): ScoreColorBand {
  if (score <= 20) return "green";
  if (score <= 40) return "yellow";
  if (score <= 60) return "orange";
  if (score <= 80) return "red";
  return "darkred";
}
