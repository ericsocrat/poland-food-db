"use client";

import type { AllergenWarning } from "@/lib/allergen-matching";

// ─── Constants ──────────────────────────────────────────────────────────────

/** Max visible chips before showing "+N more" overflow badge */
const MAX_VISIBLE = 3;

const CHIP_STYLES = {
  /** "Contains" — red/danger */
  contains:
    "bg-red-50 text-red-700 dark:bg-red-950 dark:text-red-300 border-red-200 dark:border-red-800",
  /** "Traces" — amber/warning */
  traces:
    "bg-amber-50 text-amber-700 dark:bg-amber-950 dark:text-amber-300 border-amber-200 dark:border-amber-800",
} as const;

// ─── Single chip ────────────────────────────────────────────────────────────

interface AllergenChipProps {
  readonly warning: AllergenWarning;
}

function AllergenChip({ warning }: AllergenChipProps) {
  const style = CHIP_STYLES[warning.type];
  const tooltip =
    warning.type === "contains"
      ? `Contains: ${warning.label}`
      : `May contain traces: ${warning.label}`;

  return (
    <span
      className={`inline-flex items-center gap-0.5 rounded-full border px-1.5 py-0.5 text-[10px] font-medium leading-tight ${style}`}
      title={tooltip}
      data-testid="allergen-chip"
    >
      <span aria-hidden="true">{warning.icon}</span>
      <span className="max-w-[4rem] truncate">{warning.label}</span>
    </span>
  );
}

// ─── Chip container ─────────────────────────────────────────────────────────

interface AllergenChipsProps {
  /** Allergen warnings to render (from matchProductAllergens) */
  readonly warnings: readonly AllergenWarning[];
}

/**
 * Renders compact allergen warning chips for product cards.
 *
 * - Red chips for "contains" allergens
 * - Amber chips for "may contain traces"
 * - Max 3 visible + "+N more" overflow badge
 * - Returns null when no warnings
 */
export function AllergenChips({ warnings }: AllergenChipsProps) {
  if (warnings.length === 0) return null;

  const visible = warnings.slice(0, MAX_VISIBLE);
  const overflow = warnings.length - MAX_VISIBLE;

  return (
    <div
      className="flex flex-wrap items-center gap-1"
      data-testid="allergen-chips"
      role="status"
      aria-label={`${warnings.length} allergen warning${warnings.length !== 1 ? "s" : ""}`}
    >
      {visible.map((w) => (
        <AllergenChip key={`${w.tag}-${w.type}`} warning={w} />
      ))}
      {overflow > 0 && (
        <span
          className="inline-flex items-center rounded-full bg-surface-muted px-1.5 py-0.5 text-[10px] font-medium text-foreground-muted"
          title={warnings
            .slice(MAX_VISIBLE)
            .map((w) => w.label)
            .join(", ")}
          data-testid="allergen-overflow"
        >
          +{overflow}
        </span>
      )}
    </div>
  );
}
