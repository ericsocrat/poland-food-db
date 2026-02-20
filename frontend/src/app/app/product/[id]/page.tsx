"use client";

// ─── Product detail page ────────────────────────────────────────────────────
// Uses the composite api_get_product_profile() endpoint for a single round-trip.

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { eventBus } from "@/lib/events";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { createClient } from "@/lib/supabase/client";
import { getProductProfile, recordProductView } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  SCORE_BANDS,
  scoreBandFromScore,
  getScoreInterpretation,
} from "@/lib/constants";
import { ProductProfileSkeleton } from "@/components/common/skeletons";
import {
  HealthWarningsCard,
  HealthWarningBadge,
} from "@/components/product/HealthWarningsCard";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { ProductHeroImage } from "@/components/product/ProductHeroImage";
import { ProductImageTabs } from "@/components/product/ProductImageTabs";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { NutritionDVBar } from "@/components/product/NutritionDVBar";
import { DVReferenceBadge } from "@/components/product/DVReferenceBadge";
import { DVLegend } from "@/components/product/DVLegend";
import { ShareButton } from "@/components/product/ShareButton";
import { ScoreGauge } from "@/components/product/ScoreGauge";
import { ScoreRadarChart } from "@/components/product/ScoreRadarChart";
import { getTrafficLight } from "@/components/product/TrafficLightChip";
import { NovaIndicator } from "@/components/product/NovaIndicator";
import { TrafficLightStrip } from "@/components/product/TrafficLightStrip";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { PrintButton } from "@/components/common/PrintButton";
import { WatchButton } from "@/components/product/WatchButton";
import { ScoreHistoryPanel } from "@/components/product/ScoreHistoryPanel";
import { ScoreBreakdownPanel } from "@/components/product/ScoreBreakdownPanel";
import { AllergenMatrix } from "@/components/product/AllergenMatrix";
import { IngredientList } from "@/components/product/IngredientList";
import { Info, Globe } from "lucide-react";
import type {
  ProductProfile,
  ProfileAlternative,
  DataConfidence,
} from "@/lib/types";

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
      void eventBus.emit({
        type: "product.viewed",
        payload: { productId, score: profile.scores.unhealthiness_score ?? 0 },
      });
      // Record view for dashboard recently-viewed section
      recordProductView(supabase, productId);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productId]);

  if (isLoading) {
    return <ProductProfileSkeleton />;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.search", href: "/app/search" },
          ]}
        />
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
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.search", href: "/app/search" },
          ]}
        />
        <p className="py-12 text-center text-sm text-foreground-muted">
          {t("product.notFoundPage")}
        </p>
      </div>
    );
  }

  const band = SCORE_BANDS[profile.scores.score_band];

  const tabs: { key: Tab; label: string }[] = [
    { key: "overview", label: t("product.overview") },
    { key: "nutrition", label: t("product.nutrition") },
    { key: "alternatives", label: t("product.alternatives") },
    { key: "scoring", label: t("product.scoring") },
  ];

  return (
    <div className="space-y-4 lg:space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          {
            label:
              profile.product.product_name_display ??
              profile.product.product_name,
          },
        ]}
      />

      {/* Desktop: 2-column grid; Mobile: single column */}
      <div className="lg:grid lg:grid-cols-12 lg:gap-6">
        {/* Left column — sticky on desktop */}
        <div className="space-y-4 lg:col-span-5 lg:space-y-6 lg:self-start lg:sticky lg:top-20">
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
                ean={profile.product.ean}
              />
            </div>

            <div className="flex items-start gap-4">
              <ScoreGauge
                score={profile.scores.unhealthiness_score}
                size="lg"
              />
              <div className="min-w-0 flex-1">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="text-lg font-bold text-foreground lg:text-xl">
                      {profile.product.product_name_display ??
                        profile.product.product_name}
                    </p>
                    {profile.product.product_name_en &&
                      profile.product.product_name_display !==
                        profile.product.product_name && (
                        <p className="text-xs text-foreground-muted">
                          {t("product.originalName")}:{" "}
                          {profile.product.product_name}
                        </p>
                      )}
                    <p className="text-sm text-foreground-secondary lg:text-base">
                      {profile.product.brand}
                    </p>
                  </div>
                  <div className="no-print flex flex-wrap items-center gap-2">
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
                    <CompareCheckbox
                      productId={productId}
                      productName={
                        profile.product.product_name_display ??
                        profile.product.product_name
                      }
                    />
                    <WatchButton productId={productId} />
                    <PrintButton />
                  </div>
                </div>
                <div className="mt-2 flex items-center gap-2">
                  <span className="inline-flex items-center gap-1 rounded-full bg-surface-muted px-2 py-0.5 text-xs font-bold">
                    <NutriScoreBadge
                      grade={profile.scores.nutri_score_label}
                      size="sm"
                    />
                    <span className="text-foreground-secondary">
                      {t("product.nutriScoreLabel")}
                    </span>
                  </span>
                  <span className="rounded-full bg-surface-muted px-2 py-0.5 text-xs text-foreground-secondary">
                    {t("product.novaGroup", {
                      group: profile.scores.nova_group,
                    })}
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
                {profile.product.category_icon}{" "}
                {profile.product.category_display}
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
                <p className="text-xs font-medium text-foreground-muted">
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

          {/* Score interpretation — expandable "What does this score mean?" */}
          <ScoreInterpretationCard score={profile.scores.unhealthiness_score} />

          {/* Personalized health warnings */}
          <ErrorBoundary
            level="section"
            context={{ section: "health-warnings", productId }}
          >
            <HealthWarningsCard productId={productId} />
          </ErrorBoundary>
        </div>

        {/* Right column — scrollable content */}
        <div className="mt-4 space-y-4 lg:col-span-7 lg:mt-0 lg:space-y-6">
          {/* Tab bar */}
          <div
            className="flex gap-1 rounded-lg bg-surface-muted p-1"
            role="tablist"
          >
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                role="tab"
                aria-selected={activeTab === tab.key}
                className={`flex-1 cursor-pointer rounded-md px-3 py-2.5 text-sm font-medium transition-colors ${
                  activeTab === tab.key
                    ? "bg-surface text-brand shadow-sm"
                    : "text-foreground-secondary hover:text-foreground"
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Tab content */}
          <ErrorBoundary
            level="section"
            context={{ section: "tab-content", productId, tab: activeTab }}
          >
            {activeTab === "overview" && <OverviewTab profile={profile} />}
            {activeTab === "nutrition" && <NutritionTab profile={profile} />}
            {activeTab === "alternatives" && (
              <AlternativesTab alternatives={profile.alternatives} />
            )}
            {activeTab === "scoring" && <ScoringTab profile={profile} />}
          </ErrorBoundary>
        </div>
      </div>
    </div>
  );
}

// ─── Helpers ────────────────────────────────────────────────────────────────

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
        <span className="absolute bottom-full left-0 z-10 mb-1 w-56 rounded-lg border border-border bg-surface p-2 text-xs text-foreground-secondary shadow-lg">
          {explanation}
        </span>
      )}
    </span>
  );
}

// ─── Score Interpretation Card ──────────────────────────────────────────────

function ScoreInterpretationCard({ score }: Readonly<{ score: number }>) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const interp = getScoreInterpretation(score);

  return (
    <div className="card">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex w-full items-center justify-between text-sm font-semibold text-foreground-secondary lg:text-base"
        aria-expanded={open}
      >
        {t("scoreInterpretation.title")}
        <span
          className={`text-xs transition-transform ${open ? "rotate-180" : ""}`}
          aria-hidden="true"
        >
          ▾
        </span>
      </button>
      {open && (
        <div
          className={`mt-2 rounded-lg px-3 py-2 text-sm ${interp.bg} ${interp.color}`}
          data-testid="score-interpretation"
        >
          {t(interp.key)}
        </div>
      )}
    </div>
  );
}

// ─── Overview Tab ───────────────────────────────────────────────────────────

function OverviewTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  return (
    <div className="space-y-4 lg:space-y-6">
      {/* Ingredients */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.ingredients")}
        </h3>
        <IngredientList ingredients={profile.ingredients} />
      </div>

      {/* Allergens */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.allergens")}
        </h3>
        <AllergenMatrix allergens={profile.allergens} />
      </div>

      {/* Data quality */}
      <DataQualityCard quality={profile.quality} />

      {/* Eco-Score placeholder */}
      <div className="card">
        <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold text-foreground-secondary lg:text-base">
          <Globe size={16} aria-hidden="true" /> {t("product.ecoScoreTitle")}
        </h3>
        <div className="flex items-center gap-2 rounded-lg border border-dashed border-blue-200 bg-blue-50/50 px-3 py-3">
          <Info size={18} className="flex-shrink-0 text-blue-600" aria-hidden="true" />
          <p className="text-sm text-blue-700">
            {t("product.ecoScoreComingSoon")}
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

type NutritionView = "per100g" | "perServing";

function NutritionTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  const hasServing = profile.nutrition.per_serving !== null;
  const [view, setView] = useState<NutritionView>("per100g");

  const n =
    view === "perServing" && profile.nutrition.per_serving
      ? profile.nutrition.per_serving
      : profile.nutrition.per_100g;
  const dv = profile.nutrition.daily_values;
  const dvData =
    view === "perServing" ? (dv?.per_serving ?? null) : (dv?.per_100g ?? null);

  const energyKj = Math.round(n.calories_kcal * 4.184);
  const sodiumMg = Math.round(n.salt_g * 400);

  const rows = [
    {
      label: t("product.caloriesLabel"),
      value: `${n.calories_kcal} kcal / ${energyKj} kJ`,
      dv: dvData?.calories ?? null,
      tl: null as ReturnType<typeof getTrafficLight>,
    },
    {
      label: t("product.totalFat"),
      value: `${n.total_fat_g} g`,
      dv: dvData?.total_fat ?? null,
      tl: getTrafficLight("total_fat", n.total_fat_g),
    },
    {
      label: t("product.saturatedFat"),
      value: `${n.saturated_fat_g} g`,
      dv: dvData?.saturated_fat ?? null,
      tl: getTrafficLight("saturated_fat", n.saturated_fat_g),
    },
    {
      label: t("product.transFat"),
      value: n.trans_fat_g === null ? "—" : `${n.trans_fat_g} g`,
      dv: dvData?.trans_fat ?? null,
      tl: null as ReturnType<typeof getTrafficLight>,
    },
    {
      label: t("product.carbs"),
      value: `${n.carbs_g} g`,
      dv: dvData?.carbs ?? null,
      tl: null as ReturnType<typeof getTrafficLight>,
    },
    {
      label: t("product.sugars"),
      value: `${n.sugars_g} g`,
      dv: dvData?.sugars ?? null,
      tl: getTrafficLight("sugars", n.sugars_g),
    },
    {
      label: t("product.fibre"),
      value: n.fibre_g === null ? "—" : `${n.fibre_g} g`,
      dv: dvData?.fiber ?? null,
      tl: getTrafficLight("fibre", n.fibre_g),
      beneficial: true,
    },
    {
      label: t("product.protein"),
      value: `${n.protein_g} g`,
      dv: dvData?.protein ?? null,
      tl: getTrafficLight("protein", n.protein_g),
      beneficial: true,
    },
    {
      label: t("product.salt"),
      value: `${n.salt_g} g`,
      dv: dvData?.salt ?? null,
      tl: getTrafficLight("salt", n.salt_g),
    },
  ];

  return (
    <div className="card">
      <div className="mb-3 flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground-secondary lg:text-base">
          {view === "perServing" && profile.nutrition.per_serving
            ? t("product.nutritionPerServing", {
                size: profile.nutrition.per_serving.serving_size,
              })
            : t("product.nutritionPer100g")}
        </h3>
        <div className="flex items-center gap-2">
          {hasServing && (
            <div
              className="flex rounded-lg border border-border bg-surface-subtle p-0.5"
              role="radiogroup"
              aria-label={t("product.nutritionViewToggle")}
            >
              <button
                type="button"
                role="radio"
                aria-checked={view === "per100g"}
                onClick={() => setView("per100g")}
                className={`rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                  view === "per100g"
                    ? "bg-surface text-foreground shadow-sm"
                    : "text-foreground-muted hover:text-foreground-secondary"
                }`}
              >
                {t("product.per100g")}
              </button>
              <button
                type="button"
                role="radio"
                aria-checked={view === "perServing"}
                onClick={() => setView("perServing")}
                className={`rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                  view === "perServing"
                    ? "bg-surface text-foreground shadow-sm"
                    : "text-foreground-muted hover:text-foreground-secondary"
                }`}
              >
                {t("product.perServing")}
              </button>
            </div>
          )}
          {dv && dv.reference_type !== "none" && (
            <DVReferenceBadge
              referenceType={dv.reference_type}
              regulation={dv.regulation}
            />
          )}
        </div>
      </div>

      {/* Traffic light summary strip */}
      <div className="mb-3">
        <TrafficLightStrip nutrition={n} />
      </div>

      <table className="w-full text-sm">
        <thead className="hidden text-xs text-foreground-muted lg:table-header-group">
          <tr className="border-b border-border">
            <th className="pb-2 text-left font-medium">
              {t("product.nutrient")}
            </th>
            <th className="pb-2 text-right font-medium">
              {view === "perServing"
                ? t("product.perServing")
                : t("product.per100g")}
            </th>
            <th className="pb-2 pl-4 text-left font-medium">
              {t("product.dailyValue")}
            </th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <NutritionDVBar
              key={row.label}
              label={row.label}
              rawValue={row.value}
              dv={row.dv}
              trafficLight={row.tl}
              beneficial={row.beneficial}
            />
          ))}
        </tbody>
      </table>
      {dv && dv.reference_type !== "none" && <DVLegend />}

      {/* Sodium / Salt context note */}
      <div className="mt-3 rounded-lg bg-blue-50 px-3 py-2 text-xs text-blue-700">
        <span className="font-medium">{t("product.sodiumNote")}</span>{" "}
        {t("product.sodiumValue", { mg: sodiumMg })}
      </div>

      {/* Glycemic Index indicator */}
      {profile.nutrition.gi_estimate != null && (
        <GlycemicIndexIndicator gi={profile.nutrition.gi_estimate} />
      )}
    </div>
  );
}

// ─── Glycemic Index Indicator ───────────────────────────────────────────────

function giBand(score: number): "low" | "medium" | "high" {
  if (score <= 55) return "low";
  if (score <= 69) return "medium";
  return "high";
}

function GlycemicIndexIndicator({ gi }: Readonly<{ gi: number }>) {
  const { t } = useTranslation();

  const band = giBand(gi);

  const config = {
    low: {
      bg: "bg-green-50",
      border: "border-green-200",
      text: "text-green-700",
      badge: "bg-green-100 text-green-800",
      label: t("product.gi.low"),
    },
    medium: {
      bg: "bg-amber-50",
      border: "border-amber-200",
      text: "text-amber-700",
      badge: "bg-amber-100 text-amber-800",
      label: t("product.gi.medium"),
    },
    high: {
      bg: "bg-red-50",
      border: "border-red-200",
      text: "text-red-700",
      badge: "bg-red-100 text-red-800",
      label: t("product.gi.high"),
    },
  };

  const c = config[band];

  return (
    <div
      className={`mt-3 rounded-lg border ${c.border} ${c.bg} px-3 py-3`}
      data-testid="gi-indicator"
    >
      <div className="flex items-center justify-between">
        <span className={`text-sm font-medium ${c.text}`}>
          {t("product.gi.label")}
        </span>
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-semibold ${c.badge}`}
          data-testid="gi-badge"
        >
          {c.label} ({gi})
        </span>
      </div>
    </div>
  );
}

