"use client";

// ─── Product detail page ────────────────────────────────────────────────────

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import {
  getProductDetail,
  getBetterAlternatives,
  getScoreExplanation,
  recordProductView,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import {
  HealthWarningsCard,
  HealthWarningBadge,
} from "@/components/product/HealthWarningsCard";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import type { ProductDetail, Alternative } from "@/lib/types";

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
    data: product,
    isLoading,
    error,
  } = useQuery({
    queryKey: queryKeys.product(productId),
    queryFn: async () => {
      const result = await getProductDetail(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.product,
    enabled: !Number.isNaN(productId),
  });

  useEffect(() => {
    if (product) {
      track("product_viewed", {
        product_id: productId,
        product_name: product.product_name,
        category: product.category,
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
                queryKey: queryKeys.product(productId),
              })
            }
          >
            {t("common.retry")}
          </button>
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="space-y-4">
        <BackButton />
        <p className="py-12 text-center text-sm text-gray-400">
          {t("product.notFoundPage")}
        </p>
      </div>
    );
  }

  const band = SCORE_BANDS[product.scores.score_band];
  const nutriClass = product.scores.nutri_score
    ? NUTRI_COLORS[product.scores.nutri_score]
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
        <div className="flex items-start gap-4">
          <div
            className={`flex h-16 w-16 flex-shrink-0 items-center justify-center rounded-xl text-2xl font-bold ${band.bg} ${band.color}`}
          >
            {product.scores.unhealthiness_score}
          </div>
          <div className="min-w-0 flex-1">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-lg font-bold text-gray-900">
                  {product.product_name_display ?? product.product_name}
                </p>
                {product.product_name_en &&
                  product.product_name_display !== product.product_name && (
                    <p className="text-xs text-gray-400">
                      {t("product.originalName")}: {product.product_name}
                    </p>
                  )}
                <p className="text-sm text-gray-500">{product.brand}</p>
              </div>
              <div className="flex items-center gap-2">
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
                  grade: product.scores.nutri_score ?? "?",
                })}
              </span>
              <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                {t("product.novaGroup", { group: product.scores.nova_group })}
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
            {product.category_icon} {product.category_display}
          </span>
          {product.ean && <span>EAN: {product.ean}</span>}
          {product.store_availability && (
            <span>Store: {product.store_availability}</span>
          )}
        </div>

        {/* Flags — with "why" explanations */}
        {(product.flags.high_sugar ||
          product.flags.high_salt ||
          product.flags.high_sat_fat ||
          product.flags.high_additive_load ||
          product.flags.has_palm_oil) && (
          <div className="mt-3 space-y-1">
            <p className="text-xs font-medium text-gray-400">
              {t("product.healthFlags")}
            </p>
            <div className="flex flex-wrap gap-1">
              {product.flags.high_sugar && (
                <FlagWithExplanation
                  label={t("product.highSugar")}
                  explanation={t("product.highSugarExplanation")}
                />
              )}
              {product.flags.high_salt && (
                <FlagWithExplanation
                  label={t("product.highSalt")}
                  explanation={t("product.highSaltExplanation")}
                />
              )}
              {product.flags.high_sat_fat && (
                <FlagWithExplanation
                  label={t("product.highSatFat")}
                  explanation={t("product.highSatFatExplanation")}
                />
              )}
              {product.flags.high_additive_load && (
                <FlagWithExplanation
                  label={t("product.manyAdditives")}
                  explanation={t("product.manyAdditivesExplanation")}
                />
              )}
              {product.flags.has_palm_oil && (
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
      <HealthWarningsCard productId={productId} />

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
      {activeTab === "overview" && <OverviewTab product={product} />}
      {activeTab === "nutrition" && <NutritionTab product={product} />}
      {activeTab === "alternatives" && (
        <AlternativesTab productId={productId} />
      )}
      {activeTab === "scoring" && <ScoringTab productId={productId} />}
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

function OverviewTab({ product }: Readonly<{ product: ProductDetail }>) {
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
            {t("product.ingredientCount", { count: product.ingredients.count })}
          </p>
          <p>
            {t("product.additiveCount", {
              count: product.ingredients.additives_count,
            })}
          </p>
          {product.ingredients.additive_names.length > 0 && (
            <p className="text-xs text-gray-400">
              {product.ingredients.additive_names.join(", ")}
            </p>
          )}
          <p>
            {t("product.vegan", { status: product.ingredients.vegan_status })}
          </p>
          <p>
            {t("product.vegetarian", {
              status: product.ingredients.vegetarian_status,
            })}
          </p>
        </div>
      </div>

      {/* Allergens */}
      {product.allergens.count > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            {t("product.allergens")}
          </h3>
          <div className="flex flex-wrap gap-1">
            {product.allergens.tags.map((tag) => (
              <span
                key={tag}
                className="rounded bg-amber-50 px-2 py-0.5 text-xs text-amber-700"
              >
                {tag.replaceAll("en:", "")}
              </span>
            ))}
          </div>
          {product.allergens.trace_count > 0 && (
            <div className="mt-2">
              <p className="mb-1 text-xs text-gray-400">
                {t("product.mayContain")}
              </p>
              <div className="flex flex-wrap gap-1">
                {product.allergens.trace_tags.map((tag) => (
                  <span
                    key={tag}
                    className="rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-500"
                  >
                    {tag.replaceAll("en:", "")}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Trust & data quality */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.dataQuality")}
        </h3>
        <div className="grid grid-cols-2 gap-2 text-sm text-gray-600">
          <p>{t("product.confidence", { value: product.trust.confidence })}</p>
          <p>
            {t("product.completeness", {
              pct: product.trust.data_completeness_pct,
            })}
          </p>
          <p>{t("product.source", { type: product.trust.source_type })}</p>
          <p>
            {t("product.dataAge", { days: product.freshness.data_age_days })}
          </p>
        </div>
      </div>
    </div>
  );
}

// ─── Nutrition Tab ──────────────────────────────────────────────────────────

function NutritionTab({ product }: Readonly<{ product: ProductDetail }>) {
  const { t } = useTranslation();
  const n = product.nutrition_per_100g;
  const rows = [
    { label: t("product.caloriesLabel"), value: `${n.calories} kcal` },
    { label: t("product.totalFat"), value: `${n.total_fat_g} g` },
    { label: t("product.saturatedFat"), value: `${n.saturated_fat_g} g` },
    {
      label: t("product.transFat"),
      value: n.trans_fat_g === null ? "—" : `${n.trans_fat_g} g`,
    },
    { label: t("product.carbs"), value: `${n.carbs_g} g` },
    { label: t("product.sugars"), value: `${n.sugars_g} g` },
    {
      label: t("product.fibre"),
      value: n.fibre_g === null ? "—" : `${n.fibre_g} g`,
    },
    { label: t("product.protein"), value: `${n.protein_g} g` },
    { label: t("product.salt"), value: `${n.salt_g} g` },
  ];

  return (
    <div className="card">
      <h3 className="mb-3 text-sm font-semibold text-gray-700">
        {t("product.nutritionPer100g")}
      </h3>
      <table className="w-full text-sm">
        <tbody>
          {rows.map((row) => (
            <tr key={row.label} className="border-b border-gray-100">
              <td className="py-2 text-gray-600">{row.label}</td>
              <td className="py-2 text-right font-medium text-gray-900">
                {row.value}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ─── Alternatives Tab ───────────────────────────────────────────────────────

function AlternativesTab({ productId }: Readonly<{ productId: number }>) {
  const { t } = useTranslation();
  const supabase = createClient();

  const { data, isLoading } = useQuery({
    queryKey: queryKeys.alternatives(productId),
    queryFn: async () => {
      const result = await getBetterAlternatives(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.alternatives,
  });

  if (isLoading) {
    return (
      <div className="flex justify-center py-8">
        <LoadingSpinner />
      </div>
    );
  }

  if (!data || data.alternatives.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-gray-400">
        {t("product.noAlternatives")}
      </p>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-sm text-gray-500">
        {t("product.healthierOptions", { count: data.alternatives_count })}
      </p>
      {data.alternatives.map((alt) => (
        <AlternativeCard key={alt.product_id} alt={alt} />
      ))}
    </div>
  );
}

function AlternativeCard({ alt }: Readonly<{ alt: Alternative }>) {
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
            {t("product.pointsBetter", { points: alt.score_improvement })}
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

function ScoringTab({ productId }: Readonly<{ productId: number }>) {
  const { t } = useTranslation();
  const supabase = createClient();

  const { data, isLoading } = useQuery({
    queryKey: queryKeys.scoreExplanation(productId),
    queryFn: async () => {
      const result = await getScoreExplanation(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.scoreExplanation,
  });

  if (isLoading) {
    return (
      <div className="flex justify-center py-8">
        <LoadingSpinner />
      </div>
    );
  }

  if (!data) {
    return (
      <p className="py-8 text-center text-sm text-gray-400">
        {t("product.scoreBreakdownUnavailable")}
      </p>
    );
  }

  return (
    <div className="space-y-4">
      {/* Summary */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          {t("product.summary")}
        </h3>
        <p className="text-sm text-gray-600">{data.summary.headline}</p>
      </div>

      {/* Top factors */}
      {data.top_factors.length > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            {t("product.topScoreFactors")}
          </h3>
          <div className="space-y-2">
            {data.top_factors.map((f) => (
              <div
                key={f.factor}
                className="flex items-center justify-between text-sm"
              >
                <span className="text-gray-600">{f.factor}</span>
                <span className="font-medium text-gray-900">
                  +{f.weighted.toFixed(1)}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Warnings */}
      {data.warnings.length > 0 && (
        <div className="card border-amber-200 bg-amber-50">
          <h3 className="mb-2 text-sm font-semibold text-amber-800">
            {t("product.warnings")}
          </h3>
          <ul className="list-inside list-disc space-y-1 text-sm text-amber-700">
            {data.warnings.map((w) => (
              <li key={w.message}>{w.message}</li>
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
              rank: data.category_context.category_rank,
              total: data.category_context.category_total,
            })}
          </p>
          <p>
            {t("product.categoryAvg", {
              avg: Math.round(data.category_context.category_avg_score),
            })}
          </p>
          <p>Position: {data.category_context.relative_position}</p>
        </div>
      </div>
    </div>
  );
}
