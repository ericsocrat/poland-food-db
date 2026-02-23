"use client";

import Link from "next/link";
import { useEffect, useMemo } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { useTranslation } from "@/lib/i18n";
import { getDashboardData } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { EmptyState } from "@/components/common/EmptyState";
import { DashboardSkeleton } from "@/components/common/skeletons";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { useAnalytics } from "@/hooks/use-analytics";
import { DashboardGreeting } from "@/components/dashboard/DashboardGreeting";
import { QuickActions } from "@/components/dashboard/QuickActions";
import { CategoriesBrowse } from "@/components/dashboard/CategoriesBrowse";
import { NutritionTip } from "@/components/dashboard/NutritionTip";
import { ScoreSparkline } from "@/components/dashboard/ScoreSparkline";
import { HealthInsightsPanel } from "@/components/dashboard/HealthInsightsPanel";
import { ProductThumbnail } from "@/components/common/ProductThumbnail";
import { AllergenChips } from "@/components/common/AllergenChips";
import {
  Camera,
  Eye,
  ClipboardList,
  Heart,
  Sparkles,
  Home,
  TrendingUp,
  Star,
  BarChart3,
} from "lucide-react";
import type {
  DashboardFavoritePreview,
  DashboardNewProduct,
  DashboardStats,
  RecentlyViewedProduct,
} from "@/lib/types";
import {
  useProductAllergenWarnings,
  type AllergenWarningMap,
} from "@/hooks/use-product-allergens";

// ─── Helpers ────────────────────────────────────────────────────────────────

function ScorePill({ score }: Readonly<{ score: number | null }>) {
  if (score == null) return null;
  const band = scoreBandFromScore(score);
  const cfg = SCORE_BANDS[band];
  return (
    <span
      className={`rounded-full px-2 py-0.5 text-xs font-semibold ${cfg.bg} ${cfg.color}`}
    >
      {score}
    </span>
  );
}

function NutriBadge({ grade }: Readonly<{ grade: string | null }>) {
  if (!grade) return null;
  return <NutriScoreBadge grade={grade} size="sm" />;
}

// ─── Section Components ─────────────────────────────────────────────────────

