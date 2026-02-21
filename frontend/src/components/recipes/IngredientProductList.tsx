/**
 * IngredientProductList — Expandable list of linked products for a recipe ingredient.
 * Issue #54 — Recipe ↔ Product Linking
 *
 * Shows a compact badge ("N products available") that expands to show
 * product cards sorted by primary → score. Each product links to its
 * detail page and shows a score badge.
 */

"use client";

import { useState } from "react";
import Link from "next/link";
import { ChevronDown, ChevronUp, LinkIcon } from "lucide-react";
import { ScoreBadge } from "@/components/common/ScoreBadge";
import { useTranslation } from "@/lib/i18n";
import type { LinkedProduct } from "@/lib/types";

export interface IngredientProductListProps {
  /** Linked products for this ingredient (may be empty). */
  readonly products: LinkedProduct[];
}

export function IngredientProductList({
  products,
}: Readonly<IngredientProductListProps>) {
  const [expanded, setExpanded] = useState(false);
  const { t } = useTranslation();

  if (products.length === 0) return null;

  return (
    <div className="mt-1 ml-6">
      <button
        type="button"
        onClick={() => setExpanded((prev) => !prev)}
        className="inline-flex items-center gap-1 text-xs text-primary hover:underline"
        aria-expanded={expanded}
      >
        <LinkIcon className="h-3 w-3" />
        {t("recipes.linkedProducts.count", { count: products.length })}
        {expanded ? (
          <ChevronUp className="h-3 w-3" />
        ) : (
          <ChevronDown className="h-3 w-3" />
        )}
      </button>

      {expanded && (
        <ul
          className="mt-1.5 space-y-1.5"
          data-testid="ingredient-product-list"
        >
          {products.map((product) => (
            <li key={product.product_id}>
              <Link
                href={`/app/product/${product.product_id}`}
                className="flex items-center gap-2 rounded-md border border-border bg-surface px-2.5 py-1.5 text-xs hover:bg-surface-muted transition-colors"
              >
                <ScoreBadge score={product.unhealthiness_score} size="sm" />
                <span className="flex-1 truncate font-medium text-foreground">
                  {product.product_name}
                </span>
                {product.brand && (
                  <span className="shrink-0 text-foreground-secondary">
                    {product.brand}
                  </span>
                )}
                {product.is_primary && (
                  <span className="shrink-0 rounded bg-primary/10 px-1.5 py-0.5 text-[10px] font-semibold text-primary">
                    {t("recipes.linkedProducts.primary")}
                  </span>
                )}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