// ─── Data Quality Card ──────────────────────────────────────────────────────

function DataQualityCard({ quality }: Readonly<{ quality: DataConfidence }>) {
  const { t } = useTranslation();
  const q = quality as Record<string, unknown>;
  const band = (q.confidence_band as string) ?? "unknown";
  const score = (q.confidence_score as number) ?? 0;

  const bandConfig: Record<
    string,
    { bg: string; fill: string; label: string }
  > = {
    high: { bg: "bg-green-100", fill: "bg-green-500", label: "✓" },
    medium: { bg: "bg-amber-100", fill: "bg-amber-500", label: "~" },
    low: { bg: "bg-red-100", fill: "bg-red-400", label: "!" },
    unknown: { bg: "bg-gray-100", fill: "bg-gray-400", label: "?" },
  };

  const cfg = bandConfig[band] ?? bandConfig.unknown;

  return (
    <div className="card">
      <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
        {t("product.dataQuality")}
      </h3>
      <div className="flex items-center gap-3">
        <span
          className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold ${cfg.bg}`}
        >
          {cfg.label}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between text-sm">
            <span className="font-medium capitalize text-foreground">
              {t("product.confidence", { value: band })}
            </span>
            <span className="text-xs text-foreground-muted">{score}%</span>
          </div>
          <div
            className={`mt-1 h-2 w-full overflow-hidden rounded-full ${cfg.bg}`}
          >
            <div
              className={`h-full rounded-full transition-all ${cfg.fill}`}
              style={{ width: `${Math.min(score, 100)}%` }}
            />
          </div>
        </div>
      </div>
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
      <p className="py-8 text-center text-sm text-foreground-muted">
        {t("product.noAlternatives")}
      </p>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-sm text-foreground-secondary">
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

  return (
    <Link href={`/app/product/${alt.product_id}`}>
      <div className="card hover-lift-press flex items-center gap-3">
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${SCORE_BANDS[scoreBandFromScore(alt.unhealthiness_score)].bg} ${SCORE_BANDS[scoreBandFromScore(alt.unhealthiness_score)].color}`}
        >
          {alt.unhealthiness_score}
        </div>
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-foreground">
            {alt.product_name}
          </p>
          <p className="text-sm text-foreground-secondary">{alt.brand}</p>
          <p className="text-xs text-green-600">
            {t("product.pointsBetter", { points: alt.score_delta })}
          </p>
        </div>
        <HealthWarningBadge productId={alt.product_id} />
        <NutriScoreBadge grade={alt.nutri_score} size="sm" showTooltip />
      </div>
    </Link>
  );
}

