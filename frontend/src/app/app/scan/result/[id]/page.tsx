"use client";

// ─── Scan Result Page ───────────────────────────────────────────────────────
// Shown after a successful barcode scan. Displays the scanned product summary
// with a prominent "Healthier Alternatives" section so users immediately see
// better options without having to navigate to the full product detail page.

import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getProductDetail, getBetterAlternatives } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS, scoreBandFromScore } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { HealthWarningsCard } from "@/components/product/HealthWarningsCard";
import type { ProductDetail, Alternative } from "@/lib/types";

export default function ScanResultPage() {
  const params = useParams();
  const productId = Number(params.id);
  const supabase = createClient();

  const {
    data: product,
    isLoading: productLoading,
    error: productError,
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

  const {
    data: alternativesData,
    isLoading: alternativesLoading,
  } = useQuery({
    queryKey: queryKeys.alternatives(productId),
    queryFn: async () => {
      const result = await getBetterAlternatives(supabase, productId, {
        p_same_category: true,
        p_limit: 10,
      });
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.alternatives,
    enabled: !Number.isNaN(productId),
  });

  // ─── Loading ────────────────────────────────────────────────────────────

  if (productLoading) {
    return (
      <div className="flex flex-col items-center gap-3 py-12">
        <LoadingSpinner />
        <p className="text-sm text-gray-500">Loading scan result…</p>
      </div>
    );
  }

  // ─── Error ──────────────────────────────────────────────────────────────

  if (productError || !product) {
    return (
      <div className="space-y-4">
        <div className="card border-red-200 bg-red-50 py-8 text-center">
          <p className="mb-2 text-4xl">⚠️</p>
          <p className="text-sm text-red-600">Could not load product details.</p>
        </div>
        <Link href="/app/scan" className="btn-primary block w-full text-center">
          ← Back to Scanner
        </Link>
      </div>
    );
  }

  // ─── Render ─────────────────────────────────────────────────────────────

  const band = SCORE_BANDS[product.scores.score_band];
  const nutriClass = product.scores.nutri_score
    ? NUTRI_COLORS[product.scores.nutri_score]
    : "bg-gray-200 text-gray-500";

  const alternatives = alternativesData?.alternatives ?? [];
  const hasAlternatives = alternatives.length > 0;

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-lg font-bold text-gray-900">📷 Scan Result</h1>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          Scan another →
        </Link>
      </div>

      {/* ── Scanned Product Card ─────────────────────────────────────────── */}
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
            <div className="mt-2 flex flex-wrap items-center gap-2">
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
        </div>

        {/* Health flags */}
        <HealthFlags product={product} />
      </div>

      {/* ── Personalized Health Warnings ──────────────────────────────────── */}
      <HealthWarningsCard productId={productId} />

      {/* ── Quick Nutrition Summary ──────────────────────────────────────── */}
      <div className="card">
        <h2 className="mb-2 text-sm font-semibold text-gray-700">
          Nutrition per 100 g
        </h2>
        <div className="grid grid-cols-3 gap-2 text-center text-xs">
          <NutrientPill label="Calories" value={`${product.nutrition_per_100g.calories}`} unit="kcal" />
          <NutrientPill label="Sugars" value={`${product.nutrition_per_100g.sugars_g}`} unit="g" />
          <NutrientPill label="Salt" value={`${product.nutrition_per_100g.salt_g}`} unit="g" />
          <NutrientPill label="Fat" value={`${product.nutrition_per_100g.total_fat_g}`} unit="g" />
          <NutrientPill label="Sat. Fat" value={`${product.nutrition_per_100g.saturated_fat_g}`} unit="g" />
          <NutrientPill label="Protein" value={`${product.nutrition_per_100g.protein_g}`} unit="g" />
        </div>
      </div>

      {/* ── Healthier Alternatives ───────────────────────────────────────── */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold text-gray-900">
            🥗 Healthier Alternatives
          </h2>
          {hasAlternatives && (
            <span className="rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700">
              {alternativesData!.alternatives_count} found
            </span>
          )}
        </div>

        <AlternativesSection
          loading={alternativesLoading}
          alternatives={alternatives}
          sourceScore={product.scores.unhealthiness_score}
        />
      </div>

      {/* ── Action Buttons ───────────────────────────────────────────────── */}
      <div className="flex gap-2 pt-2">
        <Link
          href={`/app/product/${productId}`}
          className="btn-secondary flex-1 text-center"
        >
          📋 Full Details
        </Link>
        <Link
          href="/app/scan"
          className="btn-primary flex-1 text-center"
        >
          📷 Scan Another
        </Link>
      </div>
    </div>
  );
}

// ─── Alternatives Section ───────────────────────────────────────────────────

function AlternativesSection({
  loading,
  alternatives,
  sourceScore,
}: Readonly<{
  loading: boolean;
  alternatives: Alternative[];
  sourceScore: number;
}>) {
  if (loading) {
    return (
      <div className="flex justify-center py-6">
        <LoadingSpinner />
      </div>
    );
  }

  if (alternatives.length === 0) {
    return (
      <div className="card bg-gray-50 py-6 text-center">
        <p className="text-sm text-gray-500">
          🏆 This is already one of the best options in its category!
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {alternatives.map((alt) => (
        <ScanAlternativeCard
          key={alt.product_id}
          alt={alt}
          sourceScore={sourceScore}
        />
      ))}
    </div>
  );
}

// ─── Health Flags ───────────────────────────────────────────────────────────

function HealthFlags({ product }: Readonly<{ product: ProductDetail }>) {
  const activeFlags = [
    product.flags.high_sugar && "🍬 High sugar",
    product.flags.high_salt && "🧂 High salt",
    product.flags.high_sat_fat && "🥓 High sat. fat",
    product.flags.high_additive_load && "🧪 Many additives",
    product.flags.has_palm_oil && "🌴 Palm oil",
  ].filter(Boolean) as string[];

  if (activeFlags.length === 0) return null;

  return (
    <div className="mt-3 flex flex-wrap gap-1">
      {activeFlags.map((flag) => (
        <span
          key={flag}
          className="rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700"
        >
          {flag}
        </span>
      ))}
    </div>
  );
}

// ─── Nutrient Pill ──────────────────────────────────────────────────────────

function NutrientPill({
  label,
  value,
  unit,
}: Readonly<{ label: string; value: string; unit: string }>) {
  return (
    <div className="rounded-lg bg-gray-50 px-2 py-2">
      <p className="font-medium text-gray-900">
        {value} <span className="text-gray-400">{unit}</span>
      </p>
      <p className="text-gray-500">{label}</p>
    </div>
  );
}

// ─── Scan Alternative Card ──────────────────────────────────────────────────

function ScanAlternativeCard({
  alt,
  sourceScore,
}: Readonly<{ alt: Alternative; sourceScore: number }>) {
  const altBand = SCORE_BANDS[scoreBandFromScore(alt.unhealthiness_score)];
  const nutriClass = alt.nutri_score
    ? NUTRI_COLORS[alt.nutri_score]
    : "bg-gray-200 text-gray-500";

  // Calculate improvement percentage
  const improvementPct =
    sourceScore > 0
      ? Math.round((alt.score_improvement / sourceScore) * 100)
      : 0;

  return (
    <Link href={`/app/product/${alt.product_id}`}>
      <div className="card flex items-center gap-3 border-green-100 transition-shadow hover:shadow-md">
        {/* Score */}
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${altBand.bg} ${altBand.color}`}
        >
          {alt.unhealthiness_score}
        </div>

        {/* Product info */}
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-gray-900">
            {alt.product_name}
          </p>
          <p className="truncate text-sm text-gray-500">{alt.brand}</p>
          <p className="text-xs font-medium text-green-600">
            ↓ {alt.score_improvement} pts better
            {improvementPct > 0 && (
              <span className="text-green-500"> ({improvementPct}% healthier)</span>
            )}
          </p>
        </div>

        {/* Nutri-Score badge */}
        <span
          className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
        >
          {alt.nutri_score ?? "?"}
        </span>

        {/* Arrow */}
        <span className="flex-shrink-0 text-gray-300">›</span>
      </div>
    </Link>
  );
}
