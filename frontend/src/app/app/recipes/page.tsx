"use client";

// ─── Recipes browse — grid of curated recipe cards with filters ─────────────
// Issue #53 — Recipes v0

import { useState, useCallback, useMemo } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { browseRecipes } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { RecipeGridSkeleton } from "@/components/common/skeletons";
import { EmptyState } from "@/components/common/EmptyState";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { RecipeCard } from "@/components/recipes";
import { useTranslation } from "@/lib/i18n";
import type { RecipeCategory, RecipeDifficulty, BrowseRecipesFilters } from "@/lib/types";

/* ── Filter options (keys map to i18n) ───────────────────────────────────── */

const CATEGORY_OPTIONS: RecipeCategory[] = [
  "breakfast", "lunch", "dinner", "snack", "dessert", "drink", "salad", "soup",
];

const DIFFICULTY_OPTIONS: RecipeDifficulty[] = ["easy", "medium", "hard"];

/* ── Component ───────────────────────────────────────────────────────────── */

export default function RecipesBrowsePage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();

  const [category, setCategory] = useState<RecipeCategory | "">("");
  const [difficulty, setDifficulty] = useState<RecipeDifficulty | "">("");

  const filters = useMemo<BrowseRecipesFilters>(
    () => ({
      ...(category ? { category } : {}),
      ...(difficulty ? { difficulty } : {}),
    }),
    [category, difficulty],
  );

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.recipes(filters as Record<string, unknown>),
    queryFn: async () => {
      const result = await browseRecipes(supabase, filters);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.recipes,
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({ queryKey: queryKeys.recipes(filters as Record<string, unknown>) });
  }, [queryClient, filters]);

  if (isLoading) return <RecipeGridSkeleton />;

  if (error) {
    return (
      <div className="py-12 text-center">
        <p className="mb-3 text-sm text-red-500">{t("recipes.loadFailed")}</p>
        <button
          type="button"
          className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
          onClick={handleRetry}
        >
          {t("common.retry")}
        </button>
      </div>
    );
  }

  return (
    <div>
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.recipes" },
        ]}
      />

      <h1 className="mb-4 text-xl font-bold text-foreground lg:text-2xl">
        {t("recipes.title")}
      </h1>

      {/* ── Filters ──────────────────────────────────────────────────── */}
      <div className="mb-4 flex flex-wrap gap-2">
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value as RecipeCategory | "")}
          className="input rounded-lg px-3 py-2 text-sm"
          aria-label={t("recipes.filterCategory")}
        >
          <option value="">{t("recipes.allCategories")}</option>
          {CATEGORY_OPTIONS.map((c) => (
            <option key={c} value={c}>
              {t(`recipes.category.${c}`)}
            </option>
          ))}
        </select>

        <select
          value={difficulty}
          onChange={(e) => setDifficulty(e.target.value as RecipeDifficulty | "")}
          className="input rounded-lg px-3 py-2 text-sm"
          aria-label={t("recipes.filterDifficulty")}
        >
          <option value="">{t("recipes.allDifficulties")}</option>
          {DIFFICULTY_OPTIONS.map((d) => (
            <option key={d} value={d}>
              {t(`recipes.difficulty.${d}`)}
            </option>
          ))}
        </select>
      </div>

      {/* ── Grid ─────────────────────────────────────────────────────── */}
      {data && data.length > 0 ? (
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3 lg:gap-4">
          {data.map((recipe) => (
            <RecipeCard key={recipe.id} recipe={recipe} />
          ))}
        </div>
      ) : (
        <EmptyState
          variant="no-results"
          titleKey="recipes.emptyTitle"
          descriptionKey="recipes.emptyDescription"
        />
      )}
    </div>
  );
}
