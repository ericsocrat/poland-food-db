"use client";

import React, { useState } from "react";
import { CONCERN_TIER_STYLES } from "@/lib/constants";
import { CheckCircle, AlertTriangle, ChevronDown } from "lucide-react";
import { InfoTooltip } from "@/components/common/InfoTooltip";

interface ConcernBadgeProps {
  readonly tier: number;
  readonly label: string;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
  /** When set, the badge becomes clickable and expands to show the reason. */
  readonly reason?: string | null;
}

/**
 * Pill badge showing concern-tier level (0 = No concern … 3 = High concern).
 * When `reason` is provided and tier > 0, the badge is clickable and reveals
 * an inline expansion with the concern reason text.
 */
export function ConcernBadge({
  tier,
  label,
  showTooltip = false,
  reason,
}: ConcernBadgeProps) {
  const [expanded, setExpanded] = useState(false);
  const style = CONCERN_TIER_STYLES[tier] ?? CONCERN_TIER_STYLES[0];
  const isExpandable = tier > 0 && !!reason;

  const badge = (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold ${style.bg} ${style.color}`}
      data-testid="concern-badge"
    >
      {tierIcon(tier)} {label}
      {isExpandable && (
        <ChevronDown
          size={12}
          aria-hidden="true"
          className={`transition-transform duration-150 ${expanded ? "rotate-180" : ""}`}
        />
      )}
    </span>
  );

  if (isExpandable) {
    return (
      <div className="inline-flex flex-col" data-testid="concern-expandable">
        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          className="cursor-pointer text-left"
          aria-expanded={expanded}
          aria-label={`${label} — expand concern details`}
        >
          {badge}
        </button>
        {expanded && (
          <p
            className={`mt-1 max-w-xs rounded-lg border px-2.5 py-1.5 text-xs leading-relaxed ${style.bg} ${style.color} ${style.border}`}
            data-testid="concern-detail"
          >
            {reason}
          </p>
        )}
      </div>
    );
  }

  if (showTooltip && tier >= 0 && tier <= 3) {
    return (
      <InfoTooltip messageKey={`tooltip.concern.${tier}`}>{badge}</InfoTooltip>
    );
  }

  return badge;
}

function tierIcon(tier: number): React.ReactNode {
  switch (tier) {
    case 0:
      return <CheckCircle size={12} aria-hidden="true" />;
    case 1:
      return <AlertTriangle size={12} aria-hidden="true" />;
    case 2:
      return "🔶";
    case 3:
      return "🔴";
    default:
      return "❓";
  }
}
