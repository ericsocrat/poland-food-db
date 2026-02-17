/**
 * NutriScoreBadge — EU standard Nutri-Score badge with official colors.
 *
 * Colors are legally mandated (EU Commission Implementing Regulation):
 *   A → #038141, B → #85BB2F, C → #FECB02, D → #EE8100, E → #E63E11
 *
 * Uses `--color-nutri-A` through `--color-nutri-E` design tokens.
 * Falls back gracefully for unknown grades.
 */

import React from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type NutriGrade = "A" | "B" | "C" | "D" | "E";
export type NutriScoreBadgeSize = "sm" | "md" | "lg";

export interface NutriScoreBadgeProps {
  /** Nutri-Score grade A–E. Null/invalid → neutral "?" badge. */
  readonly grade: string | null | undefined;
  /** Size preset. @default "md" */
  readonly size?: NutriScoreBadgeSize;
  /** Additional CSS classes. */
  readonly className?: string;
}

// ─── Grade styling ──────────────────────────────────────────────────────────

const GRADE_CLASSES: Record<NutriGrade, string> = {
  A: "bg-nutri-A text-foreground-inverse",
  B: "bg-nutri-B text-foreground-inverse",
  C: "bg-nutri-C text-foreground",
  D: "bg-nutri-D text-foreground-inverse",
  E: "bg-nutri-E text-foreground-inverse",
};

const VALID_GRADES = new Set<string>(["A", "B", "C", "D", "E"]);

const SIZE_CLASSES: Record<NutriScoreBadgeSize, string> = {
  sm: "h-5 w-5 text-xs",
  md: "h-7 w-7 text-sm",
  lg: "h-9 w-9 text-base",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const NutriScoreBadge = React.memo(function NutriScoreBadge({
  grade,
  size = "md",
  className = "",
}: Readonly<NutriScoreBadgeProps>) {
  const normalized = grade?.toUpperCase() ?? "";
  const isValid = VALID_GRADES.has(normalized);

  if (!isValid && grade != null && process.env.NODE_ENV === "development") {
    console.warn(`NutriScoreBadge: unexpected grade "${grade}", expected A–E`);
  }

  const bgClass = isValid
    ? GRADE_CLASSES[normalized as NutriGrade]
    : "bg-surface-muted text-foreground-muted";
  const displayText = isValid ? normalized : "?";

  return (
    <span
      className={[
        "inline-flex items-center justify-center rounded-md font-bold",
        bgClass,
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={`Nutri-Score ${isValid ? normalized : "unknown"}`}
    >
      {displayText}
    </span>
  );
});
