// ─── CategoryIcon — Lucide-based food category icons ────────────────────────
// Maps category slugs to visually appropriate Lucide icons. Falls back to a
// generic utensils icon for unknown categories.
//
// Issue #65 — Iconography & Illustration System
// All icons use currentColor for automatic dark mode support.

import type { LucideIcon } from "lucide-react";
import {
  Wheat,
  Soup,
  Package,
  Cookie,
  Droplets,
  Milk,
  GlassWater,
  Snowflake,
  Microwave,
  Beef,
  Nut,
  Leaf,
  Fish,
  Popcorn,
  Candy,
  Beer,
  Baby,
  Store,
  UtensilsCrossed,
} from "lucide-react";

/* ── Category → Icon map ─────────────────────────────────────────────────── */

const CATEGORY_ICON_MAP: Record<string, LucideIcon> = {
  bread: Wheat,
  "breakfast-grain-based": Soup,
  "canned-goods": Package,
  cereals: Wheat,
  "chips-pl": Cookie,
  "chips-de": Cookie,
  chips: Cookie,
  condiments: Droplets,
  dairy: Milk,
  drinks: GlassWater,
  "frozen-prepared": Snowflake,
  "instant-frozen": Microwave,
  meat: Beef,
  "nuts-seeds-legumes": Nut,
  "plant-based-alternatives": Leaf,
  sauces: Droplets,
  "seafood-fish": Fish,
  snacks: Popcorn,
  sweets: Candy,
  alcohol: Beer,
  baby: Baby,
  zabka: Store,
};

/** Generic fallback icon for unknown categories. */
const FALLBACK_ICON: LucideIcon = UtensilsCrossed;

/* ── Size scale (matches Icon.tsx) ───────────────────────────────────────── */

const SIZE_MAP = {
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
} as const;

export type CategoryIconSize = keyof typeof SIZE_MAP;

/* ── Props ───────────────────────────────────────────────────────────────── */

export interface CategoryIconProps {
  /** Food category slug (e.g. "dairy", "bread", "meat"). */
  readonly slug: string;
  /** Icon size preset. @default "lg" (24px) */
  readonly size?: CategoryIconSize;
  /** aria-label for informational usage. Omit for decorative. */
  readonly label?: string;
  /** Additional CSS classes. */
  readonly className?: string;
}

/* ── Component ───────────────────────────────────────────────────────────── */

/**
 * Renders a food category icon using Lucide icons.
 *
 * @example
 * // Decorative (alongside text label)
 * <CategoryIcon slug="dairy" size="md" />
 *
 * // Informational (standalone)
 * <CategoryIcon slug="dairy" size="lg" label="Dairy products" />
 */
export function CategoryIcon({
  slug,
  size = "lg",
  label,
  className = "",
}: CategoryIconProps) {
  const IconComponent = CATEGORY_ICON_MAP[slug] ?? FALLBACK_ICON;
  const px = SIZE_MAP[size];
  const isDecorative = !label;

  return (
    <IconComponent
      size={px}
      className={className}
      aria-hidden={isDecorative ? "true" : undefined}
      aria-label={label}
      role={label ? "img" : undefined}
    />
  );
}

/* ── Utility: check if a category has a dedicated icon ───────────────────── */

/** Returns true if the category slug has a dedicated icon (not fallback). */
export function hasCategoryIcon(slug: string): boolean {
  return slug in CATEGORY_ICON_MAP;
}

/** Returns the list of all supported category slugs. */
export function getSupportedCategorySlugs(): string[] {
  return Object.keys(CATEGORY_ICON_MAP);
}
