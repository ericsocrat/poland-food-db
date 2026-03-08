"use client";

// ─── Category listing — paginated product list for a single category ────────

import { AllergenChips } from "@/components/common/AllergenChips";
import { EmptyState } from "@/components/common/EmptyState";
import { NutriScoreBadge } from "@/components/common/NutriScoreBadge";
import { ProductThumbnail } from "@/components/common/ProductThumbnail";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { CategoryListingSkeleton } from "@/components/common/skeletons";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { HealthWarningBadge } from "@/components/product/HealthWarningsCard";
import { useAnalytics } from "@/hooks/use-analytics";
import { useProductAllergenWarnings } from "@/hooks/use-product-allergens";
import type { AllergenWarning } from "@/lib/allergen-matching";
import { getCategoryListing, getCategoryOverview } from "@/lib/api";
import { SCORE_BANDS } from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import type { CategoryOverviewItem, CategoryProduct } from "@/lib/types";
import { formatSlug } from "@/lib/validation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";

// ─── View mode ──────────────────────────────────────────────────────────────

type ViewMode = "compact" | "detailed";

const VIEW_MODE_KEY = "tryvit:category-view-mode";

function getStoredViewMode(): ViewMode {
  if (typeof window === "undefined") return "compact";
  const val = localStorage.getItem(VIEW_MODE_KEY);
  return val === "detailed" ? "detailed" : "compact";
}

function setStoredViewMode(mode: ViewMode) {
  localStorage.setItem(VIEW_MODE_KEY, mode);
}

const PAGE_SIZE = 20;

const SORT_OPTIONS_KEYS = [
  { value: "score", labelKey: "categories.healthiness" },
  { value: "name", labelKey: "filters.name" },
  { value: "calories", labelKey: "filters.calories" },
] as const;

