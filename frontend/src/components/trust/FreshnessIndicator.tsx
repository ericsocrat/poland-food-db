// ─── FreshnessIndicator ─────────────────────────────────────────────────────
// Visual indicator of product data age.
//
// Shows data age with color-coded status:
//   ≤30 days  → "Verified Xd ago" (green)
//   ≤90 days  → "Data may be outdated (Xd)" (amber)
//   >90 days  → "Stale — last verified Xd ago" (red)
//
// Degrades gracefully: returns null when lastVerifiedAt is undefined/null.
// Backend dependency: field_provenance sourced_at (#193) — not yet implemented.

"use client";

import { Clock, AlertTriangle, AlertCircle } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

type FreshnessStatus = "fresh" | "aging" | "stale";

interface FreshnessIndicatorProps {
  /** ISO date string of last verification. Null/undefined → render nothing. */
  readonly lastVerifiedAt: string | null | undefined;
  /** Display mode: compact for cards, full for detail pages. */
  readonly mode?: "compact" | "full";
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function getDaysSince(dateStr: string): number {
  const diff = Date.now() - new Date(dateStr).getTime();
  return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
}

function getFreshnessStatus(days: number): FreshnessStatus {
  if (days <= 30) return "fresh";
  if (days <= 90) return "aging";
  return "stale";
}

const FRESHNESS_CONFIG: Record<
  FreshnessStatus,
  {
    icon: typeof Clock;
    colorClass: string;
    labelKey: string;
  }
> = {
  fresh: {
    icon: Clock,
    colorClass: "text-green-600 dark:text-green-400",
    labelKey: "trust.freshness.fresh",
  },
  aging: {
    icon: AlertTriangle,
    colorClass: "text-amber-600 dark:text-amber-400",
    labelKey: "trust.freshness.aging",
  },
  stale: {
    icon: AlertCircle,
    colorClass: "text-red-600 dark:text-red-400",
    labelKey: "trust.freshness.stale",
  },
};

// ─── Component ──────────────────────────────────────────────────────────────

export function FreshnessIndicator({
  lastVerifiedAt,
  mode = "compact",
}: FreshnessIndicatorProps) {
  const { t } = useTranslation();

  if (!lastVerifiedAt) return null;

  const days = getDaysSince(lastVerifiedAt);
  const status = getFreshnessStatus(days);
  const config = FRESHNESS_CONFIG[status];
  const Icon = config.icon;
  const label = t(config.labelKey, { days });
  const tooltipDate = t("trust.freshness.tooltipDate", {
    date: new Date(lastVerifiedAt).toLocaleDateString(),
  });

  return (
    <span
      role="status"
      title={tooltipDate}
      aria-label={t("trust.freshness.ariaLabel", { status: label })}
      className={`inline-flex items-center gap-1 ${config.colorClass} ${
        mode === "compact" ? "text-xs" : "text-sm"
      }`}
    >
      <Icon size={mode === "compact" ? 12 : 14} aria-hidden="true" />
      {label}
    </span>
  );
}

// ─── Exported helpers (for testing) ─────────────────────────────────────────

export { getDaysSince, getFreshnessStatus };
