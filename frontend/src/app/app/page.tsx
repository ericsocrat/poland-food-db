"use client";

import { AllergenChips } from "@/components/common/AllergenChips";
import { EmptyState } from "@/components/common/EmptyState";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { ProductThumbnail } from "@/components/common/ProductThumbnail";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { DashboardSkeleton } from "@/components/common/skeletons";
import { DashboardGreeting } from "@/components/dashboard/DashboardGreeting";
import { QuickActions } from "@/components/dashboard/QuickActions";
import { ScoreSparkline } from "@/components/dashboard/ScoreSparkline";
import { useAnalytics } from "@/hooks/use-analytics";
import {
    useProductAllergenWarnings,
    type AllergenWarningMap,
} from "@/hooks/use-product-allergens";
import type { AllergenWarning } from "@/lib/allergen-matching";
import { getDashboardData } from "@/lib/api";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import type {
    DashboardFavoritePreview,
    DashboardStats,
    RecentlyViewedProduct,
} from "@/lib/types";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
    BarChart3,
    Camera,
    ClipboardList,
    Eye,
    Heart,
    Home,
    Star,
    TrendingUp,
} from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useMemo } from "react";

// ─── Helpers ────────────────────────────────────────────────────────────────

function ScorePill({ score }: Readonly<{ score: number | null }>) {
  if (score == null) return null;
  const band = scoreBandFromScore(score);
  const cfg = SCORE_BANDS[band];
  return (
    <span
      className={`rounded-full px-2 py-0.5 text-xs font-semibold ${cfg.bg} ${cfg.color}`}
    >
      {toTryVitScore(score)}
    </span>
  );
}

function NutriBadge({ grade }: Readonly<{ grade: string | null }>) {
  if (!grade) return null;
  return <NutriScoreBadge grade={grade} size="sm" />;
}

// ─── Section Components ─────────────────────────────────────────────────────

