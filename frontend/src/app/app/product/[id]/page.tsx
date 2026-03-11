"use client";

// ─── Product detail page ────────────────────────────────────────────────────
// Uses the composite api_get_product_profile() endpoint for a single round-trip.

import { Button } from "@/components/common/Button";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { PrintButton } from "@/components/common/PrintButton";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { ProductProfileSkeleton } from "@/components/common/skeletons";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { AlternativeProductCard } from "@/components/alternatives/AlternativeProductCard";
import { AlternativesSection } from "@/components/alternatives/AlternativesSection";
import { ActionOverflowMenu } from "@/components/product/ActionOverflowMenu";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { AllergenMatrix } from "@/components/product/AllergenMatrix";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { DVLegend } from "@/components/product/DVLegend";
import { DVReferenceBadge } from "@/components/product/DVReferenceBadge";
import { HealthWarningsCard } from "@/components/product/HealthWarningsCard";
import { IngredientList } from "@/components/product/IngredientList";
import { NovaIndicator } from "@/components/product/NovaIndicator";
import { NutritionDVBar } from "@/components/product/NutritionDVBar";
import { PercentileBadge } from "@/components/product/PercentileBadge";
import { ProductHeroImage } from "@/components/product/ProductHeroImage";
import { ProductImageTabs } from "@/components/product/ProductImageTabs";
import { ScoreBreakdownPanel } from "@/components/product/ScoreBreakdownPanel";
import { ScoreGauge } from "@/components/product/ScoreGauge";
import { ScoreHistoryPanel } from "@/components/product/ScoreHistoryPanel";
import { ScoreRadarChart } from "@/components/product/ScoreRadarChart";
import { ShareButton } from "@/components/product/ShareButton";
import { getTrafficLight } from "@/components/product/TrafficLightChip";
import { TrafficLightStrip } from "@/components/product/TrafficLightStrip";
import { WatchButton } from "@/components/product/WatchButton";
import { CachedTimestamp } from "@/components/pwa/CachedTimestamp";
import { useAnalytics } from "@/hooks/use-analytics";
import { useOnlineStatus } from "@/hooks/use-online-status";
import { getProductProfile, recordProductView } from "@/lib/api";
import { cacheProduct, getCachedProduct } from "@/lib/cache-manager";
import {
    FEATURES,
    getScoreInterpretation,
    SCORE_BANDS,
} from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { useTranslation } from "@/lib/i18n";
import { IS_QA_MODE } from "@/lib/qa-mode";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import type {
    DataConfidence,
    ProductProfile,
} from "@/lib/types";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { ChevronDown, ChevronUp, Globe, Info } from "lucide-react";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";

type Tab = "overview" | "nutrition" | "alternatives" | "scoring";
const TAB_ORDER: Tab[] = ["overview", "nutrition", "alternatives", "scoring"];
const SWIPE_THRESHOLD = 50;

// ─── Progressive Disclosure Persistence ─────────────────────────────────────
const FULL_ANALYSIS_KEY = "tryvit:product-full-analysis";

function getStoredFullAnalysis(): boolean {
  if (typeof window === "undefined") return false;
  return localStorage.getItem(FULL_ANALYSIS_KEY) === "true";
}

function setStoredFullAnalysis(expanded: boolean) {
  localStorage.setItem(FULL_ANALYSIS_KEY, expanded ? "true" : "false");
}

