"use client";

import { useMemo } from "react";
import { useTranslation } from "@/lib/i18n";
import type { NovaDistribution } from "@/lib/types";

const NOVA_GROUPS = [
  { key: "1" as const, color: "#22c55e" },
  { key: "2" as const, color: "#eab308" },
  { key: "3" as const, color: "#f97316" },
  { key: "4" as const, color: "#ef4444" },
] as const;

const BAR_WIDTH = 28;
const BAR_GAP = 8;
const MAX_HEIGHT = 44;
const SVG_WIDTH =
  NOVA_GROUPS.length * BAR_WIDTH + (NOVA_GROUPS.length - 1) * BAR_GAP;
const SVG_HEIGHT = MAX_HEIGHT + 4;

interface NovaDistributionChartProps {
  distribution: NovaDistribution;
}

export function NovaDistributionChart({
  distribution,
}: Readonly<NovaDistributionChartProps>) {
  const { t } = useTranslation();

  const bars = useMemo(() => {
    const counts = NOVA_GROUPS.map((g) => ({
      ...g,
      count: distribution[g.key] ?? 0,
    }));
    const total = counts.reduce((sum, b) => sum + b.count, 0);
    const maxCount = Math.max(...counts.map((b) => b.count));
    return counts.map((b) => ({
      ...b,
      pct: total > 0 ? Math.round((b.count / total) * 100) : 0,
      height: maxCount > 0 ? (b.count / maxCount) * MAX_HEIGHT : 0,
    }));
  }, [distribution]);

  const total = bars.reduce((sum, b) => sum + b.count, 0);
  if (total === 0) return null;

  return (
    <div data-testid="nova-distribution">
      <h3 className="mb-2 text-sm font-semibold text-foreground lg:text-base">
        {t("dashboard.novaTitle")}
      </h3>

      <div className="flex items-end justify-center gap-1">
        <svg
          width={SVG_WIDTH}
          height={SVG_HEIGHT}
          viewBox={`0 0 ${SVG_WIDTH} ${SVG_HEIGHT}`}
          role="img"
          aria-label={t("dashboard.novaAria")}
        >
          {bars.map((bar, i) => {
            const x = i * (BAR_WIDTH + BAR_GAP);
            const barH = Math.max(bar.height, bar.count > 0 ? 4 : 0);
            const y = SVG_HEIGHT - barH;
            return (
              <rect
                key={bar.key}
                x={x}
                y={y}
                width={BAR_WIDTH}
                height={barH}
                rx={3}
                fill={bar.color}
                opacity={bar.count > 0 ? 1 : 0.2}
                data-testid={`nova-bar-${bar.key}`}
              />
            );
          })}
        </svg>
      </div>

      {/* Labels under each bar */}
      <div className="mt-1 flex justify-center" style={{ width: SVG_WIDTH }}>
        {bars.map((bar, i) => (
          <div
            key={bar.key}
            className="text-center"
            style={{ width: BAR_WIDTH + (i < bars.length - 1 ? BAR_GAP : 0) }}
          >
            <span className="text-[10px] font-medium text-foreground-secondary">
              {bar.pct}%
            </span>
          </div>
        ))}
      </div>

      {/* Legend */}
      <div className="mt-2 grid grid-cols-2 gap-x-3 gap-y-0.5">
        {bars.map((bar) => (
          <div key={bar.key} className="flex items-center gap-1.5">
            <span
              className="inline-block h-2 w-2 rounded-full"
              style={{ backgroundColor: bar.color }}
              aria-hidden="true"
            />
            <span className="text-[10px] text-foreground-secondary">
              {t(`dashboard.nova.${bar.key}`)} ({bar.count})
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
