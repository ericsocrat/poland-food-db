"use client";

// ─── RecipeCard — card component for recipe grid items ──────────────────────
// Displays recipe title, category, difficulty, time, servings, and tags.
// Issue #53 — Recipes v0

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { Card, Chip } from "@/components/common";
import { Clock, Users, ChefHat } from "lucide-react";
import { Icon } from "@/components/common/Icon";
import type { RecipeSummary } from "@/lib/types";

/* ── Difficulty display ──────────────────────────────────────────────────── */

const DIFFICULTY_STYLE: Record<
  string,
  { labelKey: string; className: string }
> = {
  easy: {
    labelKey: "recipes.difficulty.easy",
    className: "text-success",
  },
  medium: {
    labelKey: "recipes.difficulty.medium",
    className: "text-warning",
  },
  hard: {
    labelKey: "recipes.difficulty.hard",
    className: "text-error",
  },
};

/* ── Component ───────────────────────────────────────────────────────────── */

interface RecipeCardProps {
  readonly recipe: RecipeSummary;
}

export function RecipeCard({ recipe }: RecipeCardProps) {
  const { t } = useTranslation();
  const diff = DIFFICULTY_STYLE[recipe.difficulty] ?? DIFFICULTY_STYLE.easy;

  return (
    <Link href={`/app/recipes/${recipe.slug}`} className="block">
      <Card
        variant="default"
        padding="none"
        className="hover-lift-press h-full transition-all duration-fast"
      >
        <div className="flex flex-col gap-2 p-4">
          {/* Title */}
          <h3 className="line-clamp-2 text-sm font-semibold text-foreground">
            {t(recipe.title_key)}
          </h3>

          {/* Description */}
          <p className="line-clamp-2 text-xs text-foreground-secondary">
            {t(recipe.description_key)}
          </p>

          {/* Meta row */}
          <div className="flex flex-wrap items-center gap-3 text-xs text-foreground-secondary">
            <span className="inline-flex items-center gap-1">
              <Icon icon={Clock} size="sm" />
              {recipe.total_time} {t("recipes.minutes")}
            </span>
            <span className={`inline-flex items-center gap-1 font-medium ${diff.className}`}>
              <Icon icon={ChefHat} size="sm" />
              {t(diff.labelKey)}
            </span>
            <span className="inline-flex items-center gap-1">
              <Icon icon={Users} size="sm" />
              {recipe.servings}
            </span>
          </div>

          {/* Tags */}
          {recipe.tags.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {recipe.tags.slice(0, 3).map((tag) => (
                <Chip key={tag} variant="default" className="!text-[10px] !px-1.5 !py-0">
                  {tag}
                </Chip>
              ))}
            </div>
          )}
        </div>
      </Card>
    </Link>
  );
}
