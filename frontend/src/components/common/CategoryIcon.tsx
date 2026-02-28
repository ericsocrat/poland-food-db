// ─── CategoryIcon — Custom food category icons (outline + filled) ───────────
// 20 category icons with outline and filled variants, plus Lucide fallback.
// All icons use currentColor for automatic dark mode support.
// SVG source files: frontend/public/icons/categories/
//
// Issue #419 — 20 category icons (outline + filled variants, 40 SVGs total)
// Issue #65 — Iconography & Illustration System

import { UtensilsCrossed } from "lucide-react";

/* ── Icon path data (inline for currentColor support) ────────────────────── */

interface IconPathData {
  readonly outline: string;
  readonly filled: string;
  readonly title: string;
}

const ICON_PATHS: Record<string, IconPathData> = {
  alcohol: {
    title: "Alcohol",
    outline:
      '<path d="M8 2h8l-2 7H10L8 2z"/><path d="M12 9v8"/><path d="M8 21h8"/><path d="M10 17h4"/>',
    filled:
      '<path d="M8 2h8l-2 7H10L8 2z"/><rect x="11" y="9" width="2" height="8" rx="1"/><rect x="8" y="20" width="8" height="1.5" rx=".75"/><rect x="10" y="16" width="4" height="1.5" rx=".75"/>',
  },
  baby: {
    title: "Baby Food",
    outline:
      '<path d="M9 2v4"/><path d="M9 6a3 3 0 0 1 3-3"/><rect x="6" y="8" width="12" height="12" rx="3"/><path d="M6 14h12"/><circle cx="10" cy="11" r=".5"/><circle cx="14" cy="11" r=".5"/>',
    filled:
      '<path d="M9 2v3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><path d="M9 6a3 3 0 0 1 3-3" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/><rect x="6" y="8" width="12" height="12" rx="3"/><rect x="6" y="13.5" width="12" height="6.5" fill-opacity=".15"/><circle cx="10" cy="11" r=".75" fill="white"/><circle cx="14" cy="11" r=".75" fill="white"/>',
  },
  bread: {
    title: "Bread",
    outline:
      '<ellipse cx="12" cy="8" rx="8" ry="4"/><path d="M4 8v6c0 2.2 3.6 4 8 4s8-1.8 8-4V8"/><path d="M8 8v7"/><path d="M12 8v8"/>',
    filled:
      '<ellipse cx="12" cy="8" rx="8" ry="4"/><path d="M4 8v6c0 2.2 3.6 4 8 4s8-1.8 8-4V8z" fill-opacity=".85"/><rect x="7.5" y="8" width="1" height="7" rx=".5" fill="white" fill-opacity=".3"/><rect x="11.5" y="8" width="1" height="8" rx=".5" fill="white" fill-opacity=".3"/>',
  },
  "breakfast-grain-based": {
    title: "Breakfast & Grain",
    outline:
      '<path d="M3 15c0 3.3 4 6 9 6s9-2.7 9-6"/><path d="M3 15c0-1.7 1.3-3.2 3.3-4.2"/><path d="M21 15c0-1.7-1.3-3.2-3.3-4.2"/><ellipse cx="12" cy="12" rx="6" ry="3"/><path d="M2 19l3-4"/><path d="M12 6V3"/><path d="M9 7l-1-3"/><path d="M15 7l1-3"/>',
    filled:
      '<ellipse cx="12" cy="15" rx="9" ry="6"/><ellipse cx="12" cy="12" rx="6" ry="3" fill="white" fill-opacity=".3"/><path d="M2 19l3-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/><rect x="11" y="3" width="2" height="4" rx="1" fill-opacity=".7"/><rect x="8" y="3.5" width="1.5" height="3.5" rx=".75" transform="rotate(-15 9 5)" fill-opacity=".5"/><rect x="14.5" y="3.5" width="1.5" height="3.5" rx=".75" transform="rotate(15 15 5)" fill-opacity=".5"/>',
  },
  "canned-goods": {
    title: "Canned Goods",
    outline:
      '<rect x="5" y="6" width="14" height="14" rx="2"/><path d="M5 10h14"/><rect x="8" y="3" width="8" height="3" rx="1"/><path d="M10 3v3"/><path d="M14 3v3"/>',
    filled:
      '<rect x="8" y="3" width="8" height="3" rx="1"/><rect x="5" y="6" width="14" height="14" rx="2"/><rect x="5" y="6" width="14" height="4" fill="white" fill-opacity=".2"/>',
  },
  cereals: {
    title: "Cereals",
    outline:
      '<path d="M12 3v18"/><path d="M12 7c-3-2-5 0-5 2s2 3 5 1"/><path d="M12 7c3-2 5 0 5 2s-2 3-5 1"/><path d="M12 13c-3-2-5 0-5 2s2 3 5 1"/><path d="M12 13c3-2 5 0 5 2s-2 3-5 1"/>',
    filled:
      '<path d="M12 3v18" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/><path d="M12 7c-3-2-5.5 0-5 2.5s2.5 3 5 .5z"/><path d="M12 7c3-2 5.5 0 5 2.5s-2.5 3-5 .5z"/><path d="M12 13c-3-2-5.5 0-5 2.5s2.5 3 5 .5z"/><path d="M12 13c3-2 5.5 0 5 2.5s-2.5 3-5 .5z"/>',
  },
  chips: {
    title: "Chips",
    outline:
      '<path d="M6 4h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z"/><path d="M4 8h16"/><path d="M9 12c1 2 3 3 6 2"/><path d="M9 15c1 1 3 1 4 0"/>',
    filled:
      '<rect x="4" y="4" width="16" height="16" rx="2"/><rect x="4" y="4" width="16" height="4" rx="2 2 0 0" fill="white" fill-opacity=".2"/><path d="M9 12c1 2 3 3 6 2" stroke="white" stroke-opacity=".4" stroke-width="1.5" stroke-linecap="round" fill="none"/><path d="M9 15c1 1 3 1 4 0" stroke="white" stroke-opacity=".4" stroke-width="1.5" stroke-linecap="round" fill="none"/>',
  },
  condiments: {
    title: "Condiments",
    outline:
      '<path d="M10 2h4v4h-4z"/><path d="M9 6h6l1 4H8l1-4z"/><path d="M8 10h8v10a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2V10z"/><path d="M11 14v4"/><path d="M13 13v4"/>',
    filled:
      '<rect x="10" y="2" width="4" height="4" rx=".5"/><path d="M9 6h6l1 4H8l1-4z"/><path d="M8 10h8v10a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2V10z"/><rect x="10.5" y="14" width="1" height="4" rx=".5" fill="white" fill-opacity=".3"/><rect x="12.5" y="13" width="1" height="4" rx=".5" fill="white" fill-opacity=".3"/>',
  },
  dairy: {
    title: "Dairy",
    outline:
      '<path d="M8 2h8l-1 4H9L8 2z"/><rect x="7" y="6" width="10" height="14" rx="2"/><path d="M7 10h10"/><path d="M10 13c0 1.1.9 2 2 2s2-.9 2-2"/>',
    filled:
      '<path d="M8 2h8l-1 4H9L8 2z"/><rect x="7" y="6" width="10" height="14" rx="2"/><rect x="7" y="6" width="10" height="4" fill="white" fill-opacity=".2"/><path d="M10 13c0 1.1.9 2 2 2s2-.9 2-2" stroke="white" stroke-opacity=".4" stroke-width="1.5" fill="none" stroke-linecap="round"/>',
  },
  drinks: {
    title: "Drinks",
    outline:
      '<path d="M8 2h8"/><path d="M9 2l-1 7h8l-1-7"/><path d="M7 9h10v10a3 3 0 0 1-3 3h-4a3 3 0 0 1-3-3V9z"/><path d="M17 12h2a2 2 0 0 1 0 4h-2"/>',
    filled:
      '<path d="M8 2h8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/><path d="M9 2l-1 7h8l-1-7z" fill-opacity=".5"/><path d="M7 9h10v10a3 3 0 0 1-3 3h-4a3 3 0 0 1-3-3V9z"/><path d="M17 12h2a2 2 0 0 1 0 4h-2" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/>',
  },
  "frozen-prepared": {
    title: "Frozen & Prepared",
    outline:
      '<path d="M12 2v20"/><path d="M5 5l14 14"/><path d="M19 5L5 19"/><path d="M12 2l-2 3h4l-2-3"/><path d="M12 22l-2-3h4l-2 3"/><path d="M19 5l-3 2v-4l3 2"/><path d="M5 19l3-2v4l-3-2"/><path d="M5 5l3 2v-4L5 5"/><path d="M19 19l-3-2v4l3-2"/>',
    filled:
      '<circle cx="12" cy="12" r="10" fill-opacity=".15"/><path d="M12 2v20" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/><path d="M5 5l14 14" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/><path d="M19 5L5 19" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/><path d="M12 2l-2 3h4z"/><path d="M12 22l-2-3h4z"/><path d="M19 5l-3 2v-4z"/><path d="M5 19l3-2v4z"/><path d="M5 5l3 2v-4z"/><path d="M19 19l-3-2v4z"/>',
  },
  "instant-frozen": {
    title: "Instant & Frozen",
    outline:
      '<rect x="3" y="4" width="18" height="14" rx="2"/><path d="M3 8h18"/><rect x="7" y="11" width="4" height="4" rx=".5"/><path d="M15 11v4"/><path d="M13 13h4"/><circle cx="18" cy="6" r=".5"/>',
    filled:
      '<rect x="3" y="4" width="18" height="14" rx="2"/><rect x="3" y="4" width="18" height="4" rx="2 2 0 0" fill="white" fill-opacity=".2"/><rect x="7" y="11" width="4" height="4" rx=".5" fill="white" fill-opacity=".4"/><circle cx="18" cy="6" r=".75" fill="white"/>',
  },
  meat: {
    title: "Meat",
    outline:
      '<path d="M15 3c3 0 6 3 6 6 0 2-1 3-3 4l-6 6c-2 2-5 2-7 0s-2-5 0-7l6-6c1-2 2-3 4-3z"/><path d="M11 11l-3 3"/><circle cx="15" cy="7" r="1"/>',
    filled:
      '<path d="M15 3c3 0 6 3 6 6 0 2-1 3-3 4l-6 6c-2 2-5 2-7 0s-2-5 0-7l6-6c1-2 2-3 4-3z"/><circle cx="15" cy="7" r="1.5" fill="white" fill-opacity=".4"/><path d="M11 11l-3 3" stroke="white" stroke-opacity=".3" stroke-width="1.5" stroke-linecap="round" fill="none"/>',
  },
  "nuts-seeds-legumes": {
    title: "Nuts, Seeds & Legumes",
    outline:
      '<ellipse cx="9" cy="12" rx="5" ry="7"/><path d="M9 5c3 0 6 3 6 7s-3 7-6 7"/><path d="M9 5v14"/><circle cx="16" cy="7" r="3"/><path d="M16 4v6"/>',
    filled:
      '<ellipse cx="9" cy="12" rx="5" ry="7"/><path d="M9 5c3 0 6 3 6 7s-3 7-6 7z" fill="white" fill-opacity=".2"/><circle cx="16" cy="7" r="3"/><path d="M16 4v6" stroke="white" stroke-opacity=".3" stroke-width="1.5" stroke-linecap="round" fill="none"/>',
  },
  "plant-based-alternatives": {
    title: "Plant-Based & Alternatives",
    outline:
      '<path d="M12 22V12"/><path d="M12 12C12 7 7 2 2 2c0 5 5 10 10 10"/><path d="M12 15c0-4 4-8 8-8 0 4-4 8-8 8"/><path d="M7 7l5 5"/><path d="M17 10l-5 5"/>',
    filled:
      '<path d="M12 22V12" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/><path d="M12 12C12 7 7 2 2 2c0 5 5 10 10 10z"/><path d="M12 15c0-4 4-8 8-8 0 4-4 8-8 8z" fill-opacity=".7"/>',
  },
  sauces: {
    title: "Sauces",
    outline:
      '<path d="M10 2h4v3h-4z"/><path d="M9 5h6a1 1 0 0 1 1 1v2H8V6a1 1 0 0 1 1-1z"/><path d="M7 8h10l-1 12a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2L7 8z"/><path d="M10 12v5"/><path d="M14 11v5"/>',
    filled:
      '<rect x="10" y="2" width="4" height="3" rx=".5"/><path d="M9 5h6a1 1 0 0 1 1 1v2H8V6a1 1 0 0 1 1-1z"/><path d="M7 8h10l-1 12a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2L7 8z"/><rect x="9.5" y="12" width="1" height="5" rx=".5" fill="white" fill-opacity=".3"/><rect x="13.5" y="11" width="1" height="5" rx=".5" fill="white" fill-opacity=".3"/>',
  },
  "seafood-fish": {
    title: "Seafood & Fish",
    outline:
      '<path d="M2 12c3-4 7-6 11-6 2 0 3.5.5 5 1.5L22 12l-4 4.5c-1.5 1-3 1.5-5 1.5-4 0-8-2-11-6z"/><circle cx="17" cy="11" r="1"/><path d="M2 12l3-2v4l-3-2"/><path d="M10 9c1 2 1 4 0 6"/>',
    filled:
      '<path d="M2 12c3-4 7-6 11-6 2 0 3.5.5 5 1.5L22 12l-4 4.5c-1.5 1-3 1.5-5 1.5-4 0-8-2-11-6z"/><circle cx="17" cy="11" r="1" fill="white"/><path d="M10 9c1 2 1 4 0 6" stroke="white" stroke-opacity=".3" stroke-width="1.5" fill="none" stroke-linecap="round"/>',
  },
  snacks: {
    title: "Snacks",
    outline:
      '<circle cx="12" cy="12" r="9"/><path d="M12 3c-2 3-2 6 0 9s2 6 0 9"/><path d="M12 3c2 3 2 6 0 9s-2 6 0 9"/><path d="M3 12h18"/>',
    filled:
      '<circle cx="12" cy="12" r="9"/><path d="M12 3c-2 3-2 6 0 9s2 6 0 9" stroke="white" stroke-opacity=".2" stroke-width="1.5" fill="none"/><path d="M12 3c2 3 2 6 0 9s-2 6 0 9" stroke="white" stroke-opacity=".2" stroke-width="1.5" fill="none"/><path d="M3 12h18" stroke="white" stroke-opacity=".2" stroke-width="1.5" fill="none"/>',
  },
  sweets: {
    title: "Sweets",
    outline:
      '<path d="M9 6.5L7 3"/><path d="M15 6.5L17 3"/><rect x="5" y="6" width="14" height="10" rx="5"/><path d="M5 11h14"/><path d="M9 18v3"/><path d="M15 18v3"/>',
    filled:
      '<path d="M9 6.5L7 3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/><path d="M15 6.5L17 3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/><rect x="5" y="6" width="14" height="10" rx="5"/><rect x="5" y="11" width="14" height="5" rx="0 0 5 5" fill="white" fill-opacity=".2"/><path d="M9 18v3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/><path d="M15 18v3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" fill="none"/>',
  },
  zabka: {
    title: "Żabka",
    outline:
      '<ellipse cx="12" cy="14" rx="8" ry="6"/><circle cx="8" cy="8" r="3"/><circle cx="16" cy="8" r="3"/><circle cx="8" cy="7.5" r="1"/><circle cx="16" cy="7.5" r="1"/><path d="M10 16c1 1 3 1 4 0"/>',
    filled:
      '<ellipse cx="12" cy="14" rx="8" ry="6"/><circle cx="8" cy="8" r="3"/><circle cx="16" cy="8" r="3"/><circle cx="8" cy="7.5" r="1.5" fill="white"/><circle cx="16" cy="7.5" r="1.5" fill="white"/><circle cx="8.3" cy="7.5" r=".75" fill="black"/><circle cx="16.3" cy="7.5" r=".75" fill="black"/><path d="M10 16c1 1 3 1 4 0" stroke="white" stroke-opacity=".5" stroke-width="1.5" fill="none" stroke-linecap="round"/>',
  },
};

