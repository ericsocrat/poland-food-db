"use client";

// ─── Product detail page ────────────────────────────────────────────────────
// Uses the composite api_get_product_profile() endpoint for a single round-trip.

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getProductProfile, recordProductView } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  SCORE_BANDS,
  NUTRI_COLORS,
  CONCERN_TIER_STYLES,
} from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import {
  HealthWarningsCard,
  HealthWarningBadge,
} from "@/components/product/HealthWarningsCard";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { ProductHeroImage } from "@/components/product/ProductHeroImage";
import { ProductImageTabs } from "@/components/product/ProductImageTabs";
import { NutritionDVBar } from "@/components/product/NutritionDVBar";
import { DVReferenceBadge } from "@/components/product/DVReferenceBadge";
import { DVLegend } from "@/components/product/DVLegend";
import { ShareButton } from "@/components/product/ShareButton";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import type { ProductProfile, ProfileAlternative } from "@/lib/types";

type Tab = "overview" | "nutrition" | "alternatives" | "scoring";

export default function ProductDetailPage() {
  const params = useParams();
  const productId = Number(params.id);
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<Tab>("overview");
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const {
    data: profile,
    isLoading,
    error,
  } = useQuery({
    queryKey: queryKeys.productProfile(productId),
    queryFn: async () => {
      const result = await getProductProfile(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.productProfile,
    enabled: !Number.isNaN(productId),
  });

  useEffect(() => {
    if (profile) {
      track("product_viewed", {
        product_id: productId,
        product_name: profile.product.product_name,
        category: profile.product.category,
      });
      // Record view for dashboard recently-viewed section
      recordProductView(supabase, productId);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productId]);

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-4">
        <BackButton />
        <div className="card border-red-200 bg-red-50 py-8 text-center">
          <p className="mb-3 text-sm text-red-600">{t("product.loadFailed")}</p>
          <button
            type="button"
            className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
            onClick={() =>
              queryClient.invalidateQueries({
                queryKey: queryKeys.productProfile(productId),
              })
            }
          >
            {t("common.retry")}
          </button>
        </div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="space-y-4">
        <BackButton />
        <p className="py-12 text-center text-sm text-gray-400">
          {t("product.notFoundPage")}
        </p>
      </div>
    );
  }

  const band = SCORE_BANDS[profile.scores.score_band];
  const nutriClass = profile.scores.nutri_score_label
    ? NUTRI_COLORS[profile.scores.nutri_score_label]
    : "bg-gray-200 text-gray-500";

  const tabs: { key: Tab; label: string }[] = [
    { key: "overview", label: t("product.overview") },
    { key: "nutrition", label: t("product.nutrition") },
    { key: "alternatives", label: t("product.alternatives") },
    { key: "scoring", label: t("product.scoring") },
  ];

  return (
    <div className="space-y-4">
      <BackButton />

      {/* Header */}
      <div className="card">
        {/* Product Hero Image */}
        <div className="mb-4">
          <ProductHeroImage
            images={profile.images}
            productName={
              profile.product.product_name_display ??
              profile.product.product_name
            }
            categoryIcon={profile.product.category_icon}
          />
        </div>

        <div className="flex items-start gap-4">
          <div
            className={`flex h-16 w-16 flex-shrink-0 items-center justify-center rounded-xl text-2xl font-bold ${band.bg} ${band.color}`}
          >
            {profile.scores.unhealthiness_score}
          </div>
          <div className="min-w-0 flex-1">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-lg font-bold text-gray-900">
                  {profile.product.product_name_display ??
                    profile.product.product_name}
                </p>
                {profile.product.product_name_en &&
                  profile.product.product_name_display !==
                    profile.product.product_name && (
                    <p className="text-xs text-gray-400">
                      {t("product.originalName")}:{" "}
                      {profile.product.product_name}
                    </p>
                  )}
                <p className="text-sm text-gray-500">{profile.product.brand}</p>
              </div>
              <div className="flex items-center gap-2">
                <ShareButton
                  productName={
                    profile.product.product_name_display ??
                    profile.product.product_name
                  }
                  score={profile.scores.unhealthiness_score}
                  productId={productId}
                />
                <AvoidBadge productId={productId} />
                <AddToListMenu productId={productId} />
                <CompareCheckbox productId={productId} />
              </div>
            </div>
            <div className="mt-2 flex items-center gap-2">
              <span
                className={`rounded-full px-2 py-0.5 text-xs font-bold ${nutriClass}`}
              >
                {t("product.nutriScore", {
                  grade: profile.scores.nutri_score_label ?? "?",
                })}
              </span>
              <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                {t("product.novaGroup", { group: profile.scores.nova_group })}
              </span>
              <span
                className={`rounded-full px-2 py-0.5 text-xs font-medium ${band.bg} ${band.color}`}
              >
                {band.label}
              </span>
            </div>
          </div>
        </div>

        {/* Category & EAN */}
        <div className="mt-3 flex flex-wrap gap-2 text-xs text-gray-500">
          <span>
            {profile.product.category_icon} {profile.product.category_display}
          </span>
          {profile.product.ean && <span>EAN: {profile.product.ean}</span>}
          {profile.product.store_availability && (
            <span>Store: {profile.product.store_availability}</span>
          )}
        </div>

        {/* Flags — with "why" explanations */}
        {(profile.flags.high_sugar ||
          profile.flags.high_salt ||
          profile.flags.high_sat_fat ||
          profile.flags.high_additive_load ||
          profile.flags.has_palm_oil) && (
          <div className="mt-3 space-y-1">
            <p className="text-xs font-medium text-gray-400">
              {t("product.healthFlags")}
            </p>
            <div className="flex flex-wrap gap-1">
              {profile.flags.high_sugar && (
                <FlagWithExplanation
                  label={t("product.highSugar")}
                  explanation={t("product.highSugarExplanation")}
                />
              )}
              {profile.flags.high_salt && (
                <FlagWithExplanation
                  label={t("product.highSalt")}
                  explanation={t("product.highSaltExplanation")}
                />
              )}
              {profile.flags.high_sat_fat && (
                <FlagWithExplanation
                  label={t("product.highSatFat")}
                  explanation={t("product.highSatFatExplanation")}
                />
              )}
              {profile.flags.high_additive_load && (
                <FlagWithExplanation
                  label={t("product.manyAdditives")}
                  explanation={t("product.manyAdditivesExplanation")}
                />
              )}
              {profile.flags.has_palm_oil && (
                <FlagWithExplanation
                  label={t("product.palmOil")}
                  explanation={t("product.palmOilExplanation")}
                />
              )}
            </div>
          </div>
        )}
      </div>

      {/* Personalized health warnings */}
      <ErrorBoundary level="section" context={{ section: "health-warnings", productId }}>
        <HealthWarningsCard productId={productId} />
      </ErrorBoundary>

      {/* Tab bar */}
      <div className="flex gap-1 rounded-lg bg-gray-100 p-1" role="tablist">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            role="tab"
            aria-selected={activeTab === tab.key}
            className={`flex-1 rounded-md px-3 py-2 text-sm font-medium transition-colors ${
              activeTab === tab.key
                ? "bg-white text-brand-700 shadow-sm"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab content */}
      <ErrorBoundary level="section" context={{ section: "tab-content", productId, tab: activeTab }}>
        {activeTab === "overview" && <OverviewTab profile={profile} />}
        {activeTab === "nutrition" && <NutritionTab profile={profile} />}
        {activeTab === "alternatives" && (
          <AlternativesTab alternatives={profile.alternatives} />
        )}
        {activeTab === "scoring" && <ScoringTab profile={profile} />}
      </ErrorBoundary>
    </div>
  );
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function BackButton() {
  const { t } = useTranslation();
  return (
    <Link
      href="/app/search"
      className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700"
    >
      <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
        <path
          fillRule="evenodd"
          d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
          clipRule="evenodd"
        />
      </svg>
      {t("product.back")}
    </Link>
  );
}

function FlagWithExplanation({
  label,
  explanation,
}: Readonly<{ label: string; explanation: string }>) {
  const [open, setOpen] = useState(false);

  return (
    <span className="group relative inline-block">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="inline-flex items-center gap-1 rounded bg-red-50 px-2 py-0.5 text-xs font-medium text-red-600 transition-colors hover:bg-red-100"
      >
        {label}
        <svg
          className="h-3 w-3 opacity-50"
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fillRule="evenodd"
            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
            clipRule="evenodd"
          />
        </svg>
      </button>
      {open && (
        <span className="absolute bottom-full left-0 z-10 mb-1 w-56 rounded-lg border border-gray-200 bg-white p-2 text-xs text-gray-600 shadow-lg">
          {explanation}
        </span>
      )}
    </span>
  );
}

// ─── Overview Tab ───────────────────────────────────────────────────────────

function OverviewTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  return (
    <div className="space-y-4">
      {/* Ingredients */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.ingredients")}
        </h3>
        <div className="space-y-1 text-sm text-gray-600">
          <p>
            {t("product.ingredientCount", { count: profile.ingredients.count })}
          </p>
          <p>
            {t("product.additiveCount", {
              count: profile.ingredients.additive_count,
            })}
          </p>
          {profile.ingredients.additive_names && (
            <p className="text-xs text-gray-400">
              {profile.ingredients.additive_names}
            </p>
          )}
          <p>
            {t("product.vegan", {
              status: profile.ingredients.vegan_status ?? "unknown",
            })}
          </p>
          <p>
            {t("product.vegetarian", {
              status: profile.ingredients.vegetarian_status ?? "unknown",
            })}
          </p>
        </div>

        {/* Top ingredients — clickable links to ingredient profiles */}
        {profile.ingredients.top_ingredients.length > 0 && (
          <div className="mt-3 border-t border-gray-100 pt-3">
            <p className="mb-2 text-xs font-medium text-gray-500 uppercase">
              {t("product.topIngredients")}
            </p>
            <div className="flex flex-wrap gap-1.5">
              {profile.ingredients.top_ingredients.map((ing) => {
                const style =
                  CONCERN_TIER_STYLES[ing.concern_tier] ??
                  CONCERN_TIER_STYLES[0];
                return (
                  <Link
                    key={ing.ingredient_id}
                    href={`/app/ingredient/${ing.ingredient_id}`}
                    className={`inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-xs font-medium transition-colors hover:opacity-80 ${style.bg} ${style.color} ${style.border}`}
                  >
                    {ing.is_additive ? "🧪" : "🌿"} {ing.name}
                  </Link>
                );
              })}
            </div>
          </div>
        )}
      </div>

      {/* Allergens */}
      {profile.allergens.contains_count > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            {t("product.allergens")}
          </h3>
          <div className="flex flex-wrap gap-1">
            {profile.allergens.contains
              .split(",")
              .filter(Boolean)
              .map((tag) => (
                <span
                  key={tag}
                  className="rounded bg-amber-50 px-2 py-0.5 text-xs text-amber-700"
                >
                  {tag.trim().replaceAll("en:", "")}
                </span>
              ))}
          </div>
          {profile.allergens.traces_count > 0 && (
            <div className="mt-2">
              <p className="mb-1 text-xs text-gray-400">
                {t("product.mayContain")}
              </p>
              <div className="flex flex-wrap gap-1">
                {profile.allergens.traces
                  .split(",")
                  .filter(Boolean)
                  .map((tag) => (
                    <span
                      key={tag}
                      className="rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-500"
                    >
                      {tag.trim().replaceAll("en:", "")}
                    </span>
                  ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Data quality */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.dataQuality")}
        </h3>
        <div className="grid grid-cols-2 gap-2 text-sm text-gray-600">
          <p>
            {t("product.confidence", {
              value:
                ((profile.quality as Record<string, unknown>)
                  .confidence_band as string) ?? "unknown",
            })}
          </p>
          <p>
            {t("product.completeness", {
              pct:
                ((profile.quality as Record<string, unknown>)
                  .confidence_score as number) ?? 0,
            })}
          </p>
        </div>
      </div>

      {/* Product image gallery */}
      <ProductImageTabs
        images={profile.images}
        productName={
          profile.product.product_name_display ?? profile.product.product_name
        }
      />
    </div>
  );
}

// ─── Nutrition Tab ──────────────────────────────────────────────────────────

function NutritionTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  const n = profile.nutrition.per_100g;
  const dv = profile.nutrition.daily_values;
  const dvPer100g = dv?.per_100g ?? null;

  const rows = [
    {
      label: t("product.caloriesLabel"),
      value: `${n.calories_kcal} kcal`,
      dv: dvPer100g?.calories ?? null,
    },
    {
      label: t("product.totalFat"),
      value: `${n.total_fat_g} g`,
      dv: dvPer100g?.total_fat ?? null,
    },
    {
      label: t("product.saturatedFat"),
      value: `${n.saturated_fat_g} g`,
      dv: dvPer100g?.saturated_fat ?? null,
    },
    {
      label: t("product.transFat"),
      value: n.trans_fat_g === null ? "—" : `${n.trans_fat_g} g`,
      dv: dvPer100g?.trans_fat ?? null,
    },
    {
      label: t("product.carbs"),
      value: `${n.carbs_g} g`,
      dv: dvPer100g?.carbs ?? null,
    },
    {
      label: t("product.sugars"),
      value: `${n.sugars_g} g`,
      dv: dvPer100g?.sugars ?? null,
    },
    {
      label: t("product.fibre"),
      value: n.fibre_g === null ? "—" : `${n.fibre_g} g`,
      dv: dvPer100g?.fiber ?? null,
    },
    {
      label: t("product.protein"),
      value: `${n.protein_g} g`,
      dv: dvPer100g?.protein ?? null,
    },
    {
      label: t("product.salt"),
      value: `${n.salt_g} g`,
      dv: dvPer100g?.salt ?? null,
    },
  ];

  return (
    <div className="card">
      <div className="mb-3 flex items-center justify-between">
        <h3 className="text-sm font-semibold text-gray-700">
          {t("product.nutritionPer100g")}
        </h3>
        {dv && dv.reference_type !== "none" && (
          <DVReferenceBadge
            referenceType={dv.reference_type}
            regulation={dv.regulation}
          />
        )}
      </div>
      <table className="w-full text-sm">
        <tbody>
          {rows.map((row) => (
            <NutritionDVBar
              key={row.label}
              label={row.label}
              rawValue={row.value}
              dv={row.dv}
            />
          ))}
        </tbody>
      </table>
      {dv && dv.reference_type !== "none" && <DVLegend />}
    </div>
  );
}

// ─── Alternatives Tab ───────────────────────────────────────────────────────

function AlternativesTab({
  alternatives,
}: Readonly<{ alternatives: ProfileAlternative[] }>) {
  const { t } = useTranslation();

  if (alternatives.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-gray-400">
        {t("product.noAlternatives")}
      </p>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-sm text-gray-500">
        {t("product.healthierOptions", { count: alternatives.length })}
      </p>
      {alternatives.map((alt) => (
        <AlternativeCard key={alt.product_id} alt={alt} />
      ))}
    </div>
  );
}

function AlternativeCard({ alt }: Readonly<{ alt: ProfileAlternative }>) {
  const { t } = useTranslation();
  const nutriClass = alt.nutri_score
    ? NUTRI_COLORS[alt.nutri_score]
    : "bg-gray-200 text-gray-500";

  return (
    <Link href={`/app/product/${alt.product_id}`}>
      <div className="card flex items-center gap-3 transition-shadow hover:shadow-md">
        <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg bg-green-100 text-lg font-bold text-green-600">
          {alt.unhealthiness_score}
        </div>
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-gray-900">
            {alt.product_name}
          </p>
          <p className="text-sm text-gray-500">{alt.brand}</p>
          <p className="text-xs text-green-600">
            {t("product.pointsBetter", { points: alt.score_delta })}
          </p>
        </div>
        <HealthWarningBadge productId={alt.product_id} />
        <span
          className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
        >
          {alt.nutri_score ?? "?"}
        </span>
      </div>
    </Link>
  );
}

// ─── Scoring Tab ────────────────────────────────────────────────────────────

function ScoringTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  const scores = profile.scores;

  const topFactors = Array.isArray(scores.score_breakdown)
    ? scores.score_breakdown
        .toSorted(
          (a, b) =>
            ((b as Record<string, number>).weighted ?? 0) -
            ((a as Record<string, number>).weighted ?? 0),
        )
        .slice(0, 5)
    : [];

  return (
    <div className="space-y-4">
      {/* Summary */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.summary")}
        </h3>
        <p className="text-sm text-gray-600">{scores.headline}</p>
      </div>

      {/* Score breakdown factors */}
      {topFactors.length > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            {t("product.topScoreFactors")}
          </h3>
          <div className="space-y-2">
            {topFactors.map((f) => (
              <div
                key={String(f.factor)}
                className="flex items-center justify-between text-sm"
              >
                <span className="text-gray-600">{String(f.factor)}</span>
                <span className="font-medium text-gray-900">
                  +{Number(f.weighted).toFixed(1)}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Warnings */}
      {profile.warnings.length > 0 && (
        <div className="card border-amber-200 bg-amber-50">
          <h3 className="mb-2 text-sm font-semibold text-amber-800">
            {t("product.warnings")}
          </h3>
          <ul className="list-inside list-disc space-y-1 text-sm text-amber-700">
            {profile.warnings.map((w) => (
              <li key={w.type}>{w.message}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Category context */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.categoryContext")}
        </h3>
        <div className="text-sm text-gray-600">
          <p>
            {t("product.rank", {
              rank: scores.category_context.rank,
              total: scores.category_context.total_in_category,
            })}
          </p>
          <p>
            {t("product.categoryAvg", {
              avg: Math.round(scores.category_context.category_avg_score),
            })}
          </p>
          <p>Position: {scores.category_context.relative_position}</p>
        </div>
      </div>
    </div>
  );
}