// ─── Scoring Tab ────────────────────────────────────────────────────────────

/** Convert snake_case to Title Case: "saturated_fat" → "Saturated Fat" */
function formatSnakeCase(s: string): string {
  return s
    .split("_")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

/** Human-friendly factor name mapping */
const FACTOR_LABELS: Record<string, string> = {
  saturated_fat: "Saturated Fat",
  trans_fat: "Trans Fat",
  sugars: "Sugars",
  salt: "Salt",
  calories: "Calories",
  additives: "Additives",
  prep_method: "Preparation Method",
  controversies: "Controversies",
  ingredient_concern: "Ingredient Concern",
};

function formatFactorName(name: string): string {
  return FACTOR_LABELS[name] ?? formatSnakeCase(name);
}

function ScoringTab({ profile }: Readonly<{ profile: ProductProfile }>) {
  const { t } = useTranslation();
  const scores = profile.scores;

  const topFactors = Array.isArray(scores.score_breakdown)
    ? scores.score_breakdown
        .toSorted((a, b) => (b.weighted ?? 0) - (a.weighted ?? 0))
        .slice(0, 5)
    : [];

  return (
    <div className="space-y-4 lg:space-y-6">
      {/* Summary */}
      <div className="card">
        <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.summary")}
        </h3>
        <p className="text-sm text-foreground-secondary">{scores.headline}</p>
      </div>

      {/* Radar chart */}
      {Array.isArray(scores.score_breakdown) &&
        scores.score_breakdown.length > 0 && (
          <div className="card">
            <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
              {t("product.scoreBreakdown")}
            </h3>
            <ScoreRadarChart breakdown={scores.score_breakdown} />
          </div>
        )}

      {/* Detailed score breakdown (lazy-loaded) */}
      <ScoreBreakdownPanel
        productId={profile.product.product_id}
        score={scores.unhealthiness_score}
        scoreBand={SCORE_BANDS[scores.score_band]?.label ?? scores.score_band}
      />

      {/* NOVA processing indicator */}
      {scores.nova_group && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("product.processingLevel")}
          </h3>
          <NovaIndicator novaGroup={scores.nova_group} />
        </div>
      )}

      {/* Score breakdown factors */}
      {topFactors.length > 0 && (
        <div className="card">
          <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("product.topScoreFactors")}
          </h3>
          <div className="space-y-2">
            {topFactors.map((f) => (
              <div
                key={String(f.name)}
                className="flex items-center justify-between text-sm"
              >
                <span className="text-foreground-secondary">
                  {formatFactorName(String(f.name))}
                </span>
                <span className="font-medium text-foreground">
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
          <h3 className="mb-2 text-sm font-semibold text-amber-800 lg:text-base">
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
        <h3 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.categoryContext")}
        </h3>
        <div className="text-sm text-foreground-secondary">
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
          <p>
            {t("product.position", {
              position: formatSnakeCase(
                scores.category_context.relative_position,
              ),
            })}
          </p>
        </div>
      </div>

      {/* Score history */}
      <ScoreHistoryPanel productId={profile.product.product_id} />
    </div>
  );
}