/* ── Slug aliases (normalize DB slugs → icon keys) ───────────────────────── */

const SLUG_ALIASES: Record<string, string> = {
  "chips-pl": "chips",
  "chips-de": "chips",
};

/* ── Size scale (matches Icon.tsx) ───────────────────────────────────────── */

const SIZE_MAP = {
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
} as const;

export type CategoryIconSize = keyof typeof SIZE_MAP;

/** Icon variant — outline stroke or solid fill. */
export type CategoryIconVariant = "outline" | "filled";

/* ── Props ───────────────────────────────────────────────────────────────── */

export interface CategoryIconProps {
  /** Food category slug (e.g. "dairy", "bread", "meat"). */
  readonly slug: string;
  /** Icon variant. @default "outline" */
  readonly variant?: CategoryIconVariant;
  /** Icon size preset. @default "lg" (24px) */
  readonly size?: CategoryIconSize;
  /** aria-label for informational usage. Omit for decorative. */
  readonly label?: string;
  /** Additional CSS classes. */
  readonly className?: string;
}

/* ── Component ───────────────────────────────────────────────────────────── */

/**
 * Renders a food category icon with outline or filled variant.
 * Uses custom inline SVGs for all 20 categories. Falls back to a generic
 * utensils icon for unknown categories.
 *
 * @example
 * // Outline (default, for lists/navigation)
 * <CategoryIcon slug="dairy" size="md" />
 *
 * // Filled (for active/selected states)
 * <CategoryIcon slug="dairy" variant="filled" size="lg" label="Dairy products" />
 */
