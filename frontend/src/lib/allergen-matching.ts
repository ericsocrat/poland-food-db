// ─── Allergen matching engine — pure functions for client-side matching ──────
// Compares product allergen data against user preferences to produce warnings.
// All functions are pure (no hooks/side-effects) for easy testing.

import { ALLERGEN_TAGS } from "@/lib/constants";

// ─── Types ──────────────────────────────────────────────────────────────────

/** Raw allergen data returned by api_get_product_allergens for a single product */
export interface ProductAllergenData {
  readonly contains: string[];
  readonly traces: string[];
}

/** Allergen data map keyed by product_id */
export type ProductAllergenMap = Readonly<
  Record<string, ProductAllergenData>
>;

/** A single allergen warning to display on a product card */
export interface AllergenWarning {
  /** Tag identifier, e.g. "milk" */
  readonly tag: string;
  /** Human-readable short label, e.g. "Milk / Dairy" */
  readonly label: string;
  /** Emoji icon for compact display */
  readonly icon: string;
  /** Whether the product "contains" or has "traces" of this allergen */
  readonly type: "contains" | "traces";
}

// ─── Allergen icon mapping ──────────────────────────────────────────────────

/** Emoji icons for the EU-14 mandatory allergens + common aliases */
export const ALLERGEN_ICONS: Readonly<Record<string, string>> = {
  "gluten": "🌾",
  "milk": "🥛",
  "eggs": "🥚",
  "tree-nuts": "🌰",
  "peanuts": "🥜",
  "soybeans": "🫘",
  "fish": "🐟",
  "crustaceans": "🦐",
  "celery": "🌿",
  "mustard": "🟡",
  "sesame": "🫘",
  "sulphites": "🧪",
  "lupin": "🌸",
  "molluscs": "🐚",
};

/** Build a label lookup from ALLERGEN_TAGS constant */
const LABEL_MAP = new Map<string, string>(
  ALLERGEN_TAGS.map((a) => [a.tag, a.label]),
);

// ─── Core matching function ─────────────────────────────────────────────────

/**
 * Match a product's allergens against user preferences and return warnings.
 *
 * @param productAllergens - Raw allergen data for a single product
 * @param userAvoidAllergens - User's avoid_allergens preference (e.g. ["milk", "gluten"])
 * @param treatMayContainAsUnsafe - Whether to include "traces" matches (user preference)
 * @returns Array of AllergenWarning sorted: contains first, then traces, alphabetical within each group
 */
export function matchProductAllergens(
  productAllergens: ProductAllergenData | undefined,
  userAvoidAllergens: readonly string[],
  treatMayContainAsUnsafe: boolean,
): AllergenWarning[] {
  if (!productAllergens || userAvoidAllergens.length === 0) return [];

  const avoidSet = new Set(userAvoidAllergens);
  const warnings: AllergenWarning[] = [];

  // Check "contains" allergens
  for (const tag of productAllergens.contains) {
    if (avoidSet.has(tag)) {
      warnings.push({
        tag,
        label: LABEL_MAP.get(tag) ?? formatTagFallback(tag),
        icon: ALLERGEN_ICONS[tag] ?? "⚠️",
        type: "contains",
      });
    }
  }

  // Check "traces" allergens only when treat_may_contain_as_unsafe is enabled
  if (treatMayContainAsUnsafe) {
    for (const tag of productAllergens.traces) {
      // Avoid duplicates: if already warned via "contains", skip
      if (avoidSet.has(tag) && !warnings.some((w) => w.tag === tag)) {
        warnings.push({
          tag,
          label: LABEL_MAP.get(tag) ?? formatTagFallback(tag),
          icon: ALLERGEN_ICONS[tag] ?? "⚠️",
          type: "traces",
        });
      }
    }
  }

  // Sort: contains first, then traces; alphabetical within each group
  return warnings.sort((a, b) => {
    if (a.type !== b.type) return a.type === "contains" ? -1 : 1;
    return a.tag.localeCompare(b.tag);
  });
}

// ─── Utility ────────────────────────────────────────────────────────────────

/** Convert a "some-tag" to "Some Tag" as a fallback label */
function formatTagFallback(tag: string): string {
  return tag
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}
