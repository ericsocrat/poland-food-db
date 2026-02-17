"use client";

// ─── Category listing — paginated product list for a single category ────────

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getCategoryListing } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { CategoryListingSkeleton } from "@/components/common/skeletons";
import { EmptyState } from "@/components/common/EmptyState";
import { HealthWarningBadge } from "@/components/product/HealthWarningsCard";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { formatSlug } from "@/lib/validation";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import type { CategoryProduct } from "@/lib/types";

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
  const { track } = useAnalytics();

  useEffect(() => {
    if (slug) {
      track("category_viewed", { category: slug });
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

  const totalPages = data ? Math.ceil(data.total_count / PAGE_SIZE) : 0;
  const currentPage = Math.floor(offset / PAGE_SIZE) + 1;

  return (
    <div className="space-y-4">
      {/* Back link */}
      <Link
        href="/app/categories"
        className="inline-flex items-center gap-1 text-sm text-foreground-secondary hover:text-foreground"
      >
        <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
            clipRule="evenodd"
          />
        </svg>
        Categories
      </Link>

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

      {/* Sort controls */}
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
          className="rounded-lg border border px-3 py-2 text-sm text-foreground-secondary hover:bg-surface-subtle"
        >
          {sortDir === "asc" ? t("filters.asc") : t("filters.desc")}
        </button>
      </div>

      {/* Product list */}
      {isLoading && <CategoryListingSkeleton />}

      {!isLoading && error && (
        <EmptyState
          variant="error"
          titleKey="categories.loadFailed"
          action={{
            labelKey: "common.retry",
            onClick: () =>
              queryClient.invalidateQueries({
                queryKey: queryKeys.categoryListing(
                  slug,
                  sortBy,
                  sortDir,
                  offset,
                ),
              }),
          }}
        />
      )}

      {!isLoading && !error && data?.products.length === 0 && (
        <EmptyState variant="no-data" titleKey="categories.noProducts" />
      )}

      {!isLoading && !error && data && data.products.length > 0 && (
        <ul className="space-y-2">
          {data.products.map((p) => (
            <ProductRow key={p.product_id} product={p} />
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
  );
}

function ProductRow({ product }: Readonly<{ product: CategoryProduct }>) {
  const { t } = useTranslation();
  const band = SCORE_BANDS[product.score_band];
  const nutriClass = product.nutri_score
    ? NUTRI_COLORS[product.nutri_score]
    : "bg-surface-muted text-foreground-secondary";

  return (
    <Link href={`/app/product/${product.product_id}`}>
      <li className="card hover-lift-press flex items-center gap-3">
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
        >
          {product.unhealthiness_score}
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
        </div>

        {/* Health warning badge */}
        <HealthWarningBadge productId={product.product_id} />

        {/* Avoid badge */}
        <AvoidBadge productId={product.product_id} />

        {/* Favorites heart */}
        <AddToListMenu productId={product.product_id} compact />

        {/* Compare checkbox */}
        <CompareCheckbox productId={product.product_id} />

        <span
          className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
        >
          {product.nutri_score ?? "?"}
        </span>
      </li>
    </Link>
  );
}
