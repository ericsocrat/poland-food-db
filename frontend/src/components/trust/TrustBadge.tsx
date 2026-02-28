// ─── TrustBadge ─────────────────────────────────────────────────────────────
// Per-product overall data confidence indicator.
//
// Shows: High Trust | Moderate Trust | Low Trust
// Based on: trust score (0–1) derived from data confidence.
//
// Thresholds:
//   ≥0.8 → "High Trust" (green, animated shield checkmark)
//   ≥0.5 → "Moderate Trust" (amber)
//   <0.5 → "Low Trust" (gray — unverified, not alarming)
//
// Degrades gracefully: returns null when trustScore is undefined/null.
// Backend dependency: api_product_provenance() (#193) — not yet implemented.

"use client";

import { ShieldCheck, ShieldAlert, ShieldQuestion } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

type TrustLevel = "high" | "moderate" | "low";

interface TrustBadgeProps {
  /** Trust score from 0 to 1. Null/undefined → render nothing. */
  readonly trustScore: number | null | undefined;
  /** Badge size variant. */
  readonly size?: "sm" | "md";
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function getTrustLevel(score: number): TrustLevel {
  if (score >= 0.8) return "high";
  if (score >= 0.5) return "moderate";
  return "low";
}

const TRUST_CONFIG: Record<
  TrustLevel,
  {
    icon: typeof ShieldCheck;
    colorClass: string;
    bgClass: string;
    labelKey: string;
    tooltipKey: string;
    /** CSS class for icon animation (high trust only). */
    iconAnimation?: string;
  }
> = {
  high: {
    icon: ShieldCheck,
    colorClass: "text-green-700 dark:text-green-400",
    bgClass: "bg-green-100 dark:bg-green-900/30",
    labelKey: "trust.badge.high",
    tooltipKey: "trust.badge.highTooltip",
    iconAnimation: "animate-trust-verified",
  },
  moderate: {
    icon: ShieldAlert,
    colorClass: "text-amber-700 dark:text-amber-400",
    bgClass: "bg-amber-100 dark:bg-amber-900/30",
    labelKey: "trust.badge.moderate",
    tooltipKey: "trust.badge.moderateTooltip",
  },
  low: {
    icon: ShieldQuestion,
    colorClass: "text-gray-500 dark:text-gray-400",
    bgClass: "bg-gray-100 dark:bg-gray-800/40",
    labelKey: "trust.badge.low",
    tooltipKey: "trust.badge.lowTooltip",
  },
};

// ─── Component ──────────────────────────────────────────────────────────────

export function TrustBadge({ trustScore, size = "md" }: TrustBadgeProps) {
  const { t } = useTranslation();

  if (trustScore == null) return null;

  const level = getTrustLevel(trustScore);
  const config = TRUST_CONFIG[level];
  const Icon = config.icon;
  const label = t(config.labelKey);
  const tooltip = t(config.tooltipKey);

  const sizeClasses =
    size === "sm" ? "px-1.5 py-0.5 text-xs gap-0.5" : "px-2 py-1 text-sm gap-1";

  return (
    <span
      role="status"
      title={tooltip}
      aria-label={t("trust.badge.ariaLabel", { level: label })}
      className={`inline-flex items-center rounded-full font-medium ${config.colorClass} ${config.bgClass} ${sizeClasses}`}
    >
      <Icon
        size={size === "sm" ? 12 : 14}
        aria-hidden="true"
        className={config.iconAnimation}
        data-testid="trust-icon"
      />
      {label}
    </span>
  );
}
