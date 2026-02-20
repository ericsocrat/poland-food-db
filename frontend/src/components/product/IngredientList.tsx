"use client";

// ─── IngredientList ─────────────────────────────────────────────────────────
// Standalone ingredient display: full ingredient text, top-ingredient pills
// with concern-tier color coding, additive vs natural icons, expandable
// concern reasons, and a concern-tier legend.

import { useState } from "react";
import Link from "next/link";
import {
  CONCERN_TIER_STYLES,
  CONCERN_TIER_LABEL_KEYS,
} from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { ProfileIngredients } from "@/lib/types";

interface IngredientListProps {
  readonly ingredients: ProfileIngredients;
}

/** Clean ingredient display name: strip underscores, normalise ALL-CAPS → Title Case */
function cleanIngredientName(raw: string): string {
  let name = raw.replaceAll("_", " ");
  name = name
    .split(/\s+/)
    .map((w) =>
      w === w.toUpperCase() && w.length > 1
        ? w.charAt(0) + w.slice(1).toLowerCase()
        : w,
    )
    .join(" ");
  return name.trim();
}

/** Concern tier legend items */
const CONCERN_TIERS = [
  { tier: 0, key: "product.concernTier.none" },
  { tier: 1, key: "product.concernTier.low" },
  { tier: 2, key: "product.concernTier.medium" },
  { tier: 3, key: "product.concernTier.high" },
] as const;

export function IngredientList({ ingredients }: IngredientListProps) {
  const { t } = useTranslation();
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [showFullText, setShowFullText] = useState(false);

  const hasData =
    ingredients.count > 0 || !!ingredients.ingredients_text;

  if (!hasData) {
    return (
      <div className="rounded-lg border border-dashed border-amber-300 bg-amber-50/50 px-3 py-4 text-center">
        <p className="text-sm text-amber-700">
          {t("product.noIngredientData")}
        </p>
        <p className="mt-1 text-xs text-amber-600/70">
          {t("product.noIngredientDataHint")}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {/* Summary stats */}
      <div className="space-y-1 text-sm text-foreground-secondary">
        <p>
          {t("product.ingredientCount", { count: ingredients.count })}
        </p>
        <p>
          {t("product.additiveCount", {
            count: ingredients.additive_count,
          })}
        </p>
        {ingredients.additive_names && (
          <p className="text-xs text-foreground-muted">
            {ingredients.additive_names}
          </p>
        )}
        <p>
          {t("product.vegan", {
            status: ingredients.vegan_status ?? "unknown",
          })}
        </p>
        <p>
          {t("product.vegetarian", {
            status: ingredients.vegetarian_status ?? "unknown",
          })}
        </p>
      </div>

      {/* Full ingredient text (collapsible) */}
      {ingredients.ingredients_text && (
        <div className="rounded-lg border border-border bg-surface-subtle px-3 py-2">
          <button
            type="button"
            onClick={() => setShowFullText((prev) => !prev)}
            className="flex w-full items-center justify-between text-xs font-medium text-foreground-secondary"
            aria-expanded={showFullText}
          >
            <span>{t("product.fullIngredientText")}</span>
            <span className="text-foreground-muted">
              {showFullText ? "−" : "+"}
            </span>
          </button>
          {showFullText && (
            <p className="mt-2 text-xs leading-relaxed text-foreground-secondary">
              {ingredients.ingredients_text}
            </p>
          )}
        </div>
      )}

      {/* Top ingredients with concern tiers */}
      {ingredients.top_ingredients.length > 0 && (
        <div className="border-t border pt-3">
          <p className="mb-2 text-xs font-medium text-foreground-secondary uppercase">
            {t("product.topIngredients")}
          </p>
          <div className="flex flex-wrap gap-1.5">
            {ingredients.top_ingredients.map((ing) => {
              const style =
                CONCERN_TIER_STYLES[ing.concern_tier] ??
                CONCERN_TIER_STYLES[0];
              const tierKey =
                CONCERN_TIER_LABEL_KEYS[ing.concern_tier] ??
                CONCERN_TIER_LABEL_KEYS[0];
              const isExpanded = expandedId === ing.ingredient_id;
              const hasConcernDetail =
                ing.concern_tier > 0 && !!ing.concern_reason;

              return (
                <div
                  key={ing.ingredient_id}
                  className="inline-flex flex-col"
                >
                  <div className="inline-flex items-center gap-0.5">
                    <Link
                      href={`/app/ingredient/${ing.ingredient_id}`}
                      className={`inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-xs font-medium transition-colors hover:opacity-80 ${style.bg} ${style.color} ${style.border}`}
                    >
                      {ing.is_additive ? "🧪" : "🌿"}{" "}
                      {cleanIngredientName(ing.name)}
                      {ing.concern_tier > 0 && (
                        <span className="ml-0.5 opacity-75">
                          · {t(tierKey)}
                        </span>
                      )}
                    </Link>
                    {hasConcernDetail && (
                      <button
                        type="button"
                        onClick={() =>
                          setExpandedId(
                            isExpanded ? null : ing.ingredient_id,
                          )
                        }
                        className={`ml-0.5 inline-flex h-5 w-5 items-center justify-center rounded-full text-xs transition-colors ${style.color} hover:${style.bg}`}
                        aria-expanded={isExpanded}
                        aria-label={t("product.toggleConcernDetail")}
                      >
                        {isExpanded ? "−" : "ⓘ"}
                      </button>
                    )}
                  </div>
                  {isExpanded && ing.concern_reason && (
                    <p
                      className={`mt-1 ml-1 max-w-xs rounded-lg border px-2 py-1.5 text-xs leading-relaxed ${style.bg} ${style.color} ${style.border}`}
                    >
                      {ing.concern_reason}
                    </p>
                  )}
                </div>
              );
            })}
          </div>

          {/* Concern tier legend */}
          <div className="mt-3 flex flex-wrap gap-2" aria-label={t("product.concernTierLegend")}>
            {CONCERN_TIERS.map(({ tier, key }) => {
              const style =
                CONCERN_TIER_STYLES[tier] ?? CONCERN_TIER_STYLES[0];
              return (
                <span
                  key={tier}
                  className={`inline-flex items-center rounded-full border px-2 py-0.5 text-[10px] font-medium ${style.bg} ${style.color} ${style.border}`}
                >
                  {t(key)}
                </span>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
