"use client";

import Link from "next/link";
import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { useTranslation } from "@/lib/i18n";
import { getDashboardData } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { NUTRI_COLORS, SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useAnalytics } from "@/hooks/use-analytics";
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
      className={`flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold ${NUTRI_COLORS[grade] ?? "bg-gray-200 text-gray-600"}`}
    >
      {grade}
    </span>
  );
}

// ─── Section Components ─────────────────────────────────────────────────────

function StatsBar({ stats }: { stats: DashboardStats }) {
  const { t } = useTranslation();
  const items = [
    { label: t("dashboard.scanned"), value: stats.total_scanned, icon: "📷" },
    { label: t("dashboard.viewed"), value: stats.total_viewed, icon: "👁️" },
    { label: t("dashboard.lists"), value: stats.lists_count, icon: "📋" },
    {
      label: t("dashboard.favorites"),
      value: stats.favorites_count,
      icon: "❤️",
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {items.map((s) => (
        <div
          key={s.label}
          className="card flex flex-col items-center gap-1 py-3"
        >
          <span className="text-2xl">{s.icon}</span>
          <span className="text-xl font-bold text-gray-900">{s.value}</span>
          <span className="text-xs text-gray-500">{s.label}</span>
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
      className="card flex items-center gap-3 transition-shadow hover:shadow-md"
    >
      <NutriBadge grade={product.nutri_score_label} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-gray-900">
          {product.product_name}
        </p>
        <p className="truncate text-xs text-gray-500">
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
        <h2 className="text-lg font-semibold text-gray-900">
          👁️ {t("dashboard.recentlyViewed")}
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
        <h2 className="text-lg font-semibold text-gray-900">
          ❤️ {t("dashboard.favorites")}
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
        <h2 className="text-lg font-semibold text-gray-900">
          ✨{" "}
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
  const { t } = useTranslation();
  return (
    <div className="py-12 text-center">
      <p className="text-4xl">🏠</p>
      <h2 className="mt-4 text-lg font-semibold text-gray-900">
        {t("dashboard.welcome")}
      </h2>
      <p className="mt-2 text-sm text-gray-500">
        {t("dashboard.welcomeDescription")}
      </p>
      <div className="mt-6 flex justify-center gap-3">
        <Link href="/app/scan" className="btn-primary">
          📷 {t("dashboard.scanProduct")}
        </Link>
        <Link href="/app/categories" className="btn-secondary">
          {t("dashboard.browseCategories")}
        </Link>
      </div>
    </div>
  );
}

// ─── Main Page ──────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const supabase = createClient();
  const { t } = useTranslation();
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
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (isError || !data) {
    return (
      <div className="card border-red-200 bg-red-50 py-8 text-center">
        <p className="text-sm text-red-600">{t("dashboard.errorMessage")}</p>
        <button
          className="btn-primary mt-4"
          onClick={() => window.location.reload()}
        >
          {t("common.tryAgain")}
        </button>
      </div>
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
      <h1 className="text-xl font-bold text-gray-900">
        {t("dashboard.title")}
      </h1>

      <StatsBar stats={dashboard.stats} />

      <RecentlyViewedSection products={dashboard.recently_viewed} />

      <FavoritesSection products={dashboard.favorites_preview} />

      <NewProductsSection
        products={dashboard.new_products}
        category={dashboard.stats.most_viewed_category}
      />
    </div>
  );
}
