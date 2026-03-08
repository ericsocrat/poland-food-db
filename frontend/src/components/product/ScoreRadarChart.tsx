"use client";

// ─── ScoreRadarChart ────────────────────────────────────────────────────────
// Custom SVG radar / spider chart for unhealthiness scoring factors.
// Zero external dependencies — pure React + SVG.
//
// Each axis represents a scoring factor (9 penalty + 1 nutrient density bonus).
// The value plotted is the raw weighted contribution (0 → centre, ceiling → edge).
// The nutrient density bonus axis is rendered with a green accent.
// The polygon area immediately communicates the product's risk profile at a glance.

import { useTranslation } from "@/lib/i18n";
import type { ScoreBreakdownFactor } from "@/lib/types";

// ── Factor metadata (order determines axis placement) ────────────────────────

interface FactorMeta {
  key: string;
  label: string;
  /** Maximum possible weighted value for this factor (weight × ceiling). */
  maxWeighted: number;
}

/**
 * The 10 scoring factors in the order they appear around the chart.
 * `maxWeighted` is computed from the formula: weight × ceiling.
 * If ceiling is absent we use a sensible cap.
 * Nutrient density bonus is rendered with green accent (negative weighted → benefit).
 */
const FACTORS: FactorMeta[] = [
  { key: "saturated_fat", label: "Sat Fat", maxWeighted: 17 },
  { key: "sugars", label: "Sugars", maxWeighted: 17 },
  { key: "salt", label: "Salt", maxWeighted: 17 },
  { key: "calories", label: "Calories", maxWeighted: 10 },
  { key: "trans_fat", label: "Trans Fat", maxWeighted: 11 },
  { key: "additives", label: "Additives", maxWeighted: 7 },
  { key: "prep_method", label: "Processing", maxWeighted: 8 },
  { key: "controversies", label: "Controversies", maxWeighted: 8 },
  { key: "ingredient_concern", label: "Concern", maxWeighted: 5 },
  { key: "nutrient_density", label: "Nutrient+", maxWeighted: 8 },
];

const BONUS_FACTOR_KEY = "nutrient_density";

const NUM_AXES = FACTORS.length;
const CHART_SIZE = 240;
const CENTER = CHART_SIZE / 2;
const OUTER_RADIUS = CHART_SIZE / 2 - 28; // leave room for labels
const RINGS = 3; // concentric reference circles

// ── Geometry helpers ─────────────────────────────────────────────────────────

function angleForIndex(i: number): number {
  // Start from the top (−π/2) and go clockwise
  return (2 * Math.PI * i) / NUM_AXES - Math.PI / 2;
}

function polarToCartesian(
  angle: number,
  radius: number,
): { x: number; y: number } {
  return {
    x: CENTER + radius * Math.cos(angle),
    y: CENTER + radius * Math.sin(angle),
  };
}

function buildPolygonPoints(values: number[]): string {
  return values
    .map((v, i) => {
      const angle = angleForIndex(i);
      const r = OUTER_RADIUS * Math.min(v, 1);
      const { x, y } = polarToCartesian(angle, r);
      return `${x},${y}`;
    })
    .join(" ");
}

// ── Component ────────────────────────────────────────────────────────────────

interface ScoreRadarChartProps {
  readonly breakdown: ScoreBreakdownFactor[];
}

export function ScoreRadarChart({ breakdown }: ScoreRadarChartProps) {
  const { t } = useTranslation();

  // Build a lookup map: factor name → weighted value
  const valueMap = new Map(breakdown.map((f) => [f.name, f.weighted]));

  // Normalised values (0–1) for each axis
  // For nutrient_density, the weighted value is negative (bonus) so we use the
  // absolute value to plot the magnitude of the benefit.
  const normalisedValues = FACTORS.map((meta) => {
    const weighted = valueMap.get(meta.key) ?? 0;
    const magnitude = meta.key === BONUS_FACTOR_KEY ? Math.abs(weighted) : weighted;
    return Math.min(magnitude / meta.maxWeighted, 1);
  });

  return (
    <svg
      viewBox={`0 0 ${CHART_SIZE} ${CHART_SIZE}`}
      className="mx-auto h-56 w-56"
      aria-label={t("a11y.scoreRadarChart")}
    >
      <title>{t("a11y.scoreRadarChartTitle")}</title>

      {/* Concentric reference rings */}
      {Array.from({ length: RINGS }, (_, ring) => {
        const r = (OUTER_RADIUS / RINGS) * (ring + 1);
        return (
          <circle
            key={ring}
            cx={CENTER}
            cy={CENTER}
            r={r}
            fill="none"
            className="stroke-foreground/10"
            strokeWidth={1}
          />
        );
      })}

      {/* Axis lines */}
      {FACTORS.map((meta, i) => {
        const angle = angleForIndex(i);
        const outer = polarToCartesian(angle, OUTER_RADIUS);
        return (
          <line
            key={meta.key}
            x1={CENTER}
            y1={CENTER}
            x2={outer.x}
            y2={outer.y}
            className="stroke-foreground/10"
            strokeWidth={1}
          />
        );
      })}

      {/* Data polygon */}
      <polygon
        points={buildPolygonPoints(normalisedValues)}
        className="fill-red-500/20 stroke-red-500"
        strokeWidth={2}
        strokeLinejoin="round"
      />

      {/* Data points */}
      {normalisedValues.map((v, i) => {
        const angle = angleForIndex(i);
        const r = OUTER_RADIUS * Math.min(v, 1);
        const { x, y } = polarToCartesian(angle, r);
        const isBonus = FACTORS[i].key === BONUS_FACTOR_KEY;
        return (
          <circle
            key={FACTORS[i].key}
            cx={x}
            cy={y}
            r={3}
            className={isBonus ? "fill-green-500" : "fill-red-500"}
          />
        );
      })}

      {/* Axis labels */}
      {FACTORS.map((meta, i) => {
        const angle = angleForIndex(i);
        const labelR = OUTER_RADIUS + 16;
        const { x, y } = polarToCartesian(angle, labelR);
        const isBonus = meta.key === BONUS_FACTOR_KEY;
        return (
          <text
            key={`lbl-${meta.key}`}
            x={x}
            y={y}
            textAnchor="middle"
            dominantBaseline="middle"
            className={isBonus ? "fill-green-600 text-[9px] dark:fill-green-400" : "fill-foreground-secondary text-[9px]"}
          >
            {meta.label}
          </text>
        );
      })}
    </svg>
  );
}
