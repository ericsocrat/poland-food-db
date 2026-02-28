/**
 * Score band utilities — maps unhealthiness scores (1–100) to visual bands.
 *
 * Canonical band definitions for the 5-band scoring system.
 * Used by ScoreBadge, ScoreGauge, and comparison/search UI.
 *
 * @see docs/SCORING_METHODOLOGY.md
 */

import type { ScoreColorBand } from "@/lib/constants";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface ScoreBand {
  /** Band key: "green" | "yellow" | "orange" | "red" | "darkred". */
  readonly band: ScoreColorBand;
  /** Human-readable label: "Low", "Moderate", "High", "Very High", "Extreme". */
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
    label: "Low",
    color: "var(--color-score-green)",
    bgColor: "bg-score-green/10",
    textColor: "text-score-green-text",
  },
  yellow: {
    label: "Moderate",
    color: "var(--color-score-yellow)",
    bgColor: "bg-score-yellow/10",
    textColor: "text-score-yellow-text",
  },
  orange: {
    label: "High",
    color: "var(--color-score-orange)",
    bgColor: "bg-score-orange/10",
    textColor: "text-score-orange-text",
  },
  red: {
    label: "Very High",
    color: "var(--color-score-red)",
    bgColor: "bg-score-red/10",
    textColor: "text-score-red-text",
  },
  darkred: {
    label: "Extreme",
    color: "var(--color-score-darkred)",
    bgColor: "bg-score-darkred/10",
    textColor: "text-score-darkred-text",
  },
};

// ─── Public API ─────────────────────────────────────────────────────────────

/**
 * Resolve a score (1–100) to its full band configuration.
 *
 * Returns `null` for invalid inputs (null, undefined, NaN, out of range).
 *
 * @example
 * ```ts
 * getScoreBand(23);
 * // → { band: "yellow", label: "Moderate", color: "var(--color-score-yellow)", … }
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
