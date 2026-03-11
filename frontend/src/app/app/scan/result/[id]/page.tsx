"use client";

// ─── Scan Result Page ───────────────────────────────────────────────────────
// Shown after a successful barcode scan. Displays the scanned product summary
// with a prominent "Healthier Alternatives" section so users immediately see
// better options without having to navigate to the full product detail page.

import { ButtonLink } from "@/components/common/Button";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import {
  ProductCardSkeleton,
  ProductProfileSkeleton,
} from "@/components/common/skeletons";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { HealthWarningsCard } from "@/components/product/HealthWarningsCard";
import { getBetterAlternatives, getProductDetail } from "@/lib/api";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import type { Alternative, ProductDetail } from "@/lib/types";
import { useQuery } from "@tanstack/react-query";
import {
  AlertTriangle,
  Camera,
  ClipboardList,
  Salad,
  Trophy,
} from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";

export default function ScanResultPage() {
  const params = useParams();
  const productId = Number(params.id);
  const supabase = createClient();
  const { t } = useTranslation();

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

  const { data: alternativesData, isLoading: alternativesLoading } = useQuery({
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
    return <ProductProfileSkeleton />;
  }

  // ─── Error ──────────────────────────────────────────────────────────────

  if (productError || !product) {
    return (
      <div className="space-y-4">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.scan", href: "/app/scan" },
          ]}
        />
        <div className="card border-error-border bg-error-bg py-8 text-center">
          <div className="mb-2 flex justify-center">
            <AlertTriangle
              size={40}
              className="text-error"
              aria-hidden="true"
            />
          </div>
          <p className="text-sm text-error-text">{t("product.loadFailed")}</p>
        </div>
        <ButtonLink href="/app/scan" fullWidth>
          ← {t("common.back")}
        </ButtonLink>
      </div>
    );
  }

  // ─── Render ─────────────────────────────────────────────────────────────

  const band = SCORE_BANDS[product.scores.score_band];

  const alternatives = alternativesData?.alternatives ?? [];
  const hasAlternatives = alternatives.length > 0;

  return (
    <div className="space-y-4">
      {/* Breadcrumbs */}
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.scan", href: "/app/scan" },
          { label: product.product_name_display ?? product.product_name },
        ]}
      />

      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="flex items-center gap-2 text-lg font-bold text-foreground">
          <Camera size={20} aria-hidden="true" /> {t("product.scanResult")}
        </h1>
        <Link
          href="/app/scan"
          className="text-sm text-brand hover:text-brand-hover"
        >
          {t("scan.scanAnother")} →
        </Link>
      </div>

      {/* ── Scanned Product Card ─────────────────────────────────────────── */}
      <div className="card">
        <div className="flex items-start gap-4">
          <div
            className={`flex h-16 w-16 shrink-0 items-center justify-center rounded-xl text-2xl font-bold ${band.bg} ${band.color}`}
          >
            {toTryVitScore(product.scores.unhealthiness_score)}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-lg font-bold text-foreground">
              {product.product_name_display ?? product.product_name}
            </p>
            <p className="text-sm text-foreground-secondary">{product.brand}</p>
            <div className="mt-2 flex flex-wrap items-center gap-2">
              <NutriScoreBadge
                grade={product.scores.nutri_score}
                size="sm"
                showTooltip
              />
              <span className="rounded-full bg-surface-muted px-2 py-0.5 text-xs text-foreground-secondary">
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
        <div className="mt-3 flex flex-wrap gap-2 text-xs text-foreground-secondary">
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
        <h2 className="mb-2 text-sm font-semibold text-foreground-secondary">
          {t("product.nutritionPer100g")}
        </h2>
        <div className="grid grid-cols-3 gap-2 text-center text-xs">
          <NutrientPill
            label={t("product.caloriesLabel")}
            value={`${product.nutrition_per_100g.calories}`}
            unit="kcal"
          />
          <NutrientPill
            label={t("product.sugars")}
            value={`${product.nutrition_per_100g.sugars_g}`}
            unit="g"
          />
          <NutrientPill
            label={t("product.salt")}
            value={`${product.nutrition_per_100g.salt_g}`}
            unit="g"
          />
          <NutrientPill
            label={t("product.totalFat")}
            value={`${product.nutrition_per_100g.total_fat_g}`}
            unit="g"
          />
          <NutrientPill
            label={t("product.saturatedFat")}
            value={`${product.nutrition_per_100g.saturated_fat_g}`}
            unit="g"
          />
          <NutrientPill
            label={t("product.protein")}
            value={`${product.nutrition_per_100g.protein_g}`}
            unit="g"
          />
        </div>
      </div>

      {/* ── Healthier Alternatives ───────────────────────────────────────── */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold text-foreground flex items-center gap-1.5">
            <Salad size={18} aria-hidden="true" />{" "}
            {t("product.healthierAlternatives")}
          </h2>
          {hasAlternatives && (
            <span className="rounded-full bg-success-bg px-2 py-0.5 text-xs font-medium text-success-text">
              {t("product.found", {
                count: alternativesData?.alternatives_count ?? 0,
              })}
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
        <ButtonLink
          href={`/app/product/${productId}`}
          variant="secondary"
          className="flex-1"
          icon={<ClipboardList size={16} aria-hidden="true" />}
        >
          {t("product.fullDetails")}
        </ButtonLink>
        <ButtonLink
          href="/app/scan"
          className="flex-1"
          icon={<Camera size={16} aria-hidden="true" />}
        >
          {t("product.scanAnother")}
        </ButtonLink>
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
  const { t } = useTranslation();

  if (loading) {
    return <ProductCardSkeleton count={3} />;
  }

  if (alternatives.length === 0) {
    return (
      <div className="card bg-surface-subtle py-6 text-center">
        <p className="text-sm text-foreground-secondary">
          <Trophy size={16} aria-hidden="true" className="inline" />{" "}
          {t("product.bestOption")}
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
  const { t } = useTranslation();
  const activeFlags = [
    product.flags.high_sugar && { emoji: "🍬", label: t("product.highSugar") },
    product.flags.high_salt && { emoji: "🧂", label: t("product.highSalt") },
    product.flags.high_sat_fat && {
      emoji: "🥓",
      label: t("product.highSatFat"),
    },
    product.flags.high_additive_load && {
      emoji: "🧪",
      label: t("product.manyAdditives"),
    },
    product.flags.has_palm_oil && { emoji: "🌴", label: t("product.palmOil") },
  ].filter(Boolean) as { emoji: string; label: string }[];

  if (activeFlags.length === 0) return null;

  return (
    <div className="mt-3 flex flex-wrap gap-1">
      {activeFlags.map((flag) => (
        <span
          key={flag.label}
          className="rounded-full bg-error-bg px-2 py-0.5 text-xs font-medium text-error-text"
        >
          {flag.emoji} {flag.label}
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
    <div className="rounded-lg bg-surface-subtle px-2 py-2">
      <p className="font-medium text-foreground">
        {value} <span className="text-foreground-muted">{unit}</span>
      </p>
      <p className="text-foreground-secondary">{label}</p>
    </div>
  );
}

// ─── Scan Alternative Card ──────────────────────────────────────────────────

function ScanAlternativeCard({
  alt,
  sourceScore,
}: Readonly<{ alt: Alternative; sourceScore: number }>) {
  const { t } = useTranslation();
  const altBand = SCORE_BANDS[scoreBandFromScore(alt.unhealthiness_score)];

  // Calculate improvement percentage
  const improvementPct =
    sourceScore > 0
      ? Math.round((alt.score_improvement / sourceScore) * 100)
      : 0;

  return (
    <Link href={`/app/product/${alt.product_id}`}>
      <div className="card hover-lift-press flex items-center gap-3 border-success-border">
        {/* Score */}
        <div
          className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-lg text-lg font-bold ${altBand.bg} ${altBand.color}`}
        >
          {toTryVitScore(alt.unhealthiness_score)}
        </div>

        {/* Product info */}
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-foreground">
            {alt.product_name}
          </p>
          <p className="truncate text-sm text-foreground-secondary">
            {alt.brand}
          </p>
          <p className="text-xs font-medium text-success-text">
            {t("product.pointsBetter", { points: alt.score_improvement })}
            {improvementPct > 0 && (
              <span className="text-success">
                {" "}
                ({improvementPct}% healthier)
              </span>
            )}
          </p>
        </div>

        {/* Nutri-Score badge */}
        <NutriScoreBadge grade={alt.nutri_score} size="sm" showTooltip />

        {/* Arrow */}
        <span className="shrink-0 text-foreground-muted">›</span>
      </div>
    </Link>
  );
}