function StatsBar({ stats }: Readonly<{ stats: DashboardStats }>) {
  const { t } = useTranslation();
  const items = [
    {
      label: t("dashboard.scanned"),
      value: stats.total_scanned,
      icon: Camera,
      href: "/app/scan/history",
    },
    {
      label: t("dashboard.viewed"),
      value: stats.total_viewed,
      icon: Eye,
      href: "/app/search",
    },
    {
      label: t("dashboard.lists"),
      value: stats.lists_count,
      icon: ClipboardList,
      href: "/app/lists",
    },
    {
      label: t("dashboard.favorites"),
      value: stats.favorites_count,
      icon: Heart,
      href: "/app/lists",
      cta:
        stats.favorites_count === 0
          ? t("dashboard.favoritesEmptyCta")
          : undefined,
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 lg:gap-4">
      {items.map((s) => (
        <Link
          key={s.label}
          href={s.cta ? "/app/search" : s.href}
          className="card hover-lift-press flex flex-col items-center gap-1 py-3"
        >
          <span className="flex items-center justify-center">
            <s.icon size={28} aria-hidden="true" />
          </span>
          {s.cta ? (
            <span className="text-center text-sm text-foreground-secondary animate-pulse">
              {s.cta}
            </span>
          ) : (
            <span className="text-xl font-bold tabular-nums text-foreground lg:text-2xl">
              {s.value}
            </span>
          )}
          <span className="text-xs text-foreground-secondary lg:text-sm">
            {s.label}
          </span>
        </Link>
      ))}
    </div>
  );
}

function WeeklySummaryCard({
  recentlyViewed,
  favoritesPreview,
}: Readonly<{
  recentlyViewed: RecentlyViewedProduct[];
  favoritesPreview: DashboardFavoritePreview[];
}>) {
  const { t } = useTranslation();

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

  // Don't render if no activity this week
  if (summary.viewedCount === 0 && summary.favoritedCount === 0) return null;

  const avgBand =
    summary.avgScore == null
      ? null
      : SCORE_BANDS[scoreBandFromScore(summary.avgScore)];

  return (
    <section className="card space-y-3" data-testid="weekly-summary">
      <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground">
        <BarChart3 size={20} aria-hidden="true" />{" "}
        {t("dashboard.weeklySummary")}
      </h2>

      <div className="grid grid-cols-2 gap-3">
        {/* Products viewed this week */}
        <div className="flex items-center gap-2 rounded-lg bg-surface-muted px-3 py-2">
          <Eye size={16} aria-hidden="true" className="text-foreground-muted" />
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
            {summary.avgScore}
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
  allergenWarnings?: import("@/lib/allergen-matching").AllergenWarning[];
}>) {
  return (
    <Link
      href={`/app/product/${product.product_id}`}
      className="card hover-lift-press flex items-center gap-3"
    >
      <ProductThumbnail
        imageUrl={product.image_thumb_url ?? null}
        productName={product.product_name}
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

function FavoritesSection({
  products,
  allergenMap = {},
}: Readonly<{
  products: DashboardFavoritePreview[];
  allergenMap?: AllergenWarningMap;
}>) {
  const { t } = useTranslation();
  if (products.length === 0) return null;

  return (
    <section>
      <div className="mb-2 flex items-center justify-between lg:mb-3">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground lg:text-xl">
          <Heart size={20} aria-hidden="true" /> {t("dashboard.favorites")}
        </h2>
        <Link
          href="/app/lists"
          className="text-sm font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.viewAll")}
        </Link>
      </div>
      <div className="space-y-2 lg:space-y-3">
        {products.map((p) => (
          <ProductRow
            key={p.product_id}
            product={p}
            allergenWarnings={allergenMap[p.product_id] ?? []}
          />
        ))}
      </div>
    </section>
  );
}

function NewProductsSection({
  products,
  category,
  allergenMap = {},
}: Readonly<{
  products: DashboardNewProduct[];
  category: string | null;
  allergenMap?: AllergenWarningMap;
}>) {
  const { t } = useTranslation();
  if (products.length === 0) return null;

  return (
    <section>
      <div className="mb-2 flex items-center justify-between lg:mb-3">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground lg:text-xl">
          <Sparkles size={20} aria-hidden="true" />{" "}
          {category
            ? t("dashboard.newInCategory", { category })
            : t("dashboard.newProducts")}
        </h2>
        <Link
          href="/app/categories"
          className="text-sm font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.browse")}
        </Link>
      </div>
      <div className="space-y-2 lg:space-y-3">
        {products.map((p) => (
          <ProductRow
            key={p.product_id}
            product={p}
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

  // Batch-fetch allergen data for all dashboard products (#128)
  // Hook must be called unconditionally (before early returns).
  const allProductIds = useMemo(
    () =>
      data
        ? [
            ...data.recently_viewed.map((p) => p.product_id),
            ...data.favorites_preview.map((p) => p.product_id),
            ...data.new_products.map((p) => p.product_id),
          ]
        : [],
    [data],
  );
  const allergenMap = useProductAllergenWarnings(allProductIds);

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
    dashboard.favorites_preview.length > 0 ||
    dashboard.new_products.length > 0;

  if (!hasContent) {
    return <EmptyDashboard />;
  }

  return (
    <div className="space-y-6 lg:grid lg:grid-cols-12 lg:gap-6 lg:space-y-0">
      {/* Row 1 — Greeting (full width) */}
      <div className="lg:col-span-12">
        <DashboardGreeting />
      </div>

      {/* Row 2 — Quick Actions (8) + Stats Summary (4) */}
      <div className="lg:col-span-8">
        <QuickActions />
      </div>
      <div className="lg:col-span-4">
        <StatsBar stats={dashboard.stats} />
      </div>

      {/* Row 2.5 — Weekly Summary (full width) */}
      <div className="lg:col-span-12">
        <WeeklySummaryCard
          recentlyViewed={dashboard.recently_viewed}
          favoritesPreview={dashboard.favorites_preview}
        />
      </div>

      {/* Row 3 — Categories (6) + Daily Tip (6) */}
      <div className="lg:col-span-6">
        <ErrorBoundary
          level="section"
          context={{ section: "categories-browse" }}
        >
          <CategoriesBrowse />
        </ErrorBoundary>
      </div>
      <div className="lg:col-span-6">
        <ErrorBoundary level="section" context={{ section: "nutrition-tip" }}>
          <NutritionTip />
        </ErrorBoundary>
      </div>

      {/* Row 3.5 — Health Insights Panel (full width) */}
      <div className="lg:col-span-12">
        <ErrorBoundary level="section" context={{ section: "health-insights" }}>
          <HealthInsightsPanel />
        </ErrorBoundary>
      </div>

      {/* Row 4 — Recently Viewed (8) + New Products (4) */}
      {dashboard.recently_viewed.length > 0 && (
        <div className="lg:col-span-8">
          <ErrorBoundary
            level="section"
            context={{ section: "recently-viewed" }}
          >
            <RecentlyViewedSection
              products={dashboard.recently_viewed}
              allergenMap={allergenMap}
            />
          </ErrorBoundary>
        </div>
      )}
      {dashboard.new_products.length > 0 && (
        <div className="lg:col-span-4">
          <ErrorBoundary level="section" context={{ section: "new-products" }}>
            <NewProductsSection
              products={dashboard.new_products}
              category={dashboard.stats.most_viewed_category}
              allergenMap={allergenMap}
            />
          </ErrorBoundary>
        </div>
      )}

      {/* Row 5 — Favorites (full width) */}
      {dashboard.favorites_preview.length > 0 && (
        <div className="lg:col-span-12">
          <ErrorBoundary level="section" context={{ section: "favorites" }}>
            <FavoritesSection
              products={dashboard.favorites_preview}
              allergenMap={allergenMap}
            />
          </ErrorBoundary>
        </div>
      )}
    </div>
  );
}