export default function ProductDetailPage() {
  const params = useParams();
  const productId = Number(params.id);
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<Tab>("overview");
  const [showFullAnalysis, setShowFullAnalysis] = useState(false);
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const isOnline = useOnlineStatus();
  const [cachedAt, setCachedAt] = useState<number | null>(null);

  // Hydrate progressive disclosure preference from localStorage (SSR-safe)
  useEffect(() => {
    setShowFullAnalysis(getStoredFullAnalysis());
  }, []);

  const toggleFullAnalysis = useCallback(() => {
    setShowFullAnalysis((prev) => {
      const next = !prev;
      setStoredFullAnalysis(next);
      return next;
    });
  }, []);

  // ─── Swipe gesture handling ───────────────────────────────────────────────
  const touchStartX = useRef(0);

  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
  }, []);

  const handleTouchEnd = useCallback(
    (e: React.TouchEvent) => {
      const diff = touchStartX.current - e.changedTouches[0].clientX;
      if (Math.abs(diff) > SWIPE_THRESHOLD) {
        setActiveTab((prev) => {
          const idx = TAB_ORDER.indexOf(prev);
          const next = idx + (diff > 0 ? 1 : -1);
          return TAB_ORDER[Math.max(0, Math.min(next, TAB_ORDER.length - 1))];
        });
      }
    },
    [],
  );

  const {
    data: profile,
    isLoading,
    error,
  } = useQuery({
    queryKey: queryKeys.productProfile(productId),
    queryFn: async () => {
      const result = await getProductProfile(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      // Cache the product for offline access
      void cacheProduct(productId, result.data);
      setCachedAt(null); // Fresh data — not from cache
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
      if (!IS_QA_MODE) {
        recordProductView(supabase, productId);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productId]);

  // ─── Offline fallback: load from IndexedDB cache when query fails ─────────
  useEffect(() => {
    if (error && !isOnline && !profile) {
      getCachedProduct<ProductProfile>(productId).then((cached) => {
        if (cached) {
          queryClient.setQueryData(
            queryKeys.productProfile(productId),
            cached.data,
          );
          setCachedAt(cached.cachedAt);
        }
      });
    }
  }, [error, isOnline, productId, profile, queryClient]);

  const handleRefresh = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: queryKeys.productProfile(productId) });
  }, [queryClient, productId]);

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
        <div className="card border-error-border bg-error-bg py-8 text-center">
          <p className="mb-3 text-sm text-error-text">{t("product.loadFailed")}</p>
          <Button
            onClick={() =>
              queryClient.invalidateQueries({
                queryKey: queryKeys.productProfile(productId),
              })
            }
          >
            {t("common.retry")}
          </Button>
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

  const tabs: { key: Tab; label: string; shortLabel: string }[] = [
    { key: "overview", label: t("product.overview"), shortLabel: t("product.overviewShort") },
    { key: "nutrition", label: t("product.nutrition"), shortLabel: t("product.nutritionShort") },
    { key: "alternatives", label: t("product.alternatives"), shortLabel: t("product.alternativesShort") },
    { key: "scoring", label: t("product.scoring"), shortLabel: t("product.scoringShort") },
  ];

  return (
    <PullToRefresh onRefresh={handleRefresh}>
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
                <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                  <div>
                    <h1 className="text-lg font-bold text-foreground lg:text-xl">
                      {profile.product.product_name_display ??
                        profile.product.product_name}
                    </h1>
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
                    {cachedAt && <CachedTimestamp cachedAt={cachedAt} />}
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
                    <span className="hidden sm:contents">
                      <WatchButton productId={productId} />
                      <PrintButton />
                    </span>
                    <ActionOverflowMenu className="sm:hidden">
                      <WatchButton productId={productId} />
                      <PrintButton />
                    </ActionOverflowMenu>
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
                  <PercentileBadge
                    rank={profile.scores.category_context?.rank}
                    total={profile.scores.category_context?.total_in_category}
                  />
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
          <ScoreInterpretationCard score={toTryVitScore(profile.scores.unhealthiness_score)} />

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
          {showFullAnalysis ? (
            <>
              {/* Collapse to summary */}
              <button
                type="button"
                onClick={toggleFullAnalysis}
                data-testid="toggle-analysis"
                className="flex w-full items-center justify-center gap-2 rounded-lg border border-border bg-surface px-4 py-2.5 text-sm font-medium text-foreground-secondary transition-colors hover:bg-surface-muted"
              >
                <ChevronUp className="h-4 w-4" />
                {t("product.showSummary")}
              </button>

              {/* Tab bar */}
              <div
                className="flex gap-1 rounded-lg bg-surface-muted p-1"
                role="tablist"
                data-testid="tab-bar"
              >
                {tabs.map((tab) => (
                  <button
                    key={tab.key}
                    id={`tab-${tab.key}`}
                    onClick={() => setActiveTab(tab.key)}
                    role="tab"
                    aria-selected={activeTab === tab.key}
                    aria-label={tab.label}
                    className={`flex-1 cursor-pointer rounded-md px-2 py-2.5 text-sm font-medium transition-colors sm:px-3 ${
                      activeTab === tab.key
                        ? "bg-surface text-brand shadow-sm"
                        : "text-foreground-secondary hover:text-foreground"
                    }`}
                  >
                    <span className="sm:hidden">{tab.shortLabel}</span>
                    <span className="hidden sm:inline">{tab.label}</span>
                  </button>
                ))}
              </div>

              {/* Tab content — swipeable on touch devices */}
              <div
                onTouchStart={handleTouchStart}
                onTouchEnd={handleTouchEnd}
                data-testid="tab-content"
                role="tabpanel"
                aria-labelledby={`tab-${activeTab}`}
              >
                <ErrorBoundary
                  level="section"
                  context={{ section: "tab-content", productId, tab: activeTab }}
                >
                  {activeTab === "overview" && <OverviewTab profile={profile} />}
                  {activeTab === "nutrition" && (
                    <NutritionTab profile={profile} />
                  )}
                  {activeTab === "alternatives" && (
                    <AlternativesSection
                      alternatives={profile.alternatives}
                      currentScore={profile.scores.unhealthiness_score}
                    />
                  )}
                  {activeTab === "scoring" && <ScoringTab profile={profile} />}
                </ErrorBoundary>
              </div>
            </>
          ) : (
            <QuickSummary
              profile={profile}
              onExpand={toggleFullAnalysis}
            />
          )}
        </div>
      </div>
    </div>
    </PullToRefresh>
  );
}

