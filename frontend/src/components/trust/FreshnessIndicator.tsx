// ─── FreshnessIndicator ─────────────────────────────────────────────────────
// Visual indicator of product data age with freshness ring.
//
// Default thresholds (configurable via props):
//   ≤7 days   → "Fresh" (green ring + clock icon)
//   ≤30 days  → "Aging" (amber ring + alert icon)
//   >30 days  → "Stale" (red ring + alert icon)
//
// The freshness ring is a circular SVG indicator that decays from full (green)
// through partial (amber) to empty (red) based on data age.
//
// Degrades gracefully: returns null when lastVerifiedAt is undefined/null.
// Backend dependency: field_provenance sourced_at (#193) — not yet implemented.

"use client";

import { Clock, AlertTriangle, AlertCircle } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

type FreshnessStatus = "fresh" | "aging" | "stale";

interface FreshnessIndicatorProps {
  /** ISO date string of last verification. Null/undefined/empty → render nothing. */
  readonly lastVerifiedAt: string | null | undefined;
  /** Display mode: compact for cards, full for detail pages. */
  readonly mode?: "compact" | "full";
  /** Days threshold for fresh status (default: 7). */
  readonly freshDays?: number;
  /** Days threshold for aging status (default: 30). Values above → stale. */
  readonly agingDays?: number;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function getDaysSince(dateStr: string): number {
  const diff = Date.now() - new Date(dateStr).getTime();
  return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
}

function getFreshnessStatus(
  days: number,
  freshDays: number,
  agingDays: number,
): FreshnessStatus {
  if (days <= freshDays) return "fresh";
  if (days <= agingDays) return "aging";
  return "stale";
}

const FRESHNESS_CONFIG: Record<
  FreshnessStatus,
  {
    icon: typeof Clock;
    colorClass: string;
    ringColor: string;
    labelKey: string;
  }
> = {
  fresh: {
    icon: Clock,
    colorClass: "text-green-600 dark:text-green-400",
    ringColor: "var(--color-confidence-high, #22c55e)",
    labelKey: "trust.freshness.fresh",
  },
  aging: {
    icon: AlertTriangle,
    colorClass: "text-amber-600 dark:text-amber-400",
    ringColor: "var(--color-confidence-medium, #f59e0b)",
    labelKey: "trust.freshness.aging",
  },
  stale: {
    icon: AlertCircle,
    colorClass: "text-red-600 dark:text-red-400",
    ringColor: "var(--color-confidence-low, #ef4444)",
    labelKey: "trust.freshness.stale",
  },
};

// ─── Freshness Ring SVG ─────────────────────────────────────────────────────

const RING_SIZE = 20;
const RING_RADIUS = 7;
const RING_CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;

function FreshnessRing({
  status,
  progress,
}: Readonly<{ status: FreshnessStatus; progress: number }>) {
  const config = FRESHNESS_CONFIG[status];
  const dashOffset = RING_CIRCUMFERENCE * (1 - progress);

  return (
    <svg
      width={RING_SIZE}
      height={RING_SIZE}
      viewBox={`0 0 ${RING_SIZE} ${RING_SIZE}`}
      aria-hidden="true"
      data-testid="freshness-ring"
      className="shrink-0"
    >
      {/* Background track */}
      <circle
        cx={RING_SIZE / 2}
        cy={RING_SIZE / 2}
        r={RING_RADIUS}
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        opacity={0.15}
      />
      {/* Progress arc */}
      <circle
        cx={RING_SIZE / 2}
        cy={RING_SIZE / 2}
        r={RING_RADIUS}
        fill="none"
        stroke={config.ringColor}
        strokeWidth={2}
        strokeDasharray={RING_CIRCUMFERENCE}
        strokeDashoffset={dashOffset}
        strokeLinecap="round"
        transform={`rotate(-90 ${RING_SIZE / 2} ${RING_SIZE / 2})`}
      />
    </svg>
  );
}

// ─── Component ──────────────────────────────────────────────────────────────

export function FreshnessIndicator({
  lastVerifiedAt,
  mode = "compact",
  freshDays = 7,
  agingDays = 30,
}: FreshnessIndicatorProps) {
  const { t } = useTranslation();

  if (!lastVerifiedAt) return null;

  const days = getDaysSince(lastVerifiedAt);
  const status = getFreshnessStatus(days, freshDays, agingDays);
  const config = FRESHNESS_CONFIG[status];
  const Icon = config.icon;
  const label = t(config.labelKey, { days });
  const tooltipDate = t("trust.freshness.tooltipDate", {
    date: new Date(lastVerifiedAt).toLocaleDateString(),
  });

  // Progress decays from 1.0 (today) to 0.0 (at agingDays*2 or beyond).
  // Clamped to [0, 1].
  const maxDays = agingDays * 2;
  const progress = Math.max(0, Math.min(1, 1 - days / maxDays));

  return (
    <span
      role="status"
      title={tooltipDate}
      aria-label={t("trust.freshness.ariaLabel", { status: label })}
      className={`inline-flex items-center gap-1.5 ${config.colorClass} ${
        mode === "compact" ? "text-xs" : "text-sm"
      }`}
    >
      <FreshnessRing status={status} progress={progress} />
      <Icon size={mode === "compact" ? 12 : 14} aria-hidden="true" />
      {label}
    </span>
  );
}

// ─── Exported helpers (for testing) ─────────────────────────────────────────

export { getDaysSince, getFreshnessStatus };
