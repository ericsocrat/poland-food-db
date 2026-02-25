// ─── ScoringVersionBadge ────────────────────────────────────────────────────
// Shows the scoring formula version that computed the product's score.
//
// Display: "Score v3.2" (small, unobtrusive)
// Tooltip: "This product was scored using formula v3.2 (9-factor model)."
//
// Degrades gracefully: returns null when version is undefined/null.
// Backend dependency: scoring_version_id from #189 — not yet implemented.

"use client";

import { FlaskConical } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

interface ScoringVersionBadgeProps {
  /** Scoring formula version string (e.g., "3.2"). Null/undefined → render nothing. */
  readonly version: string | null | undefined;
  /** Number of scoring factors (e.g., 9). Used in tooltip. */
  readonly factors?: number;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function ScoringVersionBadge({
  version,
  factors = 9,
}: ScoringVersionBadgeProps) {
  const { t } = useTranslation();

  if (!version) return null;

  const label = t("trust.scoringVersion.label", { version });
  const tooltip = t("trust.scoringVersion.tooltip", { version, factors });

  return (
    <span
      role="note"
      title={tooltip}
      aria-label={t("trust.scoringVersion.ariaLabel", { version })}
      className="inline-flex items-center gap-1 rounded-md bg-muted px-1.5 py-0.5 text-xs font-medium text-foreground-secondary"
    >
      <FlaskConical size={12} aria-hidden="true" />
      {label}
    </span>
  );
}
