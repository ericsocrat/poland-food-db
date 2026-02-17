"use client";

import { CONCERN_TIER_STYLES } from "@/lib/constants";
import { InfoTooltip } from "@/components/common/InfoTooltip";

interface ConcernBadgeProps {
  readonly tier: number;
  readonly label: string;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
}

/**
 * Pill badge showing concern-tier level (0 = No concern … 3 = High concern).
 */
export function ConcernBadge({
  tier,
  label,
  showTooltip = false,
}: ConcernBadgeProps) {
  const style = CONCERN_TIER_STYLES[tier] ?? CONCERN_TIER_STYLES[0];

  const badge = (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold ${style.bg} ${style.color}`}
      data-testid="concern-badge"
    >
      {tierIcon(tier)} {label}
    </span>
  );

  if (showTooltip && tier >= 0 && tier <= 3) {
    return (
      <InfoTooltip messageKey={`tooltip.concern.${tier}`}>{badge}</InfoTooltip>
    );
  }

  return badge;
}

function tierIcon(tier: number): string {
  switch (tier) {
    case 0:
      return "✅";
    case 1:
      return "⚠️";
    case 2:
      return "🔶";
    case 3:
      return "🔴";
    default:
      return "❓";
  }
}