export default function CategoryListingPage() {
  const params = useParams();
  const slug = String(params.slug ?? "");
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();

  const [sortBy, setSortBy] = useState("score");
  const [sortDir, setSortDir] = useState("asc");
  const [offset, setOffset] = useState(0);
  const [viewMode, setViewMode] = useState<ViewMode>("compact");
  const { track } = useAnalytics();

  // Hydrate view mode from localStorage on mount
  useEffect(() => {
    setViewMode(getStoredViewMode());
  }, []);

  const toggleViewMode = useCallback(() => {
    setViewMode((prev) => {
      const next: ViewMode = prev === "compact" ? "detailed" : "compact";
      setStoredViewMode(next);
      return next;
    });
  }, []);

  useEffect(() => {
    if (slug) {
      track("category_viewed", { category: slug });
      void eventBus.emit({
        type: "category.viewed",
        payload: { categorySlug: slug },
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slug]);

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.categoryListing(slug, sortBy, sortDir, offset),
    queryFn: async () => {
      const result = await getCategoryListing(supabase, {
        p_category: slug,
        p_sort_by: sortBy,
        p_sort_dir: sortDir,
        p_limit: PAGE_SIZE,
        p_offset: offset,
      });
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.categoryListing,
  });

  // Batch-fetch allergen data for current page (#128)
  const allergenMap = useProductAllergenWarnings(
    data?.products.map((p) => p.product_id) ?? [],
  );

  // Reuse cached category overview for summary stats
  const { data: overviewData } = useQuery({
    queryKey: queryKeys.categoryOverview,
    queryFn: async () => {
      const result = await getCategoryOverview(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.categoryOverview,
  });

  const categoryStats = overviewData?.find(
    (c: CategoryOverviewItem) => c.slug === slug,
  );

  const totalPages = data ? Math.ceil(data.total_count / PAGE_SIZE) : 0;
  const currentPage = Math.floor(offset / PAGE_SIZE) + 1;

  const handleRefresh = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: queryKeys.categoryListing(slug, sortBy, sortDir, offset) });
  }, [queryClient, slug, sortBy, sortDir, offset]);

  return (
    <PullToRefresh onRefresh={handleRefresh}>
    <div className="space-y-4">
      {/* Breadcrumbs */}
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "categories.title", href: "/app/categories" },
          { label: formatSlug(slug) },
        ]}
      />

      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold capitalize text-foreground">
          {formatSlug(slug)}
        </h1>
        {data && (
          <span className="text-sm text-foreground-secondary">
            {t("common.products", { count: data.total_count })}
          </span>
        )}
      </div>

      {/* Summary stats */}
      {categoryStats && <CategoryStatsCard stats={categoryStats} />}

      {/* Sort & view controls */}
      <div className="flex items-center gap-2">
        <select
          value={sortBy}
          onChange={(e) => {
            setSortBy(e.target.value);
            setOffset(0);
          }}
          className="input-field text-sm"
        >
          {SORT_OPTIONS_KEYS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {t(opt.labelKey)}
            </option>
          ))}
        </select>
        <button
          onClick={() => {
            setSortDir((d) => (d === "asc" ? "desc" : "asc"));
            setOffset(0);
          }}
          className="rounded-lg border border-border px-3 py-2 text-sm text-foreground-secondary hover:bg-surface-subtle"
          aria-label={t("categories.toggleSortDirection")}
        >
          {sortDir === "asc" ? t("filters.asc") : t("filters.desc")}
        </button>

        <div className="ml-auto">
          <button
            onClick={toggleViewMode}
            className="rounded-lg border border-border px-3 py-2 text-sm text-foreground-secondary hover:bg-surface-subtle"
            aria-label={t("categories.toggleViewMode")}
          >
            {viewMode === "compact"
              ? t("categories.detailedView")
              : t("categories.compactView")}
          </button>
        </div>
      </div>

      {/* Product list */}
      {isLoading && <CategoryListingSkeleton />}

      {!isLoading && error && (
        <EmptyState
          variant="error"
          titleKey="categories.loadFailed"
          action={{
            labelKey: "common.retry",
            onClick: () => {
              queryClient.invalidateQueries({
                queryKey: queryKeys.categoryListing(
                  slug,
                  sortBy,
                  sortDir,
                  offset,
                ),
              });
            },
          }}
        />
      )}

      {!isLoading && !error && data?.products.length === 0 && (
        <EmptyState variant="no-data" titleKey="categories.noProducts" />
      )}

      {!isLoading && !error && data && data.products.length > 0 && (
        <ul className="space-y-2">
          {data.products.map((p) => (
            <ProductRow
              key={p.product_id}
              product={p}
              allergenWarnings={allergenMap[p.product_id] ?? []}
              viewMode={viewMode}
              categorySlug={slug}
            />
          ))}
        </ul>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 pt-2">
          <button
            disabled={offset === 0}
            onClick={() => setOffset((o) => Math.max(0, o - PAGE_SIZE))}
            className="btn-secondary text-sm"
          >
            {t("categories.previous")}
          </button>
          <span className="text-sm text-foreground-secondary">
            {t("common.pageOf", { page: currentPage, pages: totalPages })}
          </span>
          <button
            disabled={currentPage >= totalPages}
            onClick={() => setOffset((o) => o + PAGE_SIZE)}
            className="btn-secondary text-sm"
          >
            {t("common.next")}
          </button>
        </div>
      )}
    </div>
    </PullToRefresh>
  );
}