export function CategoryIcon({
  slug,
  variant = "outline",
  size = "lg",
  label,
  className = "",
}: CategoryIconProps) {
  const resolvedSlug = SLUG_ALIASES[slug] ?? slug;
  const iconData = ICON_PATHS[resolvedSlug];
  const px = SIZE_MAP[size];
  const isDecorative = !label;

  // Fallback to Lucide UtensilsCrossed for unknown slugs
  if (!iconData) {
    return (
      <UtensilsCrossed
        size={px}
        className={className}
        aria-hidden={isDecorative ? "true" : undefined}
        aria-label={label}
      />
    );
  }

  const isOutline = variant === "outline";

  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      width={px}
      height={px}
      fill={isOutline ? "none" : "currentColor"}
      stroke={isOutline ? "currentColor" : "none"}
      strokeWidth={isOutline ? 1.5 : undefined}
      strokeLinecap={isOutline ? "round" : undefined}
      strokeLinejoin={isOutline ? "round" : undefined}
      className={className}
      aria-hidden={isDecorative ? "true" : undefined}
      aria-label={label}
    >
      <title>{iconData.title}</title>
      {/* eslint-disable-next-line react/no-danger */}
      <g dangerouslySetInnerHTML={{ __html: iconData[variant] }} />
    </svg>
  );
}

/* ── Utility: check if a category has a dedicated icon ───────────────────── */

/** Returns true if the category slug has a dedicated icon (not fallback). */
export function hasCategoryIcon(slug: string): boolean {
  const resolved = SLUG_ALIASES[slug] ?? slug;
  return resolved in ICON_PATHS;
}

/** Returns the list of all supported category slugs (including aliases). */
export function getSupportedCategorySlugs(): string[] {
  return [...Object.keys(ICON_PATHS), ...Object.keys(SLUG_ALIASES)];
}
