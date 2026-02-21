"use client";

// ─── Recipe detail page — full ingredients, steps, and metadata ─────────────
// Issue #53 — Recipes v0

import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getRecipeDetail } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { Card, Chip } from "@/components/common";
import { Icon } from "@/components/common/Icon";
import { RecipeGridSkeleton } from "@/components/common/skeletons";
import { IngredientProductList } from "@/components/recipes";
import { useTranslation } from "@/lib/i18n";
import { Clock, Users, ChefHat, Timer } from "lucide-react";

/* ── Difficulty styling ──────────────────────────────────────────────────── */

const DIFFICULTY_STYLE: Record<string, string> = {
  easy: "text-success",
  medium: "text-warning",
  hard: "text-error",
};

/* ── Component ───────────────────────────────────────────────────────────── */

export default function RecipeDetailPage() {
  const params = useParams();
  const slug = params.slug as string;
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();

  const { data: recipe, isLoading, error } = useQuery({
    queryKey: queryKeys.recipe(slug),
    queryFn: async () => {
      const result = await getRecipeDetail(supabase, slug);
      if (!result.ok) throw new Error(result.error.message);
      if (!result.data) throw new Error("Recipe not found");
      return result.data;
    },
    staleTime: staleTimes.recipe,
    enabled: Boolean(slug),
  });

  if (isLoading) return <RecipeGridSkeleton />;

  if (error || !recipe) {
    return (
      <div className="py-12 text-center">
        <p className="mb-3 text-sm text-red-500">{t("recipes.loadFailed")}</p>
        <button
          type="button"
          className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
          onClick={() =>
            queryClient.invalidateQueries({ queryKey: queryKeys.recipe(slug) })
          }
        >
          {t("common.retry")}
        </button>
      </div>
    );
  }

  const totalTime = recipe.prep_time_min + recipe.cook_time_min;

  return (
    <div className="space-y-6">
      {/* Breadcrumbs */}
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.recipes", href: "/app/recipes" },
          { labelKey: recipe.title_key },
        ]}
      />

      {/* ── Header ─────────────────────────────────────────────────── */}
      <div>
        <h1 className="text-xl font-bold text-foreground lg:text-2xl">
          {t(recipe.title_key)}
        </h1>
        <p className="mt-1 text-sm text-foreground-secondary">
          {t(recipe.description_key)}
        </p>
      </div>

      {/* ── Meta strip ─────────────────────────────────────────────── */}
      <div className="flex flex-wrap items-center gap-4 text-sm text-foreground-secondary">
        <span className="inline-flex items-center gap-1">
          <Icon icon={Timer} size="sm" />
          {t("recipes.prepTime")}: {recipe.prep_time_min} {t("recipes.minutes")}
        </span>
        <span className="inline-flex items-center gap-1">
          <Icon icon={Clock} size="sm" />
          {t("recipes.cookTime")}: {recipe.cook_time_min} {t("recipes.minutes")}
        </span>
        <span className="inline-flex items-center gap-1">
          <Icon icon={Clock} size="sm" />
          {t("recipes.totalTime")}: {totalTime} {t("recipes.minutes")}
        </span>
        <span
          className={`inline-flex items-center gap-1 font-medium ${DIFFICULTY_STYLE[recipe.difficulty] ?? ""}`}
        >
          <Icon icon={ChefHat} size="sm" />
          {t(`recipes.difficulty.${recipe.difficulty}`)}
        </span>
        <span className="inline-flex items-center gap-1">
          <Icon icon={Users} size="sm" />
          {recipe.servings} {t("recipes.servings")}
        </span>
      </div>

      {/* ── Tags ───────────────────────────────────────────────────── */}
      {recipe.tags.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {recipe.tags.map((tag) => (
            <Chip key={tag} variant="default">
              {tag}
            </Chip>
          ))}
        </div>
      )}

      {/* ── Ingredients ────────────────────────────────────────────── */}
      <Card variant="outlined" padding="md">
        <h2 className="mb-3 text-base font-semibold text-foreground">
          {t("recipes.ingredientsTitle")}
        </h2>
        <ul className="space-y-2">
          {recipe.ingredients.map((ing) => (
            <li
              key={ing.name_key}
              className="text-sm text-foreground"
            >
              <div className="flex items-start gap-2">
                <span className="mt-0.5 h-4 w-4 shrink-0 rounded border border-border" />
                <span>
                  {t(ing.name_key)}
                  {ing.optional && (
                    <span className="ml-1 text-xs text-foreground-secondary">
                      ({t("recipes.optional")})
                    </span>
                  )}
                </span>
              </div>
              {ing.linked_products && ing.linked_products.length > 0 && (
                <IngredientProductList products={ing.linked_products} />
              )}
            </li>
          ))}
        </ul>
      </Card>

      {/* ── Steps ──────────────────────────────────────────────────── */}
      <Card variant="outlined" padding="md">
        <h2 className="mb-3 text-base font-semibold text-foreground">
          {t("recipes.stepsTitle")}
        </h2>
        <ol className="space-y-4">
          {recipe.steps.map((step) => (
            <li key={step.step_number} className="flex gap-3 text-sm">
              <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-bold text-on-primary">
                {step.step_number}
              </span>
              <p className="text-foreground">{t(step.content_key)}</p>
            </li>
          ))}
        </ol>
      </Card>
    </div>
  );
}
