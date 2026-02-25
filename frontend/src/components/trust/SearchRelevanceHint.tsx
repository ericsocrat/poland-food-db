// ─── SearchRelevanceHint ────────────────────────────────────────────────────
// Shows why a product appeared in search results.
//
// Displays a subtle hint below the product name indicating which field matched:
//   "Matched: product name" | "Matched: brand" | "Matched: category" | etc.
//
// Only shown in search result context, not on product detail pages.
// Degrades gracefully: returns null when matchType is undefined/null.
// Backend dependency: search relevance metadata from #192 — not yet implemented.

"use client";

import { Search } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

export type SearchMatchType =
  | "name"
  | "brand"
  | "category"
  | "ingredient"
  | "barcode";

interface SearchRelevanceHintProps {
  /** Which field produced the primary search match. Null/undefined → render nothing. */
  readonly matchType: SearchMatchType | null | undefined;
}

// ─── Match type → i18n key mapping ──────────────────────────────────────────

const MATCH_KEY_MAP: Record<SearchMatchType, string> = {
  name: "trust.searchRelevance.matchedName",
  brand: "trust.searchRelevance.matchedBrand",
  category: "trust.searchRelevance.matchedCategory",
  ingredient: "trust.searchRelevance.matchedIngredient",
  barcode: "trust.searchRelevance.matchedBarcode",
};

// ─── Component ──────────────────────────────────────────────────────────────

export function SearchRelevanceHint({ matchType }: SearchRelevanceHintProps) {
  const { t } = useTranslation();

  if (!matchType) return null;

  const labelKey = MATCH_KEY_MAP[matchType];
  if (!labelKey) return null;

  const label = t(labelKey);

  return (
    <span
      role="note"
      aria-label={t("trust.searchRelevance.ariaLabel", { reason: label })}
      className="inline-flex items-center gap-1 text-xs text-foreground-secondary/70"
    >
      <Search size={10} aria-hidden="true" />
      {label}
    </span>
  );
}
