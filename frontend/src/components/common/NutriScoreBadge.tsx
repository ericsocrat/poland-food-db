/**
 * NutriScoreBadge — EU standard Nutri-Score badge with official colors.
 *
 * Colors are legally mandated (EU Commission Implementing Regulation):
 *   A → #038141, B → #85BB2F, C → #FECB02, D → #EE8100, E → #E63E11
 *
 * Uses `--color-nutri-A` through `--color-nutri-E` design tokens.
 *
 * Design variants:
 *   sm  → single-letter square badge (compact inline use)
 *   md  → horizontal strip with all 5 letters, active highlighted
 *   lg  → horizontal strip with all 5 letters, larger sizing
 *
 * Falls back gracefully for UNKNOWN, NOT-APPLICABLE, and invalid grades.
 */

import React from "react";
import { InfoTooltip } from "./InfoTooltip";

// ─── Types ──────────────────────────────────────────────────────────────────

export type NutriGrade = "A" | "B" | "C" | "D" | "E";
export type NutriScoreSpecial = "UNKNOWN" | "NOT-APPLICABLE";
export type NutriScoreBadgeSize = "sm" | "md" | "lg";

export interface NutriScoreBadgeProps {
  /** Nutri-Score grade A–E, UNKNOWN, NOT-APPLICABLE. Null/invalid → neutral fallback. */
  readonly grade: string | null | undefined;
  /** Size preset. sm = single letter, md/lg = 5-letter strip. @default "md" */
  readonly size?: NutriScoreBadgeSize;
  /** Show explanatory tooltip on hover. @default false */
  readonly showTooltip?: boolean;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Constants ──────────────────────────────────────────────────────────────

const ALL_GRADES: readonly NutriGrade[] = ["A", "B", "C", "D", "E"] as const;
const VALID_GRADES = new Set<string>(ALL_GRADES);
const SPECIAL_GRADES = new Set<string>(["UNKNOWN", "NOT-APPLICABLE"]);

/** Active letter styling (bg filled + high-contrast text). */
const ACTIVE_CLASSES: Record<NutriGrade, string> = {
  A: "bg-nutri-A text-foreground-inverse",
  B: "bg-nutri-B text-foreground-inverse",
  C: "bg-nutri-C text-foreground",
  D: "bg-nutri-D text-foreground-inverse",
  E: "bg-nutri-E text-foreground-inverse",
};

/** Inactive letter styling (subtle tinted background). */
const INACTIVE_CLASSES: Record<NutriGrade, string> = {
  A: "bg-nutri-A/15 text-nutri-A",
  B: "bg-nutri-B/15 text-nutri-B",
  C: "bg-nutri-C/15 text-nutri-C",
  D: "bg-nutri-D/15 text-nutri-D",
  E: "bg-nutri-E/15 text-nutri-E",
};

const SM_SIZE = "h-5 w-5 text-xs";

/** Strip letter sizing (md vs lg). */
const STRIP_LETTER_SIZE: Record<
  "md" | "lg",
  { active: string; inactive: string }
> = {
  md: { active: "h-7 w-7 text-sm", inactive: "h-5 w-5 text-[10px]" },
  lg: { active: "h-9 w-9 text-base", inactive: "h-7 w-7 text-xs" },
};

/** Special grade descriptions for aria-label. */
const SPECIAL_LABELS: Record<string, string> = {
  UNKNOWN: "not available",
  "NOT-APPLICABLE": "not applicable",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const NutriScoreBadge = React.memo(function NutriScoreBadge({
  grade,
  size = "md",
  showTooltip = false,
  className = "",
}: Readonly<NutriScoreBadgeProps>) {
  const normalized = grade?.toUpperCase() ?? "";
  const isValid = VALID_GRADES.has(normalized);
  const isSpecial = SPECIAL_GRADES.has(normalized);

  if (
    !isValid &&
    !isSpecial &&
    grade != null &&
    process.env.NODE_ENV === "development"
  ) {
    console.warn(
      `NutriScoreBadge: unexpected grade "${grade}", expected A–E, UNKNOWN, or NOT-APPLICABLE`,
    );
  }

  const tooltipKey = isValid
    ? `tooltip.nutriScore.${normalized}`
    : "tooltip.nutriScore.unknown";

  const ariaLabel = isValid
    ? `Nutri-Score ${normalized}`
    : isSpecial
      ? `Nutri-Score ${SPECIAL_LABELS[normalized]}`
      : "Nutri-Score unknown";

  // ─── sm: single-letter badge ────────────────────────────────────────────

  if (size === "sm") {
    const bgClass = isValid
      ? ACTIVE_CLASSES[normalized as NutriGrade]
      : "bg-surface-muted text-foreground-muted";
    const displayText = isValid ? normalized : isSpecial ? "–" : "?";

    const badge = (
      <span
        className={[
          "inline-flex items-center justify-center rounded-md font-bold",
          bgClass,
          SM_SIZE,
          className,
        ]
          .filter(Boolean)
          .join(" ")}
        aria-label={ariaLabel}
      >
        {displayText}
      </span>
    );

    if (showTooltip) {
      return <InfoTooltip messageKey={tooltipKey}>{badge}</InfoTooltip>;
    }
    return badge;
  }

  // ─── md / lg: horizontal 5-letter strip ─────────────────────────────────

  if (isSpecial) {
    const label = normalized === "NOT-APPLICABLE" ? "N/A" : "?";
    const strip = (
      <span
        className={[
          "inline-flex items-center gap-0.5 rounded-lg bg-surface-muted px-1 py-0.5",
          className,
        ]
          .filter(Boolean)
          .join(" ")}
        aria-label={ariaLabel}
        role="img"
      >
        <span
          className={[
            "inline-flex items-center justify-center rounded-md font-bold text-foreground-muted",
            STRIP_LETTER_SIZE[size].active,
          ].join(" ")}
        >
          {label}
        </span>
      </span>
    );

    if (showTooltip) {
      return <InfoTooltip messageKey={tooltipKey}>{strip}</InfoTooltip>;
    }
    return strip;
  }

  const letterSizes = STRIP_LETTER_SIZE[size];

  const strip = (
    <span
      className={[
        "inline-flex items-center gap-0.5 rounded-lg bg-surface-muted px-1 py-0.5",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={ariaLabel}
      role="img"
    >
      {ALL_GRADES.map((g) => {
        const active = isValid && g === normalized;
        return (
          <span
            key={g}
            className={[
              "inline-flex items-center justify-center rounded-md font-bold transition-all",
              active ? ACTIVE_CLASSES[g] : INACTIVE_CLASSES[g],
              active ? letterSizes.active : letterSizes.inactive,
            ].join(" ")}
            aria-hidden={!active}
          >
            {g}
          </span>
        );
      })}
    </span>
  );

  if (showTooltip) {
    return <InfoTooltip messageKey={tooltipKey}>{strip}</InfoTooltip>;
  }
  return strip;
});