function ProductRow({
  product,
  allergenWarnings = [],
  viewMode = "compact",
  categorySlug,
}: Readonly<{
  product: CategoryProduct;
  allergenWarnings?: AllergenWarning[];
  viewMode?: ViewMode;
  categorySlug?: string;
}>) {
  const { t } = useTranslation();
  const band = SCORE_BANDS[product.score_band];

  if (viewMode === "compact") {
    return (
      <Link href={`/app/product/${product.product_id}`}>
        <li className="card hover-lift-press flex items-center gap-3 py-3">
          <ProductThumbnail
            imageUrl={product.image_thumb_url}
            productName={product.product_name}
            categorySlug={categorySlug}
            size="md"
          />
          <div className="min-w-0 flex-1">
            <p className="truncate font-medium text-foreground">
              {product.product_name}
            </p>
            <p className="truncate text-sm text-foreground-secondary">
              {product.brand}
            </p>
          </div>
          <div
            className={`flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg text-sm font-bold ${band.bg} ${band.color}`}
          >
            {toTryVitScore(product.unhealthiness_score)}
          </div>
          <NutriScoreBadge grade={product.nutri_score} size="sm" showTooltip />
        </li>
      </Link>
    );
  }

  // Detailed view — full data per row (power-user mode)
  return (
    <Link href={`/app/product/${product.product_id}`}>
      <li className="card hover-lift-press flex items-center gap-3">
        <ProductThumbnail
          imageUrl={product.image_thumb_url}
          productName={product.product_name}
          categorySlug={categorySlug}
          size="sm"
        />
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
        >
          {toTryVitScore(product.unhealthiness_score)}
        </div>
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-foreground">
            {product.product_name}
          </p>
          <p className="text-sm text-foreground-secondary">
            {product.brand} &middot; {product.calories} kcal
          </p>
          <div className="mt-1 flex flex-wrap gap-1">
            {product.high_sugar_flag && (
              <span className="rounded bg-red-50 px-1.5 py-0.5 text-xs text-red-600">
                {t("product.highSugar")}
              </span>
            )}
            {product.high_salt_flag && (
              <span className="rounded bg-red-50 px-1.5 py-0.5 text-xs text-red-600">
                {t("product.highSalt")}
              </span>
            )}
            {product.high_sat_fat_flag && (
              <span className="rounded bg-red-50 px-1.5 py-0.5 text-xs text-red-600">
                {t("product.highSatFat")}
              </span>
            )}
          </div>
          {/* Allergen warnings */}
          <AllergenChips warnings={allergenWarnings} />
        </div>

        {/* Health warning badge */}
        <HealthWarningBadge productId={product.product_id} />

        {/* Avoid badge */}
        <AvoidBadge productId={product.product_id} />

        {/* Favorites heart */}
        <AddToListMenu productId={product.product_id} compact />

        {/* Compare checkbox */}
        <CompareCheckbox
          productId={product.product_id}
          productName={product.product_name}
        />

        <NutriScoreBadge grade={product.nutri_score} size="sm" showTooltip />
      </li>
    </Link>
  );
}

/* ── Category Summary Stats Card ──────────────────────────────────────────── */

function CategoryStatsCard({
  stats,
}: Readonly<{ stats: CategoryOverviewItem }>) {
  const { t } = useTranslation();

  return (
    <div className="card grid grid-cols-2 gap-3 sm:grid-cols-4">
      <div className="text-center">
        <p className="text-lg font-bold text-foreground">
          {Math.round(stats.avg_score)}
        </p>
        <p className="text-xs text-foreground-secondary">
          {t("categories.statAvgScore")}
        </p>
      </div>
      <div className="text-center">
        <p className="text-lg font-bold text-foreground">
          {stats.min_score}–{stats.max_score}
        </p>
        <p className="text-xs text-foreground-secondary">
          {t("categories.scoreRange")}
        </p>
      </div>
      <div className="text-center">
        <p className="text-lg font-bold text-confidence-high">
          {Math.round(stats.pct_nutri_a_b)}%
        </p>
        <p className="text-xs text-foreground-secondary">
          {t("categories.nutriAB")}
        </p>
      </div>
      <div className="text-center">
        <p className="text-lg font-bold text-warning">
          {Math.round(stats.pct_nova_4)}%
        </p>
        <p className="text-xs text-foreground-secondary">
          {t("categories.nova4Pct")}
        </p>
      </div>
    </div>
  );
}
