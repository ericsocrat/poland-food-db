"use client";

import Link from "next/link";
import { useEffect } from "react";
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
import {
  Camera,
  Eye,
  ClipboardList,
  Heart,
  Sparkles,
  Home,
} from "lucide-react";
import type {
  DashboardData,
  DashboardFavoritePreview,
  DashboardNewProduct,
  DashboardStats,
  RecentlyViewedProduct,
} from "@/lib/types";

// ─── Helpers ────────────────────────────────────────────────────────────────

function ScorePill({ score }: { score: number | null }) {
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

function NutriBadge({ grade }: { grade: string | null }) {
  if (!grade) return null;
  return <NutriScoreBadge grade={grade} size="sm" />;
}

// ─── Section Components ─────────────────────────────────────────────────────

function StatsBar({ stats }: { stats: DashboardStats }) {
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
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 lg:gap-4">
      {items.map((s) => (
        <Link
          key={s.label}
          href={s.href}
          className="card flex flex-col items-center gap-1 py-3 transition-shadow hover:bg-surface-subtle hover:shadow-md"
        >
          <span className="flex items-center justify-center">
            <s.icon size={28} aria-hidden="true" />
          </span>
          <span className="text-xl font-bold tabular-nums text-foreground lg:text-2xl">
            {s.value}
          </span>
          <span className="text-xs text-foreground-secondary lg:text-sm">
            {s.label}
          </span>
        </Link>
      ))}
    </div>
  );
}

function ProductRow({
  product,
  subtitle,
}: {
  product: {
    product_id: number;
    product_name: string;
    brand: string | null;
    category: string;
    unhealthiness_score: number | null;
    nutri_score_label: string | null;
  };
  subtitle?: string;
}) {
  return (
    <Link
      href={`/app/product/${product.product_id}`}
      className="card hover-lift-press flex items-center gap-3"
    >
      <NutriBadge grade={product.nutri_score_label} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-foreground">
          {product.product_name}
        </p>
        <p className="truncate text-xs text-foreground-secondary">
          {product.brand ?? product.category}
          {subtitle ? ` · ${subtitle}` : ""}
        </p>
      </div>
      <ScorePill score={product.unhealthiness_score} />
    </Link>
  );
}

function RecentlyViewedSection({
  products,
}: {
  products: RecentlyViewedProduct[];
}) {
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
          />
        ))}
      </div>
    </section>
  );
}

function FavoritesSection({
  products,
}: {
  products: DashboardFavoritePreview[];
}) {
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
          className="text-sm font-medium text-brand-600 hover:text-brand-700"
        >
          {t("dashboard.viewAll")}
        </Link>
      </div>
      <div className="space-y-2 lg:space-y-3">
        {products.map((p) => (
          <ProductRow key={p.product_id} product={p} />
        ))}
      </div>
    </section>
  );
}

function NewProductsSection({
  products,
  category,
}: {
  products: DashboardNewProduct[];
  category: string | null;
}) {
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
          className="text-sm font-medium text-brand-600 hover:text-brand-700"
        >
          {t("dashboard.browse")}
        </Link>
      </div>
      <div className="space-y-2 lg:space-y-3">
        {products.map((p) => (
          <ProductRow key={p.product_id} product={p} />
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
          onClick: () =>
            queryClient.invalidateQueries({ queryKey: queryKeys.dashboard }),
        }}
      />
    );
  }

  const dashboard = data as DashboardData;
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

      {/* Row 4 — Recently Viewed (8) + New Products (4) */}
      {dashboard.recently_viewed.length > 0 && (
        <div className="lg:col-span-8">
          <ErrorBoundary
            level="section"
            context={{ section: "recently-viewed" }}
          >
            <RecentlyViewedSection products={dashboard.recently_viewed} />
          </ErrorBoundary>
        </div>
      )}
      {dashboard.new_products.length > 0 && (
        <div className="lg:col-span-4">
          <ErrorBoundary
            level="section"
            context={{ section: "new-products" }}
          >
            <NewProductsSection
              products={dashboard.new_products}
              category={dashboard.stats.most_viewed_category}
            />
          </ErrorBoundary>
        </div>
      )}

      {/* Row 5 — Favorites (full width) */}
      {dashboard.favorites_preview.length > 0 && (
        <div className="lg:col-span-12">
          <ErrorBoundary level="section" context={{ section: "favorites" }}>
            <FavoritesSection products={dashboard.favorites_preview} />
          </ErrorBoundary>
        </div>
      )}
    </div>
  );
}
