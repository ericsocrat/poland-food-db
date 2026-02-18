"use client";

import Link from "next/link";
import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { useTranslation } from "@/lib/i18n";
import { getDashboardData } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { NUTRI_COLORS, SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
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
  return (
    <span
      className={`flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold ${NUTRI_COLORS[grade] ?? "bg-surface-muted text-foreground-secondary"}`}
    >
      {grade}
    </span>
  );
}

// ─── Section Components ─────────────────────────────────────────────────────

function StatsBar({ stats }: { stats: DashboardStats }) {
  const { t } = useTranslation();
  const items = [
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

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {items.map((s) => (
        <div
          key={s.label}
          className="card flex flex-col items-center gap-1 py-3"
        >
          <span className="flex items-center justify-center">
            <s.icon size={28} aria-hidden="true" />
          </span>
          <span className="text-xl font-bold text-foreground">{s.value}</span>
          <span className="text-xs text-foreground-secondary">{s.label}</span>
        </div>
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
      <div className="mb-2 flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground">
          <Eye size={20} aria-hidden="true" /> {t("dashboard.recentlyViewed")}
        </h2>
      </div>
      <div className="space-y-2">
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
      <div className="mb-2 flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground">
          <Heart size={20} aria-hidden="true" /> {t("dashboard.favorites")}
        </h2>
        <Link
          href="/app/lists"
          className="text-sm font-medium text-brand-600 hover:text-brand-700"
        >
          {t("dashboard.viewAll")}
        </Link>
      </div>
      <div className="space-y-2">
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
      <div className="mb-2 flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-lg font-semibold text-foreground">
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
      <div className="space-y-2">
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
          onClick: () => window.location.reload(),
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
    <div className="space-y-6">
      {/* Personalised greeting */}
      <DashboardGreeting />

      {/* Primary action buttons */}
      <QuickActions />

      {/* Horizontal category chips */}
      <ErrorBoundary level="section" context={{ section: "categories-browse" }}>
        <CategoriesBrowse />
      </ErrorBoundary>

      {/* Stats overview */}
      <StatsBar stats={dashboard.stats} />

      {/* Daily nutrition tip */}
      <ErrorBoundary level="section" context={{ section: "nutrition-tip" }}>
        <NutritionTip />
      </ErrorBoundary>

      <ErrorBoundary level="section" context={{ section: "recently-viewed" }}>
        <RecentlyViewedSection products={dashboard.recently_viewed} />
      </ErrorBoundary>

      <ErrorBoundary level="section" context={{ section: "favorites" }}>
        <FavoritesSection products={dashboard.favorites_preview} />
      </ErrorBoundary>

      <ErrorBoundary level="section" context={{ section: "new-products" }}>
        <NewProductsSection
          products={dashboard.new_products}
          category={dashboard.stats.most_viewed_category}
        />
      </ErrorBoundary>
    </div>
  );
}
