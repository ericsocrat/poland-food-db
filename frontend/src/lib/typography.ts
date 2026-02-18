// ─── Desktop Typography & Density Scale ─────────────────────────────────────
// Issue #76 — Systematic responsive scaling for desktop breakpoints.
//
// All classes use Tailwind responsive prefixes (mobile-first).
// Mobile sizes remain unchanged — desktop sizes added via lg: prefix.
//
// Usage:
//   import { typography, spacing } from "@/lib/typography";
//   <h1 className={typography.pageTitle}>...</h1>
//   <div className={spacing.sectionGap}>...</div>

/**
 * Responsive typography class map.
 * Each key maps a semantic role to the exact Tailwind classes
 * including responsive scaling for desktop (lg+).
 */
export const typography = {
  /** Page-level title (h1). Mobile: text-xl → Desktop: text-2xl */
  pageTitle: "text-xl font-bold text-foreground lg:text-2xl",

  /** Dashboard greeting — largest heading. Mobile: text-xl → Desktop: text-3xl */
  greeting: "text-xl font-bold text-foreground sm:text-2xl lg:text-3xl",

  /** Section heading (h2). Mobile: text-lg → Desktop: text-xl */
  sectionHeading: "text-lg font-semibold text-foreground lg:text-xl",

  /** Card section heading (h3). Mobile: text-sm → Desktop: text-base */
  cardHeading:
    "text-sm font-semibold text-foreground-secondary lg:text-base",

  /** Stat / hero numbers. Mobile: text-xl → Desktop: text-2xl */
  statValue: "text-xl font-bold text-foreground lg:text-2xl",

  /** Body text. Scales on desktop for readability. text-sm → lg:text-base */
  body: "text-sm lg:text-base",

  /** Supporting / secondary body text. Stays text-sm on desktop. */
  bodySecondary: "text-sm text-foreground-secondary",

  /** Muted metadata / captions. text-xs → lg:text-sm on desktop. */
  caption: "text-xs text-foreground-secondary lg:text-sm",

  /** Small muted text that stays xs. */
  muted: "text-xs text-foreground-muted",

  /** Interactive label (buttons, nav items). text-sm, no scaling. */
  label: "text-sm font-medium",

  /** Section "View all" link. */
  sectionLink:
    "text-sm font-medium text-brand-600 hover:text-brand-700",
} as const;

/**
 * Responsive spacing class map.
 * Provides consistent padding / gap scaling for desktop.
 */
export const spacing = {
  /** Page-level vertical spacing between sections. */
  pageStack: "space-y-6 lg:space-y-8",

  /** Section-level vertical spacing between items. */
  sectionStack: "space-y-2 lg:space-y-3",

  /** Grid gap for card grids. */
  gridGap: "gap-3 lg:gap-4",

  /** Section heading bottom margin. */
  sectionHeadingMargin: "mb-2 lg:mb-3",
} as const;