// ─── Quick Summary (Progressive Disclosure) ────────────────────────────────

function QuickSummary({
  profile,
  onExpand,
}: Readonly<{
  profile: ProductProfile;
  onExpand: () => void;
}>) {
  const { t } = useTranslation();
  const interp = getScoreInterpretation(toTryVitScore(profile.scores.unhealthiness_score));
  const topAlts = profile.alternatives.slice(0, 2);

  return (
    <div className="space-y-4" data-testid="quick-summary">
      {/* Score interpretation */}
      <div className={`card ${interp.bg}`}>
        <h2 className="mb-1 text-sm font-semibold text-foreground-secondary">
          {t("product.quickSummary")}
        </h2>
        <p className={`text-sm ${interp.color}`}>{t(interp.key)}</p>
      </div>

      {/* Traffic light strip */}
      <div className="card">
        <TrafficLightStrip nutrition={profile.nutrition.per_100g} />
      </div>

      {/* Top alternatives preview */}
      {topAlts.length > 0 && (
        <div className="card" data-testid="quick-summary-alternatives">
          <h2 className="mb-2 text-sm font-semibold text-foreground-secondary">
            {t("product.topAlternatives")}
          </h2>
          <div className="space-y-3">
            {topAlts.map((alt) => (
              <AlternativeProductCard
                key={alt.product_id}
                alt={alt}
                currentScore={profile.scores.unhealthiness_score}
              />
            ))}
          </div>
          {profile.alternatives.length > 2 && (
            <button
              type="button"
              onClick={onExpand}
              className="mt-2 text-sm font-medium text-brand hover:underline"
            >
              {t("product.viewAllAlternatives")} (
              {profile.alternatives.length})
            </button>
          )}
        </div>
      )}

      {/* Expand to full analysis */}
      <Button
        fullWidth
        onClick={onExpand}
        data-testid="toggle-analysis"
      >
        <ChevronDown className="h-4 w-4" />
        {t("product.showFullAnalysis")}
      </Button>
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
        className="inline-flex items-center gap-1 rounded bg-error-bg px-2 py-0.5 text-xs font-medium text-error-text transition-colors hover:bg-error-bg"
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
    <div className="card" data-testid="score-interpretation">
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
          data-testid="score-interpretation-content"
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
        <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.ingredients")}
        </h2>
        <IngredientList ingredients={profile.ingredients} />
      </div>

      {/* Allergens */}
      <div className="card">
        <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.allergens")}
        </h2>
        <AllergenMatrix allergens={profile.allergens} />
      </div>

      {/* Data quality */}
      <DataQualityCard quality={profile.quality} />

      {/* Eco-Score placeholder – hidden until FEATURES.ECO_SCORE is enabled */}
      {FEATURES.ECO_SCORE && (
        <div className="card">
          <h2 className="mb-2 flex items-center gap-1.5 text-sm font-semibold text-foreground-secondary lg:text-base">
            <Globe size={16} aria-hidden="true" /> {t("product.ecoScoreTitle")}
          </h2>
          <div className="flex items-center gap-2 rounded-lg border border-dashed border-info-border bg-info-bg/50 px-3 py-3">
            <Info
              size={18}
              className="flex-shrink-0 text-info-text"
              aria-hidden="true"
            />
            <p className="text-sm text-info-text">
              {t("product.ecoScoreComingSoon")}
            </p>
          </div>
        </div>
      )}

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
        <h2 className="text-sm font-semibold text-foreground-secondary lg:text-base">
          {view === "perServing" && profile.nutrition.per_serving
            ? t("product.nutritionPerServing", {
                size: profile.nutrition.per_serving.serving_size,
              })
            : t("product.nutritionPer100g")}
        </h2>
        <div className="flex items-center gap-2">
          {hasServing && (
            <div
              className="flex rounded-lg border border-border bg-surface-subtle p-0.5"
              role="radiogroup"
              aria-label={t("product.nutritionViewToggle")}
            >
              <label
                className={`cursor-pointer rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                  view === "per100g"
                    ? "bg-surface text-foreground shadow-sm"
                    : "text-foreground-muted hover:text-foreground-secondary"
                }`}
              >
                <input
                  type="radio"
                  name="nutritionView"
                  className="sr-only"
                  value="per100g"
                  checked={view === "per100g"}
                  onChange={() => setView("per100g")}
                />
                {t("product.per100g")}
              </label>
              <label
                className={`cursor-pointer rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                  view === "perServing"
                    ? "bg-surface text-foreground shadow-sm"
                    : "text-foreground-muted hover:text-foreground-secondary"
                }`}
              >
                <input
                  type="radio"
                  name="nutritionView"
                  className="sr-only"
                  value="perServing"
                  checked={view === "perServing"}
                  onChange={() => setView("perServing")}
                />
                {t("product.perServing")}
              </label>
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
      <div className="mt-3 rounded-lg bg-info-bg px-3 py-2 text-xs text-info-text">
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
      bg: "bg-success-bg",
      border: "border-success-border",
      text: "text-success-text",
      badge: "bg-success-bg text-success-text",
      label: t("product.gi.low"),
    },
    medium: {
      bg: "bg-warning-bg",
      border: "border-warning-border",
      text: "text-warning-text",
      badge: "bg-warning-bg text-warning-text",
      label: t("product.gi.medium"),
    },
    high: {
      bg: "bg-error-bg",
      border: "border-error-border",
      text: "text-error-text",
      badge: "bg-error-bg text-error-text",
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
    high: { bg: "bg-success-bg", fill: "bg-success", label: "✓" },
    medium: { bg: "bg-warning-bg", fill: "bg-warning", label: "~" },
    low: { bg: "bg-error-bg", fill: "bg-error", label: "!" },
    unknown: { bg: "bg-surface-muted", fill: "bg-neutral-400", label: "?" },
  };

  const cfg = bandConfig[band] ?? bandConfig.unknown;

  return (
    <div className="card">
      <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
        {t("product.dataQuality")}
      </h2>
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
        <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.summary")}
        </h2>
        <p className="text-sm text-foreground-secondary">{scores.headline}</p>
      </div>

      {/* Radar chart */}
      {Array.isArray(scores.score_breakdown) &&
        scores.score_breakdown.length > 0 && (
          <div className="card">
            <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
              {t("product.scoreBreakdown")}
            </h2>
            <ScoreRadarChart breakdown={scores.score_breakdown} />
          </div>
        )}

      {/* Detailed score breakdown (lazy-loaded) */}
      <ScoreBreakdownPanel
        productId={profile.product.product_id}
        score={toTryVitScore(scores.unhealthiness_score)}
        scoreBand={SCORE_BANDS[scores.score_band]?.label ?? scores.score_band}
      />

      {/* NOVA processing indicator */}
      {scores.nova_group && (
        <div className="card">
          <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("product.processingLevel")}
          </h2>
          <NovaIndicator novaGroup={scores.nova_group} />
        </div>
      )}

      {/* Score breakdown factors */}
      {topFactors.length > 0 && (
        <div className="card">
          <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
            {t("product.topScoreFactors")}
          </h2>
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
        <div className="card border-warning-border bg-warning-bg">
          <h2 className="mb-2 text-sm font-semibold text-warning-text lg:text-base">
            {t("product.warnings")}
          </h2>
          <ul className="list-inside list-disc space-y-1 text-sm text-warning-text/80">
            {profile.warnings.map((w) => (
              <li key={w.type}>{w.message}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Category context */}
      <div className="card">
        <h2 className="mb-2 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("product.categoryContext")}
        </h2>
        <div className="text-sm text-foreground-secondary">
          <div className="flex items-center gap-2">
            <p>
              {t("product.rank", {
                rank: scores.category_context.rank,
                total: scores.category_context.total_in_category,
              })}
            </p>
            <PercentileBadge
              rank={scores.category_context.rank}
              total={scores.category_context.total_in_category}
            />
          </div>
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
