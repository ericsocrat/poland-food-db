"use client";

// ─── Ingredient Profile Page ─────────────────────────────────────────────────
// Deep-dive into a single ingredient: concern tier, EFSA guidance, products
// containing it, and co-occurring ingredients.

import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { createClient } from "@/lib/supabase/client";
import { getIngredientProfile } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { ConcernBadge } from "@/components/ingredient/ConcernBadge";
import { IngredientUsageStats } from "@/components/ingredient/IngredientUsageStats";
import { ProductsContainingList } from "@/components/ingredient/ProductsContainingList";
import { RelatedIngredientsList } from "@/components/ingredient/RelatedIngredientsList";
import { useTranslation } from "@/lib/i18n";

export default function IngredientProfilePage() {
  const params = useParams<{ id: string }>();
  const ingredientId = Number(params.id);
  const { t } = useTranslation();

  const supabase = createClient();
  const {
    data: profile,
    isLoading,
    error,
  } = useQuery({
    queryKey: queryKeys.ingredientProfile(ingredientId),
    queryFn: async () => {
      const result = await getIngredientProfile(supabase, ingredientId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.ingredientProfile,
    enabled: !Number.isNaN(ingredientId),
  });

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (error || !profile || profile.error) {
    return (
      <div className="space-y-4">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.search", href: "/app/search" },
          ]}
        />
        <div className="card py-8 text-center">
          <p className="mb-2 text-4xl">🔬</p>
          <p className="text-sm text-foreground-muted">
            {t("ingredient.notFound")}
          </p>
        </div>
      </div>
    );
  }

  const ing = profile.ingredient;

  return (
    <div className="space-y-4">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          { label: ing.name_display },
        ]}
      />

      {/* ── Header Card ──────────────────────────────────────────────── */}
      <div className="card">
        <div className="flex items-start gap-4">
          <div className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-xl bg-surface-muted text-2xl">
            {ing.is_additive ? "🧪" : "🌿"}
          </div>
          <div className="min-w-0 flex-1">
            <h1 className="text-lg font-bold text-foreground">
              {ing.name_display}
            </h1>
            {ing.additive_code && (
              <span className="inline-block rounded bg-purple-100 px-2 py-0.5 text-xs font-semibold text-purple-700">
                {ing.additive_code}
              </span>
            )}
            <div className="mt-2">
              <ConcernBadge
                tier={ing.concern_tier}
                label={ing.concern_tier_label}
              />
            </div>
          </div>
        </div>

        {/* Dietary flags */}
        <div className="mt-3 flex flex-wrap gap-2 text-xs text-foreground-secondary">
          <DietaryFlag label={t("ingredient.vegan")} value={ing.vegan} />
          <DietaryFlag
            label={t("ingredient.vegetarian")}
            value={ing.vegetarian}
          />
          {ing.from_palm_oil !== "no" && (
            <DietaryFlag
              label={t("ingredient.palmOil")}
              value={ing.from_palm_oil}
            />
          )}
        </div>
      </div>

      {/* ── Concern Explanation ───────────────────────────────────────── */}
      {(ing.concern_description || ing.concern_reason) && (
        <div className="card">
          <h2 className="mb-2 text-sm font-semibold text-foreground-secondary">
            {t("ingredient.concernDetails")}
          </h2>
          {ing.concern_description && (
            <p className="text-sm text-foreground-secondary">
              {ing.concern_description}
            </p>
          )}
          {ing.concern_reason && (
            <p className="mt-1 text-sm text-foreground-secondary italic">
              {ing.concern_reason}
            </p>
          )}
          {ing.efsa_guidance && (
            <div className="mt-3 rounded-lg bg-blue-50 p-3">
              <p className="text-xs font-medium text-blue-700">
                {t("ingredient.efsaGuidance")}
              </p>
              <p className="mt-1 text-xs text-blue-600">{ing.efsa_guidance}</p>
            </div>
          )}
          {ing.score_impact && (
            <p className="mt-2 text-xs text-foreground-muted">
              {t("ingredient.scoreImpact")}: {ing.score_impact}
            </p>
          )}
        </div>
      )}

      {/* ── Usage Stats ──────────────────────────────────────────────── */}
      <IngredientUsageStats usage={profile.usage} />

      {/* ── Products Containing ──────────────────────────────────────── */}
      {profile.usage.top_products.length > 0 && (
        <ProductsContainingList products={profile.usage.top_products} />
      )}

      {/* ── Related Ingredients ──────────────────────────────────────── */}
      {profile.related_ingredients.length > 0 && (
        <RelatedIngredientsList ingredients={profile.related_ingredients} />
      )}
    </div>
  );
}

// ─── Helper Components ──────────────────────────────────────────────────────

function DietaryFlag({
  label,
  value,
}: Readonly<{ label: string; value: string }>) {
  const icons: Record<string, string> = {
    yes: "✅",
    no: "❌",
    maybe: "⚠️",
  };
  const icon = icons[value] ?? "❓";
  return (
    <span
      className="rounded-full bg-surface-muted px-2 py-0.5"
      data-testid="dietary-flag"
    >
      {icon} {label}: {value}
    </span>
  );
}
