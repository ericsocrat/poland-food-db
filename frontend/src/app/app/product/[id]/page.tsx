"use client";

// ─── Product detail page ────────────────────────────────────────────────────

import { useState } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import {
  getProductDetail,
  getBetterAlternatives,
  getScoreExplanation,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { ProductDetail, Alternative } from "@/lib/types";

type Tab = "overview" | "nutrition" | "alternatives" | "scoring";

export default function ProductDetailPage() {
  const params = useParams();
  const productId = Number(params.id);
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<Tab>("overview");

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
          <p className="mb-3 text-sm text-red-600">
            Failed to load product.
          </p>
          <button
            type="button"
            className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
            onClick={() =>
              queryClient.invalidateQueries({
                queryKey: queryKeys.product(productId),
              })
            }
          >
            Retry
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
          Product not found.
        </p>
      </div>
    );
  }

  const band = SCORE_BANDS[product.scores.score_band];
  const nutriClass = product.scores.nutri_score
    ? NUTRI_COLORS[product.scores.nutri_score]
    : "bg-gray-200 text-gray-500";

  const tabs: { key: Tab; label: string }[] = [
    { key: "overview", label: "Overview" },
    { key: "nutrition", label: "Nutrition" },
    { key: "alternatives", label: "Alternatives" },
    { key: "scoring", label: "Scoring" },
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
            <p className="text-lg font-bold text-gray-900">
              {product.product_name}
            </p>
            <p className="text-sm text-gray-500">{product.brand}</p>
            <div className="mt-2 flex items-center gap-2">
              <span
                className={`rounded-full px-2 py-0.5 text-xs font-bold ${nutriClass}`}
              >
                Nutri-Score {product.scores.nutri_score ?? "?"}
              </span>
              <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                NOVA {product.scores.nova_group}
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

        {/* Flags */}
        <div className="mt-3 flex flex-wrap gap-1">
          {product.flags.high_sugar && <Flag label="High sugar" />}
          {product.flags.high_salt && <Flag label="High salt" />}
          {product.flags.high_sat_fat && <Flag label="High sat. fat" />}
          {product.flags.high_additive_load && <Flag label="Many additives" />}
          {product.flags.has_palm_oil && <Flag label="Palm oil" />}
        </div>
      </div>

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
      Back
    </Link>
  );
}

function Flag({ label }: Readonly<{ label: string }>) {
  return (
    <span className="rounded bg-red-50 px-2 py-0.5 text-xs font-medium text-red-600">
      {label}
    </span>
  );
}

// ─── Overview Tab ───────────────────────────────────────────────────────────

function OverviewTab({ product }: Readonly<{ product: ProductDetail }>) {
  return (
    <div className="space-y-4">
      {/* Ingredients */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">
          Ingredients
        </h3>
        <div className="space-y-1 text-sm text-gray-600">
          <p>{product.ingredients.count} ingredients</p>
          <p>{product.ingredients.additives_count} additives</p>
          {product.ingredients.additive_names.length > 0 && (
            <p className="text-xs text-gray-400">
              {product.ingredients.additive_names.join(", ")}
            </p>
          )}
          <p>Vegan: {product.ingredients.vegan_status}</p>
          <p>Vegetarian: {product.ingredients.vegetarian_status}</p>
        </div>
      </div>

      {/* Allergens */}
      {product.allergens.count > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            Allergens
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
              <p className="mb-1 text-xs text-gray-400">May contain:</p>
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
          Data Quality
        </h3>
        <div className="grid grid-cols-2 gap-2 text-sm text-gray-600">
          <p>Confidence: {product.trust.confidence}</p>
          <p>Completeness: {product.trust.data_completeness_pct}%</p>
          <p>Source: {product.trust.source_type}</p>
          <p>Age: {product.freshness.data_age_days}d</p>
        </div>
      </div>
    </div>
  );
}

// ─── Nutrition Tab ──────────────────────────────────────────────────────────

function NutritionTab({ product }: Readonly<{ product: ProductDetail }>) {
  const n = product.nutrition_per_100g;
  const rows = [
    { label: "Calories", value: `${n.calories} kcal` },
    { label: "Total Fat", value: `${n.total_fat_g} g` },
    { label: "Saturated Fat", value: `${n.saturated_fat_g} g` },
    {
      label: "Trans Fat",
      value: n.trans_fat_g === null ? "—" : `${n.trans_fat_g} g`,
    },
    { label: "Carbs", value: `${n.carbs_g} g` },
    { label: "Sugars", value: `${n.sugars_g} g` },
    {
      label: "Fibre",
      value: n.fibre_g === null ? "—" : `${n.fibre_g} g`,
    },
    { label: "Protein", value: `${n.protein_g} g` },
    { label: "Salt", value: `${n.salt_g} g` },
  ];

  return (
    <div className="card">
      <h3 className="mb-3 text-sm font-semibold text-gray-700">
        Nutrition per 100 g
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
        No healthier alternatives found in this category.
      </p>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-sm text-gray-500">
        {data.alternatives_count} healthier option
        {data.alternatives_count !== 1 && "s"} found
      </p>
      {data.alternatives.map((alt) => (
        <AlternativeCard key={alt.product_id} alt={alt} />
      ))}
    </div>
  );
}

function AlternativeCard({ alt }: Readonly<{ alt: Alternative }>) {
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
            −{alt.score_improvement} points better
          </p>
        </div>
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
        Score breakdown unavailable.
      </p>
    );
  }

  return (
    <div className="space-y-4">
      {/* Summary */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-gray-700">Summary</h3>
        <p className="text-sm text-gray-600">{data.summary.headline}</p>
      </div>

      {/* Top factors */}
      {data.top_factors.length > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-gray-700">
            Top Score Factors
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
            Warnings
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
          Category Context
        </h3>
        <div className="text-sm text-gray-600">
          <p>
            Rank: {data.category_context.category_rank} of{" "}
            {data.category_context.category_total}
          </p>
          <p>
            Category avg: {Math.round(data.category_context.category_avg_score)}
          </p>
          <p>Position: {data.category_context.relative_position}</p>
        </div>
      </div>
    </div>
  );
}