function SummaryCard({
  stats,
  recentlyViewed,
  favoritesPreview,
}: Readonly<{
  stats: DashboardStats;
  recentlyViewed: RecentlyViewedProduct[];
  favoritesPreview: DashboardFavoritePreview[];
}>) {
  const { t } = useTranslation();

  const statItems = [
    { label: t("dashboard.scanned"), value: stats.total_scanned, icon: Camera },
    { label: t("dashboard.viewed"), value: stats.total_viewed, icon: Eye },
    {
      label: t("dashboard.lists"),
      value: stats.lists_count,
      icon: ClipboardList,
    },
    {
      label: t("dashboard.favorites"),
      value: stats.favorites_count,
      icon: Heart,
    },
  ];

  const summary = useMemo(() => {
    const sevenDaysAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;

    const weekViewed = recentlyViewed.filter(
      (p) => new Date(p.viewed_at).getTime() >= sevenDaysAgo,
    );
    const weekFavorited = favoritesPreview.filter(
      (p) => new Date(p.added_at).getTime() >= sevenDaysAgo,
    );

    const scored = weekViewed.filter((p) => p.unhealthiness_score != null);
    const avgScore =
      scored.length > 0
        ? Math.round(
            scored.reduce((sum, p) => sum + (p.unhealthiness_score ?? 0), 0) /
              scored.length,
          )
        : null;

    const bestFind =
      scored.length > 0
        ? scored.reduce(
            (best, p) =>
              (p.unhealthiness_score ?? 100) < (best.unhealthiness_score ?? 100)
                ? p
                : best,
            scored[0],
          )
        : null;

    return {
      viewedCount: weekViewed.length,
      favoritedCount: weekFavorited.length,
      avgScore,
      bestFind,
      allScores: weekViewed.map((p) => p.unhealthiness_score),
    };
  }, [recentlyViewed, favoritesPreview]);

  const hasWeeklyActivity =
    summary.viewedCount > 0 || summary.favoritedCount > 0;

  const avgBand =
    summary.avgScore == null
      ? null
      : SCORE_BANDS[scoreBandFromScore(summary.avgScore)];

  return (
    <section className="card space-y-4" data-testid="weekly-summary">
      {/* Overview stats */}
      <div className="grid grid-cols-4 gap-3" data-testid="stats-grid">
        {statItems.map((s) => (
          <div key={s.label} className="flex flex-col items-center gap-1">
            <s.icon
              size={18}
              aria-hidden="true"
              className="text-foreground-secondary"
            />
            <p className="text-xl font-bold tabular-nums text-foreground lg:text-2xl">
              {s.value}
            </p>
            <p className="text-xs text-foreground-secondary">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Weekly activity (conditional) */}
      {hasWeeklyActivity && (
        <>
          <div className="border-t border-surface-muted" />

          <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground">
            <BarChart3 size={20} aria-hidden="true" />{" "}
            {t("dashboard.weeklySummary")}
          </h2>

          <div className="grid grid-cols-2 gap-3">
            {/* Products viewed this week */}
            <div className="flex items-center gap-2 rounded-lg bg-surface-muted px-3 py-2">
              <Eye
                size={16}
                aria-hidden="true"
                className="text-foreground-muted"
              />
              <div>
                <p
                  className="text-lg font-bold tabular-nums text-foreground"
                  data-testid="weekly-viewed-count"
                >
                  {summary.viewedCount}
                </p>
                <p className="text-xs text-foreground-secondary">
                  {t("dashboard.weeklyViewed")}
                </p>
              </div>
            </div>

            {/* Favorited this week */}
            <div className="flex items-center gap-2 rounded-lg bg-surface-muted px-3 py-2">
              <Heart
                size={16}
                aria-hidden="true"
                className="text-foreground-muted"
              />
              <div>
                <p
                  className="text-lg font-bold tabular-nums text-foreground"
                  data-testid="weekly-favorited-count"
                >
                  {summary.favoritedCount}
                </p>
                <p className="text-xs text-foreground-secondary">
                  {t("dashboard.weeklyFavorited")}
                </p>
              </div>
            </div>
          </div>

          {/* Average score */}
          {avgBand && summary.avgScore != null && (
            <div
              className="flex items-center justify-between rounded-lg bg-surface-muted px-3 py-2"
              data-testid="weekly-avg-score"
            >
              <div className="flex items-center gap-2">
                <TrendingUp
                  size={16}
                  aria-hidden="true"
                  className="text-foreground-muted"
                />
                <span className="text-sm text-foreground-secondary">
                  {t("dashboard.weeklyAvgScore")}
                </span>
              </div>
              <span
                className={`rounded-full px-2 py-0.5 text-sm font-bold ${avgBand.bg} ${avgBand.color}`}
              >
                {toTryVitScore(summary.avgScore)}
              </span>
            </div>
          )}

          {/* Best find */}
          {summary.bestFind && (
            <div
              className="flex items-center gap-2 rounded-lg bg-surface-muted px-3 py-2"
              data-testid="weekly-best-find"
            >
              <Star size={16} aria-hidden="true" className="text-score-green" />
              <div className="min-w-0 flex-1">
                <p className="text-xs text-foreground-secondary">
                  {t("dashboard.weeklyBestFind")}
                </p>
                <p className="truncate text-sm font-medium text-foreground">
                  {summary.bestFind.product_name}
                </p>
              </div>
              <ScorePill score={summary.bestFind.unhealthiness_score} />
            </div>
          )}

          {/* Score distribution sparkline */}
          <ScoreSparkline scores={summary.allScores} />
        </>
      )}
    </section>
  );
}

function ProductRow({
  product,
  subtitle,
  allergenWarnings = [],
}: Readonly<{
  product: {
    product_id: number;
    product_name: string;
    brand: string | null;
    category: string;
    unhealthiness_score: number | null;
    nutri_score_label: string | null;
    image_thumb_url?: string | null;
  };
  subtitle?: string;
  allergenWarnings?: AllergenWarning[];
}>) {
  return (
    <Link
      href={`/app/product/${product.product_id}`}
      className="card hover-lift-press flex items-center gap-3"
    >
      <ProductThumbnail
        imageUrl={product.image_thumb_url ?? null}
        productName={product.product_name}
        categorySlug={product.category}
        size="sm"
      />
      <NutriBadge grade={product.nutri_score_label} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-foreground">
          {product.product_name}
        </p>
        <p className="truncate text-xs text-foreground-secondary">
          {product.brand ?? product.category}
          {subtitle ? ` · ${subtitle}` : ""}
        </p>
        <AllergenChips warnings={allergenWarnings} />
      </div>
      <ScorePill score={product.unhealthiness_score} />
    </Link>
  );
}

function RecentlyViewedSection({
  products,
  allergenMap = {},
}: Readonly<{
  products: RecentlyViewedProduct[];
  allergenMap?: AllergenWarningMap;
}>) {
  const { t } = useTranslation();
  if (products.length === 0) return null;

  return (
    <section>
      <div className="mb-2 flex items-center justify-between lg:mb-3">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground lg:text-xl">
          <Eye size={20} aria-hidden="true" /> {t("dashboard.recentlyViewed")}
        </h2>
      </div>
      <div className="space-y-2 lg:space-y-3">
        {products.map((p) => (
          <ProductRow
            key={p.product_id}
            product={p}
            subtitle={new Date(p.viewed_at).toLocaleDateString()}
            allergenWarnings={allergenMap[p.product_id] ?? []}
          />
        ))}
      </div>
    </section>
  );
}

function EmptyDashboard() {
  return (
    <EmptyState
      variant="no-data"
      icon={<Home size={48} className="text-foreground-muted" />}
      titleKey="dashboard.welcome"
      descriptionKey="dashboard.welcomeDescription"
      action={{ labelKey: "dashboard.scanProduct", href: "/app/scan" }}
      secondaryAction={{
        labelKey: "dashboard.browseCategories",
        href: "/app/categories",
      }}
    />
  );
}

// ─── Main Page ──────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();

  const { data, isLoading, isError } = useQuery({
    queryKey: queryKeys.dashboard,
    queryFn: async () => {
      const result = await getDashboardData(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.dashboard,
  });

  useEffect(() => {
    track("dashboard_viewed");
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Batch-fetch allergen data for recently viewed products
  // Hook must be called unconditionally (before early returns).
  const allProductIds = useMemo(
    () => (data ? data.recently_viewed.map((p) => p.product_id) : []),
    [data],
  );
  const allergenMap = useProductAllergenWarnings(allProductIds);

  const handleRefresh = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: queryKeys.dashboard });
  }, [queryClient]);

  if (isLoading) {
    return <DashboardSkeleton />;
  }

  if (isError || !data) {
    return (
      <EmptyState
        variant="error"
        titleKey="dashboard.errorMessage"
        action={{
          labelKey: "common.tryAgain",
          onClick: () => {
            queryClient.invalidateQueries({
              queryKey: queryKeys.dashboard,
            });
          },
        }}
      />
    );
  }

  const dashboard = data;

  const hasContent =
    dashboard.recently_viewed.length > 0 ||
    dashboard.stats.total_viewed > 0 ||
    dashboard.stats.total_scanned > 0;

  if (!hasContent) {
    return <EmptyDashboard />;
  }

  return (
    <PullToRefresh onRefresh={handleRefresh}>
    <div className="space-y-6 lg:space-y-8">
      {/* Hero — greeting + summary */}
      <div className="space-y-4">
        <DashboardGreeting />
        <SummaryCard
          stats={dashboard.stats}
          recentlyViewed={dashboard.recently_viewed}
          favoritesPreview={dashboard.favorites_preview}
        />
      </div>

      {/* Quick actions */}
      <QuickActions />

      {/* Recently viewed */}
      {dashboard.recently_viewed.length > 0 && (
        <ErrorBoundary
          level="section"
          context={{ section: "recently-viewed" }}
        >
          <RecentlyViewedSection
            products={dashboard.recently_viewed}
            allergenMap={allergenMap}
          />
        </ErrorBoundary>
      )}
    </div>
    </PullToRefresh>
  );
}
