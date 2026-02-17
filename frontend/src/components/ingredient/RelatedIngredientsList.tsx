"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { ConcernBadge } from "./ConcernBadge";
import type { RelatedIngredient } from "@/lib/types";

interface RelatedIngredientsListProps {
  readonly ingredients: RelatedIngredient[];
}

/**
 * Card listing ingredients that frequently co-occur with this ingredient.
 * Each row links to that ingredient's profile page.
 */
export function RelatedIngredientsList({
  ingredients,
}: RelatedIngredientsListProps) {
  const { t } = useTranslation();

  // Map tier number → label for the badge
  const tierLabel = (tier: number) => {
    switch (tier) {
      case 0:
        return t("ingredient.tierNone");
      case 1:
        return t("ingredient.tierLow");
      case 2:
        return t("ingredient.tierModerate");
      case 3:
        return t("ingredient.tierHigh");
      default:
        return t("ingredient.tierNone");
    }
  };

  return (
    <div className="card">
      <h2 className="mb-2 text-sm font-semibold text-gray-700">
        {t("ingredient.relatedIngredients")}
      </h2>
      <ul className="divide-y divide-gray-100">
        {ingredients.map((ing) => (
          <li key={ing.ingredient_id}>
            <Link
              href={`/app/ingredient/${ing.ingredient_id}`}
              className="flex items-center gap-3 py-2 hover:bg-gray-50 -mx-1 px-1 rounded"
            >
              <span className="text-lg">{ing.is_additive ? "🧪" : "🌿"}</span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-gray-800">
                  {ing.name_en}
                </p>
                <p className="text-xs text-gray-400">
                  {t("ingredient.coOccurrence", {
                    count: ing.co_occurrence_count,
                  })}
                </p>
              </div>
              <ConcernBadge
                tier={ing.concern_tier}
                label={tierLabel(ing.concern_tier)}
              />
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
