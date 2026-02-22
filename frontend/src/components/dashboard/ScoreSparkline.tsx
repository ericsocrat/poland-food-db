"use client";

// ─── Pure SVG sparkline showing score distribution across bands ──────────────
//
// Renders a bar chart bucketing scores into 4 bands:
//   low (0–25), moderate (26–50), high (51–75), very_high (76–100)
//
// Used on the dashboard to give a quick visual sense of "how healthy is my
// overall diet?" without requiring a charting library.

import { useMemo } from "react";
import { useTranslation } from "@/lib/i18n";

interface ScoreSparklineProps {
  /** Array of unhealthiness scores (0–100). Nulls are filtered out. */
  scores: (number | null)[];
}

/** Band definitions in bar order (left → right = healthiest → least healthy). */
const BANDS = [
  { key: "low", min: 0, max: 25, fill: "#22c55e", label: "0–25" },
  { key: "moderate", min: 26, max: 50, fill: "#eab308", label: "26–50" },
  { key: "high", min: 51, max: 75, fill: "#f97316", label: "51–75" },
  { key: "very_high", min: 76, max: 100, fill: "#ef4444", label: "76–100" },
] as const;

const BAR_WIDTH = 36;
const BAR_GAP = 8;
const MAX_HEIGHT = 80;
const LABEL_HEIGHT = 16; // space for band labels below bars
const COUNT_HEIGHT = 14; // space for count labels above bars
const SVG_WIDTH = BANDS.length * BAR_WIDTH + (BANDS.length - 1) * BAR_GAP;
const SVG_HEIGHT = MAX_HEIGHT + LABEL_HEIGHT + COUNT_HEIGHT + 4;

export function ScoreSparkline({ scores }: Readonly<ScoreSparklineProps>) {
  const { t } = useTranslation();

  const buckets = useMemo(() => {
    const valid = scores.filter((s): s is number => s != null);
    if (valid.length === 0) return null;

    const counts = BANDS.map((band) => ({
      ...band,
      count: valid.filter((s) => s >= band.min && s <= band.max).length,
    }));

    const maxCount = Math.max(...counts.map((b) => b.count));
    return counts.map((b) => ({
      ...b,
      height: maxCount > 0 ? (b.count / maxCount) * MAX_HEIGHT : 0,
    }));
  }, [scores]);

  if (!buckets) return null;

  const ariaDescription = buckets
    .map((b) => `${b.label}: ${b.count}`)
    .join(", ");

  return (
    <div
      className="flex flex-col items-center gap-1"
      data-testid="score-sparkline"
    >
      <p className="text-xs font-medium text-foreground-secondary">
        {t("dashboard.sparklineTitle")}
      </p>
      <svg
        width={SVG_WIDTH}
        height={SVG_HEIGHT}
        viewBox={`0 0 ${SVG_WIDTH} ${SVG_HEIGHT}`}
        role="img"
        aria-label={t("dashboard.sparklineAria")}
        aria-describedby="sparkline-desc"
      >
        <title>{t("dashboard.sparklineAria")}</title>
        <desc id="sparkline-desc">{ariaDescription}</desc>
        {buckets.map((band, i) => {
          const x = i * (BAR_WIDTH + BAR_GAP);
          const barH = Math.max(band.height, band.count > 0 ? 4 : 0);
          const barY = COUNT_HEIGHT + MAX_HEIGHT - barH;
          return (
            <g key={band.key}>
              {/* Count label above bar */}
              {band.count > 0 && (
                <text
                  x={x + BAR_WIDTH / 2}
                  y={barY - 3}
                  textAnchor="middle"
                  fontSize={11}
                  fontWeight={600}
                  fill={band.fill}
                  data-testid={`sparkline-count-${band.key}`}
                >
                  {band.count}
                </text>
              )}
              {/* Bar */}
              <rect
                x={x}
                y={barY}
                width={BAR_WIDTH}
                height={barH}
                rx={4}
                fill={band.fill}
                opacity={band.count > 0 ? 1 : 0.2}
                data-testid={`sparkline-bar-${band.key}`}
              />
              {/* Band label below bars */}
              <text
                x={x + BAR_WIDTH / 2}
                y={COUNT_HEIGHT + MAX_HEIGHT + LABEL_HEIGHT}
                textAnchor="middle"
                fontSize={10}
                fill="currentColor"
                className="fill-foreground-secondary"
                data-testid={`sparkline-label-${band.key}`}
              >
                {band.label}
              </text>
            </g>
          );
        })}
      </svg>
    </div>
  );
}
